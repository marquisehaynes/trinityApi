--
-- PostgreSQL database dump
--

-- Dumped from database version 16.6 (Ubuntu 16.6-0ubuntu0.24.10.1)
-- Dumped by pg_dump version 16.6 (Ubuntu 16.6-0ubuntu0.24.10.1)

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
-- Name: log_insert(); Type: FUNCTION; Schema: public; Owner: dbsvradmin
--

CREATE FUNCTION public.log_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Insert the ID and table name into rowindex
    INSERT INTO rowindex (object, objectid)
    VALUES (TG_TABLE_NAME, NEW.id);

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.log_insert() OWNER TO dbsvradmin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accesslog; Type: TABLE; Schema: public; Owner: dbsvradmin
--

CREATE TABLE public.accesslog (
    id text NOT NULL,
    userid text NOT NULL,
    createddate timestamp with time zone NOT NULL,
    recordid text NOT NULL
);


ALTER TABLE public.accesslog OWNER TO dbsvradmin;

--
-- Name: assignment; Type: TABLE; Schema: public; Owner: dbsvradmin
--

CREATE TABLE public.assignment (
    canvasid text NOT NULL,
    groupid text,
    courseid text NOT NULL,
    name text NOT NULL,
    pointspossible numeric NOT NULL
);


ALTER TABLE public.assignment OWNER TO dbsvradmin;

--
-- Name: assignmentgroup; Type: TABLE; Schema: public; Owner: dbsvradmin
--

CREATE TABLE public.assignmentgroup (
    canvasid text NOT NULL,
    courseid text NOT NULL,
    name text NOT NULL,
    weight numeric NOT NULL
);


ALTER TABLE public.assignmentgroup OWNER TO dbsvradmin;

--
-- Name: assignmentsubmission; Type: TABLE; Schema: public; Owner: dbsvradmin
--

CREATE TABLE public.assignmentsubmission (
    canvasid text NOT NULL,
    coursestudentid text NOT NULL,
    assignmentid text NOT NULL,
    studentid text NOT NULL,
    score numeric NOT NULL,
    attemptnumber numeric NOT NULL
);


ALTER TABLE public.assignmentsubmission OWNER TO dbsvradmin;

--
-- Name: course; Type: TABLE; Schema: public; Owner: dbsvradmin
--

CREATE TABLE public.course (
    canvasid text NOT NULL,
    coursename text NOT NULL,
    coursedescription text NOT NULL,
    startdate date NOT NULL,
    enddate date NOT NULL
);


ALTER TABLE public.course OWNER TO dbsvradmin;

--
-- Name: coursestudent; Type: TABLE; Schema: public; Owner: dbsvradmin
--

CREATE TABLE public.coursestudent (
    uniqueid text NOT NULL,
    courseid text NOT NULL,
    studentid text NOT NULL
);


ALTER TABLE public.coursestudent OWNER TO dbsvradmin;

--
-- Name: objectprefixes; Type: TABLE; Schema: public; Owner: dbsvradmin
--

CREATE TABLE public.objectprefixes (
    object text NOT NULL,
    prefix text NOT NULL
);


ALTER TABLE public.objectprefixes OWNER TO dbsvradmin;

--
-- Name: persona; Type: TABLE; Schema: public; Owner: dbsvradmin
--

CREATE TABLE public.persona (
    id text NOT NULL,
    name text,
    "isAdminType" boolean
);


ALTER TABLE public.persona OWNER TO dbsvradmin;

--
-- Name: personapermission; Type: TABLE; Schema: public; Owner: dbsvradmin
--

CREATE TABLE public.personapermission (
    id text NOT NULL,
    personaid text NOT NULL
);


ALTER TABLE public.personapermission OWNER TO dbsvradmin;

--
-- Name: processqueue; Type: TABLE; Schema: public; Owner: dbsvradmin
--

CREATE TABLE public.processqueue (
    processname text NOT NULL,
    processstatus text NOT NULL,
    processstarttime timestamp with time zone NOT NULL,
    processendtime timestamp with time zone,
    targetobject text NOT NULL,
    totalbatches numeric NOT NULL,
    failedbatches numeric NOT NULL,
    processid integer NOT NULL,
    failuremessage text
);


ALTER TABLE public.processqueue OWNER TO dbsvradmin;

--
-- Name: processqueue_processid_seq; Type: SEQUENCE; Schema: public; Owner: dbsvradmin
--

CREATE SEQUENCE public.processqueue_processid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.processqueue_processid_seq OWNER TO dbsvradmin;

--
-- Name: processqueue_processid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dbsvradmin
--

ALTER SEQUENCE public.processqueue_processid_seq OWNED BY public.processqueue.processid;


--
-- Name: recyclebin; Type: TABLE; Schema: public; Owner: dbsvradmin
--

CREATE TABLE public.recyclebin (
    id text NOT NULL,
    originalrowid text NOT NULL,
    originalobject text NOT NULL,
    deleteddate text NOT NULL,
    deletedbyid text NOT NULL
);


ALTER TABLE public.recyclebin OWNER TO dbsvradmin;

--
-- Name: rowindex; Type: TABLE; Schema: public; Owner: dbsvradmin
--

CREATE TABLE public.rowindex (
    id integer NOT NULL,
    object text NOT NULL,
    objectid text NOT NULL,
    log_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.rowindex OWNER TO dbsvradmin;

--
-- Name: rowindex_id_seq; Type: SEQUENCE; Schema: public; Owner: dbsvradmin
--

CREATE SEQUENCE public.rowindex_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rowindex_id_seq OWNER TO dbsvradmin;

--
-- Name: rowindex_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dbsvradmin
--

ALTER SEQUENCE public.rowindex_id_seq OWNED BY public.rowindex.id;


--
-- Name: student; Type: TABLE; Schema: public; Owner: dbsvradmin
--

CREATE TABLE public.student (
    canvasid text NOT NULL,
    fullname text NOT NULL,
    sortablename text NOT NULL
);


ALTER TABLE public.student OWNER TO dbsvradmin;

--
-- Name: user; Type: TABLE; Schema: public; Owner: dbsvradmin
--

CREATE TABLE public."user" (
    firstname text NOT NULL,
    lastname text NOT NULL,
    email text NOT NULL,
    phone numeric,
    linkedin text,
    id text NOT NULL,
    studentid text,
    personaid text NOT NULL
);


ALTER TABLE public."user" OWNER TO dbsvradmin;

--
-- Name: processqueue processid; Type: DEFAULT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.processqueue ALTER COLUMN processid SET DEFAULT nextval('public.processqueue_processid_seq'::regclass);


--
-- Name: rowindex id; Type: DEFAULT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.rowindex ALTER COLUMN id SET DEFAULT nextval('public.rowindex_id_seq'::regclass);


--
-- Name: accesslog accesslog_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.accesslog
    ADD CONSTRAINT accesslog_pkey PRIMARY KEY (id);


--
-- Name: assignment assignment_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.assignment
    ADD CONSTRAINT assignment_pkey PRIMARY KEY (canvasid);


--
-- Name: assignmentgroup assignmentgroup_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.assignmentgroup
    ADD CONSTRAINT assignmentgroup_pkey PRIMARY KEY (canvasid);


--
-- Name: assignmentsubmission assignmentsubmission_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.assignmentsubmission
    ADD CONSTRAINT assignmentsubmission_pkey PRIMARY KEY (canvasid);


--
-- Name: course course_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_pkey PRIMARY KEY (canvasid);


--
-- Name: student coursestudent_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT coursestudent_pkey PRIMARY KEY (canvasid);


--
-- Name: coursestudent coursestudent_pkey1; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.coursestudent
    ADD CONSTRAINT coursestudent_pkey1 PRIMARY KEY (uniqueid);


--
-- Name: objectprefixes objectprefixes_object_key; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.objectprefixes
    ADD CONSTRAINT objectprefixes_object_key UNIQUE (object);


--
-- Name: objectprefixes objectprefixes_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.objectprefixes
    ADD CONSTRAINT objectprefixes_pkey PRIMARY KEY (object);


--
-- Name: persona persona_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.persona
    ADD CONSTRAINT persona_pkey PRIMARY KEY (id);


--
-- Name: personapermission personapermission_personaid_key; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.personapermission
    ADD CONSTRAINT personapermission_personaid_key UNIQUE (personaid);


--
-- Name: personapermission personapermission_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.personapermission
    ADD CONSTRAINT personapermission_pkey PRIMARY KEY (id);


--
-- Name: processqueue processqueue_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.processqueue
    ADD CONSTRAINT processqueue_pkey PRIMARY KEY (processid);


--
-- Name: recyclebin recyclebin_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.recyclebin
    ADD CONSTRAINT recyclebin_pkey PRIMARY KEY (id);


--
-- Name: rowindex rowindex_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.rowindex
    ADD CONSTRAINT rowindex_pkey PRIMARY KEY (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: assignment assignment_courseid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.assignment
    ADD CONSTRAINT assignment_courseid_fkey FOREIGN KEY (courseid) REFERENCES public.course(canvasid);


--
-- Name: assignment assignment_groupid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.assignment
    ADD CONSTRAINT assignment_groupid_fkey FOREIGN KEY (groupid) REFERENCES public.assignmentgroup(canvasid);


--
-- Name: assignmentgroup assignmentgroup_courseid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.assignmentgroup
    ADD CONSTRAINT assignmentgroup_courseid_fkey FOREIGN KEY (courseid) REFERENCES public.course(canvasid);


--
-- Name: assignmentsubmission assignmentsubmission_assignmentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.assignmentsubmission
    ADD CONSTRAINT assignmentsubmission_assignmentid_fkey FOREIGN KEY (assignmentid) REFERENCES public.assignment(canvasid);


--
-- Name: assignmentsubmission assignmentsubmission_coursestudentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.assignmentsubmission
    ADD CONSTRAINT assignmentsubmission_coursestudentid_fkey FOREIGN KEY (coursestudentid) REFERENCES public.coursestudent(uniqueid);


--
-- Name: assignmentsubmission assignmentsubmission_studentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.assignmentsubmission
    ADD CONSTRAINT assignmentsubmission_studentid_fkey FOREIGN KEY (studentid) REFERENCES public.student(canvasid);


--
-- Name: coursestudent coursestudent_courseid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.coursestudent
    ADD CONSTRAINT coursestudent_courseid_fkey FOREIGN KEY (courseid) REFERENCES public.course(canvasid);


--
-- Name: coursestudent coursestudent_studentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.coursestudent
    ADD CONSTRAINT coursestudent_studentid_fkey FOREIGN KEY (studentid) REFERENCES public.student(canvasid);


--
-- PostgreSQL database dump complete
--

