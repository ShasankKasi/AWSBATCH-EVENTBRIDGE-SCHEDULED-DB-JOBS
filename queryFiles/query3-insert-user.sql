SELECT
  'Started Job - user-insertion' AS status,
  UTC_TIMESTAMP() AS time;

INSERT INTO DemoBatchDB.users
(email, status, last_login_utc, created_on_utc)
VALUES
(
  CONCAT('batch_user_', UNIX_TIMESTAMP(), '@example.com'),
  'ACTIVE',
  UTC_TIMESTAMP(),
  UTC_TIMESTAMP()
);

SELECT
  'Query execution done - user-insertion' AS status,
  UTC_TIMESTAMP() AS time;
