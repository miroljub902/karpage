--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: cars; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cars (
    id integer NOT NULL,
    model_id integer,
    user_id integer,
    year integer NOT NULL,
    slug character varying NOT NULL,
    description text,
    first boolean DEFAULT false NOT NULL,
    current boolean DEFAULT true NOT NULL,
    past boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    hits integer DEFAULT 0 NOT NULL
);


--
-- Name: cars_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cars_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cars_id_seq OWNED BY cars.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    commentable_id integer,
    commentable_type character varying,
    user_id integer,
    body text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: friendly_id_slugs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE friendly_id_slugs (
    id integer NOT NULL,
    slug character varying NOT NULL,
    sluggable_id integer NOT NULL,
    sluggable_type character varying(50),
    scope character varying,
    created_at timestamp without time zone
);


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE friendly_id_slugs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: friendly_id_slugs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE friendly_id_slugs_id_seq OWNED BY friendly_id_slugs.id;


--
-- Name: identities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE identities (
    id integer NOT NULL,
    user_id integer NOT NULL,
    provider character varying,
    uid character varying,
    oauth_token character varying,
    oauth_expires_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: identities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: identities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE identities_id_seq OWNED BY identities.id;


--
-- Name: makes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE makes (
    id integer NOT NULL,
    name character varying NOT NULL,
    slug character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: makes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE makes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: makes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE makes_id_seq OWNED BY makes.id;


--
-- Name: models; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE models (
    id integer NOT NULL,
    make_id integer,
    name character varying NOT NULL,
    slug character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: models_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE models_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: models_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE models_id_seq OWNED BY models.id;


--
-- Name: photos; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE photos (
    id integer NOT NULL,
    attachable_type character varying,
    attachable_id integer,
    photo_type character varying,
    image_id character varying,
    image_filename character varying,
    image_size integer,
    image_content_type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sorting integer
);


--
-- Name: photos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE photos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: photos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE photos_id_seq OWNED BY photos.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying,
    name character varying,
    login character varying,
    crypted_password character varying,
    password_salt character varying,
    persistence_token character varying,
    single_access_token character varying,
    perishable_token character varying,
    login_count integer DEFAULT 0 NOT NULL,
    failed_login_count integer DEFAULT 0 NOT NULL,
    last_request_at timestamp without time zone,
    current_login_at timestamp without time zone,
    last_login_at timestamp without time zone,
    current_login_ip character varying,
    last_login_ip character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cars ALTER COLUMN id SET DEFAULT nextval('cars_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY friendly_id_slugs ALTER COLUMN id SET DEFAULT nextval('friendly_id_slugs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY identities ALTER COLUMN id SET DEFAULT nextval('identities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY makes ALTER COLUMN id SET DEFAULT nextval('makes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY models ALTER COLUMN id SET DEFAULT nextval('models_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY photos ALTER COLUMN id SET DEFAULT nextval('photos_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: cars_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cars
    ADD CONSTRAINT cars_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: friendly_id_slugs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY friendly_id_slugs
    ADD CONSTRAINT friendly_id_slugs_pkey PRIMARY KEY (id);


--
-- Name: identities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: makes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY makes
    ADD CONSTRAINT makes_pkey PRIMARY KEY (id);


--
-- Name: models_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY models
    ADD CONSTRAINT models_pkey PRIMARY KEY (id);


--
-- Name: photos_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY photos
    ADD CONSTRAINT photos_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_cars_on_current; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cars_on_current ON cars USING btree (current);


--
-- Name: index_cars_on_first; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cars_on_first ON cars USING btree (first);


--
-- Name: index_cars_on_hits; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cars_on_hits ON cars USING btree (hits);


--
-- Name: index_cars_on_model_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cars_on_model_id ON cars USING btree (model_id);


--
-- Name: index_cars_on_past; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cars_on_past ON cars USING btree (past);


--
-- Name: index_cars_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cars_on_user_id ON cars USING btree (user_id);


--
-- Name: index_cars_on_user_id_and_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_cars_on_user_id_and_slug ON cars USING btree (user_id, slug);


--
-- Name: index_cars_on_year; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cars_on_year ON cars USING btree (year);


--
-- Name: index_comments_on_commentable_type_and_commentable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_commentable_type_and_commentable_id ON comments USING btree (commentable_type, commentable_id);


--
-- Name: index_comments_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_user_id ON comments USING btree (user_id);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type ON friendly_id_slugs USING btree (slug, sluggable_type);


--
-- Name: index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope ON friendly_id_slugs USING btree (slug, sluggable_type, scope);


--
-- Name: index_friendly_id_slugs_on_sluggable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_id ON friendly_id_slugs USING btree (sluggable_id);


--
-- Name: index_friendly_id_slugs_on_sluggable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_friendly_id_slugs_on_sluggable_type ON friendly_id_slugs USING btree (sluggable_type);


--
-- Name: index_identities_on_provider_and_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_identities_on_provider_and_uid ON identities USING btree (provider, uid);


--
-- Name: index_identities_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_identities_on_user_id ON identities USING btree (user_id);


--
-- Name: index_identities_on_user_id_and_provider_and_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_identities_on_user_id_and_provider_and_uid ON identities USING btree (user_id, provider, uid);


--
-- Name: index_makes_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_makes_on_name ON makes USING btree (lower((name)::text));


--
-- Name: index_makes_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_makes_on_slug ON makes USING btree (slug);


--
-- Name: index_models_on_make_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_models_on_make_id ON models USING btree (make_id);


--
-- Name: index_models_on_make_id_and_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_models_on_make_id_and_slug ON models USING btree (make_id, slug);


--
-- Name: index_models_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_models_on_name ON models USING btree (make_id, lower((name)::text));


--
-- Name: index_photos_on_attachable_type_and_attachable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_photos_on_attachable_type_and_attachable_id ON photos USING btree (attachable_type, attachable_id);


--
-- Name: index_photos_on_attachable_type_and_attachable_id_and_sorting; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_photos_on_attachable_type_and_attachable_id_and_sorting ON photos USING btree (attachable_type, attachable_id, sorting);


--
-- Name: index_photos_on_photo_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_photos_on_photo_type ON photos USING btree (photo_type);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_login; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_login ON users USING btree (login);


--
-- Name: index_users_on_perishable_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_perishable_token ON users USING btree (perishable_token);


--
-- Name: index_users_on_persistence_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_persistence_token ON users USING btree (persistence_token);


--
-- Name: index_users_on_single_access_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_single_access_token ON users USING btree (single_access_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: fk_rails_03de2dc08c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT fk_rails_03de2dc08c FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_7eccb46500; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cars
    ADD CONSTRAINT fk_rails_7eccb46500 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_9005a2dc8e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cars
    ADD CONSTRAINT fk_rails_9005a2dc8e FOREIGN KEY (model_id) REFERENCES models(id);


--
-- Name: fk_rails_d7d4f87ebe; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY models
    ADD CONSTRAINT fk_rails_d7d4f87ebe FOREIGN KEY (make_id) REFERENCES makes(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20151014220734');

INSERT INTO schema_migrations (version) VALUES ('20151015022815');

INSERT INTO schema_migrations (version) VALUES ('20151021231852');

INSERT INTO schema_migrations (version) VALUES ('20151021231922');

INSERT INTO schema_migrations (version) VALUES ('20151021233251');

INSERT INTO schema_migrations (version) VALUES ('20151021235437');

INSERT INTO schema_migrations (version) VALUES ('20151022205617');

INSERT INTO schema_migrations (version) VALUES ('20151023004903');

INSERT INTO schema_migrations (version) VALUES ('20151027194013');

INSERT INTO schema_migrations (version) VALUES ('20151027195233');

