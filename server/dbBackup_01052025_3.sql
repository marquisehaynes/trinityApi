--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.2

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
    id text
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
    failuremessage text,
    id text PRIMARY KEY
);


ALTER TABLE public.processqueue OWNER TO dbsvradmin;

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


--
-- Data for Name: assignment; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public.assignment (canvasid, groupid, courseid, name, pointspossible, id) FROM stdin;
49581136	12490125	10281506	How This Course is Organized	0	\N
49581144	12490125	10281506	It's time to shine!	100	\N
49581145	12490125	10281506	Learning Styles	100	\N
49581143	12490125	10281506	How to study	100	\N
49581135	12490125	10281506	Cultural Competency in Healthcare	100	\N
49581116	12490125	10281506	Orientation Discussion Forum	100	\N
49581142	12490125	10281506	How to navigate Canvas	0	\N
49581121	12490126	10281506	By Monday- Chapter 1: Cardiac Anatomy and Physiology	10	\N
49581147	12490126	10281506	On Monday- Chapter 1: Video Lecture	50	\N
49581112	12490126	10281506	Video Lecture: Quiz 1	15	\N
49581128	12490127	10281506	By Tuesday- Chapter 2 Electrophysiology: Reading Assignment 	10	\N
49581155	12490127	10281506	On Tuesday- Chapter 2: Video Lecture	50	\N
49581113	12490127	10281506	Video Lecture: Quiz 2  	30	\N
49581125	12490127	10281506	By Thursday- Chapter 4: Technical Aspects of the EKG	10	\N
49581152	12490127	10281506	On Thursday- Chapter 4: Video Lecture	50	\N
49581108	12490127	10281506	Video Lecture: Quiz 4	15	\N
49581106	12490127	10281506	Midterm Exam	200	\N
49581131	12490128	10281506	By Wednesday- Chapter 3 Lead Morphology and Placement: Reading Assignment	10	\N
49581158	12490128	10281506	On Wednesday- Chapter 3: Video Lecture	50	\N
49581100	12490128	10281506	Video Lecture: Quiz 3 	15	\N
49581141	12490128	10281506	How to Perform a 12-Lead EKG	10	\N
49581124	12490128	10281506	By Thursday- Chapter 17: Diagnostic Electrocardiography	10	\N
49581151	12490128	10281506	On Thursday- Chapter 17: Video Quiz	50	\N
49581102	12490128	10281506	Video Lecture Quiz 17	15	\N
49581123	12490129	10281506	By Monday-Chapter 5: Calculating Heart Rate	10	\N
49581150	12490129	10281506	On Monday- Video Lecture Chapter 5: Calculating Heart Rate	50	\N
49581117	12490129	10281506	How to Calculate the Heart Rate Using the 6 Second Method	100	\N
49581119	12490129	10281506	How to Calculate the Heart Rate Using the Little Block Method (1500 Method)	100	\N
49581118	12490129	10281506	How to Calculate the Heart Rate Using the Memory Method (Sequence Method)	100	\N
49581129	12490129	10281506	By Tuesday- Chapter 6: How to Interpret Rhythm Strips	10	\N
49581156	12490129	10281506	On Tuesday- Chapter 6: Video Lecture	50	\N
49581111	12490129	10281506	Video Lecture Quiz 5-6	23	\N
49581132	12490129	10281506	By Wednesday- Chapter 7: Rhythms Originating in the Sinus Node	10	\N
49581159	12490129	10281506	On Wednesday- Chapter 7: Video Lecture	50	\N
49581114	12490129	10281506	Video Lecture Quiz 7	15	\N
49581133	12490129	10281506	By Wednesday/Thursday: Midterm Exam : Chapters 1 thru 6 Material Review	100	\N
49581126	12490129	10281506	By Thursday- Chapter 8: Rhythms Originating in the Atria	10	\N
49581153	12490129	10281506	On Thursday- Chapter 8: Video Lecture	50	\N
49581110	12490129	10281506	Video Lecture Quiz 8	15	\N
49581122	12490129	10281506	By Monday- Chapter 9: Rhythms Originating in the AV Junction	10	\N
49581149	12490129	10281506	On Monday- Chapter 9 Video Lecture	50	\N
49581104	12490129	10281506	Video Lecture Quiz 9	12	\N
49581127	12490129	10281506	By Tuesday- Chapter 10: Rhythms Originating in the Ventricles	10	\N
49581154	12490129	10281506	On Tuesday- Chapter 10 Video Lecture	50	\N
49581101	12490129	10281506	Video Lecture Quiz 10	15	\N
49581130	12490129	10281506	By Wednesday- Chapter 11: AV Blocks	10	\N
49581157	12490129	10281506	On Wednesday- Chapter 11 Video Lecture	50	\N
49581103	12490129	10281506	Video Lecture Quiz 11	15	\N
49581105	12490129	10281506	By Friday- EKG Strip Interpretation	14	\N
49581146	12490129	10281506	NHA PRACTICE EXAM	100	\N
49581139	12490129	10281506	How to Calculate the Heart Rate Using the Memory Method (Sequence Method)	50	\N
49581138	12490129	10281506	How to Calculate the Heart Rate Using the Little Block Method (1500 Method)	50	\N
49581137	12490129	10281506	How to Calculate the Heart Rate Using the 6 Second Method	50	\N
49581160	12490130	10281506	Roll Call Attendance	100	\N
49581109	12490130	10281506	Unnamed Quiz	2	\N
50221440	12677613	10441987	IT'S TIME TO SHINE	100	\N
50221434	12677613	10441987	Cultural Competency in Healthcare	100	\N
50221441	12677613	10441987	Learning Styles	100	\N
50221439	12677613	10441987	How to study	100	\N
50221433	12677613	10441987	ABOUT YOUR NHA CERTIFICATION	100	\N
50221400	12677613	10441987	Unit Quiz 5 (📚 Ch 27, 33, 34, 35) 🎯	75	\N
50221431	12677613	10441987	Orientation Discussion Forum	100	\N
50796563	12677613	10441987	LECTURE: Chapter 47: Hematology	10	\N
50221407	12677614	10441987	📚 UNIT 1 QUIZ (📖 Ch 1, 2, 3, 4, 5) ✅	75	\N
50264884	12677614	10441987	READING- Chapter 5: Communication	10	\N
50278945	12677614	10441987	READING- Chapter 21: The Integumentary System	10	\N
50221429	12677614	10441987	LECTURE- Chapter 1: Medical Assisting: The Profession 	10	\N
50221463	12677614	10441987	READING- Chapter 3: Law and Ethics	10	\N
50221470	12677614	10441987	READING- Chapter 1: Medical Assisting the Profession	10	\N
50221471	12677614	10441987	READING- Chapter 2: Medical Science: History and Practice	10	\N
50221472	12677614	10441987	READING- Chapter 4: Medical Terminology	10	\N
50221428	12677614	10441987	LECTURE- Chapter 4: Medical Terminology 	10	\N
50221427	12677614	10441987	LECTURE- Chapter 2: Medical Science: History and Practice 	10	\N
50221416	12677615	10441987	📝 Unit 2 Quiz - 📚 Ch 20, 21, 22, 23	75	\N
50221397	12677615	10441987	📚Unit Quiz 3 - (Ch 24, 25, 26, 28) ✍️💡               	75	\N
50221402	12677615	10441987	Unit Quiz 4 (Ch 29, 30, 31, 32) 📚📝💡	75	\N
50221464	12677615	10441987	READING- Chapter 20: Body Structure and Function	10	\N
50221465	12677615	10441987	READING- Chapter 22: The Skeletal System and Chapter 23: The Muscular System	10	\N
50221466	12677615	10441987	READING- Chapter 24: The Nervous System	10	\N
50221401	12677615	10441987	Mid Term Exam 1 (📚 Ch 1-5, 🔢 20-35)	75	\N
50221467	12677615	10441987	READING- Chapter 26: The Circulatory System	10	\N
50221468	12677615	10441987	READING- Chapter 29: Digestive System	10	\N
50221469	12677615	10441987	READING- Chapter 31: Endocrine System	10	\N
50221443	12677615	10441987	READING- Chapter 27: Immune System	10	\N
50221445	12677615	10441987	READING- Chapter 36: Assisting with Medical Specialties	10	\N
50221446	12677615	10441987	READING- Chapter 38: Assisting w/ Eye and Ear Care	10	\N
50221473	12677615	10441987	Unit Quiz 3 Review	0	\N
50282660	12677615	10441987	LECTURE: Ch. 21 Integumentary (Skin) Assessment	10	\N
50303040	12677615	10441987	📚 LECTURE Review and Objectives for Chapter 20-23 Quiz 2 📝	10	\N
50307640	12677615	10441987	READING- Chapter 25: Senses	10	\N
50308276	12677615	10441987	READING- Chapter 28: Respiratory System	10	\N
50533097	12677615	10441987	READING- Chapter 30: Urinary System	10	\N
50534436	12677615	10441987	READING- Chapter 32: Reproductive System	10	\N
50307917	12677615	10441987	LECTURE- Chapter 25: Senses	10	\N
50308881	12677615	10441987	LECTURE:  Ch. 26: Cardiovascular System	10	\N
50526384	12677615	10441987	LECTURE: Ch. 28: Respiratory System	10	\N
50529356	12677615	10441987	📝 LECTURE Review and Objectives for Chapters 24-26, 28 📚 Quiz 3 🎯	10	\N
50533979	12677615	10441987	LECTURE:  Ch 30 Urinary System	10	\N
50534003	12677615	10441987	LECTURE:  Ch 29 Digestive System	10	\N
50534575	12677615	10441987	LECTURE: Ch 31 Endocrine System	10	\N
50534641	12677615	10441987	LECTURE: Ch 32 Reproductive System 	10	\N
50535407	12677615	10441987	📚 LECTURE Review and Objectives for Chapters 29-32 📖 Quiz 4 	10	\N
50536748	12677615	10441987	LECTURE:  Ch 27 Immune System 	10	\N
50537346	12677615	10441987	📚 Study Guide and Lecture Review for Midterm Exam 1 (CHAPTERS: 1-5 📖 AND 20-35 🩺)	10	\N
50549429	12677615	10441987	READING- Chapter 37: Assisting w/ Reproductive and Urinary Specialties	10	\N
50221444	12677616	10441987	READING- Chapter 34: Vital Signs	10	\N
50221447	12677616	10441987	READING- Chapter 40: Assisting w/ Life Span Specialties: Geriatrics	10	\N
50221448	12677616	10441987	READING- Chapter 42: Assisting w/ Medical Emergencies and Emergency Preparedness	10	\N
50221399	12677616	10441987	Unit Quiz 6 📚 (Ch 36, 37, 38, 39) ✏️	75	\N
50221418	12677616	10441987	📚Unit Quiz 7 (Ch 📖 40, 41, 42, 43) 📝	75	\N
50221404	12677616	10441987	🎯📚 Unit Quiz 9 📖 (Ch 📘48, 📘49, 📘50, 📘51) ✅	75	\N
50221423	12677616	10441987	📘✏️ AA Unit Quiz 10 (📖 Ch 54-57) 🔍	75	\N
50221406	12677616	10441987	📚 B Mid Term Test 2 📖 (Ch 52 - 57) ✅	75	\N
50221474	12677616	10441987	Unit Quiz 5 Review (Ch 27, 33, 34, 35)	10	\N
50221451	12677616	10441987	READING- Chapter 48: Radiology and Diagnostic Testing	10	\N
50221452	12677616	10441987	READING- Chapter 50: Pulmonary Function	10	\N
50221454	12677616	10441987	READING- Chapter 54: Administering Medication	10	\N
50221455	12677616	10441987	READING- Chapter 56: Nutrition	10	\N
50535868	12677616	10441987	READING- Chapter 33: Infection Control	10	\N
50536856	12677616	10441987	READING- Chapter 35: Physical Exams	10	\N
50221475	12677616	10441987	📚 Lecture Review and Objectives for Chapters 27, 33-35 📝 Quiz 5 🎯	10	\N
50536774	12677616	10441987	LECTURE: Ch 33 Infection Control	10	\N
50536948	12677616	10441987	LECTURE: Ch 35 Physical Exams  	10	\N
50536993	12677616	10441987	LECTURE: Ch 34 Vital Signs	10	\N
50549700	12677616	10441987	LECTURE- Ch 36: Assisting w/ Medical Specialties 	10	\N
50549799	12677616	10441987	LECTURE: Chapter 37: Assisting w/ Reproductive and Urinary Specialties	10	\N
50549934	12677616	10441987	LECTURE: Chapter 39: Assisting w/ Life Span Specialties: Pediatrics  	10	\N
50550563	12677616	10441987	LECTURE: Chapter 38: Assisting w/ Eye and Ear Care	10	\N
50549431	12677616	10441987	READING- Chapter 39: Assisting w/ Life Span Specialties: Pediatrics	10	\N
50551228	12677616	10441987	📚 LECTURE Review & Objectives for Ch. 36-39 📖 | Quiz 6 Review 📝	10	\N
50551393	12677616	10441987	READING-  Chapter 41: Assisting w/ Minor Surgery	10	\N
50551535	12677616	10441987	LECTURE: Chapter 40: Assisting w/ Life Span Specialties: Geriatrics	10	\N
50552674	12677616	10441987	LECTURE:  Chapter 41: Assisting W/ Minor Surgery	10	\N
50553300	12677616	10441987	LECTURE:  Chapter 42: Assisting with Medical Emergencies and Emergency Preparedness	10	\N
50555452	12677616	10441987	📚 LECTURE Review & Objectives for Chapters 40-43 Quiz 7 📝	10	\N
50796954	12677616	10441987	READING- Chapter 49: Electrocardiography	10	\N
51062236	12677616	10441987	LECTURE: Ch 48 Radiology 	10	\N
51062293	12677616	10441987	LECTURE:  Ch 49 ECG 	10	\N
51062998	12677616	10441987	READING- Chapter 51: Physical Therapy and Rehabilitation	10	\N
51063116	12677616	10441987	LECTURE: Ch 50 Pulmonary Function 	10	\N
51063837	12677616	10441987	LECTURE: Ch 51 Rehab & Therapy  	10	\N
51134420	12677616	10441987	 📚 Lecture Review & Objectives for Unit 9 Quiz 📝 (Ch 48-51)	10	\N
51155414	12677616	10441987	READING- Chapter 55: Patient Education	10	\N
51155422	12677616	10441987	READING-  Chapter 57: Mental Health	10	\N
51190382	12677616	10441987	LECTURE: Ch 54 Medication Administration	10	\N
51190424	12677616	10441987	LECTURE: Ch 55 Patient Education	10	\N
51190558	12677616	10441987	LECTURE: Ch 56 Nutrition 	10	\N
51190712	12677616	10441987	LECTURE: Ch 57 Mental Health	10	\N
51190932	12677616	10441987	📚✨ LECTURE REVIEW AND OBJECTIVES FOR CHAPTERS 54-57 ✍️📖	10	\N
50221413	12677617	10441987	📘 AA Unit Quiz 14 A (💊 Ch 52, 53) Pharmacology 🧪	30	\N
50221453	12677617	10441987	READING- Chapter 52: Math for Pharmacology	10	\N
51113541	12677617	10441987	READING- Chapter 53: Pharmacology	10	\N
29070963	1893067	1433500	THURSDAY	10	\N
51136548	12677617	10441987	LECTURE: Chapter 52: Math for Pharmacology	10	\N
51138764	12677617	10441987	LECTURE: Chapter 53 Introduction to Pharmacology Lecture, Material, and Activities	10	\N
51139255	12677617	10441987	📘✍️ Unit Quiz 14A - 🔍📖 Review Ch 52 & 53 📚✅	10	\N
50212577	12675524	10440316	IT'S TIME TO SHINE	100	\N
50212574	12675524	10440316	Cultural Competency in Healthcare	100	\N
50212578	12675524	10440316	Learning Styles	100	\N
50212576	12675524	10440316	How to study	100	\N
50212571	12675524	10440316	ABOUT YOUR NHA CERTIFICATION	100	\N
50212581	12675524	10440316	THE TEN COMMANDMENTS OF PHLEBOTOMY	0	\N
50212572	12675524	10440316	AVOIDING PHLEBOTOMY LAWSUITS	0	\N
50212575	12675524	10440316	Friday's Google Meets LInk	0	\N
50212569	12675525	10440316	Medical Terminology, Anatomy, and Physiology of Organ Systems: Homework Assignment #5	73	\N
50212554	12675525	10440316	The Cardiovascular and Lymphatic System : Homework Assignment #6	72	\N
50212560	12675525	10440316	WEEK ONE EXAM	60	\N
50212562	12675526	10440316	Blood Collection Equipment: Homework Assignment #1	70	\N
50212566	12675526	10440316	Infection Control:  Homework Assignment #7	75	\N
50212559	12675526	10440316	Capillary or Dermal Blood Specimens: Homework Assignment #8	69	\N
50212558	12675526	10440316	Venipuncture Procedures: Homework Assignment #9	73	\N
50212553	12675526	10440316	Preexamination/Preanaytical Complications: Homework Assignment #10	85	\N
50212551	12675526	10440316	Safety and First Aid: Homework Assignment #11	75	\N
50212557	12675526	10440316	Pediatric and Geriatric Procedures: Homework #13	75	\N
50212550	12675526	10440316	Point-of Care collections: Homework #14	75	\N
50212555	12675526	10440316	WEEK TWO EXAM	60	\N
50212580	12675526	10440316	NHA PRACTICE EXAM	100	\N
50212565	12675527	10440316	Specimen Handling, Transportation, and Processing: Homework #12	70	\N
50212552	12675527	10440316	Blood Cultures, Arterial, Intravenous (IV), and Special Collection Procedures: Homework #15	85	\N
50212563	12675527	10440316	Urinalysis, Body Fluids, and Other Specimens: Homework # 16	75	\N
50212568	12675527	10440316	Drug use, Forensic Toxicology, Workplace Testing, Sports Medicine, and Related Areas: Homework Assignment #17	84	\N
50212579	12675527	10440316	NHA PRACTICE EXAM	100	\N
50212564	12675528	10440316	Phlebotomy Practice and Quality Assessment: Homework Assignment #2	69	\N
50212570	12675528	10440316	Communication, Computer Essentials, and Documentation: Homework Assignment #3	80	\N
50212556	12675528	10440316	Professional Ethics, Legal, and Regulatory Issues:  Homework Assignment #4	76	\N
50212573	12675529	10440316	Attendance/Log-in	100	\N
50818461	12882551	10627765	IT'S TIME TO SHINE	100	\N
50818458	12882551	10627765	Cultural Competency in Healthcare	100	\N
50818462	12882551	10627765	Learning Styles	100	\N
50818460	12882551	10627765	How to study	100	\N
50818454	12882551	10627765	ABOUT YOUR NHA CERTIFICATION	100	\N
50818465	12882551	10627765	THE TEN COMMANDMENTS OF PHLEBOTOMY	0	\N
50818455	12882551	10627765	AVOIDING PHLEBOTOMY LAWSUITS	0	\N
50818459	12882551	10627765	Friday's Google Meets LInk	0	\N
50818446	12882552	10627765	Medical Terminology, Anatomy, and Physiology of Organ Systems: Homework Assignment #5	73	\N
50818438	12882552	10627765	The Cardiovascular and Lymphatic System : Homework Assignment #6	72	\N
50818449	12882552	10627765	WEEK ONE EXAM	60	\N
50818441	12882553	10627765	Blood Collection Equipment: Homework Assignment #1	70	\N
50818450	12882553	10627765	Infection Control:  Homework Assignment #7	75	\N
50818453	12882553	10627765	Capillary or Dermal Blood Specimens: Homework Assignment #8	69	\N
50818440	12882553	10627765	Venipuncture Procedures: Homework Assignment #9	73	\N
50818442	12882553	10627765	Preexamination/Preanaytical Complications: Homework Assignment #10	85	\N
50818444	12882553	10627765	Safety and First Aid: Homework Assignment #11	75	\N
50818433	12882553	10627765	Pediatric and Geriatric Procedures: Homework #13	75	\N
50818448	12882553	10627765	Point-of Care collections: Homework #14	75	\N
50818445	12882553	10627765	WEEK TWO EXAM	60	\N
50818464	12882553	10627765	NHA PRACTICE EXAM	100	\N
50818431	12882554	10627765	Specimen Handling, Transportation, and Processing: Homework #12	70	\N
50818443	12882554	10627765	Blood Cultures, Arterial, Intravenous (IV), and Special Collection Procedures: Homework #15	85	\N
50818435	12882554	10627765	Urinalysis, Body Fluids, and Other Specimens: Homework # 16	75	\N
50818439	12882554	10627765	Drug use, Forensic Toxicology, Workplace Testing, Sports Medicine, and Related Areas: Homework Assignment #17	84	\N
50818463	12882554	10627765	NHA PRACTICE EXAM	100	\N
50818452	12882555	10627765	Phlebotomy Practice and Quality Assessment: Homework Assignment #2	69	\N
50818432	12882555	10627765	Communication, Computer Essentials, and Documentation: Homework Assignment #3	80	\N
50818437	12882555	10627765	Professional Ethics, Legal, and Regulatory Issues:  Homework Assignment #4	76	\N
50818456	12882556	10627765	Attendance/Log-in	100	\N
23544790	2941903	1977977	IT'S TIME TO SHINE	100	\N
23544788	2941903	1977977	Cultural Competency in Healthcare	100	\N
23544791	2941903	1977977	Learning Styles	100	\N
23544789	2941903	1977977	How to study	100	\N
23544787	2941903	1977977	ABOUT YOUR NHA CERTIFICATION	100	\N
19795699	2941903	1977977	Unit Quiz 5 (Ch 27, 33, 34, 35)   	75	\N
42493940	2941903	1977977	Orientation Discussion Forum	100	\N
50206396	2941903	1977977	LECTURE- Chapter 1: Medical Assisting: The Profession 	10	\N
16829800	11116032	1977977	 Unit Quiz 1  (Ch 1, 2, 3  4, ,5)       	75	\N
47578258	11116032	1977977	READING- Chapter 1: Medical Assisting the Profession	10	\N
47578545	11116032	1977977	READING- Chapter 2: Medical Science: History and Practice	10	\N
47582382	11116032	1977977	READING ASSIGNMENT #3	10	\N
50200385	11116032	1977977	READING- Chapter 4: Medical Terminology	10	\N
50206302	11116032	1977977	LECTURE- Chapter 4: Medical Terminology 	10	\N
50207826	11116032	1977977	LECTURE- Chapter 2: Medical Science: History and Practice 	10	\N
17054141	11116038	1977977	A Unit Quiz 2 -  Ch 20, 21, 22, 23  	75	\N
17262713	11116038	1977977	A Unit Quiz 3 - (Ch 24,25,26,28)                  	75	\N
17289224	11116038	1977977	A Unit Quiz 4  (Ch 29, 30, 31, 32)  	75	\N
47582536	11116038	1977977	READING ASSIGNMENT #4	10	\N
47582657	11116038	1977977	READING ASSIGNMENT #5	10	\N
47582771	11116038	1977977	READING ASSIGNMENT #6	10	\N
17579303	11116038	1977977	B Mid Term Test 1 (Ch 1-5, 20-35)  	75	\N
47636276	11116038	1977977	READING ASSIGNMENT #7	10	\N
47830217	11116038	1977977	READING ASSIGNMENT #8	10	\N
47830656	11116038	1977977	READING ASSIGNMENT #9	10	\N
47831072	11116038	1977977	READING ASSIGNMENT #10	10	\N
48200077	11116038	1977977	READING ASSIGNMENT #12	10	\N
48201323	11116038	1977977	READING ASSIGNMENT #13	10	\N
47829934	11116038	1977977	Unit Quiz 3 Review	0	\N
47831152	11116042	1977977	READING ASSIGNMENT #11	10	\N
48446301	11116042	1977977	READING ASSIGNMENT #14	10	\N
48484467	11116042	1977977	READING ASSIGNMENT #15	10	\N
48484484	11116042	1977977	READING ASSIGNMENT #16	10	\N
17727831	11116042	1977977	A Unit Quiz 6 (Ch 36, 37, 38, 39)    	75	\N
17865206	11116042	1977977	A Unit Quiz 7 (Ch 40, 41, 42, 43)   	75	\N
17866279	11116042	1977977	A Unit Quiz 8   (Ch 44, 45, 46, 47)   	75	\N
17973550	11116042	1977977	AA Unit Quiz  9 (Ch 48, 49, 50, 51)   	75	\N
18145198	11116042	1977977	AA Unit Quiz 10   (Ch 54-57)  	75	\N
18266622	11116042	1977977	B Mid Term Test 2 (Ch 36 - 57) 	75	\N
47831698	11116042	1977977	Unit Quiz 5 Review (Ch 27, 33, 34, 35)	10	\N
48484549	11116042	1977977	READING ASSIGNMENT #17	10	\N
48484575	11116042	1977977	READING ASSIGNMENT #18	10	\N
48484738	11116042	1977977	READING ASSIGNMENT #19	10	\N
48485085	11116042	1977977	READING ASSIGNMENT #21	10	\N
48485886	11116042	1977977	READING ASSIGNMENT #22	10	\N
15505306	11116044	1977977	AA Unit Quiz 14 A (Ch 52, 53)  Pharmacology   	30	\N
48484887	11116044	1977977	READING ASSIGNMENT #20	10	\N
17973993	11116036	1977977	AA Unit Quiz 11    (Ch 6, 7, 8, 9, 10) 	75	\N
18387809	11116036	1977977	AA Unit Quiz 12 (Ch 11, 12, 13, 14, 15)  	75	\N
18491677	11116036	1977977	AA Unit Quiz 13 (Ch 16, 17, 18, 19)    	60	\N
17974440	11116036	1977977	Mid Term Test  3  (Ch 6-19,49,58,59)  	75	\N
48485141	11116036	1977977	READING ASSIGNMENT #23	10	\N
48485788	11116036	1977977	READING ASSIGNMENT #24	10	\N
49167489	11116036	1977977	READING ASSIGNMENT #25	10	\N
49167611	11116036	1977977	READING ASSIGNMENT #26	10	\N
49167880	11116036	1977977	READING ASSIGNMENT #27	10	\N
49168316	11116036	1977977	READING ASSIGNMENT #28	10	\N
17974112	11116067	1977977	AA Unit Quiz 14B (Ch 58,59)   	30	\N
17974327	11116067	1977977	N Final Exam (End of Course)                NHA Practice	100	\N
49168596	11116067	1977977	READING ASSIGNMENT #29	10	\N
49186722	11878340	1977977	How This Course is Organized	0	\N
49173220	11878340	1977977	How to navigate Canvas	0	\N
50548012	11878340	1977977	Video Lecture Quiz 17	0	\N
48199644	11878340	1977977	Unit Quiz 5 Review (Ch 27, 33, 34, 35)	10	\N
28307316	3771679	1526010	Cultural Competency in Healthcare	100	\N
20748276	3771679	1526010	Learning Styles	100	\N
20748272	3771679	1526010	How to study	100	\N
20748275	3771679	1526010	It's time to shine!	100	\N
23178963	3771679	1526010	NHA PRACTICE EXAM	100	\N
27173680	3771679	1526010	On Tuesday- Chapter 1: Video Lecture	50	\N
27173649	3771679	1526010	Video Lecture: Quiz 1	15	\N
27175827	3771679	1526010	By Wednesday- Chapter 2 Electrophysiology: Reading Assignment 	10	\N
27176290	3771679	1526010	On Wednesday- Chapter 2: Video Lecture	50	\N
27182734	3771679	1526010	Video Lecture: Quiz 2  	30	\N
27225890	3771679	1526010	By Thursday- Chapter 3 Lead Morphology and Placement: Reading Assignment	10	\N
27226180	3771679	1526010	On Thursday- Chapter 3: Video Lecture	50	\N
27281660	3771679	1526010	Video Lecture: Quiz 3 	15	\N
28265266	3771679	1526010	How to Perform a 12-Lead EKG	10	\N
27173136	3771679	1526010	By Tuesday- Chapter 1: Cardiac Anatomy and Physiology	10	\N
28365356	3771679	1526010	By Friday- Chapter 4: Technical Aspects of the EKG	10	\N
28365378	3771679	1526010	On Friday- Chapter 4: Video Lecture	50	\N
28365438	3771679	1526010	Video Lecture: Quiz 4	15	\N
28366498	3771679	1526010	On Tuesday- Chapter 4: Homework 	35	\N
28366792	3771679	1526010	By Monday-Chapter 5: Calculating Heart Rate	10	\N
28366915	3771679	1526010	On Monday- Video Lecture Chapter 5: Calculating Heart Rate	50	\N
28368366	3771679	1526010	How to Calculate the Heart Rate Using the Memory Method (Sequence Method)	50	\N
28368487	3771679	1526010	How to Calculate the Heart Rate Using the Little Block Method (1500 Method)	50	\N
28368541	3771679	1526010	How to Calculate the Heart Rate Using the 6 Second Method	50	\N
28369014	3771679	1526010	By Monday- Chapter 6: How to Interpret Rhythm Strips	10	\N
28369090	3771679	1526010	On Monday- Chapter 6: Video Lecture	50	\N
28369146	3771679	1526010	On Thursday- Chapter 6: Homework 	38	\N
28426946	3771679	1526010	Video Lecture Quiz 5-6	23	\N
28428141	3771679	1526010	By Tuesday- Chapter 7: Rhythms Originating in the Sinus Node	10	\N
28428264	3771679	1526010	On Tuesday- Chapter 7: Video Lecture	50	\N
28428950	3771679	1526010	By Wednesday: Midterm Exam : Chapters 1 thru 6 Material Review	100	\N
28429269	3771679	1526010	Orientation Discussion Forum	100	\N
28478158	3771679	1526010	Wednesday- Chapter 8: Rhythms Originating in the Atria	10	\N
28481068	3771679	1526010	On Wednesday- Chapter 8: Video Lecture	50	\N
28483543	3771679	1526010	Video Lecture Quiz 7	15	\N
28488080	3771679	1526010	Video Lecture Quiz 8	15	\N
28488171	3771679	1526010	Video Lecture Quiz 9	12	\N
28488215	3771679	1526010	Video Lecture Quiz 10	15	\N
28488293	3771679	1526010	Video Lecture Quiz 11	15	\N
28488409	3771679	1526010	Video Lecture Quiz 17	15	\N
28534530	3771679	1526010	By Thursday- Chapter 9: Rhythms Originating in the AV Junction	10	\N
28534542	3771679	1526010	By Friday- Chapter 10: Rhythms Originating in the Ventricles	10	\N
28534551	3771679	1526010	By Monday- Chapter 11: AV Blocks	10	\N
28534569	3771679	1526010	By Tuesday- Chapter 17: Diagnostic Electrocardiography	10	\N
28535185	3771679	1526010	On Thursday- Chapter 9 Video Lecture	50	\N
28535193	3771679	1526010	On Friday- Chapter 10 Video Lecture	50	\N
28535196	3771679	1526010	On Monday- Chapter 11 Video Lecture	50	\N
28558886	3771679	1526010	EKG Strip Interpretation	14	\N
28595293	3771679	1526010	By Tuesday- Chapter 17: Video Quiz	50	\N
28625655	3771679	1526010	Roll Call Attendance	100	\N
43983149	10724345	8690806	By Tuesday- Chapter 2 Electrophysiology: Reading Assignment 	10	\N
43983143	10724345	8690806	By Wednesday- Chapter 3 Lead Morphology and Placement: Reading Assignment	10	\N
43983147	10724345	8690806	By Monday- Chapter 1: Cardiac Anatomy and Physiology	10	\N
43983138	10724345	8690806	By Thursday- Chapter 4: Technical Aspects of the EKG	10	\N
43983140	10724345	8690806	By Tuesday- Chapter 6: How to Interpret Rhythm Strips	10	\N
43983148	10724345	8690806	By Wednesday- Chapter 7: Rhythms Originating in the Sinus Node	10	\N
43983150	10724345	8690806	By Wednesday/Thursday: Midterm Exam : Chapters 1 thru 6 Material Review	100	\N
43983135	10724345	8690806	Orientation Discussion Forum	100	\N
43983177	10724345	8690806	By Thursday- Chapter 8: Rhythms Originating in the Atria	10	\N
43983144	10724345	8690806	By Monday- Chapter 9: Rhythms Originating in the AV Junction	10	\N
43983136	10724345	8690806	By Tuesday- Chapter 10: Rhythms Originating in the Ventricles	10	\N
43983139	10724345	8690806	By Wednesday- Chapter 11: AV Blocks	10	\N
43983145	10724345	8690806	By Thursday- Chapter 17: Diagnostic Electrocardiography	10	\N
43987317	10724345	8690806	How This Course is Organized	0	\N
43983171	10873923	8690806	On Monday- Chapter 1: Video Lecture	50	\N
43983174	10873923	8690806	On Tuesday- Chapter 2: Video Lecture	50	\N
43983167	10873923	8690806	On Wednesday- Chapter 3: Video Lecture	50	\N
43983156	10873923	8690806	How to Perform a 12-Lead EKG	10	\N
43983163	10873923	8690806	On Thursday- Chapter 4: Video Lecture	50	\N
43983142	10873923	8690806	By Monday-Chapter 5: Calculating Heart Rate	10	\N
43983166	10873923	8690806	On Monday- Video Lecture Chapter 5: Calculating Heart Rate	50	\N
43987059	10873923	8690806	How to Calculate the Heart Rate Using the 6 Second Method	100	\N
43987106	10873923	8690806	How to Calculate the Heart Rate Using the Little Block Method (1500 Method)	100	\N
43987078	10873923	8690806	How to Calculate the Heart Rate Using the Memory Method (Sequence Method)	100	\N
43983155	10873923	8690806	How to Calculate the Heart Rate Using the Memory Method (Sequence Method)	50	\N
43983154	10873923	8690806	How to Calculate the Heart Rate Using the Little Block Method (1500 Method)	50	\N
43983152	10873923	8690806	How to Calculate the Heart Rate Using the 6 Second Method	50	\N
43983165	10873923	8690806	On Tuesday- Chapter 6: Video Lecture	50	\N
43983173	10873923	8690806	On Wednesday- Chapter 7: Video Lecture	50	\N
43983175	10873923	8690806	On Thursday- Chapter 8: Video Lecture	50	\N
43983170	10873923	8690806	On Monday- Chapter 9 Video Lecture	50	\N
43983162	10873923	8690806	On Tuesday- Chapter 10 Video Lecture	50	\N
43983164	10873923	8690806	On Wednesday- Chapter 11 Video Lecture	50	\N
43983146	10873923	8690806	On Thursday- Chapter 17: Video Quiz	50	\N
43983129	10873923	8690806	By Friday- EKG Strip Interpretation	14	\N
43983126	10873887	8690806	Video Lecture: Quiz 1	15	\N
43983122	10873887	8690806	Video Lecture: Quiz 2  	30	\N
43983125	10873887	8690806	Video Lecture: Quiz 3 	15	\N
43983131	10873887	8690806	Video Lecture: Quiz 4	15	\N
43983121	10873887	8690806	Video Lecture Quiz 5-6	23	\N
43983123	10873887	8690806	Video Lecture Quiz 7	15	\N
43983120	10873887	8690806	Video Lecture Quiz 8	15	\N
43983130	10873887	8690806	Video Lecture Quiz 9	12	\N
43983127	10873887	8690806	Video Lecture Quiz 10	15	\N
43983128	10873887	8690806	Video Lecture Quiz 11	15	\N
43983124	10873887	8690806	Video Lecture Quiz 17	15	\N
44031354	11017516	8690806	Midterm Exam	200	\N
43983161	11017516	8690806	NHA PRACTICE EXAM	100	\N
43983176	10874002	8690806	Roll Call Attendance	100	\N
43983158	11175912	8690806	It's time to shine!	100	\N
43983159	11175912	8690806	Learning Styles	100	\N
43983157	11175912	8690806	How to study	100	\N
43983151	11175912	8690806	Cultural Competency in Healthcare	100	\N
45969103	11449875	9366117	How This Course is Organized	0	\N
45969111	11449875	9366117	It's time to shine!	100	\N
45969112	11449875	9366117	Learning Styles	100	\N
45969110	11449875	9366117	How to study	100	\N
45969102	11449875	9366117	Cultural Competency in Healthcare	100	\N
45969086	11449875	9366117	Orientation Discussion Forum	100	\N
45969087	11449876	9366117	By Monday- Chapter 1: Cardiac Anatomy and Physiology	10	\N
45969117	11449876	9366117	On Monday- Chapter 1: Video Lecture	50	\N
45969082	11449876	9366117	Video Lecture: Quiz 1	15	\N
45969096	11637095	9366117	By Tuesday- Chapter 2 Electrophysiology: Reading Assignment 	10	\N
45969125	11637095	9366117	On Tuesday- Chapter 2: Video Lecture	50	\N
45969078	11637095	9366117	Video Lecture: Quiz 2  	30	\N
45969093	11637095	9366117	By Thursday- Chapter 4: Technical Aspects of the EKG	10	\N
45969122	11637095	9366117	On Thursday- Chapter 4: Video Lecture	50	\N
45969076	11637095	9366117	Video Lecture: Quiz 4	15	\N
45969069	11637095	9366117	Midterm Exam	200	\N
45969099	11637187	9366117	By Wednesday- Chapter 3 Lead Morphology and Placement: Reading Assignment	10	\N
45969128	11637187	9366117	On Wednesday- Chapter 3: Video Lecture	50	\N
45969068	11637187	9366117	Video Lecture: Quiz 3 	15	\N
45969109	11637187	9366117	How to Perform a 12-Lead EKG	10	\N
45969092	11637187	9366117	By Thursday- Chapter 17: Diagnostic Electrocardiography	10	\N
45969120	11637187	9366117	On Thursday- Chapter 17: Video Quiz	50	\N
45969080	11637187	9366117	Video Lecture Quiz 17	15	\N
45969091	11449870	9366117	By Monday-Chapter 5: Calculating Heart Rate	10	\N
45969119	11449870	9366117	On Monday- Video Lecture Chapter 5: Calculating Heart Rate	50	\N
45969085	11449870	9366117	How to Calculate the Heart Rate Using the 6 Second Method	100	\N
45969083	11449870	9366117	How to Calculate the Heart Rate Using the Little Block Method (1500 Method)	100	\N
45969084	11449870	9366117	How to Calculate the Heart Rate Using the Memory Method (Sequence Method)	100	\N
45969097	11449870	9366117	By Tuesday- Chapter 6: How to Interpret Rhythm Strips	10	\N
45969126	11449870	9366117	On Tuesday- Chapter 6: Video Lecture	50	\N
45969079	11449870	9366117	Video Lecture Quiz 5-6	23	\N
45969100	11449870	9366117	By Wednesday- Chapter 7: Rhythms Originating in the Sinus Node	10	\N
45969129	11449870	9366117	On Wednesday- Chapter 7: Video Lecture	50	\N
45969081	11449870	9366117	Video Lecture Quiz 7	15	\N
45969101	11449870	9366117	By Wednesday/Thursday: Midterm Exam : Chapters 1 thru 6 Material Review	100	\N
45969094	11449870	9366117	By Thursday- Chapter 8: Rhythms Originating in the Atria	10	\N
45969123	11449870	9366117	On Thursday- Chapter 8: Video Lecture	50	\N
45969077	11449870	9366117	Video Lecture Quiz 8	15	\N
45969089	11449870	9366117	By Monday- Chapter 9: Rhythms Originating in the AV Junction	10	\N
45969118	11449870	9366117	On Monday- Chapter 9 Video Lecture	50	\N
45969073	11449870	9366117	Video Lecture Quiz 9	12	\N
45969095	11449870	9366117	By Tuesday- Chapter 10: Rhythms Originating in the Ventricles	10	\N
45969124	11449870	9366117	On Tuesday- Chapter 10 Video Lecture	50	\N
45969071	11449870	9366117	Video Lecture Quiz 10	15	\N
45969098	11449870	9366117	By Wednesday- Chapter 11: AV Blocks	10	\N
45969127	11449870	9366117	On Wednesday- Chapter 11 Video Lecture	50	\N
45969075	11449870	9366117	Video Lecture Quiz 11	15	\N
45969070	11449870	9366117	By Friday- EKG Strip Interpretation	14	\N
45969116	11449870	9366117	NHA PRACTICE EXAM	100	\N
45969107	11449870	9366117	How to Calculate the Heart Rate Using the Memory Method (Sequence Method)	50	\N
45969105	11449870	9366117	How to Calculate the Heart Rate Using the Little Block Method (1500 Method)	50	\N
45969104	11449870	9366117	How to Calculate the Heart Rate Using the 6 Second Method	50	\N
45969130	11449874	9366117	Roll Call Attendance	100	\N
46169752	11449874	9366117	Unnamed Quiz	1	\N
46851900	11701948	9587445	How This Course is Organized	0	\N
46851906	11701948	9587445	It's time to shine!	100	\N
46851907	11701948	9587445	Learning Styles	100	\N
46851905	11701948	9587445	How to study	100	\N
46851899	11701948	9587445	Cultural Competency in Healthcare	100	\N
46851881	11701948	9587445	Orientation Discussion Forum	100	\N
46851885	11701949	9587445	By Monday- Chapter 1: Cardiac Anatomy and Physiology	10	\N
46851909	11701949	9587445	On Monday- Chapter 1: Video Lecture	50	\N
46851876	11701949	9587445	Video Lecture: Quiz 1	15	\N
46851892	11701950	9587445	By Tuesday- Chapter 2 Electrophysiology: Reading Assignment 	10	\N
46851916	11701950	9587445	On Tuesday- Chapter 2: Video Lecture	50	\N
46851875	11701950	9587445	Video Lecture: Quiz 2  	30	\N
46851889	11701950	9587445	By Thursday- Chapter 4: Technical Aspects of the EKG	10	\N
46851913	11701950	9587445	On Thursday- Chapter 4: Video Lecture	50	\N
46851869	11701950	9587445	Video Lecture: Quiz 4	15	\N
46851874	11701950	9587445	Midterm Exam	200	\N
46851896	11701951	9587445	By Wednesday- Chapter 3 Lead Morphology and Placement: Reading Assignment	10	\N
46851919	11701951	9587445	On Wednesday- Chapter 3: Video Lecture	50	\N
46851878	11701951	9587445	Video Lecture: Quiz 3 	15	\N
46851904	11701951	9587445	How to Perform a 12-Lead EKG	10	\N
46851888	11701951	9587445	By Thursday- Chapter 17: Diagnostic Electrocardiography	10	\N
46851912	11701951	9587445	On Thursday- Chapter 17: Video Quiz	50	\N
46851877	11701951	9587445	Video Lecture Quiz 17	15	\N
46851887	11701952	9587445	By Monday-Chapter 5: Calculating Heart Rate	10	\N
46851911	11701952	9587445	On Monday- Video Lecture Chapter 5: Calculating Heart Rate	50	\N
46851882	11701952	9587445	How to Calculate the Heart Rate Using the 6 Second Method	100	\N
46851884	11701952	9587445	How to Calculate the Heart Rate Using the Little Block Method (1500 Method)	100	\N
46851883	11701952	9587445	How to Calculate the Heart Rate Using the Memory Method (Sequence Method)	100	\N
46851893	11701952	9587445	By Tuesday- Chapter 6: How to Interpret Rhythm Strips	10	\N
46851917	11701952	9587445	On Tuesday- Chapter 6: Video Lecture	50	\N
46851867	11701952	9587445	Video Lecture Quiz 5-6	23	\N
46851897	11701952	9587445	By Wednesday- Chapter 7: Rhythms Originating in the Sinus Node	10	\N
46851920	11701952	9587445	On Wednesday- Chapter 7: Video Lecture	50	\N
46851873	11701952	9587445	Video Lecture Quiz 7	15	\N
46851898	11701952	9587445	By Wednesday/Thursday: Midterm Exam : Chapters 1 thru 6 Material Review	100	\N
29071109	1893067	1433500	MONDAY	10	\N
46851890	11701952	9587445	By Thursday- Chapter 8: Rhythms Originating in the Atria	10	\N
46851914	11701952	9587445	On Thursday- Chapter 8: Video Lecture	50	\N
46851879	11701952	9587445	Video Lecture Quiz 8	15	\N
46851886	11701952	9587445	By Monday- Chapter 9: Rhythms Originating in the AV Junction	10	\N
46851910	11701952	9587445	On Monday- Chapter 9 Video Lecture	50	\N
46851880	11701952	9587445	Video Lecture Quiz 9	12	\N
46851891	11701952	9587445	By Tuesday- Chapter 10: Rhythms Originating in the Ventricles	10	\N
46851915	11701952	9587445	On Tuesday- Chapter 10 Video Lecture	50	\N
46851870	11701952	9587445	Video Lecture Quiz 10	15	\N
46851894	11701952	9587445	By Wednesday- Chapter 11: AV Blocks	10	\N
46851918	11701952	9587445	On Wednesday- Chapter 11 Video Lecture	50	\N
46851871	11701952	9587445	Video Lecture Quiz 11	15	\N
46851868	11701952	9587445	By Friday- EKG Strip Interpretation	14	\N
46851908	11701952	9587445	NHA PRACTICE EXAM	100	\N
46851903	11701952	9587445	How to Calculate the Heart Rate Using the Memory Method (Sequence Method)	50	\N
46851902	11701952	9587445	How to Calculate the Heart Rate Using the Little Block Method (1500 Method)	50	\N
46851901	11701952	9587445	How to Calculate the Heart Rate Using the 6 Second Method	50	\N
46851921	11701953	9587445	Roll Call Attendance	100	\N
46851872	11701953	9587445	Unnamed Quiz	2	\N
49018829	12327473	10140155	How This Course is Organized	0	\N
49018835	12327473	10140155	It's time to shine!	100	\N
49018836	12327473	10140155	Learning Styles	100	\N
49018834	12327473	10140155	How to study	100	\N
49018828	12327473	10140155	Cultural Competency in Healthcare	100	\N
49018812	12327473	10140155	Orientation Discussion Forum	100	\N
49059815	12327473	10140155	How to navigate Canvas	0	\N
49018813	12327474	10140155	By Monday- Chapter 1: Cardiac Anatomy and Physiology	10	\N
49018838	12327474	10140155	On Monday- Chapter 1: Video Lecture	50	\N
49018802	12327474	10140155	Video Lecture: Quiz 1	15	\N
49018822	12327475	10140155	By Tuesday- Chapter 2 Electrophysiology: Reading Assignment 	10	\N
49018845	12327475	10140155	On Tuesday- Chapter 2: Video Lecture	50	\N
49018792	12327475	10140155	Video Lecture: Quiz 2  	30	\N
49018818	12327475	10140155	By Thursday- Chapter 4: Technical Aspects of the EKG	10	\N
49018842	12327475	10140155	On Thursday- Chapter 4: Video Lecture	50	\N
49018807	12327475	10140155	Video Lecture: Quiz 4	15	\N
49018791	12327475	10140155	Midterm Exam	200	\N
49018825	12327476	10140155	By Wednesday- Chapter 3 Lead Morphology and Placement: Reading Assignment	10	\N
49018848	12327476	10140155	On Wednesday- Chapter 3: Video Lecture	50	\N
49018790	12327476	10140155	Video Lecture: Quiz 3 	15	\N
49018833	12327476	10140155	How to Perform a 12-Lead EKG	10	\N
49018816	12327476	10140155	By Thursday- Chapter 17: Diagnostic Electrocardiography	10	\N
49018841	12327476	10140155	On Thursday- Chapter 17: Video Quiz	50	\N
49018794	12327476	10140155	Video Lecture Quiz 17	15	\N
49018815	12327477	10140155	By Monday-Chapter 5: Calculating Heart Rate	10	\N
49018840	12327477	10140155	On Monday- Video Lecture Chapter 5: Calculating Heart Rate	50	\N
49018811	12327477	10140155	How to Calculate the Heart Rate Using the 6 Second Method	100	\N
49018809	12327477	10140155	How to Calculate the Heart Rate Using the Little Block Method (1500 Method)	100	\N
49018810	12327477	10140155	How to Calculate the Heart Rate Using the Memory Method (Sequence Method)	100	\N
49018823	12327477	10140155	By Tuesday- Chapter 6: How to Interpret Rhythm Strips	10	\N
49018846	12327477	10140155	On Tuesday- Chapter 6: Video Lecture	50	\N
49018805	12327477	10140155	Video Lecture Quiz 5-6	23	\N
49018826	12327477	10140155	By Wednesday- Chapter 7: Rhythms Originating in the Sinus Node	10	\N
49018849	12327477	10140155	On Wednesday- Chapter 7: Video Lecture	50	\N
49018799	12327477	10140155	Video Lecture Quiz 7	15	\N
49018827	12327477	10140155	By Wednesday/Thursday: Midterm Exam : Chapters 1 thru 6 Material Review	100	\N
49018819	12327477	10140155	By Thursday- Chapter 8: Rhythms Originating in the Atria	10	\N
49018843	12327477	10140155	On Thursday- Chapter 8: Video Lecture	50	\N
49018804	12327477	10140155	Video Lecture Quiz 8	15	\N
49018814	12327477	10140155	By Monday- Chapter 9: Rhythms Originating in the AV Junction	10	\N
49018839	12327477	10140155	On Monday- Chapter 9 Video Lecture	50	\N
49018801	12327477	10140155	Video Lecture Quiz 9	12	\N
49018820	12327477	10140155	By Tuesday- Chapter 10: Rhythms Originating in the Ventricles	10	\N
49018844	12327477	10140155	On Tuesday- Chapter 10 Video Lecture	50	\N
49018797	12327477	10140155	Video Lecture Quiz 10	15	\N
49018824	12327477	10140155	By Wednesday- Chapter 11: AV Blocks	10	\N
49018847	12327477	10140155	On Wednesday- Chapter 11 Video Lecture	50	\N
49018800	12327477	10140155	Video Lecture Quiz 11	15	\N
49018803	12327477	10140155	By Friday- EKG Strip Interpretation	14	\N
49018837	12327477	10140155	NHA PRACTICE EXAM	100	\N
49018832	12327477	10140155	How to Calculate the Heart Rate Using the Memory Method (Sequence Method)	50	\N
49018831	12327477	10140155	How to Calculate the Heart Rate Using the Little Block Method (1500 Method)	50	\N
49018830	12327477	10140155	How to Calculate the Heart Rate Using the 6 Second Method	50	\N
49018850	12327478	10140155	Roll Call Attendance	100	\N
49018795	12327478	10140155	Unnamed Quiz	2	\N
49608485	12499369	10289455	How This Course is Organized	0	\N
49608498	12499369	10289455	It's time to shine!	100	\N
49608500	12499369	10289455	Learning Styles	100	\N
49608496	12499369	10289455	How to study	100	\N
49608484	12499369	10289455	Cultural Competency in Healthcare	100	\N
49608443	12499369	10289455	Orientation Discussion Forum	100	\N
49608495	12499369	10289455	How to navigate Canvas	0	\N
49608455	12499370	10289455	By Monday- Chapter 1: Cardiac Anatomy and Physiology	10	\N
49608505	12499370	10289455	On Monday- Chapter 1: Video Lecture	50	\N
49608427	12499370	10289455	Video Lecture: Quiz 1	15	\N
49608470	12499371	10289455	By Tuesday- Chapter 2 Electrophysiology: Reading Assignment 	10	\N
49608519	12499371	10289455	On Tuesday- Chapter 2: Video Lecture	50	\N
49608424	12499371	10289455	Video Lecture: Quiz 2  	30	\N
49608463	12499371	10289455	By Thursday- Chapter 4: Technical Aspects of the EKG	10	\N
49608514	12499371	10289455	On Thursday- Chapter 4: Video Lecture	50	\N
49608432	12499371	10289455	Video Lecture: Quiz 4	15	\N
49608426	12499371	10289455	Midterm Exam	200	\N
49608478	12499372	10289455	By Wednesday- Chapter 3 Lead Morphology and Placement: Reading Assignment	10	\N
49608524	12499372	10289455	On Wednesday- Chapter 3: Video Lecture	50	\N
49608428	12499372	10289455	Video Lecture: Quiz 3 	15	\N
49608493	12499372	10289455	How to Perform a 12-Lead EKG	10	\N
49608461	12499372	10289455	By Thursday- Chapter 17: Diagnostic Electrocardiography	10	\N
49608512	12499372	10289455	On Thursday- Chapter 17: Video Quiz	50	\N
49608418	12499372	10289455	Video Lecture Quiz 17	15	\N
49608459	12499373	10289455	By Monday-Chapter 5: Calculating Heart Rate	10	\N
49608509	12499373	10289455	On Monday- Video Lecture Chapter 5: Calculating Heart Rate	50	\N
49608446	12499373	10289455	How to Calculate the Heart Rate Using the 6 Second Method	100	\N
49608451	12499373	10289455	How to Calculate the Heart Rate Using the Little Block Method (1500 Method)	100	\N
49608449	12499373	10289455	How to Calculate the Heart Rate Using the Memory Method (Sequence Method)	100	\N
49608473	12499373	10289455	By Tuesday- Chapter 6: How to Interpret Rhythm Strips	10	\N
49608521	12499373	10289455	On Tuesday- Chapter 6: Video Lecture	50	\N
49608419	12499373	10289455	Video Lecture Quiz 5-6	23	\N
49608480	12499373	10289455	By Wednesday- Chapter 7: Rhythms Originating in the Sinus Node	10	\N
49608525	12499373	10289455	On Wednesday- Chapter 7: Video Lecture	50	\N
49608420	12499373	10289455	Video Lecture Quiz 7	15	\N
49608482	12499373	10289455	By Wednesday/Thursday: Midterm Exam : Chapters 1 thru 6 Material Review	100	\N
49608465	12499373	10289455	By Thursday- Chapter 8: Rhythms Originating in the Atria	10	\N
49608515	12499373	10289455	On Thursday- Chapter 8: Video Lecture	50	\N
49608421	12499373	10289455	Video Lecture Quiz 8	15	\N
49608457	12499373	10289455	By Monday- Chapter 9: Rhythms Originating in the AV Junction	10	\N
49608507	12499373	10289455	On Monday- Chapter 9 Video Lecture	50	\N
49608423	12499373	10289455	Video Lecture Quiz 9	12	\N
49608467	12499373	10289455	By Tuesday- Chapter 10: Rhythms Originating in the Ventricles	10	\N
49608517	12499373	10289455	On Tuesday- Chapter 10 Video Lecture	50	\N
49608436	12499373	10289455	Video Lecture Quiz 10	15	\N
49608475	12499373	10289455	By Wednesday- Chapter 11: AV Blocks	10	\N
49608523	12499373	10289455	On Wednesday- Chapter 11 Video Lecture	50	\N
49608430	12499373	10289455	Video Lecture Quiz 11	15	\N
49608434	12499373	10289455	By Friday- EKG Strip Interpretation	14	\N
49608503	12499373	10289455	NHA PRACTICE EXAM	100	\N
49608491	12499373	10289455	How to Calculate the Heart Rate Using the Memory Method (Sequence Method)	50	\N
49608489	12499373	10289455	How to Calculate the Heart Rate Using the Little Block Method (1500 Method)	50	\N
49608487	12499373	10289455	How to Calculate the Heart Rate Using the 6 Second Method	50	\N
49608526	12499374	10289455	Roll Call Attendance	100	\N
49608429	12499374	10289455	Unnamed Quiz	2	\N
48034320	12022297	9868740	How This Course is Organized	0	\N
48034326	12022297	9868740	It's time to shine!	100	\N
48034327	12022297	9868740	Learning Styles	100	\N
48034325	12022297	9868740	How to study	100	\N
48034319	12022297	9868740	Cultural Competency in Healthcare	100	\N
48034302	12022297	9868740	Orientation Discussion Forum	100	\N
48034304	12022298	9868740	By Monday- Chapter 1: Cardiac Anatomy and Physiology	10	\N
48034330	12022298	9868740	On Monday- Chapter 1: Video Lecture	50	\N
48034312	12022299	9868740	By Tuesday- Chapter 2 Electrophysiology: Reading Assignment 	10	\N
48034338	12022299	9868740	On Tuesday- Chapter 2: Video Lecture	50	\N
48034284	12022299	9868740	Video Lecture: Quiz 2  	30	\N
48034309	12022299	9868740	By Thursday- Chapter 4: Technical Aspects of the EKG	10	\N
48034334	12022299	9868740	On Thursday- Chapter 4: Video Lecture	50	\N
48034281	12022299	9868740	Video Lecture: Quiz 4	15	\N
48034316	12022300	9868740	By Wednesday- Chapter 3 Lead Morphology and Placement: Reading Assignment	10	\N
48034341	12022300	9868740	On Wednesday- Chapter 3: Video Lecture	50	\N
48034285	12022300	9868740	Video Lecture: Quiz 3 	15	\N
48034324	12022300	9868740	How to Perform a 12-Lead EKG	10	\N
48034307	12022300	9868740	By Thursday- Chapter 17: Diagnostic Electrocardiography	10	\N
48034333	12022300	9868740	On Thursday- Chapter 17: Video Quiz	50	\N
48034306	12022301	9868740	By Monday-Chapter 5: Calculating Heart Rate	10	\N
48034332	12022301	9868740	On Monday- Video Lecture Chapter 5: Calculating Heart Rate	50	\N
48034314	12022301	9868740	By Tuesday- Chapter 6: How to Interpret Rhythm Strips	10	\N
48034339	12022301	9868740	On Tuesday- Chapter 6: Video Lecture	50	\N
48034293	12022301	9868740	Video Lecture Quiz 5-6	23	\N
48034317	12022301	9868740	By Wednesday- Chapter 7: Rhythms Originating in the Sinus Node	10	\N
48034342	12022301	9868740	On Wednesday- Chapter 7: Video Lecture	50	\N
48034287	12022301	9868740	Video Lecture Quiz 7	15	\N
48034318	12022301	9868740	By Wednesday/Thursday: Midterm Exam : Chapters 1 thru 6 Material Review	100	\N
48053233	12028726	9874687	PhPrac 7e Ch08 Check Your Understanding	100	\N
48034310	12022301	9868740	By Thursday- Chapter 8: Rhythms Originating in the Atria	10	\N
48034335	12022301	9868740	On Thursday- Chapter 8: Video Lecture	50	\N
48034297	12022301	9868740	Video Lecture Quiz 8	15	\N
48034305	12022301	9868740	By Monday- Chapter 9: Rhythms Originating in the AV Junction	10	\N
48034331	12022301	9868740	On Monday- Chapter 9 Video Lecture	50	\N
48034292	12022301	9868740	Video Lecture Quiz 9	12	\N
48034311	12022301	9868740	By Tuesday- Chapter 10: Rhythms Originating in the Ventricles	10	\N
48034337	12022301	9868740	On Tuesday- Chapter 10 Video Lecture	50	\N
48034296	12022301	9868740	Video Lecture Quiz 10	15	\N
48034315	12022301	9868740	By Wednesday- Chapter 11: AV Blocks	10	\N
48034340	12022301	9868740	On Wednesday- Chapter 11 Video Lecture	50	\N
48034294	12022301	9868740	Video Lecture Quiz 11	15	\N
48034291	12022301	9868740	By Friday- EKG Strip Interpretation	14	\N
48034328	12022301	9868740	NHA PRACTICE EXAM	100	\N
48034323	12022301	9868740	How to Calculate the Heart Rate Using the Memory Method (Sequence Method)	50	\N
48034322	12022301	9868740	How to Calculate the Heart Rate Using the Little Block Method (1500 Method)	50	\N
48034321	12022301	9868740	How to Calculate the Heart Rate Using the 6 Second Method	50	\N
48034344	12022302	9868740	Roll Call Attendance	100	\N
48034295	12022302	9868740	Unnamed Quiz	2	\N
48040040	12022302	9868740	Retake Fee	0	\N
48040085	12022302	9868740	Retake Fee and additional NHA Practice exams	0	\N
50547839	12789679	9868740	Video Lecture Quiz 17	15	\N
50547659	12789679	9868740	Video Lecture Quiz 17	15	\N
48053160	12028718	9874687	Pharmacy Practice for Technicians 7e, eBook	10	\N
48053161	12028718	9874687	PhPrac 7e Glossary	10	\N
48053162	12028718	9874687	PhPrac 7e Additional Resources	10	\N
48053163	12028718	9874687	PhPrac 7e Instructor eResources	10	\N
48053164	12028719	9874687	PhPrac 7e Ch01 Watch and Learn Lessons	100	\N
48053165	12028719	9874687	PhPrac 7e Ch01 Check Your Understanding	100	\N
48053166	12028719	9874687	PhPrac 7e Ch01 Flash Cards	10	\N
48053167	12028719	9874687	PhPrac 7e Ch01 Short Answer	100	\N
48053168	12028719	9874687	PhPrac 7e Ch01 Apply the Concepts	100	\N
48053169	12028719	9874687	PhPrac 7e Ch01 Field Research Projects	10	\N
48053170	12028719	9874687	PhPrac 7e Ch01 Practice Test	100	\N
48053172	12028719	9874687	PhPrac 7e Ch01 Exam	10	\N
48053173	12028720	9874687	PhPrac 7e Ch02 Watch and Learn Lessons	100	\N
48053175	12028720	9874687	PhPrac 7e Ch02 Check Your Understanding	100	\N
48053176	12028720	9874687	PhPrac 7e Ch02 Flash Cards	10	\N
48053179	12028720	9874687	PhPrac 7e Ch02 Short Answer	100	\N
48053180	12028720	9874687	PhPrac 7e Ch02 Apply the Concepts	100	\N
48053181	12028720	9874687	PhPrac 7e Ch02 Field Research Projects	100	\N
48053182	12028720	9874687	PhPrac 7e Ch02 Practice Test	100	\N
48053183	12028720	9874687	PhPrac 7e Ch02 Exam	100	\N
48053184	12028721	9874687	PhPrac 7e Ch03 Watch and Learn Lessons	100	\N
48053185	12028721	9874687	PhPrac 7e Ch03 Check Your Understanding	100	\N
48053186	12028721	9874687	PHPrac 7e Ch03 Flash Cards	10	\N
48053188	12028721	9874687	PhPrac 7e Ch03 Short Answer	100	\N
48053189	12028721	9874687	PhPrac 7e Ch03 Apply the Concepts	100	\N
48053191	12028721	9874687	PhPrac 7e Ch03 Field Research Projects	100	\N
48053193	12028721	9874687	PhPrac 7e Ch03 Practice Test	100	\N
48053194	12028721	9874687	PhPrac 7e Ch03 Exam	100	\N
48053196	12028722	9874687	PhPrac 7e Ch04 Watch and Learn Lessons	100	\N
48053197	12028722	9874687	PhPrac 7e Ch04 Check Your Understanding	100	\N
48053198	12028722	9874687	PhPrac 7e Ch04 Flash Cards	10	\N
48053199	12028722	9874687	PhPrac 7e Ch04 Short Answer	100	\N
48053200	12028722	9874687	PhPrac 7e Ch04 Apply the Concepts	100	\N
48053201	12028722	9874687	PhPrac 7e Ch04 Field Research Projects	100	\N
48053202	12028722	9874687	PhPrac 7e Ch04 Practice Test	100	\N
48053203	12028722	9874687	PhPrac 7e Ch04 Exam	100	\N
48053204	12028723	9874687	PhPrac 7e Ch05 Watch and Learn Lessons	100	\N
48053205	12028723	9874687	PhPrac 7e Ch05 Check Your Understanding	100	\N
48053206	12028723	9874687	PhPrac 7e Ch05 Flash Cards	10	\N
48053207	12028723	9874687	PhPrac 7e Ch05 Short Answer	100	\N
48053208	12028723	9874687	PhPrac 7e Ch05 Apply the Concepts	100	\N
48053209	12028723	9874687	PhPrac 7e Ch05 Field Research Projects	100	\N
48053210	12028723	9874687	PhPrac 7e Ch05 Practice Test	100	\N
48053211	12028723	9874687	PhPrac 7e Ch05 Exam	100	\N
48053212	12028724	9874687	PhPrac 7e Ch06 Watch and Learn Lessons	100	\N
48053213	12028724	9874687	PhPrac 7e Ch06 Check Your Understanding	100	\N
48053214	12028724	9874687	PhPrac 7e Ch06 Flash Cards	10	\N
48053215	12028724	9874687	PhPrac 7e Ch06 Short Answer	100	\N
48053216	12028724	9874687	PhPrac 7e Ch06 Apply the Concepts	100	\N
48053217	12028724	9874687	PhPrac 7e Ch06 Field Research Projects	100	\N
48053218	12028724	9874687	PhPrac 7e Ch06 Practice Test	100	\N
48053219	12028724	9874687	PhPrac 7e Ch06 Exam	100	\N
48053220	12028725	9874687	PhPrac 7e Ch07 Watch and Learn Lessons	100	\N
48053221	12028725	9874687	PhPrac 7e Ch07 Check Your Understanding	100	\N
48053222	12028725	9874687	PhPrac 7e Ch07 Flash Cards	10	\N
48053224	12028725	9874687	PhPrac 7e Ch07 Short Answer	100	\N
48053225	12028725	9874687	PhPrac 7e Ch07 Apply the Concepts	100	\N
48053227	12028725	9874687	PhPrac 7e Ch07 Field Research Projects	100	\N
48053229	12028725	9874687	PhPrac 7e Ch07 Practice Test	100	\N
48053230	12028725	9874687	PhPrac 7e Ch07 Exam	100	\N
48053231	12028726	9874687	PhPrac 7e Ch08 Watch and Learn Lessons	100	\N
29070763	1893067	1433500	THURSDAY	10	\N
48053234	12028726	9874687	PhPrac 7e Ch08 Flash Cards	10	\N
48053235	12028726	9874687	PhPrac 7e Ch08 Short Answer	100	\N
48053236	12028726	9874687	PhPrac 7e Ch08 Apply the Concepts	100	\N
48053238	12028726	9874687	PhPrac 7e Ch08 Field Research Projects	100	\N
48053239	12028726	9874687	PhPrac 7e Ch08 Practice Test	100	\N
48053240	12028726	9874687	PhPrac 7e Ch08 Exam	100	\N
48053242	12028727	9874687	PhPrac 7e Ch09 Watch and Learn Lessons	100	\N
48053243	12028727	9874687	PhPrac 7e Ch09 Check Your Understanding	100	\N
48053244	12028727	9874687	PhPrac 7e Ch09 Flash Cards	10	\N
48053245	12028727	9874687	PhPrac 7e Ch09 Short Answer	100	\N
48053246	12028727	9874687	PhPrac 7e Ch09 Apply the Concepts	100	\N
48053247	12028727	9874687	PhPrac 7e Ch09 Field Research Projects	100	\N
48053248	12028727	9874687	PhPrac 7e Ch09 Practice Test	100	\N
48053249	12028727	9874687	PhPrac 7e Ch09 Exam	100	\N
48053250	12028728	9874687	PhPrac 7e Ch10 Watch and Learn Lessons	100	\N
48053251	12028728	9874687	PhPrac 7e Ch10 Check Your Understanding	100	\N
48053252	12028728	9874687	PhPrac 7e Ch10 Flash Cards	10	\N
48053253	12028728	9874687	PhPrac 7e Ch10 Short Answer	100	\N
48053254	12028728	9874687	PhPrac 7e Ch10 Apply the Concepts	100	\N
48053255	12028728	9874687	PhPrac 7e Ch10 Field Research Projects	100	\N
48053257	12028728	9874687	PhPrac 7e Ch10 Practice Test	100	\N
48053258	12028728	9874687	PhPrac 7e Ch10 Exam	100	\N
48053259	12028729	9874687	PhPrac 7e Ch11 Watch and Learn Lessons	100	\N
48053261	12028729	9874687	PhPrac 7e Ch11 Check Your Understanding	100	\N
48053262	12028729	9874687	PhPrac 7e Ch11 Flash Cards	10	\N
48053263	12028729	9874687	PhPrac 7e Ch11 Short Answer	100	\N
48053264	12028729	9874687	PhPrac 7e Ch11 Apply the Concepts	100	\N
48053265	12028729	9874687	PhPrac 7e Ch11 Field Research Projects	100	\N
48053266	12028729	9874687	PhPrac 7e Ch11 Practice Test	100	\N
48053267	12028729	9874687	PhPrac 7e Ch11 Exam	100	\N
48053268	12028730	9874687	PhPrac 7e Ch12 Watch and Learn Lessons	100	\N
48053269	12028730	9874687	PhPrac 7e Ch12 Check Your Understanding	100	\N
48053270	12028730	9874687	PhPrac 7e Ch12 Flash Cards	10	\N
48053271	12028730	9874687	PhPrac 7e Ch12 Short Answer	100	\N
48053272	12028730	9874687	PhPrac 7e Ch12 Apply the Concepts	100	\N
48053273	12028730	9874687	PhPrac 7e Ch12 Field Research Projects	100	\N
48053274	12028730	9874687	PhPrac 7e Ch12 Practice Test	100	\N
48053275	12028730	9874687	PhPrac 7e Ch12 Exam	100	\N
50209108	12674775	10439768	I Like myself, America and You can't stop me!  	30	\N
50209114	12674775	10439768	It's time to shine!	50	\N
50209116	12674775	10439768	Learning Styles	30	\N
50209107	12674775	10439768	How to study	15	\N
50209115	12674775	10439768	Keyboarding	50	\N
50209564	12674775	10439768	Week I: Homework Assignment Overview 	100	\N
50209102	12674775	10439768	HW1: Chapter 1	100	\N
50209555	12674775	10439768	The Professional Pharmacy Technician	50	\N
50208965	12674775	10439768	The Professional Pharmacy Technician	0	\N
50208973	12674775	10439768	Certification	25	\N
50209080	12674775	10439768	Cover Letters, Resumes, and Career Opportunities Activity	75	\N
50209101	12674775	10439768	HW 3:  Chapter 2	100	\N
50209109	12674775	10439768	In Class Activity: Professionalism and Dress Code	100	\N
50209547	12674775	10439768	Professional Organizations	100	\N
50209545	12674775	10439768	Pharmacy Operations	100	\N
50209106	12674775	10439768	Home Work Assignment 3	100	\N
50209111	12674775	10439768	In Class Activity: Time and Precision	100	\N
50209104	12674775	10439768	History of Medicine and Pharmacy	100	\N
50209103	12674775	10439768	HW4: Building Pharmacy Patient Profile	100	\N
50209112	12674775	10439768	In-Class Activity: Scenario and Role-Play Exercises	100	\N
50209113	12674775	10439768	In-class Activity:  Manufacturer's labels and MedWatch form	100	\N
50208967	12674775	10439768	Pharmacy and Health Care	0	\N
50208964	12674775	10439768	Pharmacy Laws, Regulations, and Ethics	0	\N
50209549	12674775	10439768	Roll Call Attendance	100	\N
50208875	12674775	10439768	The Pharmacy Technician; The Professional Pharmacy Tech chapter 2	43.3	\N
50208872	12674775	10439768	The pharmcy technician: Pharmacy Laws, Regulations and Ethics Chapter 3	15	\N
50208900	12674775	10439768	The Pharmacy Technician Workbook and Certification Review: Terminology Chapter 5	45	\N
50208887	12674775	10439768	The Pharnacy  Technician: Calculations Chapter 6	11	\N
50208899	12674775	10439768	The Pharmacy Technician; Prescriptions Chapter 7	10	\N
50208907	12674775	10439768	The pharmacy Technician; Routes and  Formulations Chapter 8	11	\N
50208873	12674775	10439768	The Pharmacy Technician; Nonsterile Compounding Chapter 9	10	\N
50208919	12674775	10439768	The Pharmacy Technician: Sterile Compounding and Aseptic Technique Chapter 10	10	\N
50208901	12674775	10439768	The Pharmacy Technician: Basic Biopharmaceutics Chapter 11	12	\N
50208877	12674775	10439768	The Pharmacy Technician; Factors Affecting Drug Activity Chapter 12	10	\N
50208895	12674775	10439768	The Pharmacy Technician: Common drug and Their uses Chapter 13	23	\N
50208896	12674775	10439768	The pharmacy Technician: Community Pharmacy Chapter 16	10	\N
50208948	12674775	10439768	The Pharmacy Technician: Hospital  Pharmacy Chapter 17	9	\N
50208921	12674775	10439768	The Pharmacy Technician Workbook and Certification Review; The Professional Pharmacy Technician Chapter 2	34	\N
50208890	12674775	10439768	The Pharmacy Technician Workbook and Certification;  Pharmacy Laws, Regulations, and Ethics Chapter 3	34	\N
50208910	12674775	10439768	The Pharmacy Technician Workbook and Certification Review; Information Chapter 4	39	\N
50208929	12674775	10439768	The Pharmacy Technician Workbook and Certification Review; Prescriptions Chapter 7	39	\N
50208914	12674775	10439768	The Pharmacy Technician Workbook and Certification Review: Routes and Formulations Chapter 8	64	\N
50208938	12674775	10439768	The Pharmacy Technician Workbook and Certification Review: Nonsterile Compounding Chapter 9	59	\N
50208878	12674775	10439768	The Pharmacy Technician Workbook and Certification: Sterile Compounding and Aseptic Techniques Chapter 10	51	\N
50208905	12674775	10439768	The Pharmacy Technician Workbook and Certification Review: Basic Biopharmaceutics Chapter 11	55	\N
50208897	12674775	10439768	The Pharmacy Technician Workbook and Ceritification Review: Factors Affecting Drug Activity Chapter 12	40	\N
50208912	12674775	10439768	The Pharmacy Technician Workbook and Certification Review: Common Drugs and Their Uses Chapter 13	16	\N
50208936	12674775	10439768	The Pharmacy Technician Workbook and Certification Review: Community Pharmacy Chapter 16	11	\N
50208926	12674775	10439768	The Pharmacy Technician Workbook and Certification Review: Financial issues Chapter 15	34	\N
50208874	12674775	10439768	The Pharmacy Technician Workbook and Certification Review: Inventory Management Chapter 14	10	\N
50208917	12674775	10439768	The Pharmacy Technician Workbook and Certification; Calculations Exam	48	\N
50208886	12674775	10439768	The Pharmacy Technician Workbook and Certification Review; PTCE EXAM	89	\N
50208944	12674775	10439768	The Pharmacy Technician Workbook and Certification: ExCPT	117	\N
50209542	12674775	10439768	Pharmacy Calcultations Chapter 2; Using Ratios, Percents, and Proportions	0	\N
50208879	12674775	10439768	Pharmacy Calculations Chapter 2:  Using Ratios, Proportions and Percents	0	\N
50208884	12674775	10439768	TUESDAY: CHAPTER 1 QUIZ	42	\N
50209120	12674775	10439768	Monday	10	\N
50209557	12674775	10439768	Tuesday	0	\N
50209561	12674775	10439768	Wednesday	10	\N
50209556	12674775	10439768	Thursday	0	\N
50209117	12674775	10439768	MONDAY	10	\N
50208950	12674775	10439768	THURSDAY: CHAPTER 6 QUIZ	23	\N
50208898	12674775	10439768	WEEK1: LAB QUIZ 	24	\N
50209554	12674775	10439768	TUESDAY-03/07/23	10	\N
50208931	12674775	10439768	TUESDAY- CHAPTER 4: QUIZ	20	\N
50208941	12674775	10439768	WWEDNESDAY: CHAPTER 5 QUIZ	47	\N
50209550	12674775	10439768	THURSDAY	10	\N
50208885	12674775	10439768	FRIDAY- CHAPTERS 2 & 3 QUIZ	35	\N
50209558	12674775	10439768	Tuesday	10	\N
50208893	12674775	10439768	Pharmacy Technician Exam I	21	\N
50209551	12674775	10439768	THURSDAY	10	\N
50209552	12674775	10439768	THURSDAY	10	\N
50209118	12674775	10439768	MONDAY	10	\N
50208894	12674775	10439768	EXAM 1: Chapters 1-10	145	\N
50209559	12674775	10439768	WEDNESDAY	10	\N
50209553	12674775	10439768	TUESDAY- Take great notes from these very valuable lectures	10	\N
50209119	12674775	10439768	MONDAY	10	\N
50209560	12674775	10439768	WEDNESDAY	10	\N
50208955	12674775	10439768	WEDNESDAY	30	\N
50209121	12674775	10439768	Monday	10	\N
50209122	12674775	10439768	Monday	10	\N
50209563	12674775	10439768	Wednesday	10	\N
50208932	12674775	10439768	Chapter 4: Check Your Understanding-Using Pseudoephedrine Logbook	10	\N
50209018	12674775	10439768	Chapter 4: Make Connections- Using a Pseudoephedrine Logbook	0	\N
50208963	12674775	10439768	Chapter 4: Make Connections- Using a Pseudoephedrine Logbook	50	\N
50208902	12674775	10439768	Chapter 4: Exam	30	\N
50208889	12674775	10439768	Chapter 4: Check Your Understanding- DEA Validation	15	\N
50208961	12674775	10439768	Chapter 4: Make Connections- DEA Validation	50	\N
50208882	12674775	10439768	Chapter 2: Check your understanding- Practicing Professionalism in the Pharmacy	10	\N
50208960	12674775	10439768	Chapter 2: Make Connections- Practicing Professionalism in the Pharmacy	50	\N
50208972	12674776	10439768	Announcements	10	\N
50208934	12674776	10439768	Household Measurement Conversion	14	\N
50209099	12674776	10439768	Cultural Competency in Healthcare	100	\N
50208881	12674776	10439768	PTCB Practice exam #2	10	\N
50209100	12674776	10439768	Cultural Competency in Healthcare	100	\N
50208871	12674776	10439768	PTCB Practice Exam #3	10	\N
50208892	12674776	10439768	PTCB Practice Exam #4	10	\N
50208924	12674776	10439768	PTCB Practice Exam #5	10	\N
50208971	12674776	10439768	ABOUT YOUR NHA CERTIFICATION	100	\N
50208969	12674776	10439768	PHARMACY LABS FOR TECHNICIANS	0	\N
47598128	11884713	9746185	I Like myself, America and You can't stop me!  	30	\N
47598133	11884713	9746185	It's time to shine!	50	\N
47598135	11884713	9746185	Learning Styles	30	\N
47598127	11884713	9746185	How to study	15	\N
47598134	11884713	9746185	Keyboarding	50	\N
47598438	11884713	9746185	Week I: Homework Assignment Overview 	100	\N
47598123	11884713	9746185	HW1: Chapter 1	100	\N
47598428	11884713	9746185	The Professional Pharmacy Technician	50	\N
47598023	11884713	9746185	The Professional Pharmacy Technician	0	\N
47598027	11884713	9746185	Certification	25	\N
47598102	11884713	9746185	Cover Letters, Resumes, and Career Opportunities Activity	75	\N
47598122	11884713	9746185	HW 3:  Chapter 2	100	\N
47598129	11884713	9746185	In Class Activity: Professionalism and Dress Code	100	\N
47598420	11884713	9746185	Professional Organizations	100	\N
47598419	11884713	9746185	Pharmacy Operations	100	\N
47598126	11884713	9746185	Home Work Assignment 3	100	\N
47598130	11884713	9746185	In Class Activity: Time and Precision	100	\N
47598125	11884713	9746185	History of Medicine and Pharmacy	100	\N
47598124	11884713	9746185	HW4: Building Pharmacy Patient Profile	100	\N
47598131	11884713	9746185	In-Class Activity: Scenario and Role-Play Exercises	100	\N
47598132	11884713	9746185	In-class Activity:  Manufacturer's labels and MedWatch form	100	\N
47598024	11884713	9746185	Pharmacy and Health Care	0	\N
47598022	11884713	9746185	Pharmacy Laws, Regulations, and Ethics	0	\N
47598422	11884713	9746185	Roll Call Attendance	100	\N
47597999	11884713	9746185	The Pharmacy Technician; The Professional Pharmacy Tech chapter 2	43.3	\N
47598013	11884713	9746185	The pharmcy technician: Pharmacy Laws, Regulations and Ethics Chapter 3	15	\N
47597986	11884713	9746185	The Pharmacy Technician Workbook and Certification Review: Terminology Chapter 5	45	\N
47597968	11884713	9746185	The Pharnacy  Technician: Calculations Chapter 6	11	\N
47597974	11884713	9746185	The Pharmacy Technician; Prescriptions Chapter 7	10	\N
47597985	11884713	9746185	The pharmacy Technician; Routes and  Formulations Chapter 8	11	\N
47597990	11884713	9746185	The Pharmacy Technician; Nonsterile Compounding Chapter 9	10	\N
47597952	11884713	9746185	The Pharmacy Technician: Sterile Compounding and Aseptic Technique Chapter 10	10	\N
47598012	11884713	9746185	The Pharmacy Technician: Basic Biopharmaceutics Chapter 11	12	\N
47597998	11884713	9746185	The Pharmacy Technician; Factors Affecting Drug Activity Chapter 12	10	\N
47598016	11884713	9746185	The Pharmacy Technician: Common drug and Their uses Chapter 13	23	\N
47597993	11884713	9746185	The pharmacy Technician: Community Pharmacy Chapter 16	10	\N
47597984	11884713	9746185	The Pharmacy Technician: Hospital  Pharmacy Chapter 17	9	\N
47597988	11884713	9746185	The Pharmacy Technician Workbook and Certification Review; The Professional Pharmacy Technician Chapter 2	34	\N
47597991	11884713	9746185	The Pharmacy Technician Workbook and Certification;  Pharmacy Laws, Regulations, and Ethics Chapter 3	34	\N
47598009	11884713	9746185	The Pharmacy Technician Workbook and Certification Review; Information Chapter 4	39	\N
47598002	11884713	9746185	The Pharmacy Technician Workbook and Certification Review; Prescriptions Chapter 7	39	\N
47597987	11884713	9746185	The Pharmacy Technician Workbook and Certification Review: Routes and Formulations Chapter 8	64	\N
47597997	11884713	9746185	The Pharmacy Technician Workbook and Certification Review: Nonsterile Compounding Chapter 9	59	\N
47598008	11884713	9746185	The Pharmacy Technician Workbook and Certification: Sterile Compounding and Aseptic Techniques Chapter 10	51	\N
47598011	11884713	9746185	The Pharmacy Technician Workbook and Certification Review: Basic Biopharmaceutics Chapter 11	55	\N
47597982	11884713	9746185	The Pharmacy Technician Workbook and Ceritification Review: Factors Affecting Drug Activity Chapter 12	40	\N
47598007	11884713	9746185	The Pharmacy Technician Workbook and Certification Review: Common Drugs and Their Uses Chapter 13	16	\N
47598006	11884713	9746185	The Pharmacy Technician Workbook and Certification Review: Community Pharmacy Chapter 16	11	\N
47597966	11884713	9746185	The Pharmacy Technician Workbook and Certification Review: Financial issues Chapter 15	34	\N
47598015	11884713	9746185	The Pharmacy Technician Workbook and Certification Review: Inventory Management Chapter 14	10	\N
47597981	11884713	9746185	The Pharmacy Technician Workbook and Certification; Calculations Exam	48	\N
47597975	11884713	9746185	The Pharmacy Technician Workbook and Certification Review; PTCE EXAM	89	\N
47597971	11884713	9746185	The Pharmacy Technician Workbook and Certification: ExCPT	117	\N
47598416	11884713	9746185	Pharmacy Calcultations Chapter 2; Using Ratios, Percents, and Proportions	0	\N
47597973	11884713	9746185	Pharmacy Calculations Chapter 2:  Using Ratios, Proportions and Percents	0	\N
47597956	11884713	9746185	TUESDAY: CHAPTER 1 QUIZ	42	\N
47598139	11884713	9746185	Monday- Reading Assignment	10	\N
47598430	11884713	9746185	Tuesday	0	\N
47598435	11884713	9746185	Wednesday	10	\N
47598429	11884713	9746185	Thursday	0	\N
47598136	11884713	9746185	MONDAY	10	\N
47598001	11884713	9746185	THURSDAY: CHAPTER 6 QUIZ	23	\N
47597961	11884713	9746185	WEEK1: LAB QUIZ 	24	\N
47598427	11884713	9746185	TUESDAY-03/07/23	10	\N
47598005	11884713	9746185	TUESDAY- CHAPTER 4: QUIZ	20	\N
47598004	11884713	9746185	WWEDNESDAY: CHAPTER 5 QUIZ	47	\N
47598423	11884713	9746185	THURSDAY	10	\N
47597980	11884713	9746185	FRIDAY- CHAPTERS 2 & 3 QUIZ	35	\N
47598431	11884713	9746185	Tuesday	10	\N
47597989	11884713	9746185	Pharmacy Technician Exam I	21	\N
47598424	11884713	9746185	THURSDAY	10	\N
47598425	11884713	9746185	THURSDAY	10	\N
47598137	11884713	9746185	MONDAY	10	\N
47597992	11884713	9746185	EXAM 1: Chapters 1-10	145	\N
47598433	11884713	9746185	WEDNESDAY	10	\N
47598426	11884713	9746185	TUESDAY- Take great notes from these very valuable lectures	10	\N
47598138	11884713	9746185	MONDAY	10	\N
47598434	11884713	9746185	WEDNESDAY	10	\N
47597983	11884713	9746185	WEDNESDAY	30	\N
47598140	11884713	9746185	Monday	10	\N
47598141	11884713	9746185	Monday	10	\N
47598436	11884713	9746185	Wednesday	10	\N
47598003	11884713	9746185	Chapter 4: Check Your Understanding-Using Pseudoephedrine Logbook	10	\N
47598062	11884713	9746185	Chapter 4: Make Connections- Using a Pseudoephedrine Logbook	0	\N
47598020	11884713	9746185	Chapter 4: Make Connections- Using a Pseudoephedrine Logbook	50	\N
47598014	11884713	9746185	Chapter 4: Exam	30	\N
47597994	11884713	9746185	Chapter 4: Check Your Understanding- DEA Validation	15	\N
47598019	11884713	9746185	Chapter 4: Make Connections- DEA Validation	50	\N
47597979	11884713	9746185	Chapter 2: Check your understanding- Practicing Professionalism in the Pharmacy	10	\N
47598017	11884713	9746185	Chapter 2: Make Connections- Practicing Professionalism in the Pharmacy	50	\N
47597996	11884714	9746185	Household Measurement Conversion	14	\N
47598120	11884714	9746185	Cultural Competency in Healthcare	100	\N
47598000	11884714	9746185	PTCB Practice exam #2	10	\N
47598121	11884714	9746185	Cultural Competency in Healthcare	100	\N
47597976	11884714	9746185	PTCB Practice Exam #3	10	\N
47597972	11884714	9746185	PTCB Practice Exam #4	10	\N
47597978	11884714	9746185	PTCB Practice Exam #5	10	\N
47598026	11884714	9746185	ABOUT YOUR NHA CERTIFICATION	100	\N
47598025	11884714	9746185	PHARMACY LABS FOR TECHNICIANS	0	\N
47598421	11884714	9746185	Project 1: Résumé and Cover Letter	100	\N
9711808	1893067	1433500	I Like myself, America and You can't stop me!  	30	\N
9729359	1893067	1433500	It's time to shine!	50	\N
9711814	1893067	1433500	Learning Styles	30	\N
9728971	1893067	1433500	How to study	15	\N
9729049	1893067	1433500	Keyboarding	50	\N
9733347	1893067	1433500	Week I: Homework Assignment Overview 	100	\N
9733888	1893067	1433500	HW1: Chapter 1	100	\N
9729448	1893067	1433500	The Professional Pharmacy Technician	50	\N
9739608	1893067	1433500	The Professional Pharmacy Technician	0	\N
9732770	1893067	1433500	Certification	25	\N
9733221	1893067	1433500	Cover Letters, Resumes, and Career Opportunities Activity	75	\N
9733894	1893067	1433500	HW 3:  Chapter 2	100	\N
9733591	1893067	1433500	In Class Activity: Professionalism and Dress Code	100	\N
9733279	1893067	1433500	Professional Organizations	100	\N
9733425	1893067	1433500	Pharmacy Operations	100	\N
9733895	1893067	1433500	Home Work Assignment 3	100	\N
9733602	1893067	1433500	In Class Activity: Time and Precision	100	\N
9733575	1893067	1433500	History of Medicine and Pharmacy	100	\N
9733614	1893067	1433500	HW4: Building Pharmacy Patient Profile	100	\N
9733703	1893067	1433500	In-Class Activity: Scenario and Role-Play Exercises	100	\N
9733723	1893067	1433500	In-class Activity:  Manufacturer's labels and MedWatch form	100	\N
9739604	1893067	1433500	Pharmacy and Health Care	0	\N
9739636	1893067	1433500	Pharmacy Laws, Regulations, and Ethics	0	\N
9854096	1893067	1433500	Roll Call Attendance	100	\N
11609190	1893067	1433500	The Pharmacy Technician; The Professional Pharmacy Tech chapter 2	43.3	\N
11611129	1893067	1433500	The pharmcy technician: Pharmacy Laws, Regulations and Ethics Chapter 3	15	\N
11621718	1893067	1433500	The Pharmacy Technician Workbook and Certification Review: Terminology Chapter 5	45	\N
11665264	1893067	1433500	The Pharnacy  Technician: Calculations Chapter 6	11	\N
11665833	1893067	1433500	The Pharmacy Technician; Prescriptions Chapter 7	10	\N
11666294	1893067	1433500	The pharmacy Technician; Routes and  Formulations Chapter 8	11	\N
11674933	1893067	1433500	The Pharmacy Technician; Nonsterile Compounding Chapter 9	10	\N
11676115	1893067	1433500	The Pharmacy Technician: Sterile Compounding and Aseptic Technique Chapter 10	10	\N
11676589	1893067	1433500	The Pharmacy Technician: Basic Biopharmaceutics Chapter 11	12	\N
11685705	1893067	1433500	The Pharmacy Technician; Factors Affecting Drug Activity Chapter 12	10	\N
11686777	1893067	1433500	The Pharmacy Technician: Common drug and Their uses Chapter 13	23	\N
11692888	1893067	1433500	The pharmacy Technician: Community Pharmacy Chapter 16	10	\N
11694173	1893067	1433500	The Pharmacy Technician: Hospital  Pharmacy Chapter 17	9	\N
12675292	1893067	1433500	The Pharmacy Technician Workbook and Certification Review; The Professional Pharmacy Technician Chapter 2	34	\N
12679180	1893067	1433500	The Pharmacy Technician Workbook and Certification;  Pharmacy Laws, Regulations, and Ethics Chapter 3	34	\N
12679436	1893067	1433500	The Pharmacy Technician Workbook and Certification Review; Information Chapter 4	39	\N
12680474	1893067	1433500	The Pharmacy Technician Workbook and Certification Review; Prescriptions Chapter 7	39	\N
12681350	1893067	1433500	The Pharmacy Technician Workbook and Certification Review: Routes and Formulations Chapter 8	64	\N
12681470	1893067	1433500	The Pharmacy Technician Workbook and Certification Review: Nonsterile Compounding Chapter 9	59	\N
12682948	1893067	1433500	The Pharmacy Technician Workbook and Certification: Sterile Compounding and Aseptic Techniques Chapter 10	51	\N
12683509	1893067	1433500	The Pharmacy Technician Workbook and Certification Review: Basic Biopharmaceutics Chapter 11	55	\N
12688902	1893067	1433500	The Pharmacy Technician Workbook and Ceritification Review: Factors Affecting Drug Activity Chapter 12	40	\N
12689075	1893067	1433500	The Pharmacy Technician Workbook and Certification Review: Common Drugs and Their Uses Chapter 13	16	\N
12700722	1893067	1433500	The Pharmacy Technician Workbook and Certification Review: Community Pharmacy Chapter 16	11	\N
12701612	1893067	1433500	The Pharmacy Technician Workbook and Certification Review: Financial issues Chapter 15	34	\N
12769043	1893067	1433500	The Pharmacy Technician Workbook and Certification Review: Inventory Management Chapter 14	10	\N
12791106	1893067	1433500	The Pharmacy Technician Workbook and Certification; Calculations Exam	48	\N
12792587	1893067	1433500	The Pharmacy Technician Workbook and Certification Review; PTCE EXAM	89	\N
12801562	1893067	1433500	The Pharmacy Technician Workbook and Certification: ExCPT	117	\N
12819640	1893067	1433500	Pharmacy Calcultations Chapter 2; Using Ratios, Percents, and Proportions	0	\N
12819691	1893067	1433500	Pharmacy Calculations Chapter 2:  Using Ratios, Proportions and Percents	0	\N
23019193	1893067	1433500	PHARMACY LABS FOR TECHNICIANS	0	\N
28644647	1893067	1433500	TUESDAY: CHAPTER 1 QUIZ	42	\N
28646743	1893067	1433500	Monday	10	\N
28646750	1893067	1433500	Tuesday	0	\N
28646751	1893067	1433500	Wednesday	10	\N
28646758	1893067	1433500	Thursday	0	\N
28646759	1893067	1433500	MONDAY	10	\N
28728783	1893067	1433500	THURSDAY: CHAPTER 6 QUIZ	23	\N
28730163	1893067	1433500	WEEK1: LAB QUIZ 	24	\N
28786365	1893067	1433500	TUESDAY-03/07/23	10	\N
28810035	1893067	1433500	TUESDAY- CHAPTER 4: QUIZ	20	\N
28811939	1893067	1433500	WWEDNESDAY: CHAPTER 5 QUIZ	47	\N
28812586	1893067	1433500	THURSDAY	10	\N
28812824	1893067	1433500	FRIDAY- CHAPTERS 2 & 3 QUIZ	35	\N
28813831	1893067	1433500	Tuesday	10	\N
28826081	1893067	1433500	Pharmacy Technician Exam I	25	\N
29160726	1893067	1433500	EXAM 1: Chapters 1-10	145	\N
29165731	1893067	1433500	WEDNESDAY	10	\N
29261140	1893067	1433500	TUESDAY- Take great notes from these very valuable lectures	10	\N
29261951	1893067	1433500	MONDAY	10	\N
29402975	1893067	1433500	WEDNESDAY	10	\N
29633858	1893067	1433500	WEDNESDAY	30	\N
29657321	1893067	1433500	Monday	10	\N
29842857	1893067	1433500	Monday	10	\N
29843014	1893067	1433500	Wednesday	10	\N
35915944	1893067	1433500	Chapter 4: Check Your Understanding-Using Pseudoephedrine Logbook	10	\N
35927945	1893067	1433500	Chapter 4: Make Connections- Using a Pseudoephedrine Logbook	0	\N
35941991	1893067	1433500	Chapter 4: Make Connections- Using a Pseudoephedrine Logbook	50	\N
35950496	1893067	1433500	Chapter 4: Exam	30	\N
36028241	1893067	1433500	Chapter 4: Check Your Understanding- DEA Validation	15	\N
36028827	1893067	1433500	Chapter 4: Make Connections- DEA Validation	50	\N
36029461	1893067	1433500	Chapter 2: Check your understanding- Practicing Professionalism in the Pharmacy	10	\N
36035977	1893067	1433500	Chapter 2: Make Connections- Practicing Professionalism in the Pharmacy	50	\N
48053367	1937957	1433500	Announcements	10	\N
11440563	1937957	1433500	Household Measurement Conversion	14	\N
28728266	1937957	1433500	Cultural Competency in Healthcare	100	\N
9901161	1937957	1433500	PTCB Practice exam #2	10	\N
28644273	1937957	1433500	Cultural Competency in Healthcare	100	\N
9901168	1937957	1433500	PTCB Practice Exam #3	10	\N
9901178	1937957	1433500	PTCB Practice Exam #4	10	\N
9901181	1937957	1433500	PTCB Practice Exam #5	10	\N
29893649	1937957	1433500	ABOUT YOUR NHA CERTIFICATION	100	\N
49607487	12499023	10289143	IT'S TIME TO SHINE	100	\N
49607484	12499023	10289143	Cultural Competency in Healthcare	100	\N
49607488	12499023	10289143	Learning Styles	100	\N
49607486	12499023	10289143	How to study	100	\N
49607480	12499023	10289143	ABOUT YOUR NHA CERTIFICATION	100	\N
49607491	12499023	10289143	THE TEN COMMANDMENTS OF PHLEBOTOMY	0	\N
49607481	12499023	10289143	AVOIDING PHLEBOTOMY LAWSUITS	0	\N
49607485	12499023	10289143	Friday's Google Meets LInk	0	\N
49607473	12499024	10289143	Medical Terminology, Anatomy, and Physiology of Organ Systems: Homework Assignment #5	73	\N
49607472	12499024	10289143	The Cardiovascular and Lymphatic System : Homework Assignment #6	72	\N
49607465	12499024	10289143	WEEK ONE EXAM	60	\N
49607469	12499025	10289143	Blood Collection Equipment: Homework Assignment #1	70	\N
49607466	12499025	10289143	Infection Control:  Homework Assignment #7	75	\N
49607471	12499025	10289143	Capillary or Dermal Blood Specimens: Homework Assignment #8	69	\N
49607458	12499025	10289143	Venipuncture Procedures: Homework Assignment #9	73	\N
49607475	12499025	10289143	Preexamination/Preanaytical Complications: Homework Assignment #10	85	\N
49607462	12499025	10289143	Safety and First Aid: Homework Assignment #11	75	\N
49607460	12499025	10289143	Pediatric and Geriatric Procedures: Homework #13	75	\N
49607477	12499025	10289143	Point-of Care collections: Homework #14	75	\N
49607468	12499025	10289143	WEEK TWO EXAM	60	\N
49607490	12499025	10289143	NHA PRACTICE EXAM	100	\N
49607464	12499026	10289143	Specimen Handling, Transportation, and Processing: Homework #12	70	\N
49607467	12499026	10289143	Blood Cultures, Arterial, Intravenous (IV), and Special Collection Procedures: Homework #15	85	\N
49607461	12499026	10289143	Urinalysis, Body Fluids, and Other Specimens: Homework # 16	75	\N
49607474	12499026	10289143	Drug use, Forensic Toxicology, Workplace Testing, Sports Medicine, and Related Areas: Homework Assignment #17	84	\N
49607489	12499026	10289143	NHA PRACTICE EXAM	100	\N
49607476	12499027	10289143	Phlebotomy Practice and Quality Assessment: Homework Assignment #2	69	\N
49607470	12499027	10289143	Communication, Computer Essentials, and Documentation: Homework Assignment #3	80	\N
49607463	12499027	10289143	Professional Ethics, Legal, and Regulatory Issues:  Homework Assignment #4	76	\N
49607482	12499028	10289143	Attendance/Log-in	100	\N
48438850	12154193	9987831	IT'S TIME TO SHINE	100	\N
48438847	12154193	9987831	Cultural Competency in Healthcare	100	\N
48438851	12154193	9987831	Learning Styles	100	\N
48438849	12154193	9987831	How to study	100	\N
48438844	12154193	9987831	ABOUT YOUR NHA CERTIFICATION	100	\N
48438854	12154193	9987831	THE TEN COMMANDMENTS OF PHLEBOTOMY	0	\N
48438845	12154193	9987831	AVOIDING PHLEBOTOMY LAWSUITS	0	\N
48438848	12154193	9987831	Friday's Google Meets LInk	0	\N
48438837	12154194	9987831	Medical Terminology, Anatomy, and Physiology of Organ Systems: Homework Assignment #5	73	\N
48438833	12154194	9987831	The Cardiovascular and Lymphatic System : Homework Assignment #6	72	\N
48438842	12154194	9987831	WEEK ONE EXAM	60	\N
48438838	12154195	9987831	Blood Collection Equipment: Homework Assignment #1	70	\N
48438825	12154195	9987831	Infection Control:  Homework Assignment #7	75	\N
48438839	12154195	9987831	Capillary or Dermal Blood Specimens: Homework Assignment #8	69	\N
48438836	12154195	9987831	Venipuncture Procedures: Homework Assignment #9	73	\N
48438830	12154195	9987831	Preexamination/Preanaytical Complications: Homework Assignment #10	85	\N
48438831	12154195	9987831	Safety and First Aid: Homework Assignment #11	75	\N
48438840	12154195	9987831	Pediatric and Geriatric Procedures: Homework #13	75	\N
48438832	12154195	9987831	Point-of Care collections: Homework #14	75	\N
48438826	12154195	9987831	WEEK TWO EXAM	60	\N
48438853	12154195	9987831	NHA PRACTICE EXAM	100	\N
48438835	12154196	9987831	Specimen Handling, Transportation, and Processing: Homework #12	70	\N
48438834	12154196	9987831	Blood Cultures, Arterial, Intravenous (IV), and Special Collection Procedures: Homework #15	85	\N
48438827	12154196	9987831	Urinalysis, Body Fluids, and Other Specimens: Homework # 16	75	\N
48438843	12154196	9987831	Drug use, Forensic Toxicology, Workplace Testing, Sports Medicine, and Related Areas: Homework Assignment #17	84	\N
48438852	12154196	9987831	NHA PRACTICE EXAM	100	\N
48438828	12154197	9987831	Phlebotomy Practice and Quality Assessment: Homework Assignment #2	69	\N
48438841	12154197	9987831	Communication, Computer Essentials, and Documentation: Homework Assignment #3	80	\N
48438829	12154197	9987831	Professional Ethics, Legal, and Regulatory Issues:  Homework Assignment #4	76	\N
48438846	12154198	9987831	Attendance/Log-in	100	\N
34645503	7670348	5952410	IT'S TIME TO SHINE	100	\N
34645500	7670348	5952410	Cultural Competency in Healthcare	100	\N
34645504	7670348	5952410	Learning Styles	100	\N
34645502	7670348	5952410	How to study	100	\N
34645497	7670348	5952410	ABOUT YOUR NHA CERTIFICATION	100	\N
34645507	7670348	5952410	THE TEN COMMANDMENTS OF PHLEBOTOMY	0	\N
34645498	7670348	5952410	AVOIDING PHLEBOTOMY LAWSUITS	0	\N
34645501	7670348	5952410	Friday's Google Meets LInk	0	\N
34645467	7670350	5952410	Medical Terminology, Anatomy, and Physiology of Organ Systems: Homework Assignment #5	73	\N
34645485	7670350	5952410	The Cardiovascular and Lymphatic System : Homework Assignment #6	72	\N
34645492	7670350	5952410	WEEK ONE EXAM	60	\N
34645486	7670351	5952410	Blood Collection Equipment: Homework Assignment #1	70	\N
34645488	7670351	5952410	Infection Control:  Homework Assignment #7	75	\N
34645490	7670351	5952410	Capillary or Dermal Blood Specimens: Homework Assignment #8	69	\N
34645487	7670351	5952410	Venipuncture Procedures: Homework Assignment #9	73	\N
34645481	7670351	5952410	Preexamination/Preanaytical Complications: Homework Assignment #10	85	\N
34645458	7670351	5952410	Safety and First Aid: Homework Assignment #11	75	\N
34645489	7670351	5952410	Pediatric and Geriatric Procedures: Homework #13	75	\N
34645462	7670351	5952410	Point-of Care collections: Homework #14	75	\N
34645453	7670351	5952410	WEEK TWO EXAM	60	\N
34645505	7670351	5952410	NHA PRACTICE EXAM	100	\N
34645480	7670352	5952410	Specimen Handling, Transportation, and Processing: Homework #12	70	\N
34645493	7670352	5952410	Blood Cultures, Arterial, Intravenous (IV), and Special Collection Procedures: Homework #15	85	\N
34645491	7670352	5952410	Urinalysis, Body Fluids, and Other Specimens: Homework # 16	75	\N
34645446	7670352	5952410	Drug use, Forensic Toxicology, Workplace Testing, Sports Medicine, and Related Areas: Homework Assignment #17	84	\N
34645506	7670352	5952410	NHA PRACTICE EXAM	100	\N
34645471	7670349	5952410	Phlebotomy Practice and Quality Assessment: Homework Assignment #2	69	\N
34645476	7670349	5952410	Communication, Computer Essentials, and Documentation: Homework Assignment #3	80	\N
34645482	7670349	5952410	Professional Ethics, Legal, and Regulatory Issues:  Homework Assignment #4	76	\N
34645499	7670353	5952410	Attendance/Log-in	100	\N
46449989	11585772	9483594	IT'S TIME TO SHINE	100	\N
46449985	11585772	9483594	Cultural Competency in Healthcare	100	\N
46449991	11585772	9483594	Learning Styles	100	\N
46449988	11585772	9483594	How to study	100	\N
46449981	11585772	9483594	ABOUT YOUR NHA CERTIFICATION	100	\N
46449995	11585772	9483594	THE TEN COMMANDMENTS OF PHLEBOTOMY	0	\N
46449982	11585772	9483594	AVOIDING PHLEBOTOMY LAWSUITS	0	\N
46449986	11585772	9483594	Friday's Google Meets LInk	0	\N
46449976	11585773	9483594	Medical Terminology, Anatomy, and Physiology of Organ Systems: Homework Assignment #5	73	\N
46449962	11585773	9483594	The Cardiovascular and Lymphatic System : Homework Assignment #6	72	\N
46449974	11585773	9483594	WEEK ONE EXAM	60	\N
46449958	11585774	9483594	Blood Collection Equipment: Homework Assignment #1	70	\N
46449966	11585774	9483594	Infection Control:  Homework Assignment #7	75	\N
46449972	11585774	9483594	Capillary or Dermal Blood Specimens: Homework Assignment #8	69	\N
46449978	11585774	9483594	Venipuncture Procedures: Homework Assignment #9	73	\N
46449961	11585774	9483594	Preexamination/Preanaytical Complications: Homework Assignment #10	85	\N
46449973	11585774	9483594	Safety and First Aid: Homework Assignment #11	75	\N
46449959	11585774	9483594	Pediatric and Geriatric Procedures: Homework #13	75	\N
46449980	11585774	9483594	Point-of Care collections: Homework #14	75	\N
46449975	11585774	9483594	WEEK TWO EXAM	60	\N
46449994	11585774	9483594	NHA PRACTICE EXAM	100	\N
46449960	11585775	9483594	Specimen Handling, Transportation, and Processing: Homework #12	70	\N
46449971	11585775	9483594	Blood Cultures, Arterial, Intravenous (IV), and Special Collection Procedures: Homework #15	85	\N
46449965	11585775	9483594	Urinalysis, Body Fluids, and Other Specimens: Homework # 16	75	\N
46449963	11585775	9483594	Drug use, Forensic Toxicology, Workplace Testing, Sports Medicine, and Related Areas: Homework Assignment #17	84	\N
46449992	11585775	9483594	NHA PRACTICE EXAM	100	\N
46449968	11585776	9483594	Phlebotomy Practice and Quality Assessment: Homework Assignment #2	69	\N
46449964	11585776	9483594	Communication, Computer Essentials, and Documentation: Homework Assignment #3	80	\N
46449970	11585776	9483594	Professional Ethics, Legal, and Regulatory Issues:  Homework Assignment #4	76	\N
46449983	11585777	9483594	Attendance/Log-in	100	\N
47320897	11811054	9681492	IT'S TIME TO SHINE	100	\N
47320892	11811054	9681492	Cultural Competency in Healthcare	100	\N
47320900	11811054	9681492	Learning Styles	100	\N
47320895	11811054	9681492	How to study	100	\N
47320886	11811054	9681492	ABOUT YOUR NHA CERTIFICATION	100	\N
47320904	11811054	9681492	THE TEN COMMANDMENTS OF PHLEBOTOMY	0	\N
47320888	11811054	9681492	AVOIDING PHLEBOTOMY LAWSUITS	0	\N
47320894	11811054	9681492	Friday's Google Meets LInk	0	\N
47320868	11811055	9681492	Medical Terminology, Anatomy, and Physiology of Organ Systems: Homework Assignment #5	73	\N
47320791	11811055	9681492	The Cardiovascular and Lymphatic System : Homework Assignment #6	72	\N
47320802	11811055	9681492	WEEK ONE EXAM	60	\N
47320840	11811057	9681492	Blood Collection Equipment: Homework Assignment #1	70	\N
47320875	11811057	9681492	Infection Control:  Homework Assignment #7	75	\N
47320835	11811057	9681492	Capillary or Dermal Blood Specimens: Homework Assignment #8	69	\N
47320881	11811057	9681492	Venipuncture Procedures: Homework Assignment #9	73	\N
47320879	11811057	9681492	Preexamination/Preanaytical Complications: Homework Assignment #10	85	\N
47320852	11811057	9681492	Safety and First Aid: Homework Assignment #11	75	\N
47320815	11811057	9681492	Pediatric and Geriatric Procedures: Homework #13	75	\N
47320829	11811057	9681492	Point-of Care collections: Homework #14	75	\N
47320796	11811057	9681492	WEEK TWO EXAM	60	\N
47320903	11811057	9681492	NHA PRACTICE EXAM	100	\N
47320846	11811059	9681492	Specimen Handling, Transportation, and Processing: Homework #12	70	\N
47320810	11811059	9681492	Blood Cultures, Arterial, Intravenous (IV), and Special Collection Procedures: Homework #15	85	\N
47320864	11811059	9681492	Urinalysis, Body Fluids, and Other Specimens: Homework # 16	75	\N
47320870	11811059	9681492	Drug use, Forensic Toxicology, Workplace Testing, Sports Medicine, and Related Areas: Homework Assignment #17	84	\N
47320902	11811059	9681492	NHA PRACTICE EXAM	100	\N
47320822	11811061	9681492	Phlebotomy Practice and Quality Assessment: Homework Assignment #2	69	\N
47320872	11811061	9681492	Communication, Computer Essentials, and Documentation: Homework Assignment #3	80	\N
47320858	11811061	9681492	Professional Ethics, Legal, and Regulatory Issues:  Homework Assignment #4	76	\N
47320890	11811063	9681492	Attendance/Log-in	100	\N
45965550	11449116	9365544	IT'S TIME TO SHINE	100	\N
45965546	11449116	9365544	Cultural Competency in Healthcare	100	\N
45965551	11449116	9365544	Learning Styles	100	\N
45965549	11449116	9365544	How to study	100	\N
45965543	11449116	9365544	ABOUT YOUR NHA CERTIFICATION	100	\N
45965555	11449116	9365544	THE TEN COMMANDMENTS OF PHLEBOTOMY	0	\N
45965544	11449116	9365544	AVOIDING PHLEBOTOMY LAWSUITS	0	\N
45965548	11449116	9365544	Friday's Google Meets LInk	0	\N
45965541	11449117	9365544	Medical Terminology, Anatomy, and Physiology of Organ Systems: Homework Assignment #5	73	\N
45965537	11449117	9365544	The Cardiovascular and Lymphatic System : Homework Assignment #6	72	\N
45965526	11449117	9365544	WEEK ONE EXAM	60	\N
45965540	11449118	9365544	Blood Collection Equipment: Homework Assignment #1	70	\N
45965531	11449118	9365544	Infection Control:  Homework Assignment #7	75	\N
45965530	11449118	9365544	Capillary or Dermal Blood Specimens: Homework Assignment #8	69	\N
45965533	11449118	9365544	Venipuncture Procedures: Homework Assignment #9	73	\N
45965534	11449118	9365544	Preexamination/Preanaytical Complications: Homework Assignment #10	85	\N
45965536	11449118	9365544	Safety and First Aid: Homework Assignment #11	75	\N
45965527	11449118	9365544	Pediatric and Geriatric Procedures: Homework #13	75	\N
45965528	11449118	9365544	Point-of Care collections: Homework #14	75	\N
45965535	11449118	9365544	WEEK TWO EXAM	60	\N
45965554	11449118	9365544	NHA PRACTICE EXAM	100	\N
45965532	11449119	9365544	Specimen Handling, Transportation, and Processing: Homework #12	70	\N
45965539	11449119	9365544	Blood Cultures, Arterial, Intravenous (IV), and Special Collection Procedures: Homework #15	85	\N
45965524	11449119	9365544	Urinalysis, Body Fluids, and Other Specimens: Homework # 16	75	\N
45965529	11449119	9365544	Drug use, Forensic Toxicology, Workplace Testing, Sports Medicine, and Related Areas: Homework Assignment #17	84	\N
45965553	11449119	9365544	NHA PRACTICE EXAM	100	\N
45965525	11449120	9365544	Phlebotomy Practice and Quality Assessment: Homework Assignment #2	69	\N
45965538	11449120	9365544	Communication, Computer Essentials, and Documentation: Homework Assignment #3	80	\N
45965542	11449120	9365544	Professional Ethics, Legal, and Regulatory Issues:  Homework Assignment #4	76	\N
45965545	11449121	9365544	Attendance/Log-in	100	\N
43487337	10563531	8548499	IT'S TIME TO SHINE	100	\N
43487333	10563531	8548499	Cultural Competency in Healthcare	100	\N
43487338	10563531	8548499	Learning Styles	100	\N
43487336	10563531	8548499	How to study	100	\N
43487330	10563531	8548499	ABOUT YOUR NHA CERTIFICATION	100	\N
43487341	10563531	8548499	THE TEN COMMANDMENTS OF PHLEBOTOMY	0	\N
43487331	10563531	8548499	AVOIDING PHLEBOTOMY LAWSUITS	0	\N
43487335	10563531	8548499	Friday's Google Meets LInk	0	\N
43487268	10563531	8548499	Unnamed Quiz	0	\N
43487318	10563531	8548499	Chapter 9 : Capillary or Dermal Blood Specimens	30	\N
43487329	10563531	8548499	(01/24/24)  On Wednesday- Chapter 6: Homework Assignment #1	0	\N
43583948	10563531	8548499	(01/29/24) On Monday- Chapter 8: Homework Assignment #3	0	\N
43585676	10563531	8548499	(01/31/24) On Wednesday- Chapter 9: Homework Assignment #4	0	\N
43587777	10563531	8548499	(02/02/24) On Friday- Chapter 3: Homework Assignment #6	10	\N
43487301	10563532	8548499	Blood Collection Equipment: Homework Assignment #1	70	\N
43487319	10563532	8548499	Phlebotomy Practice and Quality Assessment: Homework Assignment #2	69	\N
43487322	10563532	8548499	Communication, Computer Essentials, and Documentation: Homework Assignment #3	80	\N
43487257	10563532	8548499	Professional Ethics, Legal, and Regulatory Issues:  Homework Assignment #4	76	\N
43487259	10563532	8548499	Medical Terminology, Anatomy, and Physiology of Organ Systems: Homework Assignment #5	73	\N
43487339	10563532	8548499	NHA PRACTICE EXAM	100	\N
43487261	10563532	8548499	Chapter 2 : Ethical , Legal , and Regulatory Issues	39	\N
43487263	10563532	8548499	Chapter 1 : Phlebotomy Practice and Quality Assessment Basics	34	\N
43487317	10563532	8548499	Chapter 8 : Venipuncture Procedures	30	\N
43487324	10563532	8548499	Chapter 4 : Safety and Infection Control	40	\N
43487279	10563532	8548499	Chapter 6 : Blood Collection Equipment	26	\N
43557650	10563532	8548499	 (01/25/24) By Friday- READING 3- Chapter 8: Venipuncture Procedures	10	\N
43567446	10563532	8548499	(01/26/24) On Friday- Chapter 4: Homework Assignment #2	0	\N
43487254	10563533	8548499	The Cardiovascular and Lymphatic System : Homework Assignment #6	72	\N
43487285	10563533	8548499	Infection Control:  Homework Assignment #7	75	\N
43487323	10563533	8548499	Capillary or Dermal Blood Specimens: Homework Assignment #8	69	\N
43487314	10563533	8548499	Venipuncture Procedures: Homework Assignment #9	73	\N
43487275	10563533	8548499	Preexamination/Preanaytical Complications: Homework Assignment #10	85	\N
43487321	10563533	8548499	WEEK ONE EXAM	60	\N
43487294	10563533	8548499	Chapter 3 : Basic Medical Terminology , the Human Body , and Cardiovascular System	30	\N
43487298	10563533	8548499	Chapter 7 : Preexamination/Preanalytical Complications	28	\N
43584511	10563533	8548499	(01/30/24) By Tuesday- READING 4- Chapter 9: Capillary or Dermal Blood Specimens	10	\N
43584613	10563533	8548499	(01/31/24) By Wednesday- READING 5- Chapter 7: Preexamination/Preanalytical Complications	10	\N
43584990	10563533	8548499	(02/01/24) By Thursday- READING 6- Chapter 3: Basic Medical Terminology, the Human Body, and the Cardiovascular System	10	\N
43587745	10563533	8548499	(02/01/24) On Thursday- Chapter 7: Homework Assignment #5	0	\N
43610788	10563533	8548499	 (01/29/24) By Monday - Chapter 8: Lecture Video	50	\N
43610807	10563533	8548499	(01/30/24) On Tuesday- Chapter 9: Lecture Video	50	\N
43610813	10563533	8548499	(01/31/24) On Wednesday- Chapter 7: Lecture Video	50	\N
43610816	10563533	8548499	(02/01/24) On Thursday- Chapter 6: Lecture Video	50	\N
43487289	10563534	8548499	Safety and First Aid: Homework Assignment #11	75	\N
43487312	10563534	8548499	Specimen Handling, Transportation, and Processing: Homework #12	70	\N
43487269	10563534	8548499	Pediatric and Geriatric Procedures: Homework #13	75	\N
43487306	10563534	8548499	Point-of Care collections: Homework #14	75	\N
43487315	10563534	8548499	Blood Cultures, Arterial, Intravenous (IV), and Special Collection Procedures: Homework #15	85	\N
43487272	10563534	8548499	WEEK TWO EXAM	60	\N
43830509	10563534	8548499	(02/06/24) By Tuesday- READING 7- Chapter 2: Ethical, Legal, and Regulatory Issues	10	\N
43832741	10563534	8548499	(02/08/24) By Thursday- READING 8- Chapter 1: Phlebotomy Practice and Quality Assessment Basics	10	\N
43824639	10563534	8548499	(02/05/24) By Monday- READING 6- Chapter 3: Basic Medical Terminology, the Human Body, and the Cardiovascular System -PART 2	10	\N
43487265	10563535	8548499	Urinalysis, Body Fluids, and Other Specimens: Homework # 16	75	\N
43487320	10563535	8548499	Drug use, Forensic Toxicology, Workplace Testing, Sports Medicine, and Related Areas: Homework Assignment #17	84	\N
43487340	10563535	8548499	NHA PRACTICE EXAM	100	\N
43487270	10563535	8548499	Chapter 10 : Pediatric and Geriatric Procedures	30	\N
43487264	10563535	8548499	Chapter 11 : Special Collections	30	\N
43487316	10563535	8548499	Chapter 5 : Documentation , Specimen Handling , and Transportation	30	\N
43963523	10563535	8548499	(02/13/24) By Tuesday- READING 9-Chapter 5: Documentation, Specimen Handling, and Transportation	10	\N
43963873	10563535	8548499	(02/13/24) On Tuesday- Chapter 5 Video Lecture	0	\N
43964030	10563535	8548499	(02/15/24) By Thursday- READING 10- Chapter 10: Pediatric and Geriatric Procedures	10	\N
43487332	10563536	8548499	Attendance/Log-in	100	\N
43487327	10563537	8548499	(01/22/24) By Tuesday- READING 1- Chapter 6: Blood Collection Equipment 	10	\N
43487334	10563537	8548499	Day #2.2a:  VEIN HANDOUT	0	\N
43833237	10563537	8548499	(02/08/24) By Thursday- READING 8- Chapter 1: Phlebotomy Practice and Quality Assessment Basics	10	\N
44104289	10563537	8548499	(02/19/24) By Monday- READING 11- Chapter 11: Special Collections	10	\N
43487325	10563537	8548499	Ten Commandments of Phlebotomy	100	\N
43487326	10563537	8548499	On Monday- Orientation Discussion Forum	100	\N
43487328	10563537	8548499	(01/23/24) By Wednesday- READING 2- Chapter 4: Safety and Infection Control	10	\N
44258445	10820832	8778669	IT'S TIME TO SHINE	100	\N
44258441	10820832	8778669	Cultural Competency in Healthcare	100	\N
44258446	10820832	8778669	Learning Styles	100	\N
44258444	10820832	8778669	How to study	100	\N
44258438	10820832	8778669	ABOUT YOUR NHA CERTIFICATION	100	\N
44258449	10820832	8778669	THE TEN COMMANDMENTS OF PHLEBOTOMY	0	\N
44258439	10820832	8778669	AVOIDING PHLEBOTOMY LAWSUITS	0	\N
44258443	10820832	8778669	Friday's Google Meets LInk	0	\N
44258376	10820832	8778669	Unnamed Quiz	0	\N
44258388	10820832	8778669	Chapter 9 : Capillary or Dermal Blood Specimens	30	\N
44258419	10820832	8778669	(02/28/24)  On Wednesday- Chapter 6: Homework Assignment #1	0	\N
44258421	10820832	8778669	(03/04/24) On Monday- Chapter 8: Homework Assignment #3	0	\N
44258424	10820832	8778669	(03/06/24) On Wednesday- Chapter 9: Homework Assignment #4	0	\N
44258428	10820832	8778669	(03/08/24) On Friday- Chapter 3: Homework Assignment #6	10	\N
44258408	10820833	8778669	Blood Collection Equipment: Homework Assignment #1	70	\N
44258400	10820833	8778669	Phlebotomy Practice and Quality Assessment: Homework Assignment #2	69	\N
44258403	10820833	8778669	Communication, Computer Essentials, and Documentation: Homework Assignment #3	80	\N
44258401	10820833	8778669	Professional Ethics, Legal, and Regulatory Issues:  Homework Assignment #4	76	\N
44258399	10820833	8778669	Medical Terminology, Anatomy, and Physiology of Organ Systems: Homework Assignment #5	73	\N
44258447	10820833	8778669	NHA PRACTICE EXAM	100	\N
44258375	10820833	8778669	Chapter 2 : Ethical , Legal , and Regulatory Issues	39	\N
44258394	10820833	8778669	Chapter 1 : Phlebotomy Practice and Quality Assessment Basics	34	\N
44258383	10820833	8778669	Chapter 8 : Venipuncture Procedures	30	\N
44258381	10820833	8778669	Chapter 4 : Safety and Infection Control	40	\N
44258405	10820833	8778669	Chapter 6 : Blood Collection Equipment	26	\N
44258416	10820833	8778669	 (02/29/24) By Friday- READING 3- Chapter 8: Venipuncture Procedures	10	\N
44258420	10820833	8778669	(03/01/24) On Friday- Chapter 4: Homework Assignment #2	0	\N
44258384	10820834	8778669	The Cardiovascular and Lymphatic System : Homework Assignment #6	72	\N
44258374	10820834	8778669	Infection Control:  Homework Assignment #7	75	\N
44258395	10820834	8778669	Capillary or Dermal Blood Specimens: Homework Assignment #8	69	\N
44258406	10820834	8778669	Venipuncture Procedures: Homework Assignment #9	73	\N
44258385	10820834	8778669	Preexamination/Preanaytical Complications: Homework Assignment #10	85	\N
44258392	10820834	8778669	WEEK ONE EXAM	60	\N
44258377	10820834	8778669	Chapter 3 : Basic Medical Terminology , the Human Body , and Cardiovascular System	30	\N
44258407	10820834	8778669	Chapter 7 : Preexamination/Preanalytical Complications	28	\N
44258422	10820834	8778669	(03/05/24) By Tuesday- READING 4- Chapter 9: Capillary or Dermal Blood Specimens	10	\N
44258423	10820834	8778669	(03/06/24) By Wednesday- READING 5- Chapter 7: Preexamination/Preanalytical Complications	10	\N
44258425	10820834	8778669	(03/07/24) By Thursday- READING 6- Chapter 3: Basic Medical Terminology, the Human Body, and the Cardiovascular System	10	\N
44258426	10820834	8778669	(03/07/24) On Thursday- Chapter 7: Homework Assignment #5	0	\N
44258410	10820834	8778669	(03/06/24) On Wednesday- Chapter 7: Lecture Video	50	\N
44258411	10820834	8778669	 (03/04/24) By Monday - Chapter 8: Lecture Video	50	\N
44258412	10820834	8778669	(03/05/24) On Tuesday- Chapter 9: Lecture Video	50	\N
44258413	10820834	8778669	(03/07/24) On Thursday- Chapter 6: Lecture Video	50	\N
44258397	10820835	8778669	Safety and First Aid: Homework Assignment #11	75	\N
44258398	10820835	8778669	Specimen Handling, Transportation, and Processing: Homework #12	70	\N
44258402	10820835	8778669	Pediatric and Geriatric Procedures: Homework #13	75	\N
44258378	10820835	8778669	Point-of Care collections: Homework #14	75	\N
44258387	10820835	8778669	Blood Cultures, Arterial, Intravenous (IV), and Special Collection Procedures: Homework #15	85	\N
44258404	10820835	8778669	WEEK TWO EXAM	60	\N
44258430	10820835	8778669	(03/12/24) By Tuesday- READING 7- Chapter 2: Ethical, Legal, and Regulatory Issues	10	\N
44258431	10820835	8778669	(03/14/24) By Thursday- READING 8- Chapter 1: Phlebotomy Practice and Quality Assessment Basics	10	\N
44258429	10820835	8778669	(03/11/24) By Monday- READING 6- Chapter 3: Basic Medical Terminology, the Human Body, and the Cardiovascular System -PART 2	10	\N
44258379	10820836	8778669	Urinalysis, Body Fluids, and Other Specimens: Homework # 16	75	\N
44258396	10820836	8778669	Drug use, Forensic Toxicology, Workplace Testing, Sports Medicine, and Related Areas: Homework Assignment #17	84	\N
44258448	10820836	8778669	NHA PRACTICE EXAM	100	\N
44258393	10820836	8778669	Chapter 10 : Pediatric and Geriatric Procedures	30	\N
44258389	10820836	8778669	Chapter 11 : Special Collections	30	\N
44258386	10820836	8778669	Chapter 5 : Documentation , Specimen Handling , and Transportation	30	\N
44258434	10820836	8778669	(03/19/24) By Tuesday- READING 9-Chapter 5: Documentation, Specimen Handling, and Transportation	10	\N
44258435	10820836	8778669	(03/19/24) On Tuesday- Chapter 5 Video Lecture	0	\N
44258436	10820836	8778669	(03/21/24) By Thursday- READING 10- Chapter 10: Pediatric and Geriatric Procedures	10	\N
44258440	10820837	8778669	Attendance/Log-in	100	\N
44258417	10820838	8778669	(02/26/24) By Tuesday- READING 1- Chapter 6: Blood Collection Equipment 	10	\N
44258442	10820838	8778669	Day #2.2a:  VEIN HANDOUT	0	\N
44258433	10820838	8778669	(03/14/2024) By Thursday- READING 8- Chapter 1: Phlebotomy Practice and Quality Assessment Basics	10	\N
44258437	10820838	8778669	(03/25/24) By Monday- READING 11- Chapter 11: Special Collections	10	\N
44258409	10820838	8778669	Ten Commandments of Phlebotomy	100	\N
44258414	10820838	8778669	On Monday- Orientation Discussion Forum	100	\N
44258418	10820838	8778669	(02/27/24) By Wednesday- READING 2- Chapter 4: Safety and Infection Control	10	\N
10153845	1930925	1450448	Phlebotomy Practice and Quality Assessment: Homework Assignment #2	69	\N
19591236	1930925	1450448	I Like myself, America and You can't stop me!  	100	\N
10154316	1930925	1450448	Infection Control:  Homework Assignment #7	75	\N
10234303	1930925	1450448	Blood Collection Equipment: Homework Assignment #1	70	\N
19591239	1930925	1450448	Learning Styles	100	\N
10201473	1930925	1450448	Venipuncture Procedures: Homework Assignment #9	73	\N
19591234	1930925	1450448	How to study	100	\N
10234356	1930925	1450448	Capillary or Dermal Blood Specimens: Homework Assignment #8	69	\N
10154432	1930925	1450448	Professional Ethics, Legal, and Regulatory Issues:  Homework Assignment #4	76	\N
19591237	1930925	1450448	It's time to shine!	100	\N
10156211	1930925	1450448	Communication, Computer Essentials, and Documentation: Homework Assignment #3	80	\N
10154567	1930925	1450448	Safety and First Aid: Homework Assignment #11	75	\N
10200922	1930925	1450448	Medical Terminology, Anatomy, and Physiology of Organ Systems: Homework Assignment #5	73	\N
10201160	1930925	1450448	The Cardiovascular and Lymphatic System : Homework Assignment #6	72	\N
10201367	1930925	1450448	Preexamination/Preanaytical Complications: Homework Assignment #10	85	\N
10234379	1930925	1450448	Specimen Handling, Transportation, and Processing: Homework #12	70	\N
10234380	1930925	1450448	Pediatric and Geriatric Procedures: Homework #13	75	\N
10234384	1930925	1450448	Point-of Care collections: Homework #14	75	\N
10234387	1930925	1450448	Blood Cultures, Arterial, Intravenous (IV), and Special Collection Procedures: Homework #15	85	\N
10234408	1930925	1450448	Urinalysis, Body Fluids, and Other Specimens: Homework # 16	75	\N
10234410	1930925	1450448	Drug use, Forensic Toxicology, Workplace Testing, Sports Medicine, and Related Areas: Homework Assignment #17	84	\N
10317853	1930925	1450448	ABOUT YOUR NHA CERTIFICATION	100	\N
10321737	1930925	1450448	Day #2.2a:  VEIN HANDOUT	0	\N
10234231	1930925	1450448	Day #2.2b: IN CLASS VEIN PROJECT	0	\N
10269743	1930925	1450448	Day #2.3:  IN-CLASS VIDEO AND BANANA PRACTICE	0	\N
12367221	1930925	1450448	Day 3.2b: Donning and doffing PPE Practice	0	\N
10169984	1930925	1450448	What NOT TO EVER NEVER Do as a phlebotomist!!!!	0	\N
12367215	1930925	1450448	Day 3.4: Intro. to Lab log and start dermal punctures	0	\N
10322310	1930925	1450448	Day 4.4b:  LAB REQUISITIONS AND RESULTS- REFERENCE RANGE HANDOUTS	0	\N
10322315	1930925	1450448	PRACTICE AIDET AND Banana Practice	0	\N
12419422	1930925	1450448	Day 4.4c: Start Nasco Arm Venipunctures and repeat the 3 veins	0	\N
10322337	1930925	1450448	Day #6 LAB CHECK-OFF DAY	0	\N
10322247	1930925	1450448	- PREEXAMINATION/PREANALYTICAL COMPLICATIONS (Jeopardy)	0	\N
10322332	1930925	1450448	Day #8 AHA BLS/CPR	0	\N
12490740	1930925	1450448	Day #6: Venipuncture Skills Check off #1	0	\N
12490742	1930925	1450448	Day # 6: Lab requisition  and overview with different labs	0	\N
14426542	1930925	1450448	Mastering Pediatric Phlebotomy	100	\N
14438176	1930925	1450448	Ten Commandments of Phlebotomy	100	\N
15770415	1930925	1450448	Venipuncture sign-up	0	\N
20748264	1930925	1450448	It's time to shine! Copy	100	\N
20748265	1930925	1450448	I Like myself, America and You can't stop me!   Copy	100	\N
20748266	1930925	1450448	Learning Styles Copy	100	\N
20748267	1930925	1450448	How to study Copy	100	\N
20828163	1930925	1450448	DAY# 1- LECTURE: CHAPTER 8: BLOOD COLLECTION EQUIPMENT FOR VENIPUNCTURES	0	\N
20830412	1930925	1450448	y	100	\N
36036482	1930925	1450448	Ten Commandments of Phlebotomy Copy	100	\N
20527105	3591944	1450448	Attendance/Log-in	100	\N
19593139	3591948	1450448	WEEK ONE EXAM	60	\N
19593247	3591948	1450448	WEEK TWO EXAM	60	\N
19593775	3591948	1450448	NHA PRACTICE EXAM	100	\N
19593779	3591948	1450448	NHA PRACTICE EXAM	100	\N
21460413	3917076	1450448	National COVID Ready Certification	100	\N
\.


--
-- Data for Name: assignmentgroup; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public.assignmentgroup (canvasid, courseid, name, weight, id) FROM stdin;
12490125	10281506	NSO2317- Trinity's Skills for Success	10	\N
12490126	10281506	EKG2414- Cardiac Anatomy and Physiology	20	\N
12490127	10281506	EKG2415- Cardiac Electrophysiology	15	\N
12490128	10281506	EKG2416- EKG Acquistion	15	\N
12490129	10281506	EKG2417- EKG Interpretation	15	\N
12490130	10281506	ATTENDANCE	25	\N
12677613	10441987	NSO2317- Trinity's Skills for Success	5	\N
12677614	10441987	Introduction to Healthcare	15	\N
12677615	10441987	Anatomy and Physiology	15	\N
12677616	10441987	Clinical Medical Assisting w/Lab	15	\N
12677617	10441987	Pharmacology w/ Calculations	15	\N
12677618	10441987	Administrative Medical Assisting	15	\N
12677619	10441987	EXPL2325- Career Exploration and Professionalism	15	\N
12677620	10441987	Imported Assignments	0	\N
12870722	10441987	Introduction to the Laboratoy 	5	\N
12675524	10440316	NSO2317- Trinity's Skills for Success	5	\N
12675525	10440316	PHL2416- Introduction to Human Anatomy and Medical Terminology	15	\N
12675526	10440316	PHL2417- Phlebotomy Basics	15	\N
12675527	10440316	PHL2418- Advanced Phlebotomy Procedures	10	\N
12675528	10440316	EXPL2325- Career Exploration and Professionalism	15	\N
12675529	10440316	Attendance/Log-in	40	\N
12882551	10627765	NSO2317- Trinity's Skills for Success	5	\N
12882552	10627765	PHL2416- Introduction to Human Anatomy and Medical Terminology	15	\N
12882553	10627765	PHL2417- Phlebotomy Basics	15	\N
12882554	10627765	PHL2418- Advanced Phlebotomy Procedures	10	\N
12882555	10627765	EXPL2325- Career Exploration and Professionalism	15	\N
12882556	10627765	Attendance/Log-in	40	\N
2941903	1977977	NSO2317- Trinity's Skills for Success	5	\N
11116032	1977977	Introduction to Healthcare	15	\N
11116038	1977977	Anatomy and Physiology	15	\N
11116042	1977977	Clinical Medical Assisting w/Lab	20	\N
11116044	1977977	Pharmacology w/ Calculations	15	\N
11116036	1977977	Administrative Medical Assisting	15	\N
11116067	1977977	EXPL2325- Career Exploration and Professionalism	15	\N
11878340	1977977	Imported Assignments	0	\N
7791730	6057101	Assignments	0	\N
3771679	1526010	Imported Assignments	0	\N
10724345	8690806	READING ASSIGNMENTS	10	\N
10873923	8690806	LECTURE ASSIGNMENTS	10	\N
10873887	8690806	QUIZZES	40	\N
11017516	8690806	MIDTERM AND FINAL EXAMS	10	\N
10874002	8690806	ATTENDANCE	30	\N
11175912	8690806	NSO2317- Trinity's Skills for Success	5	\N
11175937	8690806	EKG2314- Cardiac Anatomy and Physiology	25	\N
11449875	9366117	NSO2317- Trinity's Skills for Success	10	\N
11449876	9366117	EKG2414- Cardiac Anatomy and Physiology	20	\N
11637095	9366117	EKG2415- Cardiac Electrophysiology	15	\N
11637187	9366117	EKG2416- EKG Acquistion	15	\N
11449870	9366117	EKG2417- EKG Interpretation	15	\N
11449874	9366117	ATTENDANCE	25	\N
11701948	9587445	NSO2317- Trinity's Skills for Success	10	\N
11701949	9587445	EKG2414- Cardiac Anatomy and Physiology	20	\N
11701950	9587445	EKG2415- Cardiac Electrophysiology	15	\N
11701951	9587445	EKG2416- EKG Acquistion	15	\N
11701952	9587445	EKG2417- EKG Interpretation	15	\N
11701953	9587445	ATTENDANCE	25	\N
12327473	10140155	NSO2317- Trinity's Skills for Success	10	\N
12327474	10140155	EKG2414- Cardiac Anatomy and Physiology	20	\N
12327475	10140155	EKG2415- Cardiac Electrophysiology	15	\N
12327476	10140155	EKG2416- EKG Acquistion	15	\N
12327477	10140155	EKG2417- EKG Interpretation	15	\N
12327478	10140155	ATTENDANCE	25	\N
12499369	10289455	NSO2317- Trinity's Skills for Success	10	\N
12499370	10289455	EKG2414- Cardiac Anatomy and Physiology	20	\N
12499371	10289455	EKG2415- Cardiac Electrophysiology	15	\N
12499372	10289455	EKG2416- EKG Acquistion	15	\N
12499373	10289455	EKG2417- EKG Interpretation	15	\N
12499374	10289455	ATTENDANCE	25	\N
12022297	9868740	NSO2317- Trinity's Skills for Success	10	\N
12022298	9868740	EKG2414- Cardiac Anatomy and Physiology	20	\N
12022299	9868740	EKG2415- Cardiac Electrophysiology	15	\N
12022300	9868740	EKG2416- EKG Acquistion	15	\N
12022301	9868740	EKG2417- EKG Interpretation	15	\N
12022302	9868740	ATTENDANCE	25	\N
12789679	9868740	Imported Assignments	0	\N
12636518	10406845	Assignments	0	\N
12028635	9874687	Assignments	0	\N
12028718	9874687	PhPrac 7e Course Resources	0	\N
12028719	9874687	PhPrac 7e Ch01 - The Profession of Pharmacy	0	\N
12028720	9874687	PhPrac 7e Ch02 - Pharmacy Law, Regulations, and Standards	0	\N
12028721	9874687	PhPrac 7e Ch03 - Drug and Supplement Development	0	\N
12028722	9874687	PhPrac 7e Ch04 - Introducing Pharmacology	0	\N
12028723	9874687	PhPrac 7e Ch05 - Routes of Drug Administration and Dosage Formulations	0	\N
12028724	9874687	PhPrac 7e Ch06 - Pharmacy Measurements and Calculations	0	\N
12028725	9874687	PhPrac 7e Ch07 - Community Pharmacy Dispensing	0	\N
12028726	9874687	PhPrac 7e Ch08 - Prescription Drug Insurance in Health Care	0	\N
12028727	9874687	PhPrac 7e Ch09 - The Business of Community Pharmacy	0	\N
12028728	9874687	PhPrac 7e Ch10 - Extemporaneous, Nonsterile Compounding	0	\N
12028729	9874687	PhPrac 7e Ch11 - Hospital Pharmacy Dispensing	0	\N
12028730	9874687	PhPrac 7e Ch12 - Infection Control, Aseptic Technique, and Cleanroom Facilities	0	\N
12028731	9874687	PhPrac 7e Ch13 - Sterile and Hazardous Compounding	0	\N
12028732	9874687	PhPrac 7e Ch14 - Medication Safety	0	\N
12028733	9874687	PhPrac 7e Ch15 - Professional Performance, Communication, and Ethics	0	\N
12028734	9874687	PhPrac 7e Ch16 - Your Future in Pharmacy Practice	0	\N
12028735	9874687	PhPrac 7e Instructor-Created Exams	0	\N
12028737	9874687	Imported Assignments	0	\N
12674775	10439768	Assignments	0	\N
12674776	10439768	Imported Assignments	0	\N
12674777	10439768	PhPrac 7e Course Resources	0	\N
12674778	10439768	PhLabs 4e Course Resources	0	\N
12674779	10439768	PhPrac 7e Ch01 - The Profession of Pharmacy	0	\N
12674780	10439768	PhLabs 4e Lab01: Using Reference Materials in Pharmacy Practice	0	\N
12674781	10439768	PhPrac 7e Ch02 - Pharmacy Law, Regulations, and Standards	0	\N
12674782	10439768	PhLabs 4e Lab02: Practicing Professionalism in the Pharmacy	0	\N
12674783	10439768	PhPrac 7e Ch03 - Drug and Supplement Development	0	\N
12674784	10439768	PhLabs 4e Lab03: Customer Service and Point of Sale	0	\N
12674785	10439768	PhPrac 7e Ch04 - Introducing Pharmacology	0	\N
12674786	10439768	PhLabs 4e Lab04: Using a Pseudoephedrine Logbook	0	\N
12674787	10439768	PhPrac 7e Ch05 - Routes of Drug Administration and Dosage Formulations	0	\N
12674788	10439768	PhLabs 4e Lab05: Validating DEA Numbers	0	\N
12674789	10439768	PhPrac 7e Ch06 - Pharmacy Measurements and Calculations	0	\N
12674790	10439768	PhLabs 4e Lab06: Managing Pharmacy Inventory	0	\N
12674791	10439768	PhPrac 7e Ch07 - Community Pharmacy Dispensing	0	\N
12674792	10439768	PhLabs 4e Lab07: Obtaining and Reviewing a Patient Profile	0	\N
12674793	10439768	PhPrac 7e Ch08 - Prescription Drug Insurance in Health Care	0	\N
12674794	10439768	PhLabs 4e Lab08: Reviewing Signa Codes and Creating Patient Instructions	0	\N
12674795	10439768	PhPrac 7e Ch09 - The Business of Community Pharmacy	0	\N
12674796	10439768	PhLabs 4e Lab09: Reviewing a Prescription Form	0	\N
12674797	10439768	PhPrac 7e Ch10 - Extemporaneous, Nonsterile Compounding	0	\N
12674798	10439768	PhLabs 4e Lab10: Reviewing a Filled Prescription	0	\N
12674799	10439768	PhPrac 7e Ch11 - Hospital Pharmacy Dispensing	0	\N
12674800	10439768	PhLabs 4e Lab11: Entering Patient Data	0	\N
12674801	10439768	PhPrac 7e Ch12 - Infection Control, Aseptic Technique, and Cleanroom Facilities	0	\N
12674802	10439768	PhLabs 4e Lab12: Processing a Prescription	0	\N
12674803	10439768	PhPrac 7e Ch13 - Sterile and Hazardous Compounding	0	\N
12674804	10439768	PhLabs 4e Lab13: Processing a Refill	0	\N
12674805	10439768	PhPrac 7e Ch14 - Medication Safety	0	\N
12674806	10439768	PhLabs 4e Lab14: Obtaining Refill Authorization	0	\N
12674807	10439768	PhPrac 7e Ch15 - Professional Performance, Communication, and Ethics	0	\N
12674808	10439768	PhLabs 4e Lab15: Processing Third-Party Claims	0	\N
12674809	10439768	PhPrac 7e Ch16 - Your Future in Pharmacy Practice	0	\N
12674810	10439768	PhLabs 4e Lab16: Verifying Cash Pricing 	0	\N
12674811	10439768	PhPrac 7e Instructor-Created Exams	0	\N
12674812	10439768	PhLabs 4e Lab17: Workflow in the Pharmacy	0	\N
12674813	10439768	PhLabs 4e Lab18: Reconstituting Powdered Drugs	0	\N
12674814	10439768	PhLabs 4e Lab19: Documenting and Preparing Immunizations	0	\N
12674815	10439768	PhLabs 4e Lab20: ISMP Tall-Man Lettering and Look-Alike, Sound-Alike Drugs	0	\N
12674816	10439768	PhLabs 4e Lab21: Filling a 24-Hour Medication Cart	0	\N
12674817	10439768	PhLabs 4e Lab22: Filling and Checking Floor Stock	0	\N
12674818	10439768	PhLabs 4e Lab23: Filling and Recording Controlled Substances Floor Stock	0	\N
12674819	10439768	PhLabs 4e Lab24: Preparing Oral Syringes	0	\N
12674820	10439768	PhLabs 4e Lab25: Charging and Refilling a Crash Cart	0	\N
12674821	10439768	PhLabs 4e Lab26: Filling an Automated Drug Storage and Dispensing System	0	\N
12674822	10439768	PhLabs 4e Lab27: Point-of-Care Testing	0	\N
12674823	10439768	PhLabs 4e Lab28: Producing Computerized Reports	0	\N
12674824	10439768	PhLabs 4e Lab29: Medication Therapy Management	0	\N
12674825	10439768	PhLabs 4e Lab30: Drug Recalls and Shortages	0	\N
12674826	10439768	PhLabs 4e Lab31: Medication Reconciliation	0	\N
12674827	10439768	PhLabs 4e Lab32: Reviewing Investigational Drug Documentation	0	\N
12674828	10439768	PhLabs 4e Lab33: Reviewing Medication Orders	0	\N
12674829	10439768	PhLabs 4e Lab34: Cleaning Up a Hazardous Drug Spill	0	\N
12674830	10439768	PhLabs 4e Lab35: Filling Capsules	0	\N
12674831	10439768	PhLabs 4e Lab36: Preparing Suspensions from Tablets	0	\N
12674832	10439768	PhLabs 4e Lab37: Preparing Suspensions from Capsules	0	\N
12674834	10439768	PhLabs 4e Lab38: Preparing Creams, Ointments, Gels, and Pastes	0	\N
12674835	10439768	PhLabs 4e Lab39: Garbing According to USP <797> Standards	0	\N
12674836	10439768	PhLabs 4e Lab40: Aseptic Hand Washing	0	\N
12674837	10439768	PhLabs 4e Lab41: Hood Cleaning	0	\N
12674838	10439768	PhLabs 4e Lab42: Preparing Large-Volume Parenteral Solutions	0	\N
12674839	10439768	PhLabs 4e Lab43: Preparing Small-Volume Parenteral Solutions	0	\N
12674840	10439768	PhLabs 4e Lab44: Preparing Sterile Powdered Drug Vials	0	\N
12674841	10439768	PhLabs 4e Lab45: Using Ampules	0	\N
12674842	10439768	PhLabs 4e Lab46: Compounding Chemotherapy Drugs	0	\N
12674843	10439768	PhLabs 4e Instructor-Created Exams	0	\N
12674844	10439768	New Assignments	0	\N
12674845	10439768	Quizzes	0	\N
11884713	9746185	Assignments	0	\N
11884714	9746185	Imported Assignments	0	\N
11884715	9746185	PhLabs 4e Course Resources	0	\N
11884716	9746185	PhLabs 4e Lab01: Using Reference Materials in Pharmacy Practice	0	\N
11884717	9746185	PhLabs 4e Lab02: Practicing Professionalism in the Pharmacy	0	\N
11884718	9746185	PhLabs 4e Lab03: Customer Service and Point of Sale	0	\N
11884719	9746185	PhLabs 4e Lab04: Using a Pseudoephedrine Logbook	0	\N
11884720	9746185	PhLabs 4e Lab05: Validating DEA Numbers	0	\N
11884721	9746185	PhLabs 4e Lab06: Managing Pharmacy Inventory	0	\N
11884722	9746185	PhLabs 4e Lab07: Obtaining and Reviewing a Patient Profile	0	\N
11884723	9746185	PhLabs 4e Lab08: Reviewing Signa Codes and Creating Patient Instructions	0	\N
11884724	9746185	PhLabs 4e Lab09: Reviewing a Prescription Form	0	\N
11884725	9746185	PhLabs 4e Lab10: Reviewing a Filled Prescription	0	\N
11884726	9746185	PhLabs 4e Lab11: Entering Patient Data	0	\N
11884727	9746185	PhLabs 4e Lab12: Processing a Prescription	0	\N
11884728	9746185	PhLabs 4e Lab13: Processing a Refill	0	\N
11884729	9746185	PhLabs 4e Lab14: Obtaining Refill Authorization	0	\N
11884730	9746185	PhLabs 4e Lab15: Processing Third-Party Claims	0	\N
11884731	9746185	PhLabs 4e Lab16: Verifying Cash Pricing 	0	\N
11884732	9746185	PhLabs 4e Lab17: Workflow in the Pharmacy	0	\N
11884733	9746185	PhLabs 4e Lab18: Reconstituting Powdered Drugs	0	\N
11884734	9746185	PhLabs 4e Lab19: Documenting and Preparing Immunizations	0	\N
11884735	9746185	PhLabs 4e Lab20: ISMP Tall-Man Lettering and Look-Alike, Sound-Alike Drugs	0	\N
11884736	9746185	PhLabs 4e Lab21: Filling a 24-Hour Medication Cart	0	\N
11884737	9746185	PhLabs 4e Lab22: Filling and Checking Floor Stock	0	\N
11884738	9746185	PhLabs 4e Lab23: Filling and Recording Controlled Substances Floor Stock	0	\N
11884739	9746185	PhLabs 4e Lab24: Preparing Oral Syringes	0	\N
11884740	9746185	PhLabs 4e Lab25: Charging and Refilling a Crash Cart	0	\N
11884741	9746185	PhLabs 4e Lab26: Filling an Automated Drug Storage and Dispensing System	0	\N
11884742	9746185	PhLabs 4e Lab27: Point-of-Care Testing	0	\N
11884743	9746185	PhLabs 4e Lab28: Producing Computerized Reports	0	\N
11884744	9746185	PhLabs 4e Lab29: Medication Therapy Management	0	\N
11884745	9746185	PhLabs 4e Lab30: Drug Recalls and Shortages	0	\N
11884746	9746185	PhLabs 4e Lab31: Medication Reconciliation	0	\N
11884747	9746185	PhLabs 4e Lab32: Reviewing Investigational Drug Documentation	0	\N
11884748	9746185	PhLabs 4e Lab33: Reviewing Medication Orders	0	\N
11884749	9746185	PhLabs 4e Lab34: Cleaning Up a Hazardous Drug Spill	0	\N
11884750	9746185	PhLabs 4e Lab35: Filling Capsules	0	\N
11884751	9746185	PhLabs 4e Lab36: Preparing Suspensions from Tablets	0	\N
11884752	9746185	PhLabs 4e Lab37: Preparing Suspensions from Capsules	0	\N
11884753	9746185	PhLabs 4e Lab38: Preparing Creams, Ointments, Gels, and Pastes	0	\N
11884754	9746185	PhLabs 4e Lab39: Garbing According to USP <797> Standards	0	\N
11884755	9746185	PhLabs 4e Lab40: Aseptic Hand Washing	0	\N
11884756	9746185	PhLabs 4e Lab41: Hood Cleaning	0	\N
11884757	9746185	PhLabs 4e Lab42: Preparing Large-Volume Parenteral Solutions	0	\N
11884758	9746185	PhLabs 4e Lab43: Preparing Small-Volume Parenteral Solutions	0	\N
11884759	9746185	PhLabs 4e Lab44: Preparing Sterile Powdered Drug Vials	0	\N
11884760	9746185	PhLabs 4e Lab45: Using Ampules	0	\N
11884761	9746185	PhLabs 4e Lab46: Compounding Chemotherapy Drugs	0	\N
11884762	9746185	PhLabs 4e Instructor-Created Exams	0	\N
11884763	9746185	New Assignments	0	\N
11884764	9746185	Quizzes	0	\N
1893067	1433500	Assignments	0	\N
1937957	1433500	Imported Assignments	0	\N
12028773	1433500	PhPrac 7e Course Resources	0	\N
4249132	1433500	PhLabs 4e Course Resources	0	\N
12028774	1433500	PhPrac 7e Ch01 - The Profession of Pharmacy	0	\N
4249133	1433500	PhLabs 4e Lab01: Using Reference Materials in Pharmacy Practice	0	\N
12028775	1433500	PhPrac 7e Ch02 - Pharmacy Law, Regulations, and Standards	0	\N
4249134	1433500	PhLabs 4e Lab02: Practicing Professionalism in the Pharmacy	0	\N
12028776	1433500	PhPrac 7e Ch03 - Drug and Supplement Development	0	\N
4249135	1433500	PhLabs 4e Lab03: Customer Service and Point of Sale	0	\N
12028777	1433500	PhPrac 7e Ch04 - Introducing Pharmacology	0	\N
4249136	1433500	PhLabs 4e Lab04: Using a Pseudoephedrine Logbook	0	\N
12028778	1433500	PhPrac 7e Ch05 - Routes of Drug Administration and Dosage Formulations	0	\N
4249137	1433500	PhLabs 4e Lab05: Validating DEA Numbers	0	\N
12028779	1433500	PhPrac 7e Ch06 - Pharmacy Measurements and Calculations	0	\N
4249138	1433500	PhLabs 4e Lab06: Managing Pharmacy Inventory	0	\N
12028780	1433500	PhPrac 7e Ch07 - Community Pharmacy Dispensing	0	\N
4249139	1433500	PhLabs 4e Lab07: Obtaining and Reviewing a Patient Profile	0	\N
12028781	1433500	PhPrac 7e Ch08 - Prescription Drug Insurance in Health Care	0	\N
4249140	1433500	PhLabs 4e Lab08: Reviewing Signa Codes and Creating Patient Instructions	0	\N
12028782	1433500	PhPrac 7e Ch09 - The Business of Community Pharmacy	0	\N
4249141	1433500	PhLabs 4e Lab09: Reviewing a Prescription Form	0	\N
12028783	1433500	PhPrac 7e Ch10 - Extemporaneous, Nonsterile Compounding	0	\N
4249142	1433500	PhLabs 4e Lab10: Reviewing a Filled Prescription	0	\N
12028784	1433500	PhPrac 7e Ch11 - Hospital Pharmacy Dispensing	0	\N
4249143	1433500	PhLabs 4e Lab11: Entering Patient Data	0	\N
12028785	1433500	PhPrac 7e Ch12 - Infection Control, Aseptic Technique, and Cleanroom Facilities	0	\N
4249144	1433500	PhLabs 4e Lab12: Processing a Prescription	0	\N
12028786	1433500	PhPrac 7e Ch13 - Sterile and Hazardous Compounding	0	\N
4249145	1433500	PhLabs 4e Lab13: Processing a Refill	0	\N
12028787	1433500	PhPrac 7e Ch14 - Medication Safety	0	\N
4249146	1433500	PhLabs 4e Lab14: Obtaining Refill Authorization	0	\N
12028788	1433500	PhPrac 7e Ch15 - Professional Performance, Communication, and Ethics	0	\N
4249147	1433500	PhLabs 4e Lab15: Processing Third-Party Claims	0	\N
12028789	1433500	PhPrac 7e Ch16 - Your Future in Pharmacy Practice	0	\N
4249148	1433500	PhLabs 4e Lab16: Verifying Cash Pricing 	0	\N
12028790	1433500	PhPrac 7e Instructor-Created Exams	0	\N
4249149	1433500	PhLabs 4e Lab17: Workflow in the Pharmacy	0	\N
4249150	1433500	PhLabs 4e Lab18: Reconstituting Powdered Drugs	0	\N
4249151	1433500	PhLabs 4e Lab19: Documenting and Preparing Immunizations	0	\N
4249152	1433500	PhLabs 4e Lab20: ISMP Tall-Man Lettering and Look-Alike, Sound-Alike Drugs	0	\N
4249153	1433500	PhLabs 4e Lab21: Filling a 24-Hour Medication Cart	0	\N
4249154	1433500	PhLabs 4e Lab22: Filling and Checking Floor Stock	0	\N
4249155	1433500	PhLabs 4e Lab23: Filling and Recording Controlled Substances Floor Stock	0	\N
4249156	1433500	PhLabs 4e Lab24: Preparing Oral Syringes	0	\N
4249157	1433500	PhLabs 4e Lab25: Charging and Refilling a Crash Cart	0	\N
4249158	1433500	PhLabs 4e Lab26: Filling an Automated Drug Storage and Dispensing System	0	\N
4249159	1433500	PhLabs 4e Lab27: Point-of-Care Testing	0	\N
4249160	1433500	PhLabs 4e Lab28: Producing Computerized Reports	0	\N
4249161	1433500	PhLabs 4e Lab29: Medication Therapy Management	0	\N
4249162	1433500	PhLabs 4e Lab30: Drug Recalls and Shortages	0	\N
4249163	1433500	PhLabs 4e Lab31: Medication Reconciliation	0	\N
4249164	1433500	PhLabs 4e Lab32: Reviewing Investigational Drug Documentation	0	\N
4249165	1433500	PhLabs 4e Lab33: Reviewing Medication Orders	0	\N
4249166	1433500	PhLabs 4e Lab34: Cleaning Up a Hazardous Drug Spill	0	\N
4249167	1433500	PhLabs 4e Lab35: Filling Capsules	0	\N
4249168	1433500	PhLabs 4e Lab36: Preparing Suspensions from Tablets	0	\N
4249169	1433500	PhLabs 4e Lab37: Preparing Suspensions from Capsules	0	\N
4249170	1433500	PhLabs 4e Lab38: Preparing Creams, Ointments, Gels, and Pastes	0	\N
4249171	1433500	PhLabs 4e Lab39: Garbing According to USP <797> Standards	0	\N
4249172	1433500	PhLabs 4e Lab40: Aseptic Hand Washing	0	\N
4249173	1433500	PhLabs 4e Lab41: Hood Cleaning	0	\N
4249174	1433500	PhLabs 4e Lab42: Preparing Large-Volume Parenteral Solutions	0	\N
4249175	1433500	PhLabs 4e Lab43: Preparing Small-Volume Parenteral Solutions	0	\N
4249176	1433500	PhLabs 4e Lab44: Preparing Sterile Powdered Drug Vials	0	\N
4249177	1433500	PhLabs 4e Lab45: Using Ampules	0	\N
4249178	1433500	PhLabs 4e Lab46: Compounding Chemotherapy Drugs	0	\N
4249179	1433500	PhLabs 4e Instructor-Created Exams	0	\N
4249180	1433500	New Assignments	0	\N
4249181	1433500	Quizzes	0	\N
12499023	10289143	NSO2317- Trinity's Skills for Success	5	\N
12499024	10289143	PHL2416- Introduction to Human Anatomy and Medical Terminology	15	\N
12499025	10289143	PHL2417- Phlebotomy Basics	15	\N
12499026	10289143	PHL2418- Advanced Phlebotomy Procedures	10	\N
12499027	10289143	EXPL2325- Career Exploration and Professionalism	15	\N
12499028	10289143	Attendance/Log-in	40	\N
12154193	9987831	NSO2317- Trinity's Skills for Success	5	\N
12154194	9987831	PHL2416- Introduction to Human Anatomy and Medical Terminology	15	\N
12154195	9987831	PHL2417- Phlebotomy Basics	15	\N
12154196	9987831	PHL2418- Advanced Phlebotomy Procedures	10	\N
12154197	9987831	EXPL2325- Career Exploration and Professionalism	15	\N
12154198	9987831	Attendance/Log-in	40	\N
7670348	5952410	NSO2317- Trinity's Skills for Success	5	\N
7670350	5952410	PHL2416- Introduction to Human Anatomy and Medical Terminology	15	\N
7670351	5952410	PHL2417- Phlebotomy Basics	15	\N
7670352	5952410	PHL2418- Advanced Phlebotomy Procedures	10	\N
7670349	5952410	EXPL2325- Career Exploration and Professionalism	15	\N
7670353	5952410	Attendance/Log-in	40	\N
11585772	9483594	NSO2317- Trinity's Skills for Success	5	\N
11585773	9483594	PHL2416- Introduction to Human Anatomy and Medical Terminology	15	\N
11585774	9483594	PHL2417- Phlebotomy Basics	15	\N
11585775	9483594	PHL2418- Advanced Phlebotomy Procedures	10	\N
11585776	9483594	EXPL2325- Career Exploration and Professionalism	15	\N
11585777	9483594	Attendance/Log-in	40	\N
11811054	9681492	NSO2317- Trinity's Skills for Success	5	\N
11811055	9681492	PHL2416- Introduction to Human Anatomy and Medical Terminology	15	\N
11811057	9681492	PHL2417- Phlebotomy Basics	15	\N
11811059	9681492	PHL2418- Advanced Phlebotomy Procedures	10	\N
11811061	9681492	EXPL2325- Career Exploration and Professionalism	15	\N
11811063	9681492	Attendance/Log-in	40	\N
11449116	9365544	NSO2317- Trinity's Skills for Success	5	\N
11449117	9365544	PHL2416- Introduction to Human Anatomy and Medical Terminology	15	\N
11449118	9365544	PHL2417- Phlebotomy Basics	15	\N
11449119	9365544	PHL2418- Advanced Phlebotomy Procedures	10	\N
11449120	9365544	EXPL2325- Career Exploration and Professionalism	15	\N
11449121	9365544	Attendance/Log-in	40	\N
10563531	8548499	Orientation	5	\N
10563532	8548499	Week 1	15	\N
10563533	8548499	Week 2	15	\N
10563534	8548499	Week 3	15	\N
10563535	8548499	Week 4	10	\N
10563536	8548499	Attendance/Log-in	40	\N
10563537	8548499	Imported Assignments	0	\N
10820832	8778669	Orientation	5	\N
10820833	8778669	Week 1	15	\N
10820834	8778669	Week 2	15	\N
10820835	8778669	Week 3	15	\N
10820836	8778669	Week 4	10	\N
10820837	8778669	Attendance/Log-in	40	\N
10820838	8778669	Imported Assignments	0	\N
1930925	1450448	Assignments	40	\N
3591944	1450448	Attendance/Log-in	40	\N
3591948	1450448	Quizzes	20	\N
3917076	1450448	Imported Assignments	0	\N
\.


--
-- Data for Name: assignmentsubmission; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public.assignmentsubmission (canvasid, coursestudentid, assignmentid, studentid, score, attemptnumber, id) FROM stdin;
641714800	10281506_112532815	49581105	112532815	0	0	\N
641714801	10281506_112532815	49581106	112532815	0	0	\N
641714806	10281506_112532815	49581112	112532815	14	2	\N
641714807	10281506_112532815	49581113	112532815	22	2	\N
641714809	10281506_112532815	49581116	112532815	100	1	\N
641714810	10281506_112532815	49581117	112532815	0	0	\N
641714811	10281506_112532815	49581118	112532815	0	0	\N
641714812	10281506_112532815	49581119	112532815	0	0	\N
641714813	10281506_112532815	49581121	112532815	0	0	\N
641714814	10281506_112532815	49581122	112532815	0	0	\N
641714815	10281506_112532815	49581123	112532815	0	0	\N
641714816	10281506_112532815	49581124	112532815	0	0	\N
641714817	10281506_112532815	49581125	112532815	0	0	\N
641714818	10281506_112532815	49581126	112532815	0	0	\N
641714819	10281506_112532815	49581127	112532815	0	0	\N
641714820	10281506_112532815	49581128	112532815	10	1	\N
641714821	10281506_112532815	49581129	112532815	0	0	\N
641714822	10281506_112532815	49581130	112532815	0	0	\N
641714823	10281506_112532815	49581131	112532815	10	1	\N
641714824	10281506_112532815	49581132	112532815	0	0	\N
641714825	10281506_112532815	49581133	112532815	0	0	\N
641714831	10281506_112532815	49581141	112532815	0	0	\N
641714837	10281506_112532815	49581147	112532815	50	1	\N
641714838	10281506_112532815	49581149	112532815	0	0	\N
641714839	10281506_112532815	49581150	112532815	0	0	\N
641714840	10281506_112532815	49581151	112532815	0	0	\N
641714841	10281506_112532815	49581152	112532815	0	0	\N
641714842	10281506_112532815	49581153	112532815	0	0	\N
641714843	10281506_112532815	49581154	112532815	0	0	\N
641714844	10281506_112532815	49581155	112532815	50	1	\N
641714845	10281506_112532815	49581156	112532815	0	0	\N
641714846	10281506_112532815	49581157	112532815	0	0	\N
641714847	10281506_112532815	49581158	112532815	50	1	\N
641714848	10281506_112532815	49581159	112532815	0	0	\N
641714876	10281506_112532933	49581100	112532933	14	1	\N
641714877	10281506_112532933	49581101	112532933	12	1	\N
641714878	10281506_112532933	49581102	112532933	13	1	\N
641714879	10281506_112532933	49581103	112532933	11.83333333333333	2	\N
641714880	10281506_112532933	49581104	112532933	12	1	\N
641714881	10281506_112532933	49581105	112532933	9.083333333333334	3	\N
641714882	10281506_112532933	49581106	112532933	0	0	\N
641714883	10281506_112532933	49581108	112532933	7.5	3	\N
641714885	10281506_112532933	49581110	112532933	9.833333333333334	3	\N
641714886	10281506_112532933	49581111	112532933	16.5	2	\N
641714887	10281506_112532933	49581112	112532933	9	1	\N
641714888	10281506_112532933	49581113	112532933	21.75	3	\N
641714889	10281506_112532933	49581114	112532933	15	3	\N
641714890	10281506_112532933	49581116	112532933	100	1	\N
641714891	10281506_112532933	49581117	112532933	100	1	\N
641714892	10281506_112532933	49581118	112532933	100	1	\N
641714893	10281506_112532933	49581119	112532933	100	1	\N
641714894	10281506_112532933	49581121	112532933	10	1	\N
641714895	10281506_112532933	49581122	112532933	10	1	\N
641714896	10281506_112532933	49581123	112532933	10	1	\N
641714897	10281506_112532933	49581124	112532933	10	1	\N
641714898	10281506_112532933	49581125	112532933	10	1	\N
641714899	10281506_112532933	49581126	112532933	10	1	\N
641714900	10281506_112532933	49581127	112532933	10	1	\N
641714901	10281506_112532933	49581128	112532933	10	1	\N
641714902	10281506_112532933	49581129	112532933	10	1	\N
641714903	10281506_112532933	49581130	112532933	10	1	\N
641714904	10281506_112532933	49581131	112532933	10	1	\N
641714905	10281506_112532933	49581132	112532933	10	1	\N
641714906	10281506_112532933	49581133	112532933	100	1	\N
641714912	10281506_112532933	49581141	112532933	10	1	\N
641714918	10281506_112532933	49581147	112532933	50	1	\N
641714919	10281506_112532933	49581149	112532933	50	1	\N
641714920	10281506_112532933	49581150	112532933	50	1	\N
641714921	10281506_112532933	49581151	112532933	50	1	\N
641714922	10281506_112532933	49581152	112532933	50	1	\N
641714923	10281506_112532933	49581153	112532933	50	1	\N
641714924	10281506_112532933	49581154	112532933	50	1	\N
641714925	10281506_112532933	49581155	112532933	50	1	\N
641714926	10281506_112532933	49581156	112532933	50	1	\N
641714927	10281506_112532933	49581157	112532933	50	1	\N
641714928	10281506_112532933	49581158	112532933	50	1	\N
641714929	10281506_112532933	49581159	112532933	50	1	\N
641714943	10281506_112532775	49581100	112532775	11	1	\N
641714948	10281506_112532775	49581105	112532775	0	0	\N
641714949	10281506_112532775	49581106	112532775	0	0	\N
641714957	10281506_112532775	49581116	112532775	0	0	\N
641714958	10281506_112532775	49581117	112532775	0	0	\N
641714959	10281506_112532775	49581118	112532775	0	0	\N
641714960	10281506_112532775	49581119	112532775	0	0	\N
641714961	10281506_112532775	49581121	112532775	10	1	\N
641714962	10281506_112532775	49581122	112532775	0	0	\N
641714963	10281506_112532775	49581123	112532775	0	0	\N
641714964	10281506_112532775	49581124	112532775	0	0	\N
641714965	10281506_112532775	49581125	112532775	0	0	\N
641714966	10281506_112532775	49581126	112532775	0	0	\N
641714967	10281506_112532775	49581127	112532775	0	0	\N
641714968	10281506_112532775	49581128	112532775	10	1	\N
641714969	10281506_112532775	49581129	112532775	0	0	\N
641714970	10281506_112532775	49581130	112532775	0	0	\N
641714971	10281506_112532775	49581131	112532775	0	0	\N
641714972	10281506_112532775	49581132	112532775	0	0	\N
641714973	10281506_112532775	49581133	112532775	0	0	\N
641714979	10281506_112532775	49581141	112532775	0	0	\N
641714985	10281506_112532775	49581147	112532775	50	1	\N
641714986	10281506_112532775	49581149	112532775	0	0	\N
635092029	10441987_113035256	50221397	113035256	72.66666666666667	3	\N
635092030	10441987_113531825	50221397	113531825	74	2	\N
635092031	10441987_113532285	50221397	113532285	71	1	\N
635092032	10441987_113534765	50221397	113534765	73.66666666666667	2	\N
635092033	10441987_113555087	50221397	113555087	73.66666666666667	1	\N
635092034	10441987_113589293	50221397	113589293	75	1	\N
635092041	10441987_113035256	50221399	113035256	75	3	\N
635092042	10441987_113531825	50221399	113531825	75	2	\N
635092043	10441987_113532285	50221399	113532285	73	1	\N
635092044	10441987_113534765	50221399	113534765	74	2	\N
635092045	10441987_113555087	50221399	113555087	73	1	\N
635092046	10441987_113589293	50221399	113589293	75	1	\N
635092047	10441987_113035256	50221400	113035256	73.66666666666667	2	\N
635092048	10441987_113531825	50221400	113531825	75	2	\N
635092049	10441987_113532285	50221400	113532285	67.6	1	\N
635092050	10441987_113534765	50221400	113534765	65.66666666666667	1	\N
635092051	10441987_113555087	50221400	113555087	70	1	\N
635092052	10441987_113589293	50221400	113589293	74.66666666666667	1	\N
635092053	10441987_113035256	50221401	113035256	74.16666666666667	3	\N
635092054	10441987_113531825	50221401	113531825	74.33333333333333	2	\N
635092055	10441987_113532285	50221401	113532285	55	1	\N
635092056	10441987_113534765	50221401	113534765	70.33333333333333	1	\N
635092057	10441987_113555087	50221401	113555087	74	1	\N
635092058	10441987_113589293	50221401	113589293	75	2	\N
635092059	10441987_113035256	50221402	113035256	71.75	3	\N
635092060	10441987_113531825	50221402	113531825	74.5	2	\N
635092061	10441987_113532285	50221402	113532285	72.75	2	\N
635092062	10441987_113534765	50221402	113534765	72.5	2	\N
635092063	10441987_113555087	50221402	113555087	74.5	1	\N
635092064	10441987_113589293	50221402	113589293	74	1	\N
635092065	10441987_113035256	50221404	113035256	74	2	\N
635092066	10441987_113531825	50221404	113531825	74	2	\N
635092067	10441987_113532285	50221404	113532285	69	1	\N
635092068	10441987_113534765	50221404	113534765	73	1	\N
635092069	10441987_113555087	50221404	113555087	71	1	\N
634962998	10440316_111910517	50212550	111910517	66	1	\N
634963000	10440316_112532775	50212550	112532775	61	1	\N
634963002	10440316_112532815	50212550	112532815	58.5	1	\N
634963003	10440316_112532933	50212550	112532933	72	1	\N
634963004	10440316_112532940	50212550	112532940	66.5	1	\N
634963005	10440316_112533159	50212550	112533159	75	1	\N
634963007	10440316_113868907	50212550	113868907	60.5	1	\N
634963008	10440316_111910517	50212551	111910517	63	1	\N
634963010	10440316_112532775	50212551	112532775	68	1	\N
634963012	10440316_112532815	50212551	112532815	58	1	\N
634963013	10440316_112532933	50212551	112532933	65	1	\N
634963014	10440316_112532940	50212551	112532940	69	1	\N
634963015	10440316_112533159	50212551	112533159	67	1	\N
634963017	10440316_113868907	50212551	113868907	60	1	\N
634963018	10440316_111910517	50212552	111910517	78	1	\N
634963020	10440316_112532775	50212552	112532775	71.5	1	\N
634963022	10440316_112532815	50212552	112532815	66	1	\N
634963023	10440316_112532933	50212552	112532933	67.5	1	\N
634963024	10440316_112532940	50212552	112532940	55	1	\N
634963025	10440316_112533159	50212552	112533159	84	1	\N
634963027	10440316_113868907	50212552	113868907	55	1	\N
634963028	10440316_111910517	50212553	111910517	60	1	\N
634963030	10440316_112532775	50212553	112532775	75	1	\N
634963032	10440316_112532815	50212553	112532815	71.5	1	\N
634963033	10440316_112532933	50212553	112532933	84	1	\N
634963034	10440316_112532940	50212553	112532940	79	1	\N
634963035	10440316_112533159	50212553	112533159	85	1	\N
634963037	10440316_113868907	50212553	113868907	63	1	\N
634963038	10440316_111910517	50212554	111910517	63	1	\N
634963040	10440316_112532775	50212554	112532775	51	1	\N
634963042	10440316_112532815	50212554	112532815	63	1	\N
634963043	10440316_112532933	50212554	112532933	71	1	\N
634963044	10440316_112532940	50212554	112532940	53.5	1	\N
634963045	10440316_112533159	50212554	112533159	62.5	1	\N
634963047	10440316_113868907	50212554	113868907	59	1	\N
634963048	10440316_111910517	50212555	111910517	47	1	\N
634963050	10440316_112532775	50212555	112532775	43	1	\N
634963052	10440316_112532815	50212555	112532815	50	1	\N
634963053	10440316_112532933	50212555	112532933	54	1	\N
634963054	10440316_112532940	50212555	112532940	55	1	\N
634963055	10440316_112533159	50212555	112533159	56	1	\N
634963057	10440316_113868907	50212555	113868907	54	1	\N
634963058	10440316_111910517	50212556	111910517	64	1	\N
634963060	10440316_112532775	50212556	112532775	72	1	\N
634963062	10440316_112532815	50212556	112532815	69	1	\N
634963063	10440316_112532933	50212556	112532933	73	1	\N
634963064	10440316_112532940	50212556	112532940	65	1	\N
634963065	10440316_112533159	50212556	112533159	70	1	\N
634963067	10440316_113868907	50212556	113868907	62	1	\N
634963068	10440316_111910517	50212557	111910517	62	1	\N
634963070	10440316_112532775	50212557	112532775	60	1	\N
634963072	10440316_112532815	50212557	112532815	55	1	\N
634963073	10440316_112532933	50212557	112532933	75	1	\N
634963074	10440316_112532940	50212557	112532940	69	1	\N
634963075	10440316_112533159	50212557	112533159	74	1	\N
634963077	10440316_113868907	50212557	113868907	62	1	\N
634963078	10440316_111910517	50212558	111910517	55	1	\N
634963080	10440316_112532775	50212558	112532775	65	1	\N
634963082	10440316_112532815	50212558	112532815	63	1	\N
634963083	10440316_112532933	50212558	112532933	58.5	1	\N
634963084	10440316_112532940	50212558	112532940	63	1	\N
634963085	10440316_112533159	50212558	112533159	72	1	\N
634963087	10440316_113868907	50212558	113868907	58.5	1	\N
634963088	10440316_111910517	50212559	111910517	54	1	\N
634963090	10440316_112532775	50212559	112532775	65	1	\N
634963092	10440316_112532815	50212559	112532815	60	1	\N
634963093	10440316_112532933	50212559	112532933	65	1	\N
634963094	10440316_112532940	50212559	112532940	65	1	\N
634963095	10440316_112533159	50212559	112533159	70	1	\N
634963097	10440316_113868907	50212559	113868907	66	3	\N
634963098	10440316_111910517	50212560	111910517	40	2	\N
634963100	10440316_112532775	50212560	112532775	56	1	\N
634963102	10440316_112532815	50212560	112532815	47	1	\N
634963103	10440316_112532933	50212560	112532933	47	3	\N
634963104	10440316_112532940	50212560	112532940	47	1	\N
634963105	10440316_112533159	50212560	112533159	53	1	\N
634963107	10440316_113868907	50212560	113868907	45	2	\N
634963108	10440316_111910517	50212562	111910517	65	2	\N
634963110	10440316_112532775	50212562	112532775	70	2	\N
634963112	10440316_112532815	50212562	112532815	67	1	\N
634963113	10440316_112532933	50212562	112532933	70	2	\N
634963114	10440316_112532940	50212562	112532940	59	1	\N
634963115	10440316_112533159	50212562	112533159	53	1	\N
634963117	10440316_113868907	50212562	113868907	67	3	\N
634963118	10440316_111910517	50212563	111910517	65	1	\N
634963120	10440316_112532775	50212563	112532775	61.5	1	\N
634963122	10440316_112532815	50212563	112532815	49.5	1	\N
634963123	10440316_112532933	50212563	112532933	61	1	\N
634963124	10440316_112532940	50212563	112532940	53	1	\N
634963125	10440316_112533159	50212563	112533159	55	1	\N
634963127	10440316_113868907	50212563	113868907	51.5	1	\N
640611647	10627765_114290807	50818431	114290807	48.5	1	\N
640611648	10627765_114290807	50818432	114290807	60	1	\N
640611650	10627765_114290807	50818435	114290807	45	1	\N
640611651	10627765_114290807	50818437	114290807	66	1	\N
640611652	10627765_114290807	50818438	114290807	61	1	\N
640611653	10627765_114290807	50818439	114290807	71	1	\N
640611654	10627765_114290807	50818440	114290807	56.5	1	\N
640611655	10627765_114290807	50818441	114290807	59.5	1	\N
640611656	10627765_114290807	50818442	114290807	64	1	\N
640611658	10627765_114290807	50818444	114290807	59	1	\N
640611660	10627765_114290807	50818446	114290807	67	1	\N
640611663	10627765_114290807	50818450	114290807	41	1	\N
640611664	10627765_114290807	50818452	114290807	59.5	1	\N
640611665	10627765_114290807	50818453	114290807	56	1	\N
640611668	10627765_114290807	50818456	114290807	79	0	\N
640611669	10627765_114290807	50818458	114290807	100	1	\N
640611671	10627765_114290807	50818460	114290807	100	1	\N
640611672	10627765_114290807	50818461	114290807	100	1	\N
640611673	10627765_114290807	50818462	114290807	100	1	\N
335124737	1526010_29174142	20748275	29174142	100	0	\N
335124742	1526010_29174142	20748276	29174142	100	0	\N
364576227	1526010_30186217	20748272	30186217	100	1	\N
364576229	1526010_30186217	20748275	30186217	100	1	\N
364576230	1526010_30186217	20748276	30186217	100	1	\N
417596765	1526010_24888056	27173136	24888056	0	0	\N
417599580	1526010_24888056	27173680	24888056	0	0	\N
417603344	1526010_32617388	20748275	32617388	0	0	\N
417603347	1526010_32617388	27173136	32617388	10	0	\N
417603348	1526010_32617388	27173649	32617388	12	2	\N
417603349	1526010_32617388	27173680	32617388	50	0	\N
417615467	1526010_32617388	27175827	32617388	10	0	\N
417667287	1526010_32617388	27182734	32617388	23.5	2	\N
417881594	1526010_32617388	27176290	32617388	50	0	\N
417882212	1526010_24888056	27225890	24888056	0	0	\N
417882259	1526010_32617388	27225890	32617388	10	0	\N
417882616	1526010_24888056	27226180	24888056	0	0	\N
417882663	1526010_32617388	27226180	32617388	50	0	\N
418185158	1526010_32617388	27281660	32617388	14	2	\N
430564249	1526010_33052949	27173136	33052949	10	0	\N
430564250	1526010_33052949	27173680	33052949	50	0	\N
430572673	1526010_33052949	27173649	33052949	13	2	\N
431440651	1526010_33052949	27175827	33052949	10	0	\N
431440716	1526010_33052949	27176290	33052949	50	0	\N
431440762	1526010_33052949	27182734	33052949	20.25	1	\N
431440777	1526010_33052949	27225890	33052949	0	0	\N
431441189	1526010_33052949	27226180	33052949	0	0	\N
431924474	1526010_24888056	28265266	24888056	0	0	\N
431924523	1526010_32617388	28265266	32617388	10	0	\N
431924527	1526010_33052949	28265266	33052949	0	0	\N
582743483	8690806_109743202	43983120	109743202	10.33333333333333	1	\N
582743487	8690806_110810384	43983120	110810384	8.5	3	\N
582743490	8690806_110811306	43983120	110811306	8.666666666666666	3	\N
582743491	8690806_110811478	43983120	110811478	2.666666666666667	1	\N
582743496	8690806_110821071	43983120	110821071	5.833333333333333	3	\N
582743507	8690806_110847016	43983120	110847016	1	1	\N
582743509	8690806_109743202	43983121	109743202	12.5	2	\N
582743513	8690806_110810384	43983121	110810384	9.5	4	\N
582743516	8690806_110811306	43983121	110811306	6.75	3	\N
582743517	8690806_110811478	43983121	110811478	10.25	1	\N
582743522	8690806_110821071	43983121	110821071	16	4	\N
582743533	8690806_110847016	43983121	110847016	9	3	\N
582743535	8690806_109743202	43983122	109743202	19.25	2	\N
582743539	8690806_110810384	43983122	110810384	16.5	4	\N
582743542	8690806_110811306	43983122	110811306	9.25	1	\N
582743543	8690806_110811478	43983122	110811478	20.25	2	\N
582743548	8690806_110821071	43983122	110821071	8.75	1	\N
582743559	8690806_110847016	43983122	110847016	19	1	\N
582743561	8690806_109743202	43983123	109743202	10	1	\N
582743565	8690806_110810384	43983123	110810384	10	1	\N
582743568	8690806_110811306	43983123	110811306	12	1	\N
582743569	8690806_110811478	43983123	110811478	14	1	\N
582743574	8690806_110821071	43983123	110821071	9	3	\N
582743585	8690806_110847016	43983123	110847016	15	3	\N
582743591	8690806_110810384	43983124	110810384	4	1	\N
582743594	8690806_110811306	43983124	110811306	10	2	\N
596056753	9366117_111855687	45969068	111855687	13	3	\N
596056754	9366117_111855687	45969069	111855687	0	0	\N
596056755	9366117_111855687	45969070	111855687	0	0	\N
596056759	9366117_111855687	45969076	111855687	9.5	2	\N
596056761	9366117_111855687	45969078	111855687	20.75	2	\N
596056765	9366117_111855687	45969082	111855687	13	3	\N
596056766	9366117_111855687	45969083	111855687	0	0	\N
596056767	9366117_111855687	45969084	111855687	0	0	\N
596056768	9366117_111855687	45969085	111855687	0	0	\N
596056769	9366117_111855687	45969086	111855687	100	1	\N
596056770	9366117_111855687	45969087	111855687	10	1	\N
596056771	9366117_111855687	45969089	111855687	0	0	\N
596056772	9366117_111855687	45969091	111855687	0	0	\N
596056773	9366117_111855687	45969092	111855687	0	0	\N
596056774	9366117_111855687	45969093	111855687	10	1	\N
596056775	9366117_111855687	45969094	111855687	0	0	\N
596056777	9366117_111855687	45969096	111855687	10	1	\N
596056778	9366117_111855687	45969097	111855687	0	0	\N
596056779	9366117_111855687	45969098	111855687	0	0	\N
596056780	9366117_111855687	45969099	111855687	10	1	\N
596056781	9366117_111855687	45969100	111855687	0	0	\N
596056782	9366117_111855687	45969101	111855687	0	0	\N
596056783	9366117_111855687	45969102	111855687	100	1	\N
596056788	9366117_111855687	45969109	111855687	10	1	\N
596056789	9366117_111855687	45969110	111855687	100	1	\N
596056790	9366117_111855687	45969111	111855687	100	1	\N
596056791	9366117_111855687	45969112	111855687	100	1	\N
596056793	9366117_111855687	45969117	111855687	50	1	\N
596056794	9366117_111855687	45969118	111855687	0	0	\N
596056795	9366117_111855687	45969119	111855687	0	0	\N
596056796	9366117_111855687	45969120	111855687	0	0	\N
596056797	9366117_111855687	45969122	111855687	0	0	\N
596056798	9366117_111855687	45969123	111855687	0	0	\N
596056799	9366117_111855687	45969124	111855687	0	0	\N
596056800	9366117_111855687	45969125	111855687	50	1	\N
596056801	9366117_111855687	45969126	111855687	0	0	\N
596056802	9366117_111855687	45969127	111855687	0	0	\N
596056803	9366117_111855687	45969128	111855687	50	1	\N
596056804	9366117_111855687	45969129	111855687	0	0	\N
603208349	9587445_111245545	46851867	111245545	10.5	1	\N
603208352	9587445_111854690	46851867	111854690	10	2	\N
603208354	9587445_111854768	46851867	111854768	10	1	\N
603208355	9587445_111854794	46851867	111854794	20	6	\N
603208357	9587445_111854878	46851867	111854878	12.5	2	\N
603208361	9587445_111855080	46851867	111855080	11.75	1	\N
603208362	9587445_111855153	46851867	111855153	11.25	1	\N
603208364	9587445_111245545	46851868	111245545	0	0	\N
603208367	9587445_111854690	46851868	111854690	10.75	3	\N
603208369	9587445_111854768	46851868	111854768	10.08333333333333	3	\N
603208370	9587445_111854794	46851868	111854794	9.416666666666666	2	\N
603208372	9587445_111854878	46851868	111854878	9.75	2	\N
603208376	9587445_111855080	46851868	111855080	8.25	1	\N
603208377	9587445_111855153	46851868	111855153	8.25	1	\N
603208379	9587445_111245545	46851869	111245545	7	1	\N
603208382	9587445_111854690	46851869	111854690	8.5	1	\N
603208384	9587445_111854768	46851869	111854768	6.5	1	\N
603208385	9587445_111854794	46851869	111854794	13.5	3	\N
603208387	9587445_111854878	46851869	111854878	10	3	\N
603208391	9587445_111855080	46851869	111855080	7.5	3	\N
603208392	9587445_111855153	46851869	111855153	7.5	1	\N
603208397	9587445_111854690	46851870	111854690	0	0	\N
603208399	9587445_111854768	46851870	111854768	0	0	\N
603208400	9587445_111854794	46851870	111854794	0	0	\N
603208402	9587445_111854878	46851870	111854878	12.66666666666667	1	\N
603208407	9587445_111855153	46851870	111855153	12.33333333333333	1	\N
603208412	9587445_111854690	46851871	111854690	0	0	\N
603208414	9587445_111854768	46851871	111854768	0	0	\N
603208415	9587445_111854794	46851871	111854794	0	0	\N
603208417	9587445_111854878	46851871	111854878	9.75	1	\N
603208422	9587445_111855153	46851871	111855153	9.166666666666666	1	\N
603208442	9587445_111854690	46851873	111854690	0	0	\N
603208444	9587445_111854768	46851873	111854768	0	0	\N
603208445	9587445_111854794	46851873	111854794	15	2	\N
603208447	9587445_111854878	46851873	111854878	13	1	\N
626136271	10140155_113531825	49018790	113531825	15	2	\N
626136272	10140155_113531825	49018791	113531825	194	2	\N
626136273	10140155_113531825	49018792	113531825	27	3	\N
626136274	10140155_113531825	49018794	113531825	14	3	\N
626136276	10140155_113531825	49018797	113531825	14.66666666666667	3	\N
626136277	10140155_113531825	49018799	113531825	15	2	\N
626136278	10140155_113531825	49018800	113531825	13.5	3	\N
626136279	10140155_113531825	49018801	113531825	11	3	\N
626136280	10140155_113531825	49018802	113531825	14	3	\N
626136281	10140155_113531825	49018803	113531825	12.66666666666666	3	\N
626136282	10140155_113531825	49018804	113531825	14	3	\N
626136283	10140155_113531825	49018805	113531825	17	6	\N
626136284	10140155_113531825	49018807	113531825	15	3	\N
626136285	10140155_113531825	49018809	113531825	100	1	\N
626136286	10140155_113531825	49018810	113531825	100	1	\N
626136287	10140155_113531825	49018811	113531825	100	1	\N
626136288	10140155_113531825	49018812	113531825	100	1	\N
626136289	10140155_113531825	49018813	113531825	10	1	\N
626136290	10140155_113531825	49018814	113531825	10	1	\N
626136291	10140155_113531825	49018815	113531825	10	1	\N
626136292	10140155_113531825	49018816	113531825	10	1	\N
626136293	10140155_113531825	49018818	113531825	10	1	\N
626136294	10140155_113531825	49018819	113531825	10	1	\N
626136295	10140155_113531825	49018820	113531825	10	1	\N
626136296	10140155_113531825	49018822	113531825	10	1	\N
626136297	10140155_113531825	49018823	113531825	10	1	\N
626136298	10140155_113531825	49018824	113531825	10	1	\N
626136299	10140155_113531825	49018825	113531825	10	1	\N
626136300	10140155_113531825	49018826	113531825	10	1	\N
626136301	10140155_113531825	49018827	113531825	100	1	\N
626136302	10140155_113531825	49018828	113531825	100	1	\N
626136307	10140155_113531825	49018833	113531825	10	1	\N
626136308	10140155_113531825	49018834	113531825	100	1	\N
626136309	10140155_113531825	49018835	113531825	100	1	\N
626136310	10140155_113531825	49018836	113531825	100	1	\N
626136312	10140155_113531825	49018838	113531825	50	1	\N
626136313	10140155_113531825	49018839	113531825	50	1	\N
626136314	10140155_113531825	49018840	113531825	50	1	\N
626136315	10140155_113531825	49018841	113531825	50	1	\N
626136316	10140155_113531825	49018842	113531825	50	1	\N
626136317	10140155_113531825	49018843	113531825	50	1	\N
626136318	10140155_113531825	49018844	113531825	50	1	\N
626136319	10140155_113531825	49018845	113531825	50	1	\N
626136320	10140155_113531825	49018846	113531825	50	1	\N
626136321	10140155_113531825	49018847	113531825	50	1	\N
626136322	10140155_113531825	49018848	113531825	50	1	\N
626136323	10140155_113531825	49018849	113531825	50	1	\N
626136324	10140155_113531825	49018850	113531825	100	1	\N
626149531	10140155_113532285	49018790	113532285	13	2	\N
626149532	10140155_113532285	49018791	113532285	182	2	\N
626149533	10140155_113532285	49018792	113532285	27	3	\N
626149534	10140155_113532285	49018794	113532285	10	2	\N
626149536	10140155_113532285	49018797	113532285	13.66666666666667	2	\N
626149537	10140155_113532285	49018799	113532285	15	2	\N
626149538	10140155_113532285	49018800	113532285	10.16666666666667	3	\N
626149539	10140155_113532285	49018801	113532285	10	3	\N
626149540	10140155_113532285	49018802	113532285	14	2	\N
626149541	10140155_113532285	49018803	113532285	1.333333333333333	2	\N
626149542	10140155_113532285	49018804	113532285	11.83333333333333	3	\N
626149543	10140155_113532285	49018805	113532285	20	6	\N
626149544	10140155_113532285	49018807	113532285	10	2	\N
626149545	10140155_113532285	49018809	113532285	100	1	\N
626149546	10140155_113532285	49018810	113532285	100	1	\N
626149547	10140155_113532285	49018811	113532285	100	1	\N
626149548	10140155_113532285	49018812	113532285	100	1	\N
626149549	10140155_113532285	49018813	113532285	10	1	\N
626149550	10140155_113532285	49018814	113532285	10	1	\N
626149551	10140155_113532285	49018815	113532285	10	1	\N
610287600	9868740_110374761	48034281	110374761	15	2	\N
610287602	9868740_110374761	48034284	110374761	27	3	\N
610287604	9868740_110374761	48034285	110374761	15	1	\N
610287606	9868740_110374761	48034287	110374761	15	2	\N
610287610	9868740_110374761	48034292	110374761	12	2	\N
610287612	9868740_110374761	48034293	110374761	17	2	\N
610287614	9868740_110374761	48034294	110374761	1	1	\N
610287618	9868740_110374761	48034296	110374761	15	3	\N
610287620	9868740_110374761	48034297	110374761	7.166666666666667	3	\N
634462734	9868740_113589293	48034281	113589293	14	1	\N
634462735	9868740_113589293	48034284	113589293	28	2	\N
634462736	9868740_113589293	48034285	113589293	15	1	\N
634462737	9868740_113589293	48034287	113589293	15	2	\N
634462739	9868740_113589293	48034292	113589293	10	1	\N
634462740	9868740_113589293	48034293	113589293	12.5	1	\N
634462741	9868740_113589293	48034294	113589293	7.916666666666667	1	\N
634462743	9868740_113589293	48034296	113589293	13.33333333333333	1	\N
634462744	9868740_113589293	48034297	113589293	10.5	1	\N
634464574	9868740_113035256	48034281	113035256	13.5	3	\N
634464575	9868740_113035256	48034284	113035256	30	3	\N
634464576	9868740_113035256	48034285	113035256	15	1	\N
634464577	9868740_113035256	48034287	113035256	15	2	\N
634464579	9868740_113035256	48034292	113035256	12	3	\N
634464580	9868740_113035256	48034293	113035256	15.5	1	\N
634464581	9868740_113035256	48034294	113035256	12.83333333333333	2	\N
634464583	9868740_113035256	48034296	113035256	11.33333333333333	2	\N
634464584	9868740_113035256	48034297	113035256	8.5	1	\N
634464638	9868740_113533500	48034281	113533500	9	3	\N
634464639	9868740_113533500	48034284	113533500	20	3	\N
634464640	9868740_113533500	48034285	113533500	10	3	\N
634464641	9868740_113533500	48034287	113533500	13	3	\N
634464643	9868740_113533500	48034292	113533500	8	3	\N
634464644	9868740_113533500	48034293	113533500	12.25	6	\N
634464645	9868740_113533500	48034294	113533500	9.666666666666666	3	\N
634464647	9868740_113533500	48034296	113533500	10.33333333333333	3	\N
634464648	9868740_113533500	48034297	113533500	7.833333333333333	3	\N
638043867	9868740_113533500	50547659	113533500	0	3	\N
607711603	9746185_112541526	47597956	112541526	6	2	\N
608920705	9746185_112643419	47597956	112643419	38	3	\N
608920706	9746185_112643419	47597961	112643419	23	1	\N
608920717	9746185_112643419	47597980	112643419	34.66666666666666	1	\N
608920729	9746185_112643419	47597994	112643419	11	2	\N
608920737	9746185_112643419	47598003	112643419	8	1	\N
608920739	9746185_112643419	47598005	112643419	18	1	\N
608920747	9746185_112643419	47598014	112643419	30	2	\N
634966556	9746185_113932088	47597961	113932088	20	1	\N
634966579	9746185_113932088	47597994	113932088	13	2	\N
634966587	9746185_113932088	47598003	113932088	10	2	\N
634966597	9746185_113932088	47598014	113932088	27	2	\N
626651815	10289143_113553522	49607458	113553522	57	1	\N
626651816	10289143_113553522	49607460	113553522	66	1	\N
626651818	10289143_113553522	49607462	113553522	74	2	\N
626651819	10289143_113553522	49607463	113553522	46	1	\N
626651820	10289143_113553522	49607464	113553522	59	2	\N
626651821	10289143_113553522	49607465	113553522	34	1	\N
626651822	10289143_113553522	49607466	113553522	48	2	\N
626651825	10289143_113553522	49607469	113553522	65	2	\N
626651826	10289143_113553522	49607470	113553522	62	1	\N
626651827	10289143_113553522	49607471	113553522	49.5	1	\N
626651828	10289143_113553522	49607472	113553522	47	1	\N
626651829	10289143_113553522	49607473	113553522	54	1	\N
626651831	10289143_113553522	49607475	113553522	78	1	\N
626651832	10289143_113553522	49607476	113553522	53	1	\N
626651837	10289143_113553522	49607484	113553522	100	1	\N
626651840	10289143_113553522	49607487	113553522	100	1	\N
612626869	9987831_112923870	48438825	112923870	55.5	1	\N
612626870	9987831_112923870	48438826	112923870	51	1	\N
612626871	9987831_112923870	48438827	112923870	35	1	\N
612626872	9987831_112923870	48438828	112923870	57.5	1	\N
612626873	9987831_112923870	48438829	112923870	60	1	\N
612626874	9987831_112923870	48438830	112923870	70	1	\N
612626875	9987831_112923870	48438831	112923870	68	1	\N
612626876	9987831_112923870	48438832	112923870	65	1	\N
612626877	9987831_112923870	48438833	112923870	48.5	1	\N
612626878	9987831_112923870	48438834	112923870	62	1	\N
612626879	9987831_112923870	48438835	112923870	67	1	\N
612626880	9987831_112923870	48438836	112923870	56.5	1	\N
612626881	9987831_112923870	48438837	112923870	52.5	1	\N
612626882	9987831_112923870	48438838	112923870	53	1	\N
612626883	9987831_112923870	48438839	112923870	59	1	\N
612626884	9987831_112923870	48438840	112923870	72	1	\N
612626885	9987831_112923870	48438841	112923870	72	1	\N
612626886	9987831_112923870	48438842	112923870	20	1	\N
612626887	9987831_112923870	48438843	112923870	77	1	\N
612626888	9987831_112923870	48438844	112923870	100	0	\N
612626890	9987831_112923870	48438846	112923870	82	0	\N
612626891	9987831_112923870	48438847	112923870	100	1	\N
612626893	9987831_112923870	48438849	112923870	100	1	\N
612626894	9987831_112923870	48438850	112923870	100	1	\N
612626895	9987831_112923870	48438851	112923870	100	1	\N
612626896	9987831_112923870	48438852	112923870	82	0	\N
612626897	9987831_112923870	48438853	112923870	82	0	\N
612633255	9987831_112924292	48438828	112924292	29	1	\N
612633265	9987831_112924292	48438838	112924292	66.5	3	\N
612633271	9987831_112924292	48438844	112924292	100	0	\N
612633274	9987831_112924292	48438847	112924292	100	1	\N
612633276	9987831_112924292	48438849	112924292	100	1	\N
612633277	9987831_112924292	48438850	112924292	100	1	\N
612633278	9987831_112924292	48438851	112924292	100	1	\N
612784844	9987831_112448163	48438844	112448163	100	0	\N
612784847	9987831_112448163	48438847	112448163	100	0	\N
612784849	9987831_112448163	48438849	112448163	100	0	\N
612784850	9987831_112448163	48438850	112448163	100	0	\N
612784851	9987831_112448163	48438851	112448163	100	0	\N
614436021	9987831_113035256	48438825	113035256	67	2	\N
614436022	9987831_113035256	48438826	113035256	33	1	\N
614436023	9987831_113035256	48438827	113035256	31	1	\N
614436024	9987831_113035256	48438828	113035256	69	2	\N
614436025	9987831_113035256	48438829	113035256	67	3	\N
614436026	9987831_113035256	48438830	113035256	85	1	\N
614436027	9987831_113035256	48438831	113035256	66	1	\N
614436028	9987831_113035256	48438832	113035256	74	2	\N
614436029	9987831_113035256	48438833	113035256	48.5	1	\N
614436030	9987831_113035256	48438834	113035256	50	1	\N
614436031	9987831_113035256	48438835	113035256	69	2	\N
614436032	9987831_113035256	48438836	113035256	50	1	\N
614436033	9987831_113035256	48438837	113035256	57	1	\N
614436034	9987831_113035256	48438838	113035256	67	2	\N
614436035	9987831_113035256	48438839	113035256	66	2	\N
614436036	9987831_113035256	48438840	113035256	70	2	\N
614436037	9987831_113035256	48438841	113035256	58	2	\N
614436038	9987831_113035256	48438842	113035256	34	2	\N
614436039	9987831_113035256	48438843	113035256	68	2	\N
614436042	9987831_113035256	48438846	113035256	81	0	\N
614436043	9987831_113035256	48438847	113035256	100	1	\N
614436045	9987831_113035256	48438849	113035256	100	1	\N
614436046	9987831_113035256	48438850	113035256	100	1	\N
614436047	9987831_113035256	48438851	113035256	100	1	\N
614436048	9987831_113035256	48438852	113035256	80	0	\N
614436049	9987831_113035256	48438853	113035256	87	0	\N
615528835	9987831_111855449	48438825	111855449	45	2	\N
615528836	9987831_111855449	48438826	111855449	52	1	\N
615528837	9987831_111855449	48438827	111855449	46	2	\N
615528838	9987831_111855449	48438828	111855449	55	2	\N
615528839	9987831_111855449	48438829	111855449	59	2	\N
615528840	9987831_111855449	48438830	111855449	57	1	\N
615528841	9987831_111855449	48438831	111855449	60	1	\N
615528842	9987831_111855449	48438832	111855449	73	2	\N
615528843	9987831_111855449	48438833	111855449	63	2	\N
615528844	9987831_111855449	48438834	111855449	69	1	\N
615528845	9987831_111855449	48438835	111855449	62.5	2	\N
615528846	9987831_111855449	48438836	111855449	54	2	\N
615528847	9987831_111855449	48438837	111855449	62	1	\N
615528848	9987831_111855449	48438838	111855449	69	2	\N
615528849	9987831_111855449	48438839	111855449	67	2	\N
615528850	9987831_111855449	48438840	111855449	70	2	\N
615528851	9987831_111855449	48438841	111855449	77	2	\N
615528852	9987831_111855449	48438842	111855449	37	1	\N
615528853	9987831_111855449	48438843	111855449	61	1	\N
615528854	9987831_111855449	48438844	111855449	100	0	\N
615528856	9987831_111855449	48438846	111855449	81	0	\N
615528857	9987831_111855449	48438847	111855449	100	0	\N
615528859	9987831_111855449	48438849	111855449	100	1	\N
615528861	9987831_111855449	48438851	111855449	100	0	\N
615528862	9987831_111855449	48438852	111855449	77	0	\N
615528863	9987831_111855449	48438853	111855449	85	0	\N
621049039	9987831_112121477	48438825	112121477	63.5	0	\N
621049040	9987831_112121477	48438826	112121477	41	1	\N
621049042	9987831_112121477	48438828	112121477	50	0	\N
621049043	9987831_112121477	48438829	112121477	55.5	0	\N
621049047	9987831_112121477	48438833	112121477	53.5	0	\N
621049048	9987831_112121477	48438834	112121477	73	1	\N
621049051	9987831_112121477	48438837	112121477	58	0	\N
621049052	9987831_112121477	48438838	112121477	45	0	\N
621049053	9987831_112121477	48438839	112121477	63.5	0	\N
590438946	5952410_111548843	34645446	111548843	82	1	\N
590438947	5952410_111548843	34645453	111548843	51	1	\N
590438948	5952410_111548843	34645458	111548843	67.5	1	\N
590438949	5952410_111548843	34645462	111548843	72.5	1	\N
590438950	5952410_111548843	34645467	111548843	72	1	\N
590438951	5952410_111548843	34645471	111548843	61	3	\N
590438952	5952410_111548843	34645476	111548843	66	1	\N
590438953	5952410_111548843	34645480	111548843	70	2	\N
590438954	5952410_111548843	34645481	111548843	85	1	\N
590438955	5952410_111548843	34645482	111548843	72.5	2	\N
590438956	5952410_111548843	34645485	111548843	67.5	1	\N
590438957	5952410_111548843	34645486	111548843	69	2	\N
590438958	5952410_111548843	34645487	111548843	72	1	\N
590438959	5952410_111548843	34645488	111548843	74	1	\N
590438960	5952410_111548843	34645489	111548843	75	1	\N
590438961	5952410_111548843	34645490	111548843	66.5	1	\N
590438962	5952410_111548843	34645491	111548843	57	2	\N
590438963	5952410_111548843	34645492	111548843	43	2	\N
590438964	5952410_111548843	34645493	111548843	80	1	\N
590438968	5952410_111548843	34645500	111548843	100	1	\N
590438970	5952410_111548843	34645502	111548843	100	1	\N
590438971	5952410_111548843	34645503	111548843	100	1	\N
590438972	5952410_111548843	34645504	111548843	100	1	\N
590439119	5952410_111548857	34645446	111548857	0	0	\N
590439120	5952410_111548857	34645453	111548857	50	1	\N
590439121	5952410_111548857	34645458	111548857	68	1	\N
590439122	5952410_111548857	34645462	111548857	71.5	1	\N
590439123	5952410_111548857	34645467	111548857	69.5	2	\N
590439124	5952410_111548857	34645471	111548857	68	3	\N
590439125	5952410_111548857	34645476	111548857	68	2	\N
590439126	5952410_111548857	34645480	111548857	66	2	\N
590439127	5952410_111548857	34645481	111548857	77	1	\N
590439128	5952410_111548857	34645482	111548857	65	2	\N
590439129	5952410_111548857	34645485	111548857	67.5	2	\N
590439130	5952410_111548857	34645486	111548857	64.5	2	\N
590439131	5952410_111548857	34645487	111548857	73	2	\N
590439132	5952410_111548857	34645488	111548857	72	2	\N
590439133	5952410_111548857	34645489	111548857	67	1	\N
590439134	5952410_111548857	34645490	111548857	69	2	\N
590439135	5952410_111548857	34645491	111548857	0	0	\N
590439136	5952410_111548857	34645492	111548857	53	2	\N
590439137	5952410_111548857	34645493	111548857	68	1	\N
590439140	5952410_111548857	34645499	111548857	96	0	\N
590439141	5952410_111548857	34645500	111548857	100	1	\N
590439143	5952410_111548857	34645502	111548857	100	1	\N
590439144	5952410_111548857	34645503	111548857	100	1	\N
590439145	5952410_111548857	34645504	111548857	100	1	\N
590439146	5952410_111548857	34645505	111548857	74	0	\N
590439147	5952410_111548857	34645506	111548857	68	0	\N
590439195	5952410_111548864	34645446	111548864	0	0	\N
590439196	5952410_111548864	34645453	111548864	52	1	\N
590439197	5952410_111548864	34645458	111548864	69	1	\N
590439198	5952410_111548864	34645462	111548864	72.5	1	\N
590439199	5952410_111548864	34645467	111548864	70	1	\N
590439200	5952410_111548864	34645471	111548864	61	2	\N
590439201	5952410_111548864	34645476	111548864	73	1	\N
590439202	5952410_111548864	34645480	111548864	70	2	\N
590439203	5952410_111548864	34645481	111548864	69	1	\N
590439204	5952410_111548864	34645482	111548864	65	2	\N
590439205	5952410_111548864	34645485	111548864	64	1	\N
590439206	5952410_111548864	34645486	111548864	68	2	\N
590439207	5952410_111548864	34645487	111548864	71	1	\N
590439208	5952410_111548864	34645488	111548864	73	1	\N
590439209	5952410_111548864	34645489	111548864	73	1	\N
590439210	5952410_111548864	34645490	111548864	66	2	\N
590439211	5952410_111548864	34645491	111548864	50	1	\N
590439212	5952410_111548864	34645492	111548864	52	2	\N
590439213	5952410_111548864	34645493	111548864	68	1	\N
590439216	5952410_111548864	34645499	111548864	98	0	\N
590439217	5952410_111548864	34645500	111548864	100	1	\N
590439219	5952410_111548864	34645502	111548864	100	1	\N
590439220	5952410_111548864	34645503	111548864	100	1	\N
590439221	5952410_111548864	34645504	111548864	100	1	\N
590439222	5952410_111548864	34645505	111548864	70	0	\N
590439223	5952410_111548864	34645506	111548864	79	0	\N
590439303	5952410_111548873	34645446	111548873	0	0	\N
590439304	5952410_111548873	34645453	111548873	53	1	\N
601010653	9483594_112121403	46449958	112121403	64	1	\N
601010654	9483594_112121403	46449959	112121403	66	1	\N
601010655	9483594_112121403	46449960	112121403	70	1	\N
601010656	9483594_112121403	46449961	112121403	80	1	\N
601010657	9483594_112121403	46449962	112121403	61	1	\N
601010658	9483594_112121403	46449963	112121403	80	1	\N
601010659	9483594_112121403	46449964	112121403	72	1	\N
601010660	9483594_112121403	46449965	112121403	47	1	\N
601010661	9483594_112121403	46449966	112121403	67	1	\N
601010662	9483594_112121403	46449968	112121403	60	1	\N
601010663	9483594_112121403	46449970	112121403	71	1	\N
601010664	9483594_112121403	46449971	112121403	77	1	\N
601010665	9483594_112121403	46449972	112121403	56	1	\N
601010666	9483594_112121403	46449973	112121403	69	1	\N
601010667	9483594_112121403	46449974	112121403	7	2	\N
601010668	9483594_112121403	46449975	112121403	46	1	\N
601010669	9483594_112121403	46449976	112121403	72	1	\N
601010670	9483594_112121403	46449978	112121403	71	1	\N
601010671	9483594_112121403	46449980	112121403	70	1	\N
601010674	9483594_112121403	46449983	112121403	83	0	\N
601010675	9483594_112121403	46449985	112121403	100	1	\N
601010677	9483594_112121403	46449988	112121403	100	1	\N
601010678	9483594_112121403	46449989	112121403	100	1	\N
601010679	9483594_112121403	46449991	112121403	100	1	\N
601010680	9483594_112121403	46449992	112121403	77	0	\N
601010681	9483594_112121403	46449994	112121403	57	0	\N
601014854	9483594_112121477	46449958	112121477	45	1	\N
601014855	9483594_112121477	46449959	112121477	0	0	\N
601014856	9483594_112121477	46449960	112121477	0	0	\N
601014858	9483594_112121477	46449962	112121477	53.5	1	\N
601014860	9483594_112121477	46449964	112121477	68	2	\N
601014862	9483594_112121477	46449966	112121477	63.5	1	\N
601014863	9483594_112121477	46449968	112121477	50	1	\N
601014864	9483594_112121477	46449970	112121477	55.5	1	\N
601014865	9483594_112121477	46449971	112121477	0	0	\N
601014866	9483594_112121477	46449972	112121477	63.5	1	\N
601014868	9483594_112121477	46449974	112121477	9	1	\N
601014870	9483594_112121477	46449976	112121477	58	1	\N
601014872	9483594_112121477	46449980	112121477	0	0	\N
601014875	9483594_112121477	46449983	112121477	75	0	\N
601014876	9483594_112121477	46449985	112121477	100	1	\N
601014878	9483594_112121477	46449988	112121477	100	1	\N
601014879	9483594_112121477	46449989	112121477	100	1	\N
601014880	9483594_112121477	46449991	112121477	100	1	\N
601293517	9483594_110375967	46449958	110375967	56	1	\N
601293518	9483594_111855449	46449958	111855449	53	1	\N
601293519	9483594_111855745	46449958	111855745	70	2	\N
601293520	9483594_111880599	46449958	111880599	70	3	\N
601293521	9483594_111910489	46449958	111910489	67	2	\N
601293522	9483594_111912415	46449958	111912415	66	1	\N
601293523	9483594_111912592	46449958	111912592	0	0	\N
601293524	9483594_111939973	46449958	111939973	67	2	\N
601293525	9483594_110375967	46449959	110375967	73	2	\N
601293526	9483594_111855449	46449959	111855449	0	0	\N
601293527	9483594_111855745	46449959	111855745	75	2	\N
601293528	9483594_111880599	46449959	111880599	74	1	\N
601293529	9483594_111910489	46449959	111910489	0	0	\N
601293530	9483594_111912415	46449959	111912415	75	1	\N
601293531	9483594_111912592	46449959	111912592	0	0	\N
601293532	9483594_111939973	46449959	111939973	65	2	\N
601293533	9483594_110375967	46449960	110375967	54	1	\N
601293534	9483594_111855449	46449960	111855449	0	0	\N
601293535	9483594_111855745	46449960	111855745	70	2	\N
601293536	9483594_111880599	46449960	111880599	69	1	\N
601293537	9483594_111910489	46449960	111910489	70	1	\N
601293538	9483594_111912415	46449960	111912415	63	1	\N
601293539	9483594_111912592	46449960	111912592	0	0	\N
601293540	9483594_111939973	46449960	111939973	65	2	\N
601293541	9483594_110375967	46449961	110375967	55	1	\N
601293543	9483594_111855745	46449961	111855745	82	2	\N
601293544	9483594_111880599	46449961	111880599	82	1	\N
601293545	9483594_111910489	46449961	111910489	79	1	\N
601293546	9483594_111912415	46449961	111912415	83	1	\N
601293548	9483594_111939973	46449961	111939973	54	1	\N
601293549	9483594_110375967	46449962	110375967	59	1	\N
601293551	9483594_111855745	46449962	111855745	63	2	\N
601293552	9483594_111880599	46449962	111880599	70	1	\N
601293553	9483594_111910489	46449962	111910489	69	1	\N
601293554	9483594_111912415	46449962	111912415	71	1	\N
601293556	9483594_111939973	46449962	111939973	55	1	\N
601293557	9483594_110375967	46449963	110375967	69	1	\N
601293559	9483594_111855745	46449963	111855745	82	1	\N
601293560	9483594_111880599	46449963	111880599	81	1	\N
601293562	9483594_111912415	46449963	111912415	78	1	\N
601293564	9483594_111939973	46449963	111939973	52	1	\N
601293565	9483594_110375967	46449964	110375967	68.5	1	\N
601293566	9483594_111855449	46449964	111855449	0	0	\N
601293567	9483594_111855745	46449964	111855745	80	2	\N
601293568	9483594_111880599	46449964	111880599	80	1	\N
601293569	9483594_111910489	46449964	111910489	76	1	\N
601293570	9483594_111912415	46449964	111912415	79	1	\N
601293571	9483594_111912592	46449964	111912592	0	0	\N
601293572	9483594_111939973	46449964	111939973	77	2	\N
601293573	9483594_110375967	46449965	110375967	40	1	\N
601293575	9483594_111855745	46449965	111855745	62	3	\N
601293576	9483594_111880599	46449965	111880599	61	1	\N
601293577	9483594_111910489	46449965	111910489	49	1	\N
601293578	9483594_111912415	46449965	111912415	58	1	\N
601293580	9483594_111939973	46449965	111939973	37.5	1	\N
601293581	9483594_110375967	46449966	110375967	45	1	\N
606493222	9681492_112448163	47320822	112448163	59	1	\N
606493225	9681492_112448163	47320840	112448163	60	1	\N
606493232	9681492_112448163	47320872	112448163	44	1	\N
606493236	9681492_112448163	47320886	112448163	100	0	\N
606493239	9681492_112448163	47320892	112448163	100	1	\N
606493241	9681492_112448163	47320895	112448163	100	1	\N
606493242	9681492_112448163	47320897	112448163	100	1	\N
606493243	9681492_112448163	47320900	112448163	100	1	\N
606493475	9681492_112448203	47320791	112448203	51	2	\N
606493476	9681492_112448203	47320796	112448203	52	1	\N
606493477	9681492_112448203	47320802	112448203	49	3	\N
606493478	9681492_112448203	47320810	112448203	73	1	\N
606493479	9681492_112448203	47320815	112448203	60	1	\N
606493480	9681492_112448203	47320822	112448203	62	2	\N
606493481	9681492_112448203	47320829	112448203	68	1	\N
606493482	9681492_112448203	47320835	112448203	54	1	\N
606493483	9681492_112448203	47320840	112448203	69	3	\N
606493484	9681492_112448203	47320846	112448203	63	1	\N
606493485	9681492_112448203	47320852	112448203	58.5	1	\N
606493486	9681492_112448203	47320858	112448203	60	2	\N
606493487	9681492_112448203	47320864	112448203	55	1	\N
606493488	9681492_112448203	47320868	112448203	58	1	\N
606493489	9681492_112448203	47320870	112448203	75	1	\N
606493490	9681492_112448203	47320872	112448203	70	1	\N
606493491	9681492_112448203	47320875	112448203	74	2	\N
606493492	9681492_112448203	47320879	112448203	76	1	\N
606493493	9681492_112448203	47320881	112448203	62	1	\N
606493494	9681492_112448203	47320886	112448203	100	0	\N
606493496	9681492_112448203	47320890	112448203	86	0	\N
606493497	9681492_112448203	47320892	112448203	100	1	\N
606493499	9681492_112448203	47320895	112448203	100	1	\N
606493500	9681492_112448203	47320897	112448203	100	1	\N
606493501	9681492_112448203	47320900	112448203	100	1	\N
606493502	9681492_112448203	47320902	112448203	89	0	\N
606493503	9681492_112448203	47320903	112448203	90	0	\N
606494494	9681492_112448301	47320791	112448301	57.5	1	\N
606494495	9681492_112448301	47320796	112448301	53	1	\N
606494496	9681492_112448301	47320802	112448301	37	1	\N
606494497	9681492_112448301	47320810	112448301	68	1	\N
606494498	9681492_112448301	47320815	112448301	71	1	\N
606494499	9681492_112448301	47320822	112448301	60	2	\N
606494500	9681492_112448301	47320829	112448301	69	1	\N
606494501	9681492_112448301	47320835	112448301	65	2	\N
606494502	9681492_112448301	47320840	112448301	66	2	\N
606494503	9681492_112448301	47320846	112448301	66	1	\N
606494504	9681492_112448301	47320852	112448301	66	1	\N
606494505	9681492_112448301	47320858	112448301	67	1	\N
606494506	9681492_112448301	47320864	112448301	61	1	\N
606494507	9681492_112448301	47320868	112448301	57.5	1	\N
606494508	9681492_112448301	47320870	112448301	80	1	\N
606494509	9681492_112448301	47320872	112448301	79	2	\N
606494510	9681492_112448301	47320875	112448301	63	1	\N
606494511	9681492_112448301	47320879	112448301	78	1	\N
606494512	9681492_112448301	47320881	112448301	63.5	1	\N
606494513	9681492_112448301	47320886	112448301	100	0	\N
606494515	9681492_112448301	47320890	112448301	95	0	\N
606494516	9681492_112448301	47320892	112448301	100	1	\N
606494518	9681492_112448301	47320895	112448301	100	1	\N
606494519	9681492_112448301	47320897	112448301	100	1	\N
606494520	9681492_112448301	47320900	112448301	100	1	\N
606494521	9681492_112448301	47320902	112448301	97	0	\N
606494522	9681492_112448301	47320903	112448301	98	0	\N
606810684	9681492_111205743	47320791	111205743	69.5	1	\N
606810686	9681492_111205743	47320802	111205743	57	1	\N
606810689	9681492_111205743	47320822	111205743	64	3	\N
606810691	9681492_111205743	47320835	111205743	66	1	\N
606810692	9681492_111205743	47320840	111205743	69	1	\N
606810695	9681492_111205743	47320858	111205743	75	1	\N
606810697	9681492_111205743	47320868	111205743	72	1	\N
606810699	9681492_111205743	47320872	111205743	80	1	\N
606810700	9681492_111205743	47320875	111205743	74	1	\N
606810705	9681492_111205743	47320890	111205743	75	0	\N
596035003	9365544_111854577	45965524	111854577	47	1	\N
596035004	9365544_111854577	45965525	111854577	54	1	\N
596035005	9365544_111854577	45965526	111854577	29	1	\N
596035006	9365544_111854577	45965527	111854577	70	1	\N
596035007	9365544_111854577	45965528	111854577	73	1	\N
596035008	9365544_111854577	45965529	111854577	71	1	\N
596035009	9365544_111854577	45965530	111854577	62	1	\N
596035010	9365544_111854577	45965531	111854577	67.5	1	\N
596035011	9365544_111854577	45965532	111854577	62	1	\N
596035012	9365544_111854577	45965533	111854577	59	1	\N
596035013	9365544_111854577	45965534	111854577	72	1	\N
596035014	9365544_111854577	45965535	111854577	47	1	\N
596035015	9365544_111854577	45965536	111854577	65.5	1	\N
596035016	9365544_111854577	45965537	111854577	56	1	\N
596035017	9365544_111854577	45965538	111854577	61	1	\N
596035018	9365544_111854577	45965539	111854577	55	1	\N
596035019	9365544_111854577	45965540	111854577	61	1	\N
596035020	9365544_111854577	45965541	111854577	65	1	\N
596035021	9365544_111854577	45965542	111854577	61	1	\N
596035024	9365544_111854577	45965545	111854577	93	0	\N
596035025	9365544_111854577	45965546	111854577	100	1	\N
596035027	9365544_111854577	45965549	111854577	100	1	\N
596035028	9365544_111854577	45965550	111854577	100	1	\N
596035029	9365544_111854577	45965551	111854577	100	1	\N
596035030	9365544_111854577	45965553	111854577	91	0	\N
596036100	9365544_111854667	45965524	111854667	67.5	2	\N
596036101	9365544_111854667	45965525	111854667	56	1	\N
596036102	9365544_111854667	45965526	111854667	48	3	\N
596036103	9365544_111854667	45965527	111854667	75	2	\N
596036104	9365544_111854667	45965528	111854667	71	1	\N
596036105	9365544_111854667	45965529	111854667	78	1	\N
596036106	9365544_111854667	45965530	111854667	65.5	2	\N
596036107	9365544_111854667	45965531	111854667	72	1	\N
596036108	9365544_111854667	45965532	111854667	70	2	\N
596036109	9365544_111854667	45965533	111854667	63.5	2	\N
596036110	9365544_111854667	45965534	111854667	82	1	\N
596036111	9365544_111854667	45965535	111854667	54	1	\N
596036112	9365544_111854667	45965536	111854667	69.5	2	\N
596036113	9365544_111854667	45965537	111854667	67	1	\N
596036114	9365544_111854667	45965538	111854667	79	2	\N
596036115	9365544_111854667	45965539	111854667	72	1	\N
596036116	9365544_111854667	45965540	111854667	69	2	\N
596036117	9365544_111854667	45965541	111854667	73	2	\N
596036118	9365544_111854667	45965542	111854667	74	2	\N
596036121	9365544_111854667	45965545	111854667	98	0	\N
596036122	9365544_111854667	45965546	111854667	100	1	\N
596036124	9365544_111854667	45965549	111854667	100	1	\N
596036125	9365544_111854667	45965550	111854667	100	1	\N
596036126	9365544_111854667	45965551	111854667	100	1	\N
596036127	9365544_111854667	45965553	111854667	92	0	\N
596036734	9365544_111854690	45965524	111854690	62	1	\N
596036735	9365544_111854690	45965525	111854690	55	1	\N
596036736	9365544_111854690	45965526	111854690	52	1	\N
596036737	9365544_111854690	45965527	111854690	75	1	\N
596036738	9365544_111854690	45965528	111854690	75	1	\N
596036739	9365544_111854690	45965529	111854690	84	1	\N
596036740	9365544_111854690	45965530	111854690	68	1	\N
596036741	9365544_111854690	45965531	111854690	73	1	\N
596036742	9365544_111854690	45965532	111854690	70	1	\N
596036743	9365544_111854690	45965533	111854690	67.5	1	\N
596036744	9365544_111854690	45965534	111854690	80	1	\N
596036745	9365544_111854690	45965535	111854690	42	1	\N
596036746	9365544_111854690	45965536	111854690	70.5	1	\N
596036747	9365544_111854690	45965537	111854690	60.5	1	\N
596036748	9365544_111854690	45965538	111854690	74	1	\N
596036749	9365544_111854690	45965539	111854690	85	1	\N
596036750	9365544_111854690	45965540	111854690	64	1	\N
596036751	9365544_111854690	45965541	111854690	70	1	\N
596036752	9365544_111854690	45965542	111854690	66	2	\N
596036755	9365544_111854690	45965545	111854690	82	0	\N
596036756	9365544_111854690	45965546	111854690	100	1	\N
596036758	9365544_111854690	45965549	111854690	100	1	\N
596036759	9365544_111854690	45965550	111854690	100	1	\N
596036760	9365544_111854690	45965551	111854690	100	1	\N
596036975	9365544_111854702	45965524	111854702	0	0	\N
596036976	9365544_111854702	45965525	111854702	58	3	\N
596036977	9365544_111854702	45965526	111854702	41	3	\N
576987148	8548499_110810045	43487261	110810045	32	2	\N
576987149	8548499_110810384	43487261	110810384	22	1	\N
576987150	8548499_110810914	43487261	110810914	0	0	\N
576987151	8548499_110811306	43487261	110811306	0	0	\N
576987152	8548499_110811478	43487261	110811478	32	2	\N
576987153	8548499_110812262	43487261	110812262	32	2	\N
576987154	8548499_110812448	43487261	110812448	0	0	\N
576987155	8548499_110820108	43487261	110820108	37	3	\N
576987157	8548499_110820292	43487261	110820292	30	2	\N
576987158	8548499_110821011	43487261	110821011	35	2	\N
576987159	8548499_110821071	43487261	110821071	32	2	\N
576987160	8548499_110822820	43487261	110822820	36	2	\N
576987161	8548499_110822865	43487261	110822865	37	2	\N
576987162	8548499_110822947	43487261	110822947	0	0	\N
576987163	8548499_110823103	43487261	110823103	35	2	\N
576987164	8548499_110823178	43487261	110823178	38	3	\N
576987165	8548499_110823354	43487261	110823354	37	3	\N
576987166	8548499_110810045	43487263	110810045	30	2	\N
576987167	8548499_110810384	43487263	110810384	19	2	\N
576987168	8548499_110810914	43487263	110810914	0	0	\N
576987169	8548499_110811306	43487263	110811306	0	0	\N
576987170	8548499_110811478	43487263	110811478	31	2	\N
576987171	8548499_110812262	43487263	110812262	31	2	\N
576987172	8548499_110812448	43487263	110812448	22	1	\N
576987173	8548499_110820108	43487263	110820108	32	2	\N
576987175	8548499_110820292	43487263	110820292	32	2	\N
576987176	8548499_110821011	43487263	110821011	31	1	\N
576987177	8548499_110821071	43487263	110821071	29	3	\N
576987178	8548499_110822820	43487263	110822820	30.5	1	\N
576987179	8548499_110822865	43487263	110822865	30	2	\N
576987180	8548499_110822947	43487263	110822947	0	0	\N
576987181	8548499_110823103	43487263	110823103	32	2	\N
576987182	8548499_110823178	43487263	110823178	0	0	\N
576987183	8548499_110823354	43487263	110823354	32	2	\N
576987185	8548499_110810384	43487264	110810384	18	1	\N
576987188	8548499_110811478	43487264	110811478	24	1	\N
576987191	8548499_110820108	43487264	110820108	28	2	\N
576987193	8548499_110820292	43487264	110820292	27	2	\N
576987196	8548499_110822820	43487264	110822820	26	2	\N
576987197	8548499_110822865	43487264	110822865	28	1	\N
576987199	8548499_110823103	43487264	110823103	28	2	\N
576987200	8548499_110823178	43487264	110823178	30	3	\N
576987201	8548499_110823354	43487264	110823354	3	1	\N
576987256	8548499_110810045	43487270	110810045	28	1	\N
576987257	8548499_110810384	43487270	110810384	22	2	\N
576987258	8548499_110810914	43487270	110810914	0	0	\N
576987259	8548499_110811306	43487270	110811306	0	0	\N
576987260	8548499_110811478	43487270	110811478	30	2	\N
576987261	8548499_110812262	43487270	110812262	0	0	\N
576987262	8548499_110812448	43487270	110812448	0	0	\N
576987263	8548499_110820108	43487270	110820108	24	1	\N
576987265	8548499_110820292	43487270	110820292	30	2	\N
576987266	8548499_110821011	43487270	110821011	27	1	\N
576987267	8548499_110821071	43487270	110821071	0	0	\N
576987268	8548499_110822820	43487270	110822820	30	3	\N
576987269	8548499_110822865	43487270	110822865	29	2	\N
576987270	8548499_110822947	43487270	110822947	0	0	\N
576987271	8548499_110823103	43487270	110823103	30	2	\N
576987272	8548499_110823178	43487270	110823178	30	3	\N
576987273	8548499_110823354	43487270	110823354	30	2	\N
576987310	8548499_110810045	43487279	110810045	26	2	\N
576987311	8548499_110810384	43487279	110810384	20	3	\N
576987312	8548499_110810914	43487279	110810914	18.5	2	\N
576987313	8548499_110811306	43487279	110811306	11.5	4	\N
576987314	8548499_110811478	43487279	110811478	24.75	4	\N
576987315	8548499_110812262	43487279	110812262	25	2	\N
576987316	8548499_110812448	43487279	110812448	14.5	3	\N
576987317	8548499_110820108	43487279	110820108	21.75	2	\N
576987319	8548499_110820292	43487279	110820292	21	3	\N
576987320	8548499_110821011	43487279	110821011	22.5	2	\N
576987321	8548499_110821071	43487279	110821071	21	3	\N
576987322	8548499_110822820	43487279	110822820	23	1	\N
576987323	8548499_110822865	43487279	110822865	25	2	\N
576987324	8548499_110822947	43487279	110822947	11	2	\N
576987325	8548499_110823103	43487279	110823103	25.75	2	\N
576987326	8548499_110823178	43487279	110823178	26	4	\N
576987327	8548499_110823354	43487279	110823354	20	4	\N
576987364	8548499_110810045	43487294	110810045	22	1	\N
576987365	8548499_110810384	43487294	110810384	16	3	\N
576987366	8548499_110810914	43487294	110810914	0	0	\N
576987367	8548499_110811306	43487294	110811306	10	1	\N
576987368	8548499_110811478	43487294	110811478	25.5	1	\N
576987369	8548499_110812262	43487294	110812262	24.5	2	\N
576987370	8548499_110812448	43487294	110812448	28	2	\N
576987371	8548499_110820108	43487294	110820108	23	1	\N
576987373	8548499_110820292	43487294	110820292	24	2	\N
576987374	8548499_110821011	43487294	110821011	27.5	2	\N
576987375	8548499_110821071	43487294	110821071	21	1	\N
576987376	8548499_110822820	43487294	110822820	30	2	\N
576987377	8548499_110822865	43487294	110822865	29	2	\N
576987378	8548499_110822947	43487294	110822947	19	2	\N
576987379	8548499_110823103	43487294	110823103	29	2	\N
576987380	8548499_110823178	43487294	110823178	29	3	\N
576987381	8548499_110823354	43487294	110823354	10.5	3	\N
576987382	8548499_110810045	43487298	110810045	27	1	\N
576987383	8548499_110810384	43487298	110810384	19	1	\N
576987384	8548499_110810914	43487298	110810914	0	0	\N
576987385	8548499_110811306	43487298	110811306	15	1	\N
576987386	8548499_110811478	43487298	110811478	26	2	\N
576987387	8548499_110812262	43487298	110812262	27	2	\N
584654117	8778669_110811306	44258375	110811306	18	2	\N
584654125	8778669_110811306	44258377	110811306	10.5	1	\N
584654137	8778669_110811306	44258381	110811306	16	1	\N
584654141	8778669_110811306	44258383	110811306	26	2	\N
584654161	8778669_110811306	44258388	110811306	18	1	\N
584654221	8778669_110811306	44258405	110811306	20	3	\N
584654222	8778669_111241485	44258405	111241485	1	1	\N
584654245	8778669_110811306	44258411	110811306	50	1	\N
584654257	8778669_110811306	44258414	110811306	100	0	\N
584654258	8778669_111241485	44258414	111241485	100	0	\N
584654261	8778669_110811306	44258416	110811306	10	1	\N
584654262	8778669_111241485	44258416	111241485	10	1	\N
584654265	8778669_110811306	44258417	110811306	10	1	\N
584654266	8778669_111241485	44258417	111241485	10	1	\N
584654269	8778669_110811306	44258418	110811306	10	1	\N
584654270	8778669_111241485	44258418	111241485	10	1	\N
584654285	8778669_110811306	44258422	110811306	10	1	\N
584654305	8778669_110811306	44258428	110811306	10	1	\N
584654309	8778669_110811306	44258429	110811306	10	1	\N
584654313	8778669_110811306	44258430	110811306	10	1	\N
584654317	8778669_110811306	44258431	110811306	10	1	\N
584654322	8778669_111241485	44258433	111241485	0	0	\N
584654342	8778669_111241485	44258438	111241485	100	0	\N
584654353	8778669_110811306	44258441	110811306	100	1	\N
584654354	8778669_111241485	44258441	111241485	100	1	\N
584654365	8778669_110811306	44258444	110811306	100	1	\N
584654366	8778669_111241485	44258444	111241485	100	1	\N
584654370	8778669_111241485	44258445	111241485	100	1	\N
584654373	8778669_110811306	44258446	110811306	100	1	\N
584654374	8778669_111241485	44258446	111241485	100	1	\N
585815906	8778669_111306096	44258377	111306096	20.5	1	\N
585815909	8778669_111306096	44258381	111306096	31	1	\N
585815910	8778669_111306096	44258383	111306096	23	1	\N
585815915	8778669_111306096	44258388	111306096	25	1	\N
585815930	8778669_111306096	44258405	111306096	22	1	\N
585815932	8778669_111306096	44258407	111306096	22	1	\N
585815935	8778669_111306096	44258410	111306096	50	1	\N
585815936	8778669_111306096	44258411	111306096	50	1	\N
585815937	8778669_111306096	44258412	111306096	50	1	\N
585815938	8778669_111306096	44258413	111306096	50	1	\N
585815939	8778669_111306096	44258414	111306096	100	1	\N
585815940	8778669_111306096	44258416	111306096	10	1	\N
585815941	8778669_111306096	44258417	111306096	10	1	\N
585815942	8778669_111306096	44258418	111306096	10	1	\N
585815943	8778669_111306096	44258419	111306096	0	0	\N
585815944	8778669_111306096	44258420	111306096	0	0	\N
585815945	8778669_111306096	44258421	111306096	0	0	\N
585815946	8778669_111306096	44258422	111306096	10	1	\N
585815949	8778669_111306096	44258425	111306096	10	1	\N
585815952	8778669_111306096	44258429	111306096	10	1	\N
585815955	8778669_111306096	44258433	111306096	0	0	\N
585815963	8778669_111306096	44258441	111306096	100	1	\N
585815966	8778669_111306096	44258444	111306096	100	1	\N
585815967	8778669_111306096	44258445	111306096	100	1	\N
585815968	8778669_111306096	44258446	111306096	100	1	\N
152033640	1450448_23405901	10153845	23405901	39	1	\N
152033641	1450448_23405901	10154316	23405901	67	1	\N
152033642	1450448_23405901	10154432	23405901	71	1	\N
152033643	1450448_23405901	10154567	23405901	61	1	\N
152033644	1450448_23405901	10156211	23405901	64	1	\N
152033647	1450448_23405901	10200922	23405901	67	1	\N
152033648	1450448_23405901	10201160	23405901	49	1	\N
152033649	1450448_23405901	10201367	23405901	80	1	\N
152033651	1450448_23405901	10201473	23405901	67	2	\N
152033654	1450448_23405901	10234303	23405901	68	1	\N
152033655	1450448_23405901	10234356	23405901	0	1	\N
152033656	1450448_23405901	10234379	23405901	0	0	\N
152033657	1450448_23405901	10234380	23405901	0	0	\N
152033658	1450448_23405901	10234384	23405901	0	0	\N
152033660	1450448_23405901	10234408	23405901	0	1	\N
\.


--
-- Data for Name: course; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public.course (canvasid, coursename, coursedescription, startdate, enddate, id) FROM stdin;
10440316	*PHLEBOTOMY BASICS to ADVANCED*	PHL2424	2024-10-08	2024-11-10	\N
10627765	*PHLEBOTOMY BASICS to ADVANCED*	PHL2425	2024-11-03	2024-12-22	\N
1977977	Comprehensive Medical Assisting	Comprehensive Medical Assisting	2024-07-01	2026-03-14	\N
6057101	Devepmental Psychology	Devepmental	1970-01-01	9999-12-31	\N
1526010	EKG BASICS	EKG BASICS	2019-07-09	9999-12-31	\N
8690806	EKG BASICS 2402	EKG BASICS 	2024-02-23	2024-04-25	\N
9366117	EKG BASICS 2403	EKG BASICS 	2024-04-24	2024-07-13	\N
9587445	EKG BASICS 2404	EKG BASICS 	2024-06-01	2024-06-30	\N
10140155	EKG BASICS 2405	EKG BASICS 	2024-09-08	2024-10-20	\N
10289455	EKG BASICS 2406	EKG BASICS 	2024-09-08	2024-10-04	\N
9868740	EKG Certification Exam REBOOT	EKG BASICS REVIEW	2024-06-01	2025-12-31	\N
10406845	Medical Assistant Certification Exam Reboot 	Medical	1970-01-01	9999-12-31	\N
9874687	Pharmacy Technician 2024	Pharmacy 2024	1970-01-01	9999-12-31	\N
10439768	Pharmacy Technician Basics	Pharmacy Technician Basics	2024-10-07	2025-01-11	\N
9746185	Pharmacy Technician Basics	Pharmacy Technician Basics	2022-01-01	2024-12-31	\N
1433500	Pharmacy Technician RX1200	Pharmacy Technician Basics	2022-01-01	2024-12-31	\N
10289143	PHLEBOTOMY BASICS to ADVANCED	PHL2423	2024-09-09	2024-10-11	\N
9987831	PHLEBOTOMY BASICS to ADVANCED	PHL2421	2024-08-05	2024-09-13	\N
5952410	PHLEBOTOMY BASICS to ADVANCED	PHLEBOTOMY BASICS to ADVANCED	2023-01-01	2024-12-31	\N
9483594	PHLEBOTOMY BASICS to ADVANCED	PHL2419	2024-04-23	2025-05-31	\N
9681492	PHLEBOTOMY BASICS to ADVANCED	PHL2420	2024-06-18	2024-07-31	\N
9365544	PHLEBOTOMY BASICS to ADVANCED	PHL2418	2024-04-23	2025-05-31	\N
8548499	PHLEBOTOMY BASICS to ADVANCED (2024)	PHLEBOTOMY BASICS to ADVANCED	2024-01-01	2024-12-31	\N
8778669	PHLEBOTOMY BASICS to ADVANCED (2024)	PHL2416	2024-01-01	2024-12-31	\N
1450448	PHLEBOTOMY TECHNICIAN	WELCOME!!!	2018-11-20	2022-01-30	\N
10281506	**EKG BASICS 2406**	EKG BASICS 	2024-09-08	2025-12-31	\N
10441987	*Comprehensive Medical Assisting*	Comprehensive Medical Assisting 2417	2024-10-06	2025-01-18	\N
\.


--
-- Data for Name: coursestudent; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public.coursestudent (uniqueid, courseid, studentid, id) FROM stdin;
10281506_112532775	10281506	112532775	\N
10281506_112532815	10281506	112532815	\N
10281506_112532933	10281506	112532933	\N
10281506_112532940	10281506	112532940	\N
10281506_112533159	10281506	112533159	\N
10281506_111910517	10281506	111910517	\N
10441987_113035256	10441987	113035256	\N
10441987_113534765	10441987	113534765	\N
10441987_113531825	10441987	113531825	\N
10441987_113532285	10441987	113532285	\N
10441987_114250899	10441987	114250899	\N
10441987_113555087	10441987	113555087	\N
10441987_113553522	10441987	113553522	\N
10441987_112540977	10441987	112540977	\N
10441987_111912592	10441987	111912592	\N
10441987_113589293	10441987	113589293	\N
10441987_113593603	10441987	113593603	\N
10441987_113553975	10441987	113553975	\N
10440316_113868907	10440316	113868907	\N
10440316_112532775	10440316	112532775	\N
10440316_112532803	10440316	112532803	\N
10440316_112532815	10440316	112532815	\N
10440316_112924292	10440316	112924292	\N
10440316_112532933	10440316	112532933	\N
10440316_112532940	10440316	112532940	\N
10440316_112533159	10440316	112533159	\N
10440316_111910517	10440316	111910517	\N
10627765_37973165	10627765	37973165	\N
10627765_114290807	10627765	114290807	\N
10627765_109039704	10627765	109039704	\N
10627765_35926129	10627765	35926129	\N
1977977_112532756	1977977	112532756	\N
1977977_111854835	1977977	111854835	\N
1977977_111912415	1977977	111912415	\N
1977977_111854667	1977977	111854667	\N
1977977_112532775	1977977	112532775	\N
1977977_111910489	1977977	111910489	\N
1977977_112532803	1977977	112532803	\N
1977977_112532815	1977977	112532815	\N
1977977_111939973	1977977	111939973	\N
1977977_111855745	1977977	111855745	\N
1977977_111854965	1977977	111854965	\N
1977977_111245545	1977977	111245545	\N
1977977_111855210	1977977	111855210	\N
1977977_111855153	1977977	111855153	\N
1977977_111854794	1977977	111854794	\N
1977977_112532933	1977977	112532933	\N
1977977_112532940	1977977	112532940	\N
1977977_111880599	1977977	111880599	\N
1977977_111854878	1977977	111854878	\N
1977977_112533159	1977977	112533159	\N
1977977_111855002	1977977	111855002	\N
1977977_111854768	1977977	111854768	\N
1977977_112532963	1977977	112532963	\N
1977977_112532970	1977977	112532970	\N
1977977_111910517	1977977	111910517	\N
1977977_111854690	1977977	111854690	\N
1977977_111855344	1977977	111855344	\N
1526010_110297717	1526010	110297717	\N
1526010_34777393	1526010	34777393	\N
1526010_35025264	1526010	35025264	\N
1526010_35025191	1526010	35025191	\N
1526010_35025090	1526010	35025090	\N
1526010_36519279	1526010	36519279	\N
1526010_36482586	1526010	36482586	\N
1526010_34777847	1526010	34777847	\N
1526010_34117749	1526010	34117749	\N
1526010_35114164	1526010	35114164	\N
1526010_29718097	1526010	29718097	\N
1526010_29174142	1526010	29174142	\N
1526010_36132125	1526010	36132125	\N
1526010_34118607	1526010	34118607	\N
1526010_36736726	1526010	36736726	\N
1526010_35106996	1526010	35106996	\N
1526010_35446646	1526010	35446646	\N
1526010_35116808	1526010	35116808	\N
1526010_37751678	1526010	37751678	\N
1526010_34225969	1526010	34225969	\N
1526010_35446740	1526010	35446740	\N
1526010_110178372	1526010	110178372	\N
1526010_29960755	1526010	29960755	\N
1526010_35025521	1526010	35025521	\N
1526010_35025306	1526010	35025306	\N
1526010_36482932	1526010	36482932	\N
1526010_37211122	1526010	37211122	\N
1526010_37815792	1526010	37815792	\N
1526010_26936534	1526010	26936534	\N
1526010_35060993	1526010	35060993	\N
1526010_37657016	1526010	37657016	\N
1526010_36080807	1526010	36080807	\N
1526010_36131482	1526010	36131482	\N
1526010_110131493	1526010	110131493	\N
1526010_27380085	1526010	27380085	\N
1526010_36080781	1526010	36080781	\N
1526010_36155797	1526010	36155797	\N
1526010_34777859	1526010	34777859	\N
1526010_37777709	1526010	37777709	\N
1526010_36444877	1526010	36444877	\N
1526010_110544107	1526010	110544107	\N
1526010_30101148	1526010	30101148	\N
1526010_30186217	1526010	30186217	\N
1526010_35024850	1526010	35024850	\N
1526010_30530380	1526010	30530380	\N
1526010_34117226	1526010	34117226	\N
1526010_26247132	1526010	26247132	\N
1526010_35093024	1526010	35093024	\N
1526010_28891914	1526010	28891914	\N
1526010_26256806	1526010	26256806	\N
1526010_32617388	1526010	32617388	\N
1526010_34560949	1526010	34560949	\N
1526010_26346247	1526010	26346247	\N
1526010_35511503	1526010	35511503	\N
1526010_29196189	1526010	29196189	\N
1526010_30530392	1526010	30530392	\N
1526010_37752255	1526010	37752255	\N
1526010_30530698	1526010	30530698	\N
1526010_25352293	1526010	25352293	\N
1526010_109367596	1526010	109367596	\N
1526010_91818594	1526010	91818594	\N
1526010_30890273	1526010	30890273	\N
1526010_35024983	1526010	35024983	\N
1526010_36519215	1526010	36519215	\N
1526010_35048027	1526010	35048027	\N
1526010_30486573	1526010	30486573	\N
1526010_35025327	1526010	35025327	\N
1526010_35446813	1526010	35446813	\N
1526010_26270412	1526010	26270412	\N
1526010_35446836	1526010	35446836	\N
1526010_34205552	1526010	34205552	\N
1526010_35048156	1526010	35048156	\N
1526010_35509966	1526010	35509966	\N
1526010_37715521	1526010	37715521	\N
1526010_30856205	1526010	30856205	\N
1526010_27450016	1526010	27450016	\N
1526010_35446846	1526010	35446846	\N
1526010_36519252	1526010	36519252	\N
1526010_35113692	1526010	35113692	\N
1526010_28605856	1526010	28605856	\N
1526010_91818019	1526010	91818019	\N
1526010_30080014	1526010	30080014	\N
1526010_37716255	1526010	37716255	\N
1526010_35025363	1526010	35025363	\N
1526010_110573964	1526010	110573964	\N
1526010_26275361	1526010	26275361	\N
1526010_24888056	1526010	24888056	\N
1526010_34777004	1526010	34777004	\N
1526010_37815813	1526010	37815813	\N
1526010_34205387	1526010	34205387	\N
1526010_26247120	1526010	26247120	\N
1526010_33052949	1526010	33052949	\N
1526010_25010286	1526010	25010286	\N
1526010_34214221	1526010	34214221	\N
1526010_35113975	1526010	35113975	\N
8690806_110811478	8690806	110811478	\N
8690806_110847016	8690806	110847016	\N
8690806_110810384	8690806	110810384	\N
8690806_111770881	8690806	111770881	\N
8690806_24361831	8690806	24361831	\N
8690806_111242277	8690806	111242277	\N
8690806_110544107	8690806	110544107	\N
8690806_110821071	8690806	110821071	\N
8690806_111204379	8690806	111204379	\N
8690806_110811306	8690806	110811306	\N
8690806_109743202	8690806	109743202	\N
8690806_111227599	8690806	111227599	\N
9366117_111548857	9366117	111548857	\N
9366117_111854916	9366117	111854916	\N
9366117_111910489	9366117	111910489	\N
9366117_111944073	9366117	111944073	\N
9366117_111854852	9366117	111854852	\N
9366117_110349609	9366117	110349609	\N
9366117_111855687	9366117	111855687	\N
9366117_111912592	9366117	111912592	\N
9366117_111855191	9366117	111855191	\N
9366117_111855321	9366117	111855321	\N
9587445_112271931	9587445	112271931	\N
9587445_112277691	9587445	112277691	\N
9587445_111855239	9587445	111855239	\N
9587445_112290758	9587445	112290758	\N
9587445_111855080	9587445	111855080	\N
9587445_111245545	9587445	111245545	\N
9587445_111855153	9587445	111855153	\N
9587445_111854794	9587445	111854794	\N
9587445_35048156	9587445	35048156	\N
9587445_111854878	9587445	111854878	\N
9587445_111854768	9587445	111854768	\N
9587445_111854807	9587445	111854807	\N
9587445_112277695	9587445	112277695	\N
9587445_111854690	9587445	111854690	\N
9587445_111855344	9587445	111855344	\N
10140155_113035256	10140155	113035256	\N
10140155_113534765	10140155	113534765	\N
10140155_113531825	10140155	113531825	\N
10140155_35985376	10140155	35985376	\N
10140155_113532285	10140155	113532285	\N
10140155_113555087	10140155	113555087	\N
10140155_35048156	10140155	35048156	\N
10140155_113589293	10140155	113589293	\N
10140155_113593603	10140155	113593603	\N
10140155_113533500	10140155	113533500	\N
10140155_112541538	10140155	112541538	\N
10140155_113553975	10140155	113553975	\N
9868740_113035256	9868740	113035256	\N
9868740_113589293	9868740	113589293	\N
9868740_110374761	9868740	110374761	\N
9868740_113533500	9868740	113533500	\N
9868740_112278194	9868740	112278194	\N
9868740_111227599	9868740	111227599	\N
10439768_113932088	10439768	113932088	\N
9746185_112643419	9746185	112643419	\N
9746185_113932088	9746185	113932088	\N
9746185_112541526	9746185	112541526	\N
1433500_37434104	1433500	37434104	\N
1433500_35985418	1433500	35985418	\N
1433500_33805801	1433500	33805801	\N
1433500_24361831	1433500	24361831	\N
1433500_35985333	1433500	35985333	\N
1433500_33848661	1433500	33848661	\N
1433500_37434318	1433500	37434318	\N
1433500_33788448	1433500	33788448	\N
1433500_37358860	1433500	37358860	\N
1433500_37434285	1433500	37434285	\N
1433500_35985361	1433500	35985361	\N
1433500_37434238	1433500	37434238	\N
1433500_37434373	1433500	37434373	\N
1433500_37435806	1433500	37435806	\N
1433500_111547456	1433500	111547456	\N
1433500_34777680	1433500	34777680	\N
10289143_113553522	10289143	113553522	\N
9987831_113035256	9987831	113035256	\N
9987831_112924292	9987831	112924292	\N
9987831_111855449	9987831	111855449	\N
9987831_112923870	9987831	112923870	\N
9987831_112121477	9987831	112121477	\N
9987831_112448163	9987831	112448163	\N
5952410_110348902	5952410	110348902	\N
5952410_111548857	5952410	111548857	\N
5952410_35985376	5952410	35985376	\N
5952410_111548843	5952410	111548843	\N
5952410_111548873	5952410	111548873	\N
5952410_110349609	5952410	110349609	\N
5952410_111548864	5952410	111548864	\N
5952410_110313688	5952410	110313688	\N
5952410_110374761	5952410	110374761	\N
5952410_111241779	5952410	111241779	\N
9483594_111855662	9483594	111855662	\N
9483594_111912415	9483594	111912415	\N
9483594_112121403	9483594	112121403	\N
9483594_111910489	9483594	111910489	\N
9483594_111939973	9483594	111939973	\N
9483594_111855745	9483594	111855745	\N
9483594_111912592	9483594	111912592	\N
9483594_111880599	9483594	111880599	\N
9483594_111855449	9483594	111855449	\N
9483594_112121477	9483594	112121477	\N
9483594_110375967	9483594	110375967	\N
9681492_112448203	9681492	112448203	\N
9681492_111205743	9681492	111205743	\N
9681492_112448301	9681492	112448301	\N
9681492_112448163	9681492	112448163	\N
9365544_111855259	9365544	111855259	\N
9365544_111854745	9365544	111854745	\N
9365544_111854835	9365544	111854835	\N
9365544_111854713	9365544	111854713	\N
9365544_111854667	9365544	111854667	\N
9365544_111854577	9365544	111854577	\N
9365544_111854702	9365544	111854702	\N
9365544_111854862	9365544	111854862	\N
9365544_111855080	9365544	111855080	\N
9365544_111854965	9365544	111854965	\N
9365544_111245545	9365544	111245545	\N
9365544_111855210	9365544	111855210	\N
9365544_111855153	9365544	111855153	\N
9365544_111910369	9365544	111910369	\N
9365544_111854794	9365544	111854794	\N
9365544_111855280	9365544	111855280	\N
9365544_111854947	9365544	111854947	\N
9365544_111854878	9365544	111854878	\N
9365544_111855002	9365544	111855002	\N
9365544_111854768	9365544	111854768	\N
9365544_111854807	9365544	111854807	\N
9365544_111855057	9365544	111855057	\N
9365544_111854690	9365544	111854690	\N
9365544_111855344	9365544	111855344	\N
8548499_110820108	8548499	110820108	\N
8548499_110812448	8548499	110812448	\N
8548499_110326450	8548499	110326450	\N
8548499_110843225	8548499	110843225	\N
8548499_110842758	8548499	110842758	\N
8548499_110811478	8548499	110811478	\N
8548499_110812262	8548499	110812262	\N
8548499_110823178	8548499	110823178	\N
8548499_110820292	8548499	110820292	\N
8548499_110847016	8548499	110847016	\N
8548499_110810045	8548499	110810045	\N
8548499_110822947	8548499	110822947	\N
8548499_110842851	8548499	110842851	\N
8548499_110810384	8548499	110810384	\N
8548499_111241688	8548499	111241688	\N
8548499_110811184	8548499	110811184	\N
8548499_110823354	8548499	110823354	\N
8548499_110822865	8548499	110822865	\N
8548499_110845503	8548499	110845503	\N
8548499_110821011	8548499	110821011	\N
8548499_110821071	8548499	110821071	\N
8548499_110822820	8548499	110822820	\N
8548499_110842383	8548499	110842383	\N
8548499_110811306	8548499	110811306	\N
8548499_110810914	8548499	110810914	\N
8548499_110823103	8548499	110823103	\N
8778669_111306096	8778669	111306096	\N
8778669_110811306	8778669	110811306	\N
8778669_111241485	8778669	111241485	\N
1450448_27387461	1450448	27387461	\N
1450448_29713419	1450448	29713419	\N
1450448_30362434	1450448	30362434	\N
1450448_30138675	1450448	30138675	\N
1450448_30082218	1450448	30082218	\N
1450448_30170913	1450448	30170913	\N
1450448_30170785	1450448	30170785	\N
1450448_29989396	1450448	29989396	\N
1450448_27437658	1450448	27437658	\N
1450448_27380085	1450448	27380085	\N
1450448_27362315	1450448	27362315	\N
1450448_33848478	1450448	33848478	\N
1450448_33848995	1450448	33848995	\N
1450448_25352293	1450448	25352293	\N
1450448_30163501	1450448	30163501	\N
1450448_23775544	1450448	23775544	\N
1450448_30679310	1450448	30679310	\N
1450448_30484220	1450448	30484220	\N
1450448_30530807	1450448	30530807	\N
1450448_27450016	1450448	27450016	\N
1450448_27046231	1450448	27046231	\N
1450448_27578216	1450448	27578216	\N
1450448_25342353	1450448	25342353	\N
1450448_25010286	1450448	25010286	\N
1450448_28237468	1450448	28237468	\N
1450448_26093397	1450448	26093397	\N
1450448_27046155	1450448	27046155	\N
1450448_23781721	1450448	23781721	\N
1450448_28209502	1450448	28209502	\N
1450448_23519662	1450448	23519662	\N
1450448_27172970	1450448	27172970	\N
1450448_25566473	1450448	25566473	\N
1450448_29385974	1450448	29385974	\N
1450448_25218267	1450448	25218267	\N
1450448_23519691	1450448	23519691	\N
1450448_27368640	1450448	27368640	\N
1450448_26886924	1450448	26886924	\N
1450448_29195707	1450448	29195707	\N
1450448_26259090	1450448	26259090	\N
1450448_30128199	1450448	30128199	\N
1450448_25577511	1450448	25577511	\N
1450448_23405901	1450448	23405901	\N
1450448_27436287	1450448	27436287	\N
1450448_30498885	1450448	30498885	\N
\.


--
-- Data for Name: objectprefixes; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public.objectprefixes (object, prefix) FROM stdin;
course	001
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


--
-- Data for Name: persona; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public.persona (id, name, "isAdminType") FROM stdin;
\.


--
-- Data for Name: personapermission; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public.personapermission (id, personaid, permissionname) FROM stdin;
\.


--
-- Data for Name: processqueue; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public.processqueue (processname, processstatus, processstarttime, processendtime, targetobject, totalbatches, failedbatches, failuremessage, id) FROM stdin;
\.


--
-- Data for Name: recyclebin; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public.recyclebin (id, originalrowid, originalobject, deleteddate, deletedbyid) FROM stdin;
\.


--
-- Data for Name: rowindex; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public.rowindex (id, object, objectid, log_time) FROM stdin;
\.


--
-- Data for Name: student; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public.student (canvasid, fullname, sortablename, id) FROM stdin;
112532775	Israel Hampton	Hampton, Israel	\N
112532815	Jacquel Jolly	Jolly, Jacquel	\N
112532933	Aariona Mills	Mills, Aariona	\N
112532940	Farhiya Omar	Omar, Farhiya	\N
112533159	Kanisha Pompy	Pompy, Kanisha	\N
111910517	Verlanda White	White, Verlanda	\N
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
110297717	Shameem Ahmed	Ahmed, Shameem	\N
34777393	Alexis Arevalo	Arevalo, Alexis	\N
35025264	Porcha Belser	Belser, Porcha	\N
35025191	Jaquala Burks	Burks, Jaquala	\N
35025090	Nae'chelle Carroll	Carroll, Nae'chelle	\N
36519279	Kierra Clements	Clements, Kierra	\N
36482586	Shanice Clinton	Clinton, Shanice	\N
34777847	Tashika Coleman	Coleman, Tashika	\N
34117749	Diane Cook	Cook, Diane	\N
35114164	Nayeemah Tucker Cook	Cook, Nayeemah Tucker	\N
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
112278194	Carleda Stemley	Stemley, Carleda	\N
113932088	Marige Diaz	Diaz, Marige	\N
112643419	Keturah Chesser	Chesser, Keturah	\N
112541526	Shiterra Yearby	Yearby, Shiterra	\N
37434104	Alexis Briggs	Briggs, Alexis	\N
35985418	Promise Campbell	Campbell, Promise	\N
33805801	Jamisha L Gill	Gill, Jamisha L	\N
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


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: dbsvradmin
--

COPY public."user" (firstname, lastname, email, phone, linkedin, id, studentid, personaid) FROM stdin;
\.


--
-- Name: rowindex_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dbsvradmin
--

SELECT pg_catalog.setval('public.rowindex_id_seq', 1, false);


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
    ADD CONSTRAINT processqueue_pkey PRIMARY KEY (id);


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
-- Name: processqueue IndexProcess; Type: TRIGGER; Schema: public; Owner: dbsvradmin
--

CREATE TRIGGER "IndexProcess" AFTER INSERT ON public.processqueue FOR EACH ROW EXECUTE FUNCTION public.log_insert();


--
-- Name: processqueue SetProcessId; Type: TRIGGER; Schema: public; Owner: dbsvradmin
--

CREATE TRIGGER "SetProcessId" BEFORE INSERT ON public.processqueue FOR EACH ROW EXECUTE FUNCTION public.generate_global_id();


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
-- Name: TABLE processqueue; Type: ACL; Schema: public; Owner: dbsvradmin
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.processqueue TO nexus;


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

