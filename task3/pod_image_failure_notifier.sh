#!/bin/bash

# Kubernetes Slack Notifier – Deduplicated (10 min), Polling (5 min)

set -e

SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:?SLACK webhook URL is not set}"
KUBECONFIG="${KUBECONFIG:?KUBECONFIG is not set}"

DEBUG_LOG="/var/log/k8s-slack-notifier-debug.log"
DEDUP_LOG="/var/tmp/k8s_last_alerts.log"
DEDUP_INTERVAL=600  # 10 minutes
POLL_INTERVAL=300   # 5 minutes

touch "$DEBUG_LOG" "$DEDUP_LOG"

log() {
  echo "[$(TZ=UTC date '+%Y-%m-%d %H:%M:%S UTC')] $1" | tee -a "$DEBUG_LOG"
}

send_slack_notification() {
  local pod_name="$1"
  local namespace="$2"
  local reason="$3"
  local timestamp
  timestamp=$(TZ=UTC date '+%Y-%m-%d %H:%M:%S UTC')

  local message=":rotating_light: *Kubernetes Pod Failure Detected*\n\`\`\`\nPod: ${pod_name}\nNamespace: ${namespace}\nReason: ${reason}\nTime: ${timestamp} UTC\n\`\`\`"
  local payload
  payload=$(printf '{"text": "%b"}' "$message")

  log "👉 Payload built: $payload"

  curl_response=$(curl -s -w "%{http_code}" -o /dev/null -X POST \
    -H 'Content-type: application/json' \
    --data "$payload" \
    "$SLACK_WEBHOOK_URL")

  if [[ "$curl_response" == "200" ]]; then
    log "✅ Slack message sent successfully"
  else
    log "❌ Slack webhook failed (status code: $curl_response)"
    log "Payload was: $payload"
  fi
}

should_alert() {
  local key="$1"
  local now
  now=$(date +%s)

  local last_line
  last_line=$(grep "^${key}|" "$DEDUP_LOG" | tail -n1 || true)

  if [[ -n "$last_line" ]]; then
    local last_time
    last_time=$(echo "$last_line" | awk -F'|' '{print $3}')
    if [[ "$last_time" =~ ^[0-9]+$ ]]; then
      local diff=$((now - last_time))
      if (( diff < DEDUP_INTERVAL )); then
        log "⏱️ Skipping alert for $key (last was $diff seconds ago)"
        return 1
      fi
    else
      log "⚠️ Invalid timestamp for $key: '$last_time', ignoring dedup."
    fi
  fi

  # update the timestamp
  sed -i "/^${key}|/d" "$DEDUP_LOG"
  echo "${key}|${now}" >> "$DEDUP_LOG"
  return 0
}

log "🔁 Polling Kubernetes events every ${POLL_INTERVAL} seconds (dedup = ${DEDUP_INTERVAL} seconds)..."

while true; do
  mapfile -t events < <(minikube kubectl -- get events -A -o json | jq -c '.items[]')

  for event in "${events[@]}"; do
    reason=$(jq -r '.reason' <<< "$event")
    [[ "$reason" =~ ^(BackOff|Failed)$ ]] || continue

    pod_name=$(jq -r '.involvedObject.name' <<< "$event")
    namespace=$(jq -r '.involvedObject.namespace' <<< "$event")
    key="${namespace}/${pod_name}|${reason}"

    log "🔑 Generated dedup key: $key"

    if should_alert "$key"; then
      log "⚠️ ALERTING: $key"
      send_slack_notification "$pod_name" "$namespace" "$reason"
    fi
  done

  sleep "$POLL_INTERVAL"
done
