--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 10.0

-- Started on 2017-11-01 23:29:44

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 1 (class 3079 OID 12387)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2342 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 634 (class 1247 OID 24724)
-- Name: assist_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE assist_type AS ENUM (
    'first',
    'second'
);


ALTER TYPE assist_type OWNER TO postgres;

--
-- TOC entry 640 (class 1247 OID 24858)
-- Name: game_finished_in; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE game_finished_in AS ENUM (
    'R',
    'OT',
    'SO'
);


ALTER TYPE game_finished_in OWNER TO postgres;

--
-- TOC entry 637 (class 1247 OID 24730)
-- Name: player_position; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE player_position AS ENUM (
    'G',
    'D',
    'F'
);


ALTER TYPE player_position OWNER TO postgres;

--
-- TOC entry 631 (class 1247 OID 24715)
-- Name: shot_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE shot_type AS ENUM (
    'backhand',
    'wrist',
    'slap',
    'tip-in'
);


ALTER TYPE shot_type OWNER TO postgres;

--
-- TOC entry 577 (class 1247 OID 24608)
-- Name: strength; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE strength AS ENUM (
    'EV',
    'PP',
    'SH',
    ''
);


ALTER TYPE strength OWNER TO postgres;

--
-- TOC entry 647 (class 1247 OID 32780)
-- Name: zone; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE zone AS ENUM (
    'Def. Zone',
    'Off. Zone',
    'Neu. Zone'
);


ALTER TYPE zone OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 188 (class 1259 OID 24628)
-- Name: assist; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE assist (
    id integer NOT NULL,
    player_id smallint NOT NULL,
    team_id text NOT NULL,
    type assist_type NOT NULL,
    play_id integer NOT NULL
);


ALTER TABLE assist OWNER TO postgres;

--
-- TOC entry 193 (class 1259 OID 24665)
-- Name: block; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE block (
    id integer NOT NULL,
    player_who_blocked_id smallint NOT NULL,
    player_got_blocked_id smallint NOT NULL,
    blocked_team_id text NOT NULL,
    blocking_team_id text NOT NULL,
    play_id integer NOT NULL,
    shot_type shot_type NOT NULL
);


ALTER TABLE block OWNER TO postgres;

--
-- TOC entry 190 (class 1259 OID 24641)
-- Name: faceoff; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE faceoff (
    id integer NOT NULL,
    player1_id smallint NOT NULL,
    player2_id smallint NOT NULL,
    winning_team_id text NOT NULL,
    losing_team_id text NOT NULL,
    play_id integer NOT NULL
);


ALTER TABLE faceoff OWNER TO postgres;

--
-- TOC entry 185 (class 1259 OID 16746)
-- Name: game; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE game (
    id integer NOT NULL,
    home_team_id text NOT NULL,
    away_team_id text NOT NULL,
    home_score smallint NOT NULL,
    away_score smallint NOT NULL,
    stage text NOT NULL,
    date date NOT NULL,
    finished_in game_finished_in NOT NULL,
    season smallint NOT NULL
);


ALTER TABLE game OWNER TO postgres;

--
-- TOC entry 196 (class 1259 OID 24690)
-- Name: giveaway; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE giveaway (
    id integer NOT NULL,
    player_id smallint NOT NULL,
    team_id text NOT NULL,
    play_id integer NOT NULL
);


ALTER TABLE giveaway OWNER TO postgres;

--
-- TOC entry 187 (class 1259 OID 24620)
-- Name: goal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE goal (
    id integer NOT NULL,
    player_id smallint NOT NULL,
    distance smallint NOT NULL,
    team_id text NOT NULL,
    shot_type shot_type NOT NULL,
    play_id integer NOT NULL
);


ALTER TABLE goal OWNER TO postgres;

--
-- TOC entry 191 (class 1259 OID 24649)
-- Name: hit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE hit (
    id integer NOT NULL,
    hitted_id smallint NOT NULL,
    hitter_id smallint NOT NULL,
    hitter_team_id text NOT NULL,
    hitted_team_id text NOT NULL,
    play_id integer NOT NULL
);


ALTER TABLE hit OWNER TO postgres;

--
-- TOC entry 194 (class 1259 OID 24673)
-- Name: miss; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE miss (
    id integer NOT NULL,
    player_id smallint NOT NULL,
    distance smallint NOT NULL,
    team_id text NOT NULL,
    shot_type shot_type NOT NULL,
    play_id integer NOT NULL
);


ALTER TABLE miss OWNER TO postgres;

--
-- TOC entry 189 (class 1259 OID 24636)
-- Name: on_ice; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE on_ice (
    id integer NOT NULL,
    team_id text NOT NULL,
    play_id integer NOT NULL,
    "position" player_position NOT NULL,
    player_id integer NOT NULL,
    number smallint NOT NULL
);


ALTER TABLE on_ice OWNER TO postgres;

--
-- TOC entry 195 (class 1259 OID 24681)
-- Name: penalty; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE penalty (
    id integer NOT NULL,
    length smallint NOT NULL,
    player_id smallint NOT NULL,
    reason text NOT NULL,
    team_id text NOT NULL,
    play_id integer NOT NULL
);


ALTER TABLE penalty OWNER TO postgres;

--
-- TOC entry 199 (class 1259 OID 32768)
-- Name: play; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE play (
    id bigint NOT NULL,
    game_id integer NOT NULL,
    period smallint NOT NULL,
    "time" time without time zone NOT NULL,
    in_game_id smallint NOT NULL,
    event_type text NOT NULL,
    strength text
);


ALTER TABLE play OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 32859)
-- Name: play_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE play_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE play_id_seq OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 32856)
-- Name: player_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE player_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE player_id_seq OWNER TO postgres;

--
-- TOC entry 198 (class 1259 OID 24706)
-- Name: player; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE player (
    id smallint DEFAULT nextval('player_id_seq'::regclass) NOT NULL,
    name text NOT NULL,
    actual_team_id text NOT NULL,
    "position" player_position NOT NULL
);


ALTER TABLE player OWNER TO postgres;

--
-- TOC entry 192 (class 1259 OID 24657)
-- Name: shot; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE shot (
    id integer NOT NULL,
    player_id smallint NOT NULL,
    distance smallint NOT NULL,
    shot_type shot_type NOT NULL,
    team_id text NOT NULL,
    play_id integer NOT NULL
);


ALTER TABLE shot OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 24698)
-- Name: start_stop; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE start_stop (
    id integer NOT NULL,
    what text NOT NULL,
    play_id integer NOT NULL
);


ALTER TABLE start_stop OWNER TO postgres;

--
-- TOC entry 186 (class 1259 OID 16749)
-- Name: team; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE team (
    id text NOT NULL,
    full_name text NOT NULL,
    full_name_big text
);


ALTER TABLE team OWNER TO postgres;

--
-- TOC entry 2322 (class 0 OID 24628)
-- Dependencies: 188
-- Data for Name: assist; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY assist (id, player_id, team_id, type, play_id) FROM stdin;
\.


--
-- TOC entry 2327 (class 0 OID 24665)
-- Dependencies: 193
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY block (id, player_who_blocked_id, player_got_blocked_id, blocked_team_id, blocking_team_id, play_id, shot_type) FROM stdin;
\.


--
-- TOC entry 2324 (class 0 OID 24641)
-- Dependencies: 190
-- Data for Name: faceoff; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY faceoff (id, player1_id, player2_id, winning_team_id, losing_team_id, play_id) FROM stdin;
\.


--
-- TOC entry 2319 (class 0 OID 16746)
-- Dependencies: 185
-- Data for Name: game; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY game (id, home_team_id, away_team_id, home_score, away_score, stage, date, finished_in, season) FROM stdin;
100000411	PIT	CAR	5	3	Stanley Cup Final	2017-05-29	R	2016
\.


--
-- TOC entry 2330 (class 0 OID 24690)
-- Dependencies: 196
-- Data for Name: giveaway; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY giveaway (id, player_id, team_id, play_id) FROM stdin;
\.


--
-- TOC entry 2321 (class 0 OID 24620)
-- Dependencies: 187
-- Data for Name: goal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY goal (id, player_id, distance, team_id, shot_type, play_id) FROM stdin;
\.


--
-- TOC entry 2325 (class 0 OID 24649)
-- Dependencies: 191
-- Data for Name: hit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY hit (id, hitted_id, hitter_id, hitter_team_id, hitted_team_id, play_id) FROM stdin;
\.


--
-- TOC entry 2328 (class 0 OID 24673)
-- Dependencies: 194
-- Data for Name: miss; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY miss (id, player_id, distance, team_id, shot_type, play_id) FROM stdin;
\.


--
-- TOC entry 2323 (class 0 OID 24636)
-- Dependencies: 189
-- Data for Name: on_ice; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY on_ice (id, team_id, play_id, "position", player_id, number) FROM stdin;
\.


--
-- TOC entry 2329 (class 0 OID 24681)
-- Dependencies: 195
-- Data for Name: penalty; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY penalty (id, length, player_id, reason, team_id, play_id) FROM stdin;
\.


--
-- TOC entry 2333 (class 0 OID 32768)
-- Dependencies: 199
-- Data for Name: play; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY play (id, game_id, period, "time", in_game_id, event_type, strength) FROM stdin;
1000004110001	100000411	1	00:00:00	1	PSTR	 
1000004110002	100000411	1	00:00:00	2	FAC	EV
1000004110003	100000411	1	00:00:11	3	HIT	EV
1000004110004	100000411	1	00:00:25	4	SHOT	EV
1000004110005	100000411	1	00:01:03	5	HIT	EV
1000004110006	100000411	1	00:01:24	6	SHOT	EV
1000004110007	100000411	1	00:01:25	7	STOP	 
1000004110008	100000411	1	00:01:25	8	FAC	EV
1000004110009	100000411	1	00:02:02	9	MISS	EV
10000041100010	100000411	1	00:02:09	10	SHOT	EV
10000041100011	100000411	1	00:02:46	11	HIT	EV
10000041100012	100000411	1	00:03:02	12	SHOT	EV
10000041100013	100000411	1	00:03:03	13	STOP	 
10000041100014	100000411	1	00:03:03	14	FAC	EV
10000041100015	100000411	1	00:03:18	15	GIVE	EV
10000041100016	100000411	1	00:03:22	16	HIT	EV
10000041100017	100000411	1	00:03:26	17	HIT	EV
10000041100018	100000411	1	00:03:41	18	STOP	 
10000041100019	100000411	1	00:03:41	19	FAC	EV
10000041100020	100000411	1	00:03:46	20	MISS	EV
10000041100021	100000411	1	00:03:55	21	HIT	EV
10000041100022	100000411	1	00:04:09	22	HIT	EV
10000041100023	100000411	1	00:04:12	23	SHOT	EV
10000041100024	100000411	1	00:04:14	24	HIT	EV
10000041100025	100000411	1	00:04:15	25	HIT	EV
10000041100026	100000411	1	00:04:36	26	HIT	EV
10000041100027	100000411	1	00:04:43	27	BLOCK	EV
10000041100028	100000411	1	00:04:51	28	HIT	EV
10000041100029	100000411	1	00:05:21	29	HIT	EV
10000041100030	100000411	1	00:05:41	30	BLOCK	EV
10000041100031	100000411	1	00:05:42	31	STOP	 
10000041100032	100000411	1	00:05:42	32	FAC	EV
10000041100033	100000411	1	00:05:59	33	STOP	 
10000041100034	100000411	1	00:05:59	34	FAC	EV
10000041100035	100000411	1	00:06:06	35	STOP	 
10000041100036	100000411	1	00:06:06	36	FAC	EV
10000041100037	100000411	1	00:06:17	37	STOP	 
10000041100038	100000411	1	00:06:17	38	FAC	EV
10000041100039	100000411	1	00:06:29	39	HIT	EV
10000041100040	100000411	1	00:06:32	40	STOP	 
10000041100041	100000411	1	00:06:32	41	FAC	EV
10000041100042	100000411	1	00:06:46	42	HIT	EV
10000041100043	100000411	1	00:06:58	43	CHL	EV
10000041100044	100000411	1	00:06:58	44	FAC	EV
10000041100045	100000411	1	00:07:06	45	SHOT	EV
10000041100046	100000411	1	00:07:08	46	STOP	 
10000041100047	100000411	1	00:07:11	47	STOP	 
10000041100048	100000411	1	00:07:11	48	FAC	EV
10000041100049	100000411	1	00:07:33	49	STOP	 
10000041100050	100000411	1	00:07:40	50	STOP	 
10000041100051	100000411	1	00:07:40	51	FAC	EV
10000041100052	100000411	1	00:08:41	52	SHOT	EV
10000041100053	100000411	1	00:08:42	53	STOP	 
10000041100054	100000411	1	00:08:42	54	FAC	EV
10000041100055	100000411	1	00:10:15	55	SHOT	EV
10000041100056	100000411	1	00:10:42	56	HIT	EV
10000041100057	100000411	1	00:10:59	57	HIT	EV
10000041100058	100000411	1	00:11:23	58	BLOCK	EV
10000041100059	100000411	1	00:11:26	59	HIT	EV
10000041100060	100000411	1	00:11:29	60	HIT	EV
10000041100061	100000411	1	00:11:36	61	BLOCK	EV
10000041100062	100000411	1	00:12:06	62	HIT	EV
10000041100063	100000411	1	00:12:09	63	SHOT	EV
10000041100064	100000411	1	00:12:11	64	STOP	 
10000041100065	100000411	1	00:12:11	65	FAC	EV
10000041100066	100000411	1	00:12:32	66	SHOT	EV
10000041100067	100000411	1	00:12:41	67	SHOT	EV
10000041100068	100000411	1	00:12:46	68	SHOT	EV
10000041100069	100000411	1	00:13:10	69	HIT	EV
10000041100070	100000411	1	00:13:21	70	HIT	EV
10000041100071	100000411	1	00:13:42	71	HIT	EV
10000041100072	100000411	1	00:13:50	72	PENL	EV
10000041100073	100000411	1	00:13:50	73	PENL	EV
10000041100074	100000411	1	00:13:50	74	FAC	SH
10000041100075	100000411	1	00:15:03	75	TAKE	SH
10000041100076	100000411	1	00:15:26	76	HIT	PP
10000041100077	100000411	1	00:15:32	77	GOAL	PP
10000041100078	100000411	1	00:15:32	78	FAC	PP
10000041100079	100000411	1	00:16:12	79	STOP	 
10000041100080	100000411	1	00:16:12	80	FAC	EV
10000041100081	100000411	1	00:16:18	81	STOP	 
10000041100082	100000411	1	00:16:18	82	FAC	EV
10000041100083	100000411	1	00:16:25	83	SHOT	EV
10000041100084	100000411	1	00:16:33	84	GIVE	EV
10000041100085	100000411	1	00:16:37	85	GOAL	EV
10000041100086	100000411	1	00:16:37	86	FAC	EV
10000041100087	100000411	1	00:16:47	87	STOP	 
10000041100088	100000411	1	00:16:47	88	FAC	EV
10000041100089	100000411	1	00:16:52	89	HIT	EV
10000041100090	100000411	1	00:17:02	90	HIT	EV
10000041100091	100000411	1	00:17:10	91	SHOT	EV
10000041100092	100000411	1	00:17:28	92	STOP	 
10000041100093	100000411	1	00:17:28	93	FAC	EV
10000041100094	100000411	1	00:17:34	94	SHOT	EV
10000041100095	100000411	1	00:17:35	95	STOP	 
10000041100096	100000411	1	00:17:35	96	FAC	EV
10000041100097	100000411	1	00:17:45	97	GIVE	EV
10000041100098	100000411	1	00:17:51	98	HIT	EV
10000041100099	100000411	1	00:17:55	99	STOP	 
100000411000100	100000411	1	00:17:55	100	FAC	EV
100000411000101	100000411	1	00:18:07	101	HIT	EV
100000411000102	100000411	1	00:18:29	102	HIT	EV
100000411000103	100000411	1	00:18:43	103	HIT	EV
100000411000104	100000411	1	00:19:27	104	TAKE	EV
100000411000105	100000411	1	00:19:34	105	SHOT	EV
100000411000106	100000411	1	00:19:43	106	GOAL	EV
100000411000107	100000411	1	00:19:43	107	FAC	EV
100000411000108	100000411	1	00:20:00	108	PEND	 
100000411000109	100000411	2	00:00:00	109	PSTR	 
100000411000110	100000411	2	00:00:00	110	FAC	EV
100000411000111	100000411	2	00:00:19	111	HIT	EV
100000411000112	100000411	2	00:01:11	112	TAKE	EV
100000411000113	100000411	2	00:01:16	113	BLOCK	EV
100000411000114	100000411	2	00:01:40	114	HIT	EV
100000411000115	100000411	2	00:02:00	115	HIT	EV
100000411000116	100000411	2	00:02:02	116	STOP	 
100000411000117	100000411	2	00:02:02	117	FAC	EV
100000411000118	100000411	2	00:02:12	118	HIT	EV
100000411000119	100000411	2	00:02:17	119	HIT	EV
100000411000120	100000411	2	00:02:46	120	MISS	EV
100000411000121	100000411	2	00:02:49	121	STOP	 
100000411000122	100000411	2	00:02:49	122	FAC	EV
100000411000123	100000411	2	00:03:09	123	MISS	EV
100000411000124	100000411	2	00:03:15	124	TAKE	EV
100000411000125	100000411	2	00:03:20	125	STOP	 
100000411000126	100000411	2	00:03:20	126	FAC	EV
100000411000127	100000411	2	00:03:25	127	MISS	EV
100000411000128	100000411	2	00:03:43	128	PENL	EV
100000411000129	100000411	2	00:03:43	129	FAC	SH
100000411000130	100000411	2	00:03:59	130	HIT	SH
100000411000131	100000411	2	00:04:42	131	MISS	PP
100000411000132	100000411	2	00:05:21	132	TAKE	SH
100000411000133	100000411	2	00:06:03	133	HIT	EV
100000411000134	100000411	2	00:06:22	134	HIT	EV
100000411000135	100000411	2	00:06:39	135	PENL	EV
100000411000136	100000411	2	00:06:39	136	STOP	 
100000411000137	100000411	2	00:06:39	137	FAC	PP
100000411000138	100000411	2	00:07:34	138	MISS	PP
100000411000139	100000411	2	00:07:41	139	SHOT	PP
100000411000140	100000411	2	00:08:21	140	GOAL	PP
100000411000141	100000411	2	00:08:21	141	FAC	EV
100000411000142	100000411	2	00:08:35	142	HIT	EV
100000411000143	100000411	2	00:09:18	143	STOP	 
100000411000144	100000411	2	00:09:18	144	FAC	EV
100000411000145	100000411	2	00:09:43	145	TAKE	EV
100000411000146	100000411	2	00:09:53	146	STOP	 
100000411000147	100000411	2	00:09:53	147	FAC	EV
100000411000148	100000411	2	00:10:10	148	HIT	EV
100000411000149	100000411	2	00:10:19	149	BLOCK	EV
100000411000150	100000411	2	00:10:29	150	SHOT	EV
100000411000151	100000411	2	00:11:01	151	HIT	EV
100000411000152	100000411	2	00:11:10	152	TAKE	EV
100000411000153	100000411	2	00:11:31	153	HIT	EV
100000411000154	100000411	2	00:11:39	154	BLOCK	EV
100000411000155	100000411	2	00:11:40	155	STOP	 
100000411000156	100000411	2	00:11:40	156	FAC	EV
100000411000157	100000411	2	00:11:45	157	BLOCK	EV
100000411000158	100000411	2	00:11:54	158	HIT	EV
100000411000159	100000411	2	00:12:04	159	STOP	 
100000411000160	100000411	2	00:12:04	160	FAC	EV
100000411000161	100000411	2	00:12:10	161	TAKE	EV
100000411000162	100000411	2	00:12:17	162	HIT	EV
100000411000163	100000411	2	00:12:28	163	SHOT	EV
100000411000164	100000411	2	00:12:29	164	BLOCK	EV
100000411000165	100000411	2	00:12:34	165	BLOCK	EV
100000411000166	100000411	2	00:12:36	166	STOP	 
100000411000167	100000411	2	00:12:36	167	FAC	EV
100000411000168	100000411	2	00:12:44	168	TAKE	EV
100000411000169	100000411	2	00:12:49	169	HIT	EV
100000411000170	100000411	2	00:12:56	170	SHOT	EV
100000411000171	100000411	2	00:13:20	171	GIVE	EV
100000411000172	100000411	2	00:13:20	172	HIT	EV
100000411000173	100000411	2	00:13:24	173	SHOT	EV
100000411000174	100000411	2	00:13:51	174	TAKE	EV
100000411000175	100000411	2	00:14:08	175	SHOT	EV
100000411000176	100000411	2	00:14:09	176	STOP	 
100000411000177	100000411	2	00:14:09	177	FAC	EV
100000411000178	100000411	2	00:14:18	178	MISS	EV
100000411000179	100000411	2	00:14:19	179	STOP	 
100000411000180	100000411	2	00:14:19	180	MISS	EV
100000411000181	100000411	2	00:14:19	181	FAC	EV
100000411000182	100000411	2	00:14:25	182	BLOCK	EV
100000411000183	100000411	2	00:14:25	183	STOP	 
100000411000184	100000411	2	00:14:25	184	FAC	EV
100000411000185	100000411	2	00:14:41	185	BLOCK	EV
100000411000186	100000411	2	00:14:42	186	STOP	 
100000411000187	100000411	2	00:14:42	187	FAC	EV
100000411000188	100000411	2	00:15:47	188	GIVE	EV
100000411000189	100000411	2	00:15:49	189	SHOT	EV
100000411000190	100000411	2	00:15:59	190	BLOCK	EV
100000411000191	100000411	2	00:16:10	191	STOP	 
100000411000192	100000411	2	00:16:10	192	FAC	EV
100000411000193	100000411	2	00:16:18	193	GIVE	EV
100000411000194	100000411	2	00:16:58	194	BLOCK	EV
100000411000195	100000411	2	00:17:34	195	GIVE	EV
100000411000196	100000411	2	00:17:51	196	HIT	EV
100000411000197	100000411	2	00:17:59	197	SHOT	EV
100000411000198	100000411	2	00:18:12	198	MISS	EV
100000411000199	100000411	2	00:19:58	199	HIT	EV
100000411000200	100000411	2	00:20:00	200	PEND	 
100000411000201	100000411	3	00:00:00	201	PSTR	 
100000411000202	100000411	3	00:00:00	202	FAC	EV
100000411000203	100000411	3	00:00:27	203	GIVE	EV
100000411000204	100000411	3	00:00:34	204	BLOCK	EV
100000411000205	100000411	3	00:00:35	205	STOP	 
100000411000206	100000411	3	00:00:35	206	FAC	EV
100000411000207	100000411	3	00:00:56	207	STOP	 
100000411000208	100000411	3	00:00:56	208	FAC	EV
100000411000209	100000411	3	00:01:17	209	SHOT	EV
100000411000210	100000411	3	00:01:40	210	HIT	EV
100000411000211	100000411	3	00:02:02	211	BLOCK	EV
100000411000212	100000411	3	00:02:22	212	HIT	EV
100000411000213	100000411	3	00:02:30	213	HIT	EV
100000411000214	100000411	3	00:02:39	214	STOP	 
100000411000215	100000411	3	00:02:39	215	FAC	EV
100000411000216	100000411	3	00:03:04	216	STOP	 
100000411000217	100000411	3	00:03:04	217	FAC	EV
100000411000218	100000411	3	00:03:24	218	GIVE	EV
100000411000219	100000411	3	00:04:50	219	HIT	EV
100000411000220	100000411	3	00:04:57	220	HIT	EV
100000411000221	100000411	3	00:04:59	221	HIT	EV
100000411000222	100000411	3	00:05:57	222	BLOCK	EV
100000411000223	100000411	3	00:06:09	223	HIT	EV
100000411000224	100000411	3	00:06:19	224	HIT	EV
100000411000225	100000411	3	00:07:00	225	HIT	EV
100000411000226	100000411	3	00:07:09	226	BLOCK	EV
100000411000227	100000411	3	00:07:26	227	HIT	EV
100000411000228	100000411	3	00:07:36	228	BLOCK	EV
100000411000229	100000411	3	00:07:45	229	HIT	EV
100000411000230	100000411	3	00:07:50	230	HIT	EV
100000411000231	100000411	3	00:07:59	231	HIT	EV
100000411000232	100000411	3	00:08:20	232	HIT	EV
100000411000233	100000411	3	00:08:24	233	BLOCK	EV
100000411000234	100000411	3	00:08:28	234	HIT	EV
100000411000235	100000411	3	00:09:36	235	PENL	EV
100000411000236	100000411	3	00:09:36	236	STOP	 
100000411000237	100000411	3	00:09:36	237	FAC	PP
100000411000238	100000411	3	00:09:59	238	SHOT	PP
100000411000239	100000411	3	00:10:06	239	GOAL	PP
100000411000240	100000411	3	00:10:06	240	FAC	EV
100000411000241	100000411	3	00:10:18	241	STOP	 
100000411000242	100000411	3	00:10:18	242	FAC	EV
100000411000243	100000411	3	00:10:37	243	TAKE	EV
100000411000244	100000411	3	00:10:49	244	SHOT	EV
100000411000245	100000411	3	00:10:50	245	STOP	 
100000411000246	100000411	3	00:10:50	246	FAC	EV
100000411000247	100000411	3	00:11:10	247	MISS	EV
100000411000248	100000411	3	00:11:12	248	HIT	EV
100000411000249	100000411	3	00:11:24	249	PENL	EV
100000411000250	100000411	3	00:11:24	250	FAC	PP
100000411000251	100000411	3	00:12:49	251	GIVE	PP
100000411000252	100000411	3	00:13:25	252	HIT	EV
100000411000253	100000411	3	00:13:29	253	GOAL	EV
100000411000254	100000411	3	00:13:29	254	FAC	EV
100000411000255	100000411	3	00:14:03	255	STOP	 
100000411000256	100000411	3	00:14:03	256	FAC	EV
100000411000257	100000411	3	00:14:33	257	BLOCK	EV
100000411000258	100000411	3	00:14:39	258	HIT	EV
100000411000259	100000411	3	00:15:36	259	HIT	EV
100000411000260	100000411	3	00:15:38	260	MISS	EV
100000411000261	100000411	3	00:15:41	261	HIT	EV
100000411000262	100000411	3	00:15:55	262	TAKE	EV
100000411000263	100000411	3	00:16:43	263	GOAL	EV
100000411000264	100000411	3	00:16:43	264	FAC	EV
100000411000265	100000411	3	00:17:02	265	TAKE	EV
100000411000266	100000411	3	00:17:20	266	STOP	 
100000411000267	100000411	3	00:17:20	267	FAC	EV
100000411000268	100000411	3	00:18:07	268	GIVE	EV
100000411000269	100000411	3	00:18:12	269	SHOT	EV
100000411000270	100000411	3	00:18:37	270	HIT	EV
100000411000271	100000411	3	00:18:58	271	GOAL	EV
100000411000272	100000411	3	00:18:58	272	STOP	 
100000411000273	100000411	3	00:18:58	273	FAC	EV
100000411000274	100000411	3	00:19:10	274	SHOT	EV
100000411000275	100000411	3	00:19:31	275	SHOT	EV
100000411000276	100000411	3	00:19:32	276	STOP	 
100000411000277	100000411	3	00:19:32	277	FAC	EV
100000411000278	100000411	3	00:19:42	278	MISS	EV
100000411000279	100000411	3	00:19:44	279	BLOCK	EV
100000411000280	100000411	3	00:19:51	280	BLOCK	EV
100000411000281	100000411	3	00:20:00	281	PEND	 
100000411000282	100000411	3	00:20:00	282	GEND	 
\.


--
-- TOC entry 2332 (class 0 OID 24706)
-- Dependencies: 198
-- Data for Name: player; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY player (id, name, actual_team_id, "position") FROM stdin;
1	Hans	PIT	F
2	asdjkl	NSH	G
3	Hans1	PIT	G
4	Hans2	NYR	G
\.


--
-- TOC entry 2326 (class 0 OID 24657)
-- Dependencies: 192
-- Data for Name: shot; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY shot (id, player_id, distance, shot_type, team_id, play_id) FROM stdin;
\.


--
-- TOC entry 2331 (class 0 OID 24698)
-- Dependencies: 197
-- Data for Name: start_stop; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY start_stop (id, what, play_id) FROM stdin;
\.


--
-- TOC entry 2320 (class 0 OID 16749)
-- Dependencies: 186
-- Data for Name: team; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY team (id, full_name, full_name_big) FROM stdin;
ARI	Arizona Coyotes	ARIZONA COYOTES
ANA	Anaheim Ducks	ANAHEIM DUCKS
BOS	Boston Bruins	BOSTON BRUINS
PIT	Pittsburgh Penguins	PITTSBURGH PENGUINS
STL	St. Louis Blues	ST. LOUIS BLUES
TBL	Tampa Bay Lightning	TAMPA BAY LIGHNING
TOR	Toronto Maple Leafs	TORONTO MAPLE LEAFS
VAN	Vancouver Canucks	VANCOUVER CANUCKS
OTT	Ottawa Senators	OTTAWA SENATORS
PHI	Philadelphia Flyers	PHILADELPHIA FLYERS
SJS	San Jose Sharks	SAN JOSE SHARKS
WPG	Winnipeg Jets	WINNIEG JETS
WSH	Washington Capitals	WASHINGTON CAPITALS
BUF	Buffalo Sabres	BUFFALO SABRES
CBJ	Columbus Blue Jackets	COLUMBUS BLUE JACKETS
CAR	Nashville Predators	NASHVILLE PREDATORS
CHI	Chicago Blackhawks	CHICAGO BLACKHAWKES
CGY	Calgary Flames	CALGARY FLAMES
DAL	Dallas Stars	DALLAS STARS
COL	Colorado Avalanche	COLORADO AVALANCHE
EDM	Edmonton Oilers	EDMONTON OILERS
DET	Detroit Red Wings	DETROIT RED WINGS
LAK	Los Angeles Kings	LOS ANGELES KINGS
FLA	Florida Panthers	FLORIDA PANTHERS
MTL	Montréal Canadiens	MONTREAL CANADIENS
MIN	Minnesota Wild	MINNESOTA WILD
NSH	Carolina Hurricanes	CAROLINA HURRICANES
NJD	New Jersey Devils	NEW JERSEY DEVILS
NYR	New York Rangers	NEW YORK RANGERS
NYI	New York Islanders	NEW YORK ISLANDERS
\.


--
-- TOC entry 2343 (class 0 OID 0)
-- Dependencies: 201
-- Name: play_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('play_id_seq', 1, false);


--
-- TOC entry 2344 (class 0 OID 0)
-- Dependencies: 200
-- Name: player_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('player_id_seq', 4, true);


--
-- TOC entry 2094 (class 2606 OID 24577)
-- Name: game Games_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY game
    ADD CONSTRAINT "Games_pkey" PRIMARY KEY (id);


--
-- TOC entry 2105 (class 2606 OID 24635)
-- Name: assist assist_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY assist
    ADD CONSTRAINT assist_pkey PRIMARY KEY (id);


--
-- TOC entry 2133 (class 2606 OID 24672)
-- Name: block block_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY block
    ADD CONSTRAINT block_pkey PRIMARY KEY (id);


--
-- TOC entry 2115 (class 2606 OID 24645)
-- Name: faceoff faceoff_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY faceoff
    ADD CONSTRAINT faceoff_pkey PRIMARY KEY (id);


--
-- TOC entry 2152 (class 2606 OID 24697)
-- Name: giveaway giveaway_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY giveaway
    ADD CONSTRAINT giveaway_pkey PRIMARY KEY (id);


--
-- TOC entry 2103 (class 2606 OID 24627)
-- Name: goal goal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY goal
    ADD CONSTRAINT goal_pkey PRIMARY KEY (id);


--
-- TOC entry 2126 (class 2606 OID 24656)
-- Name: hit hit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hit
    ADD CONSTRAINT hit_pkey PRIMARY KEY (id);


--
-- TOC entry 2142 (class 2606 OID 24680)
-- Name: miss miss_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY miss
    ADD CONSTRAINT miss_pkey PRIMARY KEY (id);


--
-- TOC entry 2113 (class 2606 OID 24640)
-- Name: on_ice on_ice_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY on_ice
    ADD CONSTRAINT on_ice_pkey PRIMARY KEY (id);


--
-- TOC entry 2147 (class 2606 OID 24688)
-- Name: penalty penalty_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY penalty
    ADD CONSTRAINT penalty_pkey PRIMARY KEY (id);


--
-- TOC entry 2160 (class 2606 OID 41063)
-- Name: play play_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY play
    ADD CONSTRAINT play_pkey PRIMARY KEY (id);


--
-- TOC entry 2158 (class 2606 OID 24713)
-- Name: player player_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY player
    ADD CONSTRAINT player_pkey PRIMARY KEY (id);


--
-- TOC entry 2131 (class 2606 OID 24664)
-- Name: shot shot_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY shot
    ADD CONSTRAINT shot_pkey PRIMARY KEY (id);


--
-- TOC entry 2155 (class 2606 OID 24705)
-- Name: start_stop start_stop_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY start_stop
    ADD CONSTRAINT start_stop_pkey PRIMARY KEY (id);


--
-- TOC entry 2098 (class 2606 OID 24619)
-- Name: team team_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY team
    ADD CONSTRAINT team_pkey PRIMARY KEY (id);


--
-- TOC entry 2106 (class 1259 OID 24742)
-- Name: fki_assist_player; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_assist_player ON assist USING btree (player_id);


--
-- TOC entry 2107 (class 1259 OID 24754)
-- Name: fki_assist_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_assist_team ON assist USING btree (team_id);


--
-- TOC entry 2134 (class 1259 OID 24796)
-- Name: fki_block_blocked_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_block_blocked_team ON block USING btree (blocked_team_id);


--
-- TOC entry 2135 (class 1259 OID 24802)
-- Name: fki_block_blocking_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_block_blocking_team ON block USING btree (blocking_team_id);


--
-- TOC entry 2136 (class 1259 OID 24778)
-- Name: fki_block_player_got_blocked; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_block_player_got_blocked ON block USING btree (player_got_blocked_id);


--
-- TOC entry 2137 (class 1259 OID 24772)
-- Name: fki_block_player_who_blocked; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_block_player_who_blocked ON block USING btree (player_who_blocked_id);


--
-- TOC entry 2116 (class 1259 OID 24844)
-- Name: fki_faceoff_losing_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_faceoff_losing_team ON faceoff USING btree (losing_team_id);


--
-- TOC entry 2117 (class 1259 OID 32802)
-- Name: fki_faceoff_play_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_faceoff_play_id ON faceoff USING btree (play_id);


--
-- TOC entry 2118 (class 1259 OID 24808)
-- Name: fki_faceoff_player1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_faceoff_player1 ON faceoff USING btree (player1_id);


--
-- TOC entry 2119 (class 1259 OID 24814)
-- Name: fki_faceoff_player2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_faceoff_player2 ON faceoff USING btree (player2_id);


--
-- TOC entry 2120 (class 1259 OID 24838)
-- Name: fki_faceoff_winning_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_faceoff_winning_team ON faceoff USING btree (winning_team_id);


--
-- TOC entry 2095 (class 1259 OID 24856)
-- Name: fki_game_away_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_game_away_team ON game USING btree (away_team_id);


--
-- TOC entry 2096 (class 1259 OID 24850)
-- Name: fki_game_home_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_game_home_team ON game USING btree (home_team_id);


--
-- TOC entry 2148 (class 1259 OID 32813)
-- Name: fki_giveaway_play_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_giveaway_play_id ON giveaway USING btree (play_id);


--
-- TOC entry 2149 (class 1259 OID 24870)
-- Name: fki_giveaway_player; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_giveaway_player ON giveaway USING btree (player_id);


--
-- TOC entry 2150 (class 1259 OID 24876)
-- Name: fki_giveaway_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_giveaway_team ON giveaway USING btree (team_id);


--
-- TOC entry 2099 (class 1259 OID 32819)
-- Name: fki_goal_play_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_goal_play_id ON goal USING btree (play_id);


--
-- TOC entry 2100 (class 1259 OID 24906)
-- Name: fki_goal_playerr; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_goal_playerr ON goal USING btree (player_id);


--
-- TOC entry 2101 (class 1259 OID 24918)
-- Name: fki_goal_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_goal_team ON goal USING btree (team_id);


--
-- TOC entry 2121 (class 1259 OID 24936)
-- Name: fki_hit_hitted; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_hit_hitted ON hit USING btree (hitted_id);


--
-- TOC entry 2122 (class 1259 OID 24972)
-- Name: fki_hit_hitted_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_hit_hitted_team ON hit USING btree (hitted_team_id);


--
-- TOC entry 2123 (class 1259 OID 24942)
-- Name: fki_hit_hitter; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_hit_hitter ON hit USING btree (hitter_id);


--
-- TOC entry 2124 (class 1259 OID 24966)
-- Name: fki_hit_hitter_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_hit_hitter_team ON hit USING btree (hitter_team_id);


--
-- TOC entry 2138 (class 1259 OID 32825)
-- Name: fki_miss_play_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_miss_play_id ON miss USING btree (play_id);


--
-- TOC entry 2139 (class 1259 OID 24978)
-- Name: fki_miss_player; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_miss_player ON miss USING btree (player_id);


--
-- TOC entry 2140 (class 1259 OID 24996)
-- Name: fki_miss_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_miss_team ON miss USING btree (team_id);


--
-- TOC entry 2109 (class 1259 OID 32849)
-- Name: fki_on_ice_play_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_on_ice_play_id ON on_ice USING btree (play_id);


--
-- TOC entry 2110 (class 1259 OID 32855)
-- Name: fki_on_ice_player_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_on_ice_player_id ON on_ice USING btree (player_id);


--
-- TOC entry 2111 (class 1259 OID 25059)
-- Name: fki_onice_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_onice_team ON on_ice USING btree (team_id);


--
-- TOC entry 2143 (class 1259 OID 32831)
-- Name: fki_penalty_play_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_penalty_play_id ON penalty USING btree (play_id);


--
-- TOC entry 2144 (class 1259 OID 25065)
-- Name: fki_penalty_player; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_penalty_player ON penalty USING btree (player_id);


--
-- TOC entry 2145 (class 1259 OID 25071)
-- Name: fki_penalty_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_penalty_team ON penalty USING btree (team_id);


--
-- TOC entry 2108 (class 1259 OID 32778)
-- Name: fki_play_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_play_id ON assist USING btree (play_id);


--
-- TOC entry 2156 (class 1259 OID 25095)
-- Name: fki_player_actual_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_player_actual_team ON player USING btree (actual_team_id);


--
-- TOC entry 2127 (class 1259 OID 32837)
-- Name: fki_shot_play_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_shot_play_id ON shot USING btree (play_id);


--
-- TOC entry 2128 (class 1259 OID 25107)
-- Name: fki_shot_player; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_shot_player ON shot USING btree (player_id);


--
-- TOC entry 2129 (class 1259 OID 25125)
-- Name: fki_shot_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_shot_team ON shot USING btree (team_id);


--
-- TOC entry 2153 (class 1259 OID 32843)
-- Name: fki_start_stop_play_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_start_stop_play_id ON start_stop USING btree (play_id);


--
-- TOC entry 2166 (class 2606 OID 24737)
-- Name: assist assist_player; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY assist
    ADD CONSTRAINT assist_player FOREIGN KEY (player_id) REFERENCES player(id);


--
-- TOC entry 2167 (class 2606 OID 24749)
-- Name: assist assist_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY assist
    ADD CONSTRAINT assist_team FOREIGN KEY (team_id) REFERENCES team(id);


--
-- TOC entry 2187 (class 2606 OID 24791)
-- Name: block block_blocked_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY block
    ADD CONSTRAINT block_blocked_team FOREIGN KEY (blocked_team_id) REFERENCES team(id);


--
-- TOC entry 2188 (class 2606 OID 24797)
-- Name: block block_blocking_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY block
    ADD CONSTRAINT block_blocking_team FOREIGN KEY (blocking_team_id) REFERENCES team(id);


--
-- TOC entry 2186 (class 2606 OID 24773)
-- Name: block block_player_got_blocked; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY block
    ADD CONSTRAINT block_player_got_blocked FOREIGN KEY (player_got_blocked_id) REFERENCES player(id);


--
-- TOC entry 2185 (class 2606 OID 24767)
-- Name: block block_player_who_blocked; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY block
    ADD CONSTRAINT block_player_who_blocked FOREIGN KEY (player_who_blocked_id) REFERENCES player(id);


--
-- TOC entry 2175 (class 2606 OID 24839)
-- Name: faceoff faceoff_losing_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY faceoff
    ADD CONSTRAINT faceoff_losing_team FOREIGN KEY (losing_team_id) REFERENCES team(id);


--
-- TOC entry 2177 (class 2606 OID 41079)
-- Name: faceoff faceoff_play_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY faceoff
    ADD CONSTRAINT faceoff_play_id FOREIGN KEY (play_id) REFERENCES play(id);


--
-- TOC entry 2172 (class 2606 OID 24803)
-- Name: faceoff faceoff_player1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY faceoff
    ADD CONSTRAINT faceoff_player1 FOREIGN KEY (player1_id) REFERENCES player(id);


--
-- TOC entry 2173 (class 2606 OID 24809)
-- Name: faceoff faceoff_player2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY faceoff
    ADD CONSTRAINT faceoff_player2 FOREIGN KEY (player2_id) REFERENCES player(id);


--
-- TOC entry 2174 (class 2606 OID 24833)
-- Name: faceoff faceoff_winning_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY faceoff
    ADD CONSTRAINT faceoff_winning_team FOREIGN KEY (winning_team_id) REFERENCES team(id);


--
-- TOC entry 2162 (class 2606 OID 24851)
-- Name: game game_away_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY game
    ADD CONSTRAINT game_away_team FOREIGN KEY (away_team_id) REFERENCES team(id);


--
-- TOC entry 2161 (class 2606 OID 24845)
-- Name: game game_home_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY game
    ADD CONSTRAINT game_home_team FOREIGN KEY (home_team_id) REFERENCES team(id);


--
-- TOC entry 2199 (class 2606 OID 41089)
-- Name: giveaway giveaway_play_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY giveaway
    ADD CONSTRAINT giveaway_play_id FOREIGN KEY (play_id) REFERENCES play(id);


--
-- TOC entry 2196 (class 2606 OID 24865)
-- Name: giveaway giveaway_player; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY giveaway
    ADD CONSTRAINT giveaway_player FOREIGN KEY (player_id) REFERENCES player(id);


--
-- TOC entry 2197 (class 2606 OID 24871)
-- Name: giveaway giveaway_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY giveaway
    ADD CONSTRAINT giveaway_team FOREIGN KEY (team_id) REFERENCES team(id);


--
-- TOC entry 2165 (class 2606 OID 41094)
-- Name: goal goal_play_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY goal
    ADD CONSTRAINT goal_play_id FOREIGN KEY (play_id) REFERENCES play(id);


--
-- TOC entry 2163 (class 2606 OID 24901)
-- Name: goal goal_player; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY goal
    ADD CONSTRAINT goal_player FOREIGN KEY (player_id) REFERENCES player(id);


--
-- TOC entry 2164 (class 2606 OID 24913)
-- Name: goal goal_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY goal
    ADD CONSTRAINT goal_team FOREIGN KEY (team_id) REFERENCES team(id);


--
-- TOC entry 2178 (class 2606 OID 24931)
-- Name: hit hit_hitted; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hit
    ADD CONSTRAINT hit_hitted FOREIGN KEY (hitted_id) REFERENCES player(id);


--
-- TOC entry 2181 (class 2606 OID 24967)
-- Name: hit hit_hitted_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hit
    ADD CONSTRAINT hit_hitted_team FOREIGN KEY (hitted_team_id) REFERENCES team(id);


--
-- TOC entry 2179 (class 2606 OID 24937)
-- Name: hit hit_hitter; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hit
    ADD CONSTRAINT hit_hitter FOREIGN KEY (hitter_id) REFERENCES player(id);


--
-- TOC entry 2180 (class 2606 OID 24961)
-- Name: hit hit_hitter_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hit
    ADD CONSTRAINT hit_hitter_team FOREIGN KEY (hitter_team_id) REFERENCES team(id);


--
-- TOC entry 2192 (class 2606 OID 41099)
-- Name: miss miss_play_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY miss
    ADD CONSTRAINT miss_play_id FOREIGN KEY (play_id) REFERENCES play(id);


--
-- TOC entry 2190 (class 2606 OID 24973)
-- Name: miss miss_player; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY miss
    ADD CONSTRAINT miss_player FOREIGN KEY (player_id) REFERENCES player(id);


--
-- TOC entry 2191 (class 2606 OID 24991)
-- Name: miss miss_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY miss
    ADD CONSTRAINT miss_team FOREIGN KEY (team_id) REFERENCES team(id);


--
-- TOC entry 2171 (class 2606 OID 41119)
-- Name: on_ice on_ice_play_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY on_ice
    ADD CONSTRAINT on_ice_play_id FOREIGN KEY (play_id) REFERENCES play(id);


--
-- TOC entry 2170 (class 2606 OID 32850)
-- Name: on_ice on_ice_player_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY on_ice
    ADD CONSTRAINT on_ice_player_id FOREIGN KEY (player_id) REFERENCES player(id);


--
-- TOC entry 2169 (class 2606 OID 25054)
-- Name: on_ice onice_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY on_ice
    ADD CONSTRAINT onice_team FOREIGN KEY (team_id) REFERENCES team(id);


--
-- TOC entry 2195 (class 2606 OID 41104)
-- Name: penalty penalty_play_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY penalty
    ADD CONSTRAINT penalty_play_id FOREIGN KEY (play_id) REFERENCES play(id);


--
-- TOC entry 2193 (class 2606 OID 25060)
-- Name: penalty penalty_player; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY penalty
    ADD CONSTRAINT penalty_player FOREIGN KEY (player_id) REFERENCES player(id);


--
-- TOC entry 2194 (class 2606 OID 25066)
-- Name: penalty penalty_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY penalty
    ADD CONSTRAINT penalty_team FOREIGN KEY (team_id) REFERENCES team(id);


--
-- TOC entry 2168 (class 2606 OID 41064)
-- Name: assist play_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY assist
    ADD CONSTRAINT play_id FOREIGN KEY (play_id) REFERENCES play(id);


--
-- TOC entry 2189 (class 2606 OID 41069)
-- Name: block play_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY block
    ADD CONSTRAINT play_id FOREIGN KEY (play_id) REFERENCES play(id);


--
-- TOC entry 2176 (class 2606 OID 41074)
-- Name: faceoff play_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY faceoff
    ADD CONSTRAINT play_id FOREIGN KEY (play_id) REFERENCES play(id);


--
-- TOC entry 2198 (class 2606 OID 41084)
-- Name: giveaway play_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY giveaway
    ADD CONSTRAINT play_id FOREIGN KEY (play_id) REFERENCES play(id);


--
-- TOC entry 2201 (class 2606 OID 25090)
-- Name: player player_actual_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY player
    ADD CONSTRAINT player_actual_team FOREIGN KEY (actual_team_id) REFERENCES team(id);


--
-- TOC entry 2184 (class 2606 OID 41109)
-- Name: shot shot_play_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY shot
    ADD CONSTRAINT shot_play_id FOREIGN KEY (play_id) REFERENCES play(id);


--
-- TOC entry 2182 (class 2606 OID 25102)
-- Name: shot shot_player; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY shot
    ADD CONSTRAINT shot_player FOREIGN KEY (player_id) REFERENCES player(id);


--
-- TOC entry 2183 (class 2606 OID 25120)
-- Name: shot shot_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY shot
    ADD CONSTRAINT shot_team FOREIGN KEY (team_id) REFERENCES team(id);


--
-- TOC entry 2200 (class 2606 OID 41114)
-- Name: start_stop start_stop_play_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY start_stop
    ADD CONSTRAINT start_stop_play_id FOREIGN KEY (play_id) REFERENCES play(id);


-- Completed on 2017-11-01 23:29:44

--
-- PostgreSQL database dump complete
--

