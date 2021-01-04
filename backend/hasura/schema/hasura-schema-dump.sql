--
-- PostgreSQL database dump
--

-- Dumped from database version 12.5 (Debian 12.5-1.pgdg100+1)
-- Dumped by pg_dump version 12.5 (Debian 12.5-1.pgdg100+1)

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
-- Name: topics; Type: TABLE; Schema: kgraph; Owner: postgres
--

CREATE TABLE kgraph.topics (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    users_username text NOT NULL,
    name text NOT NULL,
    content text,
    tags text,
    public boolean DEFAULT false NOT NULL,
    parent_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE kgraph.topics OWNER TO postgres;

--
-- Name: TABLE topics; Type: COMMENT; Schema: kgraph; Owner: postgres
--

COMMENT ON TABLE kgraph.topics IS 'topics table';


--
-- Name: users; Type: TABLE; Schema: kgraph; Owner: postgres
--

CREATE TABLE kgraph.users (
    username text NOT NULL,
    display_name text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE kgraph.users OWNER TO postgres;

--
-- Name: TABLE users; Type: COMMENT; Schema: kgraph; Owner: postgres
--

COMMENT ON TABLE kgraph.users IS 'users table';


--
-- Name: topics topics_pkey; Type: CONSTRAINT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.topics
    ADD CONSTRAINT topics_pkey PRIMARY KEY (users_username, name);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (username);


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
-- Name: topics topics_users_username_fkey; Type: FK CONSTRAINT; Schema: kgraph; Owner: postgres
--

ALTER TABLE ONLY kgraph.topics
    ADD CONSTRAINT topics_users_username_fkey FOREIGN KEY (users_username) REFERENCES kgraph.users(username) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

