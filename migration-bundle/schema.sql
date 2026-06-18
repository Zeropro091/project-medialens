--
-- PostgreSQL database dump
--

\restrict sTdfEN3RCdIe8rEXk9BNzJEDCvhdYH3tnwe4bfKuPHmZuisSNkWHdeJEeTKqEdd

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: categories_set_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.categories_set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new."updatedAt" = now();
  return new;
end;
$$;


ALTER FUNCTION public.categories_set_updated_at() OWNER TO postgres;

--
-- Name: check_article_tag_limit(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_article_tag_limit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  if (
    select count(*)
    from public.article_tags
    where article_id = new.article_id
  ) >= 10 then
    raise exception 'Article cannot have more than 10 tags';
  end if;
  return new;
end;
$$;


ALTER FUNCTION public.check_article_tag_limit() OWNER TO postgres;

--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
  signup_role text;
begin
  -- Get role from metadata, default to 'user'
  signup_role := coalesce(new.raw_user_meta_data->>'role', 'user');

  -- Enforce specific emails override role
  if new.email = 'admin@admin.com' then
    signup_role := 'admin';
  elsif new.email = 'dev@dev.com' then
    signup_role := 'dev';
  end if;

  insert into public.profiles (id, email, role, quota, full_name, pen_name, bio, profile_photo, phone_number, city)
  values (
    new.id,
    new.email,
    signup_role,
    case
      when signup_role in ('admin', 'dev') then 999
      else 5
    end,
    coalesce(
      nullif(trim(new.raw_user_meta_data->>'full_name'), ''),
      split_part(new.email, '@', 1)
    ),
    nullif(trim(coalesce(new.raw_user_meta_data->>'pen_name', '')), ''),
    nullif(trim(coalesce(new.raw_user_meta_data->>'bio', '')), ''),
    nullif(trim(coalesce(new.raw_user_meta_data->>'profile_photo', '')), ''),
    nullif(trim(coalesce(new.raw_user_meta_data->>'phone_number', '')), ''),
    nullif(trim(coalesce(new.raw_user_meta_data->>'city', '')), '')
  );
  return new;
end;
$$;


ALTER FUNCTION public.handle_new_user() OWNER TO postgres;

--
-- Name: is_admin(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.is_admin() RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  return exists (
    select 1 from public.profiles
    where id = auth.uid()
    and role = 'admin'
  );
end;
$$;


ALTER FUNCTION public.is_admin() OWNER TO postgres;

--
-- Name: is_admin_or_dev(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.is_admin_or_dev() RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  return exists (
    select 1 from public.profiles
    where id = auth.uid()
    and role in ('admin', 'dev')
  );
end;
$$;


ALTER FUNCTION public.is_admin_or_dev() OWNER TO postgres;

--
-- Name: is_dev(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.is_dev() RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  return exists (
    select 1 from public.profiles
    where id = auth.uid()
    and role = 'dev'
  );
end;
$$;


ALTER FUNCTION public.is_dev() OWNER TO postgres;

--
-- Name: manage_article_quota(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.manage_article_quota() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  u_role text;
  u_quota integer;
BEGIN
  IF NEW.author_id IS NULL THEN
    NEW.author_id := auth.uid();
  END IF;

  IF NEW.author_id IS NOT NULL THEN
    SELECT role, quota
      INTO u_role, u_quota
      FROM public.profiles
     WHERE id = NEW.author_id;

    IF u_role = 'poster' THEN
      IF u_quota IS NULL OR u_quota <= 0 THEN
        RAISE EXCEPTION 'Insufficient article quota. Please request more quota from an administrator.';
      END IF;
      UPDATE public.profiles SET quota = quota - 1 WHERE id = NEW.author_id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.manage_article_quota() OWNER TO postgres;

--
-- Name: set_authors_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_authors_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new."updatedAt" = now();
  return new;
end;
$$;


ALTER FUNCTION public.set_authors_updated_at() OWNER TO postgres;

--
-- Name: set_tags_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_tags_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new."updatedAt" = now();
  return new;
end;
$$;


ALTER FUNCTION public.set_tags_updated_at() OWNER TO postgres;

--
-- Name: update_author_article_count(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_author_article_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  if (TG_OP = 'INSERT') then
    -- New article published with a known author
    if new.status = 'published' and new.author_id is not null then
      update public.authors
        set article_count = article_count + 1
        where id = new.author_id;
    end if;

  elsif (TG_OP = 'UPDATE') then
    -- Transition: published → not-published (unpublish)
    if old.status = 'published' and new.status <> 'published' then
      if old.author_id is not null then
        update public.authors
          set article_count = greatest(article_count - 1, 0)
          where id = old.author_id;
      end if;

    -- Transition: not-published → published (publish)
    elsif old.status <> 'published' and new.status = 'published' then
      if new.author_id is not null then
        update public.authors
          set article_count = article_count + 1
          where id = new.author_id;
      end if;

    -- Same status but author reassigned while published
    elsif new.status = 'published' and old.author_id is distinct from new.author_id then
      if old.author_id is not null then
        update public.authors
          set article_count = greatest(article_count - 1, 0)
          where id = old.author_id;
      end if;
      if new.author_id is not null then
        update public.authors
          set article_count = article_count + 1
          where id = new.author_id;
      end if;
    end if;

  elsif (TG_OP = 'DELETE') then
    -- Article deleted while published
    if old.status = 'published' and old.author_id is not null then
      update public.authors
        set article_count = greatest(article_count - 1, 0)
        where id = old.author_id;
    end if;
  end if;

  return null;
end;
$$;


ALTER FUNCTION public.update_author_article_count() OWNER TO postgres;

--
-- Name: update_tag_usage_count(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_tag_usage_count() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  if (TG_OP = 'INSERT') then
    update public.tags
    set usage_count = usage_count + 1
    where id = new.tag_id;
  elsif (TG_OP = 'DELETE') then
    update public.tags
    set usage_count = greatest(usage_count - 1, 0)
    where id = old.tag_id;
  end if;
  return null;
end;
$$;


ALTER FUNCTION public.update_tag_usage_count() OWNER TO postgres;

--
-- Name: validate_profile_update(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validate_profile_update() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  updater_role text;
BEGIN
  updater_role := (SELECT role FROM public.profiles WHERE id = auth.uid());

  -- Users can update their own profile (e.g. writer application)
  IF auth.uid() = OLD.id THEN
    IF NEW.role NOT IN ('user', 'poster') AND updater_role NOT IN ('admin', 'dev') THEN
      RAISE EXCEPTION 'You can only apply for the poster role.';
    END IF;
    RETURN NEW;
  END IF;

  -- Must be admin or dev to modify other profiles
  IF updater_role NOT IN ('admin', 'dev') THEN
    RAISE EXCEPTION 'Unauthorized to update profiles.';
  END IF;

  -- Admin cannot modify Dev profile or promote to admin/dev
  IF updater_role = 'admin' THEN
    IF (NEW.role IN ('admin', 'dev') AND OLD.role NOT IN ('admin', 'dev')) THEN
      RAISE EXCEPTION 'Only developers can promote users to Admin or Developer.';
    END IF;
    IF OLD.role = 'dev' THEN
      RAISE EXCEPTION 'Administrators cannot modify Developer profiles.';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.validate_profile_update() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ad_sponsors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ad_sponsors (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    name text NOT NULL,
    image_url text DEFAULT ''::text NOT NULL,
    target_url text DEFAULT ''::text NOT NULL,
    is_active boolean DEFAULT false NOT NULL,
    duration_seconds integer DEFAULT 10 NOT NULL,
    frequency integer DEFAULT 3 NOT NULL,
    created_by uuid
);


ALTER TABLE public.ad_sponsors OWNER TO postgres;

--
-- Name: ad_sponsors_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ad_sponsors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ad_sponsors_id_seq OWNER TO postgres;

--
-- Name: ad_sponsors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ad_sponsors_id_seq OWNED BY public.ad_sponsors.id;


--
-- Name: article_tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.article_tags (
    article_id text NOT NULL,
    tag_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.article_tags OWNER TO postgres;

--
-- Name: TABLE article_tags; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.article_tags IS 'Junction table for many-to-many article ↔ tag associations.';


--
-- Name: articles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.articles (
    id text DEFAULT (gen_random_uuid())::text NOT NULL,
    title text NOT NULL,
    subtitle text,
    excerpt text,
    author text NOT NULL,
    role text,
    date text NOT NULL,
    "time" text,
    category text,
    "imageUrl" text,
    "contentArr" text[],
    "contentStr" text,
    status text DEFAULT 'published'::text NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now(),
    "updatedAt" timestamp with time zone DEFAULT now(),
    author_id uuid,
    slug text,
    category_id uuid,
    featured_image_id uuid,
    og_image_id uuid,
    meta_description text,
    meta_keywords text,
    canonical_url text,
    published_at timestamp with time zone,
    CONSTRAINT articles_excerpt_length CHECK (((excerpt IS NULL) OR (char_length(excerpt) <= 300))),
    CONSTRAINT articles_published_requires_fields CHECK (((status <> 'published'::text) OR ((title IS NOT NULL) AND (slug IS NOT NULL) AND (category_id IS NOT NULL) AND (author_id IS NOT NULL) AND (published_at IS NOT NULL)))),
    CONSTRAINT articles_slug_format CHECK (((slug IS NULL) OR (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'::text))),
    CONSTRAINT articles_status_check CHECK ((status = ANY (ARRAY['published'::text, 'draft'::text, 'archived'::text]))),
    CONSTRAINT articles_title_length CHECK ((char_length(title) <= 200))
);


ALTER TABLE public.articles OWNER TO postgres;

--
-- Name: COLUMN articles.author; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.articles.author IS 'DEPRECATED: use author_id (FK to authors table)';


--
-- Name: COLUMN articles.role; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.articles.role IS 'DEPRECATED: use authors.is_staff or profiles.role';


--
-- Name: COLUMN articles.date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.articles.date IS 'DEPRECATED: use createdAt or published_at';


--
-- Name: COLUMN articles."time"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.articles."time" IS 'DEPRECATED: use createdAt or published_at';


--
-- Name: COLUMN articles.category; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.articles.category IS 'DEPRECATED: use category_id (FK to categories table)';


--
-- Name: COLUMN articles."imageUrl"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.articles."imageUrl" IS 'DEPRECATED: use featured_image_id (FK to media table)';


--
-- Name: authors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.authors (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    profile_id uuid,
    name text NOT NULL,
    slug text NOT NULL,
    bio text,
    avatar_url text,
    email text,
    twitter_handle text,
    linkedin_url text,
    website_url text,
    is_staff boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    article_count integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT authors_article_count_nonneg CHECK ((article_count >= 0)),
    CONSTRAINT authors_bio_length CHECK (((bio IS NULL) OR (char_length(bio) <= 500))),
    CONSTRAINT authors_email_format CHECK (((email IS NULL) OR (email ~* '^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$'::text))),
    CONSTRAINT authors_name_length CHECK ((char_length(name) <= 100))
);


ALTER TABLE public.authors OWNER TO postgres;

--
-- Name: TABLE authors; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.authors IS 'Author profiles, decoupled from auth user accounts.';


--
-- Name: COLUMN authors.profile_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.authors.profile_id IS 'Optional FK to profiles.id; NULL for contributors without accounts.';


--
-- Name: COLUMN authors.slug; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.authors.slug IS 'Globally unique, URL-friendly identifier for author pages.';


--
-- Name: COLUMN authors.bio; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.authors.bio IS 'Short biography; max 500 characters.';


--
-- Name: COLUMN authors.email; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.authors.email IS 'Public contact email; validated via CHECK constraint.';


--
-- Name: COLUMN authors.article_count; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.authors.article_count IS 'Denormalised count of published articles; maintained by trigger.';


--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    slug text NOT NULL,
    name text NOT NULL,
    description text,
    parent_id uuid,
    level integer DEFAULT 0 NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    seo_title text,
    seo_description text,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT categories_level_valid CHECK (((level >= 0) AND (level <= 3)))
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- Name: gallery; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gallery (
    id text DEFAULT (gen_random_uuid())::text NOT NULL,
    name text NOT NULL,
    url text NOT NULL,
    "uploadedAt" timestamp with time zone DEFAULT now()
);


ALTER TABLE public.gallery OWNER TO postgres;

--
-- Name: media; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.media (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    filename text NOT NULL,
    storage_path text NOT NULL,
    public_url text NOT NULL,
    mime_type text NOT NULL,
    file_size integer NOT NULL,
    width integer,
    height integer,
    alt_text text NOT NULL,
    caption text,
    credit text,
    uploaded_by uuid NOT NULL,
    "uploadedAt" timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT media_file_size_check CHECK ((file_size <= 10485760)),
    CONSTRAINT media_height_check CHECK (((height IS NULL) OR ((height >= 100) AND (height <= 4000)))),
    CONSTRAINT media_mime_type_check CHECK ((mime_type = ANY (ARRAY['image/jpeg'::text, 'image/png'::text, 'image/webp'::text, 'image/gif'::text]))),
    CONSTRAINT media_width_check CHECK (((width IS NULL) OR ((width >= 100) AND (width <= 4000))))
);


ALTER TABLE public.media OWNER TO postgres;

--
-- Name: profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    email text,
    role text DEFAULT 'user'::text,
    quota integer DEFAULT 5,
    "createdAt" timestamp with time zone DEFAULT now(),
    full_name text,
    pen_name text,
    bio text,
    profile_photo text,
    phone_number text,
    city text,
    CONSTRAINT profiles_role_check CHECK ((role = ANY (ARRAY['admin'::text, 'dev'::text, 'poster'::text, 'user'::text])))
);


ALTER TABLE public.profiles OWNER TO postgres;

--
-- Name: tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tags (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    slug text NOT NULL,
    name text NOT NULL,
    description text,
    usage_count integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT tags_name_length CHECK ((char_length(name) <= 50)),
    CONSTRAINT tags_usage_count_nonneg CHECK ((usage_count >= 0))
);


ALTER TABLE public.tags OWNER TO postgres;

--
-- Name: TABLE tags; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.tags IS 'Non-hierarchical content labels for many-to-many article associations.';


--
-- Name: COLUMN tags.slug; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tags.slug IS 'Globally unique, URL-friendly identifier.';


--
-- Name: COLUMN tags.usage_count; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tags.usage_count IS 'Denormalized count of articles using this tag; maintained by trigger.';


--
-- Name: ad_sponsors id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ad_sponsors ALTER COLUMN id SET DEFAULT nextval('public.ad_sponsors_id_seq'::regclass);


--
-- Name: ad_sponsors ad_sponsors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ad_sponsors
    ADD CONSTRAINT ad_sponsors_pkey PRIMARY KEY (id);


--
-- Name: article_tags article_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.article_tags
    ADD CONSTRAINT article_tags_pkey PRIMARY KEY (article_id, tag_id);


--
-- Name: articles articles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.articles
    ADD CONSTRAINT articles_pkey PRIMARY KEY (id);


--
-- Name: authors authors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.authors
    ADD CONSTRAINT authors_pkey PRIMARY KEY (id);


--
-- Name: authors authors_slug_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.authors
    ADD CONSTRAINT authors_slug_unique UNIQUE (slug);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: categories categories_slug_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_slug_unique UNIQUE (slug);


--
-- Name: gallery gallery_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gallery
    ADD CONSTRAINT gallery_pkey PRIMARY KEY (id);


--
-- Name: media media_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.media
    ADD CONSTRAINT media_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: tags tags_slug_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_slug_unique UNIQUE (slug);


--
-- Name: idx_ad_sponsors_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ad_sponsors_active ON public.ad_sponsors USING btree (is_active);


--
-- Name: idx_article_tags_article_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_article_tags_article_id ON public.article_tags USING btree (article_id);


--
-- Name: idx_article_tags_tag_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_article_tags_tag_id ON public.article_tags USING btree (tag_id);


--
-- Name: idx_articles_author_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_articles_author_id ON public.articles USING btree (author_id);


--
-- Name: idx_articles_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_articles_category ON public.articles USING btree (category);


--
-- Name: idx_articles_category_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_articles_category_id ON public.articles USING btree (category_id);


--
-- Name: idx_articles_category_slug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_articles_category_slug ON public.articles USING btree (category_id, slug) WHERE ((category_id IS NOT NULL) AND (slug IS NOT NULL));


--
-- Name: idx_articles_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_articles_created_at ON public.articles USING btree ("createdAt" DESC);


--
-- Name: idx_articles_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_articles_status ON public.articles USING btree (status);


--
-- Name: idx_articles_status_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_articles_status_created_at ON public.articles USING btree (status, "createdAt" DESC);


--
-- Name: idx_articles_status_published_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_articles_status_published_at ON public.articles USING btree (status, published_at DESC);


--
-- Name: idx_authors_profile_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_authors_profile_id ON public.authors USING btree (profile_id);


--
-- Name: idx_authors_slug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_authors_slug ON public.authors USING btree (slug);


--
-- Name: idx_categories_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_categories_active ON public.categories USING btree (is_active);


--
-- Name: idx_categories_parent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_categories_parent_id ON public.categories USING btree (parent_id);


--
-- Name: idx_categories_slug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_categories_slug ON public.categories USING btree (slug);


--
-- Name: idx_gallery_uploaded_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_gallery_uploaded_at ON public.gallery USING btree ("uploadedAt" DESC);


--
-- Name: idx_media_mime_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_media_mime_type ON public.media USING btree (mime_type);


--
-- Name: idx_media_uploaded_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_media_uploaded_by ON public.media USING btree (uploaded_by);


--
-- Name: idx_tags_slug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tags_slug ON public.tags USING btree (slug);


--
-- Name: categories categories_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER categories_updated_at BEFORE UPDATE ON public.categories FOR EACH ROW EXECUTE FUNCTION public.categories_set_updated_at();


--
-- Name: articles on_article_inserted; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER on_article_inserted BEFORE INSERT ON public.articles FOR EACH ROW EXECUTE FUNCTION public.manage_article_quota();


--
-- Name: profiles on_profile_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER on_profile_update BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.validate_profile_update();


--
-- Name: article_tags trg_article_tags_limit; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_article_tags_limit BEFORE INSERT ON public.article_tags FOR EACH ROW EXECUTE FUNCTION public.check_article_tag_limit();


--
-- Name: article_tags trg_article_tags_usage_count; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_article_tags_usage_count AFTER INSERT OR DELETE ON public.article_tags FOR EACH ROW EXECUTE FUNCTION public.update_tag_usage_count();


--
-- Name: articles trg_articles_author_article_count; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_articles_author_article_count AFTER INSERT OR DELETE OR UPDATE ON public.articles FOR EACH ROW EXECUTE FUNCTION public.update_author_article_count();


--
-- Name: authors trg_authors_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_authors_updated_at BEFORE UPDATE ON public.authors FOR EACH ROW EXECUTE FUNCTION public.set_authors_updated_at();


--
-- Name: tags trg_tags_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_tags_updated_at BEFORE UPDATE ON public.tags FOR EACH ROW EXECUTE FUNCTION public.set_tags_updated_at();


--
-- Name: ad_sponsors ad_sponsors_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ad_sponsors
    ADD CONSTRAINT ad_sponsors_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: article_tags article_tags_article_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.article_tags
    ADD CONSTRAINT article_tags_article_id_fkey FOREIGN KEY (article_id) REFERENCES public.articles(id) ON DELETE CASCADE;


--
-- Name: article_tags article_tags_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.article_tags
    ADD CONSTRAINT article_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tags(id) ON DELETE CASCADE;


--
-- Name: articles articles_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.articles
    ADD CONSTRAINT articles_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- Name: articles articles_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.articles
    ADD CONSTRAINT articles_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE SET NULL;


--
-- Name: articles articles_featured_image_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.articles
    ADD CONSTRAINT articles_featured_image_id_fkey FOREIGN KEY (featured_image_id) REFERENCES public.media(id) ON DELETE SET NULL;


--
-- Name: articles articles_og_image_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.articles
    ADD CONSTRAINT articles_og_image_id_fkey FOREIGN KEY (og_image_id) REFERENCES public.media(id) ON DELETE SET NULL;


--
-- Name: authors authors_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.authors
    ADD CONSTRAINT authors_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- Name: categories categories_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.categories(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: media media_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.media
    ADD CONSTRAINT media_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.profiles(id) ON DELETE RESTRICT;


--
-- Name: profiles profiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: profiles Admin and Dev can update all profiles; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admin and Dev can update all profiles" ON public.profiles FOR UPDATE USING (public.is_admin_or_dev());


--
-- Name: profiles Admin and Dev can view all profiles; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admin and Dev can view all profiles" ON public.profiles FOR SELECT USING (public.is_admin_or_dev());


--
-- Name: article_tags Admin full access to article_tags; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admin full access to article_tags" ON public.article_tags USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: tags Admin full access to tags; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Admin full access to tags" ON public.tags USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: authors Allow admin and dev to delete authors; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow admin and dev to delete authors" ON public.authors FOR DELETE USING (public.is_admin_or_dev());


--
-- Name: authors Allow admin and dev to insert authors; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow admin and dev to insert authors" ON public.authors FOR INSERT WITH CHECK (public.is_admin_or_dev());


--
-- Name: authors Allow admin and dev to update authors; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow admin and dev to update authors" ON public.authors FOR UPDATE USING (public.is_admin_or_dev());


--
-- Name: categories Allow admin to manage categories; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow admin to manage categories" ON public.categories USING ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = ANY (ARRAY['admin'::text, 'dev'::text])))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = ANY (ARRAY['admin'::text, 'dev'::text]))))));


--
-- Name: articles Allow admin, dev, or author to delete articles; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow admin, dev, or author to delete articles" ON public.articles FOR DELETE USING ((public.is_admin_or_dev() OR ((author_id = auth.uid()) AND (EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'poster'::text)))))));


--
-- Name: gallery Allow admin, dev, or author to delete gallery; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow admin, dev, or author to delete gallery" ON public.gallery FOR DELETE USING (public.is_admin_or_dev());


--
-- Name: articles Allow admin, dev, or author to update articles; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow admin, dev, or author to update articles" ON public.articles FOR UPDATE USING ((public.is_admin_or_dev() OR ((author_id = auth.uid()) AND (EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'poster'::text)))))));


--
-- Name: articles Allow authenticated users to insert articles; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow authenticated users to insert articles" ON public.articles FOR INSERT WITH CHECK (((auth.uid() IS NOT NULL) AND (public.is_admin_or_dev() OR (EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'poster'::text) AND (profiles.quota > 0)))))));


--
-- Name: gallery Allow authenticated users to insert gallery; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow authenticated users to insert gallery" ON public.gallery FOR INSERT WITH CHECK (((auth.uid() IS NOT NULL) AND (public.is_admin_or_dev() OR (EXISTS ( SELECT 1
   FROM public.profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'poster'::text)))))));


--
-- Name: media Allow authenticated users to upload media; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow authenticated users to upload media" ON public.media FOR INSERT WITH CHECK (((auth.uid() IS NOT NULL) AND (uploaded_by = auth.uid())));


--
-- Name: authors Allow public read access to active authors; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow public read access to active authors" ON public.authors FOR SELECT USING ((is_active = true));


--
-- Name: categories Allow public read access to active categories; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow public read access to active categories" ON public.categories FOR SELECT USING ((is_active = true));


--
-- Name: articles Allow public read access to articles; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow public read access to articles" ON public.articles FOR SELECT USING (true);


--
-- Name: gallery Allow public read access to gallery; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow public read access to gallery" ON public.gallery FOR SELECT USING (true);


--
-- Name: media Allow public read access to media; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow public read access to media" ON public.media FOR SELECT USING (true);


--
-- Name: media Allow uploader or admin to delete media; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow uploader or admin to delete media" ON public.media FOR DELETE USING (((uploaded_by = auth.uid()) OR public.is_admin_or_dev()));


--
-- Name: media Allow uploader or admin to update media; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow uploader or admin to update media" ON public.media FOR UPDATE USING (((uploaded_by = auth.uid()) OR public.is_admin_or_dev()));


--
-- Name: tags Public read active tags; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public read active tags" ON public.tags FOR SELECT USING ((is_active = true));


--
-- Name: article_tags Public read article_tags; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public read article_tags" ON public.article_tags FOR SELECT USING (true);


--
-- Name: ad_sponsors Sponsors admin/dev delete; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Sponsors admin/dev delete" ON public.ad_sponsors FOR DELETE USING (public.is_admin_or_dev());


--
-- Name: ad_sponsors Sponsors admin/dev insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Sponsors admin/dev insert" ON public.ad_sponsors FOR INSERT WITH CHECK (public.is_admin_or_dev());


--
-- Name: ad_sponsors Sponsors admin/dev select all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Sponsors admin/dev select all" ON public.ad_sponsors FOR SELECT USING (public.is_admin_or_dev());


--
-- Name: ad_sponsors Sponsors admin/dev update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Sponsors admin/dev update" ON public.ad_sponsors FOR UPDATE USING (public.is_admin_or_dev());


--
-- Name: ad_sponsors Sponsors public read active; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Sponsors public read active" ON public.ad_sponsors FOR SELECT USING ((is_active = true));


--
-- Name: profiles Users can view their own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view their own profile" ON public.profiles FOR SELECT USING ((auth.uid() = id));


--
-- Name: ad_sponsors; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.ad_sponsors ENABLE ROW LEVEL SECURITY;

--
-- Name: article_tags; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.article_tags ENABLE ROW LEVEL SECURITY;

--
-- Name: articles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.articles ENABLE ROW LEVEL SECURITY;

--
-- Name: authors; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.authors ENABLE ROW LEVEL SECURITY;

--
-- Name: categories; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

--
-- Name: gallery; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.gallery ENABLE ROW LEVEL SECURITY;

--
-- Name: media; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.media ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

--
-- Name: tags; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles users_can_update_own_profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY users_can_update_own_profile ON public.profiles FOR UPDATE USING ((auth.uid() = id)) WITH CHECK ((auth.uid() = id));


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- Name: FUNCTION categories_set_updated_at(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.categories_set_updated_at() TO anon;
GRANT ALL ON FUNCTION public.categories_set_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.categories_set_updated_at() TO service_role;


--
-- Name: FUNCTION check_article_tag_limit(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.check_article_tag_limit() TO anon;
GRANT ALL ON FUNCTION public.check_article_tag_limit() TO authenticated;
GRANT ALL ON FUNCTION public.check_article_tag_limit() TO service_role;


--
-- Name: FUNCTION handle_new_user(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.handle_new_user() TO anon;
GRANT ALL ON FUNCTION public.handle_new_user() TO authenticated;
GRANT ALL ON FUNCTION public.handle_new_user() TO service_role;


--
-- Name: FUNCTION is_admin(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.is_admin() TO anon;
GRANT ALL ON FUNCTION public.is_admin() TO authenticated;
GRANT ALL ON FUNCTION public.is_admin() TO service_role;


--
-- Name: FUNCTION is_admin_or_dev(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.is_admin_or_dev() TO anon;
GRANT ALL ON FUNCTION public.is_admin_or_dev() TO authenticated;
GRANT ALL ON FUNCTION public.is_admin_or_dev() TO service_role;


--
-- Name: FUNCTION is_dev(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.is_dev() TO anon;
GRANT ALL ON FUNCTION public.is_dev() TO authenticated;
GRANT ALL ON FUNCTION public.is_dev() TO service_role;


--
-- Name: FUNCTION manage_article_quota(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.manage_article_quota() TO anon;
GRANT ALL ON FUNCTION public.manage_article_quota() TO authenticated;
GRANT ALL ON FUNCTION public.manage_article_quota() TO service_role;


--
-- Name: FUNCTION set_authors_updated_at(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.set_authors_updated_at() TO anon;
GRANT ALL ON FUNCTION public.set_authors_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.set_authors_updated_at() TO service_role;


--
-- Name: FUNCTION set_tags_updated_at(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.set_tags_updated_at() TO anon;
GRANT ALL ON FUNCTION public.set_tags_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.set_tags_updated_at() TO service_role;


--
-- Name: FUNCTION update_author_article_count(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_author_article_count() TO anon;
GRANT ALL ON FUNCTION public.update_author_article_count() TO authenticated;
GRANT ALL ON FUNCTION public.update_author_article_count() TO service_role;


--
-- Name: FUNCTION update_tag_usage_count(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_tag_usage_count() TO anon;
GRANT ALL ON FUNCTION public.update_tag_usage_count() TO authenticated;
GRANT ALL ON FUNCTION public.update_tag_usage_count() TO service_role;


--
-- Name: FUNCTION validate_profile_update(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.validate_profile_update() TO anon;
GRANT ALL ON FUNCTION public.validate_profile_update() TO authenticated;
GRANT ALL ON FUNCTION public.validate_profile_update() TO service_role;


--
-- Name: TABLE ad_sponsors; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ad_sponsors TO anon;
GRANT ALL ON TABLE public.ad_sponsors TO authenticated;
GRANT ALL ON TABLE public.ad_sponsors TO service_role;


--
-- Name: SEQUENCE ad_sponsors_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.ad_sponsors_id_seq TO anon;
GRANT ALL ON SEQUENCE public.ad_sponsors_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.ad_sponsors_id_seq TO service_role;


--
-- Name: TABLE article_tags; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.article_tags TO anon;
GRANT ALL ON TABLE public.article_tags TO authenticated;
GRANT ALL ON TABLE public.article_tags TO service_role;


--
-- Name: TABLE articles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.articles TO anon;
GRANT ALL ON TABLE public.articles TO authenticated;
GRANT ALL ON TABLE public.articles TO service_role;


--
-- Name: TABLE authors; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.authors TO anon;
GRANT ALL ON TABLE public.authors TO authenticated;
GRANT ALL ON TABLE public.authors TO service_role;


--
-- Name: TABLE categories; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.categories TO anon;
GRANT ALL ON TABLE public.categories TO authenticated;
GRANT ALL ON TABLE public.categories TO service_role;


--
-- Name: TABLE gallery; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.gallery TO anon;
GRANT ALL ON TABLE public.gallery TO authenticated;
GRANT ALL ON TABLE public.gallery TO service_role;


--
-- Name: TABLE media; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.media TO anon;
GRANT ALL ON TABLE public.media TO authenticated;
GRANT ALL ON TABLE public.media TO service_role;


--
-- Name: TABLE profiles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.profiles TO anon;
GRANT ALL ON TABLE public.profiles TO authenticated;
GRANT ALL ON TABLE public.profiles TO service_role;


--
-- Name: TABLE tags; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.tags TO anon;
GRANT ALL ON TABLE public.tags TO authenticated;
GRANT ALL ON TABLE public.tags TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- PostgreSQL database dump complete
--

\unrestrict sTdfEN3RCdIe8rEXk9BNzJEDCvhdYH3tnwe4bfKuPHmZuisSNkWHdeJEeTKqEdd

