-- Service-account deletion must find its audit rows without scanning all MCP logs.
-- Leave Drizzle's transaction for the concurrent build; the migration runner
-- removes invalid leftovers before a retry, and the closing BEGIN restores the batch.
COMMIT;--> statement-breakpoint
SET lock_timeout = '5min';--> statement-breakpoint
CREATE INDEX CONCURRENTLY IF NOT EXISTS "mcp_tool_calls_service_account_id_idx" ON "mcp_tool_calls" USING btree ("service_account_id") WHERE "mcp_tool_calls"."service_account_id" IS NOT NULL;--> statement-breakpoint
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_index i
    JOIN pg_class c ON c.oid = i.indexrelid
    WHERE c.relnamespace = 'public'::regnamespace
      AND c.relname = 'mcp_tool_calls_service_account_id_idx'
      AND i.indisvalid
  ) THEN
    RAISE EXCEPTION 'Index build did not finish: mcp_tool_calls_service_account_id_idx. Rerun the migration.';
  END IF;
END $$;--> statement-breakpoint
RESET lock_timeout;--> statement-breakpoint
BEGIN;
