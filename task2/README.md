# Prometheus Alert: `MysqlTransactionDeadlock`

This Prometheus alert detects potential **MySQL InnoDB row-level lock contention**, which can indicate transaction blocking or performance issues.

---

## Alert Rule

## 🔔 Alert Rule

```yaml
- alert: MysqlTransactionDeadlock
  expr: increase(mysql_global_status_innodb_row_lock_waits[2m]) > 0
  for: 3m
  labels:
    severity: warning
  annotations:
    dashboard: database-metrics
    summary: 'Mysql Transaction Waits'
    description: 'There are {{ $value | humanize }} MySQL connections waiting for a stale transaction to release.'


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
