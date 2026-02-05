--
-- PostgreSQL database dump
--

\restrict ShPxjPC48wfBB8Hglm1C6r9f5pGtNiuqDOQO4b2hCYr1x2Ry2F3eZTqPgLYDVEy

-- Dumped from database version 15.15
-- Dumped by pg_dump version 15.15

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: academias; Type: TABLE; Schema: public; Owner: proj_user
--

CREATE TABLE public.academias (
    id integer NOT NULL,
    nombre character varying,
    codigo character varying,
    descripcion text
);


ALTER TABLE public.academias OWNER TO proj_user;

--
-- Name: academias_id_seq; Type: SEQUENCE; Schema: public; Owner: proj_user
--

CREATE SEQUENCE public.academias_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.academias_id_seq OWNER TO proj_user;

--
-- Name: academias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: proj_user
--

ALTER SEQUENCE public.academias_id_seq OWNED BY public.academias.id;


--
-- Name: aulas; Type: TABLE; Schema: public; Owner: proj_user
--

CREATE TABLE public.aulas (
    id integer NOT NULL,
    nombre character varying,
    capacidad integer,
    tipo character varying
);


ALTER TABLE public.aulas OWNER TO proj_user;

--
-- Name: aulas_id_seq; Type: SEQUENCE; Schema: public; Owner: proj_user
--

CREATE SEQUENCE public.aulas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aulas_id_seq OWNER TO proj_user;

--
-- Name: aulas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: proj_user
--

ALTER SEQUENCE public.aulas_id_seq OWNED BY public.aulas.id;


--
-- Name: carreras; Type: TABLE; Schema: public; Owner: proj_user
--

CREATE TABLE public.carreras (
    id integer NOT NULL,
    nombre character varying,
    codigo character varying,
    descripcion text
);


ALTER TABLE public.carreras OWNER TO proj_user;

--
-- Name: carreras_id_seq; Type: SEQUENCE; Schema: public; Owner: proj_user
--

CREATE SEQUENCE public.carreras_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.carreras_id_seq OWNER TO proj_user;

--
-- Name: carreras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: proj_user
--

ALTER SEQUENCE public.carreras_id_seq OWNED BY public.carreras.id;


--
-- Name: examenes; Type: TABLE; Schema: public; Owner: proj_user
--

CREATE TABLE public.examenes (
    id integer NOT NULL,
    fecha date,
    hora_inicio time without time zone,
    hora_fin time without time zone,
    tipo character varying,
    modalidad character varying,
    materia_id integer,
    aula_id integer,
    grupo_id integer,
    sinodal_id integer,
    aplicador_id integer,
    academia_id integer,
    status character varying,
    comentarios_rechazo text,
    fecha_envio date,
    fecha_aprobacion date
);


ALTER TABLE public.examenes OWNER TO proj_user;

--
-- Name: examenes_id_seq; Type: SEQUENCE; Schema: public; Owner: proj_user
--

CREATE SEQUENCE public.examenes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.examenes_id_seq OWNER TO proj_user;

--
-- Name: examenes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: proj_user
--

ALTER SEQUENCE public.examenes_id_seq OWNED BY public.examenes.id;


--
-- Name: grupos; Type: TABLE; Schema: public; Owner: proj_user
--

CREATE TABLE public.grupos (
    id integer NOT NULL,
    nombre_grupo character varying,
    semestre integer,
    carrera_id integer
);


ALTER TABLE public.grupos OWNER TO proj_user;

--
-- Name: grupos_id_seq; Type: SEQUENCE; Schema: public; Owner: proj_user
--

CREATE SEQUENCE public.grupos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.grupos_id_seq OWNER TO proj_user;

--
-- Name: grupos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: proj_user
--

ALTER SEQUENCE public.grupos_id_seq OWNED BY public.grupos.id;


--
-- Name: horarios; Type: TABLE; Schema: public; Owner: proj_user
--

CREATE TABLE public.horarios (
    id integer NOT NULL,
    dia_semana character varying,
    hora_inicio time without time zone,
    hora_fin time without time zone,
    grupo_id integer,
    materia_id integer,
    aula_id integer
);


ALTER TABLE public.horarios OWNER TO proj_user;

--
-- Name: horarios_id_seq; Type: SEQUENCE; Schema: public; Owner: proj_user
--

CREATE SEQUENCE public.horarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.horarios_id_seq OWNER TO proj_user;

--
-- Name: horarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: proj_user
--

ALTER SEQUENCE public.horarios_id_seq OWNED BY public.horarios.id;


--
-- Name: materias; Type: TABLE; Schema: public; Owner: proj_user
--

CREATE TABLE public.materias (
    id integer NOT NULL,
    nombre character varying,
    carrera_id integer,
    profesor_id integer,
    academia_id integer,
    semestre integer,
    sinodal_id integer
);


ALTER TABLE public.materias OWNER TO proj_user;

--
-- Name: materias_id_seq; Type: SEQUENCE; Schema: public; Owner: proj_user
--

CREATE SEQUENCE public.materias_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.materias_id_seq OWNER TO proj_user;

--
-- Name: materias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: proj_user
--

ALTER SEQUENCE public.materias_id_seq OWNED BY public.materias.id;


--
-- Name: notificaciones; Type: TABLE; Schema: public; Owner: proj_user
--

CREATE TABLE public.notificaciones (
    id integer NOT NULL,
    mensaje character varying,
    leida boolean,
    fecha_creacion timestamp without time zone,
    destinatario_rol character varying,
    destinatario_id integer,
    tipo character varying,
    referencia_id integer,
    referencia_tipo character varying,
    carrera character varying
);


ALTER TABLE public.notificaciones OWNER TO proj_user;

--
-- Name: notificaciones_id_seq; Type: SEQUENCE; Schema: public; Owner: proj_user
--

CREATE SEQUENCE public.notificaciones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notificaciones_id_seq OWNER TO proj_user;

--
-- Name: notificaciones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: proj_user
--

ALTER SEQUENCE public.notificaciones_id_seq OWNED BY public.notificaciones.id;


--
-- Name: profesores; Type: TABLE; Schema: public; Owner: proj_user
--

CREATE TABLE public.profesores (
    id integer NOT NULL,
    nombre character varying,
    email character varying
);


ALTER TABLE public.profesores OWNER TO proj_user;

--
-- Name: profesores_id_seq; Type: SEQUENCE; Schema: public; Owner: proj_user
--

CREATE SEQUENCE public.profesores_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.profesores_id_seq OWNER TO proj_user;

--
-- Name: profesores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: proj_user
--

ALTER SEQUENCE public.profesores_id_seq OWNED BY public.profesores.id;


--
-- Name: tipos_examen; Type: TABLE; Schema: public; Owner: proj_user
--

CREATE TABLE public.tipos_examen (
    id integer NOT NULL,
    nombre character varying,
    descripcion text
);


ALTER TABLE public.tipos_examen OWNER TO proj_user;

--
-- Name: tipos_examen_id_seq; Type: SEQUENCE; Schema: public; Owner: proj_user
--

CREATE SEQUENCE public.tipos_examen_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tipos_examen_id_seq OWNER TO proj_user;

--
-- Name: tipos_examen_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: proj_user
--

ALTER SEQUENCE public.tipos_examen_id_seq OWNED BY public.tipos_examen.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: proj_user
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying NOT NULL,
    hashed_password character varying NOT NULL,
    role character varying NOT NULL,
    email character varying,
    carrera character varying,
    profesor_id integer,
    is_active integer
);


ALTER TABLE public.users OWNER TO proj_user;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: proj_user
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO proj_user;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: proj_user
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: academias id; Type: DEFAULT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.academias ALTER COLUMN id SET DEFAULT nextval('public.academias_id_seq'::regclass);


--
-- Name: aulas id; Type: DEFAULT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.aulas ALTER COLUMN id SET DEFAULT nextval('public.aulas_id_seq'::regclass);


--
-- Name: carreras id; Type: DEFAULT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.carreras ALTER COLUMN id SET DEFAULT nextval('public.carreras_id_seq'::regclass);


--
-- Name: examenes id; Type: DEFAULT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.examenes ALTER COLUMN id SET DEFAULT nextval('public.examenes_id_seq'::regclass);


--
-- Name: grupos id; Type: DEFAULT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.grupos ALTER COLUMN id SET DEFAULT nextval('public.grupos_id_seq'::regclass);


--
-- Name: horarios id; Type: DEFAULT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.horarios ALTER COLUMN id SET DEFAULT nextval('public.horarios_id_seq'::regclass);


--
-- Name: materias id; Type: DEFAULT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.materias ALTER COLUMN id SET DEFAULT nextval('public.materias_id_seq'::regclass);


--
-- Name: notificaciones id; Type: DEFAULT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.notificaciones ALTER COLUMN id SET DEFAULT nextval('public.notificaciones_id_seq'::regclass);


--
-- Name: profesores id; Type: DEFAULT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.profesores ALTER COLUMN id SET DEFAULT nextval('public.profesores_id_seq'::regclass);


--
-- Name: tipos_examen id; Type: DEFAULT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.tipos_examen ALTER COLUMN id SET DEFAULT nextval('public.tipos_examen_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: academias; Type: TABLE DATA; Schema: public; Owner: proj_user
--

COPY public.academias (id, nombre, codigo, descripcion) FROM stdin;
\.


--
-- Data for Name: aulas; Type: TABLE DATA; Schema: public; Owner: proj_user
--

COPY public.aulas (id, nombre, capacidad, tipo) FROM stdin;
1	A1	18	AULA
2	A2	21	AULA
3	A3	20	AULA
4	A4	15	LABORATORIO
5	AUDITORIO	800	AUDITORIO
6	B1	15	AULA
7	B2	10	AULA
8	B3	16	AULA
9	B4	12	AULA
10	BIBLIOTECA	72	AULA
11	BIBLIOTECA A	10	AULA
12	BIBLIOTECA B	9	AULA
13	BIBLIOTECA C	13	AULA
14	C1	16	AULA
15	C2	22	AULA
16	C3	5	AULA
17	C4	20	AULA
18	CAD-ALMACEN ANATOMIA	32	AULA
19	CAD-ANATOMIA DIGITAL	65	SALA DE COMPUTO
20	CAD-MORFOLOGIA	30	AULA
21	CAD-OSTEOTECA	45	AULA
22	CAD-SALA DE MODELOS	40	AULA
23	CCR1	64	AULA
24	CCR2	60	AULA
25	CEDGE-CABILDOS	50	LABORATORIO
26	CEDGE-DO	30	SALA
27	CEDGE-SIG	30	AULA
28	CEO-AULA	35	AULA
29	CEO-CLINICA1	36	CLINICA
30	CEO-SALA	42	LABORATORIO
31	CETI - DES. SOFTWARE	20	LABORATORIO
32	CETI - IHC	10	LABORATORIO
33	CETI - ING. SOFTWARE	20	LABORATORIO
34	CETI - REDES	20	LABORATORIO
35	CETI - S.O.	20	LABORATORIO
36	CETI - TEC WEB	20	LABORATORIO
37	CINA	13	AULA_ESC
38	CO-AULA CLINICA	38	AULA
39	CPAT-SALA	24	SALA_DE_CÓMPUTO
40	CUBO 11	1	CUBO
41	CUBO 12	1	CUBO
42	D1	45	AULA
43	D2	45	AULA
44	D3	44	AULA
45	D4	45	AULA
46	D5	45	AULA
47	D6	45	AULA
48	D7	45	AULA
49	D8	45	AULA
50	D9	46	AULA
51	DEP1	15	AULA
52	DEP2	2	AULA
53	DEP3	3	AULA
54	DEP4	2	AULA
55	DEP5	18	AULA
56	DEP6	4	AULA
57	DEP7	5	AULA
58	DEP8	6	AULA
59	DEP9	1	AULA
60	E1	37	AULA
61	E2	40	AULA
62	E3	40	AULA
63	E4	70	AULA
64	E5	83	AULA
65	E6	41	AULA
66	E7	31	AULA
67	E8	44	AULA
68	F1	30	AULA
69	F2	23	AULA
70	F3	22	AULA
71	F4	34	AULA
72	F5	36	AULA
73	F6	34	AULA
74	F7	34	AULA
75	F8	28	AULA
76	F9	29	AULA
77	G1	44	AULA
78	G2	44	AULA
79	G3	44	AULA
80	G4	46	AULA
81	G5	48	AULA
82	G6	47	AULA
83	G7	44	AULA
84	H1	48	AULA
85	H2	48	AULA
86	H3	48	AULA
87	H4	40	AULA
88	H5	43	AULA
89	H6	33	AULA
90	H7	47	AULA
91	I1	40	AULA
92	I2	40	AULA
93	I3	39	AULA
94	I4	33	AULA
95	I5	40	AULA
96	I6	40	AULA
97	I7	39	AULA
98	I8	40	AULA
99	I9	37	AULA
100	J1	48	AULA
101	J2	48	AULA
102	J3	48	AULA
103	J4	48	AULA
104	J5	48	AULA
105	J6	48	AULA
106	J7	47	AULA
107	K1	48	AULA
108	K2	48	AULA
109	K3	48	AULA
110	K4	48	AULA
111	K5	48	AULA
112	K6	48	AULA
113	K7	48	AULA
114	LAB INFO	15	LABORATORIO
115	LABORATORIO BIOLOGIA	37	LABORATORIO
116	LABORATORIO QUIMICA	37	LABORATORIO
117	LGE	24	LABORATORIO
118	M1	11	OFICINA
119	M2	11	AULA
120	M3	40	AULA_ESC
121	PARANINFO	75	PARANINFO
122	SALA 1	23	SALA_DE_CÓMPUTO
123	SALA 10	36	SALA_DE_CÓMPUTO
124	SALA 11	34	SALA_DE_CÓMPUTO
125	SALA 1 - CPAT	33	SALA
126	SALA 2	24	SALA_DE_CÓMPUTO
127	SALA 2 - CPAT	32	SALA
128	SALA 3	24	SALA_DE_CÓMPUTO
129	SALA 4	27	SALA_DE_CÓMPUTO
130	SALA 5	28	SALA_DE_CÓMPUTO
131	SALA 6	28	SALA_DE_CÓMPUTO
132	SALA 7	22	SALA_DE_CÓMPUTO
133	SALA 8	35	SALA_DE_CÓMPUTO
134	SALA 9	36	SALA_DE_CÓMPUTO
135	SALA-BIBLIOTECA 1	64	SALA
136	SALA-CAD	23	SALA_DE_CÓMPUTO
137	SALA-CEDGE	24	SALA_DE_CÓMPUTO
138	SALA DE MEZCLAS	35	AULA_ESC
139	SALA ODONT.	28	AULA
140	SALA TESISTA	24	AULA_ESC
141	SIS DIG	10	LABORATORIO
142	SJIDIOMAS	10	SALA_DE_JUNTAS
143	SJIEM	10	SALA_DE_JUNTAS
144	SJINFO	10	SALA_DE_JUNTAS
145	SJNUTR	10	SALA_DE_JUNTAS
146	SJSP	10	SALA_DE_JUNTAS
147	SJVA	5	SALA_DE_JUNTAS
148	W1	40	AULA
149	W2	40	AULA
150	W3	40	AULA
\.


--
-- Data for Name: carreras; Type: TABLE DATA; Schema: public; Owner: proj_user
--

COPY public.carreras (id, nombre, codigo, descripcion) FROM stdin;
1	LICENCIATURA EN CIENCIAS EMPRESARIALES	04B	\N
2	LICENCIATURA EN INFORMÁTICA	06B	\N
3	LICENCIATURA EN ADMINISTRACIÓN PÚBLICA	05	\N
4	MAESTRÍA EN PLANEACIÓN ESTRATÉGICA MUNICIPAL	08C	\N
5	MAESTRÍA EN SALUD PÚBLICA	09	\N
6	MAESTRÍA EN GOBIERNO ELECTRÓNICO	10	\N
7	DOCTORADO EN GOBIERNO ELECTRÓNICO	11	\N
8	LICENCIATURA EN NUTRICIÓN	07B	\N
9	LICENCIATURA EN ADMINISTRACIÓN MUNICIPAL	01B	\N
10	LICENCIATURA EN CIENCIAS BIOMÉDICAS	16A	\N
11	LICENCIATURA EN ODONTOLOGÍA	14	\N
12	LICENCIATURA EN ENFERMERÍA	03D	\N
13	LICENCIATURA EN MEDICINA	15	\N
14	INGLÉS	12	\N
\.


--
-- Data for Name: examenes; Type: TABLE DATA; Schema: public; Owner: proj_user
--

COPY public.examenes (id, fecha, hora_inicio, hora_fin, tipo, modalidad, materia_id, aula_id, grupo_id, sinodal_id, aplicador_id, academia_id, status, comentarios_rechazo, fecha_envio, fecha_aprobacion) FROM stdin;
\.


--
-- Data for Name: grupos; Type: TABLE DATA; Schema: public; Owner: proj_user
--

COPY public.grupos (id, nombre_grupo, semestre, carrera_id) FROM stdin;
1	104-A	1	1
2	106-A	1	2
3	106-B	1	2
4	506	5	2
5	706	7	2
6	906	9	2
7	104-B	1	1
8	304	3	1
9	504	5	1
10	704	7	1
11	904	9	1
12	505	5	3
13	705	7	3
14	905	9	3
15	105	1	3
16	305	3	3
17	108	1	4
18	109	1	5
19	309	3	5
20	310	3	6
21	111	1	7
22	511	5	7
23	307	3	8
24	507	5	8
25	707	7	8
26	907	9	8
27	501	5	9
28	701	7	9
29	901	9	9
30	308-B	3	4
31	308	3	4
32	107-A	1	8
33	107-B	1	8
34	116-A	1	10
35	116-B	1	10
36	316	3	10
37	306-B	3	2
38	306	3	2
39	113-A	1	11
40	113-B	1	11
41	113-C	1	11
42	113-D	1	11
43	113-E	1	11
44	113-F	1	11
45	113-G	1	11
46	113-H	1	11
47	113-I	1	11
48	113-J	1	11
49	313-A	3	11
50	313-B	3	11
51	313-C	3	11
52	313-D	3	11
53	513-A	5	11
54	513-B	5	11
55	513-C	5	11
56	513-D	5	11
57	713-A	7	11
58	713-B	7	11
59	713-C	7	11
60	913 A	9	11
61	913 B	9	11
62	913 C	9	11
63	103-A	1	12
64	103-B	1	12
65	103-C	1	12
66	103-D	1	12
67	103-E	1	12
68	103-F	1	12
69	103-G	1	12
70	103-H	1	12
71	103-I	1	12
72	303-A	3	12
73	303-B	3	12
74	303-C	3	12
75	303-D	3	12
76	303-E	3	12
77	303-F	3	12
78	303-G	3	12
79	503-A	5	12
80	503-B	5	12
81	503-C	5	12
82	503-D	5	12
83	703-A	7	12
84	703-B	7	12
85	703-C	7	12
86	903-A	9	12
87	903-B	9	12
88	903-C	9	12
89	114-A	1	13
90	114-B	1	13
91	114-C	1	13
92	114-D	1	13
93	314-A	3	13
94	314-B	3	13
95	314-C	3	13
96	514-A	5	13
97	514-B	5	13
98	514-C	5	13
99	714-A	7	13
100	714-B	7	13
101	914-A	9	13
102	914-B	9	13
103	914-C	9	13
104	1114-A	11	13
105	1114-B	11	13
106	1114-C	11	13
107	112	1	14
108	312	1	14
109	112C	1	14
110	112D	1	14
111	112E	1	14
\.


--
-- Data for Name: horarios; Type: TABLE DATA; Schema: public; Owner: proj_user
--

COPY public.horarios (id, dia_semana, hora_inicio, hora_fin, grupo_id, materia_id, aula_id) FROM stdin;
1	Lunes	13:00:00	14:00:00	1	1	132
2	Lunes	12:00:00	13:00:00	1	2	63
3	Lunes	17:00:00	18:00:00	1	3	48
4	Lunes	11:00:00	12:00:00	1	4	137
5	Lunes	09:00:00	10:00:00	1	5	15
6	Lunes	08:00:00	09:00:00	1	5	15
7	Martes	08:00:00	09:00:00	1	6	15
8	Martes	13:00:00	14:00:00	1	1	132
9	Martes	09:00:00	10:00:00	1	6	15
10	Martes	17:00:00	18:00:00	1	3	48
11	Martes	12:00:00	13:00:00	1	2	63
12	Martes	11:00:00	12:00:00	1	4	137
13	Miércoles	17:00:00	18:00:00	1	3	48
14	Miércoles	09:00:00	10:00:00	1	5	15
15	Miércoles	11:00:00	12:00:00	1	4	137
16	Miércoles	12:00:00	13:00:00	1	2	63
17	Miércoles	13:00:00	14:00:00	1	1	132
18	Miércoles	08:00:00	09:00:00	1	5	15
19	Jueves	17:00:00	18:00:00	1	3	48
20	Jueves	13:00:00	14:00:00	1	1	132
21	Jueves	08:00:00	09:00:00	1	6	15
22	Jueves	09:00:00	10:00:00	1	6	15
23	Jueves	11:00:00	12:00:00	1	4	137
24	Viernes	13:00:00	14:00:00	1	1	132
25	Viernes	08:00:00	09:00:00	1	5	15
26	Viernes	09:00:00	10:00:00	1	6	15
27	Viernes	17:00:00	18:00:00	1	3	48
28	Viernes	12:00:00	13:00:00	1	2	63
29	Viernes	11:00:00	12:00:00	1	4	137
30	Lunes	13:00:00	14:00:00	2	7	61
31	Lunes	09:00:00	10:00:00	2	8	45
32	Lunes	11:00:00	12:00:00	2	9	45
33	Lunes	16:00:00	17:00:00	2	10	45
34	Lunes	17:00:00	18:00:00	2	11	35
35	Lunes	10:00:00	11:00:00	2	12	31
36	Martes	17:00:00	18:00:00	2	11	35
37	Martes	10:00:00	11:00:00	2	12	31
38	Martes	13:00:00	14:00:00	2	7	61
39	Martes	11:00:00	12:00:00	2	9	45
40	Martes	16:00:00	17:00:00	2	10	45
41	Martes	09:00:00	10:00:00	2	8	45
42	Miércoles	16:00:00	17:00:00	2	10	45
43	Miércoles	17:00:00	18:00:00	2	11	35
44	Miércoles	13:00:00	14:00:00	2	7	61
45	Miércoles	11:00:00	12:00:00	2	9	45
46	Miércoles	09:00:00	10:00:00	2	8	45
47	Miércoles	10:00:00	11:00:00	2	12	31
48	Jueves	16:00:00	17:00:00	2	10	45
49	Jueves	09:00:00	10:00:00	2	8	45
50	Jueves	11:00:00	12:00:00	2	9	45
51	Jueves	10:00:00	11:00:00	2	12	31
52	Jueves	17:00:00	18:00:00	2	11	35
53	Jueves	13:00:00	14:00:00	2	7	61
54	Viernes	17:00:00	18:00:00	2	11	35
55	Viernes	11:00:00	12:00:00	2	9	45
56	Viernes	09:00:00	10:00:00	2	8	45
57	Viernes	10:00:00	11:00:00	2	12	31
58	Viernes	16:00:00	17:00:00	2	10	45
59	Viernes	13:00:00	14:00:00	2	7	61
60	Lunes	13:00:00	14:00:00	3	7	61
61	Lunes	11:00:00	12:00:00	3	8	44
62	Lunes	10:00:00	11:00:00	3	9	45
63	Lunes	16:00:00	17:00:00	3	10	45
64	Lunes	12:00:00	13:00:00	3	13	35
65	Lunes	17:00:00	18:00:00	3	14	31
66	Martes	12:00:00	13:00:00	3	13	35
67	Martes	17:00:00	18:00:00	3	14	31
68	Martes	13:00:00	14:00:00	3	7	61
69	Martes	10:00:00	11:00:00	3	9	45
70	Martes	16:00:00	17:00:00	3	10	45
71	Martes	11:00:00	12:00:00	3	8	44
72	Miércoles	16:00:00	17:00:00	3	10	45
73	Miércoles	12:00:00	13:00:00	3	13	35
74	Miércoles	13:00:00	14:00:00	3	7	61
75	Miércoles	10:00:00	11:00:00	3	9	45
76	Miércoles	11:00:00	12:00:00	3	8	44
77	Miércoles	17:00:00	18:00:00	3	14	31
78	Jueves	16:00:00	17:00:00	3	10	45
79	Jueves	11:00:00	12:00:00	3	8	44
80	Jueves	10:00:00	11:00:00	3	9	45
81	Jueves	17:00:00	18:00:00	3	14	31
82	Jueves	12:00:00	13:00:00	3	13	35
83	Jueves	13:00:00	14:00:00	3	7	61
84	Viernes	12:00:00	13:00:00	3	13	35
85	Viernes	10:00:00	11:00:00	3	9	45
86	Viernes	11:00:00	12:00:00	3	8	44
87	Viernes	17:00:00	18:00:00	3	14	31
88	Viernes	16:00:00	17:00:00	3	10	45
89	Viernes	13:00:00	14:00:00	3	7	61
90	Lunes	16:00:00	17:00:00	4	15	35
91	Lunes	11:00:00	12:00:00	4	16	36
92	Lunes	12:00:00	13:00:00	4	17	44
93	Lunes	09:00:00	10:00:00	4	18	35
94	Lunes	17:00:00	18:00:00	4	19	36
95	Lunes	10:00:00	11:00:00	4	20	36
96	Lunes	13:00:00	14:00:00	4	21	35
97	Martes	13:00:00	14:00:00	4	21	35
98	Martes	10:00:00	11:00:00	4	20	36
99	Martes	17:00:00	18:00:00	4	19	36
100	Martes	16:00:00	17:00:00	4	15	35
101	Martes	12:00:00	13:00:00	4	17	44
102	Martes	09:00:00	10:00:00	4	18	35
103	Martes	11:00:00	12:00:00	4	16	36
104	Miércoles	10:00:00	11:00:00	4	20	36
105	Miércoles	16:00:00	17:00:00	4	15	35
106	Miércoles	17:00:00	18:00:00	4	19	36
107	Miércoles	09:00:00	10:00:00	4	18	35
108	Miércoles	13:00:00	14:00:00	4	21	35
109	Miércoles	12:00:00	13:00:00	4	17	44
110	Miércoles	11:00:00	12:00:00	4	16	36
111	Jueves	09:00:00	10:00:00	4	18	35
112	Jueves	13:00:00	14:00:00	4	21	35
113	Jueves	17:00:00	18:00:00	4	19	36
114	Jueves	11:00:00	12:00:00	4	16	36
115	Jueves	12:00:00	13:00:00	4	17	44
116	Jueves	16:00:00	17:00:00	4	15	35
117	Jueves	10:00:00	11:00:00	4	20	36
118	Viernes	09:00:00	10:00:00	4	18	35
119	Viernes	11:00:00	12:00:00	4	16	36
120	Viernes	12:00:00	13:00:00	4	17	44
121	Viernes	13:00:00	14:00:00	4	21	35
122	Viernes	17:00:00	18:00:00	4	19	36
123	Viernes	16:00:00	17:00:00	4	15	35
124	Viernes	10:00:00	11:00:00	4	20	36
125	Lunes	17:00:00	18:00:00	5	22	34
126	Lunes	16:00:00	17:00:00	5	23	36
127	Lunes	10:00:00	11:00:00	5	24	93
128	Lunes	11:00:00	12:00:00	5	25	31
129	Lunes	09:00:00	10:00:00	5	26	33
130	Lunes	12:00:00	13:00:00	5	27	36
131	Lunes	08:00:00	09:00:00	5	28	36
132	Martes	08:00:00	09:00:00	5	28	36
133	Martes	12:00:00	13:00:00	5	27	36
134	Martes	09:00:00	10:00:00	5	26	33
135	Martes	17:00:00	18:00:00	5	22	34
136	Martes	10:00:00	11:00:00	5	24	93
137	Martes	11:00:00	12:00:00	5	25	31
138	Martes	16:00:00	17:00:00	5	23	36
139	Miércoles	12:00:00	13:00:00	5	27	36
140	Miércoles	17:00:00	18:00:00	5	22	34
141	Miércoles	09:00:00	10:00:00	5	26	33
142	Miércoles	11:00:00	12:00:00	5	25	31
143	Miércoles	08:00:00	09:00:00	5	28	36
144	Miércoles	10:00:00	11:00:00	5	24	93
145	Miércoles	16:00:00	17:00:00	5	23	36
146	Jueves	11:00:00	12:00:00	5	25	31
147	Jueves	08:00:00	09:00:00	5	28	36
148	Jueves	09:00:00	10:00:00	5	26	33
149	Jueves	16:00:00	17:00:00	5	23	36
150	Jueves	10:00:00	11:00:00	5	24	93
151	Jueves	17:00:00	18:00:00	5	22	34
152	Jueves	12:00:00	13:00:00	5	27	36
153	Viernes	11:00:00	12:00:00	5	25	31
154	Viernes	16:00:00	17:00:00	5	23	36
155	Viernes	10:00:00	11:00:00	5	24	93
156	Viernes	08:00:00	09:00:00	5	28	36
157	Viernes	09:00:00	10:00:00	5	26	33
158	Viernes	17:00:00	18:00:00	5	22	34
159	Viernes	12:00:00	13:00:00	5	27	36
160	Lunes	16:00:00	17:00:00	6	29	34
161	Lunes	09:00:00	10:00:00	6	30	32
162	Lunes	17:00:00	18:00:00	6	31	98
163	Lunes	10:00:00	11:00:00	6	32	35
164	Lunes	13:00:00	14:00:00	6	33	36
165	Lunes	08:00:00	09:00:00	6	34	34
166	Lunes	11:00:00	12:00:00	6	35	35
167	Martes	11:00:00	12:00:00	6	35	35
168	Martes	08:00:00	09:00:00	6	34	34
169	Martes	13:00:00	14:00:00	6	33	36
170	Martes	16:00:00	17:00:00	6	29	34
171	Martes	17:00:00	18:00:00	6	31	98
172	Martes	10:00:00	11:00:00	6	32	35
173	Martes	09:00:00	10:00:00	6	30	32
174	Miércoles	08:00:00	09:00:00	6	34	34
175	Miércoles	16:00:00	17:00:00	6	29	34
176	Miércoles	13:00:00	14:00:00	6	33	36
177	Miércoles	10:00:00	11:00:00	6	32	35
178	Miércoles	11:00:00	12:00:00	6	35	35
179	Miércoles	17:00:00	18:00:00	6	31	98
180	Miércoles	09:00:00	10:00:00	6	30	32
181	Jueves	10:00:00	11:00:00	6	32	35
182	Jueves	11:00:00	12:00:00	6	35	35
183	Jueves	13:00:00	14:00:00	6	33	36
184	Jueves	09:00:00	10:00:00	6	30	32
185	Jueves	17:00:00	18:00:00	6	31	98
186	Jueves	16:00:00	17:00:00	6	29	34
187	Jueves	08:00:00	09:00:00	6	34	34
188	Viernes	10:00:00	11:00:00	6	32	35
189	Viernes	09:00:00	10:00:00	6	30	32
190	Viernes	17:00:00	18:00:00	6	31	98
191	Viernes	11:00:00	12:00:00	6	35	35
192	Viernes	13:00:00	14:00:00	6	33	36
193	Viernes	16:00:00	17:00:00	6	29	34
194	Viernes	08:00:00	09:00:00	6	34	34
195	Lunes	13:00:00	14:00:00	7	36	126
196	Lunes	08:00:00	09:00:00	7	37	50
197	Lunes	12:00:00	13:00:00	7	2	63
198	Lunes	16:00:00	17:00:00	7	38	137
199	Lunes	09:00:00	10:00:00	7	37	50
200	Lunes	17:00:00	18:00:00	7	3	48
201	Martes	08:00:00	09:00:00	7	5	50
202	Martes	09:00:00	10:00:00	7	5	50
203	Martes	17:00:00	18:00:00	7	3	48
204	Martes	12:00:00	13:00:00	7	2	63
205	Martes	16:00:00	17:00:00	7	38	137
206	Martes	13:00:00	14:00:00	7	36	126
207	Miércoles	12:00:00	13:00:00	7	2	63
208	Miércoles	17:00:00	18:00:00	7	3	48
209	Miércoles	08:00:00	09:00:00	7	37	50
210	Miércoles	09:00:00	10:00:00	7	37	50
211	Miércoles	16:00:00	17:00:00	7	38	137
212	Miércoles	13:00:00	14:00:00	7	36	126
213	Jueves	13:00:00	14:00:00	7	36	126
214	Jueves	08:00:00	09:00:00	7	5	50
215	Jueves	17:00:00	18:00:00	7	3	48
216	Jueves	10:00:00	11:00:00	7	38	126
217	Jueves	09:00:00	10:00:00	7	5	50
218	Viernes	08:00:00	09:00:00	7	37	50
219	Viernes	17:00:00	18:00:00	7	3	48
220	Viernes	16:00:00	17:00:00	7	38	137
221	Viernes	12:00:00	13:00:00	7	2	63
222	Viernes	09:00:00	10:00:00	7	5	50
223	Viernes	13:00:00	14:00:00	7	36	126
224	Lunes	09:00:00	10:00:00	8	39	17
225	Lunes	08:00:00	09:00:00	8	40	126
226	Lunes	16:00:00	17:00:00	8	41	15
227	Lunes	11:00:00	12:00:00	8	42	17
228	Lunes	10:00:00	11:00:00	8	43	68
229	Lunes	17:00:00	18:00:00	8	44	17
230	Lunes	12:00:00	13:00:00	8	45	15
231	Martes	12:00:00	13:00:00	8	45	15
232	Martes	17:00:00	18:00:00	8	44	17
233	Martes	10:00:00	11:00:00	8	43	68
234	Martes	09:00:00	10:00:00	8	39	17
235	Martes	16:00:00	17:00:00	8	41	15
236	Martes	11:00:00	12:00:00	8	42	17
237	Martes	08:00:00	09:00:00	8	40	126
238	Miércoles	17:00:00	18:00:00	8	44	17
239	Miércoles	09:00:00	10:00:00	8	39	17
240	Miércoles	10:00:00	11:00:00	8	43	68
241	Miércoles	11:00:00	12:00:00	8	42	17
242	Miércoles	12:00:00	13:00:00	8	45	15
243	Miércoles	16:00:00	17:00:00	8	41	15
244	Miércoles	08:00:00	09:00:00	8	40	126
245	Jueves	11:00:00	12:00:00	8	42	17
246	Jueves	12:00:00	13:00:00	8	45	15
247	Jueves	10:00:00	11:00:00	8	43	68
248	Jueves	08:00:00	09:00:00	8	40	126
249	Jueves	16:00:00	17:00:00	8	41	15
250	Jueves	09:00:00	10:00:00	8	39	17
251	Jueves	17:00:00	18:00:00	8	44	17
252	Viernes	11:00:00	12:00:00	8	42	17
253	Viernes	08:00:00	09:00:00	8	40	126
254	Viernes	16:00:00	17:00:00	8	41	15
255	Viernes	12:00:00	13:00:00	8	45	15
256	Viernes	10:00:00	11:00:00	8	43	68
257	Viernes	09:00:00	10:00:00	8	39	17
258	Viernes	17:00:00	18:00:00	8	44	17
259	Lunes	16:00:00	17:00:00	9	46	68
260	Lunes	08:00:00	09:00:00	9	47	132
261	Lunes	17:00:00	18:00:00	9	48	93
262	Lunes	10:00:00	11:00:00	9	49	26
263	Lunes	11:00:00	12:00:00	9	50	68
264	Lunes	09:00:00	10:00:00	9	51	137
265	Lunes	13:00:00	14:00:00	9	52	68
266	Martes	13:00:00	14:00:00	9	52	68
267	Martes	09:00:00	10:00:00	9	51	137
268	Martes	11:00:00	12:00:00	9	50	68
269	Martes	16:00:00	17:00:00	9	46	68
270	Martes	17:00:00	18:00:00	9	48	93
271	Martes	10:00:00	11:00:00	9	49	26
272	Martes	08:00:00	09:00:00	9	47	132
273	Miércoles	09:00:00	10:00:00	9	51	137
274	Miércoles	16:00:00	17:00:00	9	46	68
275	Miércoles	11:00:00	12:00:00	9	50	68
276	Miércoles	10:00:00	11:00:00	9	49	26
277	Miércoles	13:00:00	14:00:00	9	52	68
278	Miércoles	17:00:00	18:00:00	9	48	93
279	Miércoles	08:00:00	09:00:00	9	47	132
280	Jueves	10:00:00	11:00:00	9	49	26
281	Jueves	13:00:00	14:00:00	9	52	68
282	Jueves	11:00:00	12:00:00	9	50	68
283	Jueves	08:00:00	09:00:00	9	47	132
284	Jueves	17:00:00	18:00:00	9	48	93
285	Jueves	16:00:00	17:00:00	9	46	68
286	Jueves	09:00:00	10:00:00	9	51	137
287	Viernes	10:00:00	11:00:00	9	49	26
288	Viernes	08:00:00	09:00:00	9	47	132
289	Viernes	17:00:00	18:00:00	9	48	93
290	Viernes	13:00:00	14:00:00	9	52	68
291	Viernes	11:00:00	12:00:00	9	50	68
292	Viernes	16:00:00	17:00:00	9	46	68
293	Viernes	09:00:00	10:00:00	9	51	137
294	Lunes	13:00:00	14:00:00	10	53	69
295	Lunes	12:00:00	13:00:00	10	54	132
296	Lunes	17:00:00	18:00:00	10	55	60
297	Lunes	11:00:00	12:00:00	10	56	27
298	Lunes	16:00:00	17:00:00	10	57	69
299	Lunes	08:00:00	09:00:00	10	58	69
300	Lunes	10:00:00	11:00:00	10	59	69
301	Martes	10:00:00	11:00:00	10	59	69
302	Martes	08:00:00	09:00:00	10	58	69
303	Martes	16:00:00	17:00:00	10	57	69
304	Martes	13:00:00	14:00:00	10	53	69
305	Martes	17:00:00	18:00:00	10	55	60
306	Martes	11:00:00	12:00:00	10	56	27
307	Martes	12:00:00	13:00:00	10	54	132
308	Miércoles	08:00:00	09:00:00	10	58	69
309	Miércoles	13:00:00	14:00:00	10	53	69
310	Miércoles	16:00:00	17:00:00	10	57	69
311	Miércoles	11:00:00	12:00:00	10	56	27
312	Miércoles	10:00:00	11:00:00	10	59	69
313	Miércoles	17:00:00	18:00:00	10	55	60
314	Miércoles	12:00:00	13:00:00	10	54	132
315	Jueves	11:00:00	12:00:00	10	56	27
316	Jueves	10:00:00	11:00:00	10	59	69
317	Jueves	16:00:00	17:00:00	10	57	69
318	Jueves	12:00:00	13:00:00	10	54	132
319	Jueves	17:00:00	18:00:00	10	55	60
320	Jueves	13:00:00	14:00:00	10	53	69
321	Jueves	08:00:00	09:00:00	10	58	69
322	Viernes	11:00:00	12:00:00	10	56	27
323	Viernes	12:00:00	13:00:00	10	54	132
324	Viernes	17:00:00	18:00:00	10	55	60
325	Viernes	10:00:00	11:00:00	10	59	69
326	Viernes	16:00:00	17:00:00	10	57	69
327	Viernes	13:00:00	14:00:00	10	53	69
328	Viernes	08:00:00	09:00:00	10	58	69
329	Lunes	13:00:00	14:00:00	11	60	27
330	Lunes	08:00:00	09:00:00	11	61	122
331	Lunes	17:00:00	18:00:00	11	62	42
332	Lunes	12:00:00	13:00:00	11	63	70
333	Lunes	09:00:00	10:00:00	11	64	70
334	Lunes	16:00:00	17:00:00	11	65	70
335	Lunes	11:00:00	12:00:00	11	66	70
336	Martes	11:00:00	12:00:00	11	66	70
337	Martes	16:00:00	17:00:00	11	65	70
338	Martes	09:00:00	10:00:00	11	64	70
339	Martes	13:00:00	14:00:00	11	60	27
340	Martes	17:00:00	18:00:00	11	62	42
341	Martes	12:00:00	13:00:00	11	63	70
342	Martes	08:00:00	09:00:00	11	61	122
343	Miércoles	16:00:00	17:00:00	11	65	70
344	Miércoles	13:00:00	14:00:00	11	60	27
345	Miércoles	09:00:00	10:00:00	11	64	70
346	Miércoles	12:00:00	13:00:00	11	63	70
347	Miércoles	11:00:00	12:00:00	11	66	70
348	Miércoles	17:00:00	18:00:00	11	62	42
349	Miércoles	08:00:00	09:00:00	11	61	122
350	Jueves	12:00:00	13:00:00	11	63	70
351	Jueves	11:00:00	12:00:00	11	66	70
352	Jueves	09:00:00	10:00:00	11	64	70
353	Jueves	08:00:00	09:00:00	11	61	122
354	Jueves	17:00:00	18:00:00	11	62	42
355	Jueves	13:00:00	14:00:00	11	60	27
356	Jueves	16:00:00	17:00:00	11	65	70
357	Viernes	12:00:00	13:00:00	11	63	70
358	Viernes	08:00:00	09:00:00	11	61	122
359	Viernes	17:00:00	18:00:00	11	62	42
360	Viernes	11:00:00	12:00:00	11	66	70
361	Viernes	09:00:00	10:00:00	11	64	70
362	Viernes	13:00:00	14:00:00	11	60	27
363	Viernes	16:00:00	17:00:00	11	65	70
364	Lunes	12:00:00	13:00:00	12	67	137
365	Lunes	11:00:00	12:00:00	12	68	122
366	Lunes	13:00:00	14:00:00	12	69	70
367	Lunes	16:00:00	17:00:00	12	70	14
368	Lunes	10:00:00	11:00:00	12	71	8
369	Lunes	17:00:00	18:00:00	12	72	26
370	Lunes	09:00:00	10:00:00	12	73	8
371	Martes	11:00:00	12:00:00	12	68	122
372	Martes	09:00:00	10:00:00	12	73	8
373	Martes	10:00:00	11:00:00	12	71	8
374	Martes	12:00:00	13:00:00	12	67	137
375	Martes	13:00:00	14:00:00	12	69	70
376	Martes	16:00:00	17:00:00	12	70	14
377	Miércoles	09:00:00	10:00:00	12	73	8
378	Miércoles	12:00:00	13:00:00	12	67	137
379	Miércoles	10:00:00	11:00:00	12	71	8
380	Miércoles	16:00:00	17:00:00	12	70	14
381	Miércoles	17:00:00	18:00:00	12	72	26
382	Miércoles	13:00:00	14:00:00	12	69	70
383	Miércoles	11:00:00	12:00:00	12	68	122
384	Jueves	16:00:00	17:00:00	12	70	14
385	Jueves	17:00:00	18:00:00	12	72	26
386	Jueves	10:00:00	11:00:00	12	71	8
387	Jueves	11:00:00	12:00:00	12	68	122
388	Jueves	13:00:00	14:00:00	12	69	70
389	Jueves	12:00:00	13:00:00	12	67	137
390	Jueves	09:00:00	10:00:00	12	73	8
391	Viernes	16:00:00	17:00:00	12	70	14
392	Viernes	11:00:00	12:00:00	12	68	122
393	Viernes	13:00:00	14:00:00	12	69	70
394	Viernes	17:00:00	18:00:00	12	72	26
395	Viernes	10:00:00	11:00:00	12	71	8
396	Viernes	12:00:00	13:00:00	12	67	137
397	Viernes	09:00:00	10:00:00	12	73	8
398	Lunes	12:00:00	13:00:00	13	74	9
399	Lunes	17:00:00	18:00:00	13	75	126
400	Lunes	13:00:00	14:00:00	13	76	65
401	Lunes	11:00:00	12:00:00	13	77	9
402	Lunes	16:00:00	17:00:00	13	78	9
403	Lunes	10:00:00	11:00:00	13	79	15
404	Lunes	09:00:00	10:00:00	13	80	26
405	Martes	09:00:00	10:00:00	13	80	26
406	Martes	10:00:00	11:00:00	13	79	15
407	Martes	16:00:00	17:00:00	13	78	9
408	Martes	12:00:00	13:00:00	13	74	9
409	Martes	13:00:00	14:00:00	13	76	65
410	Martes	11:00:00	12:00:00	13	77	9
411	Martes	17:00:00	18:00:00	13	75	126
412	Miércoles	10:00:00	11:00:00	13	79	15
413	Miércoles	12:00:00	13:00:00	13	74	9
414	Miércoles	16:00:00	17:00:00	13	78	9
415	Miércoles	11:00:00	12:00:00	13	77	9
416	Miércoles	09:00:00	10:00:00	13	80	26
417	Miércoles	13:00:00	14:00:00	13	76	65
418	Miércoles	17:00:00	18:00:00	13	75	126
419	Jueves	11:00:00	12:00:00	13	77	9
420	Jueves	09:00:00	10:00:00	13	80	26
421	Jueves	16:00:00	17:00:00	13	78	9
422	Jueves	17:00:00	18:00:00	13	75	126
423	Jueves	13:00:00	14:00:00	13	76	65
424	Jueves	12:00:00	13:00:00	13	74	9
425	Jueves	10:00:00	11:00:00	13	79	15
426	Viernes	11:00:00	12:00:00	13	77	9
427	Viernes	17:00:00	18:00:00	13	75	126
428	Viernes	13:00:00	14:00:00	13	76	65
429	Viernes	09:00:00	10:00:00	13	80	26
430	Viernes	16:00:00	17:00:00	13	78	9
431	Viernes	12:00:00	13:00:00	13	74	9
432	Viernes	10:00:00	11:00:00	13	79	15
433	Lunes	16:00:00	17:00:00	14	81	27
434	Lunes	09:00:00	10:00:00	14	82	9
435	Lunes	17:00:00	18:00:00	14	83	15
436	Lunes	10:00:00	11:00:00	14	84	9
437	Lunes	13:00:00	14:00:00	14	85	137
438	Lunes	12:00:00	13:00:00	14	86	43
439	Lunes	11:00:00	12:00:00	14	87	132
440	Martes	10:00:00	11:00:00	14	84	9
441	Martes	12:00:00	13:00:00	14	86	43
442	Martes	13:00:00	14:00:00	14	85	137
443	Martes	17:00:00	18:00:00	14	83	15
444	Martes	11:00:00	12:00:00	14	87	132
445	Martes	16:00:00	17:00:00	14	81	27
446	Miércoles	11:00:00	12:00:00	14	87	132
447	Miércoles	09:00:00	10:00:00	14	82	9
448	Miércoles	16:00:00	17:00:00	14	81	27
449	Miércoles	13:00:00	14:00:00	14	85	137
450	Miércoles	17:00:00	18:00:00	14	83	15
451	Miércoles	12:00:00	13:00:00	14	86	43
452	Jueves	09:00:00	10:00:00	14	82	9
453	Jueves	16:00:00	17:00:00	14	81	27
454	Jueves	13:00:00	14:00:00	14	85	137
455	Jueves	10:00:00	11:00:00	14	84	9
456	Jueves	12:00:00	13:00:00	14	86	43
457	Jueves	11:00:00	12:00:00	14	87	132
458	Viernes	12:00:00	13:00:00	14	86	43
459	Viernes	09:00:00	10:00:00	14	82	9
460	Viernes	17:00:00	18:00:00	14	83	15
461	Viernes	13:00:00	14:00:00	14	85	137
462	Viernes	10:00:00	11:00:00	14	84	9
463	Viernes	11:00:00	12:00:00	14	87	132
464	Lunes	11:00:00	12:00:00	15	88	42
465	Lunes	13:00:00	14:00:00	15	89	9
466	Lunes	09:00:00	10:00:00	15	90	60
467	Lunes	16:00:00	17:00:00	15	91	60
468	Lunes	12:00:00	13:00:00	15	92	26
469	Lunes	17:00:00	18:00:00	15	93	132
470	Martes	12:00:00	13:00:00	15	92	26
471	Martes	17:00:00	18:00:00	15	93	132
472	Martes	11:00:00	12:00:00	15	88	42
473	Martes	09:00:00	10:00:00	15	90	60
474	Martes	16:00:00	17:00:00	15	91	60
475	Martes	13:00:00	14:00:00	15	89	9
476	Miércoles	16:00:00	17:00:00	15	91	60
477	Miércoles	12:00:00	13:00:00	15	92	26
478	Miércoles	11:00:00	12:00:00	15	88	42
479	Miércoles	09:00:00	10:00:00	15	90	60
480	Miércoles	13:00:00	14:00:00	15	89	9
481	Miércoles	17:00:00	18:00:00	15	93	132
482	Jueves	16:00:00	17:00:00	15	91	60
483	Jueves	13:00:00	14:00:00	15	89	9
484	Jueves	09:00:00	10:00:00	15	90	60
485	Jueves	17:00:00	18:00:00	15	93	132
486	Jueves	12:00:00	13:00:00	15	92	26
487	Jueves	11:00:00	12:00:00	15	88	42
488	Viernes	12:00:00	13:00:00	15	92	26
489	Viernes	09:00:00	10:00:00	15	90	60
490	Viernes	13:00:00	14:00:00	15	89	9
491	Viernes	17:00:00	18:00:00	15	93	132
492	Viernes	16:00:00	17:00:00	15	91	60
493	Viernes	11:00:00	12:00:00	15	88	42
494	Lunes	17:00:00	18:00:00	16	94	7
495	Lunes	16:00:00	17:00:00	16	95	132
496	Lunes	13:00:00	14:00:00	16	96	93
497	Lunes	12:00:00	13:00:00	16	97	7
498	Lunes	08:00:00	09:00:00	16	98	27
499	Lunes	09:00:00	10:00:00	16	99	27
500	Lunes	11:00:00	12:00:00	16	100	7
501	Martes	11:00:00	12:00:00	16	100	7
502	Martes	09:00:00	10:00:00	16	99	27
503	Martes	08:00:00	09:00:00	16	98	27
504	Martes	17:00:00	18:00:00	16	94	7
505	Martes	13:00:00	14:00:00	16	96	93
506	Martes	12:00:00	13:00:00	16	97	7
507	Martes	16:00:00	17:00:00	16	95	132
508	Miércoles	09:00:00	10:00:00	16	99	27
509	Miércoles	17:00:00	18:00:00	16	94	7
510	Miércoles	08:00:00	09:00:00	16	98	27
511	Miércoles	12:00:00	13:00:00	16	97	7
512	Miércoles	11:00:00	12:00:00	16	100	7
513	Miércoles	13:00:00	14:00:00	16	96	93
514	Miércoles	16:00:00	17:00:00	16	95	132
515	Jueves	12:00:00	13:00:00	16	97	7
516	Jueves	11:00:00	12:00:00	16	100	7
517	Jueves	08:00:00	09:00:00	16	98	27
518	Jueves	16:00:00	17:00:00	16	95	132
519	Jueves	13:00:00	14:00:00	16	96	93
520	Jueves	17:00:00	18:00:00	16	94	7
521	Jueves	09:00:00	10:00:00	16	99	27
522	Viernes	12:00:00	13:00:00	16	97	7
523	Viernes	16:00:00	17:00:00	16	95	132
524	Viernes	13:00:00	14:00:00	16	96	93
525	Viernes	11:00:00	12:00:00	16	100	7
526	Viernes	08:00:00	09:00:00	16	98	27
527	Viernes	17:00:00	18:00:00	16	94	7
528	Viernes	09:00:00	10:00:00	16	99	27
529	Lunes	16:00:00	17:00:00	17	101	52
530	Lunes	11:00:00	12:00:00	17	102	52
531	Lunes	17:00:00	18:00:00	17	103	52
532	Lunes	13:00:00	14:00:00	17	104	51
533	Lunes	12:00:00	13:00:00	17	105	52
534	Lunes	09:00:00	10:00:00	17	106	52
535	Lunes	10:00:00	11:00:00	17	107	52
536	Martes	11:00:00	12:00:00	17	102	52
537	Martes	17:00:00	18:00:00	17	103	52
538	Martes	09:00:00	10:00:00	17	106	52
539	Martes	16:00:00	17:00:00	17	108	52
540	Martes	12:00:00	13:00:00	17	105	52
541	Martes	13:00:00	14:00:00	17	104	51
542	Martes	10:00:00	11:00:00	17	107	52
543	Miércoles	13:00:00	14:00:00	17	104	51
544	Miércoles	09:00:00	10:00:00	17	106	52
545	Miércoles	16:00:00	17:00:00	17	101	52
546	Miércoles	17:00:00	18:00:00	17	108	52
547	Miércoles	10:00:00	11:00:00	17	107	52
548	Miércoles	11:00:00	12:00:00	17	108	52
549	Miércoles	12:00:00	13:00:00	17	105	52
550	Jueves	11:00:00	12:00:00	17	102	52
551	Jueves	17:00:00	18:00:00	17	103	52
552	Jueves	13:00:00	14:00:00	17	104	51
553	Jueves	09:00:00	10:00:00	17	106	52
554	Jueves	12:00:00	13:00:00	17	108	52
555	Jueves	16:00:00	17:00:00	17	101	52
556	Jueves	10:00:00	11:00:00	17	107	52
557	Viernes	13:00:00	14:00:00	17	104	51
558	Viernes	17:00:00	18:00:00	17	103	52
559	Viernes	10:00:00	11:00:00	17	107	52
560	Viernes	16:00:00	17:00:00	17	101	52
561	Viernes	09:00:00	10:00:00	17	106	52
562	Viernes	11:00:00	12:00:00	17	102	52
563	Viernes	12:00:00	13:00:00	17	105	52
564	Lunes	08:00:00	09:00:00	18	109	54
565	Lunes	16:00:00	17:00:00	18	110	54
566	Lunes	11:00:00	12:00:00	18	111	140
567	Lunes	12:00:00	13:00:00	18	112	54
568	Lunes	17:00:00	18:00:00	18	113	54
569	Lunes	09:00:00	10:00:00	18	114	54
570	Lunes	10:00:00	11:00:00	18	115	27
571	Lunes	13:00:00	14:00:00	18	116	51
572	Martes	16:00:00	17:00:00	18	117	54
573	Martes	17:00:00	18:00:00	18	113	54
574	Martes	13:00:00	14:00:00	18	116	51
575	Martes	09:00:00	10:00:00	18	114	54
576	Martes	08:00:00	09:00:00	18	117	54
577	Martes	11:00:00	12:00:00	18	111	140
578	Martes	12:00:00	13:00:00	18	112	54
579	Martes	10:00:00	11:00:00	18	115	27
580	Miércoles	12:00:00	13:00:00	18	112	54
581	Miércoles	10:00:00	11:00:00	18	115	27
582	Miércoles	17:00:00	18:00:00	18	117	54
583	Miércoles	09:00:00	10:00:00	18	117	54
584	Miércoles	13:00:00	14:00:00	18	116	51
585	Miércoles	16:00:00	17:00:00	18	110	54
586	Miércoles	08:00:00	09:00:00	18	109	54
587	Miércoles	11:00:00	12:00:00	18	111	140
588	Jueves	12:00:00	13:00:00	18	117	54
589	Jueves	09:00:00	10:00:00	18	114	54
590	Jueves	08:00:00	09:00:00	18	109	54
591	Jueves	17:00:00	18:00:00	18	113	54
592	Jueves	13:00:00	14:00:00	18	116	51
593	Jueves	16:00:00	17:00:00	18	110	54
594	Jueves	11:00:00	12:00:00	18	111	140
595	Jueves	10:00:00	11:00:00	18	117	54
596	Viernes	09:00:00	10:00:00	18	114	54
597	Viernes	11:00:00	12:00:00	18	111	140
598	Viernes	16:00:00	17:00:00	18	110	54
599	Viernes	13:00:00	14:00:00	18	116	51
600	Viernes	17:00:00	18:00:00	18	113	54
601	Viernes	08:00:00	09:00:00	18	109	54
602	Viernes	10:00:00	11:00:00	18	115	27
603	Viernes	12:00:00	13:00:00	18	112	54
604	Lunes	10:00:00	11:00:00	19	118	56
605	Lunes	16:00:00	17:00:00	19	119	56
606	Lunes	09:00:00	10:00:00	19	120	140
607	Lunes	13:00:00	14:00:00	19	121	51
608	Lunes	12:00:00	13:00:00	19	122	56
609	Lunes	11:00:00	12:00:00	19	123	56
610	Lunes	17:00:00	18:00:00	19	124	56
611	Martes	09:00:00	10:00:00	19	120	140
612	Martes	16:00:00	17:00:00	19	119	56
613	Martes	17:00:00	18:00:00	19	119	56
614	Martes	13:00:00	14:00:00	19	121	51
615	Martes	11:00:00	12:00:00	19	124	56
616	Martes	10:00:00	11:00:00	19	124	56
617	Martes	12:00:00	13:00:00	19	122	56
618	Miércoles	09:00:00	10:00:00	19	120	140
619	Miércoles	11:00:00	12:00:00	19	123	56
620	Miércoles	12:00:00	13:00:00	19	122	56
621	Miércoles	10:00:00	11:00:00	19	118	56
622	Miércoles	13:00:00	14:00:00	19	121	51
623	Miércoles	17:00:00	18:00:00	19	124	56
624	Miércoles	16:00:00	17:00:00	19	119	56
625	Jueves	12:00:00	13:00:00	19	122	56
626	Jueves	10:00:00	11:00:00	19	118	56
627	Jueves	13:00:00	14:00:00	19	121	51
628	Jueves	09:00:00	10:00:00	19	120	140
629	Jueves	11:00:00	12:00:00	19	123	56
630	Jueves	16:00:00	17:00:00	19	119	56
631	Jueves	17:00:00	18:00:00	19	124	56
632	Viernes	16:00:00	17:00:00	19	119	56
633	Viernes	12:00:00	13:00:00	19	122	56
634	Viernes	09:00:00	10:00:00	19	120	140
635	Viernes	13:00:00	14:00:00	19	121	51
636	Viernes	10:00:00	11:00:00	19	118	56
637	Viernes	11:00:00	12:00:00	19	123	56
638	Viernes	17:00:00	18:00:00	19	124	56
639	Lunes	10:00:00	11:00:00	20	125	140
640	Lunes	17:00:00	18:00:00	20	126	57
641	Lunes	09:00:00	10:00:00	20	127	57
642	Lunes	16:00:00	17:00:00	20	128	117
643	Lunes	12:00:00	13:00:00	20	129	57
644	Lunes	13:00:00	14:00:00	20	130	51
645	Lunes	11:00:00	12:00:00	20	131	117
646	Martes	09:00:00	10:00:00	20	127	57
647	Martes	11:00:00	12:00:00	20	131	117
648	Martes	10:00:00	11:00:00	20	125	140
649	Martes	13:00:00	14:00:00	20	130	51
650	Martes	17:00:00	18:00:00	20	126	57
651	Martes	12:00:00	13:00:00	20	132	57
652	Martes	16:00:00	17:00:00	20	128	117
653	Miércoles	13:00:00	14:00:00	20	130	51
654	Miércoles	09:00:00	10:00:00	20	132	57
655	Miércoles	11:00:00	12:00:00	20	131	117
656	Miércoles	16:00:00	17:00:00	20	128	117
657	Miércoles	17:00:00	18:00:00	20	126	57
658	Miércoles	10:00:00	11:00:00	20	125	140
659	Miércoles	12:00:00	13:00:00	20	129	57
660	Jueves	17:00:00	18:00:00	20	125	57
661	Jueves	09:00:00	10:00:00	20	127	57
662	Jueves	13:00:00	14:00:00	20	130	51
663	Jueves	10:00:00	11:00:00	20	125	140
664	Jueves	16:00:00	17:00:00	20	128	117
665	Jueves	11:00:00	12:00:00	20	132	117
666	Jueves	12:00:00	13:00:00	20	129	57
667	Viernes	10:00:00	11:00:00	20	125	140
668	Viernes	13:00:00	14:00:00	20	130	51
669	Viernes	17:00:00	18:00:00	20	126	57
670	Viernes	11:00:00	12:00:00	20	131	117
671	Viernes	09:00:00	10:00:00	20	127	57
672	Viernes	12:00:00	13:00:00	20	129	57
673	Viernes	16:00:00	17:00:00	20	128	117
674	Lunes	16:00:00	17:00:00	21	133	117
675	Lunes	09:00:00	10:00:00	21	134	58
676	Lunes	10:00:00	11:00:00	21	135	58
677	Lunes	12:00:00	13:00:00	21	136	117
678	Lunes	17:00:00	18:00:00	21	137	58
679	Lunes	13:00:00	14:00:00	21	138	51
680	Lunes	11:00:00	12:00:00	21	139	140
681	Martes	09:00:00	10:00:00	21	134	58
682	Martes	12:00:00	13:00:00	21	140	117
683	Martes	10:00:00	11:00:00	21	135	58
684	Martes	11:00:00	12:00:00	21	139	140
685	Martes	13:00:00	14:00:00	21	138	51
686	Martes	17:00:00	18:00:00	21	137	58
687	Martes	16:00:00	17:00:00	21	133	117
688	Miércoles	10:00:00	11:00:00	21	140	58
689	Miércoles	11:00:00	12:00:00	21	139	140
690	Miércoles	13:00:00	14:00:00	21	138	51
691	Miércoles	12:00:00	13:00:00	21	136	117
692	Miércoles	16:00:00	17:00:00	21	133	117
693	Miércoles	09:00:00	10:00:00	21	134	58
694	Miércoles	17:00:00	18:00:00	21	140	58
695	Jueves	13:00:00	14:00:00	21	138	51
696	Jueves	12:00:00	13:00:00	21	136	117
697	Jueves	11:00:00	12:00:00	21	139	140
698	Jueves	17:00:00	18:00:00	21	137	58
699	Jueves	09:00:00	10:00:00	21	140	58
700	Jueves	16:00:00	17:00:00	21	133	117
701	Jueves	10:00:00	11:00:00	21	135	58
702	Viernes	11:00:00	12:00:00	21	139	140
703	Viernes	12:00:00	13:00:00	21	136	117
704	Viernes	09:00:00	10:00:00	21	134	58
705	Viernes	13:00:00	14:00:00	21	138	51
706	Viernes	16:00:00	17:00:00	21	133	117
707	Viernes	10:00:00	11:00:00	21	135	58
708	Viernes	17:00:00	18:00:00	21	137	58
709	Lunes	17:00:00	18:00:00	22	141	117
710	Lunes	13:00:00	14:00:00	22	142	51
711	Lunes	12:00:00	13:00:00	22	143	59
712	Lunes	16:00:00	17:00:00	22	144	59
713	Lunes	11:00:00	12:00:00	22	145	59
714	Martes	13:00:00	14:00:00	22	142	51
715	Martes	12:00:00	13:00:00	22	145	59
716	Martes	17:00:00	18:00:00	22	141	117
717	Martes	11:00:00	12:00:00	22	145	59
718	Martes	16:00:00	17:00:00	22	144	59
719	Miércoles	11:00:00	12:00:00	22	145	59
720	Miércoles	13:00:00	14:00:00	22	142	51
721	Miércoles	12:00:00	13:00:00	22	143	59
722	Miércoles	17:00:00	18:00:00	22	141	117
723	Jueves	17:00:00	18:00:00	22	141	117
724	Jueves	16:00:00	17:00:00	22	144	59
725	Jueves	12:00:00	13:00:00	22	143	59
726	Jueves	13:00:00	14:00:00	22	142	51
727	Jueves	11:00:00	12:00:00	22	145	59
728	Viernes	16:00:00	17:00:00	22	144	59
729	Viernes	12:00:00	13:00:00	22	143	59
730	Viernes	11:00:00	12:00:00	22	145	59
731	Viernes	17:00:00	18:00:00	22	141	117
732	Viernes	13:00:00	14:00:00	22	142	51
733	Lunes	11:00:00	12:00:00	23	146	61
734	Lunes	08:00:00	09:00:00	23	147	128
735	Lunes	17:00:00	18:00:00	23	148	78
736	Lunes	12:00:00	13:00:00	23	149	48
737	Lunes	13:00:00	14:00:00	23	149	48
738	Lunes	09:00:00	10:00:00	23	150	48
739	Lunes	16:00:00	17:00:00	23	151	48
740	Martes	16:00:00	17:00:00	23	151	48
741	Martes	13:00:00	14:00:00	23	149	48
742	Martes	09:00:00	10:00:00	23	150	48
743	Martes	17:00:00	18:00:00	23	148	78
744	Martes	11:00:00	12:00:00	23	146	61
745	Martes	10:00:00	11:00:00	23	152	48
746	Martes	08:00:00	09:00:00	23	147	128
747	Miércoles	09:00:00	10:00:00	23	152	48
748	Miércoles	16:00:00	17:00:00	23	151	48
749	Miércoles	08:00:00	09:00:00	23	147	128
750	Miércoles	11:00:00	12:00:00	23	146	61
751	Miércoles	17:00:00	18:00:00	23	148	78
752	Miércoles	13:00:00	14:00:00	23	149	48
753	Miércoles	10:00:00	11:00:00	23	152	48
754	Jueves	08:00:00	09:00:00	23	147	128
755	Jueves	11:00:00	12:00:00	23	146	61
756	Jueves	09:00:00	10:00:00	23	150	48
757	Jueves	17:00:00	18:00:00	23	148	78
758	Jueves	16:00:00	17:00:00	23	151	48
759	Jueves	13:00:00	14:00:00	23	149	48
760	Jueves	10:00:00	11:00:00	23	152	48
761	Viernes	10:00:00	11:00:00	23	152	48
762	Viernes	13:00:00	14:00:00	23	149	48
763	Viernes	17:00:00	18:00:00	23	148	78
764	Viernes	09:00:00	10:00:00	23	150	48
765	Viernes	11:00:00	12:00:00	23	146	61
766	Viernes	16:00:00	17:00:00	23	151	48
767	Viernes	08:00:00	09:00:00	23	147	128
768	Lunes	11:00:00	12:00:00	24	153	107
769	Lunes	16:00:00	17:00:00	24	154	107
770	Lunes	10:00:00	11:00:00	24	155	107
771	Lunes	12:00:00	13:00:00	24	156	107
772	Lunes	17:00:00	18:00:00	24	157	128
773	Lunes	13:00:00	14:00:00	24	158	107
774	Lunes	09:00:00	10:00:00	24	159	88
775	Martes	17:00:00	18:00:00	24	157	128
776	Martes	11:00:00	12:00:00	24	153	107
777	Martes	12:00:00	13:00:00	24	153	107
778	Martes	13:00:00	14:00:00	24	158	107
779	Martes	09:00:00	10:00:00	24	159	88
780	Martes	10:00:00	11:00:00	24	155	107
781	Martes	16:00:00	17:00:00	24	154	107
782	Miércoles	11:00:00	12:00:00	24	153	107
783	Miércoles	16:00:00	17:00:00	24	154	107
784	Miércoles	12:00:00	13:00:00	24	156	107
785	Miércoles	13:00:00	14:00:00	24	158	107
786	Miércoles	09:00:00	10:00:00	24	159	88
787	Miércoles	17:00:00	18:00:00	24	157	128
788	Miércoles	10:00:00	11:00:00	24	155	107
789	Jueves	09:00:00	10:00:00	24	159	88
790	Jueves	12:00:00	13:00:00	24	156	107
791	Jueves	16:00:00	17:00:00	24	154	107
792	Jueves	11:00:00	12:00:00	24	153	107
793	Jueves	10:00:00	11:00:00	24	155	107
794	Jueves	17:00:00	18:00:00	24	157	128
795	Viernes	12:00:00	13:00:00	24	156	107
796	Viernes	13:00:00	14:00:00	24	158	107
797	Viernes	10:00:00	11:00:00	24	155	107
798	Viernes	09:00:00	10:00:00	24	156	80
799	Viernes	17:00:00	18:00:00	24	157	128
800	Viernes	16:00:00	17:00:00	24	154	107
801	Viernes	11:00:00	12:00:00	24	153	107
802	Lunes	17:00:00	18:00:00	25	160	65
803	Lunes	11:00:00	12:00:00	25	161	47
804	Lunes	09:00:00	10:00:00	25	162	47
805	Lunes	10:00:00	11:00:00	25	163	47
806	Lunes	13:00:00	14:00:00	25	164	47
807	Lunes	08:00:00	09:00:00	25	165	129
808	Lunes	16:00:00	17:00:00	25	166	47
809	Martes	13:00:00	14:00:00	25	164	47
810	Martes	11:00:00	12:00:00	25	161	47
811	Martes	17:00:00	18:00:00	25	160	65
812	Martes	08:00:00	09:00:00	25	165	129
813	Martes	16:00:00	17:00:00	25	166	47
814	Martes	10:00:00	11:00:00	25	163	47
815	Martes	09:00:00	10:00:00	25	162	47
816	Miércoles	11:00:00	12:00:00	25	161	47
817	Miércoles	13:00:00	14:00:00	25	164	47
818	Miércoles	09:00:00	10:00:00	25	162	47
819	Miércoles	16:00:00	17:00:00	25	166	47
820	Miércoles	17:00:00	18:00:00	25	160	65
821	Miércoles	08:00:00	09:00:00	25	165	129
822	Miércoles	10:00:00	11:00:00	25	163	47
823	Jueves	09:00:00	10:00:00	25	162	47
824	Jueves	11:00:00	12:00:00	25	161	47
825	Jueves	16:00:00	17:00:00	25	166	47
826	Jueves	12:00:00	13:00:00	25	164	47
827	Jueves	13:00:00	14:00:00	25	164	47
828	Jueves	17:00:00	18:00:00	25	160	65
829	Jueves	08:00:00	09:00:00	25	165	129
830	Viernes	08:00:00	09:00:00	25	165	129
831	Viernes	17:00:00	18:00:00	25	160	65
832	Viernes	10:00:00	11:00:00	25	163	47
833	Viernes	12:00:00	13:00:00	25	161	47
834	Viernes	11:00:00	12:00:00	25	161	47
835	Viernes	13:00:00	14:00:00	25	164	47
836	Viernes	09:00:00	10:00:00	25	162	47
837	Lunes	09:00:00	10:00:00	26	167	44
838	Lunes	10:00:00	11:00:00	26	168	86
839	Lunes	12:00:00	13:00:00	26	169	46
840	Lunes	11:00:00	12:00:00	26	170	46
841	Lunes	13:00:00	14:00:00	26	171	46
842	Lunes	16:00:00	17:00:00	26	172	46
843	Lunes	17:00:00	18:00:00	26	172	46
844	Martes	12:00:00	13:00:00	26	170	46
845	Martes	10:00:00	11:00:00	26	168	86
846	Martes	09:00:00	10:00:00	26	167	44
847	Martes	17:00:00	18:00:00	26	171	46
848	Martes	11:00:00	12:00:00	26	170	46
849	Martes	16:00:00	17:00:00	26	173	128
850	Miércoles	12:00:00	13:00:00	26	169	46
851	Miércoles	09:00:00	10:00:00	26	167	44
852	Miércoles	17:00:00	18:00:00	26	172	46
853	Miércoles	11:00:00	12:00:00	26	170	46
854	Miércoles	13:00:00	14:00:00	26	171	46
855	Miércoles	10:00:00	11:00:00	26	168	86
856	Miércoles	16:00:00	17:00:00	26	173	128
857	Jueves	11:00:00	12:00:00	26	170	46
858	Jueves	13:00:00	14:00:00	26	171	46
859	Jueves	17:00:00	18:00:00	26	172	46
860	Jueves	16:00:00	17:00:00	26	173	128
861	Jueves	10:00:00	11:00:00	26	168	86
862	Jueves	09:00:00	10:00:00	26	167	44
863	Jueves	12:00:00	13:00:00	26	169	46
864	Viernes	12:00:00	13:00:00	26	169	46
865	Viernes	17:00:00	18:00:00	26	172	46
866	Viernes	16:00:00	17:00:00	26	173	128
867	Viernes	11:00:00	12:00:00	26	170	46
868	Viernes	13:00:00	14:00:00	26	171	46
869	Viernes	10:00:00	11:00:00	26	168	86
870	Viernes	09:00:00	10:00:00	26	167	44
871	Lunes	08:00:00	09:00:00	27	174	8
872	Lunes	09:00:00	10:00:00	27	175	132
873	Lunes	13:00:00	14:00:00	27	176	89
874	Lunes	17:00:00	18:00:00	27	177	137
875	Lunes	10:00:00	11:00:00	27	178	8
876	Lunes	11:00:00	12:00:00	27	179	8
877	Lunes	16:00:00	17:00:00	27	180	8
878	Martes	16:00:00	17:00:00	27	180	8
879	Martes	11:00:00	12:00:00	27	179	8
880	Martes	10:00:00	11:00:00	27	178	8
881	Martes	08:00:00	09:00:00	27	174	8
882	Martes	13:00:00	14:00:00	27	176	89
883	Martes	17:00:00	18:00:00	27	177	137
884	Martes	09:00:00	10:00:00	27	175	132
885	Miércoles	11:00:00	12:00:00	27	179	8
886	Miércoles	08:00:00	09:00:00	27	174	8
887	Miércoles	10:00:00	11:00:00	27	178	8
888	Miércoles	17:00:00	18:00:00	27	177	137
889	Miércoles	16:00:00	17:00:00	27	180	8
890	Miércoles	13:00:00	14:00:00	27	176	89
891	Miércoles	09:00:00	10:00:00	27	175	132
892	Jueves	17:00:00	18:00:00	27	177	137
893	Jueves	16:00:00	17:00:00	27	180	8
894	Jueves	10:00:00	11:00:00	27	178	8
895	Jueves	09:00:00	10:00:00	27	175	132
896	Jueves	13:00:00	14:00:00	27	176	89
897	Jueves	08:00:00	09:00:00	27	174	8
898	Jueves	11:00:00	12:00:00	27	179	8
899	Viernes	17:00:00	18:00:00	27	177	137
900	Viernes	09:00:00	10:00:00	27	175	132
901	Viernes	13:00:00	14:00:00	27	176	89
902	Viernes	16:00:00	17:00:00	27	180	8
903	Viernes	10:00:00	11:00:00	27	178	8
904	Viernes	08:00:00	09:00:00	27	174	8
905	Viernes	11:00:00	12:00:00	27	179	8
906	Lunes	09:00:00	10:00:00	28	181	14
907	Lunes	12:00:00	13:00:00	28	182	58
908	Lunes	16:00:00	17:00:00	28	183	122
909	Lunes	11:00:00	12:00:00	28	184	14
910	Lunes	08:00:00	09:00:00	28	185	14
911	Lunes	17:00:00	18:00:00	28	186	14
912	Lunes	13:00:00	14:00:00	28	187	88
913	Martes	13:00:00	14:00:00	28	187	88
914	Martes	17:00:00	18:00:00	28	186	14
915	Martes	08:00:00	09:00:00	28	185	14
916	Martes	09:00:00	10:00:00	28	181	14
917	Martes	16:00:00	17:00:00	28	183	122
918	Martes	11:00:00	12:00:00	28	184	14
919	Martes	12:00:00	13:00:00	28	182	58
920	Miércoles	17:00:00	18:00:00	28	186	14
921	Miércoles	09:00:00	10:00:00	28	181	14
922	Miércoles	08:00:00	09:00:00	28	185	14
923	Miércoles	11:00:00	12:00:00	28	184	14
924	Miércoles	13:00:00	14:00:00	28	187	88
925	Miércoles	16:00:00	17:00:00	28	183	122
926	Miércoles	12:00:00	13:00:00	28	182	58
927	Jueves	11:00:00	12:00:00	28	184	14
928	Jueves	13:00:00	14:00:00	28	187	88
929	Jueves	08:00:00	09:00:00	28	185	14
930	Jueves	12:00:00	13:00:00	28	182	58
931	Jueves	16:00:00	17:00:00	28	183	122
932	Jueves	09:00:00	10:00:00	28	181	14
933	Jueves	17:00:00	18:00:00	28	186	14
934	Viernes	11:00:00	12:00:00	28	184	14
935	Viernes	12:00:00	13:00:00	28	182	58
936	Viernes	16:00:00	17:00:00	28	183	122
937	Viernes	13:00:00	14:00:00	28	187	88
938	Viernes	08:00:00	09:00:00	28	185	14
939	Viernes	09:00:00	10:00:00	28	181	14
940	Viernes	17:00:00	18:00:00	28	186	14
941	Lunes	16:00:00	17:00:00	29	188	17
942	Lunes	09:00:00	10:00:00	29	189	132
943	Lunes	17:00:00	18:00:00	29	190	98
944	Lunes	08:00:00	09:00:00	29	191	137
945	Lunes	13:00:00	14:00:00	29	192	137
946	Lunes	12:00:00	13:00:00	29	193	17
947	Lunes	10:00:00	11:00:00	29	194	17
948	Martes	10:00:00	11:00:00	29	194	17
949	Martes	12:00:00	13:00:00	29	193	17
950	Martes	13:00:00	14:00:00	29	192	137
951	Martes	16:00:00	17:00:00	29	188	17
952	Martes	17:00:00	18:00:00	29	190	98
953	Martes	08:00:00	09:00:00	29	191	137
954	Martes	09:00:00	10:00:00	29	189	132
955	Miércoles	12:00:00	13:00:00	29	193	17
956	Miércoles	16:00:00	17:00:00	29	188	17
957	Miércoles	13:00:00	14:00:00	29	192	137
958	Miércoles	08:00:00	09:00:00	29	191	137
959	Miércoles	10:00:00	11:00:00	29	194	17
960	Miércoles	17:00:00	18:00:00	29	190	98
961	Miércoles	09:00:00	10:00:00	29	189	132
962	Jueves	08:00:00	09:00:00	29	191	137
963	Jueves	10:00:00	11:00:00	29	194	17
964	Jueves	13:00:00	14:00:00	29	192	137
965	Jueves	09:00:00	10:00:00	29	189	132
966	Jueves	17:00:00	18:00:00	29	190	98
967	Jueves	16:00:00	17:00:00	29	188	17
968	Jueves	12:00:00	13:00:00	29	193	17
969	Viernes	08:00:00	09:00:00	29	191	137
970	Viernes	09:00:00	10:00:00	29	189	132
971	Viernes	17:00:00	18:00:00	29	190	98
972	Viernes	10:00:00	11:00:00	29	194	17
973	Viernes	13:00:00	14:00:00	29	192	137
974	Viernes	16:00:00	17:00:00	29	188	17
975	Viernes	12:00:00	13:00:00	29	193	17
976	Lunes	17:00:00	18:00:00	30	195	16
977	Lunes	16:00:00	17:00:00	30	196	16
978	Lunes	10:00:00	11:00:00	30	197	16
979	Lunes	13:00:00	14:00:00	30	198	51
980	Lunes	11:00:00	12:00:00	30	199	16
981	Lunes	09:00:00	10:00:00	30	200	16
982	Lunes	12:00:00	13:00:00	30	201	16
983	Martes	09:00:00	10:00:00	30	200	16
984	Martes	16:00:00	17:00:00	30	196	16
985	Martes	13:00:00	14:00:00	30	198	51
986	Martes	12:00:00	13:00:00	30	201	16
987	Martes	10:00:00	11:00:00	30	197	16
988	Martes	11:00:00	12:00:00	30	199	16
989	Martes	17:00:00	18:00:00	30	195	16
990	Miércoles	11:00:00	12:00:00	30	197	16
991	Miércoles	10:00:00	11:00:00	30	200	16
992	Miércoles	16:00:00	17:00:00	30	199	16
993	Miércoles	13:00:00	14:00:00	30	198	51
994	Miércoles	09:00:00	10:00:00	30	200	16
995	Miércoles	12:00:00	13:00:00	30	201	16
996	Miércoles	17:00:00	18:00:00	30	195	16
997	Jueves	11:00:00	12:00:00	30	199	16
998	Jueves	13:00:00	14:00:00	30	198	51
999	Jueves	10:00:00	11:00:00	30	197	16
1000	Jueves	09:00:00	10:00:00	30	200	16
1001	Jueves	12:00:00	13:00:00	30	195	16
1002	Jueves	17:00:00	18:00:00	30	195	16
1003	Jueves	16:00:00	17:00:00	30	196	16
1004	Viernes	12:00:00	13:00:00	30	201	16
1005	Viernes	16:00:00	17:00:00	30	196	16
1006	Viernes	17:00:00	18:00:00	30	195	16
1007	Viernes	13:00:00	14:00:00	30	198	51
1008	Viernes	09:00:00	10:00:00	30	200	16
1009	Viernes	11:00:00	12:00:00	30	199	16
1010	Viernes	10:00:00	11:00:00	30	197	16
1011	Lunes	16:00:00	17:00:00	31	197	51
1012	Lunes	13:00:00	14:00:00	31	198	51
1013	Lunes	09:00:00	10:00:00	31	202	53
1014	Lunes	11:00:00	12:00:00	31	203	140
1015	Lunes	10:00:00	11:00:00	31	204	53
1016	Lunes	17:00:00	18:00:00	31	200	53
1017	Lunes	12:00:00	13:00:00	31	205	53
1018	Martes	10:00:00	11:00:00	31	206	53
1019	Martes	12:00:00	13:00:00	31	205	53
1020	Martes	13:00:00	14:00:00	31	198	51
1021	Martes	16:00:00	17:00:00	31	197	51
1022	Martes	17:00:00	18:00:00	31	200	53
1023	Martes	11:00:00	12:00:00	31	203	140
1024	Martes	09:00:00	10:00:00	31	202	53
1025	Miércoles	11:00:00	12:00:00	31	203	140
1026	Miércoles	12:00:00	13:00:00	31	206	53
1027	Miércoles	13:00:00	14:00:00	31	198	51
1028	Miércoles	10:00:00	11:00:00	31	204	53
1029	Miércoles	09:00:00	10:00:00	31	202	53
1030	Miércoles	16:00:00	17:00:00	31	200	53
1031	Miércoles	17:00:00	18:00:00	31	200	53
1032	Jueves	09:00:00	10:00:00	31	202	53
1033	Jueves	11:00:00	12:00:00	31	203	140
1034	Jueves	12:00:00	13:00:00	31	205	53
1035	Jueves	17:00:00	18:00:00	31	200	53
1036	Jueves	13:00:00	14:00:00	31	198	51
1037	Jueves	16:00:00	17:00:00	31	197	51
1038	Jueves	10:00:00	11:00:00	31	204	53
1039	Viernes	10:00:00	11:00:00	31	204	53
1040	Viernes	16:00:00	17:00:00	31	197	51
1041	Viernes	17:00:00	18:00:00	31	200	53
1042	Viernes	12:00:00	13:00:00	31	205	53
1043	Viernes	11:00:00	12:00:00	31	203	140
1044	Viernes	13:00:00	14:00:00	31	198	51
1045	Viernes	09:00:00	10:00:00	31	202	53
1046	Lunes	10:00:00	11:00:00	32	207	37
1047	Lunes	08:00:00	09:00:00	32	208	37
1048	Lunes	17:00:00	18:00:00	32	209	37
1049	Lunes	12:00:00	13:00:00	32	210	37
1050	Lunes	13:00:00	14:00:00	32	211	37
1051	Lunes	16:00:00	17:00:00	32	212	129
1052	Lunes	11:00:00	12:00:00	32	210	37
1053	Martes	08:00:00	09:00:00	32	208	37
1054	Martes	10:00:00	11:00:00	32	207	37
1055	Martes	13:00:00	14:00:00	32	211	37
1056	Martes	17:00:00	18:00:00	32	209	37
1057	Martes	11:00:00	12:00:00	32	210	37
1058	Martes	16:00:00	17:00:00	32	212	129
1059	Miércoles	16:00:00	17:00:00	32	212	129
1060	Miércoles	12:00:00	13:00:00	32	211	37
1061	Miércoles	10:00:00	11:00:00	32	207	37
1062	Miércoles	08:00:00	09:00:00	32	208	37
1063	Miércoles	11:00:00	12:00:00	32	210	37
1064	Miércoles	17:00:00	18:00:00	32	209	37
1065	Miércoles	13:00:00	14:00:00	32	211	37
1066	Jueves	17:00:00	18:00:00	32	209	37
1067	Jueves	13:00:00	14:00:00	32	211	37
1068	Jueves	08:00:00	09:00:00	32	208	37
1069	Jueves	09:00:00	10:00:00	32	208	37
1070	Jueves	16:00:00	17:00:00	32	212	129
1071	Jueves	11:00:00	12:00:00	32	210	37
1072	Viernes	11:00:00	12:00:00	32	210	37
1073	Viernes	10:00:00	11:00:00	32	207	37
1074	Viernes	16:00:00	17:00:00	32	212	129
1075	Viernes	13:00:00	14:00:00	32	211	37
1076	Viernes	08:00:00	09:00:00	32	208	37
1077	Viernes	17:00:00	18:00:00	32	209	37
1078	Lunes	13:00:00	14:00:00	33	210	50
1079	Lunes	11:00:00	12:00:00	33	208	50
1080	Lunes	08:00:00	09:00:00	33	209	43
1081	Lunes	16:00:00	17:00:00	33	207	44
1082	Lunes	10:00:00	11:00:00	33	211	46
1083	Lunes	17:00:00	18:00:00	33	213	122
1084	Martes	11:00:00	12:00:00	33	208	50
1085	Martes	09:00:00	10:00:00	33	211	46
1086	Martes	10:00:00	11:00:00	33	211	46
1087	Martes	16:00:00	17:00:00	33	209	44
1088	Martes	12:00:00	13:00:00	33	208	50
1089	Martes	13:00:00	14:00:00	33	210	50
1090	Martes	17:00:00	18:00:00	33	213	122
1091	Miércoles	13:00:00	14:00:00	33	210	50
1092	Miércoles	10:00:00	11:00:00	33	211	46
1093	Miércoles	16:00:00	17:00:00	33	207	44
1094	Miércoles	12:00:00	13:00:00	33	210	50
1095	Miércoles	17:00:00	18:00:00	33	213	122
1096	Miércoles	11:00:00	12:00:00	33	208	50
1097	Miércoles	08:00:00	09:00:00	33	209	43
1098	Jueves	17:00:00	18:00:00	33	213	122
1099	Jueves	11:00:00	12:00:00	33	208	50
1100	Jueves	16:00:00	17:00:00	33	207	44
1101	Jueves	08:00:00	09:00:00	33	209	43
1102	Jueves	13:00:00	14:00:00	33	210	50
1103	Jueves	10:00:00	11:00:00	33	211	46
1104	Viernes	13:00:00	14:00:00	33	210	50
1105	Viernes	16:00:00	17:00:00	33	207	44
1106	Viernes	10:00:00	11:00:00	33	211	46
1107	Viernes	08:00:00	09:00:00	33	209	43
1108	Viernes	11:00:00	12:00:00	33	208	50
1109	Viernes	17:00:00	18:00:00	33	213	122
1110	Lunes	09:00:00	10:00:00	34	214	105
1111	Lunes	16:00:00	17:00:00	34	215	97
1112	Lunes	08:00:00	09:00:00	34	216	125
1113	Lunes	13:00:00	14:00:00	34	217	106
1114	Lunes	11:00:00	12:00:00	34	218	101
1115	Lunes	10:00:00	11:00:00	34	219	43
1116	Martes	16:00:00	17:00:00	34	215	97
1117	Martes	09:00:00	10:00:00	34	214	105
1118	Martes	11:00:00	12:00:00	34	218	88
1119	Martes	08:00:00	09:00:00	34	216	125
1120	Martes	12:00:00	13:00:00	34	217	106
1121	Martes	13:00:00	14:00:00	34	217	106
1122	Martes	10:00:00	11:00:00	34	219	43
1123	Miércoles	08:00:00	09:00:00	34	216	125
1124	Miércoles	13:00:00	14:00:00	34	217	106
1125	Miércoles	16:00:00	17:00:00	34	215	97
1126	Miércoles	10:00:00	11:00:00	34	219	43
1127	Miércoles	17:00:00	18:00:00	34	215	97
1128	Miércoles	11:00:00	12:00:00	34	218	101
1129	Jueves	08:00:00	09:00:00	34	216	125
1130	Jueves	11:00:00	12:00:00	34	218	101
1131	Jueves	16:00:00	17:00:00	34	215	97
1132	Jueves	10:00:00	11:00:00	34	219	43
1133	Jueves	13:00:00	14:00:00	34	217	106
1134	Jueves	09:00:00	10:00:00	34	214	105
1135	Viernes	13:00:00	14:00:00	34	217	106
1136	Viernes	11:00:00	12:00:00	34	218	101
1137	Viernes	08:00:00	09:00:00	34	216	125
1138	Viernes	09:00:00	10:00:00	34	214	105
1139	Viernes	16:00:00	17:00:00	34	215	97
1140	Lunes	12:00:00	13:00:00	35	214	80
1141	Lunes	10:00:00	11:00:00	35	220	63
1142	Lunes	11:00:00	12:00:00	35	216	125
1143	Lunes	16:00:00	17:00:00	35	221	83
1144	Lunes	17:00:00	18:00:00	35	221	83
1145	Lunes	09:00:00	10:00:00	35	219	64
1146	Lunes	13:00:00	14:00:00	35	222	63
1147	Martes	11:00:00	12:00:00	35	216	125
1148	Martes	09:00:00	10:00:00	35	219	64
1149	Martes	12:00:00	13:00:00	35	214	80
1150	Martes	10:00:00	11:00:00	35	220	63
1151	Martes	13:00:00	14:00:00	35	222	63
1152	Martes	16:00:00	17:00:00	35	221	82
1153	Miércoles	12:00:00	13:00:00	35	214	79
1154	Miércoles	11:00:00	12:00:00	35	216	125
1155	Miércoles	13:00:00	14:00:00	35	222	63
1156	Miércoles	09:00:00	10:00:00	35	219	64
1157	Miércoles	16:00:00	17:00:00	35	221	82
1158	Miércoles	10:00:00	11:00:00	35	220	63
1159	Jueves	16:00:00	17:00:00	35	221	82
1160	Jueves	11:00:00	12:00:00	35	216	125
1161	Jueves	12:00:00	13:00:00	35	222	63
1162	Jueves	10:00:00	11:00:00	35	220	63
1163	Jueves	13:00:00	14:00:00	35	222	63
1164	Viernes	09:00:00	10:00:00	35	219	64
1165	Viernes	16:00:00	17:00:00	35	221	82
1166	Viernes	12:00:00	13:00:00	35	214	80
1167	Viernes	13:00:00	14:00:00	35	222	63
1168	Viernes	11:00:00	12:00:00	35	216	125
1169	Viernes	10:00:00	11:00:00	35	220	63
1170	Lunes	16:00:00	17:00:00	36	223	125
1171	Lunes	17:00:00	18:00:00	36	224	43
1172	Lunes	12:00:00	13:00:00	36	225	43
1173	Lunes	09:00:00	10:00:00	36	226	42
1174	Lunes	08:00:00	09:00:00	36	226	42
1175	Lunes	13:00:00	14:00:00	36	227	133
1176	Lunes	10:00:00	11:00:00	36	228	42
1177	Martes	10:00:00	11:00:00	36	228	42
1178	Martes	17:00:00	18:00:00	36	224	43
1179	Martes	13:00:00	14:00:00	36	227	133
1180	Martes	12:00:00	13:00:00	36	225	43
1181	Martes	16:00:00	17:00:00	36	223	125
1182	Martes	09:00:00	10:00:00	36	229	42
1183	Martes	08:00:00	09:00:00	36	226	42
1184	Miércoles	10:00:00	11:00:00	36	229	42
1185	Miércoles	16:00:00	17:00:00	36	228	43
1186	Miércoles	13:00:00	14:00:00	36	223	133
1187	Miércoles	17:00:00	18:00:00	36	228	43
1188	Miércoles	12:00:00	13:00:00	36	225	43
1189	Miércoles	09:00:00	10:00:00	36	229	42
1190	Miércoles	08:00:00	09:00:00	36	226	42
1191	Jueves	16:00:00	17:00:00	36	223	125
1192	Jueves	09:00:00	10:00:00	36	229	42
1193	Jueves	13:00:00	14:00:00	36	227	133
1194	Jueves	12:00:00	13:00:00	36	225	43
1195	Jueves	10:00:00	11:00:00	36	228	42
1196	Jueves	08:00:00	09:00:00	36	226	42
1197	Jueves	17:00:00	18:00:00	36	224	43
1198	Viernes	12:00:00	13:00:00	36	225	43
1199	Viernes	17:00:00	18:00:00	36	224	43
1200	Viernes	08:00:00	09:00:00	36	226	42
1201	Viernes	13:00:00	14:00:00	36	227	133
1202	Viernes	09:00:00	10:00:00	36	229	42
1203	Viernes	10:00:00	11:00:00	36	228	42
1204	Viernes	16:00:00	17:00:00	36	223	125
1205	Lunes	11:00:00	12:00:00	37	230	33
1206	Lunes	12:00:00	13:00:00	37	231	31
1207	Lunes	08:00:00	09:00:00	37	232	33
1208	Lunes	10:00:00	11:00:00	37	233	93
1209	Lunes	09:00:00	10:00:00	37	234	36
1210	Lunes	17:00:00	18:00:00	37	235	33
1211	Lunes	16:00:00	17:00:00	37	236	31
1212	Martes	12:00:00	13:00:00	37	231	31
1213	Martes	11:00:00	12:00:00	37	230	33
1214	Martes	17:00:00	18:00:00	37	235	33
1215	Martes	08:00:00	09:00:00	37	232	33
1216	Martes	09:00:00	10:00:00	37	234	36
1217	Martes	10:00:00	11:00:00	37	233	93
1218	Martes	16:00:00	17:00:00	37	236	31
1219	Miércoles	10:00:00	11:00:00	37	233	93
1220	Miércoles	16:00:00	17:00:00	37	236	31
1221	Miércoles	09:00:00	10:00:00	37	234	36
1222	Miércoles	17:00:00	18:00:00	37	235	33
1223	Miércoles	12:00:00	13:00:00	37	231	31
1224	Miércoles	08:00:00	09:00:00	37	232	33
1225	Miércoles	11:00:00	12:00:00	37	230	33
1226	Jueves	09:00:00	10:00:00	37	234	36
1227	Jueves	16:00:00	17:00:00	37	235	141
1228	Jueves	12:00:00	13:00:00	37	231	31
1229	Jueves	08:00:00	09:00:00	37	232	33
1230	Jueves	11:00:00	12:00:00	37	230	33
1231	Jueves	10:00:00	11:00:00	37	233	93
1232	Jueves	17:00:00	18:00:00	37	235	141
1233	Viernes	11:00:00	12:00:00	37	230	33
1234	Viernes	12:00:00	13:00:00	37	231	31
1235	Viernes	10:00:00	11:00:00	37	233	93
1236	Viernes	17:00:00	18:00:00	37	235	33
1237	Viernes	09:00:00	10:00:00	37	234	36
1238	Viernes	08:00:00	09:00:00	37	232	33
1239	Viernes	16:00:00	17:00:00	37	236	31
1240	Lunes	11:00:00	12:00:00	38	230	33
1241	Lunes	08:00:00	09:00:00	38	232	33
1242	Lunes	13:00:00	14:00:00	38	237	31
1243	Lunes	10:00:00	11:00:00	38	233	93
1244	Lunes	09:00:00	10:00:00	38	231	31
1245	Lunes	17:00:00	18:00:00	38	235	33
1246	Lunes	16:00:00	17:00:00	38	236	31
1247	Martes	08:00:00	09:00:00	38	232	33
1248	Martes	11:00:00	12:00:00	38	230	33
1249	Martes	17:00:00	18:00:00	38	235	33
1250	Martes	13:00:00	14:00:00	38	237	31
1251	Martes	09:00:00	10:00:00	38	231	31
1252	Martes	10:00:00	11:00:00	38	233	93
1253	Martes	16:00:00	17:00:00	38	236	31
1254	Miércoles	10:00:00	11:00:00	38	233	93
1255	Miércoles	16:00:00	17:00:00	38	236	31
1256	Miércoles	09:00:00	10:00:00	38	231	31
1257	Miércoles	17:00:00	18:00:00	38	235	33
1258	Miércoles	08:00:00	09:00:00	38	232	33
1259	Miércoles	13:00:00	14:00:00	38	237	31
1260	Miércoles	11:00:00	12:00:00	38	230	33
1261	Jueves	09:00:00	10:00:00	38	231	31
1262	Jueves	16:00:00	17:00:00	38	235	141
1263	Jueves	08:00:00	09:00:00	38	232	33
1264	Jueves	13:00:00	14:00:00	38	237	31
1265	Jueves	11:00:00	12:00:00	38	230	33
1266	Jueves	10:00:00	11:00:00	38	233	93
1267	Jueves	17:00:00	18:00:00	38	235	141
1268	Viernes	11:00:00	12:00:00	38	230	33
1269	Viernes	08:00:00	09:00:00	38	232	33
1270	Viernes	10:00:00	11:00:00	38	233	93
1271	Viernes	17:00:00	18:00:00	38	235	33
1272	Viernes	09:00:00	10:00:00	38	231	31
1273	Viernes	13:00:00	14:00:00	38	237	31
1274	Viernes	16:00:00	17:00:00	38	236	31
1275	Lunes	12:00:00	13:00:00	39	238	83
1276	Lunes	16:00:00	17:00:00	39	239	112
1277	Lunes	13:00:00	14:00:00	39	240	104
1278	Lunes	11:00:00	12:00:00	39	241	105
1279	Lunes	08:00:00	09:00:00	39	242	135
1280	Lunes	10:00:00	11:00:00	39	243	104
1281	Martes	16:00:00	17:00:00	39	239	112
1282	Martes	13:00:00	14:00:00	39	240	104
1283	Martes	11:00:00	12:00:00	39	241	105
1284	Martes	08:00:00	09:00:00	39	242	135
1285	Martes	12:00:00	13:00:00	39	238	83
1286	Martes	10:00:00	11:00:00	39	243	104
1287	Miércoles	11:00:00	12:00:00	39	241	105
1288	Miércoles	10:00:00	11:00:00	39	243	104
1289	Miércoles	16:00:00	17:00:00	39	239	112
1290	Miércoles	08:00:00	09:00:00	39	242	135
1291	Miércoles	13:00:00	14:00:00	39	240	104
1292	Miércoles	12:00:00	13:00:00	39	238	83
1293	Jueves	12:00:00	13:00:00	39	238	83
1294	Jueves	13:00:00	14:00:00	39	240	104
1295	Jueves	10:00:00	11:00:00	39	243	104
1296	Jueves	11:00:00	12:00:00	39	241	105
1297	Jueves	08:00:00	09:00:00	39	242	135
1298	Jueves	16:00:00	17:00:00	39	239	112
1299	Jueves	17:00:00	18:00:00	39	239	112
1300	Viernes	08:00:00	09:00:00	39	242	135
1301	Viernes	11:00:00	12:00:00	39	243	105
1302	Viernes	17:00:00	18:00:00	39	241	64
1303	Viernes	16:00:00	17:00:00	39	239	112
1304	Viernes	12:00:00	13:00:00	39	238	83
1305	Viernes	10:00:00	11:00:00	39	243	105
1306	Viernes	13:00:00	14:00:00	39	240	104
1307	Lunes	12:00:00	13:00:00	40	244	78
1308	Lunes	08:00:00	09:00:00	40	243	78
1309	Lunes	17:00:00	18:00:00	40	245	134
1310	Lunes	10:00:00	11:00:00	40	246	78
1311	Lunes	11:00:00	12:00:00	40	238	78
1312	Lunes	16:00:00	17:00:00	40	247	78
1313	Martes	08:00:00	09:00:00	40	243	78
1314	Martes	11:00:00	12:00:00	40	238	78
1315	Martes	16:00:00	17:00:00	40	247	78
1316	Martes	17:00:00	18:00:00	40	245	134
1317	Martes	09:00:00	10:00:00	40	243	78
1318	Martes	10:00:00	11:00:00	40	246	78
1319	Martes	12:00:00	13:00:00	40	244	78
1320	Miércoles	17:00:00	18:00:00	40	245	134
1321	Miércoles	10:00:00	11:00:00	40	246	78
1322	Miércoles	16:00:00	17:00:00	40	247	78
1323	Miércoles	11:00:00	12:00:00	40	238	78
1324	Miércoles	12:00:00	13:00:00	40	244	78
1325	Miércoles	08:00:00	09:00:00	40	243	78
1326	Jueves	12:00:00	13:00:00	40	244	78
1327	Jueves	08:00:00	09:00:00	40	243	78
1328	Jueves	11:00:00	12:00:00	40	238	78
1329	Jueves	17:00:00	18:00:00	40	245	134
1330	Jueves	09:00:00	10:00:00	40	246	78
1331	Jueves	10:00:00	11:00:00	40	246	78
1332	Jueves	16:00:00	17:00:00	40	247	78
1333	Viernes	10:00:00	11:00:00	40	246	78
1334	Viernes	11:00:00	12:00:00	40	238	78
1335	Viernes	16:00:00	17:00:00	40	247	78
1336	Viernes	08:00:00	09:00:00	40	243	78
1337	Viernes	17:00:00	18:00:00	40	245	134
1338	Viernes	12:00:00	13:00:00	40	244	78
1339	Lunes	10:00:00	11:00:00	41	238	79
1340	Lunes	11:00:00	12:00:00	41	239	97
1341	Lunes	17:00:00	18:00:00	41	240	89
1342	Lunes	09:00:00	10:00:00	41	245	134
1343	Lunes	13:00:00	14:00:00	41	243	79
1344	Lunes	08:00:00	09:00:00	41	244	79
1345	Martes	11:00:00	12:00:00	41	239	79
1346	Martes	12:00:00	13:00:00	41	239	79
1347	Martes	13:00:00	14:00:00	41	243	79
1348	Martes	08:00:00	09:00:00	41	244	79
1349	Martes	17:00:00	18:00:00	41	240	89
1350	Martes	10:00:00	11:00:00	41	238	79
1351	Martes	09:00:00	10:00:00	41	245	134
1352	Miércoles	13:00:00	14:00:00	41	243	79
1353	Miércoles	17:00:00	18:00:00	41	240	89
1354	Miércoles	11:00:00	12:00:00	41	239	97
1355	Miércoles	10:00:00	11:00:00	41	238	79
1356	Miércoles	09:00:00	10:00:00	41	245	134
1357	Miércoles	08:00:00	09:00:00	41	244	79
1358	Jueves	09:00:00	10:00:00	41	245	134
1359	Jueves	11:00:00	12:00:00	41	239	97
1360	Jueves	17:00:00	18:00:00	41	240	89
1361	Jueves	08:00:00	09:00:00	41	244	79
1362	Jueves	12:00:00	13:00:00	41	243	79
1363	Jueves	13:00:00	14:00:00	41	243	79
1364	Jueves	10:00:00	11:00:00	41	238	79
1365	Viernes	13:00:00	14:00:00	41	243	79
1366	Viernes	17:00:00	18:00:00	41	240	89
1367	Viernes	11:00:00	12:00:00	41	239	97
1368	Viernes	09:00:00	10:00:00	41	245	134
1369	Viernes	08:00:00	09:00:00	41	244	79
1370	Viernes	10:00:00	11:00:00	41	238	79
1371	Lunes	17:00:00	18:00:00	42	238	109
1372	Lunes	11:00:00	12:00:00	42	248	109
1373	Lunes	09:00:00	10:00:00	42	249	109
1374	Lunes	16:00:00	17:00:00	42	245	134
1375	Lunes	13:00:00	14:00:00	42	250	109
1376	Lunes	10:00:00	11:00:00	42	251	109
1377	Martes	11:00:00	12:00:00	42	248	109
1378	Martes	10:00:00	11:00:00	42	250	109
1379	Martes	13:00:00	14:00:00	42	250	109
1380	Martes	17:00:00	18:00:00	42	251	109
1381	Martes	09:00:00	10:00:00	42	249	109
1382	Martes	16:00:00	17:00:00	42	238	113
1383	Martes	12:00:00	13:00:00	42	245	124
1384	Miércoles	13:00:00	14:00:00	42	250	109
1385	Miércoles	17:00:00	18:00:00	42	238	109
1386	Miércoles	09:00:00	10:00:00	42	249	109
1387	Miércoles	11:00:00	12:00:00	42	248	109
1388	Miércoles	16:00:00	17:00:00	42	245	134
1389	Miércoles	10:00:00	11:00:00	42	251	109
1390	Jueves	16:00:00	17:00:00	42	245	134
1391	Jueves	11:00:00	12:00:00	42	248	109
1392	Jueves	12:00:00	13:00:00	42	248	109
1393	Jueves	09:00:00	10:00:00	42	249	109
1394	Jueves	10:00:00	11:00:00	42	251	109
1395	Jueves	13:00:00	14:00:00	42	250	109
1396	Jueves	17:00:00	18:00:00	42	238	109
1397	Viernes	13:00:00	14:00:00	42	250	109
1398	Viernes	09:00:00	10:00:00	42	249	109
1399	Viernes	11:00:00	12:00:00	42	248	109
1400	Viernes	10:00:00	11:00:00	42	251	109
1401	Viernes	16:00:00	17:00:00	42	245	134
1402	Viernes	17:00:00	18:00:00	42	238	109
1403	Lunes	16:00:00	17:00:00	43	252	81
1404	Lunes	09:00:00	10:00:00	43	248	81
1405	Lunes	12:00:00	13:00:00	43	253	68
1406	Lunes	13:00:00	14:00:00	43	254	124
1407	Lunes	11:00:00	12:00:00	43	255	81
1408	Lunes	17:00:00	18:00:00	43	256	81
1409	Martes	09:00:00	10:00:00	43	248	81
1410	Martes	10:00:00	11:00:00	43	248	81
1411	Martes	11:00:00	12:00:00	43	255	81
1412	Martes	17:00:00	18:00:00	43	256	81
1413	Martes	12:00:00	13:00:00	43	253	68
1414	Martes	16:00:00	17:00:00	43	252	81
1415	Martes	13:00:00	14:00:00	43	254	124
1416	Miércoles	11:00:00	12:00:00	43	255	81
1417	Miércoles	12:00:00	13:00:00	43	253	68
1418	Miércoles	09:00:00	10:00:00	43	248	81
1419	Miércoles	16:00:00	17:00:00	43	252	81
1420	Miércoles	13:00:00	14:00:00	43	254	124
1421	Miércoles	17:00:00	18:00:00	43	256	81
1422	Jueves	13:00:00	14:00:00	43	254	124
1423	Jueves	09:00:00	10:00:00	43	248	81
1424	Jueves	12:00:00	13:00:00	43	253	68
1425	Jueves	17:00:00	18:00:00	43	256	81
1426	Jueves	10:00:00	11:00:00	43	255	81
1427	Jueves	11:00:00	12:00:00	43	255	81
1428	Jueves	16:00:00	17:00:00	43	252	81
1429	Viernes	11:00:00	12:00:00	43	255	81
1430	Viernes	12:00:00	13:00:00	43	253	68
1431	Viernes	09:00:00	10:00:00	43	248	81
1432	Viernes	13:00:00	14:00:00	43	254	124
1433	Viernes	17:00:00	18:00:00	43	256	81
1434	Viernes	16:00:00	17:00:00	43	252	81
1435	Lunes	17:00:00	18:00:00	44	252	82
1436	Lunes	11:00:00	12:00:00	44	257	82
1437	Lunes	13:00:00	14:00:00	44	253	82
1438	Lunes	08:00:00	09:00:00	44	258	133
1439	Lunes	09:00:00	10:00:00	44	255	82
1440	Lunes	12:00:00	13:00:00	44	256	82
1441	Martes	11:00:00	12:00:00	44	257	82
1442	Martes	09:00:00	10:00:00	44	255	82
1443	Martes	12:00:00	13:00:00	44	256	82
1444	Martes	13:00:00	14:00:00	44	253	82
1445	Martes	17:00:00	18:00:00	44	252	82
1446	Martes	08:00:00	09:00:00	44	258	133
1447	Miércoles	12:00:00	13:00:00	44	256	82
1448	Miércoles	13:00:00	14:00:00	44	253	82
1449	Miércoles	10:00:00	11:00:00	44	255	82
1450	Miércoles	17:00:00	18:00:00	44	252	82
1451	Miércoles	11:00:00	12:00:00	44	257	82
1452	Miércoles	09:00:00	10:00:00	44	255	82
1453	Miércoles	08:00:00	09:00:00	44	258	133
1454	Jueves	08:00:00	09:00:00	44	258	133
1455	Jueves	10:00:00	11:00:00	44	257	82
1456	Jueves	11:00:00	12:00:00	44	257	82
1457	Jueves	13:00:00	14:00:00	44	253	82
1458	Jueves	12:00:00	13:00:00	44	256	82
1459	Jueves	09:00:00	10:00:00	44	255	82
1460	Jueves	17:00:00	18:00:00	44	252	82
1461	Viernes	09:00:00	10:00:00	44	255	82
1462	Viernes	13:00:00	14:00:00	44	253	82
1463	Viernes	11:00:00	12:00:00	44	257	82
1464	Viernes	12:00:00	13:00:00	44	256	82
1465	Viernes	08:00:00	09:00:00	44	258	133
1466	Viernes	17:00:00	18:00:00	44	252	82
1467	Lunes	08:00:00	09:00:00	45	259	83
1468	Lunes	09:00:00	10:00:00	45	257	83
1469	Lunes	13:00:00	14:00:00	45	260	83
1470	Lunes	12:00:00	13:00:00	45	261	123
1471	Lunes	16:00:00	17:00:00	45	262	82
1472	Lunes	11:00:00	12:00:00	45	263	83
1473	Martes	09:00:00	10:00:00	45	257	83
1474	Martes	16:00:00	17:00:00	45	262	83
1475	Martes	11:00:00	12:00:00	45	263	83
1476	Martes	13:00:00	14:00:00	45	260	83
1477	Martes	08:00:00	09:00:00	45	259	83
1478	Martes	12:00:00	13:00:00	45	261	123
1479	Miércoles	11:00:00	12:00:00	45	263	83
1480	Miércoles	13:00:00	14:00:00	45	260	83
1481	Miércoles	16:00:00	17:00:00	45	262	83
1482	Miércoles	09:00:00	10:00:00	45	257	83
1483	Miércoles	10:00:00	11:00:00	45	257	83
1484	Miércoles	08:00:00	09:00:00	45	259	83
1485	Miércoles	12:00:00	13:00:00	45	261	123
1486	Jueves	12:00:00	13:00:00	45	261	123
1487	Jueves	09:00:00	10:00:00	45	257	83
1488	Jueves	13:00:00	14:00:00	45	260	83
1489	Jueves	11:00:00	12:00:00	45	263	83
1490	Jueves	16:00:00	17:00:00	45	262	83
1491	Jueves	17:00:00	18:00:00	45	262	83
1492	Jueves	08:00:00	09:00:00	45	259	83
1493	Viernes	16:00:00	17:00:00	45	262	83
1494	Viernes	13:00:00	14:00:00	45	260	83
1495	Viernes	09:00:00	10:00:00	45	257	83
1496	Viernes	12:00:00	13:00:00	45	261	123
1497	Viernes	11:00:00	12:00:00	45	263	83
1498	Viernes	08:00:00	09:00:00	45	259	83
1499	Lunes	09:00:00	10:00:00	46	259	108
1500	Lunes	16:00:00	17:00:00	46	257	108
1501	Lunes	08:00:00	09:00:00	46	264	108
1502	Lunes	11:00:00	12:00:00	46	261	123
1503	Lunes	12:00:00	13:00:00	46	262	112
1504	Lunes	10:00:00	11:00:00	46	263	108
1505	Martes	17:00:00	18:00:00	46	257	108
1506	Martes	12:00:00	13:00:00	46	262	112
1507	Martes	09:00:00	10:00:00	46	259	108
1508	Martes	10:00:00	11:00:00	46	263	108
1509	Martes	11:00:00	12:00:00	46	261	123
1510	Martes	08:00:00	09:00:00	46	264	108
1511	Martes	16:00:00	17:00:00	46	257	108
1512	Miércoles	08:00:00	09:00:00	46	264	108
1513	Miércoles	12:00:00	13:00:00	46	262	112
1514	Miércoles	09:00:00	10:00:00	46	259	108
1515	Miércoles	13:00:00	14:00:00	46	262	112
1516	Miércoles	16:00:00	17:00:00	46	257	108
1517	Miércoles	10:00:00	11:00:00	46	263	108
1518	Miércoles	11:00:00	12:00:00	46	261	123
1519	Jueves	11:00:00	12:00:00	46	261	123
1520	Jueves	16:00:00	17:00:00	46	257	108
1521	Jueves	08:00:00	09:00:00	46	264	108
1522	Jueves	10:00:00	11:00:00	46	263	108
1523	Jueves	12:00:00	13:00:00	46	262	112
1524	Jueves	09:00:00	10:00:00	46	259	108
1525	Viernes	12:00:00	13:00:00	46	262	112
1526	Viernes	08:00:00	09:00:00	46	264	108
1527	Viernes	16:00:00	17:00:00	46	257	108
1528	Viernes	10:00:00	11:00:00	46	263	108
1529	Viernes	11:00:00	12:00:00	46	261	123
1530	Viernes	09:00:00	10:00:00	46	259	108
1531	Lunes	17:00:00	18:00:00	47	259	80
1532	Lunes	13:00:00	14:00:00	47	248	80
1533	Lunes	16:00:00	17:00:00	47	264	109
1534	Lunes	10:00:00	11:00:00	47	261	123
1535	Lunes	08:00:00	09:00:00	47	262	80
1536	Lunes	11:00:00	12:00:00	47	265	80
1537	Martes	09:00:00	10:00:00	47	262	80
1538	Martes	08:00:00	09:00:00	47	262	80
1539	Martes	17:00:00	18:00:00	47	259	80
1540	Martes	11:00:00	12:00:00	47	265	80
1541	Martes	10:00:00	11:00:00	47	261	123
1542	Martes	16:00:00	17:00:00	47	264	109
1543	Martes	13:00:00	14:00:00	47	248	80
1544	Miércoles	16:00:00	17:00:00	47	264	109
1545	Miércoles	12:00:00	13:00:00	47	248	80
1546	Miércoles	17:00:00	18:00:00	47	259	80
1547	Miércoles	08:00:00	09:00:00	47	262	80
1548	Miércoles	13:00:00	14:00:00	47	248	80
1549	Miércoles	11:00:00	12:00:00	47	265	80
1550	Miércoles	10:00:00	11:00:00	47	261	123
1551	Jueves	10:00:00	11:00:00	47	261	123
1552	Jueves	13:00:00	14:00:00	47	248	80
1553	Jueves	16:00:00	17:00:00	47	264	109
1554	Jueves	11:00:00	12:00:00	47	265	80
1555	Jueves	08:00:00	09:00:00	47	262	80
1556	Jueves	17:00:00	18:00:00	47	259	80
1557	Viernes	08:00:00	09:00:00	47	262	80
1558	Viernes	16:00:00	17:00:00	47	264	109
1559	Viernes	13:00:00	14:00:00	47	248	80
1560	Viernes	11:00:00	12:00:00	47	265	80
1561	Viernes	10:00:00	11:00:00	47	261	123
1562	Viernes	17:00:00	18:00:00	47	259	80
1563	Lunes	16:00:00	17:00:00	48	246	64
1564	Lunes	13:00:00	14:00:00	48	266	123
1565	Lunes	10:00:00	11:00:00	48	241	64
1566	Lunes	08:00:00	09:00:00	48	267	64
1567	Lunes	12:00:00	13:00:00	48	259	64
1568	Lunes	11:00:00	12:00:00	48	249	64
1569	Martes	13:00:00	14:00:00	48	266	123
1570	Martes	12:00:00	13:00:00	48	259	64
1571	Martes	11:00:00	12:00:00	48	249	64
1572	Martes	10:00:00	11:00:00	48	241	64
1573	Martes	08:00:00	09:00:00	48	267	64
1574	Martes	16:00:00	17:00:00	48	246	64
1575	Martes	17:00:00	18:00:00	48	246	64
1576	Miércoles	10:00:00	11:00:00	48	241	64
1577	Miércoles	11:00:00	12:00:00	48	249	64
1578	Miércoles	13:00:00	14:00:00	48	266	123
1579	Miércoles	16:00:00	17:00:00	48	246	64
1580	Miércoles	08:00:00	09:00:00	48	267	64
1581	Miércoles	12:00:00	13:00:00	48	259	64
1582	Jueves	10:00:00	11:00:00	48	241	64
1583	Jueves	12:00:00	13:00:00	48	259	64
1584	Jueves	16:00:00	17:00:00	48	246	64
1585	Jueves	08:00:00	09:00:00	48	267	64
1586	Jueves	09:00:00	10:00:00	48	267	64
1587	Jueves	13:00:00	14:00:00	48	266	123
1588	Jueves	11:00:00	12:00:00	48	249	64
1589	Viernes	08:00:00	09:00:00	48	267	64
1590	Viernes	16:00:00	17:00:00	48	246	64
1591	Viernes	13:00:00	14:00:00	48	266	123
1592	Viernes	10:00:00	11:00:00	48	241	64
1593	Viernes	12:00:00	13:00:00	48	259	64
1594	Viernes	11:00:00	12:00:00	48	249	64
1595	Lunes	08:00:00	09:00:00	49	268	60
1596	Lunes	16:00:00	17:00:00	49	269	111
1597	Lunes	17:00:00	18:00:00	49	270	121
1598	Lunes	09:00:00	10:00:00	49	271	111
1599	Lunes	13:00:00	14:00:00	49	272	134
1600	Lunes	12:00:00	13:00:00	49	273	111
1601	Lunes	11:00:00	12:00:00	49	274	111
1602	Martes	11:00:00	12:00:00	49	274	111
1603	Martes	12:00:00	13:00:00	49	273	111
1604	Martes	13:00:00	14:00:00	49	272	134
1605	Martes	08:00:00	09:00:00	49	268	60
1606	Martes	17:00:00	18:00:00	49	270	121
1607	Martes	09:00:00	10:00:00	49	271	111
1608	Martes	16:00:00	17:00:00	49	269	111
1609	Miércoles	12:00:00	13:00:00	49	273	111
1610	Miércoles	08:00:00	09:00:00	49	268	60
1611	Miércoles	13:00:00	14:00:00	49	272	134
1612	Miércoles	09:00:00	10:00:00	49	271	111
1613	Miércoles	11:00:00	12:00:00	49	274	111
1614	Miércoles	17:00:00	18:00:00	49	270	121
1615	Miércoles	16:00:00	17:00:00	49	269	111
1616	Jueves	09:00:00	10:00:00	49	271	111
1617	Jueves	11:00:00	12:00:00	49	274	111
1618	Jueves	13:00:00	14:00:00	49	272	134
1619	Jueves	16:00:00	17:00:00	49	269	111
1620	Jueves	17:00:00	18:00:00	49	270	121
1621	Jueves	08:00:00	09:00:00	49	268	60
1622	Jueves	12:00:00	13:00:00	49	273	111
1623	Viernes	09:00:00	10:00:00	49	271	111
1624	Viernes	16:00:00	17:00:00	49	269	111
1625	Viernes	17:00:00	18:00:00	49	270	121
1626	Viernes	11:00:00	12:00:00	49	274	111
1627	Viernes	13:00:00	14:00:00	49	272	134
1628	Viernes	08:00:00	09:00:00	49	268	60
1629	Viernes	12:00:00	13:00:00	49	273	111
1630	Lunes	08:00:00	09:00:00	50	275	61
1631	Lunes	13:00:00	14:00:00	50	269	113
1632	Lunes	10:00:00	11:00:00	50	270	121
1633	Lunes	17:00:00	18:00:00	50	276	111
1634	Lunes	11:00:00	12:00:00	50	272	134
1635	Lunes	09:00:00	10:00:00	50	277	107
1636	Lunes	16:00:00	17:00:00	50	278	85
1637	Martes	16:00:00	17:00:00	50	278	86
1638	Martes	09:00:00	10:00:00	50	277	107
1639	Martes	11:00:00	12:00:00	50	272	134
1640	Martes	08:00:00	09:00:00	50	275	61
1641	Martes	10:00:00	11:00:00	50	270	121
1642	Martes	17:00:00	18:00:00	50	276	111
1643	Martes	13:00:00	14:00:00	50	269	113
1644	Miércoles	09:00:00	10:00:00	50	277	107
1645	Miércoles	08:00:00	09:00:00	50	275	61
1646	Miércoles	11:00:00	12:00:00	50	272	134
1647	Miércoles	17:00:00	18:00:00	50	276	111
1648	Miércoles	16:00:00	17:00:00	50	278	86
1649	Miércoles	10:00:00	11:00:00	50	270	121
1650	Miércoles	13:00:00	14:00:00	50	269	113
1651	Jueves	17:00:00	18:00:00	50	276	111
1652	Jueves	11:00:00	12:00:00	50	272	134
1653	Jueves	13:00:00	14:00:00	50	269	113
1654	Jueves	10:00:00	11:00:00	50	270	121
1655	Jueves	08:00:00	09:00:00	50	275	61
1656	Jueves	09:00:00	10:00:00	50	277	107
1657	Viernes	17:00:00	18:00:00	50	276	111
1658	Viernes	10:00:00	11:00:00	50	270	121
1659	Viernes	13:00:00	14:00:00	50	269	113
1660	Viernes	16:00:00	17:00:00	50	278	86
1661	Viernes	11:00:00	12:00:00	50	272	134
1662	Viernes	08:00:00	09:00:00	50	275	61
1663	Viernes	09:00:00	10:00:00	50	277	107
1664	Lunes	11:00:00	12:00:00	51	279	62
1665	Lunes	10:00:00	11:00:00	51	270	121
1666	Lunes	17:00:00	18:00:00	51	280	62
1667	Lunes	16:00:00	17:00:00	51	281	135
1668	Lunes	12:00:00	13:00:00	51	282	62
1669	Lunes	09:00:00	10:00:00	51	283	62
1670	Lunes	13:00:00	14:00:00	51	277	62
1671	Martes	13:00:00	14:00:00	51	277	62
1672	Martes	09:00:00	10:00:00	51	283	62
1673	Martes	12:00:00	13:00:00	51	282	62
1674	Martes	11:00:00	12:00:00	51	279	62
1675	Martes	17:00:00	18:00:00	51	280	62
1676	Martes	16:00:00	17:00:00	51	281	135
1677	Martes	10:00:00	11:00:00	51	270	121
1678	Miércoles	09:00:00	10:00:00	51	283	62
1679	Miércoles	11:00:00	12:00:00	51	279	62
1680	Miércoles	12:00:00	13:00:00	51	282	62
1681	Miércoles	16:00:00	17:00:00	51	281	135
1682	Miércoles	13:00:00	14:00:00	51	277	62
1683	Miércoles	17:00:00	18:00:00	51	280	62
1684	Miércoles	10:00:00	11:00:00	51	270	121
1685	Jueves	16:00:00	17:00:00	51	281	135
1686	Jueves	13:00:00	14:00:00	51	277	62
1687	Jueves	12:00:00	13:00:00	51	282	62
1688	Jueves	10:00:00	11:00:00	51	270	121
1689	Jueves	17:00:00	18:00:00	51	280	62
1690	Jueves	11:00:00	12:00:00	51	279	62
1691	Jueves	09:00:00	10:00:00	51	283	62
1692	Viernes	16:00:00	17:00:00	51	281	135
1693	Viernes	10:00:00	11:00:00	51	270	121
1694	Viernes	17:00:00	18:00:00	51	280	62
1695	Viernes	13:00:00	14:00:00	51	277	62
1696	Viernes	12:00:00	13:00:00	51	282	62
1697	Viernes	11:00:00	12:00:00	51	279	62
1698	Viernes	09:00:00	10:00:00	51	283	62
1699	Lunes	09:00:00	10:00:00	52	279	79
1700	Lunes	17:00:00	18:00:00	52	270	121
1701	Lunes	11:00:00	12:00:00	52	273	112
1702	Lunes	16:00:00	17:00:00	52	284	124
1703	Lunes	10:00:00	11:00:00	52	285	95
1704	Lunes	13:00:00	14:00:00	52	283	100
1705	Lunes	12:00:00	13:00:00	52	278	102
1706	Martes	12:00:00	13:00:00	52	278	95
1707	Martes	13:00:00	14:00:00	52	283	100
1708	Martes	10:00:00	11:00:00	52	285	95
1709	Martes	09:00:00	10:00:00	52	279	79
1710	Martes	11:00:00	12:00:00	52	273	112
1711	Martes	16:00:00	17:00:00	52	284	124
1712	Martes	17:00:00	18:00:00	52	270	121
1713	Miércoles	13:00:00	14:00:00	52	283	100
1714	Miércoles	09:00:00	10:00:00	52	279	79
1715	Miércoles	10:00:00	11:00:00	52	285	95
1716	Miércoles	16:00:00	17:00:00	52	284	124
1717	Miércoles	12:00:00	13:00:00	52	278	102
1718	Miércoles	11:00:00	12:00:00	52	273	112
1719	Miércoles	17:00:00	18:00:00	52	270	121
1720	Jueves	16:00:00	17:00:00	52	284	124
1721	Jueves	12:00:00	13:00:00	52	278	102
1722	Jueves	10:00:00	11:00:00	52	285	95
1723	Jueves	17:00:00	18:00:00	52	270	121
1724	Jueves	11:00:00	12:00:00	52	273	112
1725	Jueves	09:00:00	10:00:00	52	279	79
1726	Jueves	13:00:00	14:00:00	52	283	100
1727	Viernes	16:00:00	17:00:00	52	284	124
1728	Viernes	17:00:00	18:00:00	52	270	121
1729	Viernes	11:00:00	12:00:00	52	273	112
1730	Viernes	12:00:00	13:00:00	52	278	102
1731	Viernes	10:00:00	11:00:00	52	285	95
1732	Viernes	09:00:00	10:00:00	52	279	79
1733	Viernes	13:00:00	14:00:00	52	283	100
1734	Lunes	12:00:00	13:00:00	53	286	66
1735	Lunes	13:00:00	14:00:00	53	286	66
1736	Lunes	10:00:00	11:00:00	53	287	86
1737	Lunes	09:00:00	10:00:00	53	288	65
1738	Lunes	17:00:00	18:00:00	53	289	129
1739	Lunes	16:00:00	17:00:00	53	290	65
1740	Lunes	08:00:00	09:00:00	53	291	65
1741	Martes	09:00:00	10:00:00	53	288	65
1742	Martes	17:00:00	18:00:00	53	289	129
1743	Martes	13:00:00	14:00:00	53	286	66
1744	Martes	11:00:00	12:00:00	53	292	74
1745	Martes	08:00:00	09:00:00	53	291	65
1746	Martes	10:00:00	11:00:00	53	287	86
1747	Martes	16:00:00	17:00:00	53	290	65
1748	Miércoles	13:00:00	14:00:00	53	286	66
1749	Miércoles	11:00:00	12:00:00	53	292	74
1750	Miércoles	10:00:00	11:00:00	53	287	86
1751	Miércoles	17:00:00	18:00:00	53	289	129
1752	Miércoles	08:00:00	09:00:00	53	291	65
1753	Miércoles	09:00:00	10:00:00	53	288	65
1754	Miércoles	16:00:00	17:00:00	53	290	65
1755	Jueves	17:00:00	18:00:00	53	289	129
1756	Jueves	08:00:00	09:00:00	53	291	65
1757	Jueves	10:00:00	11:00:00	53	287	86
1758	Jueves	16:00:00	17:00:00	53	290	65
1759	Jueves	09:00:00	10:00:00	53	288	65
1760	Jueves	11:00:00	12:00:00	53	292	74
1761	Jueves	13:00:00	14:00:00	53	286	66
1762	Viernes	17:00:00	18:00:00	53	289	129
1763	Viernes	16:00:00	17:00:00	53	290	65
1764	Viernes	09:00:00	10:00:00	53	288	65
1765	Viernes	08:00:00	09:00:00	53	291	65
1766	Viernes	10:00:00	11:00:00	53	287	86
1767	Viernes	11:00:00	12:00:00	53	292	74
1768	Viernes	13:00:00	14:00:00	53	286	66
1769	Lunes	08:00:00	09:00:00	54	286	66
1770	Lunes	12:00:00	13:00:00	54	293	67
1771	Lunes	16:00:00	17:00:00	54	294	133
1772	Lunes	10:00:00	11:00:00	54	295	50
1773	Lunes	11:00:00	12:00:00	54	296	66
1774	Lunes	09:00:00	10:00:00	54	290	66
1775	Lunes	17:00:00	18:00:00	54	292	66
1776	Martes	08:00:00	09:00:00	54	286	66
1777	Martes	12:00:00	13:00:00	54	293	67
1778	Martes	10:00:00	11:00:00	54	295	50
1779	Martes	17:00:00	18:00:00	54	292	66
1780	Martes	09:00:00	10:00:00	54	290	66
1781	Martes	16:00:00	17:00:00	54	294	133
1782	Martes	11:00:00	12:00:00	54	296	66
1783	Miércoles	16:00:00	17:00:00	54	294	133
1784	Miércoles	08:00:00	09:00:00	54	286	66
1785	Miércoles	11:00:00	12:00:00	54	296	66
1786	Miércoles	10:00:00	11:00:00	54	295	50
1787	Miércoles	12:00:00	13:00:00	54	293	67
1788	Miércoles	09:00:00	10:00:00	54	290	66
1789	Miércoles	17:00:00	18:00:00	54	292	66
1790	Jueves	11:00:00	12:00:00	54	296	66
1791	Jueves	10:00:00	11:00:00	54	295	50
1792	Jueves	16:00:00	17:00:00	54	294	133
1793	Jueves	08:00:00	09:00:00	54	286	66
1794	Jueves	09:00:00	10:00:00	54	286	66
1795	Jueves	12:00:00	13:00:00	54	293	67
1796	Jueves	17:00:00	18:00:00	54	290	66
1797	Viernes	09:00:00	10:00:00	54	290	66
1798	Viernes	12:00:00	13:00:00	54	293	67
1799	Viernes	16:00:00	17:00:00	54	294	133
1800	Viernes	10:00:00	11:00:00	54	295	50
1801	Viernes	17:00:00	18:00:00	54	292	66
1802	Viernes	08:00:00	09:00:00	54	286	66
1803	Viernes	11:00:00	12:00:00	54	296	66
1804	Lunes	16:00:00	17:00:00	55	296	67
1805	Lunes	11:00:00	12:00:00	55	286	49
1806	Lunes	12:00:00	13:00:00	55	289	129
1807	Lunes	09:00:00	10:00:00	55	291	67
1808	Lunes	17:00:00	18:00:00	55	290	67
1809	Lunes	10:00:00	11:00:00	55	297	65
1810	Lunes	13:00:00	14:00:00	55	292	67
1811	Martes	11:00:00	12:00:00	55	286	49
1812	Martes	09:00:00	10:00:00	55	291	67
1813	Martes	10:00:00	11:00:00	55	297	65
1814	Martes	17:00:00	18:00:00	55	290	67
1815	Martes	13:00:00	14:00:00	55	289	129
1816	Martes	16:00:00	17:00:00	55	296	67
1817	Martes	12:00:00	13:00:00	55	286	49
1818	Miércoles	13:00:00	14:00:00	55	292	67
1819	Miércoles	11:00:00	12:00:00	55	286	49
1820	Miércoles	16:00:00	17:00:00	55	296	67
1821	Miércoles	10:00:00	11:00:00	55	297	65
1822	Miércoles	09:00:00	10:00:00	55	291	67
1823	Miércoles	17:00:00	18:00:00	55	290	67
1824	Miércoles	12:00:00	13:00:00	55	289	129
1825	Jueves	16:00:00	17:00:00	55	296	67
1826	Jueves	13:00:00	14:00:00	55	292	67
1827	Jueves	10:00:00	11:00:00	55	297	65
1828	Jueves	17:00:00	18:00:00	55	289	133
1829	Jueves	11:00:00	12:00:00	55	286	49
1830	Jueves	09:00:00	10:00:00	55	291	67
1831	Jueves	12:00:00	13:00:00	55	290	66
1832	Viernes	17:00:00	18:00:00	55	290	67
1833	Viernes	09:00:00	10:00:00	55	291	67
1834	Viernes	12:00:00	13:00:00	55	289	129
1835	Viernes	10:00:00	11:00:00	55	297	65
1836	Viernes	13:00:00	14:00:00	55	292	67
1837	Viernes	11:00:00	12:00:00	55	286	49
1838	Viernes	16:00:00	17:00:00	55	296	67
1839	Lunes	10:00:00	11:00:00	56	286	49
1840	Lunes	12:00:00	13:00:00	56	298	99
1841	Lunes	16:00:00	17:00:00	56	299	49
1842	Lunes	11:00:00	12:00:00	56	289	129
1843	Lunes	12:00:00	13:00:00	56	300	81
1844	Lunes	13:00:00	14:00:00	56	290	42
1845	Lunes	17:00:00	18:00:00	56	301	49
1846	Lunes	08:00:00	09:00:00	56	292	49
1847	Martes	10:00:00	11:00:00	56	286	49
1848	Martes	08:00:00	09:00:00	56	292	49
1849	Martes	12:00:00	13:00:00	56	300	81
1850	Martes	12:00:00	13:00:00	56	298	99
1851	Martes	11:00:00	12:00:00	56	289	129
1852	Martes	17:00:00	18:00:00	56	301	49
1853	Martes	16:00:00	17:00:00	56	299	49
1854	Martes	13:00:00	14:00:00	56	290	42
1855	Miércoles	11:00:00	12:00:00	56	289	129
1856	Miércoles	12:00:00	13:00:00	56	300	81
1857	Miércoles	13:00:00	14:00:00	56	290	42
1858	Miércoles	17:00:00	18:00:00	56	301	49
1859	Miércoles	12:00:00	13:00:00	56	298	99
1860	Miércoles	09:00:00	10:00:00	56	286	49
1861	Miércoles	10:00:00	11:00:00	56	286	49
1862	Miércoles	16:00:00	17:00:00	56	299	49
1863	Jueves	17:00:00	18:00:00	56	301	49
1864	Jueves	11:00:00	12:00:00	56	289	129
1865	Jueves	12:00:00	13:00:00	56	300	81
1866	Jueves	10:00:00	11:00:00	56	286	49
1867	Jueves	13:00:00	14:00:00	56	290	42
1868	Jueves	16:00:00	17:00:00	56	299	49
1869	Jueves	08:00:00	09:00:00	56	292	49
1870	Jueves	12:00:00	13:00:00	56	298	99
1871	Viernes	12:00:00	13:00:00	56	300	81
1872	Viernes	12:00:00	13:00:00	56	298	99
1873	Viernes	16:00:00	17:00:00	56	299	49
1874	Viernes	11:00:00	12:00:00	56	289	129
1875	Viernes	10:00:00	11:00:00	56	286	49
1876	Viernes	17:00:00	18:00:00	56	301	49
1877	Viernes	08:00:00	09:00:00	56	292	49
1878	Viernes	13:00:00	14:00:00	56	290	42
1879	Lunes	17:00:00	18:00:00	57	302	28
1880	Lunes	10:00:00	11:00:00	57	303	28
1881	Lunes	12:00:00	13:00:00	57	304	97
1882	Lunes	12:00:00	13:00:00	57	305	81
1883	Lunes	13:00:00	14:00:00	57	306	139
1884	Lunes	08:00:00	09:00:00	57	307	28
1885	Lunes	16:00:00	17:00:00	57	308	28
1886	Lunes	11:00:00	12:00:00	57	309	28
1887	Martes	12:00:00	13:00:00	57	304	97
1888	Martes	08:00:00	09:00:00	57	307	28
1889	Martes	17:00:00	18:00:00	57	302	28
1890	Martes	12:00:00	13:00:00	57	305	81
1891	Martes	10:00:00	11:00:00	57	303	28
1892	Martes	11:00:00	12:00:00	57	309	28
1893	Martes	13:00:00	14:00:00	57	306	139
1894	Martes	16:00:00	17:00:00	57	308	28
1895	Miércoles	16:00:00	17:00:00	57	308	28
1896	Miércoles	11:00:00	12:00:00	57	309	28
1897	Miércoles	12:00:00	13:00:00	57	305	81
1898	Miércoles	08:00:00	09:00:00	57	307	28
1899	Miércoles	12:00:00	13:00:00	57	304	97
1900	Miércoles	10:00:00	11:00:00	57	303	28
1901	Miércoles	17:00:00	18:00:00	57	302	28
1902	Miércoles	13:00:00	14:00:00	57	306	139
1903	Jueves	10:00:00	11:00:00	57	303	28
1904	Jueves	12:00:00	13:00:00	57	304	97
1905	Jueves	12:00:00	13:00:00	57	305	81
1906	Jueves	13:00:00	14:00:00	57	306	139
1907	Jueves	08:00:00	09:00:00	57	307	28
1908	Jueves	11:00:00	12:00:00	57	309	28
1909	Jueves	17:00:00	18:00:00	57	302	28
1910	Jueves	16:00:00	17:00:00	57	308	28
1911	Viernes	12:00:00	13:00:00	57	305	81
1912	Viernes	11:00:00	12:00:00	57	309	28
1913	Viernes	12:00:00	13:00:00	57	304	97
1914	Viernes	16:00:00	17:00:00	57	308	28
1915	Viernes	17:00:00	18:00:00	57	302	28
1916	Viernes	08:00:00	09:00:00	57	307	28
1917	Viernes	10:00:00	11:00:00	57	303	28
1918	Viernes	13:00:00	14:00:00	57	306	139
1919	Lunes	11:00:00	12:00:00	58	302	98
1920	Lunes	13:00:00	14:00:00	58	310	98
1921	Lunes	12:00:00	13:00:00	58	311	98
1922	Lunes	12:00:00	13:00:00	58	305	81
1923	Lunes	17:00:00	18:00:00	58	306	139
1924	Lunes	09:00:00	10:00:00	58	307	98
1925	Lunes	10:00:00	11:00:00	58	308	98
1926	Lunes	16:00:00	17:00:00	58	309	98
1927	Martes	12:00:00	13:00:00	58	311	98
1928	Martes	09:00:00	10:00:00	58	307	98
1929	Martes	11:00:00	12:00:00	58	302	98
1930	Martes	12:00:00	13:00:00	58	305	81
1931	Martes	13:00:00	14:00:00	58	310	98
1932	Martes	16:00:00	17:00:00	58	309	98
1933	Martes	17:00:00	18:00:00	58	306	139
1934	Martes	10:00:00	11:00:00	58	308	98
1935	Miércoles	10:00:00	11:00:00	58	308	98
1936	Miércoles	16:00:00	17:00:00	58	309	98
1937	Miércoles	12:00:00	13:00:00	58	305	81
1938	Miércoles	09:00:00	10:00:00	58	307	98
1939	Miércoles	12:00:00	13:00:00	58	311	98
1940	Miércoles	13:00:00	14:00:00	58	310	98
1941	Miércoles	11:00:00	12:00:00	58	302	98
1942	Miércoles	17:00:00	18:00:00	58	306	139
1943	Jueves	13:00:00	14:00:00	58	310	98
1944	Jueves	12:00:00	13:00:00	58	311	98
1945	Jueves	12:00:00	13:00:00	58	305	81
1946	Jueves	17:00:00	18:00:00	58	306	139
1947	Jueves	09:00:00	10:00:00	58	307	98
1948	Jueves	16:00:00	17:00:00	58	309	98
1949	Jueves	11:00:00	12:00:00	58	302	98
1950	Jueves	10:00:00	11:00:00	58	308	98
1951	Viernes	12:00:00	13:00:00	58	305	81
1952	Viernes	16:00:00	17:00:00	58	309	98
1953	Viernes	12:00:00	13:00:00	58	311	98
1954	Viernes	10:00:00	11:00:00	58	308	98
1955	Viernes	11:00:00	12:00:00	58	302	98
1956	Viernes	09:00:00	10:00:00	58	307	98
1957	Viernes	13:00:00	14:00:00	58	310	98
1958	Viernes	17:00:00	18:00:00	58	306	139
1959	Lunes	11:00:00	12:00:00	59	312	99
1960	Lunes	17:00:00	18:00:00	59	313	99
1961	Lunes	13:00:00	14:00:00	59	308	99
1962	Lunes	12:00:00	13:00:00	59	305	81
1963	Lunes	08:00:00	09:00:00	59	314	99
1964	Lunes	16:00:00	17:00:00	59	306	139
1965	Lunes	10:00:00	11:00:00	59	315	99
1966	Martes	10:00:00	11:00:00	59	315	99
1967	Martes	16:00:00	17:00:00	59	306	139
1968	Martes	08:00:00	09:00:00	59	314	99
1969	Martes	11:00:00	12:00:00	59	312	99
1970	Martes	13:00:00	14:00:00	59	308	99
1971	Martes	12:00:00	13:00:00	59	305	81
1972	Martes	17:00:00	18:00:00	59	313	99
1973	Miércoles	16:00:00	17:00:00	59	306	139
1974	Miércoles	11:00:00	12:00:00	59	312	99
1975	Miércoles	08:00:00	09:00:00	59	314	99
1976	Miércoles	12:00:00	13:00:00	59	305	81
1977	Miércoles	10:00:00	11:00:00	59	315	99
1978	Miércoles	13:00:00	14:00:00	59	308	99
1979	Miércoles	17:00:00	18:00:00	59	313	99
1980	Jueves	12:00:00	13:00:00	59	305	81
1981	Jueves	10:00:00	11:00:00	59	315	99
1982	Jueves	08:00:00	09:00:00	59	314	99
1983	Jueves	17:00:00	18:00:00	59	313	99
1984	Jueves	13:00:00	14:00:00	59	308	99
1985	Jueves	11:00:00	12:00:00	59	312	99
1986	Jueves	16:00:00	17:00:00	59	306	139
1987	Viernes	12:00:00	13:00:00	59	305	81
1988	Viernes	17:00:00	18:00:00	59	313	99
1989	Viernes	13:00:00	14:00:00	59	308	99
1990	Viernes	10:00:00	11:00:00	59	315	99
1991	Viernes	08:00:00	09:00:00	59	314	99
1992	Viernes	11:00:00	12:00:00	59	312	99
1993	Viernes	16:00:00	17:00:00	59	306	139
1994	Lunes	09:00:00	10:00:00	60	316	38
1995	Lunes	08:00:00	09:00:00	60	316	38
1996	Lunes	12:00:00	13:00:00	60	317	109
1997	Lunes	13:00:00	14:00:00	60	318	78
1998	Lunes	16:00:00	17:00:00	60	319	80
1999	Lunes	17:00:00	18:00:00	60	320	96
2000	Lunes	11:00:00	12:00:00	60	321	88
2001	Martes	08:00:00	09:00:00	60	316	38
2002	Martes	16:00:00	17:00:00	60	319	80
2003	Martes	17:00:00	18:00:00	60	320	96
2004	Martes	12:00:00	13:00:00	60	317	108
2005	Martes	09:00:00	10:00:00	60	316	38
2006	Martes	13:00:00	14:00:00	60	318	78
2007	Martes	11:00:00	12:00:00	60	321	87
2008	Miércoles	16:00:00	17:00:00	60	319	80
2009	Miércoles	08:00:00	09:00:00	60	316	38
2010	Miércoles	17:00:00	18:00:00	60	320	96
2011	Miércoles	09:00:00	10:00:00	60	316	38
2012	Miércoles	12:00:00	13:00:00	60	317	108
2013	Miércoles	11:00:00	12:00:00	60	321	87
2014	Miércoles	13:00:00	14:00:00	60	318	78
2015	Jueves	08:00:00	09:00:00	60	316	38
2016	Jueves	12:00:00	13:00:00	60	317	108
2017	Jueves	13:00:00	14:00:00	60	318	78
2018	Jueves	09:00:00	10:00:00	60	316	38
2019	Jueves	17:00:00	18:00:00	60	320	96
2020	Jueves	16:00:00	17:00:00	60	319	80
2021	Jueves	11:00:00	12:00:00	60	321	87
2022	Viernes	09:00:00	10:00:00	60	316	38
2023	Viernes	16:00:00	17:00:00	60	319	80
2024	Viernes	08:00:00	09:00:00	60	316	38
2025	Viernes	12:00:00	13:00:00	60	317	108
2026	Viernes	13:00:00	14:00:00	60	318	78
2027	Viernes	17:00:00	18:00:00	60	320	96
2028	Viernes	11:00:00	12:00:00	60	321	87
2029	Lunes	13:00:00	14:00:00	61	317	87
2030	Lunes	17:00:00	18:00:00	61	322	38
2031	Lunes	16:00:00	17:00:00	61	322	38
2032	Lunes	12:00:00	13:00:00	61	323	96
2033	Lunes	10:00:00	11:00:00	61	320	94
2034	Lunes	09:00:00	10:00:00	61	319	104
2035	Lunes	11:00:00	12:00:00	61	318	96
2036	Martes	11:00:00	12:00:00	61	318	96
2037	Martes	13:00:00	14:00:00	61	317	87
2038	Martes	16:00:00	17:00:00	61	322	38
2039	Martes	10:00:00	11:00:00	61	320	94
2040	Martes	09:00:00	10:00:00	61	319	104
2041	Martes	12:00:00	13:00:00	61	323	96
2042	Martes	17:00:00	18:00:00	61	322	38
2043	Miércoles	13:00:00	14:00:00	61	317	87
2044	Miércoles	09:00:00	10:00:00	61	319	104
2045	Miércoles	10:00:00	11:00:00	61	320	94
2046	Miércoles	12:00:00	13:00:00	61	323	96
2047	Miércoles	11:00:00	12:00:00	61	318	96
2048	Miércoles	16:00:00	17:00:00	61	322	38
2049	Miércoles	17:00:00	18:00:00	61	322	38
2050	Jueves	12:00:00	13:00:00	61	323	96
2051	Jueves	17:00:00	18:00:00	61	322	38
2052	Jueves	11:00:00	12:00:00	61	318	96
2053	Jueves	10:00:00	11:00:00	61	320	94
2054	Jueves	09:00:00	10:00:00	61	319	104
2055	Jueves	16:00:00	17:00:00	61	322	38
2056	Jueves	13:00:00	14:00:00	61	317	87
2057	Viernes	12:00:00	13:00:00	61	323	96
2058	Viernes	16:00:00	17:00:00	61	322	38
2059	Viernes	17:00:00	18:00:00	61	322	38
2060	Viernes	11:00:00	12:00:00	61	318	96
2061	Viernes	10:00:00	11:00:00	61	320	94
2062	Viernes	13:00:00	14:00:00	61	317	87
2063	Viernes	09:00:00	10:00:00	61	319	104
2064	Lunes	11:00:00	12:00:00	62	317	94
2065	Lunes	17:00:00	18:00:00	62	322	38
2066	Lunes	16:00:00	17:00:00	62	322	38
2067	Lunes	13:00:00	14:00:00	62	323	85
2068	Lunes	12:00:00	13:00:00	62	320	90
2069	Lunes	08:00:00	09:00:00	62	319	81
2070	Lunes	10:00:00	11:00:00	62	318	83
2071	Martes	10:00:00	11:00:00	62	318	83
2072	Martes	11:00:00	12:00:00	62	317	94
2073	Martes	16:00:00	17:00:00	62	322	38
2074	Martes	12:00:00	13:00:00	62	320	90
2075	Martes	08:00:00	09:00:00	62	319	81
2076	Martes	13:00:00	14:00:00	62	323	85
2077	Martes	17:00:00	18:00:00	62	322	38
2078	Miércoles	11:00:00	12:00:00	62	317	94
2079	Miércoles	08:00:00	09:00:00	62	319	81
2080	Miércoles	12:00:00	13:00:00	62	320	90
2081	Miércoles	13:00:00	14:00:00	62	323	85
2082	Miércoles	10:00:00	11:00:00	62	318	81
2083	Miércoles	16:00:00	17:00:00	62	322	38
2084	Miércoles	17:00:00	18:00:00	62	322	38
2085	Jueves	13:00:00	14:00:00	62	323	85
2086	Jueves	17:00:00	18:00:00	62	322	38
2087	Jueves	10:00:00	11:00:00	62	318	83
2088	Jueves	12:00:00	13:00:00	62	320	90
2089	Jueves	08:00:00	09:00:00	62	319	81
2090	Jueves	16:00:00	17:00:00	62	322	38
2091	Jueves	11:00:00	12:00:00	62	317	94
2092	Viernes	13:00:00	14:00:00	62	323	85
2093	Viernes	16:00:00	17:00:00	62	322	38
2094	Viernes	17:00:00	18:00:00	62	322	38
2095	Viernes	10:00:00	11:00:00	62	318	83
2096	Viernes	12:00:00	13:00:00	62	320	90
2097	Viernes	11:00:00	12:00:00	62	317	94
2098	Viernes	08:00:00	09:00:00	62	319	81
2099	Lunes	08:00:00	09:00:00	63	324	100
2100	Lunes	16:00:00	17:00:00	63	325	100
2101	Lunes	12:00:00	13:00:00	63	326	100
2102	Lunes	10:00:00	11:00:00	63	327	100
2103	Lunes	17:00:00	18:00:00	63	328	130
2104	Lunes	09:00:00	10:00:00	63	329	100
2105	Martes	16:00:00	17:00:00	63	325	100
2106	Martes	12:00:00	13:00:00	63	326	100
2107	Martes	10:00:00	11:00:00	63	327	100
2108	Martes	17:00:00	18:00:00	63	328	130
2109	Martes	08:00:00	09:00:00	63	324	100
2110	Martes	09:00:00	10:00:00	63	329	100
2111	Miércoles	16:00:00	17:00:00	63	325	100
2112	Miércoles	10:00:00	11:00:00	63	329	100
2113	Miércoles	08:00:00	09:00:00	63	324	100
2114	Miércoles	17:00:00	18:00:00	63	328	130
2115	Miércoles	09:00:00	10:00:00	63	329	100
2116	Jueves	12:00:00	13:00:00	63	326	100
2117	Jueves	10:00:00	11:00:00	63	327	100
2118	Jueves	09:00:00	10:00:00	63	329	100
2119	Jueves	08:00:00	09:00:00	63	324	100
2120	Jueves	17:00:00	18:00:00	63	328	130
2121	Jueves	16:00:00	17:00:00	63	325	100
2122	Viernes	09:00:00	10:00:00	63	329	100
2123	Viernes	10:00:00	11:00:00	63	327	100
2124	Viernes	08:00:00	09:00:00	63	324	100
2125	Viernes	16:00:00	17:00:00	63	325	100
2126	Viernes	12:00:00	13:00:00	63	326	100
2127	Viernes	17:00:00	18:00:00	63	328	130
2128	Lunes	08:00:00	09:00:00	64	330	110
2129	Lunes	17:00:00	18:00:00	64	325	101
2130	Lunes	12:00:00	13:00:00	64	331	79
2131	Lunes	10:00:00	11:00:00	64	332	128
2132	Lunes	16:00:00	17:00:00	64	324	101
2133	Lunes	11:00:00	12:00:00	64	329	102
2134	Martes	17:00:00	18:00:00	64	325	101
2135	Martes	08:00:00	09:00:00	64	330	110
2136	Martes	16:00:00	17:00:00	64	324	101
2137	Martes	10:00:00	11:00:00	64	332	128
2138	Martes	11:00:00	12:00:00	64	329	102
2139	Martes	12:00:00	13:00:00	64	329	102
2140	Miércoles	12:00:00	13:00:00	64	331	95
2141	Miércoles	10:00:00	11:00:00	64	332	128
2142	Miércoles	11:00:00	12:00:00	64	329	102
2143	Miércoles	17:00:00	18:00:00	64	325	101
2144	Miércoles	16:00:00	17:00:00	64	324	101
2145	Jueves	12:00:00	13:00:00	64	331	95
2146	Jueves	16:00:00	17:00:00	64	324	101
2147	Jueves	17:00:00	18:00:00	64	325	101
2148	Jueves	10:00:00	11:00:00	64	332	128
2149	Jueves	08:00:00	09:00:00	64	330	110
2150	Jueves	11:00:00	12:00:00	64	329	102
2151	Viernes	17:00:00	18:00:00	64	325	101
2152	Viernes	12:00:00	13:00:00	64	331	79
2153	Viernes	11:00:00	12:00:00	64	329	102
2154	Viernes	08:00:00	09:00:00	64	330	110
2155	Viernes	16:00:00	17:00:00	64	324	101
2156	Viernes	10:00:00	11:00:00	64	332	128
2157	Lunes	12:00:00	13:00:00	65	330	105
2158	Lunes	13:00:00	14:00:00	65	325	102
2159	Lunes	17:00:00	18:00:00	65	333	102
2160	Lunes	08:00:00	09:00:00	65	328	130
2161	Lunes	10:00:00	11:00:00	65	334	102
2162	Lunes	09:00:00	10:00:00	65	335	102
2163	Martes	13:00:00	14:00:00	65	325	102
2164	Martes	12:00:00	13:00:00	65	330	105
2165	Martes	10:00:00	11:00:00	65	334	102
2166	Martes	17:00:00	18:00:00	65	333	102
2167	Martes	08:00:00	09:00:00	65	328	130
2168	Martes	09:00:00	10:00:00	65	335	102
2169	Miércoles	12:00:00	13:00:00	65	330	105
2170	Miércoles	10:00:00	11:00:00	65	334	102
2171	Miércoles	08:00:00	09:00:00	65	328	130
2172	Miércoles	13:00:00	14:00:00	65	325	102
2173	Miércoles	17:00:00	18:00:00	65	333	102
2174	Miércoles	09:00:00	10:00:00	65	335	102
2175	Jueves	17:00:00	18:00:00	65	333	102
2176	Jueves	13:00:00	14:00:00	65	325	102
2177	Jueves	10:00:00	11:00:00	65	335	102
2178	Jueves	08:00:00	09:00:00	65	328	130
2179	Jueves	09:00:00	10:00:00	65	335	102
2180	Viernes	12:00:00	13:00:00	65	330	105
2181	Viernes	09:00:00	10:00:00	65	335	102
2182	Viernes	13:00:00	14:00:00	65	325	102
2183	Viernes	17:00:00	18:00:00	65	333	102
2184	Viernes	10:00:00	11:00:00	65	334	102
2185	Viernes	08:00:00	09:00:00	65	328	130
2186	Lunes	11:00:00	12:00:00	66	325	103
2187	Lunes	17:00:00	18:00:00	66	334	103
2188	Lunes	08:00:00	09:00:00	66	336	103
2189	Lunes	16:00:00	17:00:00	66	337	131
2190	Lunes	12:00:00	13:00:00	66	338	103
2191	Lunes	09:00:00	10:00:00	66	336	103
2192	Martes	09:00:00	10:00:00	66	330	103
2193	Martes	12:00:00	13:00:00	66	338	103
2194	Martes	17:00:00	18:00:00	66	334	103
2195	Martes	11:00:00	12:00:00	66	325	103
2196	Martes	16:00:00	17:00:00	66	337	131
2197	Martes	08:00:00	09:00:00	66	336	103
2198	Miércoles	17:00:00	18:00:00	66	334	103
2199	Miércoles	12:00:00	13:00:00	66	338	103
2200	Miércoles	08:00:00	09:00:00	66	336	103
2201	Miércoles	11:00:00	12:00:00	66	325	103
2202	Miércoles	16:00:00	17:00:00	66	337	131
2203	Miércoles	09:00:00	10:00:00	66	330	103
2204	Jueves	17:00:00	18:00:00	66	334	103
2205	Jueves	16:00:00	17:00:00	66	337	131
2206	Jueves	12:00:00	13:00:00	66	338	103
2207	Jueves	11:00:00	12:00:00	66	325	103
2208	Jueves	08:00:00	09:00:00	66	336	103
2209	Jueves	09:00:00	10:00:00	66	330	103
2210	Viernes	11:00:00	12:00:00	66	325	103
2211	Viernes	08:00:00	09:00:00	66	336	103
2212	Viernes	16:00:00	17:00:00	66	337	131
2213	Viernes	12:00:00	13:00:00	66	338	103
2214	Viernes	09:00:00	10:00:00	66	330	103
2215	Lunes	11:00:00	12:00:00	67	330	104
2216	Lunes	09:00:00	10:00:00	67	339	113
2217	Lunes	17:00:00	18:00:00	67	340	104
2218	Lunes	16:00:00	17:00:00	67	334	104
2219	Lunes	13:00:00	14:00:00	67	341	135
2220	Lunes	12:00:00	13:00:00	67	336	104
2221	Martes	11:00:00	12:00:00	67	330	104
2222	Martes	13:00:00	14:00:00	67	341	135
2223	Martes	16:00:00	17:00:00	67	334	104
2224	Martes	09:00:00	10:00:00	67	339	113
2225	Martes	17:00:00	18:00:00	67	340	104
2226	Martes	12:00:00	13:00:00	67	336	104
2227	Miércoles	09:00:00	10:00:00	67	339	113
2228	Miércoles	12:00:00	13:00:00	67	336	104
2229	Miércoles	17:00:00	18:00:00	67	340	104
2230	Miércoles	13:00:00	14:00:00	67	341	135
2231	Miércoles	11:00:00	12:00:00	67	330	104
2232	Jueves	13:00:00	14:00:00	67	341	135
2233	Jueves	17:00:00	18:00:00	67	340	104
2234	Jueves	09:00:00	10:00:00	67	339	113
2235	Jueves	11:00:00	12:00:00	67	330	104
2236	Jueves	12:00:00	13:00:00	67	336	104
2237	Jueves	16:00:00	17:00:00	67	334	104
2238	Viernes	12:00:00	13:00:00	67	336	104
2239	Viernes	11:00:00	12:00:00	67	336	104
2240	Viernes	17:00:00	18:00:00	67	340	104
2241	Viernes	09:00:00	10:00:00	67	339	113
2242	Viernes	13:00:00	14:00:00	67	341	135
2243	Viernes	16:00:00	17:00:00	67	334	104
2244	Lunes	08:00:00	09:00:00	68	339	105
2245	Lunes	12:00:00	13:00:00	68	342	45
2246	Lunes	10:00:00	11:00:00	68	333	105
2247	Lunes	13:00:00	14:00:00	68	343	105
2248	Lunes	11:00:00	12:00:00	68	332	128
2249	Lunes	17:00:00	18:00:00	68	335	105
2250	Martes	12:00:00	13:00:00	68	342	45
2251	Martes	10:00:00	11:00:00	68	333	105
2252	Martes	11:00:00	12:00:00	68	332	128
2253	Martes	08:00:00	09:00:00	68	339	105
2254	Martes	17:00:00	18:00:00	68	335	105
2255	Miércoles	08:00:00	09:00:00	68	339	105
2256	Miércoles	13:00:00	14:00:00	68	343	105
2257	Miércoles	11:00:00	12:00:00	68	332	128
2258	Miércoles	17:00:00	18:00:00	68	335	105
2259	Miércoles	10:00:00	11:00:00	68	333	105
2260	Jueves	13:00:00	14:00:00	68	343	105
2261	Jueves	17:00:00	18:00:00	68	335	105
2262	Jueves	08:00:00	09:00:00	68	339	105
2263	Jueves	11:00:00	12:00:00	68	332	128
2264	Jueves	10:00:00	11:00:00	68	333	105
2265	Jueves	16:00:00	17:00:00	68	335	105
2266	Jueves	12:00:00	13:00:00	68	342	45
2267	Viernes	13:00:00	14:00:00	68	343	105
2268	Viernes	17:00:00	18:00:00	68	335	105
2269	Viernes	08:00:00	09:00:00	68	339	105
2270	Viernes	12:00:00	13:00:00	68	342	45
2271	Viernes	10:00:00	11:00:00	68	333	104
2272	Viernes	11:00:00	12:00:00	68	332	128
2273	Lunes	11:00:00	12:00:00	69	342	100
2274	Lunes	10:00:00	11:00:00	69	344	101
2275	Lunes	16:00:00	17:00:00	69	333	103
2276	Lunes	09:00:00	10:00:00	69	343	101
2277	Lunes	12:00:00	13:00:00	69	341	135
2278	Lunes	08:00:00	09:00:00	69	345	101
2279	Martes	11:00:00	12:00:00	69	342	100
2280	Martes	12:00:00	13:00:00	69	341	135
2281	Martes	09:00:00	10:00:00	69	343	101
2282	Martes	10:00:00	11:00:00	69	344	101
2283	Martes	16:00:00	17:00:00	69	333	103
2284	Martes	08:00:00	09:00:00	69	345	101
2285	Miércoles	10:00:00	11:00:00	69	344	101
2286	Miércoles	08:00:00	09:00:00	69	345	101
2287	Miércoles	16:00:00	17:00:00	69	333	103
2288	Miércoles	09:00:00	10:00:00	69	343	101
2289	Miércoles	12:00:00	13:00:00	69	341	135
2290	Miércoles	11:00:00	12:00:00	69	342	100
2291	Jueves	16:00:00	17:00:00	69	333	103
2292	Jueves	10:00:00	11:00:00	69	344	101
2293	Jueves	08:00:00	09:00:00	69	345	101
2294	Jueves	12:00:00	13:00:00	69	341	135
2295	Jueves	09:00:00	10:00:00	69	343	101
2296	Viernes	11:00:00	12:00:00	69	342	100
2297	Viernes	09:00:00	10:00:00	69	345	101
2298	Viernes	16:00:00	17:00:00	69	333	103
2299	Viernes	10:00:00	11:00:00	69	344	101
2300	Viernes	12:00:00	13:00:00	69	341	135
2301	Viernes	08:00:00	09:00:00	69	345	101
2302	Lunes	10:00:00	11:00:00	70	342	103
2303	Lunes	08:00:00	09:00:00	70	344	102
2304	Lunes	16:00:00	17:00:00	70	338	106
2305	Lunes	17:00:00	18:00:00	70	346	72
2306	Lunes	09:00:00	10:00:00	70	341	135
2307	Lunes	12:00:00	13:00:00	70	345	101
2308	Martes	09:00:00	10:00:00	70	341	135
2309	Martes	17:00:00	18:00:00	70	346	72
2310	Martes	11:00:00	12:00:00	70	345	101
2311	Martes	12:00:00	13:00:00	70	345	101
2312	Martes	16:00:00	17:00:00	70	338	106
2313	Martes	08:00:00	09:00:00	70	344	102
2314	Miércoles	08:00:00	09:00:00	70	344	102
2315	Miércoles	16:00:00	17:00:00	70	338	106
2316	Miércoles	12:00:00	13:00:00	70	345	101
2317	Miércoles	17:00:00	18:00:00	70	346	72
2318	Miércoles	09:00:00	10:00:00	70	341	135
2319	Miércoles	10:00:00	11:00:00	70	342	103
2320	Jueves	12:00:00	13:00:00	70	345	101
2321	Jueves	16:00:00	17:00:00	70	338	106
2322	Jueves	09:00:00	10:00:00	70	341	135
2323	Jueves	08:00:00	09:00:00	70	344	102
2324	Jueves	10:00:00	11:00:00	70	342	103
2325	Jueves	17:00:00	18:00:00	70	346	72
2326	Viernes	16:00:00	17:00:00	70	338	106
2327	Viernes	08:00:00	09:00:00	70	344	102
2328	Viernes	10:00:00	11:00:00	70	342	103
2329	Viernes	09:00:00	10:00:00	70	341	135
2330	Viernes	12:00:00	13:00:00	70	345	101
2331	Lunes	10:00:00	11:00:00	71	347	106
2332	Lunes	11:00:00	12:00:00	71	333	106
2333	Lunes	17:00:00	18:00:00	71	341	135
2334	Lunes	08:00:00	09:00:00	71	348	106
2335	Lunes	12:00:00	13:00:00	71	344	106
2336	Martes	16:00:00	17:00:00	71	342	46
2337	Martes	09:00:00	10:00:00	71	344	106
2338	Martes	11:00:00	12:00:00	71	333	106
2339	Martes	08:00:00	09:00:00	71	348	106
2340	Martes	17:00:00	18:00:00	71	341	135
2341	Martes	10:00:00	11:00:00	71	347	106
2342	Miércoles	09:00:00	10:00:00	71	347	106
2343	Miércoles	10:00:00	11:00:00	71	347	106
2344	Miércoles	17:00:00	18:00:00	71	341	135
2345	Miércoles	16:00:00	17:00:00	71	342	46
2346	Miércoles	12:00:00	13:00:00	71	344	106
2347	Miércoles	11:00:00	12:00:00	71	333	106
2348	Jueves	10:00:00	11:00:00	71	347	106
2349	Jueves	11:00:00	12:00:00	71	333	106
2350	Jueves	12:00:00	13:00:00	71	344	106
2351	Jueves	17:00:00	18:00:00	71	341	135
2352	Jueves	16:00:00	17:00:00	71	342	46
2353	Jueves	08:00:00	09:00:00	71	348	106
2354	Viernes	12:00:00	13:00:00	71	344	106
2355	Viernes	17:00:00	18:00:00	71	341	135
2356	Viernes	08:00:00	09:00:00	71	348	106
2357	Viernes	11:00:00	12:00:00	71	333	106
2358	Viernes	16:00:00	17:00:00	71	342	46
2359	Viernes	10:00:00	11:00:00	71	347	106
2360	Lunes	17:00:00	18:00:00	72	349	47
2361	Lunes	13:00:00	14:00:00	72	350	130
2362	Lunes	09:00:00	10:00:00	72	351	93
2363	Lunes	12:00:00	13:00:00	72	352	69
2364	Lunes	08:00:00	09:00:00	72	353	70
2365	Lunes	11:00:00	12:00:00	72	354	69
2366	Lunes	10:00:00	11:00:00	72	355	70
2367	Martes	13:00:00	14:00:00	72	350	130
2368	Martes	12:00:00	13:00:00	72	352	69
2369	Martes	09:00:00	10:00:00	72	351	93
2370	Martes	11:00:00	12:00:00	72	354	69
2371	Martes	17:00:00	18:00:00	72	349	47
2372	Martes	10:00:00	11:00:00	72	355	70
2373	Martes	08:00:00	09:00:00	72	353	70
2374	Miércoles	12:00:00	13:00:00	72	352	69
2375	Miércoles	17:00:00	18:00:00	72	349	47
2376	Miércoles	11:00:00	12:00:00	72	354	69
2377	Miércoles	08:00:00	09:00:00	72	353	70
2378	Miércoles	10:00:00	11:00:00	72	355	70
2379	Miércoles	09:00:00	10:00:00	72	351	93
2380	Miércoles	13:00:00	14:00:00	72	350	130
2381	Jueves	08:00:00	09:00:00	72	353	70
2382	Jueves	10:00:00	11:00:00	72	355	70
2383	Jueves	11:00:00	12:00:00	72	354	69
2384	Jueves	13:00:00	14:00:00	72	350	130
2385	Jueves	09:00:00	10:00:00	72	351	93
2386	Jueves	17:00:00	18:00:00	72	349	47
2387	Jueves	12:00:00	13:00:00	72	352	69
2388	Viernes	12:00:00	13:00:00	72	352	69
2389	Viernes	08:00:00	09:00:00	72	353	70
2390	Viernes	11:00:00	12:00:00	72	354	69
2391	Viernes	13:00:00	14:00:00	72	350	130
2392	Viernes	09:00:00	10:00:00	72	351	93
2393	Viernes	10:00:00	11:00:00	72	355	70
2394	Viernes	16:00:00	17:00:00	72	349	47
2395	Viernes	17:00:00	18:00:00	72	349	47
2396	Lunes	09:00:00	10:00:00	73	349	43
2397	Lunes	11:00:00	12:00:00	73	356	131
2398	Lunes	16:00:00	17:00:00	73	357	87
2399	Lunes	08:00:00	09:00:00	73	352	68
2400	Lunes	10:00:00	11:00:00	73	358	44
2401	Lunes	17:00:00	18:00:00	73	354	71
2402	Lunes	13:00:00	14:00:00	73	355	43
2403	Martes	11:00:00	12:00:00	73	356	131
2404	Martes	08:00:00	09:00:00	73	352	68
2405	Martes	16:00:00	17:00:00	73	357	87
2406	Martes	17:00:00	18:00:00	73	354	71
2407	Martes	09:00:00	10:00:00	73	349	43
2408	Martes	13:00:00	14:00:00	73	355	43
2409	Martes	12:00:00	13:00:00	73	358	42
2410	Miércoles	08:00:00	09:00:00	73	352	68
2411	Miércoles	09:00:00	10:00:00	73	349	43
2412	Miércoles	17:00:00	18:00:00	73	354	71
2413	Miércoles	12:00:00	13:00:00	73	358	49
2414	Miércoles	13:00:00	14:00:00	73	355	43
2415	Miércoles	16:00:00	17:00:00	73	357	87
2416	Miércoles	11:00:00	12:00:00	73	356	131
2417	Jueves	12:00:00	13:00:00	73	358	49
2418	Jueves	13:00:00	14:00:00	73	355	43
2419	Jueves	17:00:00	18:00:00	73	354	71
2420	Jueves	11:00:00	12:00:00	73	356	131
2421	Jueves	16:00:00	17:00:00	73	357	87
2422	Jueves	09:00:00	10:00:00	73	349	43
2423	Jueves	08:00:00	09:00:00	73	352	68
2424	Viernes	08:00:00	09:00:00	73	352	68
2425	Viernes	12:00:00	13:00:00	73	358	49
2426	Viernes	17:00:00	18:00:00	73	354	71
2427	Viernes	11:00:00	12:00:00	73	356	131
2428	Viernes	16:00:00	17:00:00	73	357	87
2429	Viernes	13:00:00	14:00:00	73	355	43
2430	Viernes	09:00:00	10:00:00	73	349	43
2431	Viernes	10:00:00	11:00:00	73	349	43
2432	Lunes	10:00:00	11:00:00	74	352	111
2433	Lunes	17:00:00	18:00:00	74	356	131
2434	Lunes	08:00:00	09:00:00	74	359	44
2435	Lunes	16:00:00	17:00:00	74	358	62
2436	Lunes	13:00:00	14:00:00	74	354	44
2437	Lunes	11:00:00	12:00:00	74	349	48
2438	Lunes	09:00:00	10:00:00	74	355	68
2439	Martes	11:00:00	12:00:00	74	349	48
2440	Martes	09:00:00	10:00:00	74	355	68
2441	Martes	10:00:00	11:00:00	74	352	111
2442	Martes	17:00:00	18:00:00	74	356	131
2443	Martes	13:00:00	14:00:00	74	354	44
2444	Martes	12:00:00	13:00:00	74	349	48
2445	Martes	08:00:00	09:00:00	74	359	44
2446	Martes	16:00:00	17:00:00	74	358	62
2447	Miércoles	10:00:00	11:00:00	74	352	111
2448	Miércoles	11:00:00	12:00:00	74	349	48
2449	Miércoles	13:00:00	14:00:00	74	354	44
2450	Miércoles	16:00:00	17:00:00	74	358	62
2451	Miércoles	09:00:00	10:00:00	74	355	68
2452	Miércoles	08:00:00	09:00:00	74	359	44
2453	Miércoles	17:00:00	18:00:00	74	356	131
2454	Jueves	16:00:00	17:00:00	74	358	62
2455	Jueves	09:00:00	10:00:00	74	355	68
2456	Jueves	13:00:00	14:00:00	74	354	44
2457	Jueves	17:00:00	18:00:00	74	356	131
2458	Jueves	08:00:00	09:00:00	74	359	44
2459	Jueves	11:00:00	12:00:00	74	349	48
2460	Jueves	10:00:00	11:00:00	74	352	111
2461	Viernes	16:00:00	17:00:00	74	358	62
2462	Viernes	17:00:00	18:00:00	74	356	131
2463	Viernes	08:00:00	09:00:00	74	359	44
2464	Viernes	09:00:00	10:00:00	74	355	68
2465	Viernes	13:00:00	14:00:00	74	354	44
2466	Viernes	11:00:00	12:00:00	74	349	48
2467	Viernes	10:00:00	11:00:00	74	352	111
2468	Lunes	10:00:00	11:00:00	75	354	110
2469	Lunes	09:00:00	10:00:00	75	356	131
2470	Lunes	13:00:00	14:00:00	75	360	88
2471	Lunes	08:00:00	09:00:00	75	361	73
2472	Lunes	11:00:00	12:00:00	75	362	108
2473	Lunes	12:00:00	13:00:00	75	362	108
2474	Lunes	17:00:00	18:00:00	75	363	110
2475	Lunes	16:00:00	17:00:00	75	364	110
2476	Martes	17:00:00	18:00:00	75	363	110
2477	Martes	16:00:00	17:00:00	75	364	110
2478	Martes	11:00:00	12:00:00	75	362	108
2479	Martes	10:00:00	11:00:00	75	354	110
2480	Martes	13:00:00	14:00:00	75	360	88
2481	Martes	08:00:00	09:00:00	75	361	73
2482	Martes	09:00:00	10:00:00	75	356	131
2483	Miércoles	16:00:00	17:00:00	75	364	110
2484	Miércoles	10:00:00	11:00:00	75	354	110
2485	Miércoles	11:00:00	12:00:00	75	362	108
2486	Miércoles	08:00:00	09:00:00	75	361	73
2487	Miércoles	17:00:00	18:00:00	75	363	110
2488	Miércoles	13:00:00	14:00:00	75	360	88
2489	Miércoles	09:00:00	10:00:00	75	356	131
2490	Jueves	08:00:00	09:00:00	75	361	73
2491	Jueves	17:00:00	18:00:00	75	363	110
2492	Jueves	11:00:00	12:00:00	75	362	108
2493	Jueves	09:00:00	10:00:00	75	356	131
2494	Jueves	13:00:00	14:00:00	75	360	88
2495	Jueves	10:00:00	11:00:00	75	354	110
2496	Jueves	16:00:00	17:00:00	75	364	110
2497	Viernes	08:00:00	09:00:00	75	361	73
2498	Viernes	09:00:00	10:00:00	75	356	131
2499	Viernes	13:00:00	14:00:00	75	360	88
2500	Viernes	17:00:00	18:00:00	75	363	110
2501	Viernes	11:00:00	12:00:00	75	362	108
2502	Viernes	10:00:00	11:00:00	75	354	110
2503	Viernes	16:00:00	17:00:00	75	364	110
2504	Lunes	08:00:00	09:00:00	76	362	96
2505	Lunes	13:00:00	14:00:00	76	356	131
2506	Lunes	17:00:00	18:00:00	76	365	78
2507	Lunes	12:00:00	13:00:00	76	364	110
2508	Lunes	11:00:00	12:00:00	76	366	110
2509	Lunes	10:00:00	11:00:00	76	353	112
2510	Lunes	16:00:00	17:00:00	76	363	73
2511	Martes	13:00:00	14:00:00	76	356	131
2512	Martes	12:00:00	13:00:00	76	364	110
2513	Martes	17:00:00	18:00:00	76	365	78
2514	Martes	10:00:00	11:00:00	76	353	112
2515	Martes	08:00:00	09:00:00	76	362	96
2516	Martes	16:00:00	17:00:00	76	363	73
2517	Martes	11:00:00	12:00:00	76	366	110
2518	Miércoles	12:00:00	13:00:00	76	364	110
2519	Miércoles	08:00:00	09:00:00	76	362	96
2520	Miércoles	10:00:00	11:00:00	76	353	112
2521	Miércoles	11:00:00	12:00:00	76	366	110
2522	Miércoles	16:00:00	17:00:00	76	363	73
2523	Miércoles	17:00:00	18:00:00	76	365	78
2524	Miércoles	13:00:00	14:00:00	76	356	131
2525	Jueves	11:00:00	12:00:00	76	366	110
2526	Jueves	16:00:00	17:00:00	76	363	73
2527	Jueves	10:00:00	11:00:00	76	353	112
2528	Jueves	13:00:00	14:00:00	76	356	131
2529	Jueves	17:00:00	18:00:00	76	365	78
2530	Jueves	09:00:00	10:00:00	76	362	96
2531	Jueves	08:00:00	09:00:00	76	362	96
2532	Jueves	12:00:00	13:00:00	76	364	110
2533	Viernes	10:00:00	11:00:00	76	353	112
2534	Viernes	13:00:00	14:00:00	76	356	131
2535	Viernes	12:00:00	13:00:00	76	364	110
2536	Viernes	16:00:00	17:00:00	76	363	73
2537	Viernes	17:00:00	18:00:00	76	365	78
2538	Viernes	08:00:00	09:00:00	76	362	96
2539	Viernes	11:00:00	12:00:00	76	366	110
2540	Lunes	13:00:00	14:00:00	79	367	71
2541	Lunes	16:00:00	17:00:00	79	368	76
2542	Lunes	09:00:00	10:00:00	79	369	75
2543	Lunes	12:00:00	13:00:00	79	370	131
2544	Lunes	17:00:00	18:00:00	79	371	100
2545	Lunes	11:00:00	12:00:00	79	372	73
2546	Lunes	08:00:00	09:00:00	79	373	75
2547	Martes	16:00:00	17:00:00	79	368	76
2548	Martes	11:00:00	12:00:00	79	372	75
2549	Martes	08:00:00	09:00:00	79	373	75
2550	Martes	09:00:00	10:00:00	79	369	75
2551	Martes	10:00:00	11:00:00	79	369	75
2552	Martes	17:00:00	18:00:00	79	371	100
2553	Martes	12:00:00	13:00:00	79	370	131
2554	Martes	13:00:00	14:00:00	79	367	71
2555	Miércoles	13:00:00	14:00:00	79	367	71
2556	Miércoles	17:00:00	18:00:00	79	371	100
2557	Miércoles	10:00:00	11:00:00	79	372	75
2558	Miércoles	11:00:00	12:00:00	79	372	75
2559	Miércoles	09:00:00	10:00:00	79	369	75
2560	Miércoles	12:00:00	13:00:00	79	370	131
2561	Miércoles	08:00:00	09:00:00	79	373	75
2562	Jueves	09:00:00	10:00:00	79	369	75
2563	Jueves	16:00:00	17:00:00	79	368	76
2564	Jueves	11:00:00	12:00:00	79	372	73
2565	Jueves	17:00:00	18:00:00	79	371	100
2566	Jueves	13:00:00	14:00:00	79	367	71
2567	Jueves	12:00:00	13:00:00	79	370	131
2568	Jueves	08:00:00	09:00:00	79	373	75
2569	Viernes	13:00:00	14:00:00	79	367	71
2570	Viernes	12:00:00	13:00:00	79	370	131
2571	Viernes	08:00:00	09:00:00	79	373	75
2572	Viernes	09:00:00	10:00:00	79	369	75
2573	Viernes	17:00:00	18:00:00	79	371	100
2574	Viernes	11:00:00	12:00:00	79	372	73
2575	Viernes	16:00:00	17:00:00	79	368	76
2576	Lunes	12:00:00	13:00:00	80	368	76
2577	Lunes	11:00:00	12:00:00	80	369	76
2578	Lunes	10:00:00	11:00:00	80	369	76
2579	Lunes	16:00:00	17:00:00	80	374	126
2580	Lunes	08:00:00	09:00:00	80	375	46
2581	Lunes	13:00:00	14:00:00	80	376	76
2582	Lunes	17:00:00	18:00:00	80	373	76
2583	Lunes	09:00:00	10:00:00	80	377	73
2584	Martes	12:00:00	13:00:00	80	368	76
2585	Martes	13:00:00	14:00:00	80	376	76
2586	Martes	17:00:00	18:00:00	80	373	76
2587	Martes	11:00:00	12:00:00	80	369	76
2588	Martes	08:00:00	09:00:00	80	375	46
2589	Martes	16:00:00	17:00:00	80	374	126
2590	Martes	09:00:00	10:00:00	80	377	73
2591	Miércoles	09:00:00	10:00:00	80	377	73
2592	Miércoles	08:00:00	09:00:00	80	375	46
2593	Miércoles	17:00:00	18:00:00	80	373	76
2594	Miércoles	13:00:00	14:00:00	80	376	76
2595	Miércoles	12:00:00	13:00:00	80	368	76
2596	Miércoles	10:00:00	11:00:00	80	369	76
2597	Miércoles	16:00:00	17:00:00	80	374	126
2598	Jueves	10:00:00	11:00:00	80	369	76
2599	Jueves	12:00:00	13:00:00	80	368	76
2600	Jueves	08:00:00	09:00:00	80	375	46
2601	Jueves	13:00:00	14:00:00	80	376	76
2602	Jueves	09:00:00	10:00:00	80	377	73
2603	Jueves	16:00:00	17:00:00	80	374	126
2604	Jueves	17:00:00	18:00:00	80	373	76
2605	Viernes	09:00:00	10:00:00	80	377	73
2606	Viernes	16:00:00	17:00:00	80	374	126
2607	Viernes	13:00:00	14:00:00	80	376	76
2608	Viernes	08:00:00	09:00:00	80	375	46
2609	Viernes	17:00:00	18:00:00	80	373	76
2610	Viernes	10:00:00	11:00:00	80	369	76
2611	Viernes	12:00:00	13:00:00	80	376	76
2612	Lunes	11:00:00	12:00:00	81	376	75
2613	Lunes	08:00:00	09:00:00	81	378	47
2614	Lunes	09:00:00	10:00:00	81	374	126
2615	Lunes	17:00:00	18:00:00	81	369	75
2616	Lunes	13:00:00	14:00:00	81	377	64
2617	Lunes	10:00:00	11:00:00	81	373	74
2618	Lunes	12:00:00	13:00:00	81	376	75
2619	Lunes	16:00:00	17:00:00	81	379	75
2620	Martes	10:00:00	11:00:00	81	373	74
2621	Martes	13:00:00	14:00:00	81	377	64
2622	Martes	08:00:00	09:00:00	81	378	47
2623	Martes	12:00:00	13:00:00	81	376	75
2624	Martes	09:00:00	10:00:00	81	374	126
2625	Martes	16:00:00	17:00:00	81	369	75
2626	Martes	17:00:00	18:00:00	81	369	75
2627	Miércoles	16:00:00	17:00:00	81	379	75
2628	Miércoles	12:00:00	13:00:00	81	376	75
2629	Miércoles	10:00:00	11:00:00	81	373	74
2630	Miércoles	17:00:00	18:00:00	81	369	75
2631	Miércoles	08:00:00	09:00:00	81	378	47
2632	Miércoles	09:00:00	10:00:00	81	374	126
2633	Miércoles	13:00:00	14:00:00	81	377	64
2634	Jueves	17:00:00	18:00:00	81	369	75
2635	Jueves	08:00:00	09:00:00	81	378	47
2636	Jueves	10:00:00	11:00:00	81	373	74
2637	Jueves	13:00:00	14:00:00	81	377	64
2638	Jueves	09:00:00	10:00:00	81	374	126
2639	Jueves	12:00:00	13:00:00	81	376	75
2640	Jueves	16:00:00	17:00:00	81	379	75
2641	Viernes	17:00:00	18:00:00	81	369	75
2642	Viernes	13:00:00	14:00:00	81	377	64
2643	Viernes	09:00:00	10:00:00	81	374	126
2644	Viernes	08:00:00	09:00:00	81	378	47
2645	Viernes	10:00:00	11:00:00	81	373	74
2646	Viernes	11:00:00	12:00:00	81	376	75
2647	Viernes	16:00:00	17:00:00	81	379	75
2648	Lunes	13:00:00	14:00:00	82	377	64
2649	Lunes	10:00:00	11:00:00	82	376	60
2650	Lunes	08:00:00	09:00:00	82	380	111
2651	Lunes	12:00:00	13:00:00	82	369	60
2652	Lunes	17:00:00	18:00:00	82	381	124
2653	Lunes	09:00:00	10:00:00	82	382	97
2654	Lunes	18:00:00	19:00:00	82	373	61
2655	Martes	08:00:00	09:00:00	82	380	111
2656	Martes	10:00:00	11:00:00	82	376	60
2657	Martes	11:00:00	12:00:00	82	376	60
2658	Martes	18:00:00	19:00:00	82	373	61
2659	Martes	12:00:00	13:00:00	82	369	60
2660	Martes	09:00:00	10:00:00	82	382	97
2661	Martes	17:00:00	18:00:00	82	381	124
2662	Martes	13:00:00	14:00:00	82	377	64
2663	Miércoles	13:00:00	14:00:00	82	377	64
2664	Miércoles	09:00:00	10:00:00	82	382	97
2665	Miércoles	12:00:00	13:00:00	82	369	60
2666	Miércoles	18:00:00	19:00:00	82	373	61
2667	Miércoles	08:00:00	09:00:00	82	380	111
2668	Miércoles	10:00:00	11:00:00	82	376	60
2669	Miércoles	17:00:00	18:00:00	82	381	124
2670	Jueves	12:00:00	13:00:00	82	369	60
2671	Jueves	18:00:00	19:00:00	82	373	61
2672	Jueves	09:00:00	10:00:00	82	382	97
2673	Jueves	10:00:00	11:00:00	82	376	60
2674	Jueves	13:00:00	14:00:00	82	377	64
2675	Jueves	17:00:00	18:00:00	82	381	124
2676	Jueves	11:00:00	12:00:00	82	369	60
2677	Viernes	12:00:00	13:00:00	82	369	60
2678	Viernes	17:00:00	18:00:00	82	381	124
2679	Viernes	08:00:00	09:00:00	82	380	111
2680	Viernes	09:00:00	10:00:00	82	382	97
2681	Viernes	18:00:00	19:00:00	82	373	61
2682	Viernes	13:00:00	14:00:00	82	377	64
2683	Viernes	10:00:00	11:00:00	82	376	60
2684	Lunes	10:00:00	11:00:00	83	383	71
2685	Lunes	16:00:00	17:00:00	83	384	87
2686	Lunes	12:00:00	13:00:00	83	385	73
2687	Lunes	09:00:00	10:00:00	83	386	133
2688	Lunes	17:00:00	18:00:00	83	387	73
2689	Lunes	08:00:00	09:00:00	83	388	74
2690	Lunes	13:00:00	14:00:00	83	389	73
2691	Martes	08:00:00	09:00:00	83	388	74
2692	Martes	10:00:00	11:00:00	83	383	71
2693	Martes	13:00:00	14:00:00	83	389	73
2694	Martes	12:00:00	13:00:00	83	385	73
2695	Martes	09:00:00	10:00:00	83	386	133
2696	Martes	17:00:00	18:00:00	83	387	73
2697	Martes	16:00:00	17:00:00	83	384	87
2698	Miércoles	10:00:00	11:00:00	83	383	71
2699	Miércoles	11:00:00	12:00:00	83	385	73
2700	Miércoles	12:00:00	13:00:00	83	385	73
2701	Miércoles	13:00:00	14:00:00	83	389	73
2702	Miércoles	17:00:00	18:00:00	83	387	73
2703	Miércoles	16:00:00	17:00:00	83	384	87
2704	Miércoles	09:00:00	10:00:00	83	386	133
2705	Miércoles	08:00:00	09:00:00	83	388	74
2706	Jueves	17:00:00	18:00:00	83	387	73
2707	Jueves	16:00:00	17:00:00	83	384	87
2708	Jueves	13:00:00	14:00:00	83	389	73
2709	Jueves	08:00:00	09:00:00	83	388	74
2710	Jueves	09:00:00	10:00:00	83	386	133
2711	Jueves	12:00:00	13:00:00	83	385	73
2712	Jueves	10:00:00	11:00:00	83	383	71
2713	Viernes	17:00:00	18:00:00	83	387	73
2714	Viernes	08:00:00	09:00:00	83	388	74
2715	Viernes	09:00:00	10:00:00	83	386	133
2716	Viernes	16:00:00	17:00:00	83	384	87
2717	Viernes	13:00:00	14:00:00	83	389	73
2718	Viernes	12:00:00	13:00:00	83	385	73
2719	Viernes	10:00:00	11:00:00	83	383	71
2720	Lunes	13:00:00	14:00:00	84	390	74
2721	Lunes	11:00:00	12:00:00	84	388	67
2722	Lunes	08:00:00	09:00:00	84	391	131
2723	Lunes	17:00:00	18:00:00	84	383	74
2724	Lunes	16:00:00	17:00:00	84	389	74
2725	Lunes	09:00:00	10:00:00	84	392	74
2726	Lunes	10:00:00	11:00:00	84	393	73
2727	Martes	11:00:00	12:00:00	84	388	67
2728	Martes	17:00:00	18:00:00	84	383	74
2729	Martes	08:00:00	09:00:00	84	391	131
2730	Martes	09:00:00	10:00:00	84	392	74
2731	Martes	13:00:00	14:00:00	84	390	74
2732	Martes	10:00:00	11:00:00	84	393	73
2733	Martes	16:00:00	17:00:00	84	389	74
2734	Miércoles	17:00:00	18:00:00	84	383	74
2735	Miércoles	13:00:00	14:00:00	84	390	74
2736	Miércoles	09:00:00	10:00:00	84	392	74
2737	Miércoles	16:00:00	17:00:00	84	389	74
2738	Miércoles	10:00:00	11:00:00	84	393	73
2739	Miércoles	08:00:00	09:00:00	84	391	131
2740	Miércoles	11:00:00	12:00:00	84	388	67
2741	Jueves	16:00:00	17:00:00	84	389	74
2742	Jueves	10:00:00	11:00:00	84	393	73
2743	Jueves	09:00:00	10:00:00	84	392	74
2744	Jueves	11:00:00	12:00:00	84	388	67
2745	Jueves	08:00:00	09:00:00	84	391	131
2746	Jueves	13:00:00	14:00:00	84	390	74
2747	Jueves	12:00:00	13:00:00	84	390	74
2748	Jueves	17:00:00	18:00:00	84	383	74
2749	Viernes	09:00:00	10:00:00	84	392	74
2750	Viernes	11:00:00	12:00:00	84	388	67
2751	Viernes	17:00:00	18:00:00	84	383	74
2752	Viernes	10:00:00	11:00:00	84	393	73
2753	Viernes	08:00:00	09:00:00	84	391	131
2754	Viernes	13:00:00	14:00:00	84	390	74
2755	Viernes	16:00:00	17:00:00	84	389	74
2756	Lunes	16:00:00	17:00:00	85	385	72
2757	Lunes	13:00:00	14:00:00	85	388	96
2758	Lunes	08:00:00	09:00:00	85	394	134
2759	Lunes	12:00:00	13:00:00	85	383	93
2760	Lunes	11:00:00	12:00:00	85	389	65
2761	Lunes	10:00:00	11:00:00	85	392	72
2762	Lunes	09:00:00	10:00:00	85	395	99
2763	Martes	13:00:00	14:00:00	85	388	96
2764	Martes	12:00:00	13:00:00	85	383	93
2765	Martes	08:00:00	09:00:00	85	394	134
2766	Martes	10:00:00	11:00:00	85	392	72
2767	Martes	16:00:00	17:00:00	85	385	72
2768	Martes	09:00:00	10:00:00	85	395	99
2769	Martes	11:00:00	12:00:00	85	389	65
2770	Miércoles	12:00:00	13:00:00	85	383	93
2771	Miércoles	16:00:00	17:00:00	85	385	72
2772	Miércoles	10:00:00	11:00:00	85	392	72
2773	Miércoles	11:00:00	12:00:00	85	389	65
2774	Miércoles	09:00:00	10:00:00	85	395	99
2775	Miércoles	08:00:00	09:00:00	85	394	134
2776	Miércoles	13:00:00	14:00:00	85	388	96
2777	Jueves	11:00:00	12:00:00	85	389	65
2778	Jueves	09:00:00	10:00:00	85	395	99
2779	Jueves	10:00:00	11:00:00	85	392	72
2780	Jueves	13:00:00	14:00:00	85	388	96
2781	Jueves	08:00:00	09:00:00	85	394	134
2782	Jueves	16:00:00	17:00:00	85	385	72
2783	Jueves	12:00:00	13:00:00	85	383	93
2784	Viernes	12:00:00	13:00:00	85	383	93
2785	Viernes	11:00:00	12:00:00	85	389	65
2786	Viernes	10:00:00	11:00:00	85	392	72
2787	Viernes	13:00:00	14:00:00	85	388	96
2788	Viernes	08:00:00	09:00:00	85	394	134
2789	Viernes	09:00:00	10:00:00	85	395	99
2790	Viernes	16:00:00	17:00:00	85	385	72
2791	Viernes	17:00:00	18:00:00	85	385	72
2792	Lunes	09:00:00	10:00:00	86	396	71
2793	Lunes	10:00:00	11:00:00	86	397	133
2794	Lunes	17:00:00	18:00:00	86	398	98
2795	Lunes	08:00:00	09:00:00	86	399	71
2796	Lunes	12:00:00	13:00:00	86	400	71
2797	Lunes	16:00:00	17:00:00	86	401	71
2798	Lunes	11:00:00	12:00:00	86	402	71
2799	Martes	11:00:00	12:00:00	86	402	71
2800	Martes	16:00:00	17:00:00	86	401	71
2801	Martes	12:00:00	13:00:00	86	400	71
2802	Martes	09:00:00	10:00:00	86	396	71
2803	Martes	17:00:00	18:00:00	86	398	98
2804	Martes	08:00:00	09:00:00	86	399	71
2805	Martes	10:00:00	11:00:00	86	397	133
2806	Miércoles	16:00:00	17:00:00	86	401	71
2807	Miércoles	09:00:00	10:00:00	86	396	71
2808	Miércoles	12:00:00	13:00:00	86	400	71
2809	Miércoles	08:00:00	09:00:00	86	399	71
2810	Miércoles	11:00:00	12:00:00	86	402	71
2811	Miércoles	17:00:00	18:00:00	86	398	98
2812	Miércoles	10:00:00	11:00:00	86	397	133
2813	Jueves	08:00:00	09:00:00	86	399	71
2814	Jueves	11:00:00	12:00:00	86	402	71
2815	Jueves	12:00:00	13:00:00	86	400	71
2816	Jueves	10:00:00	11:00:00	86	397	133
2817	Jueves	17:00:00	18:00:00	86	398	98
2818	Jueves	09:00:00	10:00:00	86	396	71
2819	Jueves	16:00:00	17:00:00	86	401	71
2820	Viernes	08:00:00	09:00:00	86	399	71
2821	Viernes	10:00:00	11:00:00	86	397	133
2822	Viernes	17:00:00	18:00:00	86	398	98
2823	Viernes	11:00:00	12:00:00	86	402	71
2824	Viernes	12:00:00	13:00:00	86	400	71
2825	Viernes	09:00:00	10:00:00	86	396	71
2826	Viernes	16:00:00	17:00:00	86	401	71
2827	Lunes	12:00:00	13:00:00	87	396	47
2828	Lunes	10:00:00	11:00:00	87	403	135
2829	Lunes	16:00:00	17:00:00	87	404	84
2830	Lunes	11:00:00	12:00:00	87	399	93
2831	Lunes	17:00:00	18:00:00	87	400	44
2832	Lunes	08:00:00	09:00:00	87	401	45
2833	Lunes	09:00:00	10:00:00	87	402	46
2834	Martes	09:00:00	10:00:00	87	402	49
2835	Martes	08:00:00	09:00:00	87	401	45
2836	Martes	17:00:00	18:00:00	87	400	44
2837	Martes	12:00:00	13:00:00	87	396	47
2838	Martes	16:00:00	17:00:00	87	404	84
2839	Martes	11:00:00	12:00:00	87	399	93
2840	Martes	10:00:00	11:00:00	87	403	135
2841	Miércoles	08:00:00	09:00:00	87	401	45
2842	Miércoles	12:00:00	13:00:00	87	396	47
2843	Miércoles	17:00:00	18:00:00	87	400	44
2844	Miércoles	11:00:00	12:00:00	87	399	93
2845	Miércoles	09:00:00	10:00:00	87	402	46
2846	Miércoles	16:00:00	17:00:00	87	404	84
2847	Miércoles	10:00:00	11:00:00	87	403	135
2848	Jueves	11:00:00	12:00:00	87	399	93
2849	Jueves	09:00:00	10:00:00	87	402	46
2850	Jueves	17:00:00	18:00:00	87	400	44
2851	Jueves	10:00:00	11:00:00	87	403	135
2852	Jueves	16:00:00	17:00:00	87	404	84
2853	Jueves	12:00:00	13:00:00	87	396	48
2854	Jueves	08:00:00	09:00:00	87	401	45
2855	Viernes	11:00:00	12:00:00	87	399	93
2856	Viernes	10:00:00	11:00:00	87	403	135
2857	Viernes	16:00:00	17:00:00	87	404	84
2858	Viernes	09:00:00	10:00:00	87	402	46
2859	Viernes	17:00:00	18:00:00	87	400	44
2860	Viernes	12:00:00	13:00:00	87	396	48
2861	Viernes	08:00:00	09:00:00	87	401	45
2862	Lunes	11:00:00	12:00:00	88	396	72
2863	Lunes	10:00:00	11:00:00	88	403	135
2864	Lunes	17:00:00	18:00:00	88	405	100
2865	Lunes	12:00:00	13:00:00	88	399	72
2866	Lunes	13:00:00	14:00:00	88	400	72
2867	Lunes	09:00:00	10:00:00	88	401	72
2868	Lunes	08:00:00	09:00:00	88	402	72
2869	Martes	08:00:00	09:00:00	88	402	72
2870	Martes	09:00:00	10:00:00	88	401	72
2871	Martes	13:00:00	14:00:00	88	400	72
2872	Martes	11:00:00	12:00:00	88	396	72
2873	Martes	17:00:00	18:00:00	88	405	100
2874	Martes	12:00:00	13:00:00	88	399	72
2875	Martes	10:00:00	11:00:00	88	403	135
2876	Miércoles	09:00:00	10:00:00	88	401	72
2877	Miércoles	11:00:00	12:00:00	88	396	72
2878	Miércoles	13:00:00	14:00:00	88	400	72
2879	Miércoles	12:00:00	13:00:00	88	399	72
2880	Miércoles	08:00:00	09:00:00	88	402	72
2881	Miércoles	17:00:00	18:00:00	88	405	100
2882	Miércoles	10:00:00	11:00:00	88	403	135
2883	Jueves	12:00:00	13:00:00	88	399	72
2884	Jueves	08:00:00	09:00:00	88	402	72
2885	Jueves	13:00:00	14:00:00	88	400	72
2886	Jueves	10:00:00	11:00:00	88	403	135
2887	Jueves	17:00:00	18:00:00	88	405	100
2888	Jueves	11:00:00	12:00:00	88	396	72
2889	Jueves	09:00:00	10:00:00	88	401	72
2890	Viernes	12:00:00	13:00:00	88	399	72
2891	Viernes	10:00:00	11:00:00	88	403	135
2892	Viernes	17:00:00	18:00:00	88	405	100
2893	Viernes	08:00:00	09:00:00	88	402	72
2894	Viernes	13:00:00	14:00:00	88	400	72
2895	Viernes	11:00:00	12:00:00	88	396	72
2896	Viernes	09:00:00	10:00:00	88	401	72
2897	Lunes	09:00:00	10:00:00	89	406	86
2898	Lunes	13:00:00	14:00:00	89	407	121
2899	Lunes	12:00:00	13:00:00	89	408	86
2900	Lunes	11:00:00	12:00:00	89	408	86
2901	Lunes	10:00:00	11:00:00	89	409	124
2902	Lunes	17:00:00	18:00:00	89	410	106
2903	Martes	11:00:00	12:00:00	89	411	86
2904	Martes	10:00:00	11:00:00	89	409	124
2905	Martes	13:00:00	14:00:00	89	407	121
2906	Martes	09:00:00	10:00:00	89	406	86
2907	Martes	12:00:00	13:00:00	89	408	86
2908	Martes	17:00:00	18:00:00	89	410	106
2909	Miércoles	17:00:00	18:00:00	89	410	106
2910	Miércoles	11:00:00	12:00:00	89	411	86
2911	Miércoles	13:00:00	14:00:00	89	407	121
2912	Miércoles	09:00:00	10:00:00	89	406	86
2913	Miércoles	12:00:00	13:00:00	89	408	86
2914	Miércoles	10:00:00	11:00:00	89	409	124
2915	Jueves	17:00:00	18:00:00	89	410	85
2916	Jueves	16:00:00	17:00:00	89	410	85
2917	Jueves	09:00:00	10:00:00	89	406	86
2918	Jueves	11:00:00	12:00:00	89	411	86
2919	Jueves	13:00:00	14:00:00	89	407	121
2920	Jueves	12:00:00	13:00:00	89	408	86
2921	Jueves	10:00:00	11:00:00	89	409	124
2922	Viernes	11:00:00	12:00:00	89	411	86
2923	Viernes	17:00:00	18:00:00	89	410	106
2924	Viernes	10:00:00	11:00:00	89	409	124
2925	Viernes	13:00:00	14:00:00	89	407	121
2926	Viernes	09:00:00	10:00:00	89	406	86
2927	Viernes	12:00:00	13:00:00	89	408	86
2928	Lunes	11:00:00	12:00:00	90	412	85
2929	Lunes	08:00:00	09:00:00	90	406	82
2930	Lunes	12:00:00	13:00:00	90	407	113
2931	Lunes	10:00:00	11:00:00	90	408	85
2932	Lunes	09:00:00	10:00:00	90	413	127
2933	Lunes	17:00:00	18:00:00	90	414	90
2934	Martes	08:00:00	09:00:00	90	406	82
2935	Martes	11:00:00	12:00:00	90	412	85
2936	Martes	09:00:00	10:00:00	90	413	127
2937	Martes	12:00:00	13:00:00	90	407	113
2938	Martes	10:00:00	11:00:00	90	408	85
2939	Martes	17:00:00	18:00:00	90	414	90
2940	Miércoles	12:00:00	13:00:00	90	407	113
2941	Miércoles	09:00:00	10:00:00	90	413	127
2942	Miércoles	08:00:00	09:00:00	90	406	82
2943	Miércoles	10:00:00	11:00:00	90	408	85
2944	Miércoles	11:00:00	12:00:00	90	408	85
2945	Miércoles	17:00:00	18:00:00	90	414	90
2946	Jueves	11:00:00	12:00:00	90	412	85
2947	Jueves	16:00:00	17:00:00	90	414	90
2948	Jueves	09:00:00	10:00:00	90	413	127
2949	Jueves	10:00:00	11:00:00	90	408	85
2950	Jueves	12:00:00	13:00:00	90	407	113
2951	Jueves	08:00:00	09:00:00	90	406	82
2952	Jueves	17:00:00	18:00:00	90	414	90
2953	Viernes	10:00:00	11:00:00	90	408	85
2954	Viernes	11:00:00	12:00:00	90	412	85
2955	Viernes	09:00:00	10:00:00	90	413	127
2956	Viernes	08:00:00	09:00:00	90	406	82
2957	Viernes	12:00:00	13:00:00	90	407	113
2958	Viernes	17:00:00	18:00:00	90	414	90
2959	Lunes	10:00:00	11:00:00	91	412	88
2960	Lunes	13:00:00	14:00:00	91	406	101
2961	Lunes	09:00:00	10:00:00	91	407	110
2962	Lunes	17:00:00	18:00:00	91	408	86
2963	Lunes	11:00:00	12:00:00	91	415	124
2964	Lunes	12:00:00	13:00:00	91	414	21
2965	Lunes	16:00:00	17:00:00	91	408	86
2966	Martes	13:00:00	14:00:00	91	406	101
2967	Martes	10:00:00	11:00:00	91	412	88
2968	Martes	11:00:00	12:00:00	91	415	124
2969	Martes	09:00:00	10:00:00	91	407	110
2970	Martes	17:00:00	18:00:00	91	408	86
2971	Martes	12:00:00	13:00:00	91	414	21
2972	Miércoles	11:00:00	12:00:00	91	415	124
2973	Miércoles	13:00:00	14:00:00	91	406	101
2974	Miércoles	10:00:00	11:00:00	91	412	88
2975	Miércoles	17:00:00	18:00:00	91	408	86
2976	Miércoles	09:00:00	10:00:00	91	407	110
2977	Miércoles	12:00:00	13:00:00	91	414	21
2978	Jueves	09:00:00	10:00:00	91	407	110
2979	Jueves	11:00:00	12:00:00	91	415	124
2980	Jueves	13:00:00	14:00:00	91	406	101
2981	Jueves	10:00:00	11:00:00	91	412	88
2982	Jueves	17:00:00	18:00:00	91	408	86
2983	Jueves	12:00:00	13:00:00	91	414	21
2984	Viernes	11:00:00	12:00:00	91	414	21
2985	Viernes	12:00:00	13:00:00	91	414	21
2986	Viernes	13:00:00	14:00:00	91	406	101
2987	Viernes	09:00:00	10:00:00	91	407	110
2988	Viernes	10:00:00	11:00:00	91	415	134
2989	Viernes	17:00:00	18:00:00	91	408	86
2990	Lunes	10:00:00	11:00:00	93	416	125
2991	Lunes	08:00:00	09:00:00	93	417	87
2992	Lunes	09:00:00	10:00:00	93	418	87
2993	Lunes	17:00:00	18:00:00	93	419	84
2994	Lunes	11:00:00	12:00:00	93	420	84
2995	Lunes	12:00:00	13:00:00	93	420	84
2996	Lunes	16:00:00	17:00:00	93	421	84
2997	Martes	09:00:00	10:00:00	93	417	87
2998	Martes	10:00:00	11:00:00	93	416	125
2999	Martes	11:00:00	12:00:00	93	422	84
3000	Martes	16:00:00	17:00:00	93	421	84
3001	Martes	08:00:00	09:00:00	93	417	87
3002	Martes	17:00:00	18:00:00	93	419	84
3003	Martes	12:00:00	13:00:00	93	420	84
3004	Miércoles	17:00:00	18:00:00	93	419	84
3005	Miércoles	09:00:00	10:00:00	93	418	87
3006	Miércoles	08:00:00	09:00:00	93	417	87
3007	Miércoles	16:00:00	17:00:00	93	421	84
3008	Miércoles	11:00:00	12:00:00	93	422	84
3009	Miércoles	10:00:00	11:00:00	93	416	125
3010	Miércoles	12:00:00	13:00:00	93	420	84
3011	Jueves	08:00:00	09:00:00	93	417	87
3012	Jueves	12:00:00	13:00:00	93	420	84
3013	Jueves	11:00:00	12:00:00	93	422	84
3014	Jueves	16:00:00	17:00:00	93	421	84
3015	Jueves	10:00:00	11:00:00	93	416	125
3016	Jueves	17:00:00	18:00:00	93	419	84
3017	Jueves	09:00:00	10:00:00	93	418	87
3018	Viernes	12:00:00	13:00:00	93	420	84
3019	Viernes	11:00:00	12:00:00	93	422	84
3020	Viernes	09:00:00	10:00:00	93	418	87
3021	Viernes	16:00:00	17:00:00	93	421	84
3022	Viernes	10:00:00	11:00:00	93	416	125
3023	Viernes	17:00:00	18:00:00	93	419	84
3024	Viernes	08:00:00	09:00:00	93	417	87
3025	Lunes	10:00:00	11:00:00	94	419	84
3026	Lunes	16:00:00	17:00:00	94	423	89
3027	Lunes	13:00:00	14:00:00	94	424	127
3028	Lunes	17:00:00	18:00:00	94	425	88
3029	Lunes	09:00:00	10:00:00	94	420	89
3030	Lunes	12:00:00	13:00:00	94	417	88
3031	Lunes	08:00:00	09:00:00	94	420	89
3032	Martes	17:00:00	18:00:00	94	425	88
3033	Martes	12:00:00	13:00:00	94	417	88
3034	Martes	16:00:00	17:00:00	94	423	89
3035	Martes	08:00:00	09:00:00	94	420	89
3036	Martes	13:00:00	14:00:00	94	424	127
3037	Martes	10:00:00	11:00:00	94	419	84
3038	Martes	09:00:00	10:00:00	94	422	89
3039	Miércoles	09:00:00	10:00:00	94	422	89
3040	Miércoles	12:00:00	13:00:00	94	417	88
3041	Miércoles	10:00:00	11:00:00	94	419	84
3042	Miércoles	17:00:00	18:00:00	94	425	88
3043	Miércoles	16:00:00	17:00:00	94	423	89
3044	Miércoles	08:00:00	09:00:00	94	420	89
3045	Miércoles	13:00:00	14:00:00	94	424	127
3046	Jueves	10:00:00	11:00:00	94	419	84
3047	Jueves	09:00:00	10:00:00	94	422	89
3048	Jueves	16:00:00	17:00:00	94	423	89
3049	Jueves	13:00:00	14:00:00	94	424	127
3050	Jueves	17:00:00	18:00:00	94	425	88
3051	Jueves	12:00:00	13:00:00	94	417	88
3052	Jueves	08:00:00	09:00:00	94	420	89
3053	Viernes	12:00:00	13:00:00	94	417	88
3054	Viernes	10:00:00	11:00:00	94	419	84
3055	Viernes	13:00:00	14:00:00	94	424	127
3056	Viernes	16:00:00	17:00:00	94	423	89
3057	Viernes	09:00:00	10:00:00	94	422	89
3058	Viernes	08:00:00	09:00:00	94	420	89
3059	Viernes	11:00:00	12:00:00	94	417	88
3060	Lunes	09:00:00	10:00:00	95	417	90
3061	Lunes	11:00:00	12:00:00	95	426	87
3062	Lunes	17:00:00	18:00:00	95	427	91
3063	Lunes	12:00:00	13:00:00	95	426	87
3064	Lunes	10:00:00	11:00:00	95	417	90
3065	Lunes	16:00:00	17:00:00	95	419	88
3066	Lunes	13:00:00	14:00:00	95	428	136
3067	Lunes	08:00:00	09:00:00	95	422	86
3068	Martes	16:00:00	17:00:00	95	419	88
3069	Martes	13:00:00	14:00:00	95	428	136
3070	Martes	12:00:00	13:00:00	95	426	87
3071	Martes	10:00:00	11:00:00	95	417	90
3072	Martes	09:00:00	10:00:00	95	425	77
3073	Martes	17:00:00	18:00:00	95	427	91
3074	Miércoles	13:00:00	14:00:00	95	428	136
3075	Miércoles	08:00:00	09:00:00	95	422	86
3076	Miércoles	12:00:00	13:00:00	95	426	87
3077	Miércoles	17:00:00	18:00:00	95	427	91
3078	Miércoles	16:00:00	17:00:00	95	419	88
3079	Miércoles	09:00:00	10:00:00	95	425	77
3080	Miércoles	10:00:00	11:00:00	95	417	90
3081	Jueves	16:00:00	17:00:00	95	419	88
3082	Jueves	12:00:00	13:00:00	95	426	87
3083	Jueves	10:00:00	11:00:00	95	417	90
3084	Jueves	08:00:00	09:00:00	95	422	86
3085	Jueves	13:00:00	14:00:00	95	428	136
3086	Jueves	09:00:00	10:00:00	95	425	77
3087	Jueves	17:00:00	18:00:00	95	427	91
3088	Viernes	17:00:00	18:00:00	95	427	91
3089	Viernes	10:00:00	11:00:00	95	417	90
3090	Viernes	16:00:00	17:00:00	95	419	88
3091	Viernes	12:00:00	13:00:00	95	426	87
3092	Viernes	09:00:00	10:00:00	95	425	77
3093	Viernes	08:00:00	09:00:00	95	422	86
3094	Viernes	13:00:00	14:00:00	95	428	136
3095	Lunes	17:00:00	18:00:00	96	429	78
3096	Lunes	12:00:00	13:00:00	96	430	121
3097	Lunes	10:00:00	11:00:00	96	431	87
3098	Lunes	11:00:00	12:00:00	96	432	90
3099	Lunes	13:00:00	14:00:00	96	433	125
3100	Lunes	08:00:00	09:00:00	96	434	90
3101	Lunes	16:00:00	17:00:00	96	435	91
3102	Martes	16:00:00	17:00:00	96	435	91
3103	Martes	08:00:00	09:00:00	96	434	90
3104	Martes	13:00:00	14:00:00	96	433	125
3105	Martes	17:00:00	18:00:00	96	429	78
3106	Martes	10:00:00	11:00:00	96	431	87
3107	Martes	11:00:00	12:00:00	96	432	90
3108	Martes	12:00:00	13:00:00	96	430	121
3109	Miércoles	08:00:00	09:00:00	96	434	90
3110	Miércoles	17:00:00	18:00:00	96	429	78
3111	Miércoles	13:00:00	14:00:00	96	433	125
3112	Miércoles	11:00:00	12:00:00	96	432	90
3113	Miércoles	09:00:00	10:00:00	96	434	90
3114	Miércoles	16:00:00	17:00:00	96	435	91
3115	Miércoles	10:00:00	11:00:00	96	431	87
3116	Miércoles	12:00:00	13:00:00	96	430	121
3117	Jueves	11:00:00	12:00:00	96	432	90
3118	Jueves	17:00:00	18:00:00	96	429	78
3119	Jueves	16:00:00	17:00:00	96	435	91
3120	Jueves	13:00:00	14:00:00	96	433	125
3121	Jueves	12:00:00	13:00:00	96	430	121
3122	Jueves	10:00:00	11:00:00	96	431	87
3123	Jueves	08:00:00	09:00:00	96	434	90
3124	Viernes	08:00:00	09:00:00	96	434	90
3125	Viernes	10:00:00	11:00:00	96	431	87
3126	Viernes	16:00:00	17:00:00	96	435	91
3127	Viernes	13:00:00	14:00:00	96	433	125
3128	Viernes	17:00:00	18:00:00	96	429	78
3129	Viernes	11:00:00	12:00:00	96	432	90
3130	Lunes	17:00:00	18:00:00	97	436	93
3131	Lunes	12:00:00	13:00:00	97	430	121
3132	Lunes	09:00:00	10:00:00	97	431	84
3133	Lunes	16:00:00	17:00:00	97	432	92
3134	Lunes	08:00:00	09:00:00	97	437	124
3135	Lunes	11:00:00	12:00:00	97	434	89
3136	Lunes	13:00:00	14:00:00	97	435	86
3137	Martes	13:00:00	14:00:00	97	435	86
3138	Martes	11:00:00	12:00:00	97	434	89
3139	Martes	08:00:00	09:00:00	97	437	124
3140	Martes	17:00:00	18:00:00	97	436	93
3141	Martes	09:00:00	10:00:00	97	431	84
3142	Martes	16:00:00	17:00:00	97	432	92
3143	Martes	12:00:00	13:00:00	97	430	121
3144	Miércoles	11:00:00	12:00:00	97	434	89
3145	Miércoles	17:00:00	18:00:00	97	436	93
3146	Miércoles	08:00:00	09:00:00	97	437	124
3147	Miércoles	10:00:00	11:00:00	97	432	89
3148	Miércoles	13:00:00	14:00:00	97	435	86
3149	Miércoles	09:00:00	10:00:00	97	431	84
3150	Miércoles	12:00:00	13:00:00	97	430	121
3151	Jueves	12:00:00	13:00:00	97	430	121
3152	Jueves	09:00:00	10:00:00	97	431	84
3153	Jueves	13:00:00	14:00:00	97	435	86
3154	Jueves	16:00:00	17:00:00	97	432	92
3155	Jueves	11:00:00	12:00:00	97	434	89
3156	Jueves	17:00:00	18:00:00	97	436	93
3157	Jueves	08:00:00	09:00:00	97	437	124
3158	Viernes	11:00:00	12:00:00	97	434	89
3159	Viernes	13:00:00	14:00:00	97	435	86
3160	Viernes	08:00:00	09:00:00	97	437	124
3161	Viernes	09:00:00	10:00:00	97	431	84
3162	Viernes	17:00:00	18:00:00	97	436	93
3163	Viernes	10:00:00	11:00:00	97	434	89
3164	Viernes	16:00:00	17:00:00	97	432	92
3165	Lunes	16:00:00	17:00:00	98	438	94
3166	Lunes	12:00:00	13:00:00	98	430	121
3167	Lunes	11:00:00	12:00:00	98	431	91
3168	Lunes	09:00:00	10:00:00	98	432	91
3169	Lunes	10:00:00	11:00:00	98	439	127
3170	Lunes	13:00:00	14:00:00	98	434	91
3171	Lunes	17:00:00	18:00:00	98	435	92
3172	Martes	17:00:00	18:00:00	98	435	92
3173	Martes	13:00:00	14:00:00	98	434	91
3174	Martes	10:00:00	11:00:00	98	439	127
3175	Martes	16:00:00	17:00:00	98	438	94
3176	Martes	11:00:00	12:00:00	98	431	91
3177	Martes	09:00:00	10:00:00	98	432	91
3178	Martes	12:00:00	13:00:00	98	430	121
3179	Miércoles	13:00:00	14:00:00	98	434	91
3180	Miércoles	16:00:00	17:00:00	98	438	94
3181	Miércoles	10:00:00	11:00:00	98	439	127
3182	Miércoles	09:00:00	10:00:00	98	432	91
3183	Miércoles	17:00:00	18:00:00	98	435	92
3184	Miércoles	11:00:00	12:00:00	98	431	91
3185	Miércoles	12:00:00	13:00:00	98	430	121
3186	Jueves	12:00:00	13:00:00	98	430	121
3187	Jueves	11:00:00	12:00:00	98	431	91
3188	Jueves	17:00:00	18:00:00	98	435	92
3189	Jueves	09:00:00	10:00:00	98	432	91
3190	Jueves	13:00:00	14:00:00	98	434	91
3191	Jueves	16:00:00	17:00:00	98	438	94
3192	Jueves	10:00:00	11:00:00	98	439	127
3193	Viernes	13:00:00	14:00:00	98	434	91
3194	Viernes	17:00:00	18:00:00	98	435	92
3195	Viernes	10:00:00	11:00:00	98	439	127
3196	Viernes	11:00:00	12:00:00	98	431	91
3197	Viernes	16:00:00	17:00:00	98	438	94
3198	Viernes	12:00:00	13:00:00	98	434	91
3199	Viernes	09:00:00	10:00:00	98	432	91
3200	Lunes	13:00:00	14:00:00	99	440	84
3201	Lunes	17:00:00	18:00:00	99	441	87
3202	Lunes	11:00:00	12:00:00	99	442	136
3203	Lunes	16:00:00	17:00:00	99	443	96
3204	Lunes	10:00:00	11:00:00	99	444	92
3205	Lunes	12:00:00	13:00:00	99	445	89
3206	Lunes	09:00:00	10:00:00	99	444	92
3207	Martes	12:00:00	13:00:00	99	445	89
3208	Martes	17:00:00	18:00:00	99	441	87
3209	Martes	16:00:00	17:00:00	99	443	96
3210	Martes	09:00:00	10:00:00	99	444	92
3211	Martes	11:00:00	12:00:00	99	442	136
3212	Martes	13:00:00	14:00:00	99	440	84
3213	Martes	10:00:00	11:00:00	99	446	92
3214	Miércoles	10:00:00	11:00:00	99	446	92
3215	Miércoles	17:00:00	18:00:00	99	441	87
3216	Miércoles	13:00:00	14:00:00	99	440	84
3217	Miércoles	12:00:00	13:00:00	99	445	89
3218	Miércoles	16:00:00	17:00:00	99	443	96
3219	Miércoles	09:00:00	10:00:00	99	444	92
3220	Miércoles	11:00:00	12:00:00	99	442	136
3221	Jueves	13:00:00	14:00:00	99	440	84
3222	Jueves	10:00:00	11:00:00	99	446	92
3223	Jueves	16:00:00	17:00:00	99	443	96
3224	Jueves	11:00:00	12:00:00	99	442	136
3225	Jueves	12:00:00	13:00:00	99	445	89
3226	Jueves	17:00:00	18:00:00	99	441	87
3227	Jueves	09:00:00	10:00:00	99	444	92
3228	Viernes	17:00:00	18:00:00	99	441	87
3229	Viernes	13:00:00	14:00:00	99	440	84
3230	Viernes	11:00:00	12:00:00	99	442	136
3231	Viernes	16:00:00	17:00:00	99	443	96
3232	Viernes	10:00:00	11:00:00	99	446	92
3233	Viernes	12:00:00	13:00:00	99	445	89
3234	Viernes	09:00:00	10:00:00	99	444	92
3235	Lunes	16:00:00	17:00:00	100	447	95
3236	Lunes	11:00:00	12:00:00	100	441	92
3237	Lunes	10:00:00	11:00:00	100	442	136
3238	Lunes	13:00:00	14:00:00	100	448	90
3239	Lunes	12:00:00	13:00:00	100	440	92
3240	Lunes	09:00:00	10:00:00	100	445	85
3241	Lunes	17:00:00	18:00:00	100	444	107
3242	Martes	09:00:00	10:00:00	100	445	85
3243	Martes	11:00:00	12:00:00	100	441	92
3244	Martes	13:00:00	14:00:00	100	448	90
3245	Martes	17:00:00	18:00:00	100	444	107
3246	Martes	10:00:00	11:00:00	100	442	136
3247	Martes	16:00:00	17:00:00	100	444	102
3248	Martes	12:00:00	13:00:00	100	440	92
3249	Miércoles	10:00:00	11:00:00	100	442	136
3250	Miércoles	09:00:00	10:00:00	100	445	85
3251	Miércoles	12:00:00	13:00:00	100	440	92
3252	Miércoles	16:00:00	17:00:00	100	447	95
3253	Miércoles	13:00:00	14:00:00	100	448	90
3254	Miércoles	17:00:00	18:00:00	100	444	107
3255	Miércoles	11:00:00	12:00:00	100	441	92
3256	Jueves	12:00:00	13:00:00	100	440	92
3257	Jueves	16:00:00	17:00:00	100	447	95
3258	Jueves	13:00:00	14:00:00	100	448	90
3259	Jueves	10:00:00	11:00:00	100	442	136
3260	Jueves	09:00:00	10:00:00	100	445	85
3261	Jueves	11:00:00	12:00:00	100	441	92
3262	Jueves	17:00:00	18:00:00	100	444	107
3263	Viernes	11:00:00	12:00:00	100	441	92
3264	Viernes	12:00:00	13:00:00	100	440	92
3265	Viernes	10:00:00	11:00:00	100	442	136
3266	Viernes	13:00:00	14:00:00	100	448	90
3267	Viernes	16:00:00	17:00:00	100	447	95
3268	Viernes	09:00:00	10:00:00	100	445	85
3269	Viernes	17:00:00	18:00:00	100	444	107
3270	Lunes	12:00:00	13:00:00	101	449	91
3271	Lunes	09:00:00	10:00:00	101	450	94
3272	Lunes	13:00:00	14:00:00	101	451	128
3273	Lunes	16:00:00	17:00:00	101	452	93
3274	Lunes	10:00:00	11:00:00	101	453	91
3275	Lunes	17:00:00	18:00:00	101	454	94
3276	Lunes	11:00:00	12:00:00	101	455	95
3277	Martes	17:00:00	18:00:00	101	454	94
3278	Martes	16:00:00	17:00:00	101	452	93
3279	Martes	10:00:00	11:00:00	101	453	91
3280	Martes	13:00:00	14:00:00	101	451	128
3281	Martes	12:00:00	13:00:00	101	449	91
3282	Martes	11:00:00	12:00:00	101	455	95
3283	Martes	09:00:00	10:00:00	101	450	94
3284	Miércoles	11:00:00	12:00:00	101	455	95
3285	Miércoles	17:00:00	18:00:00	101	454	94
3286	Miércoles	09:00:00	10:00:00	101	450	94
3287	Miércoles	12:00:00	13:00:00	101	449	91
3288	Miércoles	13:00:00	14:00:00	101	451	128
3289	Miércoles	10:00:00	11:00:00	101	453	91
3290	Miércoles	16:00:00	17:00:00	101	452	93
3291	Jueves	09:00:00	10:00:00	101	450	94
3292	Jueves	12:00:00	13:00:00	101	449	91
3293	Jueves	10:00:00	11:00:00	101	453	91
3294	Jueves	13:00:00	14:00:00	101	451	128
3295	Jueves	17:00:00	18:00:00	101	454	94
3296	Jueves	16:00:00	17:00:00	101	452	93
3297	Jueves	11:00:00	12:00:00	101	455	95
3298	Viernes	16:00:00	17:00:00	101	452	93
3299	Viernes	09:00:00	10:00:00	101	450	94
3300	Viernes	13:00:00	14:00:00	101	451	128
3301	Viernes	10:00:00	11:00:00	101	453	91
3302	Viernes	12:00:00	13:00:00	101	455	95
3303	Viernes	17:00:00	18:00:00	101	454	94
3304	Viernes	11:00:00	12:00:00	101	455	95
3305	Lunes	16:00:00	17:00:00	102	454	63
3306	Lunes	17:00:00	18:00:00	102	456	127
3307	Lunes	12:00:00	13:00:00	102	455	95
3308	Lunes	11:00:00	12:00:00	102	450	63
3309	Lunes	08:00:00	09:00:00	102	452	91
3310	Lunes	13:00:00	14:00:00	102	455	95
3311	Lunes	09:00:00	10:00:00	102	457	88
3312	Martes	09:00:00	10:00:00	102	457	88
3313	Martes	13:00:00	14:00:00	102	455	95
3314	Martes	12:00:00	13:00:00	102	458	85
3315	Martes	17:00:00	18:00:00	102	456	127
3316	Martes	11:00:00	12:00:00	102	450	63
3317	Martes	16:00:00	17:00:00	102	454	63
3318	Martes	08:00:00	09:00:00	102	452	91
3319	Miércoles	08:00:00	09:00:00	102	452	91
3320	Miércoles	11:00:00	12:00:00	102	450	63
3321	Miércoles	12:00:00	13:00:00	102	458	85
3322	Miércoles	16:00:00	17:00:00	102	454	63
3323	Miércoles	09:00:00	10:00:00	102	457	88
3324	Miércoles	13:00:00	14:00:00	102	455	95
3325	Miércoles	17:00:00	18:00:00	102	456	127
3326	Jueves	16:00:00	17:00:00	102	454	63
3327	Jueves	17:00:00	18:00:00	102	456	127
3328	Jueves	11:00:00	12:00:00	102	450	63
3329	Jueves	13:00:00	14:00:00	102	455	95
3330	Jueves	09:00:00	10:00:00	102	457	88
3331	Jueves	08:00:00	09:00:00	102	452	91
3332	Jueves	12:00:00	13:00:00	102	458	85
3333	Viernes	13:00:00	14:00:00	102	455	95
3334	Viernes	12:00:00	13:00:00	102	458	85
3335	Viernes	17:00:00	18:00:00	102	456	127
3336	Viernes	11:00:00	12:00:00	102	450	63
3337	Viernes	16:00:00	17:00:00	102	454	63
3338	Viernes	08:00:00	09:00:00	102	452	91
3339	Lunes	12:00:00	13:00:00	103	452	94
3340	Lunes	10:00:00	11:00:00	103	459	96
3341	Lunes	17:00:00	18:00:00	103	460	136
3342	Lunes	16:00:00	17:00:00	103	454	63
3343	Lunes	11:00:00	12:00:00	103	450	63
3344	Lunes	08:00:00	09:00:00	103	455	95
3345	Lunes	13:00:00	14:00:00	103	461	92
3346	Martes	16:00:00	17:00:00	103	454	63
3347	Martes	12:00:00	13:00:00	103	452	94
3348	Martes	10:00:00	11:00:00	103	459	96
3349	Martes	13:00:00	14:00:00	103	461	92
3350	Martes	08:00:00	09:00:00	103	455	95
3351	Martes	17:00:00	18:00:00	103	460	136
3352	Martes	11:00:00	12:00:00	103	450	63
3353	Miércoles	17:00:00	18:00:00	103	460	136
3354	Miércoles	16:00:00	17:00:00	103	454	63
3355	Miércoles	11:00:00	12:00:00	103	450	63
3356	Miércoles	10:00:00	11:00:00	103	459	96
3357	Miércoles	12:00:00	13:00:00	103	452	94
3358	Miércoles	08:00:00	09:00:00	103	455	95
3359	Miércoles	13:00:00	14:00:00	103	461	92
3360	Jueves	11:00:00	12:00:00	103	450	63
3361	Jueves	10:00:00	11:00:00	103	459	96
3362	Jueves	17:00:00	18:00:00	103	460	136
3363	Jueves	16:00:00	17:00:00	103	454	63
3364	Jueves	12:00:00	13:00:00	103	452	94
3365	Jueves	08:00:00	09:00:00	103	455	95
3366	Jueves	09:00:00	10:00:00	103	455	95
3367	Viernes	12:00:00	13:00:00	103	452	94
3368	Viernes	17:00:00	18:00:00	103	460	136
3369	Viernes	10:00:00	11:00:00	103	459	96
3370	Viernes	13:00:00	14:00:00	103	461	92
3371	Viernes	16:00:00	17:00:00	103	454	63
3372	Viernes	11:00:00	12:00:00	103	450	63
3373	Viernes	08:00:00	09:00:00	103	455	95
3374	Lunes	17:00:00	18:00:00	104	462	20
3375	Lunes	12:00:00	13:00:00	104	463	77
3376	Lunes	16:00:00	17:00:00	104	464	121
3377	Lunes	13:00:00	14:00:00	104	465	94
3378	Lunes	18:00:00	19:00:00	104	466	77
3379	Lunes	09:00:00	10:00:00	104	467	136
3380	Lunes	11:00:00	12:00:00	104	468	77
3381	Martes	18:00:00	19:00:00	104	466	77
3382	Martes	17:00:00	18:00:00	104	462	20
3383	Martes	12:00:00	13:00:00	104	463	77
3384	Martes	11:00:00	12:00:00	104	468	77
3385	Martes	09:00:00	10:00:00	104	467	136
3386	Martes	13:00:00	14:00:00	104	465	94
3387	Martes	16:00:00	17:00:00	104	464	121
3388	Miércoles	17:00:00	18:00:00	104	462	20
3389	Miércoles	13:00:00	14:00:00	104	465	94
3390	Miércoles	09:00:00	10:00:00	104	467	136
3391	Miércoles	16:00:00	17:00:00	104	462	20
3392	Miércoles	11:00:00	12:00:00	104	468	77
3393	Miércoles	18:00:00	19:00:00	104	466	77
3394	Miércoles	12:00:00	13:00:00	104	463	77
3395	Jueves	09:00:00	10:00:00	104	467	136
3396	Jueves	11:00:00	12:00:00	104	468	77
3397	Jueves	13:00:00	14:00:00	104	465	94
3398	Jueves	12:00:00	13:00:00	104	463	77
3399	Jueves	18:00:00	19:00:00	104	466	77
3400	Jueves	16:00:00	17:00:00	104	464	121
3401	Jueves	17:00:00	18:00:00	104	462	20
3402	Viernes	09:00:00	10:00:00	104	467	136
3403	Viernes	12:00:00	13:00:00	104	463	77
3404	Viernes	18:00:00	19:00:00	104	466	77
3405	Viernes	11:00:00	12:00:00	104	468	77
3406	Viernes	13:00:00	14:00:00	104	465	94
3407	Viernes	16:00:00	17:00:00	104	464	121
3408	Viernes	17:00:00	18:00:00	104	462	20
3409	Lunes	12:00:00	13:00:00	105	469	65
3410	Lunes	17:00:00	18:00:00	105	470	21
3411	Lunes	08:00:00	09:00:00	105	467	136
3412	Lunes	13:00:00	14:00:00	105	471	21
3413	Lunes	09:00:00	10:00:00	105	462	21
3414	Lunes	11:00:00	12:00:00	105	463	113
3415	Lunes	16:00:00	17:00:00	105	464	121
3416	Martes	08:00:00	09:00:00	105	467	136
3417	Martes	13:00:00	14:00:00	105	471	21
3418	Martes	12:00:00	13:00:00	105	469	65
3419	Martes	17:00:00	18:00:00	105	470	21
3420	Martes	16:00:00	17:00:00	105	464	121
3421	Martes	11:00:00	12:00:00	105	463	113
3422	Martes	09:00:00	10:00:00	105	462	21
3423	Miércoles	08:00:00	09:00:00	105	467	136
3424	Miércoles	17:00:00	18:00:00	105	470	21
3425	Miércoles	09:00:00	10:00:00	105	462	21
3426	Miércoles	12:00:00	13:00:00	105	469	65
3427	Miércoles	13:00:00	14:00:00	105	471	21
3428	Miércoles	11:00:00	12:00:00	105	463	113
3429	Jueves	09:00:00	10:00:00	105	462	21
3430	Jueves	16:00:00	17:00:00	105	464	121
3431	Jueves	12:00:00	13:00:00	105	469	65
3432	Jueves	08:00:00	09:00:00	105	467	136
3433	Jueves	10:00:00	11:00:00	105	462	21
3434	Jueves	13:00:00	14:00:00	105	471	21
3435	Jueves	17:00:00	18:00:00	105	470	21
3436	Jueves	11:00:00	12:00:00	105	463	113
3437	Viernes	11:00:00	12:00:00	105	463	113
3438	Viernes	17:00:00	18:00:00	105	470	21
3439	Viernes	08:00:00	09:00:00	105	467	136
3440	Viernes	12:00:00	13:00:00	105	469	65
3441	Viernes	16:00:00	17:00:00	105	464	121
3442	Viernes	13:00:00	14:00:00	105	471	21
3443	Viernes	09:00:00	10:00:00	105	462	21
3444	Lunes	10:00:00	11:00:00	106	462	20
3445	Lunes	11:00:00	12:00:00	106	462	20
3446	Lunes	17:00:00	18:00:00	106	472	61
3447	Lunes	16:00:00	17:00:00	106	470	21
3448	Lunes	08:00:00	09:00:00	106	473	127
3449	Lunes	13:00:00	14:00:00	106	463	20
3450	Lunes	09:00:00	10:00:00	106	471	20
3451	Martes	16:00:00	17:00:00	106	470	21
3452	Martes	08:00:00	09:00:00	106	473	127
3453	Martes	11:00:00	12:00:00	106	462	20
3454	Martes	12:00:00	13:00:00	106	474	20
3455	Martes	09:00:00	10:00:00	106	471	20
3456	Martes	17:00:00	18:00:00	106	472	61
3457	Martes	13:00:00	14:00:00	106	463	20
3458	Miércoles	11:00:00	12:00:00	106	462	20
3459	Miércoles	12:00:00	13:00:00	106	474	20
3460	Miércoles	17:00:00	18:00:00	106	472	61
3461	Miércoles	08:00:00	09:00:00	106	473	127
3462	Miércoles	09:00:00	10:00:00	106	471	20
3463	Miércoles	16:00:00	17:00:00	106	470	21
3464	Miércoles	13:00:00	14:00:00	106	463	20
3465	Jueves	08:00:00	09:00:00	106	473	127
3466	Jueves	09:00:00	10:00:00	106	471	20
3467	Jueves	17:00:00	18:00:00	106	472	61
3468	Jueves	13:00:00	14:00:00	106	463	20
3469	Jueves	16:00:00	17:00:00	106	470	21
3470	Jueves	12:00:00	13:00:00	106	474	20
3471	Jueves	11:00:00	12:00:00	106	462	20
3472	Viernes	08:00:00	09:00:00	106	473	127
3473	Viernes	13:00:00	14:00:00	106	463	20
3474	Viernes	16:00:00	17:00:00	106	470	21
3475	Viernes	09:00:00	10:00:00	106	471	20
3476	Viernes	17:00:00	18:00:00	106	472	61
3477	Viernes	12:00:00	13:00:00	106	474	20
3478	Viernes	11:00:00	12:00:00	106	462	20
3479	Lunes	17:00:00	18:00:00	107	475	123
3480	Martes	17:00:00	18:00:00	107	475	123
3481	Miércoles	17:00:00	18:00:00	107	475	123
3482	Jueves	17:00:00	18:00:00	107	475	123
3483	Viernes	17:00:00	18:00:00	107	475	123
3484	Lunes	17:00:00	18:00:00	109	476	79
3485	Lunes	16:00:00	17:00:00	109	476	79
3486	Lunes	08:00:00	09:00:00	109	477	48
3487	Martes	16:00:00	17:00:00	109	476	79
3488	Martes	08:00:00	09:00:00	109	477	48
3489	Martes	17:00:00	18:00:00	109	476	79
3490	Miércoles	16:00:00	17:00:00	109	476	79
3491	Miércoles	08:00:00	09:00:00	109	477	48
3492	Miércoles	17:00:00	18:00:00	109	476	79
3493	Jueves	08:00:00	09:00:00	109	477	48
3494	Jueves	16:00:00	17:00:00	109	476	79
3495	Jueves	17:00:00	18:00:00	109	476	79
3496	Viernes	08:00:00	09:00:00	109	477	48
3497	Viernes	17:00:00	18:00:00	109	476	79
3498	Viernes	16:00:00	17:00:00	109	476	79
3499	Lunes	08:00:00	09:00:00	110	478	62
3500	Martes	08:00:00	09:00:00	110	478	62
3501	Miércoles	08:00:00	09:00:00	110	478	62
3502	Jueves	08:00:00	09:00:00	110	478	62
3503	Viernes	08:00:00	09:00:00	110	478	62
3504	Lunes	10:00:00	11:00:00	111	479	82
3505	Lunes	17:00:00	18:00:00	111	479	113
3506	Martes	10:00:00	11:00:00	111	479	82
3507	Martes	17:00:00	18:00:00	111	479	113
3508	Miércoles	16:00:00	17:00:00	111	479	113
3509	Miércoles	17:00:00	18:00:00	111	479	113
3510	Jueves	10:00:00	11:00:00	111	479	89
3511	Jueves	17:00:00	18:00:00	111	479	113
3512	Viernes	10:00:00	11:00:00	111	479	82
3513	Viernes	17:00:00	18:00:00	111	479	113
\.


--
-- Data for Name: materias; Type: TABLE DATA; Schema: public; Owner: proj_user
--

COPY public.materias (id, nombre, carrera_id, profesor_id, academia_id, semestre, sinodal_id) FROM stdin;
1	SALA DE CÓMPUTO / INGLÉS	1	1	\N	1	\N
2	HISTORIA DEL PENSAMIENTO FILOSÓFICO	1	2	\N	1	\N
3	INTRODUCCIÓN A LAS CIENCIAS ADMINISTRATIVAS	1	3	\N	1	\N
4	INFORMÁTICA EMPRESARIAL	1	4	\N	1	\N
5	INTRODUCCIÓN A LA CONTABILIDAD	1	5	\N	1	\N
6	MATEMÁTICAS PARA CIENCIAS EMPRESARIALES	1	6	\N	1	\N
7	ADMINISTRACIÓN	2	7	\N	1	\N
8	CÁLCULO I	2	8	\N	1	\N
9	LÓGICA MATEMÁTICA	2	9	\N	1	\N
10	HISTORIA DEL PENSAMIENTO FILOSÓFICO	2	10	\N	1	\N
11	DISEÑO ESTRUCTURADO DE ALGORITMOS	2	11	\N	1	\N
12	SALA DE CÓMPUTO	2	12	\N	1	\N
13	DISEÑO ESTRUCTURADO DE ALGORITMOS	2	13	\N	1	\N
14	SALA DE CÓMPUTO / INGLÉS	2	14	\N	1	\N
15	REDES I	2	15	\N	5	\N
16	SALA DE CÓMPUTO	2	16	\N	5	\N
17	INGLÉS	2	17	\N	5	\N
18	BASES DE DATOS II	2	4	\N	5	\N
19	DISEÑO WEB	2	18	\N	5	\N
20	FUNDAMENTOS DE SISTEMAS OPERATIVOS	2	10	\N	5	\N
21	PARADIGMAS DE PROGRAMACIÓN II	2	13	\N	5	\N
22	DERECHO Y LEGISLACIÓN EN INFORMÁTICA	2	19	\N	7	\N
23	SALA DE CÓMPUTO	2	16	\N	7	\N
24	INGLÉS	2	20	\N	7	\N
25	INGENIERÍA DE SOFTWARE II	2	21	\N	7	\N
26	PROBABILIDAD Y ESTADÍSTICA	2	22	\N	7	\N
27	BASES DE DATOS AVANZADAS	2	18	\N	7	\N
28	TECNOLOGÍAS WEB II	2	11	\N	7	\N
29	METODOLOGÍA DE LA INVESTIGACIÓN	2	22	\N	9	\N
30	SALA DE CÓMPUTO	2	23	\N	9	\N
31	INGLÉS	2	24	\N	9	\N
32	TECNOLOGÍAS DE INFORMACIÓN I	2	18	\N	9	\N
33	SEGURIDAD DE CENTROS DE INFORMÁTICA	2	15	\N	9	\N
34	TEORÍA DE ALGORITMOS	2	9	\N	9	\N
35	INTELIGENCIA ARTIFICIAL I	2	25	\N	9	\N
36	SALA DE CÓMPUTO / INGLÉS	1	26	\N	1	\N
37	MATEMÁTICAS PARA CIENCIAS EMPRESARIALES	1	27	\N	1	\N
38	INFORMÁTICA EMPRESARIAL	1	28	\N	1	\N
39	ADMINISTRACIÓN DE RECURSOS HUMANOS II	1	2	\N	3	\N
40	SALA DE CÓMPUTO	1	26	\N	3	\N
41	INGLÉS	1	29	\N	3	\N
42	ADMINISTRACIÓN DE COMPRAS E INVENTARIOS	1	7	\N	3	\N
43	CONTABILIDAD DE COSTOS	1	30	\N	3	\N
44	ESTADÍSTICA INFERENCIAL	1	8	\N	3	\N
45	DERECHO MERCANTIL	1	31	\N	3	\N
46	MACROECONOMÍA	1	32	\N	5	\N
47	SALA DE CÓMPUTO	1	1	\N	5	\N
48	INGLÉS	1	33	\N	5	\N
49	TALLER DE METODOLOGÍA DE LA INVESTIGACIÓN	1	3	\N	5	\N
50	ADMINISTRACIÓN DE SUELDOS Y SALARIOS	1	5	\N	5	\N
51	FINANZAS EMPRESARIALES I	1	34	\N	5	\N
52	DERECHO FISCAL	1	31	\N	5	\N
53	ECONOMÍA DEL SECTOR PÚBLICO MEXICANO	1	32	\N	7	\N
54	SALA DE CÓMPUTO	1	1	\N	7	\N
55	INGLÉS	1	35	\N	7	\N
56	SISTEMA FINANCIERO	1	34	\N	7	\N
57	INVESTIGACIÓN DE OPERACIONES	1	6	\N	7	\N
58	ADMINISTRACIÓN ESTRATÉGICA DE VENTAS	1	30	\N	7	\N
59	PLANEACIÓN ESTRATÉGICA	1	7	\N	7	\N
60	EMPRENDIMIENTO DE NEGOCIOS	1	36	\N	9	\N
61	SALA DE CÓMPUTO	1	37	\N	9	\N
62	INGLÉS	1	38	\N	9	\N
63	GESTIÓN DE LA CALIDAD	1	30	\N	9	\N
64	CULTURA EMPRESARIAL	1	3	\N	9	\N
65	FINANZAS CORPORATIVAS	1	7	\N	9	\N
66	COMERCIO EXTERIOR	1	39	\N	9	\N
67	FINANZAS PÚBLICAS I	3	34	\N	5	\N
68	SALA DE CÓMPUTO	3	37	\N	5	\N
69	INGLÉS	3	40	\N	5	\N
70	GERENCIA PÚBLICA	3	41	\N	5	\N
71	MACROECONOMÍA	3	42	\N	5	\N
72	GOBIERNO Y ASUNTOS PÚBLICOS	3	43	\N	5	\N
73	SISTEMA POLÍTICO MEXICANO	3	44	\N	5	\N
74	GERENCIA SOCIAL	3	45	\N	7	\N
75	SALA DE CÓMPUTO	3	26	\N	7	\N
76	INGLÉS	3	46	\N	7	\N
77	SISTEMAS DE AUDITORÍA GUBERNAMENTAL	3	47	\N	7	\N
78	PROCESOS DE GOBIERNO EN MÉXICO (ÁMBITO FEDERAL)	3	48	\N	7	\N
79	POLÍTICAS PÚBLICAS II	3	43	\N	7	\N
80	GESTIÓN DE RECURSOS HUMANOS	3	49	\N	7	\N
81	GESTIÓN Y ADMINISTRACIÓN URBANA	3	50	\N	9	\N
82	PROCESOS DE GOBIERNO EN MÉXICO (ÁMBITO MUNICIPAL)	3	51	\N	9	\N
83	PLANEACIÓN ESTRATÉGICA	3	41	\N	9	\N
84	ÉTICA Y RENDICIÓN DE CUENTAS PÚBLICAS	3	52	\N	9	\N
85	SEMINARIO DE TESIS I	3	53	\N	9	\N
86	INGLÉS	3	54	\N	9	\N
87	SALA DE CÓMPUTO	3	1	\N	9	\N
88	MATEMATICAS APLICADAS A LAS CIENCIAS SOCIALES	3	6	\N	1	\N
89	FUNDAMENTOS DE LA ADMINISTRACION PUBLICA	3	45	\N	1	\N
90	INTRODUCCION AL SISTEMA JURIDICO MEXICANO	3	48	\N	1	\N
91	HISTORIA DEL PENSAMIENTO FILOSOFICO	3	55	\N	1	\N
92	HISTORIA MUNDIAL	3	44	\N	1	\N
93	SALA DE CÓMPUTO / INGLÉS	3	1	\N	1	\N
94	MICROECONOMÍA	3	42	\N	3	\N
95	SALA DE CÓMPUTO	3	1	\N	3	\N
96	INGLÉS	3	56	\N	3	\N
97	GOBIERNO Y ASUNTOS PÚBLICOS	3	43	\N	3	\N
98	SOCIEDAD Y ESTADO EN MÉXICO	3	44	\N	3	\N
99	DERECHO ADMINISTRATIVO	3	31	\N	3	\N
100	TEORÍA GENERAL DEL ESTADO	3	57	\N	3	\N
101	FUNDAMENTOS, METODOS Y TECNICAS DE PLANEACION	4	58	\N	1	\N
102	TALLER DE TESIS I: PROTOCOLO DE INVESTIGACIÓN	4	59	\N	1	\N
103	TEORIAS DEL DESARROLLO	4	60	\N	1	\N
104	INGLÉS	4	61	\N	1	\N
105	TEORÍA Y MARCO JURÍDICO DEL MUNICIPIO	4	51	\N	1	\N
106	ESTADISTICA PARA CIENCIAS SOCIALES	4	52	\N	1	\N
107	COMITÉ TUTORIAL	4	62	\N	1	\N
108	INVESTIGACIÓN	4	62	\N	1	\N
109	BIOESTADÍSTICA I	5	21	\N	1	\N
110	METODOLOGÍA DE LA INVESTIGACIÓN CIENTÍFICA	5	63	\N	1	\N
111	SALA TESISTA	5	64	\N	1	\N
112	SALUD, SOCIEDAD Y DERECHOS HUMANOS	5	65	\N	1	\N
113	FUNDAMENTOS DE SALUD PÚBLICA	5	66	\N	1	\N
114	METODOLOGÍA DE LA INVESTIGACIÓN CUALITATIVA	5	67	\N	1	\N
115	EPIDEMIOLOGÍA I	5	68	\N	1	\N
116	INGLÉS	5	61	\N	1	\N
117	COMITÉ TUTORIAL	5	69	\N	1	\N
118	POLÍTICAS DE SALUD	5	70	\N	3	\N
119	FARMACOLOGÍA REGIONAL Y SALUD PÚBLICA (OPTATIVA)	5	71	\N	3	\N
120	SALA TESISTA	5	72	\N	3	\N
121	INGLÉS	5	61	\N	3	\N
122	COMITÉ TUTORIAL	5	73	\N	3	\N
123	SEMINARIO DE INVESTIGACIÓN	5	65	\N	3	\N
124	INVESTIGACIÓN	5	74	\N	3	\N
125	SALA TESISTA	6	75	\N	3	\N
126	POLÍTICAS PÚBLICAS Y TIC	6	52	\N	3	\N
127	DEMOCRACIA, GOBERNABILIDAD Y GOBERNANZA	6	43	\N	3	\N
128	LABORATORIO DE GOBIERNO ELECTRÓNICO	6	76	\N	3	\N
129	PROTOCOLO DE INVESTIGACIÓN	6	39	\N	3	\N
130	INGLÉS	6	61	\N	3	\N
131	DESARROLLO DE APLICACIONES PARA GOBIERNO ELECTRÓNICO	6	77	\N	3	\N
132	INVESTIGACIÓN	6	76	\N	3	\N
133	LABORATORIO DE GOBIERNO ELECTRÓNICO	7	76	\N	1	\N
134	METODOLOGÍA DE LA INVESTIGACIÓN I	7	59	\N	1	\N
135	MARCO JURÍDICO E INSTITUCIONAL DEL GOBIERNO ELECTRÓNICO	7	49	\N	1	\N
136	SISTEMAS PARA LA TOMA DE DECISIONES EN GOBIERNO ELECTRÓNICO	7	15	\N	1	\N
137	GESTIÓN Y ADMINISTRACIÓN PÚBLICA ELECTRÓNICA	7	78	\N	1	\N
138	INGLÉS	7	61	\N	1	\N
139	SALA TESISTA	7	64	\N	1	\N
140	INVESTIGACIÓN	7	79	\N	1	\N
141	LABORATORIO DE GOBIERNO ELECTRÓNICO	7	80	\N	5	\N
142	INGLÉS	7	61	\N	5	\N
143	INVESTIGACIÓN	7	79	\N	5	\N
144	TESIS DOCTORAL III	7	45	\N	5	\N
145	GOBIERNO ABIERTO	7	49	\N	5	\N
146	EDUCACIÓN Y NUTRICIÓN	8	81	\N	3	\N
147	SALA DE CÓMPUTO	8	82	\N	3	\N
148	INGLÉS	8	83	\N	3	\N
149	BIOQUÍMICA NUTRICIONAL II	8	84	\N	3	\N
150	PSICOLOGÍA ALIMENTARIA Y NUTRICIONAL	8	85	\N	3	\N
151	PATOLOGÍA I	8	86	\N	3	\N
152	MICROBIOLOGÍA Y PARASITOLOGÍA DE LOS ALIMENTOS	8	87	\N	3	\N
153	CÁLCULO Y LABORATORIO DE NUTRICIÓN EN EL CICLO DE VIDA	8	88	\N	5	\N
154	ADMINISTRACIÓN GENERAL	8	34	\N	5	\N
155	GASTROENTEROLOGÍA NUTRICIONAL	8	89	\N	5	\N
156	LABORATORIO DE EVALUACIÓN DEL ESTADO DE NUTRICIÓN	8	90	\N	5	\N
157	SALA DE CÓMPUTO	8	82	\N	5	\N
158	NUTRICIÓN POBLACIONAL II	8	66	\N	5	\N
159	INGLÉS	8	91	\N	5	\N
160	INGLÉS	8	92	\N	7	\N
161	ANÁLISIS DE ALIMENTOS	8	93	\N	7	\N
162	ADMINISTRACIÓN DE SERVICIOS DE ALIMENTOS II	8	94	\N	7	\N
163	QUÍMICA DE LOS ALIMENTOS	8	94	\N	7	\N
164	CÁLCULO Y DIETOTERAPIA EN SITUACIONES PATOLÓGICAS II	8	95	\N	7	\N
165	SALA DE CÓMPUTO	8	96	\N	7	\N
166	NUTRICIÓN Y FARMACOLOGÍA	8	90	\N	7	\N
167	BIOESTADÍSTICA	8	97	\N	9	\N
168	INGLÉS	8	98	\N	9	\N
169	NUTRICIÓN EN SALUD PÚBLICA	8	66	\N	9	\N
170	ATENCIÓN CLÍNICA NUTRICIONAL	8	95	\N	9	\N
171	MÉTODOS Y TÉCNICAS DE INVESTIGACIÓN	8	88	\N	9	\N
172	TECNOLOGÍA DE ALIMENTOS DE ORIGEN ANIMAL	8	93	\N	9	\N
173	SALA DE CÓMPUTO	8	82	\N	9	\N
174	CONTABILIDAD GUBERNAMENTAL	9	99	\N	5	\N
175	SALA DE CÓMPUTO	9	1	\N	5	\N
176	INGLÉS	9	100	\N	5	\N
177	GESTIÓN DE LA INFORMACIÓN TERRITORIAL II	9	101	\N	5	\N
178	MACROECONOMÍA	9	42	\N	5	\N
179	SISTEMAS POLÍTICOS DE GOBIERNO MUNICIPAL	9	55	\N	5	\N
180	DERECHO AGRARIO Y ANÁLISIS DE CONFLICTOS	9	60	\N	5	\N
181	AUDITORÍA GUBERNAMENTAL	9	99	\N	7	\N
182	PLANEACIÓN PROGRAMACIÓN Y PRESUPUESTO	9	102	\N	7	\N
183	SALA DE CÓMPUTO	9	37	\N	7	\N
184	DESARROLLO URBANO	9	101	\N	7	\N
185	METODOLOGÍA DE LA INVESTIGACIÓN CUANTITATIVA	9	42	\N	7	\N
186	SUSTENTABILIDAD Y GESTIÓN LOCAL	9	103	\N	7	\N
187	INGLÉS	9	104	\N	7	\N
188	ADMINISTRACIÓN DE OBRAS PÚBLICAS	9	101	\N	9	\N
189	SALA DE CÓMPUTO	9	1	\N	9	\N
190	INGLÉS	9	24	\N	9	\N
191	SISTEMAS DE EVALUACIÓN Y SEGUIMIENTO	9	41	\N	9	\N
192	SEMINARIO DE TESIS I	9	53	\N	9	\N
193	FORMULACIÓN Y EVALUACIÓN DE PROYECTOS DE INVERSIÓN	9	103	\N	9	\N
194	ADMINISTRACIÓN DE SERVICIOS PÚBLICOS MUNICIPALES	9	39	\N	9	\N
195	INVESTIGACIÓN	4	105	\N	3	\N
196	ANÁLISIS DE INFORMACIÓN DE CAMPO	4	102	\N	3	\N
197	COMITÉ TUTORIAL	4	106	\N	3	\N
198	INGLÉS	4	61	\N	3	\N
199	DIAGNÓSTICO MUNICIPAL PARA LA PLANEACIÓN	4	51	\N	3	\N
200	CONFLICTOS EN PROCESOS SOCIALES DEL MUNICIPIO	4	57	\N	3	\N
201	ORDENAMIENTO TERRITORIAL SOSTENIBLE	4	58	\N	3	\N
202	DIAGNÓSTICO MUNICIPAL PARA LA PLANEACIÓN	4	102	\N	3	\N
203	SALA TESISTA	4	64	\N	3	\N
204	ANÁLISIS DE INFORMACIÓN DE CAMPO	4	60	\N	3	\N
205	ORDENAMIENTO TERRITORIAL SOSTENIBLE	4	101	\N	3	\N
206	INVESTIGACIÓN	4	107	\N	3	\N
207	HISTORIA DEL PENSAMIENTO FILOSÓFICO	8	103	\N	1	\N
208	ANATOMÍA Y FISIOLOGÍA HUMANA I	8	90	\N	1	\N
209	ANTROPOLOGÍA DE LA ALIMENTACIÓN	8	81	\N	1	\N
210	FUNDAMENTOS DE NUTRICIÓN HUMANA	8	108	\N	1	\N
211	QUÍMICA NUTRICIONAL	8	93	\N	1	\N
212	SALA DE CÓMPUTO / INGLÉS	8	96	\N	1	\N
213	SALA DE CÓMPUTO / INGLÉS	8	37	\N	1	\N
214	HISTORIA DEL PENSAMIENTO FILOSOFICO	10	50	\N	1	\N
215	BIOLOGIA CELULAR	10	109	\N	1	\N
216	SALA DE CÓMPUTO / INGLÉS	10	110	\N	1	\N
217	QUIMICA GENERAL	10	111	\N	1	\N
218	MATEMATICAS	10	11	\N	1	\N
219	INTRODUCCION A LA METODOLOGIA DE LA INVESTIGACION	10	112	\N	1	\N
220	MATEMATICAS	10	27	\N	1	\N
221	BIOLOGIA CELULAR	10	87	\N	1	\N
222	QUIMICA GENERAL	10	113	\N	1	\N
223	SALA DE CÓMPUTO	10	96	\N	3	\N
224	BIOSEGURIDAD	10	114	\N	3	\N
225	INGLÉS	10	54	\N	3	\N
226	BIOQUÍMICA METABÓLICA	10	115	\N	3	\N
227	TIC APLICADAS A LAS CIENCIAS BIOMÉDICAS	10	28	\N	3	\N
228	HISTOLOGÍA	10	116	\N	3	\N
229	ANATOMÍA	10	117	\N	3	\N
230	CONTABILIDAD Y FINANZAS	2	30	\N	3	\N
231	TEORÍA DE AUTÓMATAS	2	25	\N	3	\N
232	ÁLGEBRA LINEAL	2	8	\N	3	\N
233	INGLÉS	2	20	\N	3	\N
234	ESTRUCTURAS DE DATOS	2	11	\N	3	\N
235	ELECTRÓNICA DIGITAL	2	27	\N	3	\N
236	SALA DE CÓMPUTO	2	14	\N	3	\N
237	ESTRUCTURAS DE DATOS	2	18	\N	3	\N
238	EMBRIOLOGÍA APLICADA A LA ODONTOLOGÍA	11	118	\N	1	\N
239	ANATOMÍA Y FISIOLOGÍA HUMANA	11	119	\N	1	\N
240	HISTORIA DEL PENSAMIENTO FILOSÓFICO	11	2	\N	1	\N
241	BIOQUÍMICA APLICADA A LA ODONTOLOGÍA	11	120	\N	1	\N
242	SALA DE CÓMPUTO / INGLÉS	11	121	\N	1	\N
243	MATERIALES DENTALES	11	122	\N	1	\N
244	BIOQUÍMICA APLICADA A LA ODONTOLOGÍA	11	87	\N	1	\N
245	SALA DE CÓMPUTO / INGLÉS	11	123	\N	1	\N
246	ANATOMÍA Y FISIOLOGÍA HUMANA	11	124	\N	1	\N
247	HISTORIA DEL PENSAMIENTO FILOSÓFICO	11	78	\N	1	\N
248	ANATOMÍA Y FISIOLOGÍA HUMANA	11	125	\N	1	\N
249	HISTORIA DEL PENSAMIENTO FILOSÓFICO	11	28	\N	1	\N
250	MATERIALES DENTALES	11	126	\N	1	\N
251	BIOQUÍMICA APLICADA A LA ODONTOLOGÍA	11	109	\N	1	\N
252	EMBRIOLOGÍA APLICADA A LA ODONTOLOGÍA	11	127	\N	1	\N
253	HISTORIA DEL PENSAMIENTO FILOSÓFICO	11	55	\N	1	\N
254	SALA DE CÓMPUTO / INGLÉS	11	128	\N	1	\N
255	MATERIALES DENTALES	11	129	\N	1	\N
256	BIOQUÍMICA APLICADA A LA ODONTOLOGÍA	11	130	\N	1	\N
257	ANATOMÍA Y FISIOLOGÍA HUMANA	11	131	\N	1	\N
258	SALA DE CÓMPUTO / INGLÉS	11	132	\N	1	\N
259	EMBRIOLOGÍA APLICADA A LA ODONTOLOGÍA	11	133	\N	1	\N
260	HISTORIA DEL PENSAMIENTO FILOSÓFICO	11	134	\N	1	\N
261	SALA DE CÓMPUTO / INGLÉS	11	135	\N	1	\N
262	MATERIALES DENTALES	11	136	\N	1	\N
263	BIOQUÍMICA APLICADA A LA ODONTOLOGÍA	11	115	\N	1	\N
264	HISTORIA DEL PENSAMIENTO FILOSÓFICO	11	47	\N	1	\N
265	BIOQUÍMICA APLICADA A LA ODONTOLOGÍA	11	111	\N	1	\N
266	SALA DE CÓMPUTO	11	135	\N	1	\N
267	MATERIALES DENTALES	11	137	\N	1	\N
268	INGLÉS	11	138	\N	3	\N
269	FARMACOLOGÍA EN ODONTOLOGÍA	11	130	\N	3	\N
270	PATOLOGÍA GENERAL E INMUNOLOGÍA	11	139	\N	3	\N
271	ODONTOLOGÍA PREVENTIVA Y SALUD PÚBLICA I	11	140	\N	3	\N
272	SALA DE CÓMPUTO	11	123	\N	3	\N
273	RADIOLOGÍA E IMAGENOLOGÍA	11	126	\N	3	\N
274	ANATOMÍA E HISTOLOGÍA DENTAL	11	136	\N	3	\N
275	INGLÉS	11	141	\N	3	\N
276	ODONTOLOGÍA PREVENTIVA Y SALUD PÚBLICA I	11	142	\N	3	\N
277	RADIOLOGÍA E IMAGENOLOGÍA	11	143	\N	3	\N
278	ANATOMÍA E HISTOLOGÍA DENTAL	11	129	\N	3	\N
279	FARMACOLOGÍA EN ODONTOLOGÍA	11	71	\N	3	\N
280	ANATOMÍA E HISTOLOGÍA DENTAL	11	122	\N	3	\N
281	SALA DE CÓMPUTO	11	121	\N	3	\N
282	INGLÉS	11	144	\N	3	\N
283	ODONTOLOGÍA PREVENTIVA Y SALUD PÚBLICA I	11	145	\N	3	\N
284	SALA DE CÓMPUTO	11	128	\N	3	\N
285	INGLÉS	11	146	\N	3	\N
286	PATOLOGÍA BUCODENTAL	11	147	\N	5	\N
287	INGLÉS	11	98	\N	5	\N
288	EXODONCIA I	11	126	\N	5	\N
289	SALA DE CÓMPUTO	11	96	\N	5	\N
290	TÉCNICAS QUIRÚRGICAS	11	148	\N	5	\N
291	OPERATORIA DENTAL	11	149	\N	5	\N
292	PSICOLOGÍA APLICADA EN CLÍNICA	11	85	\N	5	\N
293	OPERATORIA DENTAL	11	150	\N	5	\N
294	SALA DE CÓMPUTO	11	132	\N	5	\N
295	INGLÉS	11	151	\N	5	\N
296	EXODONCIA I	11	145	\N	5	\N
297	INGLÉS	11	152	\N	5	\N
298	INGLÉS	11	153	\N	5	\N
299	OPERATORIA DENTAL	11	143	\N	5	\N
300	INGLÉS	11	154	\N	5	\N
301	EXODONCIA I	11	150	\N	5	\N
302	BIOESTADÍSTICA	11	97	\N	7	\N
303	NUTRICIÓN	11	81	\N	7	\N
304	INGLÉS	11	155	\N	7	\N
305	INGLÉS	11	154	\N	7	\N
306	SALA DE CÓMPUTO	11	156	\N	7	\N
307	PRÓTESIS BUCAL II	11	150	\N	7	\N
308	ENDODONCIA I	11	140	\N	7	\N
309	PROSTODONCIA	11	157	\N	7	\N
310	NUTRICIÓN	11	90	\N	7	\N
311	INGLÉS	11	158	\N	7	\N
312	BIOESTADÍSTICA	11	22	\N	7	\N
313	PROSTODONCIA	11	143	\N	7	\N
314	NUTRICIÓN	11	95	\N	7	\N
315	PRÓTESIS BUCAL II	11	159	\N	7	\N
316	CLÍNICA INTEGRAL	11	142	\N	9	\N
317	ODONTOPEDIATRÍA II	11	142	\N	9	\N
318	CIRUGÍA BUCAL	11	160	\N	9	\N
319	INVESTIGACIÓN EN SALUD	11	120	\N	9	\N
320	PERIODONCIA	11	137	\N	9	\N
321	ORTODONCIA	11	161	\N	9	\N
322	CLÍNICA INTEGRAL	11	160	\N	9	\N
323	ORTODONCIA	11	159	\N	9	\N
324	BASES EPISTEMOLÓGICAS DE LA ENFERMERIA	12	162	\N	1	\N
325	ANATOMÍA HUMANA I	12	117	\N	1	\N
326	HISTORIA DEL PENSAMIENTO FILOSOFICO	12	21	\N	1	\N
327	SOCIOLOGIA Y SALUD	12	58	\N	1	\N
328	SALA DE CÓMPUTO / INGLÉS	12	163	\N	1	\N
329	BIOQUIMICA PARA ENFERMERIA	12	84	\N	1	\N
330	HISTORIA DEL PENSAMIENTO FILOSOFICO	12	164	\N	1	\N
331	SOCIOLOGIA Y SALUD	12	165	\N	1	\N
332	SALA DE CÓMPUTO / INGLÉS	12	82	\N	1	\N
333	BASES EPISTEMOLÓGICAS DE LA ENFERMERIA	12	166	\N	1	\N
334	SOCIOLOGIA Y SALUD	12	167	\N	1	\N
335	BIOQUIMICA PARA ENFERMERIA	12	111	\N	1	\N
336	BIOQUIMICA PARA ENFERMERIA	12	109	\N	1	\N
337	SALA DE CÓMPUTO / INGLÉS	12	168	\N	1	\N
338	BASES EPISTEMOLÓGICAS DE LA ENFERMERIA	12	169	\N	1	\N
339	ANATOMÍA HUMANA I	12	170	\N	1	\N
340	BASES EPISTEMOLÓGICAS DE LA ENFERMERIA	12	171	\N	1	\N
341	SALA DE CÓMPUTO / INGLÉS	12	121	\N	1	\N
342	SOCIOLOGIA Y SALUD	12	171	\N	1	\N
343	HISTORIA DEL PENSAMIENTO FILOSOFICO	12	77	\N	1	\N
344	ANATOMÍA HUMANA I	12	119	\N	1	\N
345	BIOQUIMICA PARA ENFERMERIA	12	114	\N	1	\N
346	HISTORIA DEL PENSAMIENTO FILOSOFICO	12	10	\N	1	\N
347	BIOQUIMICA PARA ENFERMERIA	12	172	\N	1	\N
348	HISTORIA DEL PENSAMIENTO FILOSOFICO	12	4	\N	1	\N
349	BASES DE LA ENFERMERÍA CLÍNICA	12	173	\N	3	\N
350	SALA DE CÓMPUTO	12	163	\N	3	\N
351	INGLÉS	12	174	\N	3	\N
352	SALUD PÚBLICA	12	175	\N	3	\N
353	FISIOLOGÍA AVANZADA	12	176	\N	3	\N
354	BASES DE LA ENFERMERÍA COMUNITARIA	12	177	\N	3	\N
355	INTRODUCCIÓN A LA PSICOLOGÍA	12	178	\N	3	\N
356	SALA DE CÓMPUTO	12	168	\N	3	\N
357	INGLÉS	12	179	\N	3	\N
358	FISIOLOGÍA AVANZADA	12	180	\N	3	\N
359	INGLÉS	12	181	\N	3	\N
360	INGLÉS	12	104	\N	3	\N
361	FISIOLOGÍA AVANZADA	12	131	\N	3	\N
362	BASES DE LA ENFERMERÍA CLÍNICA	12	180	\N	3	\N
363	SALUD PÚBLICA	12	70	\N	3	\N
364	INTRODUCCIÓN A LA PSICOLOGÍA	12	182	\N	3	\N
365	INGLÉS	12	83	\N	3	\N
366	BASES DE LA ENFERMERÍA COMUNITARIA	12	169	\N	3	\N
367	PATOLOGÍA II	12	86	\N	5	\N
368	NUTRICIÓN	12	94	\N	5	\N
369	ENFERMERÍA MÉDICO-QUIRÚRGICA	12	183	\N	5	\N
370	SALA DE CÓMPUTO	12	168	\N	5	\N
371	INGLÉS	12	184	\N	5	\N
372	ENFERMERÍA GINECO-OBSTÉTRICA	12	133	\N	5	\N
373	FARMACOLOGÍA II	12	185	\N	5	\N
374	SALA DE CÓMPUTO	12	26	\N	5	\N
375	INGLÉS	12	186	\N	5	\N
376	ENFERMERÍA GINECO-OBSTÉTRICA	12	127	\N	5	\N
377	PATOLOGÍA II	12	187	\N	5	\N
378	INGLÉS	12	188	\N	5	\N
379	NUTRICIÓN	12	81	\N	5	\N
380	NUTRICIÓN	12	88	\N	5	\N
381	SALA DE CÓMPUTO	12	128	\N	5	\N
382	INGLÉS	12	189	\N	5	\N
383	BIOESTADÍSTICA	12	190	\N	7	\N
384	INGLÉS	12	179	\N	7	\N
385	ENFERMERÍA PEDIÁTRICA	12	170	\N	7	\N
386	SALA DE CÓMPUTO	12	132	\N	7	\N
387	ADMINISTRACIÓN EN LOS SERVICIOS DE ENFERMERÍA	12	125	\N	7	\N
388	PSIQUIATRÍA	12	124	\N	7	\N
389	ENFERMERÍA GERIÁTRICA	12	176	\N	7	\N
390	ENFERMERÍA PEDIÁTRICA	12	173	\N	7	\N
391	SALA DE CÓMPUTO	12	168	\N	7	\N
392	ADMINISTRACIÓN EN LOS SERVICIOS DE ENFERMERÍA	12	191	\N	7	\N
393	INGLÉS	12	192	\N	7	\N
394	SALA DE CÓMPUTO	12	123	\N	7	\N
395	INGLÉS	12	193	\N	7	\N
396	BIOÉTICA	12	19	\N	9	\N
397	SALA DE CÓMPUTO	12	132	\N	9	\N
398	INGLÉS	12	24	\N	9	\N
399	INVESTIGACIÓN CUALITATIVA  EN ENFERMERÍA	12	67	\N	9	\N
400	SEGURIDAD E HIGIENE EN EL TRABAJO	12	191	\N	9	\N
401	ESTRATEGIAS DE ENSEÑANZA-APRENDIZAJE	12	194	\N	9	\N
402	REHABILITACIÓN EN ENFERMERÍA	12	195	\N	9	\N
403	SALA DE CÓMPUTO	12	121	\N	9	\N
404	INGLÉS	12	196	\N	9	\N
405	INGLÉS	12	184	\N	9	\N
406	EMBRIOLOGÍA	13	197	\N	1	\N
407	HISTOLOGÍA I	13	198	\N	1	\N
408	ANATOMÍA HUMANA I	13	187	\N	1	\N
409	SALA DE CÓMPUTO / INGLÉS	13	128	\N	1	\N
410	BIOQUÍMICA	13	84	\N	1	\N
411	HISTORIA DEL PENSAMIENTO FILOSÓFICO	13	50	\N	1	\N
412	HISTORIA DEL PENSAMIENTO FILOSÓFICO	13	134	\N	1	\N
413	SALA DE CÓMPUTO / INGLÉS	13	199	\N	1	\N
414	BIOQUÍMICA	13	112	\N	1	\N
415	SALA DE CÓMPUTO / INGLÉS	13	163	\N	1	\N
416	SALA DE CÓMPUTO	13	110	\N	3	\N
417	FISIOLOGÍA I	13	200	\N	3	\N
418	HISTORIA Y ANTROPOLOGÍA MÉDICA	13	65	\N	3	\N
419	INMUNOLOGÍA	13	201	\N	3	\N
420	BACTERIOLOGÍA Y MICOLOGÍA MÉDICA	13	172	\N	3	\N
421	INGLÉS	13	196	\N	3	\N
422	PSICOLOGÍA MÉDICA	13	202	\N	3	\N
423	INGLÉS	13	203	\N	3	\N
424	SALA DE CÓMPUTO	13	199	\N	3	\N
425	HISTORIA Y ANTROPOLOGÍA MÉDICA	13	89	\N	3	\N
426	BACTERIOLOGÍA Y MICOLOGÍA MÉDICA	13	63	\N	3	\N
427	INGLÉS	13	204	\N	3	\N
428	SALA DE CÓMPUTO	13	205	\N	3	\N
429	INGLÉS	13	83	\N	5	\N
430	SALUD PÚBLICA	13	89	\N	5	\N
431	FARMACOLOGÍA II	13	86	\N	5	\N
432	ANATOMÍA Y FISIOLOGÍA PATOLÓGICA I	13	116	\N	5	\N
433	SALA DE CÓMPUTO	13	110	\N	5	\N
434	FUNDAMENTOS DE CIRUGÍA	13	206	\N	5	\N
435	IMAGENOLOGÍA MÉDICA	13	207	\N	5	\N
436	INGLÉS	13	33	\N	5	\N
437	SALA DE CÓMPUTO	13	128	\N	5	\N
438	INGLÉS	13	208	\N	5	\N
439	SALA DE CÓMPUTO	13	199	\N	5	\N
440	GENÉTICA	13	209	\N	7	\N
441	NEUMOLOGÍA	13	198	\N	7	\N
442	SALA DE CÓMPUTO	13	205	\N	7	\N
443	INGLÉS	13	210	\N	7	\N
444	CIRUGÍA CARDIOTORÁCICA	13	211	\N	7	\N
445	CARDIOLOGÍA	13	207	\N	7	\N
446	EPIDEMIOLOGÍA	13	66	\N	7	\N
447	EPIDEMIOLOGÍA	13	88	\N	7	\N
448	INGLÉS	13	212	\N	7	\N
449	METODOLOGÍA DE LA INVESTIGACIÓN CUALITATIVA	13	41	\N	9	\N
450	REUMATOLOGÍA	13	201	\N	9	\N
451	SALA DE CÓMPUTO	13	82	\N	9	\N
452	NEFROLOGÍA	13	213	\N	9	\N
453	INGLÉS	13	214	\N	9	\N
454	PEDIATRÍA II	13	206	\N	9	\N
455	GINECOLOGÍA	13	139	\N	9	\N
456	SALA DE CÓMPUTO	13	199	\N	9	\N
457	INGLÉS	13	91	\N	9	\N
458	METODOLOGÍA DE LA INVESTIGACIÓN CUALITATIVA	13	162	\N	9	\N
459	INGLÉS	13	215	\N	9	\N
460	SALA DE CÓMPUTO	13	205	\N	9	\N
461	METODOLOGÍA DE LA INVESTIGACIÓN CUALITATIVA	13	59	\N	9	\N
462	URGENCIAS MÉDICAS	13	209	\N	11	\N
463	HEMATOLOGÍA	13	211	\N	11	\N
464	ADMINISTRACIÓN DE ORGANIZACIONES Y SERVICIOS DE SALUD	13	5	\N	11	\N
465	INGLÉS	13	216	\N	11	\N
466	UROLOGÍA	13	148	\N	11	\N
467	SALA DE CÓMPUTO	13	205	\N	11	\N
468	ENDOCRINOLOGÍA	13	217	\N	11	\N
469	INGLÉS	13	218	\N	11	\N
470	UROLOGÍA	13	197	\N	11	\N
471	ENDOCRINOLOGÍA	13	213	\N	11	\N
472	INGLÉS	13	219	\N	11	\N
473	SALA DE CÓMPUTO	13	199	\N	11	\N
474	ADMINISTRACIÓN DE ORGANIZACIONES Y SERVICIOS DE SALUD	13	36	\N	11	\N
475	OCUP. LE	14	220	\N	1	\N
476	INTERNADO	14	221	\N	1	\N
477	INGLÉS	14	222	\N	1	\N
478	INGLÉS	14	223	\N	1	\N
479	OCUP. LO	14	224	\N	1	\N
\.


--
-- Data for Name: notificaciones; Type: TABLE DATA; Schema: public; Owner: proj_user
--

COPY public.notificaciones (id, mensaje, leida, fecha_creacion, destinatario_rol, destinatario_id, tipo, referencia_id, referencia_tipo, carrera) FROM stdin;
4	El Jefe de Carrera de Licenciatura en Informática ha enviado los exámenes del grupo 306-B para revisión.	f	2026-01-22 17:42:38.007921	servicios_escolares	\N	envio_revision	59	grupo	Licenciatura en Informática
8	Revisión Aprobada para el grupo 106-A de Licenciatura en Informática.	f	2026-01-22 17:43:06.386033	jefe_carrera	\N	aprobacion	56	grupo	Licenciatura en Informática
9	Revisión Aprobada para el grupo 106-B de Licenciatura en Informática.	f	2026-01-22 17:43:06.386038	jefe_carrera	\N	aprobacion	57	grupo	Licenciatura en Informática
10	Revisión Aprobada para el grupo 306-A de Licenciatura en Informática.	f	2026-01-22 17:43:06.38604	jefe_carrera	\N	aprobacion	58	grupo	Licenciatura en Informática
11	Revisión Aprobada para el grupo 306-B de Licenciatura en Informática.	f	2026-01-22 17:43:06.386041	jefe_carrera	\N	aprobacion	59	grupo	Licenciatura en Informática
12	Revisión Aprobada para el grupo 506 de Licenciatura en Informática.	f	2026-01-22 17:43:06.386042	jefe_carrera	\N	aprobacion	60	grupo	Licenciatura en Informática
13	Revisión Aprobada para el grupo 706 de Licenciatura en Informática.	f	2026-01-22 17:43:06.386043	jefe_carrera	\N	aprobacion	61	grupo	Licenciatura en Informática
14	Revisión Aprobada para el grupo 906 de Licenciatura en Informática.	f	2026-01-22 17:43:06.386044	jefe_carrera	\N	aprobacion	62	grupo	Licenciatura en Informática
27	El Jefe de Carrera de Licenciatura en Medicina ha enviado los exámenes del grupo 114-B para revisión.	f	2026-01-22 18:06:41.077096	servicios_escolares	\N	envio_revision	16	grupo	Licenciatura en Medicina
28	El Jefe de Carrera de Licenciatura en Medicina ha enviado los exámenes del grupo 114-A para revisión.	f	2026-01-22 18:06:41.077097	servicios_escolares	\N	envio_revision	15	grupo	Licenciatura en Medicina
29	El Jefe de Carrera de Licenciatura en Medicina ha enviado los exámenes del grupo 914-A para revisión.	f	2026-01-22 18:06:41.077097	servicios_escolares	\N	envio_revision	26	grupo	Licenciatura en Medicina
30	El Jefe de Carrera de Licenciatura en Medicina ha enviado los exámenes del grupo 914-B para revisión.	f	2026-01-22 18:06:41.077098	servicios_escolares	\N	envio_revision	27	grupo	Licenciatura en Medicina
31	El Jefe de Carrera de Licenciatura en Medicina ha enviado los exámenes del grupo 514-C para revisión.	f	2026-01-22 18:06:41.077098	servicios_escolares	\N	envio_revision	23	grupo	Licenciatura en Medicina
32	Revisión Aprobada para el grupo 714-A de Licenciatura en Medicina.	f	2026-01-22 18:07:34.754041	jefe_carrera	\N	aprobacion	24	grupo	Licenciatura en Medicina
33	Revisión Aprobada para el grupo 314-B de Licenciatura en Medicina.	f	2026-01-22 18:07:34.75405	jefe_carrera	\N	aprobacion	19	grupo	Licenciatura en Medicina
34	Revisión Aprobada para el grupo 714-B de Licenciatura en Medicina.	f	2026-01-22 18:07:34.754052	jefe_carrera	\N	aprobacion	25	grupo	Licenciatura en Medicina
35	Revisión Aprobada para el grupo 1114-C de Licenciatura en Medicina.	f	2026-01-22 18:07:34.754054	jefe_carrera	\N	aprobacion	31	grupo	Licenciatura en Medicina
36	Revisión Aprobada para el grupo 1114-A de Licenciatura en Medicina.	f	2026-01-22 18:07:34.754055	jefe_carrera	\N	aprobacion	29	grupo	Licenciatura en Medicina
37	Revisión Aprobada para el grupo 1114-B de Licenciatura en Medicina.	f	2026-01-22 18:07:34.754057	jefe_carrera	\N	aprobacion	30	grupo	Licenciatura en Medicina
2	El Jefe de Carrera de Licenciatura en Informática ha enviado los exámenes del grupo 106-B para revisión.	t	2026-01-22 17:42:38.00792	servicios_escolares	\N	envio_revision	57	grupo	Licenciatura en Informática
3	El Jefe de Carrera de Licenciatura en Informática ha enviado los exámenes del grupo 306-A para revisión.	t	2026-01-22 17:42:38.007921	servicios_escolares	\N	envio_revision	58	grupo	Licenciatura en Informática
5	El Jefe de Carrera de Licenciatura en Informática ha enviado los exámenes del grupo 506 para revisión.	t	2026-01-22 17:42:38.007922	servicios_escolares	\N	envio_revision	60	grupo	Licenciatura en Informática
6	El Jefe de Carrera de Licenciatura en Informática ha enviado los exámenes del grupo 706 para revisión.	t	2026-01-22 17:42:38.007923	servicios_escolares	\N	envio_revision	61	grupo	Licenciatura en Informática
7	El Jefe de Carrera de Licenciatura en Informática ha enviado los exámenes del grupo 906 para revisión.	t	2026-01-22 17:42:38.007923	servicios_escolares	\N	envio_revision	62	grupo	Licenciatura en Informática
15	El Jefe de Carrera de Licenciatura en Medicina ha enviado los exámenes del grupo 714-A para revisión.	t	2026-01-22 18:06:41.077088	servicios_escolares	\N	envio_revision	24	grupo	Licenciatura en Medicina
16	El Jefe de Carrera de Licenciatura en Medicina ha enviado los exámenes del grupo 314-B para revisión.	t	2026-01-22 18:06:41.07709	servicios_escolares	\N	envio_revision	19	grupo	Licenciatura en Medicina
18	El Jefe de Carrera de Licenciatura en Medicina ha enviado los exámenes del grupo 1114-C para revisión.	t	2026-01-22 18:06:41.077091	servicios_escolares	\N	envio_revision	31	grupo	Licenciatura en Medicina
17	El Jefe de Carrera de Licenciatura en Medicina ha enviado los exámenes del grupo 714-B para revisión.	t	2026-01-22 18:06:41.077091	servicios_escolares	\N	envio_revision	25	grupo	Licenciatura en Medicina
19	El Jefe de Carrera de Licenciatura en Medicina ha enviado los exámenes del grupo 1114-A para revisión.	t	2026-01-22 18:06:41.077092	servicios_escolares	\N	envio_revision	29	grupo	Licenciatura en Medicina
20	El Jefe de Carrera de Licenciatura en Medicina ha enviado los exámenes del grupo 1114-B para revisión.	t	2026-01-22 18:06:41.077092	servicios_escolares	\N	envio_revision	30	grupo	Licenciatura en Medicina
21	El Jefe de Carrera de Licenciatura en Medicina ha enviado los exámenes del grupo 514-A para revisión.	t	2026-01-22 18:06:41.077093	servicios_escolares	\N	envio_revision	21	grupo	Licenciatura en Medicina
22	El Jefe de Carrera de Licenciatura en Medicina ha enviado los exámenes del grupo 114-C para revisión.	t	2026-01-22 18:06:41.077093	servicios_escolares	\N	envio_revision	17	grupo	Licenciatura en Medicina
23	El Jefe de Carrera de Licenciatura en Medicina ha enviado los exámenes del grupo 914-C para revisión.	t	2026-01-22 18:06:41.077094	servicios_escolares	\N	envio_revision	28	grupo	Licenciatura en Medicina
24	El Jefe de Carrera de Licenciatura en Medicina ha enviado los exámenes del grupo 514-B para revisión.	t	2026-01-22 18:06:41.077095	servicios_escolares	\N	envio_revision	22	grupo	Licenciatura en Medicina
25	El Jefe de Carrera de Licenciatura en Medicina ha enviado los exámenes del grupo 314-C para revisión.	t	2026-01-22 18:06:41.077095	servicios_escolares	\N	envio_revision	20	grupo	Licenciatura en Medicina
26	El Jefe de Carrera de Licenciatura en Medicina ha enviado los exámenes del grupo 314-A para revisión.	t	2026-01-22 18:06:41.077096	servicios_escolares	\N	envio_revision	18	grupo	Licenciatura en Medicina
38	Revisión Aprobada para el grupo 514-A de Licenciatura en Medicina.	f	2026-01-22 18:07:34.754059	jefe_carrera	\N	aprobacion	21	grupo	Licenciatura en Medicina
39	Revisión Aprobada para el grupo 114-C de Licenciatura en Medicina.	f	2026-01-22 18:07:34.75406	jefe_carrera	\N	aprobacion	17	grupo	Licenciatura en Medicina
40	Revisión Aprobada para el grupo 914-C de Licenciatura en Medicina.	f	2026-01-22 18:07:34.754061	jefe_carrera	\N	aprobacion	28	grupo	Licenciatura en Medicina
41	Revisión Aprobada para el grupo 514-B de Licenciatura en Medicina.	f	2026-01-22 18:07:34.754062	jefe_carrera	\N	aprobacion	22	grupo	Licenciatura en Medicina
42	Revisión Aprobada para el grupo 314-C de Licenciatura en Medicina.	f	2026-01-22 18:07:34.754063	jefe_carrera	\N	aprobacion	20	grupo	Licenciatura en Medicina
43	Revisión Aprobada para el grupo 314-A de Licenciatura en Medicina.	f	2026-01-22 18:07:34.754064	jefe_carrera	\N	aprobacion	18	grupo	Licenciatura en Medicina
44	Revisión Aprobada para el grupo 114-B de Licenciatura en Medicina.	f	2026-01-22 18:07:34.754065	jefe_carrera	\N	aprobacion	16	grupo	Licenciatura en Medicina
45	Revisión Aprobada para el grupo 114-A de Licenciatura en Medicina.	f	2026-01-22 18:07:34.754066	jefe_carrera	\N	aprobacion	15	grupo	Licenciatura en Medicina
46	Revisión Aprobada para el grupo 914-A de Licenciatura en Medicina.	f	2026-01-22 18:07:34.754066	jefe_carrera	\N	aprobacion	26	grupo	Licenciatura en Medicina
47	Revisión Aprobada para el grupo 914-B de Licenciatura en Medicina.	f	2026-01-22 18:07:34.754067	jefe_carrera	\N	aprobacion	27	grupo	Licenciatura en Medicina
48	Revisión Aprobada para el grupo 514-C de Licenciatura en Medicina.	f	2026-01-22 18:07:34.754068	jefe_carrera	\N	aprobacion	23	grupo	Licenciatura en Medicina
1	El Jefe de Carrera de Licenciatura en Informática ha enviado los exámenes del grupo 106-A para revisión.	t	2026-01-22 17:42:38.007918	servicios_escolares	\N	envio_revision	56	grupo	Licenciatura en Informática
49	El Jefe de Carrera de Licenciatura en Informática ha enviado los exámenes del grupo 106-A para revisión.	f	2026-01-23 18:08:37.826955	servicios_escolares	\N	envio_revision	56	grupo	Licenciatura en Informática
50	El Jefe de Carrera de Licenciatura en Informática ha enviado los exámenes del grupo 106-B para revisión.	f	2026-01-23 18:08:37.826957	servicios_escolares	\N	envio_revision	57	grupo	Licenciatura en Informática
51	El Jefe de Carrera de Licenciatura en Informática ha enviado los exámenes del grupo 306-A para revisión.	f	2026-01-23 18:08:37.826958	servicios_escolares	\N	envio_revision	58	grupo	Licenciatura en Informática
52	El Jefe de Carrera de Licenciatura en Informática ha enviado los exámenes del grupo 306-B para revisión.	f	2026-01-23 18:08:37.826958	servicios_escolares	\N	envio_revision	59	grupo	Licenciatura en Informática
53	El Jefe de Carrera de Licenciatura en Informática ha enviado los exámenes del grupo 506 para revisión.	f	2026-01-23 18:08:37.826959	servicios_escolares	\N	envio_revision	60	grupo	Licenciatura en Informática
54	El Jefe de Carrera de Licenciatura en Informática ha enviado los exámenes del grupo 706 para revisión.	f	2026-01-23 18:08:37.82696	servicios_escolares	\N	envio_revision	61	grupo	Licenciatura en Informática
55	El Jefe de Carrera de Licenciatura en Informática ha enviado los exámenes del grupo 906 para revisión.	f	2026-01-23 18:08:37.82696	servicios_escolares	\N	envio_revision	62	grupo	Licenciatura en Informática
56	Revisión Rechazada para el grupo 906 de Licenciatura en Informática.	f	2026-01-23 18:11:34.546331	jefe_carrera	\N	rechazo	62	grupo	Licenciatura en Informática
57	Revisión Aprobada para el grupo 106-A de Licenciatura en Informática.	f	2026-01-23 18:11:43.233641	jefe_carrera	\N	aprobacion	56	grupo	Licenciatura en Informática
58	Revisión Aprobada para el grupo 106-B de Licenciatura en Informática.	f	2026-01-23 18:11:43.233648	jefe_carrera	\N	aprobacion	57	grupo	Licenciatura en Informática
59	Revisión Aprobada para el grupo 306-A de Licenciatura en Informática.	f	2026-01-23 18:11:43.233649	jefe_carrera	\N	aprobacion	58	grupo	Licenciatura en Informática
60	Revisión Aprobada para el grupo 306-B de Licenciatura en Informática.	f	2026-01-23 18:11:43.23365	jefe_carrera	\N	aprobacion	59	grupo	Licenciatura en Informática
61	Revisión Aprobada para el grupo 506 de Licenciatura en Informática.	f	2026-01-23 18:11:43.233652	jefe_carrera	\N	aprobacion	60	grupo	Licenciatura en Informática
62	Revisión Aprobada para el grupo 706 de Licenciatura en Informática.	f	2026-01-23 18:11:43.233653	jefe_carrera	\N	aprobacion	61	grupo	Licenciatura en Informática
63	El Jefe de Carrera de LICENCIATURA EN INFORMÁTICA ha enviado los exámenes del grupo 906 para revisión.	f	2026-01-29 14:15:49.475947	servicios_escolares	\N	envio_revision	6	grupo	LICENCIATURA EN INFORMÁTICA
64	Revisión Aprobada para el grupo 906 de LICENCIATURA EN INFORMÁTICA.	f	2026-01-29 14:16:39.839051	jefe_carrera	\N	aprobacion	6	grupo	LICENCIATURA EN INFORMÁTICA
65	El Jefe de Carrera de LICENCIATURA EN INFORMÁTICA 2022 ha enviado los exámenes del grupo 106-A para revisión.	f	2026-01-29 14:17:50.188514	servicios_escolares	\N	envio_revision	2	grupo	LICENCIATURA EN INFORMÁTICA 2022
66	El Jefe de Carrera de LICENCIATURA EN INFORMÁTICA 2022 ha enviado los exámenes del grupo 106-B para revisión.	f	2026-01-29 14:17:50.188518	servicios_escolares	\N	envio_revision	3	grupo	LICENCIATURA EN INFORMÁTICA 2022
67	El Jefe de Carrera de LICENCIATURA EN INFORMÁTICA 2022 ha enviado los exámenes del grupo 506 para revisión.	f	2026-01-29 14:17:50.188519	servicios_escolares	\N	envio_revision	4	grupo	LICENCIATURA EN INFORMÁTICA 2022
68	El Jefe de Carrera de LICENCIATURA EN INFORMÁTICA 2022 ha enviado los exámenes del grupo 706 para revisión.	f	2026-01-29 14:17:50.18852	servicios_escolares	\N	envio_revision	5	grupo	LICENCIATURA EN INFORMÁTICA 2022
69	El Jefe de Carrera de LICENCIATURA EN INFORMÁTICA 2022 ha enviado los exámenes del grupo 306-B para revisión.	f	2026-01-29 14:17:50.188522	servicios_escolares	\N	envio_revision	37	grupo	LICENCIATURA EN INFORMÁTICA 2022
70	El Jefe de Carrera de LICENCIATURA EN INFORMÁTICA 2022 ha enviado los exámenes del grupo 306 para revisión.	f	2026-01-29 14:17:50.188523	servicios_escolares	\N	envio_revision	38	grupo	LICENCIATURA EN INFORMÁTICA 2022
71	Revisión Aprobada para el grupo 106-A de LICENCIATURA EN INFORMÁTICA 2022.	f	2026-01-29 14:18:04.359273	jefe_carrera	\N	aprobacion	2	grupo	LICENCIATURA EN INFORMÁTICA 2022
72	Revisión Aprobada para el grupo 106-B de LICENCIATURA EN INFORMÁTICA 2022.	f	2026-01-29 14:18:04.359278	jefe_carrera	\N	aprobacion	3	grupo	LICENCIATURA EN INFORMÁTICA 2022
73	Revisión Aprobada para el grupo 506 de LICENCIATURA EN INFORMÁTICA 2022.	f	2026-01-29 14:18:04.35928	jefe_carrera	\N	aprobacion	4	grupo	LICENCIATURA EN INFORMÁTICA 2022
74	Revisión Aprobada para el grupo 706 de LICENCIATURA EN INFORMÁTICA 2022.	f	2026-01-29 14:18:04.359281	jefe_carrera	\N	aprobacion	5	grupo	LICENCIATURA EN INFORMÁTICA 2022
75	Revisión Aprobada para el grupo 306-B de LICENCIATURA EN INFORMÁTICA 2022.	f	2026-01-29 14:18:04.359282	jefe_carrera	\N	aprobacion	37	grupo	LICENCIATURA EN INFORMÁTICA 2022
76	Revisión Aprobada para el grupo 306 de LICENCIATURA EN INFORMÁTICA 2022.	f	2026-01-29 14:18:04.359284	jefe_carrera	\N	aprobacion	38	grupo	LICENCIATURA EN INFORMÁTICA 2022
77	El Jefe de Carrera de LICENCIATURA EN INFORMÁTICA ha enviado los exámenes del grupo 106-A para revisión.	f	2026-01-29 20:02:05.530938	servicios_escolares	\N	envio_revision	2	grupo	LICENCIATURA EN INFORMÁTICA
78	El Jefe de Carrera de LICENCIATURA EN INFORMÁTICA ha enviado los exámenes del grupo 106-B para revisión.	f	2026-01-29 20:02:05.530942	servicios_escolares	\N	envio_revision	3	grupo	LICENCIATURA EN INFORMÁTICA
79	El Jefe de Carrera de LICENCIATURA EN INFORMÁTICA ha enviado los exámenes del grupo 506 para revisión.	f	2026-01-29 20:02:05.530943	servicios_escolares	\N	envio_revision	4	grupo	LICENCIATURA EN INFORMÁTICA
80	El Jefe de Carrera de LICENCIATURA EN INFORMÁTICA ha enviado los exámenes del grupo 706 para revisión.	f	2026-01-29 20:02:05.530945	servicios_escolares	\N	envio_revision	5	grupo	LICENCIATURA EN INFORMÁTICA
81	El Jefe de Carrera de LICENCIATURA EN INFORMÁTICA ha enviado los exámenes del grupo 906 para revisión.	f	2026-01-29 20:02:05.530946	servicios_escolares	\N	envio_revision	6	grupo	LICENCIATURA EN INFORMÁTICA
82	El Jefe de Carrera de LICENCIATURA EN INFORMÁTICA ha enviado los exámenes del grupo 306-B para revisión.	f	2026-01-29 20:02:05.530947	servicios_escolares	\N	envio_revision	37	grupo	LICENCIATURA EN INFORMÁTICA
83	El Jefe de Carrera de LICENCIATURA EN INFORMÁTICA ha enviado los exámenes del grupo 306 para revisión.	f	2026-01-29 20:02:05.530949	servicios_escolares	\N	envio_revision	38	grupo	LICENCIATURA EN INFORMÁTICA
84	Revisión Aprobada para el grupo 106-A de LICENCIATURA EN INFORMÁTICA.	f	2026-01-29 20:02:22.087886	jefe_carrera	\N	aprobacion	2	grupo	LICENCIATURA EN INFORMÁTICA
85	Revisión Aprobada para el grupo 106-B de LICENCIATURA EN INFORMÁTICA.	f	2026-01-29 20:02:22.087896	jefe_carrera	\N	aprobacion	3	grupo	LICENCIATURA EN INFORMÁTICA
86	Revisión Aprobada para el grupo 506 de LICENCIATURA EN INFORMÁTICA.	f	2026-01-29 20:02:22.087899	jefe_carrera	\N	aprobacion	4	grupo	LICENCIATURA EN INFORMÁTICA
87	Revisión Aprobada para el grupo 706 de LICENCIATURA EN INFORMÁTICA.	f	2026-01-29 20:02:22.087901	jefe_carrera	\N	aprobacion	5	grupo	LICENCIATURA EN INFORMÁTICA
88	Revisión Aprobada para el grupo 906 de LICENCIATURA EN INFORMÁTICA.	f	2026-01-29 20:02:22.087904	jefe_carrera	\N	aprobacion	6	grupo	LICENCIATURA EN INFORMÁTICA
89	Revisión Aprobada para el grupo 306-B de LICENCIATURA EN INFORMÁTICA.	f	2026-01-29 20:02:22.087906	jefe_carrera	\N	aprobacion	37	grupo	LICENCIATURA EN INFORMÁTICA
90	Revisión Aprobada para el grupo 306 de LICENCIATURA EN INFORMÁTICA.	f	2026-01-29 20:02:22.087909	jefe_carrera	\N	aprobacion	38	grupo	LICENCIATURA EN INFORMÁTICA
\.


--
-- Data for Name: profesores; Type: TABLE DATA; Schema: public; Owner: proj_user
--

COPY public.profesores (id, nombre, email) FROM stdin;
1	7 TÉCNICO SALA	\N
2	M.F. ARACELI LUZ ALVA RODRÍGUEZ MARTÍNEZ	\N
3	M.E.O. MARIANO OLVERA RAMÍREZ	\N
4	M.C.C. SILVIANA JUÁREZ CHALINI	\N
5	M.C.D.R.T. MONICA LETICIA MEJIA RAMIREZ	\N
6	M.E. JORGE LAMAS CARLOS	\N
7	M.I.S. FABIOLA CRESPO BARRIOS	\N
8	M.C. ENRIQUE GARCÍA REYES	\N
9	M.C.M. JESÚS PACHECO MENDOZA	\N
10	M.I.T.I. OSWALDO REY ÁVILA BARRÓN	\N
11	M.T.I.E IRVING ULISES HERNANDEZ MIGUEL	\N
12	S.O. TÉCNICO LAB	\N
13	M.T.E. EVERARDO DE JESÚS PACHECO ANTONIO	\N
14	SOFTWARE TÉCNICO LAB	\N
15	DR. ARISAÍ DARÍO BARRAGÁN LÓPEZ	\N
16	TECNOLOGÍAS WEB TÉCNICO LAB	\N
17	506 PROFESOR INGLÉS	\N
18	M.C.C. ELIEZER ALCAZAR SILVA	\N
19	DR. GERARDO ROBERTO ARAGÓN GONZÁLEZ	\N
20	306 PROFESOR INGLÉS	\N
21	DR. ERIC MELECIO CASTRO LEAL	\N
22	DR. ALEJANDRO JARILLO SILVA	\N
23	INFO TÉCNICO LABORATORIO	\N
24	903A PROFESOR INGLÉS	\N
25	M.C. MONICA PÉREZ MEZA	\N
26	2 TÉCNICO SALA	\N
27	DR. AMANDO ALEJANDRO RUÍZ FIGUEROA	\N
28	DR. ARTURO BENÍTEZ HERNÁNDEZ	\N
29	304 PROFESOR INGLÉS	\N
30	M.I.A. HADYA CONCEPCIÓN DÍAZ ORTÍZ	\N
31	M.G.P. RAFAEL RENTERÍA GAETA	\N
32	DR. PEDRO DURÁN FÉRMAN	\N
33	514B PROFESOR INGLÉS	\N
34	M.F. MÁXIMO JORGE SAAVEDRA GARCÍA	\N
35	704 PROFESOR INGLÉS	\N
36	M.C. MARCO ANTONIO SANTOS MARTÍNEZ	\N
37	1 TÉCNICO SALA	\N
38	904 PROFESOR INGLÉS	\N
39	DR. OSCAR DAVID VALENCIA LÓPEZ	\N
40	505 PROFESOR INGLÉS	\N
41	M.A.I.A ABISAÍ ARAGÓN CRUZ	\N
42	DR. MAURICIO SOSA MONTES	\N
43	M.P.P. JUAN CARLOS MATA ESPINOZA	\N
44	M.C.P. ROCÍO GUADALUPE BRAVO SALAZAR	\N
45	DRA. ALICIA MARTÍNEZ CRUZ	\N
46	705 PROFESOR INGLÉS	\N
47	M.C.D.R.T. LIZETH DANIZA GÓMEZ HERNÁNDEZ	\N
48	DRA. NINA MARTÍNEZ CRUZ	\N
49	DR. CHRISTIAN ARTURO CRUZ MELÉNDEZ	\N
50	DR. ROBERTO GARCÍA ZÚÑIGA	\N
51	M.C.S. ROSARIO MAYA LUCAS	\N
52	DR. DIEGO SOTO HERNÁNDEZ	\N
53	M.A.E. ENRIQUE MARTÍNEZ SÁNCHEZ	\N
54	403A PROFESOR INGLÉS	\N
55	M.C.P. JOANN ETIENNE OLIVIER PICARD	\N
56	305 PROFESOR INGLÉS	\N
57	MTRO. DANIEL ROBLES TORRES	\N
58	DRA. DEISY COROMOTO REBOLLEDO LÓPEZ	\N
59	DR. GUADALUPE GABRIEL DURÁN FÉRMAN	\N
60	DR. JOAQUÍN HUITZILIHUITL CAMACHO VERA	\N
61	P108 PROFESOR INGLÉS	\N
62	LGE 208 TÉCNICO SALA	\N
63	DRA. ARACELI HERNÁNDEZ FLORES	\N
64	611 SALA TESISTA	\N
65	DRA. MARÍA ALEJANDRA SÁNCHEZ BANDALA	\N
66	M.S.P. ERIC RAMIREZ BOHORQUEZ	\N
67	L.E. SILVIA MERCEDES COCA	\N
68	DR. ROBERTO ARIEL ABELDAÑO ZÚÑIGA	\N
69	LGE 209 TÉCNICO SALA	\N
70	M.S.P. MALENI RODRIGUEZ GARCÍA	\N
71	DR. HADY KEITA	\N
72	409 SALA TESISTA	\N
73	COMITÉ 209A TUTORIAL	\N
74	LGE 409 TÉCNICO SALA	\N
75	410 SALA TESISTA	\N
76	LGE 410 TÉCNICO SALA	\N
77	DRA. AIDEE CRUZ BARRAGÁN	\N
78	DR. JOSELITO FERNÁNDEZ TAPIA	\N
79	LGE 211 TÉCNICO SALA	\N
80	611 LABORATORIO GOBIERNO	\N
81	L.N. CÉSAR JUÁREZ DURÁN	\N
82	3 TÉCNICO SALA	\N
83	514A PROFESOR INGLÉS	\N
84	DR. JUAN CARLOS BARRAGÁN GÁLVEZ	\N
85	PSIC. ODALIS DANIELA FLORES BUSTAMANTE	\N
86	MÉD. MARCOS URIEL CUEVAS OLIVERA	\N
87	M.C. ANDREA ITAYETZZI ORTÍZ GARCÍA	\N
88	M.S.P. TEOFILA ENRIQUEZ ALMARAZ	\N
89	M.S.P. ADRIÁN GABRIEL DELGADO LARA	\N
90	L.N. YANNICK JOSÉ RUIZ RAMOS	\N
91	914B PROFESOR INGLÉS	\N
92	707A PROFESOR INGLÉS	\N
93	DRA. CLAUDIA VILLANUEVA CAÑONGO	\N
94	M.C.A. LAURA JOCELYN VALDEZ GUTIÉRREZ	\N
95	M.N.C. GRISELDA BELÉN AVENDAÑO RODRÍGUEZ	\N
96	4 TÉCNICO SALA	\N
97	M.C.A.C. JOSÉ ALBERTO CRUZ TOLENTINO	\N
98	907A PROFESOR INGLÉS	\N
99	DRA. FELÍCITAS ORTÍZ GARCÍA	\N
100	501 PROFESOR INGLÉS	\N
101	DR. OMAR ÁVILA FLORES	\N
102	M.P.E.M. EMANUEL LORENZO RAMÍREZ ARELLANES	\N
103	M.D.G.P.L. ELEAZAR BRENA GARCÍA	\N
104	701 PROFESOR INGLÉS	\N
105	214A PROFESOR INGLÉS	\N
106	408 COMITÉ TUTORIAL	\N
107	408 INVESTIGACIÓN	\N
108	M.C.B. ARACELI MENESES CORONA	\N
109	DRA. VICTORIA VERA PINEDA	\N
110	CPAT TÉCNICO SALA	\N
111	DR. EDGAR RODRIGO GUZMÁN BAUTISTA	\N
112	M.C.T.A. ILIANA VASQUEZ LARA	\N
113	MTRO. RAUL MISAEL CORTES OLIVERA	\N
114	M.C.I.B. ERICAY BERENICE MARTÍNEZ RAMOS	\N
115	DRA. CLAUDIA CHÁVEZ LÓPEZ	\N
116	E.A.P. JORGE CARLOS MOGUEL GAMBOA	\N
117	M.T.H.E.Q. MARGARITA SELENE ARAGÓN SIERRA	\N
118	L.E. ELISEO GABRIEL JIMÉNEZ CORTES	\N
119	L.E. JOSE BALTAZAR BALLESTEROS LOPEZ	\N
120	M.S.P. DIEGO ORTEGA PACHECO	\N
121	BIBLIO-SALA TÉCNICO	\N
122	L.O. YAMILE YOLOTZIN VASQUEZ RIOS	\N
123	9 TÉCNICO SALA	\N
124	MÉD. JENNIFER DE LA LUZ SANTOS SANTOS	\N
125	M.A.I.S. AMELIA ROSELIA JUÁREZ AGUDO	\N
126	L.O. JOCABET RAMIREZ GARCIA	\N
127	E.E.S.M.P. ISABEL SANTOS RUIZ	\N
128	11 TÉCNICO SALA	\N
129	L.O. ABIGAIL VASQUEZ MARTINEZ	\N
130	M.B.E. DIEGO SAIT CRUZ HERNANDEZ	\N
131	L.E. YAZMIN ACATLIXCO SEBASTIAN VENTURA	\N
132	8 TÉCNICO SALA	\N
133	E.E.S.M.P. DANIA VELASCO RAMÍREZ	\N
134	DR. HORACIO GONZÁLEZ PÉREZ	\N
135	10 TÉCNICO SALA	\N
136	L.O. ZOE MABEL MENDEZ CRUZ	\N
137	C.D. AMALINALLI BARON ZARAGOZA	\N
138	P313A PROFESOR INGLÉS	\N
139	MÉD. HANNALI VASQUEZ BOHORQUEZ	\N
140	C.D. LAURA ALEJANDRA MORA GONZALEZ	\N
141	P313B PROFESOR INGLÉS	\N
142	C.D. KATIA CECILIA GONZALEZ VAZQUEZ	\N
143	C.D. LUIS BERNARDO MARTÍNEZ MARTÍNEZ	\N
144	P313C PROFESOR INGLÉS	\N
145	C.D. ADRIANA RAQUEL CRUZ GARCIA	\N
146	313D PROFESOR INGLÉS	\N
147	C.D. JESUS CRUZ VELAZQUEZ	\N
148	MÉD. JOSÉ GUADALUPE REYES RAMÍREZ	\N
149	L.O. DAMARY LOPEZ REYES	\N
150	C.D. JONATHAN MARTINEZ CRUZ	\N
151	P513B PROFESOR INGLÉS	\N
152	P513C PROFESOR INGLÉS	\N
153	P513D PROFESOR INGLÉS	\N
154	813A PROFESOR INGLÉS	\N
155	713A PROFESOR INGLÉS	\N
156	ODONT. TÉCNICO SALA	\N
157	L.O. ELVIRA GLAFIRA JUAREZ AGUDO	\N
158	713B PROFESOR INGLÉS	\N
159	C.D. JAVIER LÓPEZ REYES	\N
160	C.D. MAURICIO GONZÁLEZ OSORIO	\N
161	E.O. GUADALUPE CARLOS OGARRIO RAMÍREZ	\N
162	M.C.E. IGNACIO GRAJALES ALONSO	\N
163	5 TÉCNICO SALA	\N
164	DRA. ROXANA NAYELI GUERRERO SOTELO	\N
165	M.E.D. VERÓNICA GARCÍA BRENA	\N
166	M.E. JOSÉ ALBERTO RAMIREZ RODRÍGUEZ	\N
167	M.C.E. DOUGLAS CRITTENDEN NANCE	\N
168	6 TÉCNICO SALA	\N
169	L.E. YARELY YANETH ZURITA LÓPEZ	\N
170	E.E.N. MARITZA NICOLÁS SANTIAGO	\N
171	L.E. ESDRAS ALMARAZ ALONSO	\N
172	M.C.C.A.R.B. GUILIBALDO GABRIEL ZURITA VÁSQUEZ	\N
173	E.E.P. ROSSELL PERLA STOCKETT HERNÁNDEZ	\N
174	303A PROFESOR INGLÉS	\N
175	M.C.E. LUIS MIGUEL MÁRQUEZ VALDEZ	\N
176	L.E. JOSE LUIS NUNEZ CASTILLO	\N
177	L.E. CARMELA CORTEZ GONSALEZ	\N
178	M.S.P. GLORIA VERÓNICA ALBA ALBA	\N
179	703A PROFESOR INGLÉS	\N
180	L.E. JERUSHA AZUCENA BUSTAMANTE RAMÍREZ	\N
181	303C PROFESOR INGLÉS	\N
182	M.R.N. PEDRO LUIS HERNÁNDEZ GONZÁLEZ	\N
183	L.E. GISELA MAYRA BUSTAMANTE RAMOS	\N
184	903C PROFESOR INGLÉS	\N
185	E.E.U. ROLANDO EMILIO MARTÍNEZ JUÁREZ	\N
186	503B PROFESOR INGLÉS	\N
187	MÉD. XOCHIQUETZALLI GARCÍA MENDOZA	\N
188	503C PROFESOR INGLÉS	\N
189	503D PROFESOR INGLÉS	\N
190	M.C.M. OSCAR CUAUHTÉMOC ESPERANZA CONTRERAS	\N
191	L.E. CHRISTIAN MARTÍNEZ HERNÁNDEZ	\N
192	703B PROFESOR INGLÉS	\N
193	703C PROFESOR INGLÉS	\N
194	M.E.S. ADRIANA ZÚÑIGA JIMÉNEZ	\N
195	M.R.N. LISBETH AMARO LÓPEZ	\N
196	314A PROFESOR INGLÉS	\N
197	MÉD. JASIBE IVETTE CRUZ VASQUEZ	\N
198	MÉD. EDGAR GARCIA CASAS	\N
199	CPAT2 TÉCNICO SALA	\N
200	M.S.P. JOSE LUIS ELIAZAR TORRALBA FLORES	\N
201	DR. ALEJANDRO FRANCISCO CRUZ	\N
202	M.P. TANIA LIZBETH HERNÁNDEZ CRUZ	\N
203	314B PROFESOR INGLÉS	\N
204	314C PROFESOR INGLÉS	\N
205	SC-CAD TÉCNICO SALA	\N
206	M.A.H.S.S. ERICA ROCÍO GASPAR SÁNCHEZ	\N
207	MÉD. ABIMAEL SALINAS VASQUEZ	\N
208	514C PROFESOR INGLÉS	\N
209	E.M.F. CONCEPCIÓN JULIÁN LÓPEZ	\N
210	714A PROFESOR INGLÉS	\N
211	M.S.P. PABLO CATANEO PÉREZ	\N
212	714B PROFESOR INGLÉS	\N
213	MÉD. CARLOS ARTURO SÁNCHEZ REYES	\N
214	914A PROFESOR INGLÉS	\N
215	914C PROFESOR INGLÉS	\N
216	1114A PROFESOR INGLÉS	\N
217	MÉD. GUADALUPE ITHALIVI OLIVERA DOMÍNGUEZ	\N
218	1114B PROFESOR INGLÉS	\N
219	1114C PROFESOR INGLÉS	\N
220	112B PROFESOR INGLÉS	\N
221	907B PROFESOR INGLÉS	\N
222	112C PROFESOR INGLÉS	\N
223	112A PROFESOR INGLÉS	\N
224	201 PROFESOR INGLÉS	\N
\.


--
-- Data for Name: tipos_examen; Type: TABLE DATA; Schema: public; Owner: proj_user
--

COPY public.tipos_examen (id, nombre, descripcion) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: proj_user
--

COPY public.users (id, username, hashed_password, role, email, carrera, profesor_id, is_active) FROM stdin;
1	admin	$2b$12$Dg4QaWqn3Qro3.dzTO7IEeZgL/198hMAVTlLxuoSc5SCWMiW2bF2G	administrador	admin@escuela.edu.mx	\N	\N	1
2	escolares	$2b$12$0.JKHHsjVSNT9OT9DAIfx.HXg152W5F8EqYRQuIuy/yCemYPvHblm	servicios_escolares	escolares@escuela.edu.mx	\N	\N	1
3	jefe_ciencias_empresariales	$2b$12$MiNFo9Vf0s30sQ3BeWrQFOkUaO8EMDRVql2m13i0HWG0nxktjLxte	jefe_carrera	jefe_ciencias_empresariales@escuela.edu.mx	04B	\N	1
4	jefe_informatica	$2b$12$DB.0ZyNlyVR7.7z1OEYfsu7iLtGSN31qIfshXncSimQvyPVh5X2ym	jefe_carrera	jefe_informatica@escuela.edu.mx	06B	\N	1
5	jefe_administracion_publica	$2b$12$0Li.WlxKcY1YMcZLuNPVC.d/ySI1OnWO5OfIlfBkyUMTztGOqWU6i	jefe_carrera	jefe_administracion_publica@escuela.edu.mx	05	\N	1
6	jefe_mtr_planeacion_estrategica_municipal	$2b$12$U34h.e6waUSxkU6b7Px1LuaHg3vkCF2StdQ1KO8VGGTay7Hpr5fxW	jefe_carrera	jefe_mtr_planeacion_estrategica_municipal@escuela.edu.mx	08C	\N	1
7	jefe_mtr_salud_publica	$2b$12$WOO5TEjRsqL7Q/Wdw.PbeuG80uJf5ObewcaSwOxff9hY9.shq.g.W	jefe_carrera	jefe_mtr_salud_publica@escuela.edu.mx	09	\N	1
8	jefe_mtr_gobierno_electronico	$2b$12$BxnQpRhyanLlPBNjYzLlnu1y5psWQX74LIPKV6/sxIdNzC38mwa5y	jefe_carrera	jefe_mtr_gobierno_electronico@escuela.edu.mx	10	\N	1
9	jefe_dr_gobierno_electronico	$2b$12$KvEfJYLwlHo55JLRj3xKZufh2urcSpz2n9B9Kh7.1Zr7SiUJCquM2	jefe_carrera	jefe_dr_gobierno_electronico@escuela.edu.mx	11	\N	1
10	jefe_nutricion	$2b$12$ETPX.wmNOOA5QDybYz.Ti.7VjKgkBSkzBOAOwcvssujKRUsQEOn1y	jefe_carrera	jefe_nutricion@escuela.edu.mx	07B	\N	1
11	jefe_administracion_municipal	$2b$12$Ssmf4y82lIVrhlCyLrnTPOqMa3wgWBvz91miUOkKHClR8AOnWkYCS	jefe_carrera	jefe_administracion_municipal@escuela.edu.mx	01B	\N	1
12	jefe_ciencias_biomedicas	$2b$12$mhx9G3VL.55vZQ1VTPNJYuQM9PJqTeYHL3LLcmG2GDTVMVbuzjPLK	jefe_carrera	jefe_ciencias_biomedicas@escuela.edu.mx	16A	\N	1
13	jefe_odontologia	$2b$12$IKCE4ZLDd1gjZ.f/Ko8edegAzU0JXW1/ak17NR3COfsyKYisqFDwu	jefe_carrera	jefe_odontologia@escuela.edu.mx	14	\N	1
14	jefe_enfermeria	$2b$12$qkzOBEB97HcubntUpwxF6../efxi4DMW.mq8DRSOZmT3SKJeR8DvK	jefe_carrera	jefe_enfermeria@escuela.edu.mx	03D	\N	1
15	jefe_medicina	$2b$12$WXzZjLWARRczkIECihOuuOqTucJfeWrNWKT4HCg8ASIsoeETEX8zK	jefe_carrera	jefe_medicina@escuela.edu.mx	15	\N	1
16	jefe_ingles	$2b$12$4VOhGEBdTDMcHzdS.ZG6Z.ojeDRUCzNDAkeTrWpxLjbyELrdeeKgO	jefe_carrera	jefe_ingles@escuela.edu.mx	12	\N	1
\.


--
-- Name: academias_id_seq; Type: SEQUENCE SET; Schema: public; Owner: proj_user
--

SELECT pg_catalog.setval('public.academias_id_seq', 1, false);


--
-- Name: aulas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: proj_user
--

SELECT pg_catalog.setval('public.aulas_id_seq', 150, true);


--
-- Name: carreras_id_seq; Type: SEQUENCE SET; Schema: public; Owner: proj_user
--

SELECT pg_catalog.setval('public.carreras_id_seq', 14, true);


--
-- Name: examenes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: proj_user
--

SELECT pg_catalog.setval('public.examenes_id_seq', 1, false);


--
-- Name: grupos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: proj_user
--

SELECT pg_catalog.setval('public.grupos_id_seq', 111, true);


--
-- Name: horarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: proj_user
--

SELECT pg_catalog.setval('public.horarios_id_seq', 3513, true);


--
-- Name: materias_id_seq; Type: SEQUENCE SET; Schema: public; Owner: proj_user
--

SELECT pg_catalog.setval('public.materias_id_seq', 479, true);


--
-- Name: notificaciones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: proj_user
--

SELECT pg_catalog.setval('public.notificaciones_id_seq', 90, true);


--
-- Name: profesores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: proj_user
--

SELECT pg_catalog.setval('public.profesores_id_seq', 224, true);


--
-- Name: tipos_examen_id_seq; Type: SEQUENCE SET; Schema: public; Owner: proj_user
--

SELECT pg_catalog.setval('public.tipos_examen_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: proj_user
--

SELECT pg_catalog.setval('public.users_id_seq', 16, true);


--
-- Name: academias academias_codigo_key; Type: CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.academias
    ADD CONSTRAINT academias_codigo_key UNIQUE (codigo);


--
-- Name: academias academias_pkey; Type: CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.academias
    ADD CONSTRAINT academias_pkey PRIMARY KEY (id);


--
-- Name: aulas aulas_pkey; Type: CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.aulas
    ADD CONSTRAINT aulas_pkey PRIMARY KEY (id);


--
-- Name: carreras carreras_codigo_key; Type: CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.carreras
    ADD CONSTRAINT carreras_codigo_key UNIQUE (codigo);


--
-- Name: carreras carreras_pkey; Type: CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.carreras
    ADD CONSTRAINT carreras_pkey PRIMARY KEY (id);


--
-- Name: examenes examenes_pkey; Type: CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.examenes
    ADD CONSTRAINT examenes_pkey PRIMARY KEY (id);


--
-- Name: grupos grupos_pkey; Type: CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.grupos
    ADD CONSTRAINT grupos_pkey PRIMARY KEY (id);


--
-- Name: horarios horarios_pkey; Type: CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.horarios
    ADD CONSTRAINT horarios_pkey PRIMARY KEY (id);


--
-- Name: materias materias_pkey; Type: CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.materias
    ADD CONSTRAINT materias_pkey PRIMARY KEY (id);


--
-- Name: notificaciones notificaciones_pkey; Type: CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.notificaciones
    ADD CONSTRAINT notificaciones_pkey PRIMARY KEY (id);


--
-- Name: profesores profesores_pkey; Type: CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.profesores
    ADD CONSTRAINT profesores_pkey PRIMARY KEY (id);


--
-- Name: tipos_examen tipos_examen_pkey; Type: CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.tipos_examen
    ADD CONSTRAINT tipos_examen_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: ix_academias_id; Type: INDEX; Schema: public; Owner: proj_user
--

CREATE INDEX ix_academias_id ON public.academias USING btree (id);


--
-- Name: ix_academias_nombre; Type: INDEX; Schema: public; Owner: proj_user
--

CREATE UNIQUE INDEX ix_academias_nombre ON public.academias USING btree (nombre);


--
-- Name: ix_aulas_id; Type: INDEX; Schema: public; Owner: proj_user
--

CREATE INDEX ix_aulas_id ON public.aulas USING btree (id);


--
-- Name: ix_aulas_nombre; Type: INDEX; Schema: public; Owner: proj_user
--

CREATE UNIQUE INDEX ix_aulas_nombre ON public.aulas USING btree (nombre);


--
-- Name: ix_carreras_id; Type: INDEX; Schema: public; Owner: proj_user
--

CREATE INDEX ix_carreras_id ON public.carreras USING btree (id);


--
-- Name: ix_carreras_nombre; Type: INDEX; Schema: public; Owner: proj_user
--

CREATE UNIQUE INDEX ix_carreras_nombre ON public.carreras USING btree (nombre);


--
-- Name: ix_examenes_id; Type: INDEX; Schema: public; Owner: proj_user
--

CREATE INDEX ix_examenes_id ON public.examenes USING btree (id);


--
-- Name: ix_grupos_id; Type: INDEX; Schema: public; Owner: proj_user
--

CREATE INDEX ix_grupos_id ON public.grupos USING btree (id);


--
-- Name: ix_horarios_id; Type: INDEX; Schema: public; Owner: proj_user
--

CREATE INDEX ix_horarios_id ON public.horarios USING btree (id);


--
-- Name: ix_materias_id; Type: INDEX; Schema: public; Owner: proj_user
--

CREATE INDEX ix_materias_id ON public.materias USING btree (id);


--
-- Name: ix_notificaciones_id; Type: INDEX; Schema: public; Owner: proj_user
--

CREATE INDEX ix_notificaciones_id ON public.notificaciones USING btree (id);


--
-- Name: ix_profesores_email; Type: INDEX; Schema: public; Owner: proj_user
--

CREATE UNIQUE INDEX ix_profesores_email ON public.profesores USING btree (email);


--
-- Name: ix_profesores_id; Type: INDEX; Schema: public; Owner: proj_user
--

CREATE INDEX ix_profesores_id ON public.profesores USING btree (id);


--
-- Name: ix_profesores_nombre; Type: INDEX; Schema: public; Owner: proj_user
--

CREATE INDEX ix_profesores_nombre ON public.profesores USING btree (nombre);


--
-- Name: ix_tipos_examen_id; Type: INDEX; Schema: public; Owner: proj_user
--

CREATE INDEX ix_tipos_examen_id ON public.tipos_examen USING btree (id);


--
-- Name: ix_tipos_examen_nombre; Type: INDEX; Schema: public; Owner: proj_user
--

CREATE UNIQUE INDEX ix_tipos_examen_nombre ON public.tipos_examen USING btree (nombre);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: proj_user
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: ix_users_id; Type: INDEX; Schema: public; Owner: proj_user
--

CREATE INDEX ix_users_id ON public.users USING btree (id);


--
-- Name: ix_users_username; Type: INDEX; Schema: public; Owner: proj_user
--

CREATE UNIQUE INDEX ix_users_username ON public.users USING btree (username);


--
-- Name: examenes examenes_academia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.examenes
    ADD CONSTRAINT examenes_academia_id_fkey FOREIGN KEY (academia_id) REFERENCES public.academias(id);


--
-- Name: examenes examenes_aplicador_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.examenes
    ADD CONSTRAINT examenes_aplicador_id_fkey FOREIGN KEY (aplicador_id) REFERENCES public.profesores(id);


--
-- Name: examenes examenes_aula_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.examenes
    ADD CONSTRAINT examenes_aula_id_fkey FOREIGN KEY (aula_id) REFERENCES public.aulas(id);


--
-- Name: examenes examenes_grupo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.examenes
    ADD CONSTRAINT examenes_grupo_id_fkey FOREIGN KEY (grupo_id) REFERENCES public.grupos(id);


--
-- Name: examenes examenes_materia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.examenes
    ADD CONSTRAINT examenes_materia_id_fkey FOREIGN KEY (materia_id) REFERENCES public.materias(id);


--
-- Name: examenes examenes_sinodal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.examenes
    ADD CONSTRAINT examenes_sinodal_id_fkey FOREIGN KEY (sinodal_id) REFERENCES public.profesores(id);


--
-- Name: grupos grupos_carrera_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.grupos
    ADD CONSTRAINT grupos_carrera_id_fkey FOREIGN KEY (carrera_id) REFERENCES public.carreras(id);


--
-- Name: horarios horarios_aula_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.horarios
    ADD CONSTRAINT horarios_aula_id_fkey FOREIGN KEY (aula_id) REFERENCES public.aulas(id);


--
-- Name: horarios horarios_grupo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.horarios
    ADD CONSTRAINT horarios_grupo_id_fkey FOREIGN KEY (grupo_id) REFERENCES public.grupos(id);


--
-- Name: horarios horarios_materia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.horarios
    ADD CONSTRAINT horarios_materia_id_fkey FOREIGN KEY (materia_id) REFERENCES public.materias(id);


--
-- Name: materias materias_academia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.materias
    ADD CONSTRAINT materias_academia_id_fkey FOREIGN KEY (academia_id) REFERENCES public.academias(id);


--
-- Name: materias materias_carrera_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.materias
    ADD CONSTRAINT materias_carrera_id_fkey FOREIGN KEY (carrera_id) REFERENCES public.carreras(id);


--
-- Name: materias materias_profesor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.materias
    ADD CONSTRAINT materias_profesor_id_fkey FOREIGN KEY (profesor_id) REFERENCES public.profesores(id);


--
-- Name: materias materias_sinodal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: proj_user
--

ALTER TABLE ONLY public.materias
    ADD CONSTRAINT materias_sinodal_id_fkey FOREIGN KEY (sinodal_id) REFERENCES public.profesores(id);


--
-- PostgreSQL database dump complete
--

\unrestrict ShPxjPC48wfBB8Hglm1C6r9f5pGtNiuqDOQO4b2hCYr1x2Ry2F3eZTqPgLYDVEy

