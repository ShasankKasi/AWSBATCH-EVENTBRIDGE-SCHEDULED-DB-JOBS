SELECT
  'Started Job - inactive-user-fetch' AS status,
  UTC_TIMESTAMP() AS time;

SELECT
  user_id,
  email,
  last_login_utc
FROM DemoBatchDB.users
WHERE status = 'INACTIVE'
  AND last_login_utc < DATE_SUB(UTC_TIMESTAMP(), INTERVAL 60 DAY);

SELECT
  'Query execution done - inactive-user-fetch' AS status,
  UTC_TIMESTAMP() AS time;
