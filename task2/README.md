##Alert

```sh
  - alert: MysqlTransactionDeadlock
    expr: increase(mysql_global_status_innodb_row_lock_waits[2m]) > 0
    for: 3m
    labels:
      severity: warning
    annotations:
      dashboard: database-metrics
      summary: 'Mysql Transaction Waits'
    description: 'There are `{{ $value | humanize }}` MySQL connections waiting for a stale transaction to release.'
```

##Graph

![Graph Example](alert_example.png)

## What Each Line Means

| Line                                                                                       | Explanation                                                                                                                                                                                                 |
|--------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `- alert: MysqlTransactionDeadlock`                                                       | Defines the unique name of the alert. Helps Prometheus and Alertmanager identify and reference it.                                                                                                          |
| `expr: increase(mysql_global_status_innodb_row_lock_waits[2m]) > 0`                        | Triggers the alert if the number of InnoDB row lock waits has increased in the last 2 minutes. A value greater than 0 means at least one transaction has been blocked.                                      |
| `for: 3m`                                                                                  | Ensures the alert only fires if the condition stays true for 3 consecutive minutes. Reduces noise from short-lived spikes.                                                                                  |
| `labels:`                                                                                  | Metadata used to help organize, route, and filter alerts.                                                                                                                                                   |
| `severity: warning`                                                                       | Classifies this alert as a warning (non-critical but worth checking). Useful for routing alerts to the right notification channel.                                                                          |
| `annotations:`                                                                             | Human-readable context shown in dashboards and alerts.                                                                                                                                                      |
| `dashboard: database-metrics`                                                             | Refers to the name or ID of the related Grafana dashboard where metrics can be explored.                                                                                                                    |
| `summary: 'Mysql Transaction Waits'`                                                      | A short, descriptive title for the alert. Ideal for use in notifications or dashboard alert tables.                                                                                                         |
| `description: 'There are {{ $value | humanize }} MySQL connections waiting for a stale transaction to release.'` | Provides a clear explanation of the alert and includes dynamic data (e.g., how many connections are affected). Helps responders quickly understand the issue.                                 |

## 🔍 Alert Investigation & Optimization

This section explains how to handle and improve the `MysqlTransactionDeadlock` alert.

---

### How to Investigate the Cause

| Step | Action |
|------|--------|
| 1. Check current transactions | Use `SHOW ENGINE INNODB STATUS\G` to inspect current locks, waits, and active transactions. |
| 2. Inspect lock waits | Query `performance_schema.data_locks` to see which rows are locked and by whom. |
| 3. Find blocking queries | Use a join on `information_schema.innodb_lock_waits` and `innodb_trx` to identify blocking vs waiting transactions. |
| 4. Look for long-running transactions | Check for uncommitted or long transactions that may be holding locks too long. |
| 5. Investigate application behavior | Ensure your app commits promptly and avoids holding transactions open longer than necessary. |

---

### Recommended Alert Improvements

| Change | Reason |
|--------|--------|
| Update summary: <br> `summary: 'MySQL InnoDB Transaction Lock Waits Detected'` | Makes it more descriptive and helpful in alert dashboards or messages. |
| Update description: <br> `Detected {{ $value | humanize }} lock waits. Check for blocking transactions.` | Provides immediate context and next steps for responders. |
| Add labels: <br> `team: dba`, `service: mysql` | Helps route alerts to the right team and categorize them by service. |

---

### Avoiding Alert Fatigue

| Problem | Recommended Change | Why |
|--------|--------------------|-----|
| Too many alerts from brief or minor issues | Increase threshold: <br> `increase(...[5m]) > 3` | Avoids firing for every small lock wait event. |
| Alert firing from short spikes | Increase duration: <br> `for: 5m` | Only alerts if the issue persists, not for quick recoveries. |
| False positives | Combine with other metrics (e.g., lock time or deadlocks) | Ensures you're reacting to real impact, not just symptoms. |

---

### Alternative or Additional Metrics

| Metric | Description | When to Use |
|--------|-------------|-------------|
| `mysql_global_status_innodb_row_lock_time` | Total time (ms) spent waiting for row locks. | To detect **severity** of contention. |
| `mysql_global_status_innodb_row_lock_time_avg` | Average wait time per lock event. | To detect **slow** or inefficient waits. |
| `mysql_global_status_innodb_deadlocks` | Count of detected deadlocks. | For critical alerts, indicating transaction rollback occurred. |
| `mysql_global_status_threads_running` | Number of concurrent running threads. | To correlate system load with lock behavior. |

---

