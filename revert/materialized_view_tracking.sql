-- Revert unicef_philippines:materialized_view_tracking from pg

BEGIN;

SET search_path TO :"schema",public;

DROP TABLE IF EXISTS materialized_view_tracking;

COMMIT;
