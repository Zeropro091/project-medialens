--
-- PostgreSQL database dump
--

\restrict LxIMG4bBra6B0bYYELnd1ea1RqfxtsciNELLYaOuZR45KWagw81mevUQliamhdx

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id, type) VALUES ('images', 'images', NULL, '2026-06-18 01:57:55.542484+00', '2026-06-18 01:57:55.542484+00', true, false, 52428800, '{image/jpeg,image/png,image/gif,image/webp,image/svg+xml}', NULL, 'STANDARD') ON CONFLICT DO NOTHING;


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: iceberg_namespaces; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: iceberg_tables; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (0, 'create-migrations-table', 'e18db593bcde2aca2a408c4d1100f6abba2195df', '2026-06-18 01:57:51.257606') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (1, 'initialmigration', '6ab16121fbaa08bbd11b712d05f358f9b555d777', '2026-06-18 01:57:51.266303') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (2, 'storage-schema', 'f6a1fa2c93cbcd16d4e487b362e45fca157a8dbd', '2026-06-18 01:57:51.273119') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (3, 'pathtoken-column', '2cb1b0004b817b29d5b0a971af16bafeede4b70d', '2026-06-18 01:57:51.319085') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (4, 'add-migrations-rls', '427c5b63fe1c5937495d9c635c263ee7a5905058', '2026-06-18 01:57:51.343883') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (5, 'add-size-functions', '79e081a1455b63666c1294a440f8ad4b1e6a7f84', '2026-06-18 01:57:51.355384') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (6, 'change-column-name-in-get-size', 'ded78e2f1b5d7e616117897e6443a925965b30d2', '2026-06-18 01:57:51.366068') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (7, 'add-rls-to-buckets', 'e7e7f86adbc51049f341dfe8d30256c1abca17aa', '2026-06-18 01:57:51.375445') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (8, 'add-public-to-buckets', 'fd670db39ed65f9d08b01db09d6202503ca2bab3', '2026-06-18 01:57:51.403502') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (9, 'fix-search-function', 'af597a1b590c70519b464a4ab3be54490712796b', '2026-06-18 01:57:51.422708') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (10, 'search-files-search-function', 'b595f05e92f7e91211af1bbfe9c6a13bb3391e16', '2026-06-18 01:57:51.442547') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (11, 'add-trigger-to-auto-update-updated_at-column', '7425bdb14366d1739fa8a18c83100636d74dcaa2', '2026-06-18 01:57:51.483771') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (12, 'add-automatic-avif-detection-flag', '8e92e1266eb29518b6a4c5313ab8f29dd0d08df9', '2026-06-18 01:57:51.501526') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (13, 'add-bucket-custom-limits', 'cce962054138135cd9a8c4bcd531598684b25e7d', '2026-06-18 01:57:51.510723') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (14, 'use-bytes-for-max-size', '941c41b346f9802b411f06f30e972ad4744dad27', '2026-06-18 01:57:51.521628') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (15, 'add-can-insert-object-function', '934146bc38ead475f4ef4b555c524ee5d66799e5', '2026-06-18 01:57:51.564174') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (16, 'add-version', '76debf38d3fd07dcfc747ca49096457d95b1221b', '2026-06-18 01:57:51.576647') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (17, 'drop-owner-foreign-key', 'f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101', '2026-06-18 01:57:51.588263') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (18, 'add_owner_id_column_deprecate_owner', 'e7a511b379110b08e2f214be852c35414749fe66', '2026-06-18 01:57:51.599665') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (19, 'alter-default-value-objects-id', '02e5e22a78626187e00d173dc45f58fa66a4f043', '2026-06-18 01:57:51.611081') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (20, 'list-objects-with-delimiter', 'cd694ae708e51ba82bf012bba00caf4f3b6393b7', '2026-06-18 01:57:51.62462') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (21, 's3-multipart-uploads', '8c804d4a566c40cd1e4cc5b3725a664a9303657f', '2026-06-18 01:57:51.637444') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (22, 's3-multipart-uploads-big-ints', '9737dc258d2397953c9953d9b86920b8be0cdb73', '2026-06-18 01:57:51.667606') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (23, 'optimize-search-function', '9d7e604cddc4b56a5422dc68c9313f4a1b6f132c', '2026-06-18 01:57:51.686784') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (24, 'operation-function', '8312e37c2bf9e76bbe841aa5fda889206d2bf8aa', '2026-06-18 01:57:51.695015') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (25, 'custom-metadata', 'd974c6057c3db1c1f847afa0e291e6165693b990', '2026-06-18 01:57:51.703692') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (26, 'objects-prefixes', '215cabcb7f78121892a5a2037a09fedf9a1ae322', '2026-06-18 01:57:51.714425') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (27, 'search-v2', '859ba38092ac96eb3964d83bf53ccc0b141663a6', '2026-06-18 01:57:51.724156') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (28, 'object-bucket-name-sorting', 'c73a2b5b5d4041e39705814fd3a1b95502d38ce4', '2026-06-18 01:57:51.740804') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (29, 'create-prefixes', 'ad2c1207f76703d11a9f9007f821620017a66c21', '2026-06-18 01:57:51.754974') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (30, 'update-object-levels', '2be814ff05c8252fdfdc7cfb4b7f5c7e17f0bed6', '2026-06-18 01:57:51.771932') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (31, 'objects-level-index', 'b40367c14c3440ec75f19bbce2d71e914ddd3da0', '2026-06-18 01:57:51.81395') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (32, 'backward-compatible-index-on-objects', 'e0c37182b0f7aee3efd823298fb3c76f1042c0f7', '2026-06-18 01:57:51.820695') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (33, 'backward-compatible-index-on-prefixes', 'b480e99ed951e0900f033ec4eb34b5bdcb4e3d49', '2026-06-18 01:57:51.834825') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (34, 'optimize-search-function-v1', 'ca80a3dc7bfef894df17108785ce29a7fc8ee456', '2026-06-18 01:57:51.892731') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (35, 'add-insert-trigger-prefixes', '458fe0ffd07ec53f5e3ce9df51bfdf4861929ccc', '2026-06-18 01:57:51.898695') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (36, 'optimise-existing-functions', '6ae5fca6af5c55abe95369cd4f93985d1814ca8f', '2026-06-18 01:57:51.90783') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (37, 'add-bucket-name-length-trigger', '3944135b4e3e8b22d6d4cbb568fe3b0b51df15c1', '2026-06-18 01:57:51.913015') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (38, 'iceberg-catalog-flag-on-buckets', '02716b81ceec9705aed84aa1501657095b32e5c5', '2026-06-18 01:57:51.919083') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (39, 'add-search-v2-sort-support', '6706c5f2928846abee18461279799ad12b279b78', '2026-06-18 01:57:51.943185') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (40, 'fix-prefix-race-conditions-optimized', '7ad69982ae2d372b21f48fc4829ae9752c518f6b', '2026-06-18 01:57:51.948135') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (41, 'add-object-level-update-trigger', '07fcf1a22165849b7a029deed059ffcde08d1ae0', '2026-06-18 01:57:51.951431') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (42, 'rollback-prefix-triggers', '771479077764adc09e2ea2043eb627503c034cd4', '2026-06-18 01:57:51.954619') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (43, 'fix-object-level', '84b35d6caca9d937478ad8a797491f38b8c2979f', '2026-06-18 01:57:51.958716') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (44, 'vector-bucket-type', '99c20c0ffd52bb1ff1f32fb992f3b351e3ef8fb3', '2026-06-18 01:57:51.961661') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (45, 'vector-buckets', '049e27196d77a7cb76497a85afae669d8b230953', '2026-06-18 01:57:51.967065') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (46, 'buckets-objects-grants', 'fedeb96d60fefd8e02ab3ded9fbde05632f84aed', '2026-06-18 01:57:51.980463') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (47, 'iceberg-table-metadata', '649df56855c24d8b36dd4cc1aeb8251aa9ad42c2', '2026-06-18 01:57:51.985463') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (48, 'iceberg-catalog-ids', 'e0e8b460c609b9999ccd0df9ad14294613eed939', '2026-06-18 01:57:51.990212') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (49, 'buckets-objects-grants-postgres', '072b1195d0d5a2f888af6b2302a1938dd94b8b3d', '2026-06-18 01:57:52.025314') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (50, 'search-v2-optimised', '6323ac4f850aa14e7387eb32102869578b5bd478', '2026-06-18 01:57:52.031024') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (51, 'index-backward-compatible-search', '2ee395d433f76e38bcd3856debaf6e0e5b674011', '2026-06-18 01:57:52.055647') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (52, 'drop-not-used-indexes-and-functions', '5cc44c8696749ac11dd0dc37f2a3802075f3a171', '2026-06-18 01:57:52.057328') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (53, 'drop-index-lower-name', 'd0cb18777d9e2a98ebe0bc5cc7a42e57ebe41854', '2026-06-18 01:57:52.073055') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (54, 'drop-index-object-level', '6289e048b1472da17c31a7eba1ded625a6457e67', '2026-06-18 01:57:52.077842') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (55, 'prevent-direct-deletes', '262a4798d5e0f2e7c8970232e03ce8be695d5819', '2026-06-18 01:57:52.080603') ON CONFLICT DO NOTHING;
INSERT INTO storage.migrations (id, name, hash, executed_at) VALUES (56, 'fix-optimized-search-function', 'cb58526ebc23048049fd5bf2fd148d18b04a2073', '2026-06-18 01:57:52.089724') ON CONFLICT DO NOTHING;


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata) VALUES ('cace3ca8-bb65-48c0-a00b-f24225b67516', 'images', '1781755074754-an3acksynuj.png', '00000000-0000-0000-0000-000000000002', '2026-06-18 03:58:05.190417+00', '2026-06-18 03:58:05.190417+00', '2026-06-18 03:58:05.190417+00', '{"eTag": "\"4f01c9e91fe31b3488680f62b250ae94\"", "size": 36129, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T03:58:04.873Z", "contentLength": 36129, "httpStatusCode": 200}', '3bbecd5b-6b42-43fe-b9d3-cc356d251e91', '00000000-0000-0000-0000-000000000002', '{}') ON CONFLICT DO NOTHING;
INSERT INTO storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata) VALUES ('8a0c92ac-763b-4015-a644-6db461ab1979', 'images', '1781755310621-ftdtludon3t.png', '00000000-0000-0000-0000-000000000002', '2026-06-18 04:01:51.069229+00', '2026-06-18 04:01:51.069229+00', '2026-06-18 04:01:51.069229+00', '{"eTag": "\"4f01c9e91fe31b3488680f62b250ae94\"", "size": 36129, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-06-18T04:01:51.037Z", "contentLength": 36129, "httpStatusCode": 200}', '61d3122f-d022-4b24-8ffc-c0a10b256849', '00000000-0000-0000-0000-000000000002', '{}') ON CONFLICT DO NOTHING;


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- PostgreSQL database dump complete
--

\unrestrict LxIMG4bBra6B0bYYELnd1ea1RqfxtsciNELLYaOuZR45KWagw81mevUQliamhdx

