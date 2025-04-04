#!/bin/bash

# Kubernetes Slack Notifier – Deduplicated (10 min), Polling (5 min)

set -e  # Exit the script immediately if any command fails

# Required environment variables
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:?SLACK webhook URL is not set}"  # Webhook URL must be set or script exits
KUBECONFIG="${KUBECONFIG:?KUBECONFIG is not set}"                        # Path to kubeconfig must be set or script exits

# Log files and configuration
DEBUG_LOG="/var/log/k8s-slack-notifier-debug.log"   # Log file for debug output
DEDUP_LOG="/var/tmp/k8s_last_alerts.log"            # File to store last alerts for deduplication
DEDUP_INTERVAL=600  # Minimum time (in seconds) before resending the same alert (10 minutes)
POLL_INTERVAL=300   # How often to poll for events (in seconds) (5 minutes)

# Ensure log files exist
touch "$DEBUG_LOG" "$DEDUP_LOG"

# Function to write timestamped messages to log
log() {
  echo "[$(TZ=UTC date '+%Y-%m-%d %H:%M:%S UTC')] $1" | tee -a "$DEBUG_LOG"
}

# Function to send Slack alert message
send_slack_notification() {
  local pod_name="$1"      # Name of the failed pod
  local namespace="$2"     # Namespace where the pod is located
  local reason="$3"        # Reason for failure
  local timestamp
  timestamp=$(TZ=UTC date '+%Y-%m-%d %H:%M:%S UTC')  # Current UTC timestamp

  # Slack message payload
  local message=":rotating_light: *Kubernetes Pod Failure Detected*\n\`\`\`\nPod: ${pod_name}\nNamespace: ${namespace}\nReason: ${reason}\nTime: ${timestamp} UTC\n\`\`\`"
  local payload
  payload=$(printf '{"text": "%b"}' "$message")  # JSON format with escaped message

  log "👉 Payload built: $payload"  # Log payload being sent

  # Send to Slack webhook
  curl_response=$(curl -s -w "%{http_code}" -o /dev/null -X POST \
    -H 'Content-type: application/json' \
    --data "$payload" \
    "$SLACK_WEBHOOK_URL")

  # Check if the Slack request succeeded
  if [[ "$curl_response" == "200" ]]; then
    log "✅ Slack message sent successfully"
  else
    log "❌ Slack webhook failed (status code: $curl_response)"
    log "Payload was: $payload"
  fi
}

# Function to determine whether an alert should be sent (deduplication logic)
should_alert() {
  local key="$1"                      # Unique key per pod/namespace/reason
  local now
  now=$(date +%s)                     # Current UNIX timestamp

  # Retrieve the most recent matching alert timestamp from dedup log
  local last_line
  last_line=$(grep "^${key}|" "$DEDUP_LOG" | tail -n1 || true)

  if [[ -n "$last_line" ]]; then
    local last_time
    last_time=$(echo "$last_line" | awk -F'|' '{print $3}')  # Extract timestamp
    if [[ "$last_time" =~ ^[0-9]+$ ]]; then
      local diff=$((now - last_time))  # Time since last alert
      if (( diff < DEDUP_INTERVAL )); then
        log "⏱️ Skipping alert for $key (last was $diff seconds ago)"
        return 1  # Suppress alert
      fi
    else
      log "⚠️ Invalid timestamp for $key: '$last_time', ignoring dedup."
    fi
  fi

  # Update dedup log with current timestamp
  sed -i "/^${key}|/d" "$DEDUP_LOG"    # Remove previous entry
  echo "${key}|${now}" >> "$DEDUP_LOG" # Append new entry
  return 0  # Allow alert
}

# Initial log message showing the polling config
log "🔁 Polling Kubernetes events every ${POLL_INTERVAL} seconds (dedup = ${DEDUP_INTERVAL} seconds)..."

# Main loop to poll Kubernetes events
while true; do
  # Get all Kubernetes events as JSON and split into lines (one JSON object per event)
  mapfile -t events < <(minikube kubectl -- get events -A -o json | jq -c '.items[]')

  # Loop through each event
  for event in "${events[@]}"; do
    reason=$(jq -r '.reason' <<< "$event")  # Extract reason (e.g., Failed, BackOff)
    [[ "$reason" =~ ^(BackOff|Failed)$ ]] || continue  # Only process selected failure reasons

    pod_name=$(jq -r '.involvedObject.name' <<< "$event")         # Extract pod name
    namespace=$(jq -r '.involvedObject.namespace' <<< "$event")   # Extract namespace
    key="${namespace}/${pod_name}|${reason}"                      # Build unique dedup key

    log "🔑 Generated dedup key: $key"  # Log the dedup key

    if should_alert "$key"; then
      log "⚠️ ALERTING: $key"           # Log that alert will be sent
      send_slack_notification "$pod_name" "$namespace" "$reason"  # Send alert to Slack
    fi
  done

  sleep "$POLL_INTERVAL"  # Wait before polling again
done
