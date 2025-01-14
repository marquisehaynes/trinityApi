toc.dat                                                                                             0000600 0004000 0002000 00000047736 14737626254 0014500 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        PGDMP   7    7        	         }            studentdata    17.2 (Debian 17.2-1.pgdg120+1)    17.2 (Debian 17.2-1.pgdg120+1) <    }           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false         ~           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false                    0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false         �           1262    16384    studentdata    DATABASE     v   CREATE DATABASE studentdata WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';
    DROP DATABASE studentdata;
                     nexus    false         �            1255    16709    gen_id(text)    FUNCTION     �  CREATE FUNCTION public.gen_id(tablename text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_prefix text;
    v_nextval bigint;
    v_custom_id text;
BEGIN
    -- Get the prefix from objectprefixes table
    SELECT prefix INTO v_prefix
    FROM objectprefixes
    WHERE object = tablename
    LIMIT 1;

    -- If no prefix found, raise an error
    IF v_prefix IS NULL THEN
        RAISE EXCEPTION 'Prefix not found for table: %', tablename;
    END IF;

    -- Get the next value from the corresponding sequence
    EXECUTE format('SELECT nextval(''%I_serial'')', tablename) INTO v_nextval;

    -- Combine the prefix and the next sequence value
    v_custom_id := v_prefix || LPAD(v_nextval::text, 10, '0');

    -- Ensure the total length is exactly 13 characters
    IF length(v_custom_id) <> 13 THEN
        RAISE EXCEPTION 'Generated ID length is not 13 characters: %', v_custom_id;
    END IF;

    RETURN v_custom_id;
END;
$$;
 -   DROP FUNCTION public.gen_id(tablename text);
       public               nexus    false         �            1255    16389    generate_global_id()    FUNCTION     �  CREATE FUNCTION public.generate_global_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    pre CHAR(3);
    next_id BIGINT;
    padded_id CHAR(7);
BEGIN
    -- Get the prefix for the table
    SELECT prefix INTO pre FROM objectprefixes WHERE object = TG_TABLE_NAME;

    IF pre IS NULL THEN
        RAISE EXCEPTION 'Prefix not defined for table %', TG_TABLE_NAME;
    END IF;

    -- Generate the next serial number
    EXECUTE format('SELECT nextval(pg_get_serial_sequence(''%I'', ''id''))', TG_TABLE_NAME) INTO next_id;

    -- Pad the serial number to 7 characters
    padded_id := LPAD(next_id::TEXT, 7, '0');

    -- Set the new ID
    NEW.id := pre || padded_id;

    RETURN NEW;
END;
$$;
 +   DROP FUNCTION public.generate_global_id();
       public               postgres    false         �            1255    16390    log_insert()    FUNCTION     �   CREATE FUNCTION public.log_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Insert the ID and table name into rowindex
    INSERT INTO rowindex (object, objectid)
    VALUES (TG_TABLE_NAME, NEW.id);

    RETURN NEW;
END;
$$;
 #   DROP FUNCTION public.log_insert();
       public            
   dbsvradmin    false         �            1259    16546 	   accesslog    TABLE     �   CREATE TABLE public.accesslog (
    id text NOT NULL,
    userid text NOT NULL,
    createddate timestamp with time zone NOT NULL,
    recordid text NOT NULL
);
    DROP TABLE public.accesslog;
       public         heap r    
   dbsvradmin    false         �            1259    16551 
   assignment    TABLE     �   CREATE TABLE public.assignment (
    canvasid text NOT NULL,
    groupid text,
    courseid text NOT NULL,
    name text NOT NULL,
    pointspossible numeric NOT NULL,
    id text
);
    DROP TABLE public.assignment;
       public         heap r    
   dbsvradmin    false         �           0    0    TABLE assignment    ACL     @   GRANT SELECT,INSERT,UPDATE ON TABLE public.assignment TO nexus;
          public            
   dbsvradmin    false    218         �            1259    16556    assignmentgroup    TABLE     �   CREATE TABLE public.assignmentgroup (
    canvasid text NOT NULL,
    courseid text NOT NULL,
    name text NOT NULL,
    weight numeric NOT NULL,
    id text
);
 #   DROP TABLE public.assignmentgroup;
       public         heap r    
   dbsvradmin    false         �           0    0    TABLE assignmentgroup    ACL     E   GRANT SELECT,INSERT,UPDATE ON TABLE public.assignmentgroup TO nexus;
          public            
   dbsvradmin    false    219         �            1259    16561    assignmentsubmission    TABLE     �   CREATE TABLE public.assignmentsubmission (
    canvasid text NOT NULL,
    coursestudentid text NOT NULL,
    assignmentid text NOT NULL,
    studentid text NOT NULL,
    score numeric NOT NULL,
    attemptnumber numeric NOT NULL,
    id text
);
 (   DROP TABLE public.assignmentsubmission;
       public         heap r    
   dbsvradmin    false         �           0    0    TABLE assignmentsubmission    ACL     J   GRANT SELECT,INSERT,UPDATE ON TABLE public.assignmentsubmission TO nexus;
          public            
   dbsvradmin    false    220         �            1259    16566    course    TABLE     �   CREATE TABLE public.course (
    canvasid text NOT NULL,
    coursename text NOT NULL,
    coursedescription text NOT NULL,
    startdate date NOT NULL,
    enddate date NOT NULL,
    id text NOT NULL
);
    DROP TABLE public.course;
       public         heap r    
   dbsvradmin    false         �           0    0    TABLE course    ACL     <   GRANT SELECT,INSERT,UPDATE ON TABLE public.course TO nexus;
          public            
   dbsvradmin    false    221         �            1259    16571    coursestudent    TABLE     �   CREATE TABLE public.coursestudent (
    uniqueid text NOT NULL,
    courseid text NOT NULL,
    studentid text NOT NULL,
    id text
);
 !   DROP TABLE public.coursestudent;
       public         heap r    
   dbsvradmin    false         �           0    0    TABLE coursestudent    ACL     C   GRANT SELECT,INSERT,UPDATE ON TABLE public.coursestudent TO nexus;
          public            
   dbsvradmin    false    222         �            1259    16576    objectprefixes    TABLE     [   CREATE TABLE public.objectprefixes (
    object text NOT NULL,
    prefix text NOT NULL
);
 "   DROP TABLE public.objectprefixes;
       public         heap r    
   dbsvradmin    false         �           0    0    TABLE objectprefixes    ACL     7   GRANT SELECT ON TABLE public.objectprefixes TO PUBLIC;
          public            
   dbsvradmin    false    223         �            1259    16581    persona    TABLE     `   CREATE TABLE public.persona (
    id text NOT NULL,
    name text,
    "isAdminType" boolean
);
    DROP TABLE public.persona;
       public         heap r    
   dbsvradmin    false         �           0    0    TABLE persona    ACL     :   GRANT SELECT,REFERENCES ON TABLE public.persona TO nexus;
          public            
   dbsvradmin    false    224         �            1259    16586    personapermission    TABLE     v   CREATE TABLE public.personapermission (
    id text NOT NULL,
    personaid text NOT NULL,
    permissionname text
);
 %   DROP TABLE public.personapermission;
       public         heap r    
   dbsvradmin    false         �           0    0    TABLE personapermission    ACL     D   GRANT SELECT,REFERENCES ON TABLE public.personapermission TO nexus;
          public            
   dbsvradmin    false    225         �            1259    16591    processqueue    TABLE     W  CREATE TABLE public.processqueue (
    processname text NOT NULL,
    processstatus text NOT NULL,
    processstarttime timestamp with time zone NOT NULL,
    processendtime timestamp with time zone,
    targetobject text NOT NULL,
    totalbatches numeric NOT NULL,
    failedbatches numeric NOT NULL,
    failuremessage text,
    id text
);
     DROP TABLE public.processqueue;
       public         heap r       nexus    false         �            1259    16707    processqueue_serial    SEQUENCE     ~   CREATE SEQUENCE public.processqueue_serial
    START WITH 101
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.processqueue_serial;
       public               nexus    false         �            1259    16598 
   recyclebin    TABLE     �   CREATE TABLE public.recyclebin (
    id text NOT NULL,
    originalrowid text NOT NULL,
    originalobject text NOT NULL,
    deleteddate text NOT NULL,
    deletedbyid text NOT NULL
);
    DROP TABLE public.recyclebin;
       public         heap r    
   dbsvradmin    false         �           0    0    TABLE recyclebin    ACL     R   GRANT SELECT,INSERT,REFERENCES,DELETE,UPDATE ON TABLE public.recyclebin TO nexus;
          public            
   dbsvradmin    false    227         �            1259    16603    rowindex    TABLE     �   CREATE TABLE public.rowindex (
    id integer NOT NULL,
    object text NOT NULL,
    objectid text NOT NULL,
    log_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);
    DROP TABLE public.rowindex;
       public         heap r    
   dbsvradmin    false         �            1259    16609    rowindex_id_seq    SEQUENCE     �   CREATE SEQUENCE public.rowindex_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.rowindex_id_seq;
       public            
   dbsvradmin    false    228         �           0    0    rowindex_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.rowindex_id_seq OWNED BY public.rowindex.id;
          public            
   dbsvradmin    false    229         �           0    0    SEQUENCE rowindex_id_seq    ACL     A   GRANT SELECT,USAGE ON SEQUENCE public.rowindex_id_seq TO PUBLIC;
          public            
   dbsvradmin    false    229         �            1259    16610    student    TABLE     �   CREATE TABLE public.student (
    canvasid text NOT NULL,
    fullname text NOT NULL,
    sortablename text NOT NULL,
    id text
);
    DROP TABLE public.student;
       public         heap r    
   dbsvradmin    false         �           0    0    TABLE student    ACL     =   GRANT SELECT,INSERT,UPDATE ON TABLE public.student TO nexus;
          public            
   dbsvradmin    false    230         �            1259    16615    user    TABLE     �   CREATE TABLE public."user" (
    firstname text NOT NULL,
    lastname text NOT NULL,
    email text NOT NULL,
    phone numeric,
    linkedin text,
    id text NOT NULL,
    studentid text,
    personaid text NOT NULL
);
    DROP TABLE public."user";
       public         heap r    
   dbsvradmin    false         �           0    0    TABLE "user"    ACL     9   GRANT SELECT,REFERENCES ON TABLE public."user" TO nexus;
          public            
   dbsvradmin    false    231         �           2604    16620    rowindex id    DEFAULT     j   ALTER TABLE ONLY public.rowindex ALTER COLUMN id SET DEFAULT nextval('public.rowindex_id_seq'::regclass);
 :   ALTER TABLE public.rowindex ALTER COLUMN id DROP DEFAULT;
       public            
   dbsvradmin    false    229    228         �           2606    16622    accesslog accesslog_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.accesslog
    ADD CONSTRAINT accesslog_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.accesslog DROP CONSTRAINT accesslog_pkey;
       public              
   dbsvradmin    false    217         �           2606    16624    assignment assignment_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.assignment
    ADD CONSTRAINT assignment_pkey PRIMARY KEY (canvasid);
 D   ALTER TABLE ONLY public.assignment DROP CONSTRAINT assignment_pkey;
       public              
   dbsvradmin    false    218         �           2606    16626 $   assignmentgroup assignmentgroup_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.assignmentgroup
    ADD CONSTRAINT assignmentgroup_pkey PRIMARY KEY (canvasid);
 N   ALTER TABLE ONLY public.assignmentgroup DROP CONSTRAINT assignmentgroup_pkey;
       public              
   dbsvradmin    false    219         �           2606    16628 .   assignmentsubmission assignmentsubmission_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.assignmentsubmission
    ADD CONSTRAINT assignmentsubmission_pkey PRIMARY KEY (canvasid);
 X   ALTER TABLE ONLY public.assignmentsubmission DROP CONSTRAINT assignmentsubmission_pkey;
       public              
   dbsvradmin    false    220         �           2606    16630    course course_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_pkey PRIMARY KEY (canvasid);
 <   ALTER TABLE ONLY public.course DROP CONSTRAINT course_pkey;
       public              
   dbsvradmin    false    221         �           2606    16632    student coursestudent_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.student
    ADD CONSTRAINT coursestudent_pkey PRIMARY KEY (canvasid);
 D   ALTER TABLE ONLY public.student DROP CONSTRAINT coursestudent_pkey;
       public              
   dbsvradmin    false    230         �           2606    16634 !   coursestudent coursestudent_pkey1 
   CONSTRAINT     e   ALTER TABLE ONLY public.coursestudent
    ADD CONSTRAINT coursestudent_pkey1 PRIMARY KEY (uniqueid);
 K   ALTER TABLE ONLY public.coursestudent DROP CONSTRAINT coursestudent_pkey1;
       public              
   dbsvradmin    false    222         �           2606    16636 (   objectprefixes objectprefixes_object_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.objectprefixes
    ADD CONSTRAINT objectprefixes_object_key UNIQUE (object);
 R   ALTER TABLE ONLY public.objectprefixes DROP CONSTRAINT objectprefixes_object_key;
       public              
   dbsvradmin    false    223         �           2606    16638 "   objectprefixes objectprefixes_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.objectprefixes
    ADD CONSTRAINT objectprefixes_pkey PRIMARY KEY (object);
 L   ALTER TABLE ONLY public.objectprefixes DROP CONSTRAINT objectprefixes_pkey;
       public              
   dbsvradmin    false    223         �           2606    16640    persona persona_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.persona
    ADD CONSTRAINT persona_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.persona DROP CONSTRAINT persona_pkey;
       public              
   dbsvradmin    false    224         �           2606    16642 1   personapermission personapermission_personaid_key 
   CONSTRAINT     q   ALTER TABLE ONLY public.personapermission
    ADD CONSTRAINT personapermission_personaid_key UNIQUE (personaid);
 [   ALTER TABLE ONLY public.personapermission DROP CONSTRAINT personapermission_personaid_key;
       public              
   dbsvradmin    false    225         �           2606    16644 (   personapermission personapermission_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.personapermission
    ADD CONSTRAINT personapermission_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.personapermission DROP CONSTRAINT personapermission_pkey;
       public              
   dbsvradmin    false    225         �           2606    16646    recyclebin recyclebin_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.recyclebin
    ADD CONSTRAINT recyclebin_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.recyclebin DROP CONSTRAINT recyclebin_pkey;
       public              
   dbsvradmin    false    227         �           2606    16648    rowindex rowindex_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.rowindex
    ADD CONSTRAINT rowindex_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.rowindex DROP CONSTRAINT rowindex_pkey;
       public              
   dbsvradmin    false    228         �           2606    16650    user user_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public."user" DROP CONSTRAINT user_pkey;
       public              
   dbsvradmin    false    231         �           2606    16653 #   assignment assignment_courseid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.assignment
    ADD CONSTRAINT assignment_courseid_fkey FOREIGN KEY (courseid) REFERENCES public.course(canvasid);
 M   ALTER TABLE ONLY public.assignment DROP CONSTRAINT assignment_courseid_fkey;
       public            
   dbsvradmin    false    218    3277    221         �           2606    16658 "   assignment assignment_groupid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.assignment
    ADD CONSTRAINT assignment_groupid_fkey FOREIGN KEY (groupid) REFERENCES public.assignmentgroup(canvasid);
 L   ALTER TABLE ONLY public.assignment DROP CONSTRAINT assignment_groupid_fkey;
       public            
   dbsvradmin    false    218    3273    219         �           2606    16663 -   assignmentgroup assignmentgroup_courseid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.assignmentgroup
    ADD CONSTRAINT assignmentgroup_courseid_fkey FOREIGN KEY (courseid) REFERENCES public.course(canvasid);
 W   ALTER TABLE ONLY public.assignmentgroup DROP CONSTRAINT assignmentgroup_courseid_fkey;
       public            
   dbsvradmin    false    219    3277    221         �           2606    16668 ;   assignmentsubmission assignmentsubmission_assignmentid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.assignmentsubmission
    ADD CONSTRAINT assignmentsubmission_assignmentid_fkey FOREIGN KEY (assignmentid) REFERENCES public.assignment(canvasid);
 e   ALTER TABLE ONLY public.assignmentsubmission DROP CONSTRAINT assignmentsubmission_assignmentid_fkey;
       public            
   dbsvradmin    false    220    3271    218         �           2606    16673 >   assignmentsubmission assignmentsubmission_coursestudentid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.assignmentsubmission
    ADD CONSTRAINT assignmentsubmission_coursestudentid_fkey FOREIGN KEY (coursestudentid) REFERENCES public.coursestudent(uniqueid);
 h   ALTER TABLE ONLY public.assignmentsubmission DROP CONSTRAINT assignmentsubmission_coursestudentid_fkey;
       public            
   dbsvradmin    false    222    220    3279         �           2606    16678 8   assignmentsubmission assignmentsubmission_studentid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.assignmentsubmission
    ADD CONSTRAINT assignmentsubmission_studentid_fkey FOREIGN KEY (studentid) REFERENCES public.student(canvasid);
 b   ALTER TABLE ONLY public.assignmentsubmission DROP CONSTRAINT assignmentsubmission_studentid_fkey;
       public            
   dbsvradmin    false    220    3295    230         �           2606    16683 )   coursestudent coursestudent_courseid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.coursestudent
    ADD CONSTRAINT coursestudent_courseid_fkey FOREIGN KEY (courseid) REFERENCES public.course(canvasid);
 S   ALTER TABLE ONLY public.coursestudent DROP CONSTRAINT coursestudent_courseid_fkey;
       public            
   dbsvradmin    false    221    222    3277         �           2606    16688 *   coursestudent coursestudent_studentid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.coursestudent
    ADD CONSTRAINT coursestudent_studentid_fkey FOREIGN KEY (studentid) REFERENCES public.student(canvasid);
 T   ALTER TABLE ONLY public.coursestudent DROP CONSTRAINT coursestudent_studentid_fkey;
       public            
   dbsvradmin    false    230    3295    222                                          restore.sql                                                                                         0000600 0004000 0002000 00000037032 14737626254 0015411 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        --
-- NOTE:
--
-- File paths need to be edited. Search for $$PATH$$ and
-- replace it with the path to the directory containing
-- the extracted data files.
--
--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2 (Debian 17.2-1.pgdg120+1)
-- Dumped by pg_dump version 17.2 (Debian 17.2-1.pgdg120+1)

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

DROP DATABASE studentdata;
--
-- Name: studentdata; Type: DATABASE; Schema: -; Owner: nexus
--

CREATE DATABASE studentdata WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE studentdata OWNER TO nexus;

\connect studentdata

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
-- Name: gen_id(text); Type: FUNCTION; Schema: public; Owner: nexus
--

CREATE FUNCTION public.gen_id(tablename text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_prefix text;
    v_nextval bigint;
    v_custom_id text;
BEGIN
    -- Get the prefix from objectprefixes table
    SELECT prefix INTO v_prefix
    FROM objectprefixes
    WHERE object = tablename
    LIMIT 1;

    -- If no prefix found, raise an error
    IF v_prefix IS NULL THEN
        RAISE EXCEPTION 'Prefix not found for table: %', tablename;
    END IF;

    -- Get the next value from the corresponding sequence
    EXECUTE format('SELECT nextval(''%I_serial'')', tablename) INTO v_nextval;

    -- Combine the prefix and the next sequence value
    v_custom_id := v_prefix || LPAD(v_nextval::text, 10, '0');

    -- Ensure the total length is exactly 13 characters
    IF length(v_custom_id) <> 13 THEN
        RAISE EXCEPTION 'Generated ID length is not 13 characters: %', v_custom_id;
    END IF;

    RETURN v_custom_id;
END;
$$;


ALTER FUNCTION public.gen_id(tablename text) OWNER TO nexus;

--
-- Name: generate_global_id(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.generate_global_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    pre CHAR(3);
    next_id BIGINT;
    padded_id CHAR(7);
BEGIN
    -- Get the prefix for the table
    SELECT prefix INTO pre FROM objectprefixes WHERE object = TG_TABLE_NAME;

    IF pre IS NULL THEN
        RAISE EXCEPTION 'Prefix not defined for table %', TG_TABLE_NAME;
    END IF;

    -- Generate the next serial number
    EXECUTE format('SELECT nextval(pg_get_serial_sequence(''%I'', ''id''))', TG_TABLE_NAME) INTO next_id;

    -- Pad the serial number to 7 characters
    padded_id := LPAD(next_id::TEXT, 7, '0');

    -- Set the new ID
    NEW.id := pre || padded_id;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.generate_global_id() OWNER TO postgres;

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
    pointspossible numeric NOT NULL,
    id text
);


ALTER TABLE public.assignment OWNER TO dbsvradmin;

--
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
-- Name: course; Type: TABLE; Schema: public; Owner: dbsvradmin
--

CREATE TABLE public.course (
    canvasid text NOT NULL,
    coursename text NOT NULL,
    coursedescription text NOT NULL,
    startdate date NOT NULL,
    enddate date NOT NULL,
    id text NOT NULL
);


ALTER TABLE public.course OWNER TO dbsvradmin;

--
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
    personaid text NOT NULL,
    permissionname text
);


ALTER TABLE public.personapermission OWNER TO dbsvradmin;

--
-- Name: processqueue; Type: TABLE; Schema: public; Owner: nexus
--

CREATE TABLE public.processqueue (
    processname text NOT NULL,
    processstatus text NOT NULL,
    processstarttime timestamp with time zone NOT NULL,
    processendtime timestamp with time zone,
    targetobject text NOT NULL,
    totalbatches numeric NOT NULL,
    failedbatches numeric NOT NULL,
    failuremessage text,
    id text
);


ALTER TABLE public.processqueue OWNER TO nexus;

--
-- Name: processqueue_serial; Type: SEQUENCE; Schema: public; Owner: nexus
--

CREATE SEQUENCE public.processqueue_serial
    START WITH 101
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.processqueue_serial OWNER TO nexus;

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
    sortablename text NOT NULL,
    id text
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
-- Name: TABLE assignment; Type: ACL; Schema: public; Owner: dbsvradmin
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.assignment TO nexus;


--
-- Name: TABLE assignmentgroup; Type: ACL; Schema: public; Owner: dbsvradmin
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.assignmentgroup TO nexus;


--
-- Name: TABLE assignmentsubmission; Type: ACL; Schema: public; Owner: dbsvradmin
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.assignmentsubmission TO nexus;


--
-- Name: TABLE course; Type: ACL; Schema: public; Owner: dbsvradmin
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.course TO nexus;


--
-- Name: TABLE coursestudent; Type: ACL; Schema: public; Owner: dbsvradmin
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.coursestudent TO nexus;


--
-- Name: TABLE objectprefixes; Type: ACL; Schema: public; Owner: dbsvradmin
--

GRANT SELECT ON TABLE public.objectprefixes TO PUBLIC;


--
-- Name: TABLE persona; Type: ACL; Schema: public; Owner: dbsvradmin
--

GRANT SELECT,REFERENCES ON TABLE public.persona TO nexus;


--
-- Name: TABLE personapermission; Type: ACL; Schema: public; Owner: dbsvradmin
--

GRANT SELECT,REFERENCES ON TABLE public.personapermission TO nexus;


--
-- Name: TABLE recyclebin; Type: ACL; Schema: public; Owner: dbsvradmin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,UPDATE ON TABLE public.recyclebin TO nexus;


--
-- Name: SEQUENCE rowindex_id_seq; Type: ACL; Schema: public; Owner: dbsvradmin
--

GRANT SELECT,USAGE ON SEQUENCE public.rowindex_id_seq TO PUBLIC;


--
-- Name: TABLE student; Type: ACL; Schema: public; Owner: dbsvradmin
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.student TO nexus;


--
-- Name: TABLE "user"; Type: ACL; Schema: public; Owner: dbsvradmin
--

GRANT SELECT,REFERENCES ON TABLE public."user" TO nexus;


--
-- PostgreSQL database dump complete
--

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      