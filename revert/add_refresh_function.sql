-- Revert unicef_philippines:add_refresh_function from pg

BEGIN;

SET search_path TO :"schema",public;

DROP FUNCTION IF EXISTS public.refresh_mat_view(varchar, boolean, boolean);

COMMIT;
