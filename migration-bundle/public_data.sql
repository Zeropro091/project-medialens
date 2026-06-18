--
-- PostgreSQL database dump
--

\restrict kQb6GMSnCtqYlO0k6fNhzWJ0tA82evY5Iy3kS6KUehe3P5k7g8ZHVI8hgKQBGzX

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
-- Data for Name: ad_sponsors; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.categories (id, slug, name, description, parent_id, level, sort_order, is_active, seo_title, seo_description, "createdAt", "updatedAt") VALUES ('aaaaaaaa-0000-0000-0000-000000000001', 'business', 'Business', NULL, NULL, 0, 1, true, NULL, NULL, '2026-06-18 01:57:55.880228+00', '2026-06-18 01:57:55.880228+00') ON CONFLICT DO NOTHING;
INSERT INTO public.categories (id, slug, name, description, parent_id, level, sort_order, is_active, seo_title, seo_description, "createdAt", "updatedAt") VALUES ('aaaaaaaa-0000-0000-0000-000000000002', 'world', 'World', NULL, NULL, 0, 2, true, NULL, NULL, '2026-06-18 01:57:55.880228+00', '2026-06-18 01:57:55.880228+00') ON CONFLICT DO NOTHING;
INSERT INTO public.categories (id, slug, name, description, parent_id, level, sort_order, is_active, seo_title, seo_description, "createdAt", "updatedAt") VALUES ('aaaaaaaa-0000-0000-0000-000000000003', 'tech', 'Tech', NULL, NULL, 0, 3, true, NULL, NULL, '2026-06-18 01:57:55.880228+00', '2026-06-18 01:57:55.880228+00') ON CONFLICT DO NOTHING;
INSERT INTO public.categories (id, slug, name, description, parent_id, level, sort_order, is_active, seo_title, seo_description, "createdAt", "updatedAt") VALUES ('aaaaaaaa-0000-0000-0000-000000000004', 'science', 'Science', NULL, NULL, 0, 4, true, NULL, NULL, '2026-06-18 01:57:55.880228+00', '2026-06-18 01:57:55.880228+00') ON CONFLICT DO NOTHING;
INSERT INTO public.categories (id, slug, name, description, parent_id, level, sort_order, is_active, seo_title, seo_description, "createdAt", "updatedAt") VALUES ('aaaaaaaa-0000-0000-0000-000000000005', 'politics', 'Politics', NULL, NULL, 0, 5, true, NULL, NULL, '2026-06-18 01:57:55.880228+00', '2026-06-18 01:57:55.880228+00') ON CONFLICT DO NOTHING;
INSERT INTO public.categories (id, slug, name, description, parent_id, level, sort_order, is_active, seo_title, seo_description, "createdAt", "updatedAt") VALUES ('aaaaaaaa-0000-0000-0000-000000000006', 'health', 'Health', NULL, NULL, 0, 6, true, NULL, NULL, '2026-06-18 01:57:55.880228+00', '2026-06-18 01:57:55.880228+00') ON CONFLICT DO NOTHING;
INSERT INTO public.categories (id, slug, name, description, parent_id, level, sort_order, is_active, seo_title, seo_description, "createdAt", "updatedAt") VALUES ('aaaaaaaa-0000-0000-0000-000000000007', 'sports', 'Sports', NULL, NULL, 0, 7, true, NULL, NULL, '2026-06-18 01:57:55.880228+00', '2026-06-18 01:57:55.880228+00') ON CONFLICT DO NOTHING;
INSERT INTO public.categories (id, slug, name, description, parent_id, level, sort_order, is_active, seo_title, seo_description, "createdAt", "updatedAt") VALUES ('aaaaaaaa-0000-0000-0000-000000000008', 'arts', 'Arts', NULL, NULL, 0, 8, true, NULL, NULL, '2026-06-18 01:57:55.880228+00', '2026-06-18 01:57:55.880228+00') ON CONFLICT DO NOTHING;
INSERT INTO public.categories (id, slug, name, description, parent_id, level, sort_order, is_active, seo_title, seo_description, "createdAt", "updatedAt") VALUES ('aaaaaaaa-0000-0000-0000-000000000009', 'opinion', 'Opinion', NULL, NULL, 0, 9, true, NULL, NULL, '2026-06-18 01:57:55.880228+00', '2026-06-18 01:57:55.880228+00') ON CONFLICT DO NOTHING;


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.profiles (id, email, role, quota, "createdAt", full_name, pen_name, bio, profile_photo, phone_number, city) VALUES ('00000000-0000-0000-0000-000000000001', 'admin@admin.com', 'admin', 999, '2026-06-18 01:57:55.880228+00', 'Admin', NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO public.profiles (id, email, role, quota, "createdAt", full_name, pen_name, bio, profile_photo, phone_number, city) VALUES ('00000000-0000-0000-0000-000000000002', 'dev@dev.com', 'dev', 999, '2026-06-18 01:57:55.880228+00', 'Dev User', NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO public.profiles (id, email, role, quota, "createdAt", full_name, pen_name, bio, profile_photo, phone_number, city) VALUES ('00000000-0000-0000-0000-000000000003', 'poster@poster.com', 'poster', 5, '2026-06-18 01:57:55.880228+00', 'Poster User', NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO public.profiles (id, email, role, quota, "createdAt", full_name, pen_name, bio, profile_photo, phone_number, city) VALUES ('00000000-0000-0000-0000-000000000004', 'user@user.com', 'user', 5, '2026-06-18 01:57:55.880228+00', 'Regular User', NULL, NULL, NULL, NULL, NULL) ON CONFLICT DO NOTHING;
INSERT INTO public.profiles (id, email, role, quota, "createdAt", full_name, pen_name, bio, profile_photo, phone_number, city) VALUES ('1125697b-23ac-4be9-9ce1-f7e1c475c8d8', 'putuari0911@gmail.com', 'poster', 5, '2026-06-18 07:47:53.278245+00', 'Putu Ari', NULL, NULL, NULL, '081237729115', 'bali') ON CONFLICT DO NOTHING;


--
-- Data for Name: media; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: articles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.articles (id, title, subtitle, excerpt, author, role, date, "time", category, "imageUrl", "contentArr", "contentStr", status, "createdAt", "updatedAt", author_id, slug, category_id, featured_image_id, og_image_id, meta_description, meta_keywords, canonical_url, published_at) VALUES ('featured-1', 'Global Markets Rally as Tech Sector Shows Unexpected Resilience', 'Despite early quarter concerns, major technology firms report record-breaking earnings, driving indices to all-time highs and easing recession fears.', 'Despite early quarter concerns, major technology firms report record-breaking earnings, driving indices to all-time highs and easing recession fears.', 'Sarah Jenkins', 'Senior Financial Correspondent', 'April 14, 2026', '2 hours ago', 'Business', 'https://picsum.photos/seed/markets/1200/800', '{"The global financial markets experienced an unprecedented surge today, driven largely by a tech sector that refused to bow to early-quarter pessimism. Major indices across North America, Europe, and Asia closed at record highs, painting a picture of a global economy that is far more resilient than analysts predicted just months ago.","At the heart of this rally are the quarterly earnings reports from the ''Big Tech'' conglomerates. Defying expectations of a slowdown due to regulatory pressures and supply chain bottlenecks, these companies posted record-breaking revenues. The surge was led by unexpected growth in cloud computing divisions and enterprise AI solutions, which saw adoption rates double compared to the previous fiscal year.","\"What we''re seeing is a fundamental shift in how businesses are investing in technology,\" explained Dr. Aris Thorne, Chief Economist at Global Horizon Bank. \"It''s no longer about expansion; it''s about efficiency. The tools these tech giants are providing are becoming indispensable for companies trying to navigate a complex global market.\"","The ripple effect of this tech rally was felt across other sectors. Consumer discretionary stocks saw a modest bump, while industrials held steady. However, the bond market saw a slight dip as investors moved capital into equities, chasing the higher yields promised by the tech sector''s performance.","Despite the overwhelming optimism, some analysts are urging caution. The rapid ascent of these stocks has raised concerns about overvaluation. \"We are in uncharted territory,\" warned Elena Rostova, a market strategist. \"While the fundamentals are strong, the speed of this rally leaves little room for error. Any negative news, whether geopolitical or economic, could trigger a sharp correction.\"","For now, however, the bulls are firmly in control. As the trading day closed, the atmosphere on the trading floors was one of cautious jubilation. The tech sector has once again proven its ability to drive the broader market, leaving investors eagerly anticipating the next wave of innovation and growth."}', NULL, 'published', '2026-06-18 01:57:55.880228+00', '2026-06-18 01:57:55.880228+00', 'bbbbbbbb-0000-0000-0000-000000000001', 'featured-1', 'aaaaaaaa-0000-0000-0000-000000000001', NULL, NULL, NULL, NULL, NULL, '2026-06-18 01:57:55.880228+00') ON CONFLICT DO NOTHING;
INSERT INTO public.articles (id, title, subtitle, excerpt, author, role, date, "time", category, "imageUrl", "contentArr", "contentStr", status, "createdAt", "updatedAt", author_id, slug, category_id, featured_image_id, og_image_id, meta_description, meta_keywords, canonical_url, published_at) VALUES ('sec-1', 'New Climate Accord Reached in Geneva Summit', 'World leaders agree on aggressive new carbon reduction targets for 2035.', 'World leaders agree on aggressive new carbon reduction targets for 2035.', 'David Chen', 'Environmental Editor', 'April 14, 2026', '4 hours ago', 'World', 'https://picsum.photos/seed/climate/600/400', '{"New Climate Accord Reached in Geneva Summit marks a significant turning point in recent developments. Experts and analysts have been closely monitoring the situation, noting that the implications could be far-reaching and transformative across multiple sectors.","\"This is unprecedented in many ways,\" stated a leading researcher familiar with the matter. \"We are seeing patterns that challenge our previous models and force us to rethink our long-term strategies.\" The data collected over the past few months supports this assertion, showing a clear deviation from historical norms.","Stakeholders are now scrambling to adjust to the new reality. While some view this as a challenge, others see it as a unique opportunity for innovation and growth. The coming weeks will be critical in determining the ultimate trajectory of these events.","As the situation continues to evolve, one thing is certain: the landscape has changed permanently. Observers advise cautious optimism while preparing for a range of possible outcomes in the near future."}', NULL, 'published', '2026-06-18 01:57:55.880228+00', '2026-06-18 01:57:55.880228+00', 'bbbbbbbb-0000-0000-0000-000000000001', 'sec-1', 'aaaaaaaa-0000-0000-0000-000000000002', NULL, NULL, NULL, NULL, NULL, '2026-06-18 01:57:55.880228+00') ON CONFLICT DO NOTHING;
INSERT INTO public.articles (id, title, subtitle, excerpt, author, role, date, "time", category, "imageUrl", "contentArr", "contentStr", status, "createdAt", "updatedAt", author_id, slug, category_id, featured_image_id, og_image_id, meta_description, meta_keywords, canonical_url, published_at) VALUES ('sec-2', 'Central Bank Signals Potential Rate Cuts by Q3', 'Inflation cools faster than expected, prompting a shift in monetary policy.', 'Inflation cools faster than expected, prompting a shift in monetary policy.', 'Michael Ross', 'Economics Reporter', 'April 14, 2026', '5 hours ago', 'Business', 'https://picsum.photos/seed/bank/600/400', '{"Central Bank Signals Potential Rate Cuts by Q3 marks a significant turning point in recent developments. Experts and analysts have been closely monitoring the situation, noting that the implications could be far-reaching and transformative across multiple sectors.","\"This is unprecedented in many ways,\" stated a leading researcher familiar with the matter. \"We are seeing patterns that challenge our previous models and force us to rethink our long-term strategies.\" The data collected over the past few months supports this assertion, showing a clear deviation from historical norms.","Stakeholders are now scrambling to adjust to the new reality. While some view this as a challenge, others see it as a unique opportunity for innovation and growth. The coming weeks will be critical in determining the ultimate trajectory of these events.","As the situation continues to evolve, one thing is certain: the landscape has changed permanently. Observers advise cautious optimism while preparing for a range of possible outcomes in the near future."}', NULL, 'published', '2026-06-18 01:57:55.880228+00', '2026-06-18 01:57:55.880228+00', 'bbbbbbbb-0000-0000-0000-000000000001', 'sec-2', 'aaaaaaaa-0000-0000-0000-000000000001', NULL, NULL, NULL, NULL, NULL, '2026-06-18 01:57:55.880228+00') ON CONFLICT DO NOTHING;
INSERT INTO public.articles (id, title, subtitle, excerpt, author, role, date, "time", category, "imageUrl", "contentArr", "contentStr", status, "createdAt", "updatedAt", author_id, slug, category_id, featured_image_id, og_image_id, meta_description, meta_keywords, canonical_url, published_at) VALUES ('sec-3', 'Breakthrough in Quantum Computing Architecture', 'Researchers achieve stable qubits at room temperature, a holy grail for computing.', 'Researchers achieve stable qubits at room temperature, a holy grail for computing.', 'Dr. Elena Rostova', 'Science Contributor', 'April 14, 2026', '6 hours ago', 'Tech', 'https://picsum.photos/seed/quantum/600/400', '{"Breakthrough in Quantum Computing Architecture marks a significant turning point in recent developments. Experts and analysts have been closely monitoring the situation, noting that the implications could be far-reaching and transformative across multiple sectors.","\"This is unprecedented in many ways,\" stated a leading researcher familiar with the matter. \"We are seeing patterns that challenge our previous models and force us to rethink our long-term strategies.\" The data collected over the past few months supports this assertion, showing a clear deviation from historical norms.","Stakeholders are now scrambling to adjust to the new reality. While some view this as a challenge, others see it as a unique opportunity for innovation and growth. The coming weeks will be critical in determining the ultimate trajectory of these events.","As the situation continues to evolve, one thing is certain: the landscape has changed permanently. Observers advise cautious optimism while preparing for a range of possible outcomes in the near future."}', NULL, 'published', '2026-06-18 01:57:55.880228+00', '2026-06-18 01:57:55.880228+00', 'bbbbbbbb-0000-0000-0000-000000000001', 'sec-3', 'aaaaaaaa-0000-0000-0000-000000000003', NULL, NULL, NULL, NULL, NULL, '2026-06-18 01:57:55.880228+00') ON CONFLICT DO NOTHING;
INSERT INTO public.articles (id, title, subtitle, excerpt, author, role, date, "time", category, "imageUrl", "contentArr", "contentStr", status, "createdAt", "updatedAt", author_id, slug, category_id, featured_image_id, og_image_id, meta_description, meta_keywords, canonical_url, published_at) VALUES ('sec-4', 'Urban Planning Shift: The Rise of 15-Minute Cities', 'How metropolises are redesigning themselves for hyper-local living.', 'How metropolises are redesigning themselves for hyper-local living.', 'James Wilson', 'Urban Affairs', 'April 14, 2026', '8 hours ago', 'Science', 'https://picsum.photos/seed/city/600/400', '{"Urban Planning Shift: The Rise of 15-Minute Cities marks a significant turning point in recent developments. Experts and analysts have been closely monitoring the situation, noting that the implications could be far-reaching and transformative across multiple sectors.","\"This is unprecedented in many ways,\" stated a leading researcher familiar with the matter. \"We are seeing patterns that challenge our previous models and force us to rethink our long-term strategies.\" The data collected over the past few months supports this assertion, showing a clear deviation from historical norms.","Stakeholders are now scrambling to adjust to the new reality. While some view this as a challenge, others see it as a unique opportunity for innovation and growth. The coming weeks will be critical in determining the ultimate trajectory of these events.","As the situation continues to evolve, one thing is certain: the landscape has changed permanently. Observers advise cautious optimism while preparing for a range of possible outcomes in the near future."}', NULL, 'published', '2026-06-18 01:57:55.880228+00', '2026-06-18 01:57:55.880228+00', 'bbbbbbbb-0000-0000-0000-000000000001', 'sec-4', 'aaaaaaaa-0000-0000-0000-000000000004', NULL, NULL, NULL, NULL, NULL, '2026-06-18 01:57:55.880228+00') ON CONFLICT DO NOTHING;
INSERT INTO public.articles (id, title, subtitle, excerpt, author, role, date, "time", category, "imageUrl", "contentArr", "contentStr", status, "createdAt", "updatedAt", author_id, slug, category_id, featured_image_id, og_image_id, meta_description, meta_keywords, canonical_url, published_at) VALUES ('d7761a88-7475-430e-9eb4-337717191a05', 'ada', NULL, 'aa', 'Dev User', 'Editor', 'June 18, 2026', '11:19 AM', 'World', NULL, '{a}', 'a', 'published', '2026-06-18 03:19:55.14+00', '2026-06-18 03:19:55.14+00', '00000000-0000-0000-0000-000000000002', 'ada', 'aaaaaaaa-0000-0000-0000-000000000002', NULL, NULL, NULL, NULL, NULL, '2026-06-18 03:20:00.137+00') ON CONFLICT DO NOTHING;
INSERT INTO public.articles (id, title, subtitle, excerpt, author, role, date, "time", category, "imageUrl", "contentArr", "contentStr", status, "createdAt", "updatedAt", author_id, slug, category_id, featured_image_id, og_image_id, meta_description, meta_keywords, canonical_url, published_at) VALUES ('9049a094-d8ee-446d-b63e-3fded72ed856', 'DGT.LZ

', NULL, NULL, 'DGT.LZ', 'Editor', 'June 18, 2026', '11:32 AM', 'Business', '/storage/v1/object/public/images/1781755074754-an3acksynuj.png', '{"# **DGT.LZ | DIGITAL ARTIFACTS STUDIO**","*\"Engineered for the Future,bridging art,tech,and automation.\"*",![dgt_lz_light.png](http://127.0.0.1:54821/storage/v1/object/public/images/1781755310621-ftdtludon3t.png),"DGT.LZ adalah agensi teknologi modern yang berfokus pada penggabungan estetika visual dengan sistem otomasi dan kecerdasan buatan (AI). Kami tidak sekadar membuat produk digital; kami memahat **Digital Artifacts** yang otentik dan fungsional.","## **1\\. Filosofi Brand: \"Digital Craftsmanship\"**","Kami percaya bahwa teknologi harus seindah karya seni di museum dan seefisien mesin industri.","-   **Aesthetics:** Pendekatan visual berbasis Setiap elemen desain memiliki tujuan, tanpa ada noise yang tidak perlu.
-   **Intelligent Architecture:** Keindahan visual harus ditopang oleh kecerdasan sistem di baliknya. Desain kami tidak hanya terlihat bagus, tetapi juga bekerja secara otonom.
-   **Bespoke Authenticity:** Menolak solusi template. Setiap proyek adalah karya asli yang dirancang khusus untuk membedakan klien dari kompetitor mereka.","## **2\\. Struktur Organisasi (The Core Units)**","DGT.LZ beroperasi melalui empat divisi spesialis yang saling terintegrasi:","### **A. dgt.lz Studio (Creative & Design)**","Unit yang bertanggung jawab atas wajah visual dan pengalaman pengguna.","-   **Layanan:** UI/UX Design (Web & App), Logo Design, Poster Design.","### **B. dgt.lz Labs (AI & Experimental Tech)**","Pusat inovasi untuk integrasi kecerdasan buatan dalam operasional bisnis.","-   **Layanan:** AI Chatbot Business, Customer Service Automation, AI Content System, Internal AI Tools.","### **C. dgt.lz Systems (Infrastructure & Automation)**","Mesin penggerak teknis yang membangun fondasi digital yang kokoh.","-   **Layanan:** Web Development (Company Profile, Landing Page, E-commerce), Custom Web App, Dashboard/Admin Panel, WhatsApp & Workflow Automation.","### **D. dgt.lz Media (Growth & Visibility)**","Divisi yang memastikan sistem digital klien ditemukan oleh pasar yang tepat.","-   **Layanan:** SEO (Search Engine Optimization), Digital Campaign & Performance Marketing (Ads).","## **3\\. Ekosistem Layanan (Full Stack Services)**","<table><tbody><tr><td><p><strong>Kategori</strong></p></td><td><p><strong>Detail Layanan</strong></p></td></tr><tr><td><p><strong>Web &amp; Dev</strong></p></td><td><p>Website Company Profile, Landing Page, E-commerce, Dashboard/Admin Panel, Custom Web App.</p></td></tr><tr><td><p><strong>AI &amp; Automation</strong></p></td><td><p>AI Chatbot, Customer Service Automation, WhatsApp Automation, Workflow Automation, Internal AI Tools.</p></td></tr><tr><td><p><strong>Design</strong></p></td><td><p>High-end UI/UX Design, Authentic Logo, High-impact Poster.</p></td></tr><tr><td><p><strong>Maintenance</strong></p></td><td><p>Website Maintenance, Custom Software Support, AI &amp; Automation Monitoring.</p></td></tr></tbody></table>","## **4\\. Model Pendapatan (Revenue Streams)**","DGT.LZ menggunakan pendekatan tiga lapis untuk menjaga stabilitas finansial:","1.  **Project-Based (Injeksi Modal):**
    -   Pembayaran satu kali untuk solusi *custom*.
    -   Contoh: Pembuatan Website E-commerce atau Setup AI Chatbot awal.
2.  **Monthly Retainer (Pendapatan Stabil):**
    -   Biaya langganan bulanan untuk layanan jangka panjang.
    -   Contoh: Pemeliharaan sistem, monitoring otomasi, dan SEO bulanan.
3.  **Productized Service (Skalabilitas Cepat):**
    -   Paket layanan tetap dengan harga dan waktu pengerjaan yang pasti.
    -   Contoh: *\"Web 7 Hari\"*, *\"AI Chatbot Starter\"*, atau *\"Business Digital Setup\"*.","## **5\\. Alur Kerja Operasional (Workflow)**","1.  **Discovery :** Proses menjangkau klien (*outreach*) dan memahami masalah utama bisnis mereka.
2.  **Strategic Proposal:** Menyusun solusi teknologi yang menggabungkan Studio, Labs, dan Systems.
3.  **Production (Team):** Eksekusi teknis dengan standar kualitas tinggi dan pengawasan ketat pada detail estetika.
4.  **Deployment & Handover:** Peluncuran sistem dan penyerahan aset digital kepada klien.
5.  **Optimization (Retainer):** Pemantauan berkala dan pembaruan sistem untuk memastikan performa tetap maksimal.","## **6\\. Target Pasar**","Fokus utama adalah **Bisnis dan Brandi** yang ingin melakukan transformasi digital secara serius, terutama mereka yang menghargai kualitas desain dan membutuhkan efisiensi melalui teknologi AI."}', '# **DGT.LZ | DIGITAL ARTIFACTS STUDIO**

*"Engineered for the Future,bridging art,tech,and automation."*


![dgt_lz_light.png](http://127.0.0.1:54821/storage/v1/object/public/images/1781755310621-ftdtludon3t.png)



DGT.LZ adalah agensi teknologi modern yang berfokus pada penggabungan estetika visual dengan sistem otomasi dan kecerdasan buatan (AI). Kami tidak sekadar membuat produk digital; kami memahat **Digital Artifacts** yang otentik dan fungsional.

## **1\. Filosofi Brand: "Digital Craftsmanship"**

Kami percaya bahwa teknologi harus seindah karya seni di museum dan seefisien mesin industri.

-   **Aesthetics:** Pendekatan visual berbasis Setiap elemen desain memiliki tujuan, tanpa ada noise yang tidak perlu.
-   **Intelligent Architecture:** Keindahan visual harus ditopang oleh kecerdasan sistem di baliknya. Desain kami tidak hanya terlihat bagus, tetapi juga bekerja secara otonom.
-   **Bespoke Authenticity:** Menolak solusi template. Setiap proyek adalah karya asli yang dirancang khusus untuk membedakan klien dari kompetitor mereka.

## **2\. Struktur Organisasi (The Core Units)**

DGT.LZ beroperasi melalui empat divisi spesialis yang saling terintegrasi:

### **A. dgt.lz Studio (Creative & Design)**

Unit yang bertanggung jawab atas wajah visual dan pengalaman pengguna.

-   **Layanan:** UI/UX Design (Web & App), Logo Design, Poster Design.

### **B. dgt.lz Labs (AI & Experimental Tech)**

Pusat inovasi untuk integrasi kecerdasan buatan dalam operasional bisnis.

-   **Layanan:** AI Chatbot Business, Customer Service Automation, AI Content System, Internal AI Tools.

### **C. dgt.lz Systems (Infrastructure & Automation)**

Mesin penggerak teknis yang membangun fondasi digital yang kokoh.

-   **Layanan:** Web Development (Company Profile, Landing Page, E-commerce), Custom Web App, Dashboard/Admin Panel, WhatsApp & Workflow Automation.

### **D. dgt.lz Media (Growth & Visibility)**

Divisi yang memastikan sistem digital klien ditemukan oleh pasar yang tepat.

-   **Layanan:** SEO (Search Engine Optimization), Digital Campaign & Performance Marketing (Ads).

## **3\. Ekosistem Layanan (Full Stack Services)**

<table><tbody><tr><td><p><strong>Kategori</strong></p></td><td><p><strong>Detail Layanan</strong></p></td></tr><tr><td><p><strong>Web &amp; Dev</strong></p></td><td><p>Website Company Profile, Landing Page, E-commerce, Dashboard/Admin Panel, Custom Web App.</p></td></tr><tr><td><p><strong>AI &amp; Automation</strong></p></td><td><p>AI Chatbot, Customer Service Automation, WhatsApp Automation, Workflow Automation, Internal AI Tools.</p></td></tr><tr><td><p><strong>Design</strong></p></td><td><p>High-end UI/UX Design, Authentic Logo, High-impact Poster.</p></td></tr><tr><td><p><strong>Maintenance</strong></p></td><td><p>Website Maintenance, Custom Software Support, AI &amp; Automation Monitoring.</p></td></tr></tbody></table>

## **4\. Model Pendapatan (Revenue Streams)**

DGT.LZ menggunakan pendekatan tiga lapis untuk menjaga stabilitas finansial:

1.  **Project-Based (Injeksi Modal):**
    -   Pembayaran satu kali untuk solusi *custom*.
    -   Contoh: Pembuatan Website E-commerce atau Setup AI Chatbot awal.
2.  **Monthly Retainer (Pendapatan Stabil):**
    -   Biaya langganan bulanan untuk layanan jangka panjang.
    -   Contoh: Pemeliharaan sistem, monitoring otomasi, dan SEO bulanan.
3.  **Productized Service (Skalabilitas Cepat):**
    -   Paket layanan tetap dengan harga dan waktu pengerjaan yang pasti.
    -   Contoh: *"Web 7 Hari"*, *"AI Chatbot Starter"*, atau *"Business Digital Setup"*.

## **5\. Alur Kerja Operasional (Workflow)**

1.  **Discovery :** Proses menjangkau klien (*outreach*) dan memahami masalah utama bisnis mereka.
2.  **Strategic Proposal:** Menyusun solusi teknologi yang menggabungkan Studio, Labs, dan Systems.
3.  **Production (Team):** Eksekusi teknis dengan standar kualitas tinggi dan pengawasan ketat pada detail estetika.
4.  **Deployment & Handover:** Peluncuran sistem dan penyerahan aset digital kepada klien.
5.  **Optimization (Retainer):** Pemantauan berkala dan pembaruan sistem untuk memastikan performa tetap maksimal.

## **6\. Target Pasar**

Fokus utama adalah **Bisnis dan Brandi** yang ingin melakukan transformasi digital secara serius, terutama mereka yang menghargai kualitas desain dan membutuhkan efisiensi melalui teknologi AI.', 'published', '2026-06-18 03:32:40.045+00', '2026-06-18 04:02:41.342+00', '00000000-0000-0000-0000-000000000002', 'dgtlz-4zlq0i', 'aaaaaaaa-0000-0000-0000-000000000001', NULL, NULL, NULL, NULL, NULL, '2026-06-18 03:40:17.327+00') ON CONFLICT DO NOTHING;
INSERT INTO public.articles (id, title, subtitle, excerpt, author, role, date, "time", category, "imageUrl", "contentArr", "contentStr", status, "createdAt", "updatedAt", author_id, slug, category_id, featured_image_id, og_image_id, meta_description, meta_keywords, canonical_url, published_at) VALUES ('trend-1', 'Elections 2026: Key Battleground States Shift', 'Recent polling shows unexpected demographic realignments.', 'Recent polling shows unexpected demographic realignments.', 'Amanda Pierce', 'Political Analyst', 'April 13, 2026', '12 hours ago', 'Politics', 'https://picsum.photos/seed/vote/600/400', '{"Elections 2026: Key Battleground States Shift marks a significant turning point in recent developments. Experts and analysts have been closely monitoring the situation, noting that the implications could be far-reaching and transformative across multiple sectors.","\"This is unprecedented in many ways,\" stated a leading researcher familiar with the matter. \"We are seeing patterns that challenge our previous models and force us to rethink our long-term strategies.\" The data collected over the past few months supports this assertion, showing a clear deviation from historical norms.","Stakeholders are now scrambling to adjust to the new reality. While some view this as a challenge, others see it as a unique opportunity for innovation and growth. The coming weeks will be critical in determining the ultimate trajectory of these events.","As the situation continues to evolve, one thing is certain: the landscape has changed permanently. Observers advise cautious optimism while preparing for a range of possible outcomes in the near future."}', NULL, 'published', '2026-06-18 01:57:55.880228+00', '2026-06-18 01:57:55.880228+00', 'bbbbbbbb-0000-0000-0000-000000000001', 'trend-1', 'aaaaaaaa-0000-0000-0000-000000000005', NULL, NULL, NULL, NULL, NULL, '2026-06-18 01:57:55.880228+00') ON CONFLICT DO NOTHING;
INSERT INTO public.articles (id, title, subtitle, excerpt, author, role, date, "time", category, "imageUrl", "contentArr", "contentStr", status, "createdAt", "updatedAt", author_id, slug, category_id, featured_image_id, og_image_id, meta_description, meta_keywords, canonical_url, published_at) VALUES ('trend-2', 'The Future of Remote Work: Post-Pandemic Reality', 'Companies settle into permanent hybrid models as office leases expire.', 'Companies settle into permanent hybrid models as office leases expire.', 'Marcus Johnson', 'Workplace Reporter', 'April 13, 2026', '14 hours ago', 'Business', 'https://picsum.photos/seed/office/600/400', '{"The Future of Remote Work: Post-Pandemic Reality marks a significant turning point in recent developments. Experts and analysts have been closely monitoring the situation, noting that the implications could be far-reaching and transformative across multiple sectors.","\"This is unprecedented in many ways,\" stated a leading researcher familiar with the matter. \"We are seeing patterns that challenge our previous models and force us to rethink our long-term strategies.\" The data collected over the past few months supports this assertion, showing a clear deviation from historical norms.","Stakeholders are now scrambling to adjust to the new reality. While some view this as a challenge, others see it as a unique opportunity for innovation and growth. The coming weeks will be critical in determining the ultimate trajectory of these events.","As the situation continues to evolve, one thing is certain: the landscape has changed permanently. Observers advise cautious optimism while preparing for a range of possible outcomes in the near future."}', NULL, 'published', '2026-06-18 01:57:55.880228+00', '2026-06-18 01:57:55.880228+00', 'bbbbbbbb-0000-0000-0000-000000000001', 'trend-2', 'aaaaaaaa-0000-0000-0000-000000000001', NULL, NULL, NULL, NULL, NULL, '2026-06-18 01:57:55.880228+00') ON CONFLICT DO NOTHING;
INSERT INTO public.articles (id, title, subtitle, excerpt, author, role, date, "time", category, "imageUrl", "contentArr", "contentStr", status, "createdAt", "updatedAt", author_id, slug, category_id, featured_image_id, og_image_id, meta_description, meta_keywords, canonical_url, published_at) VALUES ('trend-3', 'Electric Vehicle Sales Surpass Traditional Autos in Europe', 'A historic milestone for the automotive industry.', 'A historic milestone for the automotive industry.', 'Sophie Laurent', 'European Correspondent', 'April 13, 2026', '16 hours ago', 'Tech', 'https://picsum.photos/seed/ev/600/400', '{"Electric Vehicle Sales Surpass Traditional Autos in Europe marks a significant turning point in recent developments. Experts and analysts have been closely monitoring the situation, noting that the implications could be far-reaching and transformative across multiple sectors.","\"This is unprecedented in many ways,\" stated a leading researcher familiar with the matter. \"We are seeing patterns that challenge our previous models and force us to rethink our long-term strategies.\" The data collected over the past few months supports this assertion, showing a clear deviation from historical norms.","Stakeholders are now scrambling to adjust to the new reality. While some view this as a challenge, others see it as a unique opportunity for innovation and growth. The coming weeks will be critical in determining the ultimate trajectory of these events.","As the situation continues to evolve, one thing is certain: the landscape has changed permanently. Observers advise cautious optimism while preparing for a range of possible outcomes in the near future."}', NULL, 'published', '2026-06-18 01:57:55.880228+00', '2026-06-18 01:57:55.880228+00', 'bbbbbbbb-0000-0000-0000-000000000001', 'trend-3', 'aaaaaaaa-0000-0000-0000-000000000003', NULL, NULL, NULL, NULL, NULL, '2026-06-18 01:57:55.880228+00') ON CONFLICT DO NOTHING;
INSERT INTO public.articles (id, title, subtitle, excerpt, author, role, date, "time", category, "imageUrl", "contentArr", "contentStr", status, "createdAt", "updatedAt", author_id, slug, category_id, featured_image_id, og_image_id, meta_description, meta_keywords, canonical_url, published_at) VALUES ('trend-4', 'Healthcare Reform Bill Passes Senate with Narrow Margin', 'Sweeping changes to prescription drug pricing approved.', 'Sweeping changes to prescription drug pricing approved.', 'Thomas Wright', 'Capitol Hill Reporter', 'April 13, 2026', '18 hours ago', 'Health', 'https://picsum.photos/seed/health/600/400', '{"Healthcare Reform Bill Passes Senate with Narrow Margin marks a significant turning point in recent developments. Experts and analysts have been closely monitoring the situation, noting that the implications could be far-reaching and transformative across multiple sectors.","\"This is unprecedented in many ways,\" stated a leading researcher familiar with the matter. \"We are seeing patterns that challenge our previous models and force us to rethink our long-term strategies.\" The data collected over the past few months supports this assertion, showing a clear deviation from historical norms.","Stakeholders are now scrambling to adjust to the new reality. While some view this as a challenge, others see it as a unique opportunity for innovation and growth. The coming weeks will be critical in determining the ultimate trajectory of these events.","As the situation continues to evolve, one thing is certain: the landscape has changed permanently. Observers advise cautious optimism while preparing for a range of possible outcomes in the near future."}', NULL, 'published', '2026-06-18 01:57:55.880228+00', '2026-06-18 01:57:55.880228+00', 'bbbbbbbb-0000-0000-0000-000000000001', 'trend-4', 'aaaaaaaa-0000-0000-0000-000000000006', NULL, NULL, NULL, NULL, NULL, '2026-06-18 01:57:55.880228+00') ON CONFLICT DO NOTHING;
INSERT INTO public.articles (id, title, subtitle, excerpt, author, role, date, "time", category, "imageUrl", "contentArr", "contentStr", status, "createdAt", "updatedAt", author_id, slug, category_id, featured_image_id, og_image_id, meta_description, meta_keywords, canonical_url, published_at) VALUES ('trend-5', 'Space Tourism: First Commercial Flight Scheduled for Next Month', 'Civilian passengers prepare for suborbital journey.', 'Civilian passengers prepare for suborbital journey.', 'Dr. Elena Rostova', 'Science Contributor', 'April 12, 2026', '1 day ago', 'Science', 'https://picsum.photos/seed/space/600/400', '{"Space Tourism: First Commercial Flight Scheduled for Next Month marks a significant turning point in recent developments. Experts and analysts have been closely monitoring the situation, noting that the implications could be far-reaching and transformative across multiple sectors.","\"This is unprecedented in many ways,\" stated a leading researcher familiar with the matter. \"We are seeing patterns that challenge our previous models and force us to rethink our long-term strategies.\" The data collected over the past few months supports this assertion, showing a clear deviation from historical norms.","Stakeholders are now scrambling to adjust to the new reality. While some view this as a challenge, others see it as a unique opportunity for innovation and growth. The coming weeks will be critical in determining the ultimate trajectory of these events.","As the situation continues to evolve, one thing is certain: the landscape has changed permanently. Observers advise cautious optimism while preparing for a range of possible outcomes in the near future."}', NULL, 'published', '2026-06-18 01:57:55.880228+00', '2026-06-18 01:57:55.880228+00', 'bbbbbbbb-0000-0000-0000-000000000001', 'trend-5', 'aaaaaaaa-0000-0000-0000-000000000004', NULL, NULL, NULL, NULL, NULL, '2026-06-18 01:57:55.880228+00') ON CONFLICT DO NOTHING;


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: article_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: authors; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.authors (id, profile_id, name, slug, bio, avatar_url, email, twitter_handle, linkedin_url, website_url, is_staff, is_active, article_count, "createdAt", "updatedAt") VALUES ('bbbbbbbb-0000-0000-0000-000000000001', NULL, 'Editorial Team', 'editorial-team', 'Lensa Insignia editorial staff.', NULL, NULL, NULL, NULL, NULL, false, true, 0, '2026-06-18 01:57:55.880228+00', '2026-06-18 01:57:55.880228+00') ON CONFLICT DO NOTHING;
INSERT INTO public.authors (id, profile_id, name, slug, bio, avatar_url, email, twitter_handle, linkedin_url, website_url, is_staff, is_active, article_count, "createdAt", "updatedAt") VALUES ('a4e2ad90-4bc3-4ca6-bd1e-7dcb5478591b', '00000000-0000-0000-0000-000000000002', 'Dev User', 'dev-user', NULL, NULL, NULL, NULL, NULL, NULL, false, true, 0, '2026-06-18 03:13:51.845236+00', '2026-06-18 03:13:51.845236+00') ON CONFLICT DO NOTHING;


--
-- Data for Name: gallery; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.gallery (id, name, url, "uploadedAt") VALUES ('a480a0c4-f173-46e4-8041-396b67447b8b', 'dgt_lz_light.png', '/storage/v1/object/public/images/1781755310621-ftdtludon3t.png', '2026-06-18 04:01:51.176+00') ON CONFLICT DO NOTHING;


--
-- Name: ad_sponsors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ad_sponsors_id_seq', 1, false);


--
-- PostgreSQL database dump complete
--

\unrestrict kQb6GMSnCtqYlO0k6fNhzWJ0tA82evY5Iy3kS6KUehe3P5k7g8ZHVI8hgKQBGzX

