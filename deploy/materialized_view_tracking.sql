-- Deploy sqitch_migrations_template:materialized_view_tracking to pg

BEGIN;

SET search_path TO :"schema",public;

CREATE TABLE IF NOT EXISTS materialized_view_tracking (
    name VARCHAR UNIQUE NOT NULL,
    start TIMESTAMP NOT NULL DEFAULT NOW(),
    finish TIMESTAMP NULL,
    PRIMARY KEY (name)
);

COMMIT;
