-- Verify project_name:materialized_view_tracking on pg

BEGIN;

SET search_path TO :"schema",public;

SELECT
    name,
    start,
    finish
FROM materialized_view_tracking
WHERE FALSE;

-- check primary key
SELECT 1/COUNT(*)
FROM pg_catalog.pg_constraint
WHERE
conname = 'materialized_view_tracking_pkey'
AND contype = 'p'
AND 1 = ALL(conkey);

ROLLBACK;
