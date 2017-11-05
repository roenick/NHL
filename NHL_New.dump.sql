--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 9.6.3

-- Started on 2017-08-09 13:30:03

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2370 (class 1262 OID 16745)
-- Name: NHL; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "NHL" WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'German_Switzerland.1252' LC_CTYPE = 'German_Switzerland.1252';


ALTER DATABASE "NHL" OWNER TO postgres;

\connect "NHL"

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
-- TOC entry 2372 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 632 (class 1247 OID 24724)
-- Name: assist_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE assist_type AS ENUM (
    'first',
    'second'
);


ALTER TYPE assist_type OWNER TO postgres;

--
-- TOC entry 638 (class 1247 OID 24858)
-- Name: game_finished_in; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE game_finished_in AS ENUM (
    'R',
    'OT',
    'SO'
);


ALTER TYPE game_finished_in OWNER TO postgres;

--
-- TOC entry 635 (class 1247 OID 24730)
-- Name: player_position; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE player_position AS ENUM (
    'G',
    'D',
    'F'
);


ALTER TYPE player_position OWNER TO postgres;

--
-- TOC entry 629 (class 1247 OID 24715)
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
-- TOC entry 575 (class 1247 OID 24608)
-- Name: strength; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE strength AS ENUM (
    'EV',
    'PP',
    'SH'
);


ALTER TYPE strength OWNER TO postgres;

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
    play_id integer NOT NULL
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
    game_id smallint NOT NULL,
    on_ice_home_id integer NOT NULL,
    on_ice_away_id integer NOT NULL,
    "time" time without time zone NOT NULL,
    winning_team_id text NOT NULL,
    losing_team_id text NOT NULL,
    zone text NOT NULL,
    strength strength NOT NULL,
    period smallint
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
    finished_in game_finished_in NOT NULL
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
    "time" time without time zone NOT NULL,
    period smallint NOT NULL,
    zone text NOT NULL,
    on_ice_home integer NOT NULL,
    on_ice_away integer NOT NULL,
    strength strength NOT NULL,
    game_id integer NOT NULL
);


ALTER TABLE giveaway OWNER TO postgres;

--
-- TOC entry 187 (class 1259 OID 24620)
-- Name: goal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE goal (
    id integer NOT NULL,
    player_id smallint NOT NULL,
    game_id smallint NOT NULL,
    distance smallint NOT NULL,
    "time" time without time zone NOT NULL,
    team_id text NOT NULL,
    on_ice_home_id integer NOT NULL,
    on_ice_away_id integer NOT NULL,
    strength strength NOT NULL,
    shot_type shot_type NOT NULL,
    period smallint NOT NULL
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
    zone text NOT NULL,
    on_ice_home integer NOT NULL,
    on_ice_away integer NOT NULL,
    "time" time without time zone NOT NULL,
    game_id smallint NOT NULL,
    hitter_team_id text NOT NULL,
    hitted_team_id text NOT NULL,
    strength strength NOT NULL,
    period smallint NOT NULL
);


ALTER TABLE hit OWNER TO postgres;

--
-- TOC entry 194 (class 1259 OID 24673)
-- Name: miss; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE miss (
    id integer NOT NULL,
    player_id smallint NOT NULL,
    "time" time without time zone NOT NULL,
    distance smallint NOT NULL,
    on_ice_home integer NOT NULL,
    on_ice_away integer NOT NULL,
    team_id text NOT NULL,
    strength strength NOT NULL,
    shot_type shot_type NOT NULL,
    period smallint NOT NULL,
    game_id integer NOT NULL
);


ALTER TABLE miss OWNER TO postgres;

--
-- TOC entry 189 (class 1259 OID 24636)
-- Name: on_ice; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE on_ice (
    id integer NOT NULL,
    game_id integer NOT NULL,
    "time" time without time zone NOT NULL,
    goalie_id smallint,
    defender1_id smallint,
    defender2_id smallint,
    forward1_id smallint,
    forward2_id smallint,
    forward3_id smallint,
    forward_extra_id smallint,
    team_id text
);


ALTER TABLE on_ice OWNER TO postgres;

--
-- TOC entry 195 (class 1259 OID 24681)
-- Name: penalty; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE penalty (
    id integer NOT NULL,
    "time" time without time zone NOT NULL,
    period smallint NOT NULL,
    length smallint NOT NULL,
    player_id smallint NOT NULL,
    reason text NOT NULL,
    on_ice_home integer NOT NULL,
    on_ice_away integer NOT NULL,
    strength strength NOT NULL,
    game_id integer NOT NULL,
    team_id text NOT NULL
);


ALTER TABLE penalty OWNER TO postgres;

--
-- TOC entry 199 (class 1259 OID 32768)
-- Name: play; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE play (
    id integer NOT NULL,
    game_id smallint,
    period smallint,
    "time" time without time zone,
    in_game_id smallint,
    strength strength
);


ALTER TABLE play OWNER TO postgres;

--
-- TOC entry 198 (class 1259 OID 24706)
-- Name: player; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE player (
    id smallint NOT NULL,
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
    game_id smallint NOT NULL,
    player_id smallint NOT NULL,
    distance smallint NOT NULL,
    on_ice_home integer NOT NULL,
    on_ice_away integer NOT NULL,
    "time" time without time zone NOT NULL,
    strength strength NOT NULL,
    shot_type shot_type NOT NULL,
    period smallint NOT NULL,
    team_id text NOT NULL
);


ALTER TABLE shot OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 24698)
-- Name: start_stop; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE start_stop (
    id integer NOT NULL,
    what text NOT NULL,
    period smallint NOT NULL,
    "time" time without time zone NOT NULL,
    on_ice_home integer NOT NULL,
    on_ice_away integer NOT NULL
);


ALTER TABLE start_stop OWNER TO postgres;

--
-- TOC entry 186 (class 1259 OID 16749)
-- Name: team; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE team (
    id text NOT NULL,
    full_name text NOT NULL
);


ALTER TABLE team OWNER TO postgres;

--
-- TOC entry 2354 (class 0 OID 24628)
-- Dependencies: 188
-- Data for Name: assist; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY assist (id, player_id, team_id, type, play_id) FROM stdin;
\.


--
-- TOC entry 2359 (class 0 OID 24665)
-- Dependencies: 193
-- Data for Name: block; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY block (id, player_who_blocked_id, player_got_blocked_id, blocked_team_id, blocking_team_id, play_id) FROM stdin;
\.


--
-- TOC entry 2356 (class 0 OID 24641)
-- Dependencies: 190
-- Data for Name: faceoff; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY faceoff (id, player1_id, player2_id, game_id, on_ice_home_id, on_ice_away_id, "time", winning_team_id, losing_team_id, zone, strength, period) FROM stdin;
\.


--
-- TOC entry 2351 (class 0 OID 16746)
-- Dependencies: 185
-- Data for Name: game; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY game (id, home_team_id, away_team_id, home_score, away_score, stage, date, finished_in) FROM stdin;
\.


--
-- TOC entry 2362 (class 0 OID 24690)
-- Dependencies: 196
-- Data for Name: giveaway; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY giveaway (id, player_id, team_id, "time", period, zone, on_ice_home, on_ice_away, strength, game_id) FROM stdin;
\.


--
-- TOC entry 2353 (class 0 OID 24620)
-- Dependencies: 187
-- Data for Name: goal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY goal (id, player_id, game_id, distance, "time", team_id, on_ice_home_id, on_ice_away_id, strength, shot_type, period) FROM stdin;
\.


--
-- TOC entry 2357 (class 0 OID 24649)
-- Dependencies: 191
-- Data for Name: hit; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY hit (id, hitted_id, hitter_id, zone, on_ice_home, on_ice_away, "time", game_id, hitter_team_id, hitted_team_id, strength, period) FROM stdin;
\.


--
-- TOC entry 2360 (class 0 OID 24673)
-- Dependencies: 194
-- Data for Name: miss; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY miss (id, player_id, "time", distance, on_ice_home, on_ice_away, team_id, strength, shot_type, period, game_id) FROM stdin;
\.


--
-- TOC entry 2355 (class 0 OID 24636)
-- Dependencies: 189
-- Data for Name: on_ice; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY on_ice (id, game_id, "time", goalie_id, defender1_id, defender2_id, forward1_id, forward2_id, forward3_id, forward_extra_id, team_id) FROM stdin;
\.


--
-- TOC entry 2361 (class 0 OID 24681)
-- Dependencies: 195
-- Data for Name: penalty; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY penalty (id, "time", period, length, player_id, reason, on_ice_home, on_ice_away, strength, game_id, team_id) FROM stdin;
\.


--
-- TOC entry 2365 (class 0 OID 32768)
-- Dependencies: 199
-- Data for Name: play; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY play (id, game_id, period, "time", in_game_id, strength) FROM stdin;
\.


--
-- TOC entry 2364 (class 0 OID 24706)
-- Dependencies: 198
-- Data for Name: player; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY player (id, name, actual_team_id, "position") FROM stdin;
\.


--
-- TOC entry 2358 (class 0 OID 24657)
-- Dependencies: 192
-- Data for Name: shot; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY shot (id, game_id, player_id, distance, on_ice_home, on_ice_away, "time", strength, shot_type, period, team_id) FROM stdin;
\.


--
-- TOC entry 2363 (class 0 OID 24698)
-- Dependencies: 197
-- Data for Name: start_stop; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY start_stop (id, what, period, "time", on_ice_home, on_ice_away) FROM stdin;
\.


--
-- TOC entry 2352 (class 0 OID 16749)
-- Dependencies: 186
-- Data for Name: team; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY team (id, full_name) FROM stdin;
NSH	Carolina Hurricanes
ANA	Anaheim Ducks
ARI	Arizona Coyotes
BOS	Boston Bruins
BUF	Buffalo Sabres
CAR	Nashville Predators
CBJ	Columbus Blue Jackets
CGY	Calgary Flames
CHI	Chicago Blackhawks
COL	Colorado Avalanche
DAL	Dallas Stars
DET	Detroit Red Wings
EDM	Edmonton Oilers
FLA	Florida Panthers
MIN	Minnesota Wild
MTL	Montréal Canadiens
NJD	New Jersey Devils
NYI	New York Islanders
NYR	New York Rangers
OTT	Ottawa Senators
PIT	Pittsburgh Penguins
SJS	San Jose Sharks
STL	St. Louis Blues
TBL	Tampa Bay Lightning
TOR	Toronto Maple Leafs
VAN	Vancouver Canucks
WPG	Winnipeg Jets
WSH	Washington Capitals
LAK	Los Angeles Kings
PHI	Philadelphia Flyers
\.


--
-- TOC entry 2085 (class 2606 OID 24577)
-- Name: game Games_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY game
    ADD CONSTRAINT "Games_pkey" PRIMARY KEY (id);


--
-- TOC entry 2098 (class 2606 OID 24635)
-- Name: assist assist_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY assist
    ADD CONSTRAINT assist_pkey PRIMARY KEY (id);


--
-- TOC entry 2139 (class 2606 OID 24672)
-- Name: block block_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY block
    ADD CONSTRAINT block_pkey PRIMARY KEY (id);


--
-- TOC entry 2114 (class 2606 OID 24645)
-- Name: faceoff faceoff_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY faceoff
    ADD CONSTRAINT faceoff_pkey PRIMARY KEY (id);


--
-- TOC entry 2164 (class 2606 OID 24697)
-- Name: giveaway giveaway_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY giveaway
    ADD CONSTRAINT giveaway_pkey PRIMARY KEY (id);


--
-- TOC entry 2096 (class 2606 OID 24627)
-- Name: goal goal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY goal
    ADD CONSTRAINT goal_pkey PRIMARY KEY (id);


--
-- TOC entry 2130 (class 2606 OID 24656)
-- Name: hit hit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hit
    ADD CONSTRAINT hit_pkey PRIMARY KEY (id);


--
-- TOC entry 2150 (class 2606 OID 24680)
-- Name: miss miss_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY miss
    ADD CONSTRAINT miss_pkey PRIMARY KEY (id);


--
-- TOC entry 2112 (class 2606 OID 24640)
-- Name: on_ice on_ice_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY on_ice
    ADD CONSTRAINT on_ice_pkey PRIMARY KEY (id);


--
-- TOC entry 2157 (class 2606 OID 24688)
-- Name: penalty penalty_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY penalty
    ADD CONSTRAINT penalty_pkey PRIMARY KEY (id);


--
-- TOC entry 2173 (class 2606 OID 32772)
-- Name: play play_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY play
    ADD CONSTRAINT play_pkey PRIMARY KEY (id);


--
-- TOC entry 2171 (class 2606 OID 24713)
-- Name: player player_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY player
    ADD CONSTRAINT player_pkey PRIMARY KEY (id);


--
-- TOC entry 2137 (class 2606 OID 24664)
-- Name: shot shot_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY shot
    ADD CONSTRAINT shot_pkey PRIMARY KEY (id);


--
-- TOC entry 2168 (class 2606 OID 24705)
-- Name: start_stop start_stop_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY start_stop
    ADD CONSTRAINT start_stop_pkey PRIMARY KEY (id);


--
-- TOC entry 2089 (class 2606 OID 24619)
-- Name: team team_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY team
    ADD CONSTRAINT team_pkey PRIMARY KEY (id);


--
-- TOC entry 2099 (class 1259 OID 24742)
-- Name: fki_assist_player; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_assist_player ON assist USING btree (player_id);


--
-- TOC entry 2100 (class 1259 OID 24754)
-- Name: fki_assist_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_assist_team ON assist USING btree (team_id);


--
-- TOC entry 2140 (class 1259 OID 24796)
-- Name: fki_block_blocked_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_block_blocked_team ON block USING btree (blocked_team_id);


--
-- TOC entry 2141 (class 1259 OID 24802)
-- Name: fki_block_blocking_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_block_blocking_team ON block USING btree (blocking_team_id);


--
-- TOC entry 2142 (class 1259 OID 24778)
-- Name: fki_block_player_got_blocked; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_block_player_got_blocked ON block USING btree (player_got_blocked_id);


--
-- TOC entry 2143 (class 1259 OID 24772)
-- Name: fki_block_player_who_blocked; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_block_player_who_blocked ON block USING btree (player_who_blocked_id);


--
-- TOC entry 2115 (class 1259 OID 24820)
-- Name: fki_faceoff_game; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_faceoff_game ON faceoff USING btree (game_id);


--
-- TOC entry 2116 (class 1259 OID 24844)
-- Name: fki_faceoff_losing_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_faceoff_losing_team ON faceoff USING btree (losing_team_id);


--
-- TOC entry 2117 (class 1259 OID 24832)
-- Name: fki_faceoff_on_ice_away; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_faceoff_on_ice_away ON faceoff USING btree (on_ice_away_id);


--
-- TOC entry 2118 (class 1259 OID 24826)
-- Name: fki_faceoff_on_ice_home; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_faceoff_on_ice_home ON faceoff USING btree (on_ice_home_id);


--
-- TOC entry 2119 (class 1259 OID 24808)
-- Name: fki_faceoff_player1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_faceoff_player1 ON faceoff USING btree (player1_id);


--
-- TOC entry 2120 (class 1259 OID 24814)
-- Name: fki_faceoff_player2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_faceoff_player2 ON faceoff USING btree (player2_id);


--
-- TOC entry 2121 (class 1259 OID 24838)
-- Name: fki_faceoff_winning_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_faceoff_winning_team ON faceoff USING btree (winning_team_id);


--
-- TOC entry 2086 (class 1259 OID 24856)
-- Name: fki_game_away_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_game_away_team ON game USING btree (away_team_id);


--
-- TOC entry 2087 (class 1259 OID 24850)
-- Name: fki_game_home_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_game_home_team ON game USING btree (home_team_id);


--
-- TOC entry 2158 (class 1259 OID 24900)
-- Name: fki_giveaway_game; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_giveaway_game ON giveaway USING btree (game_id);


--
-- TOC entry 2159 (class 1259 OID 24888)
-- Name: fki_giveaway_on_ice_away; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_giveaway_on_ice_away ON giveaway USING btree (on_ice_away);


--
-- TOC entry 2160 (class 1259 OID 24882)
-- Name: fki_giveaway_on_ice_home; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_giveaway_on_ice_home ON giveaway USING btree (on_ice_home);


--
-- TOC entry 2161 (class 1259 OID 24870)
-- Name: fki_giveaway_player; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_giveaway_player ON giveaway USING btree (player_id);


--
-- TOC entry 2162 (class 1259 OID 24876)
-- Name: fki_giveaway_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_giveaway_team ON giveaway USING btree (team_id);


--
-- TOC entry 2090 (class 1259 OID 24912)
-- Name: fki_goal_game; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_goal_game ON goal USING btree (game_id);


--
-- TOC entry 2091 (class 1259 OID 24930)
-- Name: fki_goal_on_ice_away; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_goal_on_ice_away ON goal USING btree (on_ice_away_id);


--
-- TOC entry 2092 (class 1259 OID 24924)
-- Name: fki_goal_on_ice_home; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_goal_on_ice_home ON goal USING btree (on_ice_home_id);


--
-- TOC entry 2093 (class 1259 OID 24906)
-- Name: fki_goal_playerr; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_goal_playerr ON goal USING btree (player_id);


--
-- TOC entry 2094 (class 1259 OID 24918)
-- Name: fki_goal_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_goal_team ON goal USING btree (team_id);


--
-- TOC entry 2122 (class 1259 OID 24960)
-- Name: fki_hit_game; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_hit_game ON hit USING btree (game_id);


--
-- TOC entry 2123 (class 1259 OID 24936)
-- Name: fki_hit_hitted; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_hit_hitted ON hit USING btree (hitted_id);


--
-- TOC entry 2124 (class 1259 OID 24972)
-- Name: fki_hit_hitted_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_hit_hitted_team ON hit USING btree (hitted_team_id);


--
-- TOC entry 2125 (class 1259 OID 24942)
-- Name: fki_hit_hitter; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_hit_hitter ON hit USING btree (hitter_id);


--
-- TOC entry 2126 (class 1259 OID 24966)
-- Name: fki_hit_hitter_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_hit_hitter_team ON hit USING btree (hitter_team_id);


--
-- TOC entry 2127 (class 1259 OID 24954)
-- Name: fki_hit_on_ice_away; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_hit_on_ice_away ON hit USING btree (on_ice_away);


--
-- TOC entry 2128 (class 1259 OID 24948)
-- Name: fki_hit_on_ice_home; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_hit_on_ice_home ON hit USING btree (on_ice_home);


--
-- TOC entry 2144 (class 1259 OID 25002)
-- Name: fki_miss_game; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_miss_game ON miss USING btree (game_id);


--
-- TOC entry 2145 (class 1259 OID 24990)
-- Name: fki_miss_on_ice_away; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_miss_on_ice_away ON miss USING btree (on_ice_away);


--
-- TOC entry 2146 (class 1259 OID 24984)
-- Name: fki_miss_on_ice_home; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_miss_on_ice_home ON miss USING btree (on_ice_home);


--
-- TOC entry 2147 (class 1259 OID 24978)
-- Name: fki_miss_player; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_miss_player ON miss USING btree (player_id);


--
-- TOC entry 2148 (class 1259 OID 24996)
-- Name: fki_miss_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_miss_team ON miss USING btree (team_id);


--
-- TOC entry 2102 (class 1259 OID 25023)
-- Name: fki_onice_defender1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_onice_defender1 ON on_ice USING btree (defender1_id);


--
-- TOC entry 2103 (class 1259 OID 25029)
-- Name: fki_onice_defender2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_onice_defender2 ON on_ice USING btree (defender2_id);


--
-- TOC entry 2104 (class 1259 OID 25035)
-- Name: fki_onice_forward1; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_onice_forward1 ON on_ice USING btree (forward1_id);


--
-- TOC entry 2105 (class 1259 OID 25047)
-- Name: fki_onice_forward2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_onice_forward2 ON on_ice USING btree (forward2_id);


--
-- TOC entry 2106 (class 1259 OID 25041)
-- Name: fki_onice_forward3; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_onice_forward3 ON on_ice USING btree (forward3_id);


--
-- TOC entry 2107 (class 1259 OID 25053)
-- Name: fki_onice_forward_extra; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_onice_forward_extra ON on_ice USING btree (forward_extra_id);


--
-- TOC entry 2108 (class 1259 OID 25011)
-- Name: fki_onice_game; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_onice_game ON on_ice USING btree (game_id);


--
-- TOC entry 2109 (class 1259 OID 25017)
-- Name: fki_onice_goalie; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_onice_goalie ON on_ice USING btree (goalie_id);


--
-- TOC entry 2110 (class 1259 OID 25059)
-- Name: fki_onice_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_onice_team ON on_ice USING btree (team_id);


--
-- TOC entry 2151 (class 1259 OID 25089)
-- Name: fki_penalty_game; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_penalty_game ON penalty USING btree (game_id);


--
-- TOC entry 2152 (class 1259 OID 25083)
-- Name: fki_penalty_on_ice_away; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_penalty_on_ice_away ON penalty USING btree (on_ice_away);


--
-- TOC entry 2153 (class 1259 OID 25077)
-- Name: fki_penalty_on_ice_home; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_penalty_on_ice_home ON penalty USING btree (on_ice_home);


--
-- TOC entry 2154 (class 1259 OID 25065)
-- Name: fki_penalty_player; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_penalty_player ON penalty USING btree (player_id);


--
-- TOC entry 2155 (class 1259 OID 25071)
-- Name: fki_penalty_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_penalty_team ON penalty USING btree (team_id);


--
-- TOC entry 2101 (class 1259 OID 32778)
-- Name: fki_play_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_play_id ON assist USING btree (play_id);


--
-- TOC entry 2169 (class 1259 OID 25095)
-- Name: fki_player_actual_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_player_actual_team ON player USING btree (actual_team_id);


--
-- TOC entry 2131 (class 1259 OID 25101)
-- Name: fki_shot_game; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_shot_game ON shot USING btree (game_id);


--
-- TOC entry 2132 (class 1259 OID 25119)
-- Name: fki_shot_on_ice_away; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_shot_on_ice_away ON shot USING btree (on_ice_away);


--
-- TOC entry 2133 (class 1259 OID 25113)
-- Name: fki_shot_on_ice_home; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_shot_on_ice_home ON shot USING btree (on_ice_home);


--
-- TOC entry 2134 (class 1259 OID 25107)
-- Name: fki_shot_player; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_shot_player ON shot USING btree (player_id);


--
-- TOC entry 2135 (class 1259 OID 25125)
-- Name: fki_shot_team; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_shot_team ON shot USING btree (team_id);


--
-- TOC entry 2165 (class 1259 OID 25137)
-- Name: fki_start_stop_on_ice_away; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_start_stop_on_ice_away ON start_stop USING btree (on_ice_away);


--
-- TOC entry 2166 (class 1259 OID 25131)
-- Name: fki_start_stop_on_ice_home; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_start_stop_on_ice_home ON start_stop USING btree (on_ice_home);


--
-- TOC entry 2181 (class 2606 OID 24737)
-- Name: assist assist_player; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY assist
    ADD CONSTRAINT assist_player FOREIGN KEY (player_id) REFERENCES player(id);


--
-- TOC entry 2182 (class 2606 OID 24749)
-- Name: assist assist_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY assist
    ADD CONSTRAINT assist_team FOREIGN KEY (team_id) REFERENCES team(id);


--
-- TOC entry 2214 (class 2606 OID 24791)
-- Name: block block_blocked_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY block
    ADD CONSTRAINT block_blocked_team FOREIGN KEY (blocked_team_id) REFERENCES team(id);


--
-- TOC entry 2215 (class 2606 OID 24797)
-- Name: block block_blocking_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY block
    ADD CONSTRAINT block_blocking_team FOREIGN KEY (blocking_team_id) REFERENCES team(id);


--
-- TOC entry 2213 (class 2606 OID 24773)
-- Name: block block_player_got_blocked; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY block
    ADD CONSTRAINT block_player_got_blocked FOREIGN KEY (player_got_blocked_id) REFERENCES player(id);


--
-- TOC entry 2212 (class 2606 OID 24767)
-- Name: block block_player_who_blocked; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY block
    ADD CONSTRAINT block_player_who_blocked FOREIGN KEY (player_who_blocked_id) REFERENCES player(id);


--
-- TOC entry 2195 (class 2606 OID 24815)
-- Name: faceoff faceoff_game; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY faceoff
    ADD CONSTRAINT faceoff_game FOREIGN KEY (game_id) REFERENCES game(id);


--
-- TOC entry 2199 (class 2606 OID 24839)
-- Name: faceoff faceoff_losing_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY faceoff
    ADD CONSTRAINT faceoff_losing_team FOREIGN KEY (losing_team_id) REFERENCES team(id);


--
-- TOC entry 2197 (class 2606 OID 24827)
-- Name: faceoff faceoff_on_ice_away; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY faceoff
    ADD CONSTRAINT faceoff_on_ice_away FOREIGN KEY (on_ice_away_id) REFERENCES on_ice(id);


--
-- TOC entry 2196 (class 2606 OID 24821)
-- Name: faceoff faceoff_on_ice_home; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY faceoff
    ADD CONSTRAINT faceoff_on_ice_home FOREIGN KEY (on_ice_home_id) REFERENCES on_ice(id);


--
-- TOC entry 2193 (class 2606 OID 24803)
-- Name: faceoff faceoff_player1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY faceoff
    ADD CONSTRAINT faceoff_player1 FOREIGN KEY (player1_id) REFERENCES player(id);


--
-- TOC entry 2194 (class 2606 OID 24809)
-- Name: faceoff faceoff_player2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY faceoff
    ADD CONSTRAINT faceoff_player2 FOREIGN KEY (player2_id) REFERENCES player(id);


--
-- TOC entry 2198 (class 2606 OID 24833)
-- Name: faceoff faceoff_winning_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY faceoff
    ADD CONSTRAINT faceoff_winning_team FOREIGN KEY (winning_team_id) REFERENCES team(id);


--
-- TOC entry 2175 (class 2606 OID 24851)
-- Name: game game_away_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY game
    ADD CONSTRAINT game_away_team FOREIGN KEY (away_team_id) REFERENCES team(id);


--
-- TOC entry 2174 (class 2606 OID 24845)
-- Name: game game_home_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY game
    ADD CONSTRAINT game_home_team FOREIGN KEY (home_team_id) REFERENCES team(id);


--
-- TOC entry 2230 (class 2606 OID 24895)
-- Name: giveaway giveaway_game; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY giveaway
    ADD CONSTRAINT giveaway_game FOREIGN KEY (game_id) REFERENCES game(id);


--
-- TOC entry 2229 (class 2606 OID 24883)
-- Name: giveaway giveaway_on_ice_away; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY giveaway
    ADD CONSTRAINT giveaway_on_ice_away FOREIGN KEY (on_ice_away) REFERENCES giveaway(id);


--
-- TOC entry 2228 (class 2606 OID 24877)
-- Name: giveaway giveaway_on_ice_home; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY giveaway
    ADD CONSTRAINT giveaway_on_ice_home FOREIGN KEY (on_ice_home) REFERENCES on_ice(id);


--
-- TOC entry 2226 (class 2606 OID 24865)
-- Name: giveaway giveaway_player; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY giveaway
    ADD CONSTRAINT giveaway_player FOREIGN KEY (player_id) REFERENCES player(id);


--
-- TOC entry 2227 (class 2606 OID 24871)
-- Name: giveaway giveaway_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY giveaway
    ADD CONSTRAINT giveaway_team FOREIGN KEY (team_id) REFERENCES team(id);


--
-- TOC entry 2176 (class 2606 OID 24907)
-- Name: goal goal_game; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY goal
    ADD CONSTRAINT goal_game FOREIGN KEY (game_id) REFERENCES game(id);


--
-- TOC entry 2180 (class 2606 OID 24925)
-- Name: goal goal_on_ice_away; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY goal
    ADD CONSTRAINT goal_on_ice_away FOREIGN KEY (on_ice_away_id) REFERENCES on_ice(id);


--
-- TOC entry 2179 (class 2606 OID 24919)
-- Name: goal goal_on_ice_home; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY goal
    ADD CONSTRAINT goal_on_ice_home FOREIGN KEY (on_ice_home_id) REFERENCES on_ice(id);


--
-- TOC entry 2177 (class 2606 OID 24901)
-- Name: goal goal_player; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY goal
    ADD CONSTRAINT goal_player FOREIGN KEY (player_id) REFERENCES player(id);


--
-- TOC entry 2178 (class 2606 OID 24913)
-- Name: goal goal_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY goal
    ADD CONSTRAINT goal_team FOREIGN KEY (team_id) REFERENCES team(id);


--
-- TOC entry 2204 (class 2606 OID 24955)
-- Name: hit hit_game; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hit
    ADD CONSTRAINT hit_game FOREIGN KEY (game_id) REFERENCES game(id);


--
-- TOC entry 2200 (class 2606 OID 24931)
-- Name: hit hit_hitted; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hit
    ADD CONSTRAINT hit_hitted FOREIGN KEY (hitted_id) REFERENCES player(id);


--
-- TOC entry 2206 (class 2606 OID 24967)
-- Name: hit hit_hitted_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hit
    ADD CONSTRAINT hit_hitted_team FOREIGN KEY (hitted_team_id) REFERENCES team(id);


--
-- TOC entry 2201 (class 2606 OID 24937)
-- Name: hit hit_hitter; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hit
    ADD CONSTRAINT hit_hitter FOREIGN KEY (hitter_id) REFERENCES player(id);


--
-- TOC entry 2205 (class 2606 OID 24961)
-- Name: hit hit_hitter_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hit
    ADD CONSTRAINT hit_hitter_team FOREIGN KEY (hitter_team_id) REFERENCES team(id);


--
-- TOC entry 2203 (class 2606 OID 24949)
-- Name: hit hit_on_ice_away; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hit
    ADD CONSTRAINT hit_on_ice_away FOREIGN KEY (on_ice_away) REFERENCES on_ice(id);


--
-- TOC entry 2202 (class 2606 OID 24943)
-- Name: hit hit_on_ice_home; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY hit
    ADD CONSTRAINT hit_on_ice_home FOREIGN KEY (on_ice_home) REFERENCES on_ice(id);


--
-- TOC entry 2220 (class 2606 OID 24997)
-- Name: miss miss_game; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY miss
    ADD CONSTRAINT miss_game FOREIGN KEY (game_id) REFERENCES game(id);


--
-- TOC entry 2218 (class 2606 OID 24985)
-- Name: miss miss_on_ice_away; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY miss
    ADD CONSTRAINT miss_on_ice_away FOREIGN KEY (on_ice_away) REFERENCES on_ice(id);


--
-- TOC entry 2217 (class 2606 OID 24979)
-- Name: miss miss_on_ice_home; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY miss
    ADD CONSTRAINT miss_on_ice_home FOREIGN KEY (on_ice_home) REFERENCES on_ice(id);


--
-- TOC entry 2216 (class 2606 OID 24973)
-- Name: miss miss_player; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY miss
    ADD CONSTRAINT miss_player FOREIGN KEY (player_id) REFERENCES player(id);


--
-- TOC entry 2219 (class 2606 OID 24991)
-- Name: miss miss_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY miss
    ADD CONSTRAINT miss_team FOREIGN KEY (team_id) REFERENCES team(id);


--
-- TOC entry 2186 (class 2606 OID 25018)
-- Name: on_ice onice_defender1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY on_ice
    ADD CONSTRAINT onice_defender1 FOREIGN KEY (defender1_id) REFERENCES player(id);


--
-- TOC entry 2187 (class 2606 OID 25024)
-- Name: on_ice onice_defender2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY on_ice
    ADD CONSTRAINT onice_defender2 FOREIGN KEY (defender2_id) REFERENCES player(id);


--
-- TOC entry 2188 (class 2606 OID 25030)
-- Name: on_ice onice_forward1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY on_ice
    ADD CONSTRAINT onice_forward1 FOREIGN KEY (forward1_id) REFERENCES player(id);


--
-- TOC entry 2190 (class 2606 OID 25042)
-- Name: on_ice onice_forward2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY on_ice
    ADD CONSTRAINT onice_forward2 FOREIGN KEY (forward2_id) REFERENCES player(id);


--
-- TOC entry 2189 (class 2606 OID 25036)
-- Name: on_ice onice_forward3; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY on_ice
    ADD CONSTRAINT onice_forward3 FOREIGN KEY (forward3_id) REFERENCES player(id);


--
-- TOC entry 2191 (class 2606 OID 25048)
-- Name: on_ice onice_forward_extra; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY on_ice
    ADD CONSTRAINT onice_forward_extra FOREIGN KEY (forward_extra_id) REFERENCES player(id);


--
-- TOC entry 2184 (class 2606 OID 25006)
-- Name: on_ice onice_game; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY on_ice
    ADD CONSTRAINT onice_game FOREIGN KEY (game_id) REFERENCES game(id);


--
-- TOC entry 2185 (class 2606 OID 25012)
-- Name: on_ice onice_goalie; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY on_ice
    ADD CONSTRAINT onice_goalie FOREIGN KEY (goalie_id) REFERENCES player(id);


--
-- TOC entry 2192 (class 2606 OID 25054)
-- Name: on_ice onice_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY on_ice
    ADD CONSTRAINT onice_team FOREIGN KEY (team_id) REFERENCES team(id);


--
-- TOC entry 2225 (class 2606 OID 25084)
-- Name: penalty penalty_game; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY penalty
    ADD CONSTRAINT penalty_game FOREIGN KEY (game_id) REFERENCES game(id);


--
-- TOC entry 2224 (class 2606 OID 25078)
-- Name: penalty penalty_on_ice_away; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY penalty
    ADD CONSTRAINT penalty_on_ice_away FOREIGN KEY (on_ice_away) REFERENCES on_ice(id);


--
-- TOC entry 2223 (class 2606 OID 25072)
-- Name: penalty penalty_on_ice_home; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY penalty
    ADD CONSTRAINT penalty_on_ice_home FOREIGN KEY (on_ice_home) REFERENCES on_ice(id);


--
-- TOC entry 2221 (class 2606 OID 25060)
-- Name: penalty penalty_player; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY penalty
    ADD CONSTRAINT penalty_player FOREIGN KEY (player_id) REFERENCES player(id);


--
-- TOC entry 2222 (class 2606 OID 25066)
-- Name: penalty penalty_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY penalty
    ADD CONSTRAINT penalty_team FOREIGN KEY (team_id) REFERENCES team(id);


--
-- TOC entry 2183 (class 2606 OID 32773)
-- Name: assist play_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY assist
    ADD CONSTRAINT play_id FOREIGN KEY (play_id) REFERENCES play(id);


--
-- TOC entry 2233 (class 2606 OID 25090)
-- Name: player player_actual_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY player
    ADD CONSTRAINT player_actual_team FOREIGN KEY (actual_team_id) REFERENCES team(id);


--
-- TOC entry 2207 (class 2606 OID 25096)
-- Name: shot shot_game; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY shot
    ADD CONSTRAINT shot_game FOREIGN KEY (game_id) REFERENCES game(id);


--
-- TOC entry 2210 (class 2606 OID 25114)
-- Name: shot shot_on_ice_away; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY shot
    ADD CONSTRAINT shot_on_ice_away FOREIGN KEY (on_ice_away) REFERENCES on_ice(id);


--
-- TOC entry 2209 (class 2606 OID 25108)
-- Name: shot shot_on_ice_home; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY shot
    ADD CONSTRAINT shot_on_ice_home FOREIGN KEY (on_ice_home) REFERENCES on_ice(id);


--
-- TOC entry 2208 (class 2606 OID 25102)
-- Name: shot shot_player; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY shot
    ADD CONSTRAINT shot_player FOREIGN KEY (player_id) REFERENCES player(id);


--
-- TOC entry 2211 (class 2606 OID 25120)
-- Name: shot shot_team; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY shot
    ADD CONSTRAINT shot_team FOREIGN KEY (team_id) REFERENCES team(id);


--
-- TOC entry 2232 (class 2606 OID 25132)
-- Name: start_stop start_stop_on_ice_away; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY start_stop
    ADD CONSTRAINT start_stop_on_ice_away FOREIGN KEY (on_ice_away) REFERENCES on_ice(id);


--
-- TOC entry 2231 (class 2606 OID 25126)
-- Name: start_stop start_stop_on_ice_home; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY start_stop
    ADD CONSTRAINT start_stop_on_ice_home FOREIGN KEY (on_ice_home) REFERENCES on_ice(id);


-- Completed on 2017-08-09 13:30:03

--
-- PostgreSQL database dump complete
--

