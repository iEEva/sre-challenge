| Line(s)                                       | Explanation                                                                                   |
|----------------------------------------------|-----------------------------------------------------------------------------------------------|
| `#!/bin/bash`                                | Shebang to indicate this script should be run with the Bash shell                             |
| `# Kubernetes Slack Notifier...`             | Comment describing purpose: deduplicated notifications every 10 mins, polling every 5 mins    |
| `set -e`                                     | Exit immediately if any command exits with a non-zero status                                  |
|                                              |                                                                                               |
| `SLACK_WEBHOOK_URL=...`                      | Ensures the `SLACK_WEBHOOK_URL` is set, or exits with an error message                        |
| `KUBECONFIG=...`                             | Same as above: ensures the `KUBECONFIG` env var is set                                        |
|                                              |                                                                                               |
| `DEBUG_LOG="/var/log/k8s-slack-notifier...`  | Path for the debug log file where events and messages are logged                              |
| `DEDUP_LOG="/var/tmp/k8s_last_alerts.log"`   | File to cache sent alerts and their timestamps for deduplication                              |
| `DEDUP_INTERVAL=600`                         | Deduplication interval in seconds (10 minutes)                                                |
| `POLL_INTERVAL=300`                          | Polling interval in seconds (5 minutes)                                                       |
|                                              |                                                                                               |
| `touch "$DEBUG_LOG" "$DEDUP_LOG"`            | Ensures the log files exist; creates them if they don't                                       |
|                                              |                                                                                               |
| `log()` function                             | Utility function to prepend timestamps and write logs to both stdout and `DEBUG_LOG`          |
| `echo "[...]" | tee -a "$DEBUG_LOG"`         | Logs the message with UTC timestamp to screen and file                                        |
|                                              |                                                                                               |
| `send_slack_notification()` function         | Builds and sends a Slack alert using a webhook                                                |
| `local pod_name namespace reason`            | Arguments passed to the function: pod name, namespace, failure reason                         |
| `timestamp=$(...)`                           | Captures current UTC time in a readable format                                                |
| `message="..."`                              | Formats the Slack message as a Markdown code block                                            |
| `payload=$(printf ...)`                      | Wraps the message into a JSON payload for Slack                                               |
| `log "👉 Payload built..."`                  | Logs the final message payload                                                                |
| `curl_response=... curl ... "$SLACK_WEBHOOK_URL"` | Sends the payload via `curl`, silently capturing the HTTP response code                      |
| `if [[ "$curl_response" == "200" ]]`         | Checks if Slack accepted the message successfully                                             |
| `log "✅..." / "❌..."`                      | Logs success or failure based on Slack's response                                             |
|                                              |                                                                                               |
| `should_alert()` function                    | Checks if a deduplication key has been recently alerted; if not, it updates the cache         |
| `local key="$1"`                             | Unique deduplication key in the form `namespace/pod|reason`                                   |
| `now=$(date +%s)`                            | Gets current UNIX timestamp in seconds                                                        |
| `last_line=$(grep "^${key}|" "$DEDUP_LOG")`  | Looks up the latest entry for the key in the dedup log                                        |
| `if [[ -n "$last_line" ]]; then ...`         | If a record exists, extract and compare its timestamp                                         |
| `diff=$((now - last_time))`                  | Calculates how long ago the last alert was sent                                               |
| `if (( diff < DEDUP_INTERVAL ))`             | If it was too recent (<10 min), suppress the alert                                            |
| `sed -i "/^${key}|/d" "$DEDUP_LOG"`          | Otherwise, remove old entry (if any) from log                                                 |
| `echo "${key}|${now}" >> "$DEDUP_LOG"`       | And append a fresh timestamped entry                                                          |
| `return 0`                                   | Signals that we *should* send an alert                                                        |
|                                              |                                                                                               |
| `log "🔁 Polling Kubernetes events..."`       | Initial log message showing the polling and dedup intervals                                   |
| `while true; do`                             | Infinite loop to continuously poll for events                                                 |
| `mapfile -t events < <(minikube kubectl ...)`| Fetches all events from all namespaces, parsed into JSON, stored in `events[]` array          |
| `for event in "${events[@]}"; do`            | Iterates through each event returned                                                          |
| `reason=$(jq -r '.reason' <<< "$event")`     | Extracts the event's reason field using `jq`                                                  |
| `[[ "$reason" =~...`                          | Filters reasons                                                                               |
| `pod_name=$(jq -r ...)`                      | Extracts the pod name from the event                                                          |
| `namespace=$(jq -r ...)`                     | Extracts the namespace from the event                                                         |
| `key="${namespace}/${pod_name}|${reason}"`   | Builds the deduplication key                                                                 |
| `log "🔑 Generated dedup key..."`            | Logs the key for visibility                                                                   |
| `if should_alert "$key"; then`               | Calls the dedup check function                                                                |
| `send_slack_notification "$pod_name" ...`    | If allowed, sends the actual Slack alert                                                      |
| `fi`                                         | End of alert check                                                                            |
| `done`                                       | End of event loop                                                                             |
| `sleep "$POLL_INTERVAL"`                     | Waits 5 minutes before polling again                                                          |
| `done`                                       | End of main loop                                                                              |
