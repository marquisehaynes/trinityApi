--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

-- Started on 2025-01-05 01:53:17

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
-- TOC entry 233 (class 1255 OID 16709)
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
-- TOC entry 217 (class 1259 OID 16710)
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
-- TOC entry 218 (class 1259 OID 16715)
-- Name: assignment; Type: TABLE; Schema: public; Owner: dbsvradmin
--

CREATE TABLE public.assignment (
    canvasid text NOT NULL,
    groupid text,
    courseid text NOT NULL,
    name text NOT NULL,
    pointspossible numeric NOT NULL,
    id text
);


ALTER TABLE public.assignment OWNER TO dbsvradmin;

--
-- TOC entry 219 (class 1259 OID 16720)
-- Name: assignmentgroup; Type: TABLE; Schema: public; Owner: dbsvradmin
--

CREATE TABLE public.assignmentgroup (
    canvasid text NOT NULL,
    courseid text NOT NULL,
    name text NOT NULL,
    weight numeric NOT NULL,
    id text
);


ALTER TABLE public.assignmentgroup OWNER TO dbsvradmin;

--
-- TOC entry 220 (class 1259 OID 16725)
-- Name: assignmentsubmission; Type: TABLE; Schema: public; Owner: dbsvradmin
--

CREATE TABLE public.assignmentsubmission (
    canvasid text NOT NULL,
    coursestudentid text NOT NULL,
    assignmentid text NOT NULL,
    studentid text NOT NULL,
    score numeric NOT NULL,
    attemptnumber numeric NOT NULL,
    id text
);


ALTER TABLE public.assignmentsubmission OWNER TO dbsvradmin;

--
-- TOC entry 221 (class 1259 OID 16730)
-- Name: course; Type: TABLE; Schema: public; Owner: dbsvradmin
--

CREATE TABLE public.course (
    canvasid text NOT NULL,
    coursename text NOT NULL,
    coursedescription text NOT NULL,
    startdate date NOT NULL,
    enddate date NOT NULL,
    id text
);


ALTER TABLE public.course OWNER TO dbsvradmin;

--
-- TOC entry 222 (class 1259 OID 16735)
-- Name: coursestudent; Type: TABLE; Schema: public; Owner: dbsvradmin
--

CREATE TABLE public.coursestudent (
    uniqueid text NOT NULL,
    courseid text NOT NULL,
    studentid text NOT NULL,
    id text
);


ALTER TABLE public.coursestudent OWNER TO dbsvradmin;

--
-- TOC entry 223 (class 1259 OID 16740)
-- Name: objectprefixes; Type: TABLE; Schema: public; Owner: dbsvradmin
--

CREATE TABLE public.objectprefixes (
    object text NOT NULL,
    prefix text NOT NULL
);


ALTER TABLE public.objectprefixes OWNER TO dbsvradmin;

--
-- TOC entry 224 (class 1259 OID 16745)
-- Name: persona; Type: TABLE; Schema: public; Owner: dbsvradmin
--

CREATE TABLE public.persona (
    id text NOT NULL,
    name text,
    "isAdminType" boolean
);


ALTER TABLE public.persona OWNER TO dbsvradmin;

--
-- TOC entry 225 (class 1259 OID 16750)
-- Name: personapermission; Type: TABLE; Schema: public; Owner: dbsvradmin
--

CREATE TABLE public.personapermission (
    id text NOT NULL,
    personaid text NOT NULL,
    permissionname text
);


ALTER TABLE public.personapermission OWNER TO dbsvradmin;

--
-- TOC entry 226 (class 1259 OID 16755)
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
    id integer NOT NULL,
    failuremessage text
);


ALTER TABLE public.processqueue OWNER TO dbsvradmin;

--
-- TOC entry 227 (class 1259 OID 16760)
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
-- TOC entry 4896 (class 0 OID 0)
-- Dependencies: 227
-- Name: processqueue_processid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dbsvradmin
--

ALTER SEQUENCE public.processqueue_processid_seq OWNED BY public.processqueue.id;


--
-- TOC entry 228 (class 1259 OID 16761)
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
-- TOC entry 229 (class 1259 OID 16766)
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
-- TOC entry 230 (class 1259 OID 16772)
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
-- TOC entry 4898 (class 0 OID 0)
-- Dependencies: 230
-- Name: rowindex_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dbsvradmin
--

ALTER SEQUENCE public.rowindex_id_seq OWNED BY public.rowindex.id;


--
-- TOC entry 231 (class 1259 OID 16773)
-- Name: student; Type: TABLE; Schema: public; Owner: dbsvradmin
--

CREATE TABLE public.student (
    canvasid text NOT NULL,
    fullname text NOT NULL,
    sortablename text NOT NULL,
    id text
);


ALTER TABLE public.student OWNER TO dbsvradmin;

--
-- TOC entry 232 (class 1259 OID 16778)
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
-- TOC entry 4695 (class 2604 OID 16783)
-- Name: processqueue id; Type: DEFAULT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.processqueue ALTER COLUMN id SET DEFAULT nextval('public.processqueue_processid_seq'::regclass);


--
-- TOC entry 4696 (class 2604 OID 16784)
-- Name: rowindex id; Type: DEFAULT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.rowindex ALTER COLUMN id SET DEFAULT nextval('public.rowindex_id_seq'::regclass);


--
-- TOC entry 4699 (class 2606 OID 16786)
-- Name: accesslog accesslog_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.accesslog
    ADD CONSTRAINT accesslog_pkey PRIMARY KEY (id);


--
-- TOC entry 4701 (class 2606 OID 16788)
-- Name: assignment assignment_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.assignment
    ADD CONSTRAINT assignment_pkey PRIMARY KEY (canvasid);


--
-- TOC entry 4703 (class 2606 OID 16790)
-- Name: assignmentgroup assignmentgroup_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.assignmentgroup
    ADD CONSTRAINT assignmentgroup_pkey PRIMARY KEY (canvasid);


--
-- TOC entry 4705 (class 2606 OID 16792)
-- Name: assignmentsubmission assignmentsubmission_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.assignmentsubmission
    ADD CONSTRAINT assignmentsubmission_pkey PRIMARY KEY (canvasid);


--
-- TOC entry 4707 (class 2606 OID 16794)
-- Name: course course_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_pkey PRIMARY KEY (canvasid);


--
-- TOC entry 4727 (class 2606 OID 16796)
-- Name: student coursestudent_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT coursestudent_pkey PRIMARY KEY (canvasid);


--
-- TOC entry 4709 (class 2606 OID 16798)
-- Name: coursestudent coursestudent_pkey1; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.coursestudent
    ADD CONSTRAINT coursestudent_pkey1 PRIMARY KEY (uniqueid);


--
-- TOC entry 4711 (class 2606 OID 16800)
-- Name: objectprefixes objectprefixes_object_key; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.objectprefixes
    ADD CONSTRAINT objectprefixes_object_key UNIQUE (object);


--
-- TOC entry 4713 (class 2606 OID 16802)
-- Name: objectprefixes objectprefixes_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.objectprefixes
    ADD CONSTRAINT objectprefixes_pkey PRIMARY KEY (object);


--
-- TOC entry 4715 (class 2606 OID 16804)
-- Name: persona persona_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.persona
    ADD CONSTRAINT persona_pkey PRIMARY KEY (id);


--
-- TOC entry 4717 (class 2606 OID 16806)
-- Name: personapermission personapermission_personaid_key; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.personapermission
    ADD CONSTRAINT personapermission_personaid_key UNIQUE (personaid);


--
-- TOC entry 4719 (class 2606 OID 16808)
-- Name: personapermission personapermission_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.personapermission
    ADD CONSTRAINT personapermission_pkey PRIMARY KEY (id);


--
-- TOC entry 4721 (class 2606 OID 16810)
-- Name: processqueue processqueue_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.processqueue
    ADD CONSTRAINT processqueue_pkey PRIMARY KEY (id);


--
-- TOC entry 4723 (class 2606 OID 16812)
-- Name: recyclebin recyclebin_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.recyclebin
    ADD CONSTRAINT recyclebin_pkey PRIMARY KEY (id);


--
-- TOC entry 4725 (class 2606 OID 16814)
-- Name: rowindex rowindex_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.rowindex
    ADD CONSTRAINT rowindex_pkey PRIMARY KEY (id);


--
-- TOC entry 4729 (class 2606 OID 16816)
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- TOC entry 4730 (class 2606 OID 16817)
-- Name: assignment assignment_courseid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.assignment
    ADD CONSTRAINT assignment_courseid_fkey FOREIGN KEY (courseid) REFERENCES public.course(canvasid);


--
-- TOC entry 4731 (class 2606 OID 16822)
-- Name: assignment assignment_groupid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.assignment
    ADD CONSTRAINT assignment_groupid_fkey FOREIGN KEY (groupid) REFERENCES public.assignmentgroup(canvasid);


--
-- TOC entry 4732 (class 2606 OID 16827)
-- Name: assignmentgroup assignmentgroup_courseid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.assignmentgroup
    ADD CONSTRAINT assignmentgroup_courseid_fkey FOREIGN KEY (courseid) REFERENCES public.course(canvasid);


--
-- TOC entry 4733 (class 2606 OID 16832)
-- Name: assignmentsubmission assignmentsubmission_assignmentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.assignmentsubmission
    ADD CONSTRAINT assignmentsubmission_assignmentid_fkey FOREIGN KEY (assignmentid) REFERENCES public.assignment(canvasid);


--
-- TOC entry 4734 (class 2606 OID 16837)
-- Name: assignmentsubmission assignmentsubmission_coursestudentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.assignmentsubmission
    ADD CONSTRAINT assignmentsubmission_coursestudentid_fkey FOREIGN KEY (coursestudentid) REFERENCES public.coursestudent(uniqueid);


--
-- TOC entry 4735 (class 2606 OID 16842)
-- Name: assignmentsubmission assignmentsubmission_studentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.assignmentsubmission
    ADD CONSTRAINT assignmentsubmission_studentid_fkey FOREIGN KEY (studentid) REFERENCES public.student(canvasid);


--
-- TOC entry 4736 (class 2606 OID 16847)
-- Name: coursestudent coursestudent_courseid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.coursestudent
    ADD CONSTRAINT coursestudent_courseid_fkey FOREIGN KEY (courseid) REFERENCES public.course(canvasid);


--
-- TOC entry 4737 (class 2606 OID 16852)
-- Name: coursestudent coursestudent_studentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dbsvradmin
--

ALTER TABLE ONLY public.coursestudent
    ADD CONSTRAINT coursestudent_studentid_fkey FOREIGN KEY (studentid) REFERENCES public.student(canvasid);


--
-- TOC entry 4888 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE assignment; Type: ACL; Schema: public; Owner: dbsvradmin
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.assignment TO nexus;


--
-- TOC entry 4889 (class 0 OID 0)
-- Dependencies: 219
-- Name: TABLE assignmentgroup; Type: ACL; Schema: public; Owner: dbsvradmin
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.assignmentgroup TO nexus;


--
-- TOC entry 4890 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE assignmentsubmission; Type: ACL; Schema: public; Owner: dbsvradmin
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.assignmentsubmission TO nexus;


--
-- TOC entry 4891 (class 0 OID 0)
-- Dependencies: 221
-- Name: TABLE course; Type: ACL; Schema: public; Owner: dbsvradmin
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.course TO nexus;


--
-- TOC entry 4892 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE coursestudent; Type: ACL; Schema: public; Owner: dbsvradmin
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.coursestudent TO nexus;


--
-- TOC entry 4893 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE persona; Type: ACL; Schema: public; Owner: dbsvradmin
--

GRANT SELECT,REFERENCES ON TABLE public.persona TO nexus;


--
-- TOC entry 4894 (class 0 OID 0)
-- Dependencies: 225
-- Name: TABLE personapermission; Type: ACL; Schema: public; Owner: dbsvradmin
--

GRANT SELECT,REFERENCES ON TABLE public.personapermission TO nexus;


--
-- TOC entry 4895 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE processqueue; Type: ACL; Schema: public; Owner: dbsvradmin
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.processqueue TO nexus;


--
-- TOC entry 4897 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE recyclebin; Type: ACL; Schema: public; Owner: dbsvradmin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,UPDATE ON TABLE public.recyclebin TO nexus;


--
-- TOC entry 4899 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE student; Type: ACL; Schema: public; Owner: dbsvradmin
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.student TO nexus;


--
-- TOC entry 4900 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE "user"; Type: ACL; Schema: public; Owner: dbsvradmin
--

GRANT SELECT,REFERENCES ON TABLE public."user" TO nexus;


-- Completed on 2025-01-05 01:53:17

--
-- PostgreSQL database dump complete
--

