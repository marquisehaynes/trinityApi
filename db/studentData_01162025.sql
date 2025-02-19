PGDMP  *    	                 }            studentdata    17.2    17.1 D    &           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false            '           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false            (           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false            )           1262    24576    studentdata    DATABASE     �   CREATE DATABASE studentdata WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';
    DROP DATABASE studentdata;
                     postgres    false            �            1255    24577    gen_id(text)    FUNCTION     �  CREATE FUNCTION public.gen_id(tablename text) RETURNS text
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
       public               nexus    false            �            1259    24580 	   accesslog    TABLE     �   CREATE TABLE public.accesslog (
    id text DEFAULT public.gen_id('accesslog'::text) NOT NULL,
    userid text NOT NULL,
    createddate timestamp with time zone NOT NULL,
    recordid text NOT NULL
);
    DROP TABLE public.accesslog;
       public         heap r    
   dbsvradmin    false    242            �            1259    24741    accesslog_serial    SEQUENCE     y   CREATE SEQUENCE public.accesslog_serial
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.accesslog_serial;
       public            
   dbsvradmin    false            �            1259    24585 
   assignment    TABLE       CREATE TABLE public.assignment (
    groupid text NOT NULL,
    courseid text NOT NULL,
    name text NOT NULL,
    pointspossible numeric NOT NULL,
    canvasid text,
    id text DEFAULT public.gen_id('assignment'::text) NOT NULL,
    isdeleted boolean
);
    DROP TABLE public.assignment;
       public         heap r    
   dbsvradmin    false    242            *           0    0    TABLE assignment    ACL     @   GRANT SELECT,INSERT,UPDATE ON TABLE public.assignment TO nexus;
          public            
   dbsvradmin    false    218            �            1259    24732    assignment_serial    SEQUENCE     z   CREATE SEQUENCE public.assignment_serial
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.assignment_serial;
       public            
   dbsvradmin    false            �            1259    24590    assignmentgroup    TABLE     �   CREATE TABLE public.assignmentgroup (
    courseid text NOT NULL,
    name text NOT NULL,
    weight numeric NOT NULL,
    id text DEFAULT public.gen_id('assignmentgroup'::text) NOT NULL,
    canvasid text,
    isdeleted boolean
);
 #   DROP TABLE public.assignmentgroup;
       public         heap r    
   dbsvradmin    false    242            +           0    0    TABLE assignmentgroup    ACL     E   GRANT SELECT,INSERT,UPDATE ON TABLE public.assignmentgroup TO nexus;
          public            
   dbsvradmin    false    219            �            1259    24733    assignmentgroup_serial    SEQUENCE        CREATE SEQUENCE public.assignmentgroup_serial
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.assignmentgroup_serial;
       public               nexus    false            �            1259    24595    assignmentsubmission    TABLE     J  CREATE TABLE public.assignmentsubmission (
    canvasid text NOT NULL,
    coursestudentid text NOT NULL,
    assignmentid text NOT NULL,
    studentid text NOT NULL,
    score numeric NOT NULL,
    attemptnumber numeric NOT NULL,
    id text DEFAULT public.gen_id('assignmentsubmission'::text) NOT NULL,
    isdeleted boolean
);
 (   DROP TABLE public.assignmentsubmission;
       public         heap r       nexus    false    242            ,           0    0    TABLE assignmentsubmission    ACL     �   REVOKE ALL ON TABLE public.assignmentsubmission FROM nexus;
GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE public.assignmentsubmission TO nexus;
          public               nexus    false    220            �            1259    24734    assignmentsubmission_serial    SEQUENCE     �   CREATE SEQUENCE public.assignmentsubmission_serial
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public.assignmentsubmission_serial;
       public               nexus    false            �            1259    24600    course    TABLE        CREATE TABLE public.course (
    canvasid text,
    coursename text NOT NULL,
    coursedescription text NOT NULL,
    startdate date NOT NULL,
    enddate date NOT NULL,
    id text DEFAULT public.gen_id('course'::text) NOT NULL,
    isdeleted boolean
);
    DROP TABLE public.course;
       public         heap r    
   dbsvradmin    false    242            -           0    0    TABLE course    ACL     <   GRANT SELECT,INSERT,UPDATE ON TABLE public.course TO nexus;
          public            
   dbsvradmin    false    221            �            1259    24728    course_serial    SEQUENCE     v   CREATE SEQUENCE public.course_serial
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.course_serial;
       public            
   dbsvradmin    false            .           0    0    SEQUENCE course_serial    ACL     >   GRANT SELECT,USAGE ON SEQUENCE public.course_serial TO nexus;
          public            
   dbsvradmin    false    231            �            1259    24605    coursestudent    TABLE     �   CREATE TABLE public.coursestudent (
    uniqueid text NOT NULL,
    courseid text NOT NULL,
    studentid text NOT NULL,
    id text DEFAULT public.gen_id('coursestudent'::text) NOT NULL,
    isdeleted boolean
);
 !   DROP TABLE public.coursestudent;
       public         heap r    
   dbsvradmin    false    242            /           0    0    TABLE coursestudent    ACL     C   GRANT SELECT,INSERT,UPDATE ON TABLE public.coursestudent TO nexus;
          public            
   dbsvradmin    false    222            �            1259    24735    coursestudent_serial    SEQUENCE     }   CREATE SEQUENCE public.coursestudent_serial
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.coursestudent_serial;
       public               nexus    false            �            1259    24610    objectprefixes    TABLE     [   CREATE TABLE public.objectprefixes (
    object text NOT NULL,
    prefix text NOT NULL
);
 "   DROP TABLE public.objectprefixes;
       public         heap r    
   dbsvradmin    false            0           0    0    TABLE objectprefixes    ACL     7   GRANT SELECT ON TABLE public.objectprefixes TO PUBLIC;
          public            
   dbsvradmin    false    223            �            1259    24615    persona    TABLE     �   CREATE TABLE public.persona (
    id text DEFAULT public.gen_id('persona'::text) NOT NULL,
    name text,
    "isAdminType" boolean
);
    DROP TABLE public.persona;
       public         heap r    
   dbsvradmin    false    242            1           0    0    TABLE persona    ACL     :   GRANT SELECT,REFERENCES ON TABLE public.persona TO nexus;
          public            
   dbsvradmin    false    224            �            1259    24736    persona_serial    SEQUENCE     w   CREATE SEQUENCE public.persona_serial
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.persona_serial;
       public               nexus    false            �            1259    24620    personapermission    TABLE     �   CREATE TABLE public.personapermission (
    id text DEFAULT public.gen_id('personapermission'::text) NOT NULL,
    personaid text NOT NULL,
    permissionname text
);
 %   DROP TABLE public.personapermission;
       public         heap r    
   dbsvradmin    false    242            2           0    0    TABLE personapermission    ACL     D   GRANT SELECT,REFERENCES ON TABLE public.personapermission TO nexus;
          public            
   dbsvradmin    false    225            �            1259    24737    personapermission_serial    SEQUENCE     �   CREATE SEQUENCE public.personapermission_serial
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.personapermission_serial;
       public            
   dbsvradmin    false            �            1259    24625    processqueue    TABLE     �  CREATE TABLE public.processqueue (
    processname text NOT NULL,
    processstatus text NOT NULL,
    processstarttime timestamp with time zone NOT NULL,
    processendtime timestamp with time zone,
    targetobject text NOT NULL,
    totalbatches numeric NOT NULL,
    failedbatches numeric NOT NULL,
    failuremessage text,
    id text DEFAULT public.gen_id('processqueue'::text) NOT NULL
);
     DROP TABLE public.processqueue;
       public         heap r       nexus    false    242            �            1259    24630    processqueue_serial    SEQUENCE     |   CREATE SEQUENCE public.processqueue_serial
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.processqueue_serial;
       public               nexus    false            �            1259    24631 
   recyclebin    TABLE     �   CREATE TABLE public.recyclebin (
    id text DEFAULT public.gen_id('recyclebin'::text) NOT NULL,
    originalrowid text NOT NULL,
    originalobject text NOT NULL,
    deleteddate text NOT NULL,
    deletedbyid text NOT NULL
);
    DROP TABLE public.recyclebin;
       public         heap r    
   dbsvradmin    false    242            3           0    0    TABLE recyclebin    ACL     R   GRANT SELECT,INSERT,REFERENCES,DELETE,UPDATE ON TABLE public.recyclebin TO nexus;
          public            
   dbsvradmin    false    228            �            1259    24738    recyclebin_serial    SEQUENCE     z   CREATE SEQUENCE public.recyclebin_serial
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.recyclebin_serial;
       public               nexus    false            �            1259    24643    student    TABLE     �   CREATE TABLE public.student (
    canvasid text,
    fullname text NOT NULL,
    sortablename text NOT NULL,
    id text DEFAULT public.gen_id('student'::text) NOT NULL,
    isdeleted boolean
);
    DROP TABLE public.student;
       public         heap r    
   dbsvradmin    false    242            4           0    0    TABLE student    ACL     =   GRANT SELECT,INSERT,UPDATE ON TABLE public.student TO nexus;
          public            
   dbsvradmin    false    229            �            1259    24739    student_serial    SEQUENCE     w   CREATE SEQUENCE public.student_serial
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.student_serial;
       public               nexus    false            �            1259    24648    user    TABLE       CREATE TABLE public."user" (
    firstname text NOT NULL,
    lastname text NOT NULL,
    email text NOT NULL,
    phone numeric,
    linkedin text,
    id text DEFAULT public.gen_id('user'::text) NOT NULL,
    studentid text,
    personaid text NOT NULL,
    isactive boolean
);
    DROP TABLE public."user";
       public         heap r    
   dbsvradmin    false    242            5           0    0    TABLE "user"    ACL     9   GRANT SELECT,REFERENCES ON TABLE public."user" TO nexus;
          public            
   dbsvradmin    false    230            �            1259    24740    user_serial    SEQUENCE     t   CREATE SEQUENCE public.user_serial
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.user_serial;
       public            
   dbsvradmin    false            j           2606    24655    accesslog accesslog_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.accesslog
    ADD CONSTRAINT accesslog_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.accesslog DROP CONSTRAINT accesslog_pkey;
       public              
   dbsvradmin    false    217            l           2606    24782    assignment assignment_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.assignment
    ADD CONSTRAINT assignment_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.assignment DROP CONSTRAINT assignment_pkey;
       public              
   dbsvradmin    false    218            n           2606    24753 $   assignmentgroup assignmentgroup_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.assignmentgroup
    ADD CONSTRAINT assignmentgroup_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.assignmentgroup DROP CONSTRAINT assignmentgroup_pkey;
       public              
   dbsvradmin    false    219            p           2606    24751 .   assignmentsubmission assignmentsubmission_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public.assignmentsubmission
    ADD CONSTRAINT assignmentsubmission_pkey PRIMARY KEY (id);
 X   ALTER TABLE ONLY public.assignmentsubmission DROP CONSTRAINT assignmentsubmission_pkey;
       public                 nexus    false    220            r           2606    25025    course course_canvasid_key 
   CONSTRAINT     Y   ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_canvasid_key UNIQUE (canvasid);
 D   ALTER TABLE ONLY public.course DROP CONSTRAINT course_canvasid_key;
       public              
   dbsvradmin    false    221            t           2606    24749    course course_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.course DROP CONSTRAINT course_pkey;
       public              
   dbsvradmin    false    221            v           2606    24747 !   coursestudent coursestudent_pkey1 
   CONSTRAINT     _   ALTER TABLE ONLY public.coursestudent
    ADD CONSTRAINT coursestudent_pkey1 PRIMARY KEY (id);
 K   ALTER TABLE ONLY public.coursestudent DROP CONSTRAINT coursestudent_pkey1;
       public              
   dbsvradmin    false    222            x           2606    24669 (   objectprefixes objectprefixes_object_key 
   CONSTRAINT     e   ALTER TABLE ONLY public.objectprefixes
    ADD CONSTRAINT objectprefixes_object_key UNIQUE (object);
 R   ALTER TABLE ONLY public.objectprefixes DROP CONSTRAINT objectprefixes_object_key;
       public              
   dbsvradmin    false    223            z           2606    24671 "   objectprefixes objectprefixes_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.objectprefixes
    ADD CONSTRAINT objectprefixes_pkey PRIMARY KEY (object);
 L   ALTER TABLE ONLY public.objectprefixes DROP CONSTRAINT objectprefixes_pkey;
       public              
   dbsvradmin    false    223            |           2606    24673    persona persona_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.persona
    ADD CONSTRAINT persona_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.persona DROP CONSTRAINT persona_pkey;
       public              
   dbsvradmin    false    224            ~           2606    24675 1   personapermission personapermission_personaid_key 
   CONSTRAINT     q   ALTER TABLE ONLY public.personapermission
    ADD CONSTRAINT personapermission_personaid_key UNIQUE (personaid);
 [   ALTER TABLE ONLY public.personapermission DROP CONSTRAINT personapermission_personaid_key;
       public              
   dbsvradmin    false    225            �           2606    24677 (   personapermission personapermission_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.personapermission
    ADD CONSTRAINT personapermission_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.personapermission DROP CONSTRAINT personapermission_pkey;
       public              
   dbsvradmin    false    225            �           2606    25199    processqueue processqueue_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.processqueue
    ADD CONSTRAINT processqueue_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.processqueue DROP CONSTRAINT processqueue_pkey;
       public                 nexus    false    226            �           2606    24679    recyclebin recyclebin_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.recyclebin
    ADD CONSTRAINT recyclebin_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.recyclebin DROP CONSTRAINT recyclebin_pkey;
       public              
   dbsvradmin    false    228            �           2606    24760    student student_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.student DROP CONSTRAINT student_pkey;
       public              
   dbsvradmin    false    229            �           2606    24683    user user_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public."user" DROP CONSTRAINT user_pkey;
       public              
   dbsvradmin    false    230            �           2606    24788 #   assignment assignment_courseid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.assignment
    ADD CONSTRAINT assignment_courseid_fkey FOREIGN KEY (courseid) REFERENCES public.course(id) NOT VALID;
 M   ALTER TABLE ONLY public.assignment DROP CONSTRAINT assignment_courseid_fkey;
       public            
   dbsvradmin    false    4724    221    218            �           2606    24783 "   assignment assignment_groupid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.assignment
    ADD CONSTRAINT assignment_groupid_fkey FOREIGN KEY (groupid) REFERENCES public.assignmentgroup(id) NOT VALID;
 L   ALTER TABLE ONLY public.assignment DROP CONSTRAINT assignment_groupid_fkey;
       public            
   dbsvradmin    false    218    219    4718            �           2606    24793 -   assignmentgroup assignmentgroup_courseid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.assignmentgroup
    ADD CONSTRAINT assignmentgroup_courseid_fkey FOREIGN KEY (courseid) REFERENCES public.course(id) NOT VALID;
 W   ALTER TABLE ONLY public.assignmentgroup DROP CONSTRAINT assignmentgroup_courseid_fkey;
       public            
   dbsvradmin    false    219    4724    221            �           2606    24798 >   assignmentsubmission assignmentsubmission_coursestudentid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.assignmentsubmission
    ADD CONSTRAINT assignmentsubmission_coursestudentid_fkey FOREIGN KEY (coursestudentid) REFERENCES public.coursestudent(id) NOT VALID;
 h   ALTER TABLE ONLY public.assignmentsubmission DROP CONSTRAINT assignmentsubmission_coursestudentid_fkey;
       public               nexus    false    220    4726    222            �           2606    24803 8   assignmentsubmission assignmentsubmission_studentid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.assignmentsubmission
    ADD CONSTRAINT assignmentsubmission_studentid_fkey FOREIGN KEY (studentid) REFERENCES public.student(id) NOT VALID;
 b   ALTER TABLE ONLY public.assignmentsubmission DROP CONSTRAINT assignmentsubmission_studentid_fkey;
       public               nexus    false    4742    220    229            �           2606    24761 )   coursestudent coursestudent_courseid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.coursestudent
    ADD CONSTRAINT coursestudent_courseid_fkey FOREIGN KEY (courseid) REFERENCES public.course(id) NOT VALID;
 S   ALTER TABLE ONLY public.coursestudent DROP CONSTRAINT coursestudent_courseid_fkey;
       public            
   dbsvradmin    false    221    222    4724            �           2606    24766 *   coursestudent coursestudent_studentid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.coursestudent
    ADD CONSTRAINT coursestudent_studentid_fkey FOREIGN KEY (studentid) REFERENCES public.student(id) NOT VALID;
 T   ALTER TABLE ONLY public.coursestudent DROP CONSTRAINT coursestudent_studentid_fkey;
       public            
   dbsvradmin    false    4742    222    229            �           2606    24754 2   personapermission personapermission_personaid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.personapermission
    ADD CONSTRAINT personapermission_personaid_fkey FOREIGN KEY (personaid) REFERENCES public.persona(id) NOT VALID;
 \   ALTER TABLE ONLY public.personapermission DROP CONSTRAINT personapermission_personaid_fkey;
       public            
   dbsvradmin    false    4732    225    224            �           2606    24776    user user_personaid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_personaid_fkey FOREIGN KEY (personaid) REFERENCES public.persona(id) NOT VALID;
 D   ALTER TABLE ONLY public."user" DROP CONSTRAINT user_personaid_fkey;
       public            
   dbsvradmin    false    4732    224    230            �           2606    24771    user user_studentid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_studentid_fkey FOREIGN KEY (studentid) REFERENCES public.student(id) NOT VALID;
 D   ALTER TABLE ONLY public."user" DROP CONSTRAINT user_studentid_fkey;
       public            
   dbsvradmin    false    4742    229    230           