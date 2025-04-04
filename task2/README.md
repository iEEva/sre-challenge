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
|  description:       ...                                                                      | Provides a clear explanation of the alert and includes dynamic data (e.g., how many connections are affected). Helps responders quickly understand the issue.                                 |

## How to Investigate the Reason for the Alert

The alert is based on this PromQL expression:
increase(mysql_global_status_innodb_row_lock_waits[2m]) > 0 # This tells us that at least one InnoDB transaction had to wait for a row lock in the last 2 minutes. 

🔹 Investigating Root Cause
Command / Query	Purpose
SHOW ENGINE INNODB STATUS\G	Shows InnoDB internal engine report. Look for LATEST DETECTED DEADLOCK and TRANSACTIONS sections.
SELECT * FROM information_schema.innodb_locks;	Shows current row-level locks held by transactions.
SELECT * FROM information_schema.innodb_lock_waits;	Shows which transactions are waiting on other transactions’ locks.
SELECT * FROM information_schema.innodb_trx;	Displays active transactions, their state, age, and running queries. Useful for finding long transactions.
🔹 Query: innodb_locks

SELECT * FROM information_schema.innodb_locks;

Line	Explanation
SELECT *	Selects all columns (lock details).
FROM information_schema.innodb_locks;	Views all row locks currently held by active InnoDB transactions.
Purpose	Identifies which transactions are currently holding locks on specific rows/tables.
Use Case	Helps trace blocking transactions that may be holding up others.

Sample Output:
lock_id	lock_trx_id	lock_mode	lock_type	lock_table	lock_index	lock_data
123456	98765	X	RECORD	db.orders	PRIMARY	101

    lock_trx_id: Transaction ID holding the lock

    lock_mode: Lock type (X = exclusive, S = shared)

    lock_data: The locked row’s key or identifying value

🔹 Query: innodb_lock_waits

SELECT * FROM information_schema.innodb_lock_waits;

Line	Explanation
SELECT *	Selects all columns showing lock wait relationships.
FROM information_schema.innodb_lock_waits;	Provides details on which transactions are waiting and which are blocking.
Purpose	Maps waiting transactions to the ones currently holding the locks.
Use Case	Helps visualize blocking chains and investigate the root cause of stalls.

Sample Output:
requesting_trx_id	requested_lock_id	blocking_trx_id	blocking_lock_id
98766	lock567	98765	lock123

    requesting_trx_id: Transaction ID that is waiting

    blocking_trx_id: Transaction ID currently holding the lock

🔹 Query: innodb_trx

SELECT * FROM information_schema.innodb_trx;

Line	Explanation
SELECT *	Selects all columns showing active transactions.
FROM information_schema.innodb_trx;	Queries currently running transactions inside the InnoDB engine.
Purpose	Shows transaction IDs, state, age, and current SQL being executed.
Use Case	Useful to identify long-running or idle-in-transaction sessions that may be causing contention.

Sample Output:
trx_id	trx_state	trx_started	trx_mysql_thread_id	trx_query
98765	RUNNING	2025-04-04 14:05:00	234	UPDATE orders SET status='shipped'...
98766	LOCK WAIT	2025-04-04 14:05:03	235	UPDATE orders SET status='shipped'...
🔄 Recommended Investigation Flow
Step	Tool / Query	Goal
1	innodb_lock_waits	Identify which transaction is waiting and who is blocking it.
2	innodb_locks	Check which locks are held and what resource (row/index) is locked.
3	innodb_trx	Understand who’s running what, how long, and what query is responsible.

To debug a deadlock or long wait:

    Start with innodb_lock_waits
    → See who is waiting and who is blocking.

    Use innodb_locks
    → Inspect what locks are involved (on which table/index/row).

    Use innodb_trx
    → Trace back to actual SQL query, start time, and connection ID.
