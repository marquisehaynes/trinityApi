toc.dat                                                                                             0000600 0004000 0002000 00000057262 14737344516 0014471 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        PGDMP   )    '                  }            studentdata    17.2 (Debian 17.2-1.pgdg120+1)    17.2 (Debian 17.2-1.pgdg120+1) L    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false         �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false         �           0    0 
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
   dbsvradmin    false    229    228         {          0    16546 	   accesslog 
   TABLE DATA           F   COPY public.accesslog (id, userid, createddate, recordid) FROM stdin;
    public            
   dbsvradmin    false    217       3451.dat |          0    16551 
   assignment 
   TABLE DATA           [   COPY public.assignment (canvasid, groupid, courseid, name, pointspossible, id) FROM stdin;
    public            
   dbsvradmin    false    218       3452.dat }          0    16556    assignmentgroup 
   TABLE DATA           O   COPY public.assignmentgroup (canvasid, courseid, name, weight, id) FROM stdin;
    public            
   dbsvradmin    false    219       3453.dat ~          0    16561    assignmentsubmission 
   TABLE DATA           |   COPY public.assignmentsubmission (canvasid, coursestudentid, assignmentid, studentid, score, attemptnumber, id) FROM stdin;
    public            
   dbsvradmin    false    220       3454.dat           0    16566    course 
   TABLE DATA           a   COPY public.course (canvasid, coursename, coursedescription, startdate, enddate, id) FROM stdin;
    public            
   dbsvradmin    false    221       3455.dat �          0    16571    coursestudent 
   TABLE DATA           J   COPY public.coursestudent (uniqueid, courseid, studentid, id) FROM stdin;
    public            
   dbsvradmin    false    222       3456.dat �          0    16576    objectprefixes 
   TABLE DATA           8   COPY public.objectprefixes (object, prefix) FROM stdin;
    public            
   dbsvradmin    false    223       3457.dat �          0    16581    persona 
   TABLE DATA           :   COPY public.persona (id, name, "isAdminType") FROM stdin;
    public            
   dbsvradmin    false    224       3458.dat �          0    16586    personapermission 
   TABLE DATA           J   COPY public.personapermission (id, personaid, permissionname) FROM stdin;
    public            
   dbsvradmin    false    225       3459.dat �          0    16591    processqueue 
   TABLE DATA           �   COPY public.processqueue (processname, processstatus, processstarttime, processendtime, targetobject, totalbatches, failedbatches, failuremessage, id) FROM stdin;
    public               nexus    false    226       3460.dat �          0    16598 
   recyclebin 
   TABLE DATA           a   COPY public.recyclebin (id, originalrowid, originalobject, deleteddate, deletedbyid) FROM stdin;
    public            
   dbsvradmin    false    227       3461.dat �          0    16603    rowindex 
   TABLE DATA           B   COPY public.rowindex (id, object, objectid, log_time) FROM stdin;
    public            
   dbsvradmin    false    228       3462.dat �          0    16610    student 
   TABLE DATA           G   COPY public.student (canvasid, fullname, sortablename, id) FROM stdin;
    public            
   dbsvradmin    false    230       3464.dat �          0    16615    user 
   TABLE DATA           g   COPY public."user" (firstname, lastname, email, phone, linkedin, id, studentid, personaid) FROM stdin;
    public            
   dbsvradmin    false    231       3465.dat �           0    0    processqueue_serial    SEQUENCE SET     D   SELECT pg_catalog.setval('public.processqueue_serial', 7623, true);
          public               nexus    false    232         �           0    0    rowindex_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.rowindex_id_seq', 1, true);
          public            
   dbsvradmin    false    229         �           2606    16622    accesslog accesslog_pkey 
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
   dbsvradmin    false    230    3295    222                                                                                                                                                                                                                                                                                                                                                      3451.dat                                                                                            0000600 0004000 0002000 00000000005 14737344516 0014257 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           3452.dat                                                                                            0000600 0004000 0002000 00000000005 14737344516 0014260 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           3453.dat                                                                                            0000600 0004000 0002000 00000000005 14737344516 0014261 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           3454.dat                                                                                            0000600 0004000 0002000 00000000005 14737344516 0014262 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           3455.dat                                                                                            0000600 0004000 0002000 00000000005 14737344516 0014263 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           3456.dat                                                                                            0000600 0004000 0002000 00000000005 14737344516 0014264 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           3457.dat                                                                                            0000600 0004000 0002000 00000000354 14737344516 0014274 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        course	001
student	002
assignmentgroup	003
assignment	004
assignmentquestion	005
submission	006
timesheet	007
timesheetentry	008
user	a01
persona	a02
personapermission	a03
processqueue	a04
accesslog	a05
recyclebin	a06
rowindex	a07
\.


                                                                                                                                                                                                                                                                                    3458.dat                                                                                            0000600 0004000 0002000 00000000005 14737344516 0014266 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           3459.dat                                                                                            0000600 0004000 0002000 00000000005 14737344516 0014267 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           3460.dat                                                                                            0000600 0004000 0002000 00000000467 14737344516 0014273 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        testProcess	Running	2025-01-07 22:47:47.953+00	\N	All	1	0	\N	a040000007591
testProcess	Running	2025-01-07 22:54:27.347+00	\N	All	1	0	\N	a040000007592
DataSync	Running	2025-01-07 22:56:46.223+00	\N	All	1	0	\N	a040000007593
Retrieve Canvas Data	Running	2025-01-07 22:56:46.393+00	\N	All	1	0	\N	a040000007594
\.


                                                                                                                                                                                                         3461.dat                                                                                            0000600 0004000 0002000 00000000005 14737344516 0014260 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           3462.dat                                                                                            0000600 0004000 0002000 00000000005 14737344516 0014261 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           3464.dat                                                                                            0000600 0004000 0002000 00000027645 14737344516 0014306 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        36482586	Shanice Clinton	Clinton, Shanice	\N
34777847	Tashika Coleman	Coleman, Tashika	\N
34117749	Diane Cook	Cook, Diane	\N
35114164	Nayeemah Tucker Cook	Cook, Nayeemah Tucker	\N
112532775	Israel Hampton	Hampton, Israel	\N
112532815	Jacquel Jolly	Jolly, Jacquel	\N
112532933	Aariona Mills	Mills, Aariona	\N
112532940	Farhiya Omar	Omar, Farhiya	\N
112533159	Kanisha Pompy	Pompy, Kanisha	\N
111910517	Verlanda White	White, Verlanda	\N
114908564	Shantajah Caldwell	Caldwell, Shantajah	\N
113868907	Keme Allen	Allen, Keme	\N
112532803	Marisha\tJackson	Jackson, Marisha	\N
112924292	Constance Mayo	Mayo, Constance	\N
37973165	Shauntia Haynes	Haynes, Shauntia	\N
114290807	Osha Jones	Jones, Osha	\N
109039704	Marie Michi	Michi, Marie	\N
35926129	Ashley Tiegs	Tiegs, Ashley	\N
112532756	Shavon Clay	Clay, Shavon	\N
111854835	Belinda Dupriest	Dupriest, Belinda	\N
111912415	Aag Gayfield	Gayfield, Aag	\N
111854667	Tatyanna Grayson	Grayson, Tatyanna	\N
111910489	Bushra Haq	Haq, Bushra	\N
111939973	Rokenya Jones	Jones, Rokenya	\N
111855745	Georgianna King	King, Georgianna	\N
111854965	Kaitlyn Maduscha	Maduscha, Kaitlyn	\N
111245545	Isis Marks	Marks, Isis	\N
111855210	Alexandria McGowan	McGowan, Alexandria	\N
111855153	Rashon McGowan	McGowan, Rashon	\N
111854794	Manquenda McLaughlin	McLaughlin, Manquenda	\N
111880599	Clarissa Peters	Peters, Clarissa	\N
111854878	Incemirra Pole	Pole, Incemirra	\N
111855002	Launette Sanders	Sanders, Launette	\N
111854768	DaShuna Savage	Savage, DaShuna	\N
112532963	Jessica Stossmeister	Stossmeister, Jessica	\N
112532970	Virgia Watkins 	Watkins, Virgia	\N
111854690	Da'Shonte Williams	Williams, Da'Shonte	\N
111855344	Leeanna Williams	Williams, Leeanna	\N
113035256	Mary Anglin	Anglin, Mary	\N
113534765	Kadijha Bonds	Bonds, Kadijha	\N
113531825	Kimberly Gwin	Gwin, Kimberly	\N
113532285	Kadeejah Johnson	Johnson, Kadeejah	\N
114250899	Aerikka Jones	Jones, Aerikka	\N
113555087	Alashia Kirkwood	Kirkwood, Alashia	\N
113553522	Jonise McGowan	McGowan, Jonise	\N
112540977	Ashanti Patrick	Patrick, Ashanti	\N
111912592	Diamond Patterson	Patterson, Diamond	\N
113589293	Danyell Pierce	Pierce, Danyell	\N
113593603	Malikica Robinson	Robinson, Malikica	\N
113553975	Mechelle Townsend	Townsend, Mechelle	\N
110297717	Shameem Ahmed	Ahmed, Shameem	\N
34777393	Alexis Arevalo	Arevalo, Alexis	\N
35025264	Porcha Belser	Belser, Porcha	\N
35025191	Jaquala Burks	Burks, Jaquala	\N
35025090	Nae'chelle Carroll	Carroll, Nae'chelle	\N
36519279	Kierra Clements	Clements, Kierra	\N
29718097	Tashnia Cousins	Cousins, Tashnia	\N
29174142	Nevia Cullins	Cullins, Nevia	\N
36132125	Kenya Dixon	Dixon, Kenya	\N
34118607	Damaris Dorsey	Dorsey, Damaris	\N
36736726	Aliyah Durden	Durden, Aliyah	\N
35106996	Latice Evans	Evans, Latice	\N
35446646	Tunisia Evans	Evans, Tunisia	\N
35116808	Kierra Faygo	Faygo, Kierra	\N
37751678	Brittany Fowler	Fowler, Brittany	\N
34225969	Aryeus Portis Franklin	Franklin, Aryeus Portis	\N
35446740	Kynia Gale	Gale, Kynia	\N
110178372	Shameera Garrett	Garrett, Shameera	\N
29960755	Patricia A Garza	Garza, Patricia A	\N
35025521	Joi Gipson	Gipson, Joi	\N
35025306	Shacora Gipson	Gipson, Shacora	\N
36482932	Elisha Grady	Grady, Elisha	\N
37211122	Ikeria Green	Green, Ikeria	\N
37815792	Kadiyah Green	Green, Kadiyah	\N
26936534	Michael Gregory	Gregory, Michael	\N
35060993	Estella Hall	Hall, Estella	\N
37657016	Javonia Harper	Harper, Javonia	\N
36080807	Sharlissa Harris	Harris, Sharlissa	\N
36131482	Keywaunda Hicks	Hicks, Keywaunda	\N
110131493	Nikila Higgins	Higgins, Nikila	\N
27380085	Jacqueline HillParker	HillParker, Jacqueline	\N
36080781	Jasmine Hollins	Hollins, Jasmine	\N
36155797	Katina Hollis	Hollis, Katina	\N
34777859	Sharlisa Holloway	Holloway, Sharlisa	\N
37777709	Roshya Hortman	Hortman, Roshya	\N
36444877	Bollo Hussein	Hussein, Bollo	\N
110544107	Arfa Mohammed Ilyas	Ilyas, Arfa Mohammed	\N
30101148	Jacquline	Jacquline	\N
30186217	Lori Janusz	Janusz, Lori	\N
35024850	Shenikwa Jennings	Jennings, Shenikwa	\N
30530380	Brittney Johnson	Johnson, Brittney	\N
34117226	Cierra Johnson	Johnson, Cierra	\N
26247132	KANISHA A JOHNSON	JOHNSON, KANISHA A	\N
35093024	Samia Johnson	Johnson, Samia	\N
28891914	JoMarieDowell	JoMarieDowell	\N
26256806	Ashanti Jones	Jones, Ashanti	\N
32617388	Precious Jones	Jones, Precious	\N
34560949	Kimberly	Kimberly	\N
26346247	Chiandria King	King, Chiandria	\N
35511503	Crystal Larkin	Larkin, Crystal	\N
29196189	Latricia	Latricia	\N
30530392	Lawanda	Lawanda	\N
37752255	Jaliyah Lawrence	Lawrence, Jaliyah	\N
30530698	Latonya Lockwood	Lockwood, Latonya	\N
25352293	Cherish Lumpkins	Lumpkins, Cherish	\N
109367596	Shahidah Malone	Malone, Shahidah	\N
91818594	Jarnay Martin	Martin, Jarnay	\N
30890273	Elsa Mata	Mata, Elsa	\N
35024983	Gamila May	May, Gamila	\N
36519215	Latosha Mayhall	Mayhall, Latosha	\N
35048027	Tiffany McClain	McClain, Tiffany	\N
30486573	Janice Monique McKinley	McKinley, Janice Monique	\N
35025327	Yamika Meek	Meek, Yamika	\N
35446813	Reahna Miller	Miller, Reahna	\N
26270412	Lexus Mitchell 	Mitchell, Lexus	\N
35446836	Aviance Montgomery	Montgomery, Aviance	\N
34205552	Sabrina Moore	Moore, Sabrina	\N
35048156	Dianna Moralez	Moralez, Dianna	\N
35509966	Jocelyn Morrison	Morrison, Jocelyn	\N
37715521	Tamischa Morrison	Morrison, Tamischa	\N
30856205	Debbie Mosinski	Mosinski, Debbie	\N
27450016	Christina A. Munoz	Munoz, Christina A.	\N
35446846	Francine Mwanga	Mwanga, Francine	\N
36519252	Phalyn Patterson	Patterson, Phalyn	\N
35113692	Sofia Perez	Perez, Sofia	\N
28605856	TRACY PERKINS	PERKINS, TRACY	\N
91818019	K'ona Peters	Peters, K'ona	\N
30080014	Alicia Phillips	Phillips, Alicia	\N
37716255	Shiconda Phipps	Phipps, Shiconda	\N
35025363	Jaymia Putzear	Putzear, Jaymia	\N
110573964	Alexis Ramirez	Ramirez, Alexis	\N
26275361	Ericka Reed	Reed, Ericka	\N
24888056	Effie Renfro	Renfro, Effie	\N
34777004	Svanna Ricks	Ricks, Svanna	\N
37815813	Antoinette Roberts	Roberts, Antoinette	\N
34205387	Shaqualyn Roberts	Roberts, Shaqualyn	\N
26247120	Bianca D Robinson	Robinson, Bianca D	\N
33052949	Rosheena 	Rosheena	\N
25010286	Zerina Derria Sandridge	Sandridge, Zerina Derria	\N
34214221	Latanna Semons	Semons, Latanna	\N
35113975	Monique Sledge	Sledge, Monique	\N
110811478	MarQuianna Butler	Butler, MarQuianna	\N
110847016	Reva Davis	Davis, Reva	\N
110810384	Lataura Griffin	Griffin, Lataura	\N
111770881	Marquise Haynes	Haynes, Marquise	\N
24361831	Shauntia Haynes	Haynes, Shauntia	\N
111242277	Terranae Hollins	Hollins, Terranae	\N
110821071	Lekemberell Mathies	Mathies, Lekemberell	\N
111204379	Artorous Moran	Moran, Artorous	\N
110811306	Sharita Rollins	Rollins, Sharita	\N
109743202	Arnestris Thompson	Thompson, Arnestris	\N
111227599	Jessica Wiley	Wiley, Jessica	\N
111548857	Kennedi Austyn	Austyn, Kennedi	\N
111854916	Asia Dunomeshood	Dunomeshood, Asia	\N
111944073	Mohammed Haq	Haq, Mohammed	\N
111854852	Emeline Harmon	Harmon, Emeline	\N
110349609	Azariea Lee	Lee, Azariea	\N
111855687	Breonna Lovett	Lovett, Breonna	\N
111855191	Treasure Perkins	Perkins, Treasure	\N
111855321	Antonia Wren	Wren, Antonia	\N
112271931	Nur Shaidah Nur Amin	Amin, Nur Shaidah Nur	\N
112277691	Miquela DeBerry	DeBerry, Miquela	\N
111855239	Brenda Fiebig	Fiebig, Brenda	\N
112290758	Linta Hag	Hag, Linta	\N
111855080	Danisha Jones	Jones, Danisha	\N
111854807	Andrea Sharp	Sharp, Andrea	\N
112277695	Lakecia Turner	Turner, Lakecia	\N
35985376	Sheresa Hayes	Hayes, Sheresa	\N
113533500	Jasmine Smith	Smith, Jasmine	\N
112541538	Nakiah Torrence	Torrence, Nakiah	\N
110374761	Capresha Sloan	Sloan, Capresha	\N
35985418	Promise Campbell	Campbell, Promise	\N
33805801	Jamisha L Gill	Gill, Jamisha L	\N
112278194	Carleda Stemley	Stemley, Carleda	\N
113932088	Marige Diaz	Diaz, Marige	\N
112643419	Keturah Chesser	Chesser, Keturah	\N
112541526	Shiterra Yearby	Yearby, Shiterra	\N
37434104	Alexis Briggs	Briggs, Alexis	\N
35985333	Isaiah LeBlanc	LeBlanc, Isaiah	\N
33848661	JAMIELLA MILLER	MILLER, JAMIELLA	\N
37434318	Curissa Mitchell	Mitchell, Curissa	\N
33788448	Mary neal 	neal, Mary	\N
37358860	Myelle Reynolds	Reynolds, Myelle	\N
37434285	Cherneice Stewart	Stewart, Cherneice	\N
35985361	Meagan Taylor	Taylor, Meagan	\N
37434238	Hlikou Thor	Thor, Hlikou	\N
37434373	Tionna Trotter	Trotter, Tionna	\N
37435806	Tionna Trotter	Trotter, Tionna	\N
111547456	Habibah Ramat Ullah	Ullah, Habibah Ramat	\N
34777680	Charlesha Williams	Williams, Charlesha	\N
111855449	Tiffany Phillips	Phillips, Tiffany	\N
112923870	Eva Ragsdale	Ragsdale, Eva	\N
112121477	Dyvia Taylor	Taylor, Dyvia	\N
112448163	Tiora Workman	Workman, Tiora	\N
110348902	Cornelius Armstrong	Armstrong, Cornelius	\N
111548843	Shantavia Hullum	Hullum, Shantavia	\N
111548873	Elika Johnican	Johnican, Elika	\N
111548864	Shiloh McKinney	McKinney, Shiloh	\N
110313688	Lashell Scott	Scott, Lashell	\N
111241779	Lasandra Walker	Walker, Lasandra	\N
111855662	Jaclynne Evans	Evans, Jaclynne	\N
112121403	Karmalah Griffin	Griffin, Karmalah	\N
110375967	Tashanda Washington	Washington, Tashanda	\N
112448203	Danyell Pierce	Danyell4.0	\N
111205743	Sakila Griffin	Griffin, Sakila	\N
112448301	Davionna Lee	Lee, Davionna	\N
111855259	Majuma Chivala	Chivala, Majuma	\N
111854745	Shuntaye Davis	Davis, Shuntaye	\N
111854713	Kmya Eason-Love	Eason-Love, Kmya	\N
111854577	Jamiah Herron-James	Herron-James, Jamiah	\N
111854702	Crystal Jackson	Jackson, Crystal	\N
111854862	Dominque Jackson	Jackson, Dominque	\N
111910369	Christinique McKnight	McKnight, Christinique	\N
111855280	Nicole Nichols	Nichols, Nicole	\N
111854947	Amber Perkins	Perkins, Amber	\N
111855057	Ataesha Ward	Ward, Ataesha	\N
110820108	Tracy Alvarez	Alvarez, Tracy	\N
110812448	Adrianna Austin	Austin, Adrianna	\N
110326450	Olivia Beard	Beard, Olivia	\N
110843225	Ricayla Brooks	Brooks, Ricayla	\N
110842758	Jalica Brown	Brown, Jalica	\N
110812262	Takiria Canada	Canada, Takiria	\N
110823178	Precious Cloyd	Cloyd, Precious	\N
110820292	Denisha Cox	Cox, Denisha	\N
110810045	Aaliyah Edwards	Edwards, Aaliyah	\N
110822947	Ladaisha Gatson	Gatson, Ladaisha	\N
110842851	Priscilla Gholston	Gholston, Priscilla	\N
111241688	Tawanda Henderson	Henderson, Tawanda	\N
110811184	Caniqua Hendon	Hendon, Caniqua	\N
110823354	Tranice Holifield	Holifield, Tranice	\N
110822865	Diamond Jackson	Jackson, Diamond	\N
110845503	Nakisha Johnson	Johnson, Nakisha	\N
110821011	Myisha Malone	Malone, Myisha	\N
110822820	Catelyn Milinski	Milinski, Catelyn	\N
110842383	Tayo Olufosoye	Olufosoye, Tayo	\N
110810914	Vonquella Sparks	Sparks, Vonquella	\N
110823103	Ebony Watts	Watts, Ebony	\N
111306096	Essence	Essence	\N
111241485	Noah Smith	Smith, Noah	\N
27387461	Keishla Montas Baez	Baez, Keishla Montas	\N
29713419	Lakeysha brown 	brown, Lakeysha	\N
30362434	Lakeysha Brown	Brown, Lakeysha	\N
30138675	Chasmaine burris	burris, Chasmaine	\N
30082218	Drakeylia Cook	Cook, Drakeylia	\N
30170913	Minerva Cruz	Cruz, Minerva	\N
30170785	Adriana Dunson	Dunson, Adriana	\N
29989396	Barbara Emanuela	Emanuela, Barbara	\N
27437658	Andrea Glazer	Glazer, Andrea	\N
27362315	Haley Lang	Lang, Haley	\N
33848478	tianna love	love, tianna	\N
33848995	tianna love	love, tianna	\N
30163501	Sherry Mccoy	Mccoy, Sherry	\N
23775544	Ylenia Medina	Medina, Ylenia	\N
30679310	Ylenia Medina	Medina, Ylenia	\N
30484220	Jasmine Moore	Moore, Jasmine	\N
30530807	Juanita moore	moore, Juanita	\N
27046231	arnetta rockett	rockett, arnetta	\N
27578216	Elias Rosario	Rosario, Elias	\N
25342353	Cloetta Sanders 	Sanders, Cloetta	\N
28237468	Bailie sass	sass, Bailie	\N
26093397	Cassandra Scott	Scott, Cassandra	\N
27046155	sharita	sharita	\N
23781721	SHARONDA	SHARONDA	\N
28209502	Satara Shaw	Shaw, Satara	\N
23519662	Ledeisha Smith	Smith, Ledeisha	\N
27172970	Lawanda Lavonne Starks	Starks, Lawanda Lavonne	\N
25566473	Sheronica Staten 	Staten, Sheronica	\N
29385974	Dyavena Sumler	Sumler, Dyavena	\N
25218267	jaya tancinco	tancinco, jaya	\N
23519691	Takilra Thomas	Thomas, Takilra	\N
27368640	Ryllie Thompson	Thompson, Ryllie	\N
26886924	Porsha Thornton 	Thornton, Porsha	\N
29195707	tia	tia	\N
26259090	Ellavisha R Tillman	Tillman, Ellavisha R	\N
30128199	Jihan Todorovich	Todorovich, Jihan	\N
25577511	Toni	Toni	\N
23405901	Rashana Walker	Walker, Rashana	\N
27436287	Glenda Ward	Ward, Glenda	\N
30498885	Jacqueline D Williams	Williams, Jacqueline D	\N
\.


                                                                                           3465.dat                                                                                            0000600 0004000 0002000 00000000005 14737344516 0014264 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        \.


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           restore.sql                                                                                         0000600 0004000 0002000 00000047273 14737344516 0015417 0                                                                                                    ustar 00postgres                        postgres                        0000000 0000000                                                                                                                                                                        --
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
-- Data for Name: accesslog; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public.accesslog (id, userid, createddate, recordid) FROM stdin;
\.
COPY public.accesslog (id, userid, createddate, recordid) FROM '$$PATH$$/3451.dat';

--
-- Data for Name: assignment; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public.assignment (canvasid, groupid, courseid, name, pointspossible, id) FROM stdin;
\.
COPY public.assignment (canvasid, groupid, courseid, name, pointspossible, id) FROM '$$PATH$$/3452.dat';

--
-- Data for Name: assignmentgroup; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public.assignmentgroup (canvasid, courseid, name, weight, id) FROM stdin;
\.
COPY public.assignmentgroup (canvasid, courseid, name, weight, id) FROM '$$PATH$$/3453.dat';

--
-- Data for Name: assignmentsubmission; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public.assignmentsubmission (canvasid, coursestudentid, assignmentid, studentid, score, attemptnumber, id) FROM stdin;
\.
COPY public.assignmentsubmission (canvasid, coursestudentid, assignmentid, studentid, score, attemptnumber, id) FROM '$$PATH$$/3454.dat';

--
-- Data for Name: course; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public.course (canvasid, coursename, coursedescription, startdate, enddate, id) FROM stdin;
\.
COPY public.course (canvasid, coursename, coursedescription, startdate, enddate, id) FROM '$$PATH$$/3455.dat';

--
-- Data for Name: coursestudent; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public.coursestudent (uniqueid, courseid, studentid, id) FROM stdin;
\.
COPY public.coursestudent (uniqueid, courseid, studentid, id) FROM '$$PATH$$/3456.dat';

--
-- Data for Name: objectprefixes; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public.objectprefixes (object, prefix) FROM stdin;
\.
COPY public.objectprefixes (object, prefix) FROM '$$PATH$$/3457.dat';

--
-- Data for Name: persona; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public.persona (id, name, "isAdminType") FROM stdin;
\.
COPY public.persona (id, name, "isAdminType") FROM '$$PATH$$/3458.dat';

--
-- Data for Name: personapermission; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public.personapermission (id, personaid, permissionname) FROM stdin;
\.
COPY public.personapermission (id, personaid, permissionname) FROM '$$PATH$$/3459.dat';

--
-- Data for Name: processqueue; Type: TABLE DATA; Schema: public; Owner: nexus
--

COPY public.processqueue (processname, processstatus, processstarttime, processendtime, targetobject, totalbatches, failedbatches, failuremessage, id) FROM stdin;
\.
COPY public.processqueue (processname, processstatus, processstarttime, processendtime, targetobject, totalbatches, failedbatches, failuremessage, id) FROM '$$PATH$$/3460.dat';

--
-- Data for Name: recyclebin; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public.recyclebin (id, originalrowid, originalobject, deleteddate, deletedbyid) FROM stdin;
\.
COPY public.recyclebin (id, originalrowid, originalobject, deleteddate, deletedbyid) FROM '$$PATH$$/3461.dat';

--
-- Data for Name: rowindex; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public.rowindex (id, object, objectid, log_time) FROM stdin;
\.
COPY public.rowindex (id, object, objectid, log_time) FROM '$$PATH$$/3462.dat';

--
-- Data for Name: student; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public.student (canvasid, fullname, sortablename, id) FROM stdin;
\.
COPY public.student (canvasid, fullname, sortablename, id) FROM '$$PATH$$/3464.dat';

--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public."user" (firstname, lastname, email, phone, linkedin, id, studentid, personaid) FROM stdin;
\.
COPY public."user" (firstname, lastname, email, phone, linkedin, id, studentid, personaid) FROM '$$PATH$$/3465.dat';

--
-- Name: processqueue_serial; Type: SEQUENCE SET; Schema: public; Owner: nexus
--

SELECT pg_catalog.setval('public.processqueue_serial', 7623, true);


--
-- Name: rowindex_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dbsvradmin
--

SELECT pg_catalog.setval('public.rowindex_id_seq', 1, true);


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

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     