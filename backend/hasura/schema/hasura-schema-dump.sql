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
-- Name: kgraph; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA kgraph;


ALTER SCHEMA kgraph OWNER TO postgres;

--
-- Name: set_current_timestamp_updated_at(); Type: FUNCTION; Schema: kgraph; Owner: postgres
--

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


ALTER FUNCTION kgraph.set_current_timestamp_updated_at() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: labels; Type: TABLE; Schema: kgraph; Owner: postgres
--

CREATE TABLE kgraph.labels (
    id integer NOT NULL,
    title text NOT NULL,
    description text,
    users_username text NOT NULL,
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE kgraph.labels OWNER TO postgres;

--
-- Name: TABLE labels; Type: COMMENT; Schema: kgraph; Owner: postgres
--

COMMENT ON TABLE kgraph.labels IS 'user labels';


--
-- Name: labels_id_seq; Type: SEQUENCE; Schema: kgraph; Owner: postgres
--

CREATE SEQUENCE kgraph.labels_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE kgraph.labels_id_seq OWNER TO postgres;

--
-- Name: labels_id_seq; Type: SEQUENCE OWNED BY; Schema: kgraph; Owner: postgres
--

ALTER SEQUENCE kgraph.labels_id_seq OWNED BY kgraph.labels.id;


--
-- Name: roles; Type: TABLE; Schema: kgraph; Owner: postgres
--

CREATE TABLE kgraph.roles (
    id integer NOT NULL,
    name text NOT NULL,
    description text,
    "default" boolean DEFAULT false NOT NULL,
    admin boolean DEFAULT false NOT NULL
);


ALTER TABLE kgraph.roles OWNER TO postgres;

--
-- Name: TABLE roles; Type: COMMENT; Schema: kgraph; Owner: postgres
--

COMMENT ON TABLE kgraph.roles IS 'users roles';


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: kgraph; Owner: postgres
--

CREATE SEQUENCE kgraph.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE kgraph.roles_id_seq OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: kgraph; Owner: postgres
--

ALTER SEQUENCE kgraph.roles_id_seq OWNED BY kgraph.roles.id;


--
-- Name: topics; Type: TABLE; Schema: kgraph; Owner: postgres
--

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


ALTER TABLE kgraph.topics OWNER TO postgres;

--
-- Name: TABLE topics; Type: COMMENT; Schema: kgraph; Owner: postgres
--

COMMENT ON TABLE kgraph.topics IS 'topics table';


--
-- Name: topics_labels; Type: TABLE; Schema: kgraph; Owner: postgres
--

CREATE TABLE kgraph.topics_labels (
    labels_id integer NOT NULL,
    topics_id uuid NOT NULL,
    id bigint NOT NULL
);


ALTER TABLE kgraph.topics_labels OWNER TO postgres;

--
-- Name: TABLE topics_labels; Type: COMMENT; Schema: kgraph; Owner: postgres
--

COMMENT ON TABLE kgraph.topics_labels IS 'labels set for each topic';


--
-- Name: topics_labels_id_seq; Type: SEQUENCE; Schema: kgraph; Owner: postgres
--

CREATE SEQUENCE kgraph.topics_labels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE kgraph.topics_labels_id_seq OWNER TO postgres;

--
-- Name: topics_labels_id_seq; Type: SEQUENCE OWNED BY; Schema: kgraph; Owner: postgres
--

ALTER SEQUENCE kgraph.topics_labels_id_seq OWNED BY kgraph.topics_labels.id;


--
-- Name: users; Type: TABLE; Schema: kgraph; Owner: postgres
--

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


ALTER TABLE kgraph.users OWNER TO postgres;

--
-- Name: TABLE users; Type: COMMENT; Schema: kgraph; Owner: postgres
--

COMMENT ON TABLE kgraph.users IS 'users table';


--
-- Name: users_roles; Type: TABLE; Schema: kgraph; Owner: postgres
--

CREATE TABLE kgraph.users_roles (
    id integer NOT NULL,
    users_username text NOT NULL,
    roles_id integer NOT NULL
);


ALTER TABLE kgraph.users_roles OWNER TO postgres;

--
-- Name: TABLE users_roles; Type: COMMENT; Schema: kgraph; Owner: postgres
--

COMMENT ON TABLE kgraph.users_roles IS 'roles assigned to users';


--
-- Name: users_roles_id_seq; Type: SEQUENCE; Schema: kgraph; Owner: postgres
--

CREATE SEQUENCE kgraph.users_roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE kgraph.users_roles_id_seq OWNER TO postgres;

--
-- Name: users_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: kgraph; Owner: postgres
--

ALTER SEQUENCE kgraph.users_roles_id_seq OWNED BY kgraph.users_roles.id;


--
-- Name: labels id; Type: DEFAULT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.labels ALTER COLUMN id SET DEFAULT nextval('kgraph.labels_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.roles ALTER COLUMN id SET DEFAULT nextval('kgraph.roles_id_seq'::regclass);


--
-- Name: topics_labels id; Type: DEFAULT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.topics_labels ALTER COLUMN id SET DEFAULT nextval('kgraph.topics_labels_id_seq'::regclass);


--
-- Name: users_roles id; Type: DEFAULT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.users_roles ALTER COLUMN id SET DEFAULT nextval('kgraph.users_roles_id_seq'::regclass);


--
-- Name: labels labels_pkey; Type: CONSTRAINT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.labels
    ADD CONSTRAINT labels_pkey PRIMARY KEY (id);


--
-- Name: labels labels_users_username_title_key; Type: CONSTRAINT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.labels
    ADD CONSTRAINT labels_users_username_title_key UNIQUE (users_username, title);


--
-- Name: roles roles_id_key; Type: CONSTRAINT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.roles
    ADD CONSTRAINT roles_id_key UNIQUE (id);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: topics_labels topics_labels_pkey; Type: CONSTRAINT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.topics_labels
    ADD CONSTRAINT topics_labels_pkey PRIMARY KEY (id);


--
-- Name: topics_labels topics_labels_topics_id_key; Type: CONSTRAINT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.topics_labels
    ADD CONSTRAINT topics_labels_topics_id_key UNIQUE (topics_id);


--
-- Name: topics topics_name_users_username_key; Type: CONSTRAINT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.topics
    ADD CONSTRAINT topics_name_users_username_key UNIQUE (name, users_username);


--
-- Name: topics topics_pkey; Type: CONSTRAINT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.topics
    ADD CONSTRAINT topics_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (username);


--
-- Name: users_roles users_roles_pkey; Type: CONSTRAINT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.users_roles
    ADD CONSTRAINT users_roles_pkey PRIMARY KEY (id);


--
-- Name: users_roles users_roles_users_username_roles_id_key; Type: CONSTRAINT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.users_roles
    ADD CONSTRAINT users_roles_users_username_roles_id_key UNIQUE (users_username, roles_id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: labels set_kgraph_labels_updated_at; Type: TRIGGER; Schema: kgraph; Owner: postgres
--

CREATE TRIGGER set_kgraph_labels_updated_at BEFORE UPDATE ON kgraph.labels FOR EACH ROW EXECUTE FUNCTION kgraph.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_kgraph_labels_updated_at ON labels; Type: COMMENT; Schema: kgraph; Owner: postgres
--

COMMENT ON TRIGGER set_kgraph_labels_updated_at ON kgraph.labels IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: topics set_kgraph_topics_updated_at; Type: TRIGGER; Schema: kgraph; Owner: postgres
--

CREATE TRIGGER set_kgraph_topics_updated_at BEFORE UPDATE ON kgraph.topics FOR EACH ROW EXECUTE FUNCTION kgraph.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_kgraph_topics_updated_at ON topics; Type: COMMENT; Schema: kgraph; Owner: postgres
--

COMMENT ON TRIGGER set_kgraph_topics_updated_at ON kgraph.topics IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: users set_kgraph_users_updated_at; Type: TRIGGER; Schema: kgraph; Owner: postgres
--

CREATE TRIGGER set_kgraph_users_updated_at BEFORE UPDATE ON kgraph.users FOR EACH ROW EXECUTE FUNCTION kgraph.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_kgraph_users_updated_at ON users; Type: COMMENT; Schema: kgraph; Owner: postgres
--

COMMENT ON TRIGGER set_kgraph_users_updated_at ON kgraph.users IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: labels labels_users_username_fkey; Type: FK CONSTRAINT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.labels
    ADD CONSTRAINT labels_users_username_fkey FOREIGN KEY (users_username) REFERENCES kgraph.users(username) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: topics_labels topics_labels_labels_id_fkey; Type: FK CONSTRAINT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.topics_labels
    ADD CONSTRAINT topics_labels_labels_id_fkey FOREIGN KEY (labels_id) REFERENCES kgraph.labels(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: topics_labels topics_labels_topics_id_fkey; Type: FK CONSTRAINT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.topics_labels
    ADD CONSTRAINT topics_labels_topics_id_fkey FOREIGN KEY (topics_id) REFERENCES kgraph.topics(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: topics topics_users_username_fkey; Type: FK CONSTRAINT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.topics
    ADD CONSTRAINT topics_users_username_fkey FOREIGN KEY (users_username) REFERENCES kgraph.users(username) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users_roles users_roles_roles_id_fkey; Type: FK CONSTRAINT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.users_roles
    ADD CONSTRAINT users_roles_roles_id_fkey FOREIGN KEY (roles_id) REFERENCES kgraph.roles(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users_roles users_roles_users_username_fkey; Type: FK CONSTRAINT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.users_roles
    ADD CONSTRAINT users_roles_users_username_fkey FOREIGN KEY (users_username) REFERENCES kgraph.users(username) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

