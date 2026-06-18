--
-- PostgreSQL database dump
--

\restrict mauNsDZ9deogGuQgM0gCbVSXG3wIYGXzAcI9IJrhCa82i5rYtdCuM4V3LapfvTX

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
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) VALUES ('00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000003', 'authenticated', 'authenticated', 'poster@poster.com', '$2a$06$29PimZdYiyhb0A8xhn/zwO1mFhPWIcSHxT7YkKIUR1uZYYE9wokwy', '2026-06-18 01:57:55.880228+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"provider": "email", "providers": ["email"]}', '{"full_name": "Poster User"}', NULL, '2026-06-18 01:57:55.880228+00', '2026-06-18 01:57:55.880228+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false) ON CONFLICT DO NOTHING;
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) VALUES ('00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000004', 'authenticated', 'authenticated', 'user@user.com', '$2a$06$QadnLH2Ss/1rsH0N7FLkVeCx1HUipTkwig2kU4bKusIkpZs9BUvw.', '2026-06-18 01:57:55.880228+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"provider": "email", "providers": ["email"]}', '{"full_name": "Regular User"}', NULL, '2026-06-18 01:57:55.880228+00', '2026-06-18 01:57:55.880228+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false) ON CONFLICT DO NOTHING;
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) VALUES ('00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000001', 'authenticated', 'authenticated', 'admin@admin.com', '$2a$06$.WrdthJ9NsOTFe/sPKChrOL8MctZWzEvXzQcsCt8yG8udxVXGKZEq', '2026-06-18 01:57:55.880228+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-06-18 02:02:21.162375+00', '{"provider": "email", "providers": ["email"]}', '{"full_name": "Admin"}', NULL, '2026-06-18 01:57:55.880228+00', '2026-06-18 02:02:21.168751+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false) ON CONFLICT DO NOTHING;
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) VALUES ('00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000002', 'authenticated', 'authenticated', 'dev@dev.com', '$2a$06$KZOL7MRu6SC6Xbo2OQwhEudPq3YjSnibQT57ThFhbZZM8ziVo3O2W', '2026-06-18 01:57:55.880228+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-06-18 02:25:53.686941+00', '{"provider": "email", "providers": ["email"]}', '{"full_name": "Dev User"}', NULL, '2026-06-18 01:57:55.880228+00', '2026-06-18 06:48:11.73588+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false) ON CONFLICT DO NOTHING;
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) VALUES ('00000000-0000-0000-0000-000000000000', '1125697b-23ac-4be9-9ce1-f7e1c475c8d8', 'authenticated', 'authenticated', 'putuari0911@gmail.com', '$2a$10$fu24siEYaIPD/D4onsYlIu4vqZxcM5vJ8UWKrOeuIy/BYcCS5Fk4S', '2026-06-18 07:47:53.580722+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-06-18 07:47:53.721966+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "1125697b-23ac-4be9-9ce1-f7e1c475c8d8", "role": "user", "email": "putuari0911@gmail.com", "full_name": "Putu Ari", "email_verified": true, "phone_verified": false}', NULL, '2026-06-18 07:47:53.29447+00', '2026-06-18 07:47:53.802323+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false) ON CONFLICT DO NOTHING;


--
-- PostgreSQL database dump complete
--

\unrestrict mauNsDZ9deogGuQgM0gCbVSXG3wIYGXzAcI9IJrhCa82i5rYtdCuM4V3LapfvTX

