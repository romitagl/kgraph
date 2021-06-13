CREATE SCHEMA kgraph;
CREATE FUNCTION kgraph.set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$;
CREATE TABLE kgraph.labels (
    id integer NOT NULL,
    title text NOT NULL,
    description text,
    users_username text NOT NULL,
    updated_at timestamp with time zone DEFAULT now()
);
COMMENT ON TABLE kgraph.labels IS 'user labels';
CREATE SEQUENCE kgraph.labels_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE kgraph.labels_id_seq OWNED BY kgraph.labels.id;
CREATE TABLE kgraph.roles (
    id integer NOT NULL,
    name text NOT NULL,
    description text,
    "default" boolean DEFAULT false NOT NULL,
    admin boolean DEFAULT false NOT NULL
);
COMMENT ON TABLE kgraph.roles IS 'users roles';
CREATE SEQUENCE kgraph.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE kgraph.roles_id_seq OWNED BY kgraph.roles.id;
CREATE TABLE kgraph.topics (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    users_username text NOT NULL,
    parent_id uuid,
    name text NOT NULL,
    content text,
    public boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
COMMENT ON TABLE kgraph.topics IS 'topics table';
CREATE TABLE kgraph.topics_labels (
    labels_id integer NOT NULL,
    topics_id uuid NOT NULL,
    id bigint NOT NULL
);
COMMENT ON TABLE kgraph.topics_labels IS 'labels set for each topic';
CREATE SEQUENCE kgraph.topics_labels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE kgraph.topics_labels_id_seq OWNED BY kgraph.topics_labels.id;
CREATE TABLE kgraph.users (
    username text NOT NULL,
    display_name text,
    email character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    password_hash character varying NOT NULL,
    active boolean DEFAULT true NOT NULL,
    data json
);
COMMENT ON TABLE kgraph.users IS 'users table';
CREATE TABLE kgraph.users_roles (
    id integer NOT NULL,
    users_username text NOT NULL,
    roles_id integer NOT NULL
);
COMMENT ON TABLE kgraph.users_roles IS 'roles assigned to users';
CREATE SEQUENCE kgraph.users_roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE kgraph.users_roles_id_seq OWNED BY kgraph.users_roles.id;
ALTER TABLE ONLY kgraph.labels ALTER COLUMN id SET DEFAULT nextval('kgraph.labels_id_seq'::regclass);
ALTER TABLE ONLY kgraph.roles ALTER COLUMN id SET DEFAULT nextval('kgraph.roles_id_seq'::regclass);
ALTER TABLE ONLY kgraph.topics_labels ALTER COLUMN id SET DEFAULT nextval('kgraph.topics_labels_id_seq'::regclass);
ALTER TABLE ONLY kgraph.users_roles ALTER COLUMN id SET DEFAULT nextval('kgraph.users_roles_id_seq'::regclass);
ALTER TABLE ONLY kgraph.labels
    ADD CONSTRAINT labels_pkey PRIMARY KEY (id);
ALTER TABLE ONLY kgraph.labels
    ADD CONSTRAINT labels_users_username_title_key UNIQUE (users_username, title);
ALTER TABLE ONLY kgraph.roles
    ADD CONSTRAINT roles_id_key UNIQUE (id);
ALTER TABLE ONLY kgraph.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);
ALTER TABLE ONLY kgraph.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);
ALTER TABLE ONLY kgraph.topics_labels
    ADD CONSTRAINT topics_labels_pkey PRIMARY KEY (id);
ALTER TABLE ONLY kgraph.topics_labels
    ADD CONSTRAINT topics_labels_topics_id_key UNIQUE (topics_id);
ALTER TABLE ONLY kgraph.topics
    ADD CONSTRAINT topics_name_users_username_key UNIQUE (name, users_username);
ALTER TABLE ONLY kgraph.topics
    ADD CONSTRAINT topics_pkey PRIMARY KEY (id);
ALTER TABLE ONLY kgraph.users
    ADD CONSTRAINT users_email_key UNIQUE (email);
ALTER TABLE ONLY kgraph.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (username);
ALTER TABLE ONLY kgraph.users_roles
    ADD CONSTRAINT users_roles_pkey PRIMARY KEY (id);
ALTER TABLE ONLY kgraph.users_roles
    ADD CONSTRAINT users_roles_users_username_roles_id_key UNIQUE (users_username, roles_id);
ALTER TABLE ONLY kgraph.users
    ADD CONSTRAINT users_username_key UNIQUE (username);
CREATE TRIGGER set_kgraph_labels_updated_at BEFORE UPDATE ON kgraph.labels FOR EACH ROW EXECUTE FUNCTION kgraph.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_kgraph_labels_updated_at ON kgraph.labels IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_kgraph_topics_updated_at BEFORE UPDATE ON kgraph.topics FOR EACH ROW EXECUTE FUNCTION kgraph.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_kgraph_topics_updated_at ON kgraph.topics IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_kgraph_users_updated_at BEFORE UPDATE ON kgraph.users FOR EACH ROW EXECUTE FUNCTION kgraph.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_kgraph_users_updated_at ON kgraph.users IS 'trigger to set value of column "updated_at" to current timestamp on row update';
ALTER TABLE ONLY kgraph.labels
    ADD CONSTRAINT labels_users_username_fkey FOREIGN KEY (users_username) REFERENCES kgraph.users(username) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY kgraph.topics_labels
    ADD CONSTRAINT topics_labels_labels_id_fkey FOREIGN KEY (labels_id) REFERENCES kgraph.labels(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY kgraph.topics_labels
    ADD CONSTRAINT topics_labels_topics_id_fkey FOREIGN KEY (topics_id) REFERENCES kgraph.topics(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY kgraph.topics
    ADD CONSTRAINT topics_users_username_fkey FOREIGN KEY (users_username) REFERENCES kgraph.users(username) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY kgraph.users_roles
    ADD CONSTRAINT users_roles_roles_id_fkey FOREIGN KEY (roles_id) REFERENCES kgraph.roles(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY kgraph.users_roles
    ADD CONSTRAINT users_roles_users_username_fkey FOREIGN KEY (users_username) REFERENCES kgraph.users(username) ON UPDATE CASCADE ON DELETE CASCADE;
--
-- PostgreSQL database dump
--

-- Dumped from database version 12.6 (Debian 12.6-1.pgdg100+1)
-- Dumped by pg_dump version 12.6 (Debian 12.6-1.pgdg100+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: users; Type: TABLE DATA; Schema: kgraph; Owner: postgres
--



--
-- Data for Name: labels; Type: TABLE DATA; Schema: kgraph; Owner: postgres
--



--
-- Data for Name: roles; Type: TABLE DATA; Schema: kgraph; Owner: postgres
--

INSERT INTO kgraph.roles (id, name, description, "default", admin) VALUES (3, 'anonymous', NULL, false, false);
INSERT INTO kgraph.roles (id, name, description, "default", admin) VALUES (2, 'registred_user', NULL, true, false);
INSERT INTO kgraph.roles (id, name, description, "default", admin) VALUES (1, 'admin', NULL, false, true);


--
-- Data for Name: topics; Type: TABLE DATA; Schema: kgraph; Owner: postgres
--



--
-- Data for Name: topics_labels; Type: TABLE DATA; Schema: kgraph; Owner: postgres
--



--
-- Data for Name: users_roles; Type: TABLE DATA; Schema: kgraph; Owner: postgres
--



--
-- Name: labels_id_seq; Type: SEQUENCE SET; Schema: kgraph; Owner: postgres
--

SELECT pg_catalog.setval('kgraph.labels_id_seq', 1, false);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: kgraph; Owner: postgres
--

SELECT pg_catalog.setval('kgraph.roles_id_seq', 3, true);


--
-- Name: topics_labels_id_seq; Type: SEQUENCE SET; Schema: kgraph; Owner: postgres
--

SELECT pg_catalog.setval('kgraph.topics_labels_id_seq', 1, false);


--
-- Name: users_roles_id_seq; Type: SEQUENCE SET; Schema: kgraph; Owner: postgres
--

SELECT pg_catalog.setval('kgraph.users_roles_id_seq', 1, false);


--
-- PostgreSQL database dump complete
--

