-- Deploy unicef_philippines:add_refresh_function to pg
-- requires: materialized_view_tracking

BEGIN;

-- lets make it possible to create this function in any schema provided by the
-- :"schema" variable - and default to public.
SET search_path TO :"schema",public;

CREATE OR REPLACE FUNCTION refresh_mat_view(view_name VARCHAR, concurrent BOOLEAN DEFAULT FALSE, check_schema BOOLEAN DEFAULT FALSE) RETURNS VARCHAR AS $$
-- this function is used to refresh a materialized view and simultaneously record
-- the time that the refresh started and finished
-- params:
--      view_name - the name of the materialized view
--      concurrent - whether to refresh concurrently or not
--      check_schema - whether to check for ongoing refreshes in the current schema or not
DECLARE
    refresh_statement VARCHAR;
    check_existing_stmnt VARCHAR;
    existing_queries INTEGER;
    mat_views VARCHAR[] := ARRAY['mr_opv_luzon_merged_view', 'opv_luzon_view', 'mr_opv_combined_view', 'mr_opv_combined_table', 'mr_opv_combined_filter_table', 
        'mr_mindanao_view', 'mr_mindanao_merged_view'];
BEGIN
    -- check if the view is part of our list
    IF view_name <> ANY(mat_views) THEN
        RETURN view_name || ' is not in the refresh list.';
    END IF;

    -- check if we should refresh
    IF check_schema = TRUE THEN
        check_existing_stmnt = CONCAT('%', current_schema(), '.refresh_mat_view(''', view_name, '%');
    ELSE
        check_existing_stmnt = CONCAT('%refresh_mat_view(''', view_name, '%');
    END IF;

    SELECT COUNT(*) FROM pg_stat_activity
    INTO existing_queries
    WHERE query ILIKE check_existing_stmnt;

    IF existing_queries > 1 THEN
        RETURN view_name || ' refresh already in progress.';
    ELSE
        -- get the refresh statement
        IF concurrent = TRUE THEN
            refresh_statement = 'REFRESH MATERIALIZED VIEW CONCURRENTLY ' || view_name || ' WITH DATA';
        ELSE
            refresh_statement = 'REFRESH MATERIALIZED VIEW ' || view_name || ' WITH DATA';
        END IF;

        -- record the start time
        INSERT INTO materialized_view_tracking (name, start, finish)
        VALUES (view_name, CLOCK_TIMESTAMP(), NULL)
        ON CONFLICT (name) DO UPDATE
        SET start = CLOCK_TIMESTAMP(), finish = NULL;

        -- refresh the view
        EXECUTE refresh_statement;

        -- record the end time
        UPDATE materialized_view_tracking
        SET finish = CLOCK_TIMESTAMP()
        WHERE name = view_name;

        RETURN refresh_statement;
    END IF;

END;
$$ LANGUAGE plpgsql;

COMMIT;