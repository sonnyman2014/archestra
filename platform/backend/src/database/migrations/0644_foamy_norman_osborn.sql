-- Existing rows have no service account. Enforce new writes without scanning the log table.
ALTER TABLE "mcp_tool_calls" ADD COLUMN "service_account_id" uuid;--> statement-breakpoint
ALTER TABLE "mcp_tool_calls" ADD CONSTRAINT "mcp_tool_calls_service_account_id_service_accounts_id_fk" FOREIGN KEY ("service_account_id") REFERENCES "public"."service_accounts"("id") ON DELETE set null ON UPDATE no action NOT VALID;
