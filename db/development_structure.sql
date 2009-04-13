CREATE TABLE "companies" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "company_number" varchar(255), "address" text, "url" varchar(255), "wikipedia_url" varchar(255), "created_at" datetime, "updated_at" datetime, "logo_image_url" varchar(255), "company_category" varchar(255), "company_status" varchar(255), "incorporation_date" date, "country_code" varchar(2));
CREATE TABLE "lobbyist_clients" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "company_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "ogc_suppliers" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "ogc_id" integer, "company_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE TABLE "search_results" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "search_id" integer, "company_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "searches" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "term" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE TABLE "slugs" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "sluggable_id" integer, "sequence" integer DEFAULT 1 NOT NULL, "sluggable_type" varchar(40), "scope" varchar(40), "created_at" datetime);
CREATE INDEX "index_companies_on_company_category" ON "companies" ("company_category");
CREATE INDEX "index_companies_on_company_number" ON "companies" ("company_number");
CREATE INDEX "index_companies_on_company_status" ON "companies" ("company_status");
CREATE INDEX "index_companies_on_name" ON "companies" ("name");
CREATE INDEX "index_companies_on_url" ON "companies" ("url");
CREATE INDEX "index_lobbyist_clients_on_company_id" ON "lobbyist_clients" ("company_id");
CREATE INDEX "index_ogc_suppliers_on_company_id" ON "ogc_suppliers" ("company_id");
CREATE INDEX "index_search_results_on_company_id" ON "search_results" ("company_id");
CREATE INDEX "index_search_results_on_search_id" ON "search_results" ("search_id");
CREATE INDEX "index_searches_on_term" ON "searches" ("term");
CREATE UNIQUE INDEX "index_slugs_on_name_and_sluggable_type_and_scope_and_sequence" ON "slugs" ("name", "sluggable_type", "scope", "sequence");
CREATE INDEX "index_slugs_on_sluggable_id" ON "slugs" ("sluggable_id");
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
INSERT INTO schema_migrations (version) VALUES ('20090307115355');

INSERT INTO schema_migrations (version) VALUES ('20090307121056');

INSERT INTO schema_migrations (version) VALUES ('20090307142543');

INSERT INTO schema_migrations (version) VALUES ('20090307142721');

INSERT INTO schema_migrations (version) VALUES ('20090311124308');

INSERT INTO schema_migrations (version) VALUES ('20090316233326');

INSERT INTO schema_migrations (version) VALUES ('20090316233652');

INSERT INTO schema_migrations (version) VALUES ('20090326125745');

INSERT INTO schema_migrations (version) VALUES ('20090413135607');

INSERT INTO schema_migrations (version) VALUES ('20090413135700');