CREATE TABLE "companies" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "company_number" varchar(255), "address" text, "url" varchar(255), "wikipedia_url" varchar(255), "created_at" datetime, "updated_at" datetime, "logo_image_url" varchar(255));
CREATE TABLE "lobbyist_clients" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "company_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "ogc_suppliers" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "ogc_id" integer, "company_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE TABLE "slugs" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "sluggable_id" integer, "sequence" integer DEFAULT 1 NOT NULL, "sluggable_type" varchar(40), "scope" varchar(40), "created_at" datetime);
CREATE INDEX "index_companies_on_company_number" ON "companies" ("company_number");
CREATE INDEX "index_companies_on_name" ON "companies" ("name");
CREATE INDEX "index_companies_on_url" ON "companies" ("url");
CREATE INDEX "index_lobbyist_clients_on_company_id" ON "lobbyist_clients" ("company_id");
CREATE INDEX "index_ogc_suppliers_on_company_id" ON "ogc_suppliers" ("company_id");
CREATE UNIQUE INDEX "index_slugs_on_name_and_sluggable_type_and_scope_and_sequence" ON "slugs" ("name", "sluggable_type", "scope", "sequence");
CREATE INDEX "index_slugs_on_sluggable_id" ON "slugs" ("sluggable_id");
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
INSERT INTO schema_migrations (version) VALUES ('20090307115355');

INSERT INTO schema_migrations (version) VALUES ('20090307121056');

INSERT INTO schema_migrations (version) VALUES ('20090307142543');

INSERT INTO schema_migrations (version) VALUES ('20090307142721');

INSERT INTO schema_migrations (version) VALUES ('20090311124308');