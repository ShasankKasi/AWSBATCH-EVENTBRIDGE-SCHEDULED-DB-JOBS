SELECT
  'Started Job - job-summary-log' AS status,
  UTC_TIMESTAMP() AS time;

INSERT INTO DemoBatchDB.job_run_log
(job_name, records_found, executed_at_utc)
SELECT
  'inactive-user-report',
  COUNT(*),
  UTC_TIMESTAMP()
FROM DemoBatchDB.users
WHERE status = 'INACTIVE'
  AND last_login_utc < DATE_SUB(UTC_TIMESTAMP(), INTERVAL 60 DAY);

SELECT
  'Query execution done - job-summary-log' AS status,
  UTC_TIMESTAMP() AS time;
