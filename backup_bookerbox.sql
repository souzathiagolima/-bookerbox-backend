--
-- PostgreSQL database dump
--

\restrict nWZA2rnvFfC6PWjX4cMkWVmA3c2mLt4uMQU43OBWVTjp8F9nYL6LgnrdWPAWQ0b

-- Dumped from database version 18.4 (Debian 18.4-1.pgdg12+1)
-- Dumped by pg_dump version 18.6

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: bookerbox_db_user
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO bookerbox_db_user;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: shelf_status; Type: TYPE; Schema: public; Owner: bookerbox_db_user
--

CREATE TYPE public.shelf_status AS ENUM (
    'want',
    'reading',
    'read'
);


ALTER TYPE public.shelf_status OWNER TO bookerbox_db_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: books; Type: TABLE; Schema: public; Owner: bookerbox_db_user
--

CREATE TABLE public.books (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    google_books_id text,
    title text NOT NULL,
    authors text,
    cover_url text,
    description text,
    isbn text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    categories text
);


ALTER TABLE public.books OWNER TO bookerbox_db_user;

--
-- Name: follows; Type: TABLE; Schema: public; Owner: bookerbox_db_user
--

CREATE TABLE public.follows (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    follower_id uuid NOT NULL,
    following_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT follows_check CHECK ((follower_id <> following_id))
);


ALTER TABLE public.follows OWNER TO bookerbox_db_user;

--
-- Name: likes; Type: TABLE; Schema: public; Owner: bookerbox_db_user
--

CREATE TABLE public.likes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    review_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.likes OWNER TO bookerbox_db_user;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: bookerbox_db_user
--

CREATE TABLE public.notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    type text NOT NULL,
    payload jsonb,
    read boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.notifications OWNER TO bookerbox_db_user;

--
-- Name: reviews; Type: TABLE; Schema: public; Owner: bookerbox_db_user
--

CREATE TABLE public.reviews (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    book_id uuid NOT NULL,
    rating smallint NOT NULL,
    text text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.reviews OWNER TO bookerbox_db_user;

--
-- Name: shelves; Type: TABLE; Schema: public; Owner: bookerbox_db_user
--

CREATE TABLE public.shelves (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    book_id uuid NOT NULL,
    status public.shelf_status NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.shelves OWNER TO bookerbox_db_user;

--
-- Name: users; Type: TABLE; Schema: public; Owner: bookerbox_db_user
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    password_hash text,
    avatar_url text,
    facebook_id text,
    apple_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    google_id text
);


ALTER TABLE public.users OWNER TO bookerbox_db_user;

--
-- Data for Name: books; Type: TABLE DATA; Schema: public; Owner: bookerbox_db_user
--

COPY public.books (id, google_books_id, title, authors, cover_url, description, isbn, created_at, categories) FROM stdin;
ddd1ed3b-b0c2-48f5-b271-8d65b657cbc9	eMU6AQAAIAAJ	Tamara Hood Et Al., Plaintiffs and Appellants, V. the National Enquirer, Inc. Et Al., Defendants and Respondents	Tamara Hood	https://books.google.com/books/content?id=eMU6AQAAIAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api	\N	\N	2026-08-16 16:53:46.106956+00	\N
d6a7925c-2d6c-4d52-9a53-540c2efd0451	K88MAQAAIAAJ	Yama The Pit	Александр Иванович Куприн	https://books.google.com/books/content?id=K88MAQAAIAAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	A social novel about the horrors of prostitution.	\N	2026-08-16 16:53:46.109191+00	\N
ee6cb21a-4bf3-473b-acc6-9d1d33e4c410	LUH_tDybtZkC	People of the State of Illinois V. Hill	\N	https://books.google.com/books/content?id=LUH_tDybtZkC&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	\N	\N	2026-08-16 16:53:46.11102+00	\N
c66ad8fc-09c7-4626-ae81-2c6a8a0d55d7	aOqMEAAAQBAJ	Harry Potter and the Half-Blood Prince	J.K. Rowling	https://books.google.com/books/content?id=aOqMEAAAQBAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api	Harry Potter begins his sixth year at Hogwarts School of Witchcraft and Wizardry in an atmosphere of uncertainty, as the magical world begins to face the fact that the evil wizard Voldemort is alive and active once again.	9780307283658	2026-08-16 16:53:32.014212+00	\N
8f423e12-32ef-4017-bb00-ed3ccc897f2f	nmXTy4FPfcwC	Harry Potter and the Chamber of Secrets	J. K. Rowling	https://books.google.com/books/content?id=nmXTy4FPfcwC&printsec=frontcover&img=1&zoom=1&source=gbs_api	Witchcraft, wizardry - fiction.	9781551922447	2026-08-16 16:53:32.016331+00	\N
7006821e-9f36-4e42-ba17-979e3e73cc08	Wlp0nAEACAAJ	Harry Potter and the Prisoner of Azkaban	J. K. Rowling	https://books.google.com/books/content?id=Wlp0nAEACAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api	Sequel to: Harry Potter and the Chamber of Secrets.	9780606323475	2026-08-16 16:53:32.020489+00	\N
09389fa8-91f0-44f5-9306-f2c5474b6bbf	wyjkzQEACAAJ	Harry Potter and the Deathly Hallows - Hufflepuff Edition	J. K. Rowling	https://books.google.com/books/content?id=wyjkzQEACAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api	\N	9781526618344	2026-08-16 16:53:32.022482+00	\N
ebce31ad-3b10-4c30-8317-619ad318e4eb	h_zfzQEACAAJ	Harry Potter and the Deathly Hallows - Ravenclaw Edition	J. K. Rowling	https://books.google.com/books/content?id=h_zfzQEACAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api	\N	9781526618320	2026-08-16 16:53:32.024461+00	\N
0039a763-6260-4261-a75b-ad16d4e277cb	WA-wzQEACAAJ	Harry Potter and the Half-Blood Prince - Ravenclaw Edition	J. K. Rowling	https://books.google.com/books/content?id=WA-wzQEACAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api	\N	9781526618269	2026-08-16 16:53:32.026697+00	\N
08544609-b6af-4794-b4d4-670a35108b2c	OXfvzQEACAAJ	Harry Potter and the Deathly Hallows - Gryffindor Edition	J. K. Rowling	https://books.google.com/books/content?id=OXfvzQEACAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api	\N	9781526618306	2026-08-16 16:53:32.028697+00	\N
70d6f221-5bcd-443c-994d-679243637f46	eEXizQEACAAJ	Harry Potter and the Deathly Hallows - Slytherin Edition	J. K. Rowling	https://books.google.com/books/content?id=eEXizQEACAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api	\N	9781526618368	2026-08-16 16:53:32.032555+00	\N
2efc1d04-0954-4a82-86db-82ff5ea3db72	n3vng7gyGCYC	Harry Potter	\N	https://books.google.com/books/content?id=n3vng7gyGCYC&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	\N	\N	2026-08-16 16:53:32.03455+00	\N
1b08ffe1-6f7f-4fd2-b078-af42177bc5ee	CPJJAQAACAAJ	Harry Potter and the Sorcerer's Stone	J. K. Rowling	https://books.google.com/books/content?id=CPJJAQAACAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api	Rescued from the outrageous neglect of his aunt and uncle, a young boy with a great destiny proves his worth while attending Hogwarts School for Witchcraft and Wizardry.	9780545919661	2026-08-16 16:53:32.036467+00	\N
2f246dc8-a6ee-41ba-924d-b02006521c8e	NWSwzQEACAAJ	Harry Potter and the Half-Blood Prince - Hufflepuff Edition	J. K. Rowling	https://books.google.com/books/content?id=NWSwzQEACAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api	Suspicion and fear blow through the wizarding world as news of the Dark Lord's attack on the Ministry of Magic spreads. Harry has not told anyone about the future predicted by the prophecy in the Department of Mysteries, nor how deeply what happened to Sirius Black affected him. He's desperate for Professor Dumbledore to arrive and take him away from the Dursley's but Hogwarts may not be the safe haven from Voldemort's Dark Forces that it once was. In his sixth year, the names Black, Malfoy, Lestrange and Snape will haunt Harry with shades of trust and treachery as he discovers the secret behind the mysterious Half-Blood Prince and Dumbledore prepares him to face his own terrifying destiny.	9781526618252	2026-08-16 16:53:32.038529+00	\N
425bc67d-56df-4c04-bdec-1bc171ebe8a4	7zeyHAAACAAJ	Harry Potter et la coupe de feu	J. K. Rowling, Jean-François Ménard	https://books.google.com/books/content?id=7zeyHAAACAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api	Harry Potter a quatorze ans et il entre en quatrième année au collège de Poudlard. Une grande nouvelle attend Harry, Ron et Hermione à leur arrivée : la tenue d'un tournoi de magie exceptionnel entre les plus célèbres écoles de sorcellerie. Déjà, les délégations étrangères font leur entrée. Harry se réjouit... Trop vite. Il va se trouver plongé au cœur des événements les plus dramatiques qu'il ait jamais eu à affronter. Fascinant, drôle, bouleversant, ce quatrième tome est le pilier central des aventures de Harry Potter.	9782070543519	2026-08-16 16:53:32.040342+00	\N
272c8427-aade-409e-9050-22bc97def29f	3jD4EQAAQBAJ	Tamara	Dr. Valkyrie Scheidl	https://books.google.com/books/content?id=3jD4EQAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	In the golden halls of Asgard, love is the bravest rebellion. Tamara, a legendary warrior forged in storms, and Kavita, the goddess of Art and Healing, have defied tradition to build a family in a realm that worships strength and fears change. But as their wedding ignites both celebration and silent fury, shadows gather at the edge of paradise. When prejudice turns to violence, hatred ignites a city and the pyre is built for those who dare to love, Tamara and Kavita must summon every ounce of courage, hope, and magic to survive. As the flames rise and the world teeters on the edge of ruin, it is the unbreakable bond between two women and the miracle of a child’s love that may yet save Asgard from itself. Will love be their downfall or Asgard’s salvation? A story of devotion, heartbreak, and the courage to love against all odds.	\N	2026-08-16 16:53:46.082724+00	\N
ee4c7644-5ceb-468b-a5f0-0d4620f9ffdf	3icDcgAACAAJ	Tamara	Canadian Stage Theatre Archives (University of Guelph), Moses Znaimer, John Krizanc, Richard Rose, CentreStage	\N	\N	\N	2026-08-16 16:53:46.085998+00	\N
4630a7f8-65e0-4542-aedf-55fbe450b7a0	KPeJ6OmNcsYC	Tamara Drewe	Posy Simmonds	https://books.google.com/books/content?id=KPeJ6OmNcsYC&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	Tamara Drew is loosely inspired by a 19th century novel -- Far From the Madding Crowd. Set in a writers' retreat, it is a thrilling tale of jealousy and desire.	9780547154121	2026-08-16 16:53:46.088276+00	\N
19964cb0-3c53-43d5-97a1-a0afe6b1f9fd	kZTTDwAAQBAJ	Tamara's Teardrops 1-4	P.D. Workman	https://books.google.com/books/content?id=kZTTDwAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	Follow Tamara French as she struggles to overcome the challenges of her past and reintegrate into the normal world. This set includes: 1. Tattooed Teardrops Winner of Top Fiction Award, In the Margins Committee, 2016. Tamara had thought that when she got out of juvie, things would be easier. But before long, it seems like her life is spiraling into chaos. 2. Two Teardrops Returning to juvie after breaching her parole, Tamara finds that everything is the same as when she left, and yet everything is different. She fights to reestablish her rep while increasingly troubled by emerging memories. 3. Tortured Teardrops Tamara French is back in juvenile detention, and things are not going well. Have her experiences on the outside affected her so much? The staff can’t figure out what is wrong, and Tamara herself can’t explain what is going on with her. 4. Vanishing Teardrops It was her second chance at parole, and Tamara knew this time that it wasn’t going to be easy. That ended up being the understatement of the century. In a new environment, trying to be a parent for the first time after years of not being allowed to make any decisions for herself, she didn’t know how she was going to make it.	9781989415528	2026-08-16 16:53:46.090295+00	\N
4a789e9c-5793-49c0-8f4a-7234af3a0c20	lpOnswEACAAJ	Tamara	Richard Rose Collection	\N	\N	\N	2026-08-16 16:53:46.092278+00	\N
573aecb6-04c8-4512-b37f-c50d0637cc3f	eYn6tccAs24C	TAMARA J. RADTKE V STUART B. EVERETT, D.V.M., 442 MICH 368 (1993)	\N	https://books.google.com/books/content?id=eYn6tccAs24C&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	92582	\N	2026-08-16 16:53:46.09419+00	\N
3b35f993-df3f-41f1-9f85-8d3a0c0bd135	DykGPQAACAAJ	Tamara	Eeva Kilpi, Binham, Philip	\N	\N	9780671825713	2026-08-16 16:53:46.096298+00	\N
86c1e59e-cb36-4ee8-8221-dce579a5cc21	lMyqzAEACAAJ	Tamara	John Krizanc	https://books.google.com/books/content?id=lMyqzAEACAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api	Now available in a handsome A List edition, John Krizanc's internationally acclaimed experimental play that redefined the limits of theatre with its haunting tale of art, sex, violence, and political intrigue in Fascist Italy.	9781487008482	2026-08-16 16:53:46.098281+00	\N
a3567d42-0847-42e3-90ae-b9eaccfd1a3d	MW2KuQAACAAJ	The Definition of Tamara	Tamara Smith	https://books.google.com/books/content?id=MW2KuQAACAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api	Book Summary In this book, The Definition of Tamara: The Resilient Palm Tree, author Tamara Smith shares optimism and hopefulness that will inspire readers to confidently face each daily challenge that life brings into being. While this may be viewed as an eccentric outlook on encountering life's obstacles it's much needed in the somewhat pessimistic world we live in today. Utilizing personal stories and factual information, Tamara discusses sensitive issues of sexual abuse, domestic violence, and physical illnesses and demonstrates how the use of religion and support systems during periods of stress in one's life is the pathway to resiliency.	9781469166025	2026-08-16 16:53:46.100321+00	\N
f9e86b68-1cf4-49e3-b9cf-a5f6ebbca920	hSZABAAACAAJ	Tamara K.E.	K. E. Tamara	\N	\N	9783939583134	2026-08-16 16:53:46.102223+00	\N
d85f5d92-d73c-466d-8a53-12ae1d1ee58d	3QVXskNQefMC	California. Court of Appeal (2nd Appellate District). Records and Briefs	California (State).	https://books.google.com/books/content?id=3QVXskNQefMC&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	\N	\N	2026-08-16 16:53:46.104159+00	\N
ac9bd4a4-927b-4474-a530-24cb0f10a856	HbhVAAAAYAAJ	National Journal	\N	https://books.google.com/books/content?id=HbhVAAAAYAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api	\N	\N	2026-08-16 16:53:51.503257+00	\N
faf1788a-8a06-4cc2-a578-3c311597d799	9dbPAQAACAAJ	Harry Potter and the Half-Blood Prince	J. K. Rowling	https://books.google.com/books/content?id=9dbPAQAACAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api	Harry Potter begins his sixth year at Hogwarts School of Witchcraft and Wizardry in an atmosphere of uncertainty, as the magical world begins to face the fact that the evil wizard Voldemort is alive and active once again.	9781417751396	2026-08-16 16:53:32.044609+00	\N
6663825d-f072-4145-9828-0cc905ed865f	aban8lZ3kRcC	The Magical Worlds of Harry Potter	David Colbert	https://books.google.com/books/content?id=aban8lZ3kRcC&printsec=frontcover&img=1&zoom=1&source=gbs_api	Explores the true history, folklore and mythology behind the magical practices, creatures, and personalities that appear in J.K. Rowling's Harry Potter books.	9780425198919	2026-08-16 16:53:32.046461+00	\N
3febc5c9-f4ef-42a0-b18d-ce4905420a51	TSPcEQAAQBAJ	Harry Potter and Genocide	Jeffrey S. Bachman	https://books.google.com/books/content?id=TSPcEQAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	This book is a go-to source for educators, including those in late-primary education, secondary education, and undergraduate higher education, interested in teaching genocide studies. The author makes the subject more accessible for students, as well as for educators who do not have a background in this subarea. Each chapter includes discussion questions, research prompts, and suggestions for further reading. The book will also appeal to fans of the Harry Potter series.	9783032185518	2026-08-16 16:53:32.0484+00	\N
e5e4564f-6293-4922-8083-e3e92b83527d	sxBI9z9pgPIC	A perambulation of the Antient and Royal Forest of Dartmoor and the Venville Precincts or a Topographical Survey of their Antiquities a. Scenery by the late Samuel Rowe, M. A.	Samuel Rowe	https://books.google.com/books/content?id=sxBI9z9pgPIC&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	\N	\N	2026-08-16 16:53:46.113079+00	\N
da463d81-c6e6-468b-a236-96c41f62d992	-bQzsl89n3sC	California. Court of Appeal (1st Appellate District). Records and Briefs	California (State).	https://books.google.com/books/content?id=-bQzsl89n3sC&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	\N	\N	2026-08-16 16:53:46.115048+00	\N
ca17be12-bca3-4c93-9f38-7071e5aaf824	BLfb6akAqycC	California. Supreme Court. Records and Briefs	California (State).	https://books.google.com/books/content?id=BLfb6akAqycC&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	Court of Appeal Case(s): C000007	\N	2026-08-16 16:53:46.11697+00	\N
c03c345f-6a3c-41a3-9182-bd5d768b4d5c	5m8uAAAAMAAJ	The American History and Encyclopedia of Music ...	William Lines Hubbard, George Whitfield Andrews, Edward Dickinson, Arthur Foote, Emil Liebling	https://books.google.com/books/content?id=5m8uAAAAMAAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	\N	\N	2026-08-16 16:53:46.118934+00	\N
c2866774-9877-4294-b4a4-7d123fe6a068	ivA_AAAAYAAJ	The New Day	Scudder Middleton	https://books.google.com/books/content?id=ivA_AAAAYAAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	\N	\N	2026-08-16 16:53:46.120762+00	\N
2570d7b8-4f56-45b1-9e6c-ceb84ce8eb71	ll9FAQAAMAAJ	The American History and Encyclopedia of Music	\N	https://books.google.com/books/content?id=ll9FAQAAMAAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	\N	\N	2026-08-16 16:53:46.122612+00	\N
959d1d95-1857-4903-aa52-552d95da4315	iy_KEQAAQBAJ	Bom dia, inverno	Tamara Klink	https://books.google.com/books/content?id=iy_KEQAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	Durante oito meses, Tamara Klink viveu sozinha num pequeno veleiro preso no mar congelado do Ártico Groenlandês. Depois de uma longa preparação e de atravessar o oceano desviando de icebergs, ela ancorou em um fiorde escuro sem saber se estava pronta para o que iria encontrar. O que acontece quando ficamos sozinhos, sem ter para quem sorrir? Quando passamos longos dias sem ver o Sol? Quando somos o ser vivo menos apto a sobreviver no lugar onde estamos? Depois de se tornar a pessoa mais jovem da América Latina a cruzar o Atlântico em solitário, a navegadora e escritora Tamara Klink se lançou numa nova navegação: em vez de atravessar o espaço, dessa vez atravessaria o tempo. Isolada em um fiorde na Groenlândia na época mais fria do ano, ela pôde observar o inverno polar transformar o mar em terra e os dias em noites infinitas. Em Bom dia, inverno, os leitores são convidados a conhecer de perto os perigos e as alegrias dessa viagem extremamente arriscada. Nessa experiência de isolamento radical, em meio a auroras boreais e visitas inesperadas de raposas, focas e outros animais selvagens, o silêncio se torna palco para reflexões profundas sobre a liberdade, a cultura, o futuro do planeta e o modo como escolhemos viver.	9788535946529	2026-08-16 16:53:51.464155+00	\N
25f02809-6da8-42d3-9797-af63ab7bae80	czIbEQAAQBAJ	Catálogo Infantojuvenil da Peirópolis	Editora Peirópolis	https://books.google.com/books/content?id=czIbEQAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	O catálogo da Editora Peirópolis apresenta seus livros, um a um, de modo a facilitar a melhor escolha do adulto que pretende fazer uma leitura compartilhada, contar uma história ou incentivar a leitura de histórias, tendo em vista a formação do leitor no decorrer de sua infância e adolescência.	9786559313020	2026-08-16 16:53:51.466671+00	\N
cc24ec89-59a5-4908-af8d-3a421ec6bf37	CoFmEQAAQBAJ	Shackleton: Uma biografia	Ranulph Fiennes	https://books.google.com/books/content?id=CoFmEQAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	No início do século XX, Shackleton viajou quatro vezes à Antártida. Embora as missões tenham fracassado em seus objetivos, o navegador se tornou uma lenda, graças à sua impressionante habilidade como líder. Narrado pelo escritor e explorador Ranulph Fiennes, este livro segue os passos de um homem que não conhecia o medo e viveu de forma extraordinária. Ranulph Fiennes conta que existe uma palavra em dinamarquês — polarhullar — que pode ser traduzida como um "forte desejo pelas regiões polares". Na virada do século XX, grandes navegadores empenharam-se em alcançar essas áreas remotas, movidos pela ambição de fazer fortuna, estabelecer recordes e conquistar prestígio. Ernest Shackleton sintetizou bem esse impulso: "É privilégio de poucos homens ver terras nunca vistas por olhos humanos." Do ponto de vista prático, as empreitadas de Shackleton não foram exatamente bem-sucedidas. A mais célebre, a bordo do Endurance, em 1914, fracassou pouco antes de efetivamente começar. Com o navio preso no gelo antes de alcançar a Antártida, a missão precisou ser abortada. A tripulação, então, viu-se à deriva, sem comunicação com o mundo externo e sem perspectiva de resgate, enfrentando, ao todo, 22 meses de privação extrema. Graças ao entusiasmo, à coragem, à inteligência e à prudência de Shackleton, a viagem teve final feliz, com o retorno para casa de todos os membros do Endurance — vivos. Nesta biografia eletrizante, narrada por Ranulph Fiennes – ele próprio um viajante experiente, que também enfrentou os desafios do continente gelado –, acompanhamos de perto os percalços e as conquistas de uma vida surpreendente e inspiradora.	9788535942729	2026-08-16 16:53:51.470367+00	\N
5db20790-02c6-4765-9691-5dabfec05633	GXqEEAAAQBAJ	Aldeia Ed.163	Editora Aldeia	https://books.google.com/books/content?id=GXqEEAAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	Primato e os desafios que constroem a história da empresa. Adetur, as perspectivas para o desenvolvimento do turismo no Paraná. Processos e histórias na produção de queijos finos. A empresa têxtil Seven, lançamento de livro e colunas mensais.	\N	2026-08-16 16:53:51.47238+00	\N
b96f652b-02c5-44d3-9bf7-215e888fa9c2	bWRZAAAAMAAJ	Science Fiction, Horror & Fantasy Film and Television Credits: Television shows	Harris M. Lentz (III.)	https://books.google.com/books/content?id=bWRZAAAAMAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api	\N	\N	2026-08-16 16:53:51.474373+00	\N
3f87085c-eaa0-4bfe-be43-531718f614af	7hOkDAAAQBAJ	Vacation in Antarctica	Laura Klink, Tamara Klink, Marininha Klink	https://books.google.com/books/content?id=7hOkDAAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	Every child likes to listen to stories, and to tell stories too. But the stories by sisters Laura, Tamara, and Marininha do not speak of kings, queens, princes or princesses, though the plot is really charming. They speak of super-special holidays aboard sailboat Parati 2, built by their renowned father Amyr Klink. Here they recall five family expeditions to the Antarctic Continent, where seals, penguins, whales, and many other animals spend their summer. Besides logging all the information on their journey, this book brings about important considerations on nature and how our attitude may reflect upon the entire planet.	9788575964309	2026-08-16 16:53:51.476938+00	\N
6086eb9e-2979-47a3-9b57-7c9f8330c3a9	LvgPYetj6NYC	Baltimore-Annapolis 1997-98	R. Willson Hardy	https://books.google.com/books/content?id=LvgPYetj6NYC&printsec=frontcover&img=1&zoom=1&source=gbs_api	\N	9781880873267	2026-08-16 16:53:51.505098+00	\N
9767ae8e-5b5d-478a-ace0-e9964e2c41e6	7f5kDwAAQBAJ	Sem título	\N	https://books.google.com/books/content?id=7f5kDwAAQBAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api	\N	9781526602381	2026-08-16 16:53:32.005161+00	\N
f6fce294-959f-4b8b-9800-6430a57f68f7	GZAoAQAAIAAJ	Harry Potter and the Deathly Hallows	J. K. Rowling	https://books.google.com/books/content?id=GZAoAQAAIAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api	"The final adventure in J.K. Rowling's phenomenal, best-selling Harry Potter book series"--Provided by publisher.	\N	2026-08-16 16:53:32.011974+00	\N
38377a28-3061-4b00-b90c-8fbc3fbbb910	Z_dgEAAAQBAJ	Crescer e Partir	Tamara Klink	https://books.google.com/books/content?id=Z_dgEAAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	Tamara Klink viaja desde pequena na companhia da família. Mas sempre planejou "navegar consigo mesma", e foi construindo as condições para isso enquanto crescia. Aos 24 anos, formou-se em arquitetura naval em Nantes, na França, e concluiu sua primeira viagem em solitário pelo Mar do Norte – detalhe: no próprio veleiro, recém-adquirido e apelidado Sardinha. Seus relatos em prosa, traço e verso estão reunidos neste box com os dois livros da autora: Mil milhas , com poemas, desenhos e o relato da viagem, e o livro Um mundo em poucas linhas , com poemas e textos em prosa poética sobre as viagens realizadas em família e as diferentes travessias que fez ao longo da vida. Em Mil Milhas , acompanhamos Tamara em sua travessia geográfica, heroica e pessoal durante os meses em que preparou e realizou a viagem. Temos em mãos o diário que ela escreveu ao longo das mil milhas percorridas. Em seus escritos, ela nos conta não apenas sobre como navegou pelo mar do Norte e enfrentou desafios sozinha em seu pequeno e primeiro barco, colhendo medos e alegrias, mas também sobre como essa viagem significou poder crescer e dar-se conta da própria envergadura: virar adulta. Travessia que todos nós precisamos realizar em vida, onde quer que estejamos e por onde escolhemos realizar nosso trajeto: na terra ou no mar. Em Um mundo em poucas linhas , Tamara nos mostra tudo aquilo que se pode sentir ao crescer: reconhecer as raízes ao estar só, sentir saudade e desejar voltar, descobrir-se capaz e querer seguir, colocar-se em dúvida, atravessar e se firmar em suas escolhas e travessias. E, assim, os escritos de Tamara nos contam que viver parece com deslocar-se e experimentar. Este livro ressoa não apenas em jovens leitores, que vivem intensamente as mudanças provocadas pelo crescimento e suas descobertas, mas também naqueles que sabem reconhecer a vida como um eterno movimento de crescer e partir para novos recomeços.	9786559311040	2026-08-16 16:53:51.478802+00	\N
48a423d4-caea-48d0-a9ca-3e2bd5972014	CT6-EAAAQBAJ	Nós	Tamara Klink	https://books.google.com/books/content?id=CT6-EAAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	Aos 24 anos, Tamara Klink tornou-se a pessoa mais jovem do Brasil a cruzar o Atlântico sozinha. Nós descreve os triunfos e percalços dessa expedição. Em 2021, em plena pandemia, a navegadora Tamara Klink partiu da França com o objetivo de chegar até a costa brasileira pelo mar. Nessa empreitada ambiciosa, contou apenas com a companhia permanente de seu caderno e do barco, Sardinha. À distância, teve o apoio (e também a preocupação) constante da família, dos amigos, de Henrique — conselheiro de primeira hora —, e dos admiradores nas redes sociais, que seguiram a viagem praticamente em tempo real. Em meio a vitórias, fracassos, temores e desvios de percurso, este livro nos convida a embarcar numa jornada corajosa, feita de deslocamentos físicos, mas sobretudo de impressionantes superações psicológicas.	9788535935240	2026-08-16 16:53:51.48091+00	\N
4b060fa1-9138-4597-9e37-00a505394363	tZVOEAAAQBAJ	Mil milhas	Tamara Klink	https://books.google.com/books/content?id=tZVOEAAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	A preparação foi longa. Durou precisamente 24 anos para que a jovem Tamara Klink se descobrisse finalmente pronta para a partida para a sua primeira viagem em solitário, da Noruega até a França, no pequeno e recém-adquirido veleiro a que chamou Sardinha, o passo inaugural na direção do sonho de tornar-se uma navegadora. Foi o tempo de crescer, de entender e acalentar seus próprios sonhos e tomar suas decisões, ir e voltar graças a seu próprio desejo. Estar distante da família para entender-se parte dela. O livro mistura relatos de viagem, poemas e desenhos que revelam a intimidade e os desafios dessa viagem que, embora planejada, trouxe enormes desafios e aprendizados para a velejadora.	9786559311064	2026-08-16 16:53:51.482749+00	\N
bb259a5a-dc91-4046-bc07-37220bba62b4	rhEcAQAAMAAJ	National Roster of Realtors	\N	https://books.google.com/books/content?id=rhEcAQAAMAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api	\N	\N	2026-08-16 16:53:51.484671+00	\N
309df230-d7a9-40f0-a95b-a773d8abd4da	25OyAAAAIAAJ	A History of Women in the West	Georges Duby	https://books.google.com/books/content?id=25OyAAAAIAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api	Has the worst of times for humanity--this century bloodied by wars and revolutions without precedent in history--been the best of times for women? How have the promises of freedom, parity with men, full participation in society, actually been met amid all the transformations and upheavals the twentieth century has witnessed? This fifth volume in the world-acclaimed series brings the history of women up to the present, placing it in the context of momentous events and profound social changes that have marked our time.	\N	2026-08-16 16:53:51.486434+00	\N
25981d32-fb26-4cf8-83d1-2cb8c6dc5bc1	t5VOEAAAQBAJ	Um mundo em poucas linhas	Tamara Klink	https://books.google.com/books/content?id=t5VOEAAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	Tamara tem um projeto de vida: ser navegadora. Leva consigo a coleção de aprendizados de várias viagens com a mãe, irmãs e na companhia do pai, o velejador Amyr Klink. Mas segue passos próprios. Aos vinte e poucos anos, decidiu morar e estudar arquitetura naval na França, como parte do seu plano: realizar expedições que exigem uma preparação incomum para alguém da sua idade. E é justamente essa longa travessia que está presente em sua obra— não só aquela marcada por ondas e ventos, necessidade de içar velas ou de se lançar ao mar — mas os percalços de outro caminho, aquele que fazemos da adolescência para a vida adulta. Uma jornada heroica pela qual todos passamos, na terra ou no mar. Um mundo em poucas linhas reúne poemas e textos em prosa poética sobre as viagens variadas que Tamara fez desde criança com sua família, além de reflexões sobre a vida, a adolescência, os amores, o crescimento e as muitas experiências de deslocamento e travessias. Um livro sobre a beleza de se construir como ser humano, com liberdade, alegria e coragem para viver e seguir seus próprios caminhos.	9786559311095	2026-08-16 16:53:51.489972+00	\N
042c3f07-21e5-48f8-9806-14c7491c0943	ZdRmAAAAMAAJ	Tri-state Obituaries (Indiana-Ohio-Michigan), 1970-1974: S-Z	\N	https://books.google.com/books/content?id=ZdRmAAAAMAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api	\N	\N	2026-08-16 16:53:51.492125+00	\N
b671eea8-33db-4b19-8705-6d063b9f440c	yROkDAAAQBAJ	Férias na Antártica	Laura Klink, Tamara Klink, Marininha Klink	https://books.google.com/books/content?id=yROkDAAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	Três irmãs, duas idades diferentes, três visões de mundo, todas no mesmo barco, de férias na Antártica. Conheça neste livro o delicado equilíbrio do planeta e, de quebra, o divertido jeito de encarar o mundo das jovens Laura, Tamara e Marininha, filhas do navegador Amyr Klink e da fotógrafa Marina Bandeira Klink. Nos relatos de viagem, estão as lembranças de cinco expedições em família ao continente antártico, onde focas, pinguins, baleias e muitos outros animais especiais passam o verão. Com ainda pouca vivência, elas já sabem e entendem que nosso planeta precisa de cuidados e que, onde quer que a gente viva, nossas atitudes refletem em lugares muito distantes daqui.	9788575964262	2026-08-16 16:53:51.494077+00	\N
2e7f408c-9f62-4ed4-b1a4-c4b6a9601e8f	ib9YAAAAYAAJ	Pure-bred Dogs, American Kennel Gazette	\N	https://books.google.com/books/content?id=ib9YAAAAYAAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	\N	\N	2026-08-16 16:53:51.495901+00	\N
6f58e6f8-2fec-4c97-9e7a-9bec7f37996b	neF-gYyuFbwC	The American Kennel Club Stud Book Register	\N	https://books.google.com/books/content?id=neF-gYyuFbwC&printsec=frontcover&img=1&zoom=1&source=gbs_api	\N	\N	2026-08-16 16:53:51.497735+00	\N
39b8873a-c31e-49b7-bbb2-0a8c71e9dfbf	lCdRAQAAIAAJ	European law directory	\N	https://books.google.com/books/content?id=lCdRAQAAIAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api	\N	\N	2026-08-16 16:53:51.499535+00	\N
e8aa2965-f32e-482d-a04c-2ba37a90b8bd	441KAQAAIAAJ	The Canadian Law List	\N	https://books.google.com/books/content?id=441KAQAAIAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api	\N	\N	2026-08-16 16:53:51.50135+00	\N
ffae81b1-115e-451b-8e7c-ea2a992cdf1a	pXKRvIufdBIC	Harry Potter and the Prisoner of Azkaban	J. K. Rowling	https://books.google.com/books/content?id=pXKRvIufdBIC&printsec=frontcover&img=1&zoom=1&source=gbs_api	For twelve years, the dread fortress of Azkaban held an infamous prisoner named Sirius Black. Convicted of killing thirteen people with a single curse, he was said to be the heir apparent to the Dark Lord, Voldemort. Now he has escaped, leaving only two clues as to where he might be headed: Harry Potter's defeat of You-Know-Who was Black's downfall as well. And the Azkaban guards heard Black muttering in his sleep, "He's at Hogwarts." Harry Potter isn't safe, not even within the walls of his magical school, surrounded by his friends. Because on top of it all, there may well be a traitor in their midst.	9780439136365	2026-08-16 16:53:32.018416+00	\N
bd7ed846-ea36-48ed-a43c-cf378e0e60da	etukl7GfrxQC	Harry Potter and the Goblet of Fire	J.K. Rowling	https://books.google.com/books/content?id=etukl7GfrxQC&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api	'There will be three tasks, spaced throughout the school year, and they will test the champions in many different ways ... their magical prowess - their daring - their powers of deduction - and, of course, their ability to cope with danger.' The Triwizard Tournament is to be held at Hogwarts. Only wizards who are over seventeen are allowed to enter - but that doesn't stop Harry dreaming that he will win the competition. Then at Hallowe'en, when the Goblet of Fire makes its selection, Harry is amazed to find his name is one of those that the magical cup picks out. He will face death-defying tasks, dragons and Dark wizards, but with the help of his best friends, Ron and Hermione, he might just make it through - alive! Having become classics of our time, the Harry Potter eBooks never fail to bring comfort and escapism. With their message of hope, belonging and the enduring power of truth and love, the story of the Boy Who Lived continues to delight generations of new readers.	9781781100523	2026-08-16 16:53:32.030666+00	\N
285607df-f97b-41a9-a577-76ac2c7d1f95	p2swDQAAQBAJ	Harry Potter and the Order of the Phoenix	J. K. Rowling	https://books.google.com/books/content?id=p2swDQAAQBAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api	Celebrate 20 years of Harry Potter magic! Dark times have come to Hogwarts. After the Dementors' attack on his cousin Dudley, Harry Potter knows that Voldemort will stop at nothing to find him. There are many who deny the Dark Lord's return, but Harry is not alone: a secret order gathers at Grimmauld Place to fight against the Dark forces. Harry must allow Professor Snape to teach him how to protect himself from Voldemort's savage assaults on his mind. But they are growing stronger by the day and Harry is running out of time.These new editions of the classic and internationally bestselling, multi-award-winning series feature instantly pick-up-able new jackets by Jonny Duddle, with huge child appeal, to bring Harry Potter to the next generation of readers. It's time to PASS THE MAGIC ON ...	9781408855690	2026-08-16 16:53:32.042368+00	\N
\.


--
-- Data for Name: follows; Type: TABLE DATA; Schema: public; Owner: bookerbox_db_user
--

COPY public.follows (id, follower_id, following_id, created_at) FROM stdin;
85c569fa-0a49-4311-88d6-47eb8ba168e5	1b0b755b-597c-4e68-a54f-bd4293ac9238	735ea257-0bc7-4e05-9864-178d2e23e3b5	2026-08-16 17:32:24.772808+00
24e636b1-781e-444b-b1b4-005c98545aea	735ea257-0bc7-4e05-9864-178d2e23e3b5	1b0b755b-597c-4e68-a54f-bd4293ac9238	2026-08-16 17:33:26.186238+00
\.


--
-- Data for Name: likes; Type: TABLE DATA; Schema: public; Owner: bookerbox_db_user
--

COPY public.likes (id, user_id, review_id, created_at) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: bookerbox_db_user
--

COPY public.notifications (id, user_id, type, payload, read, created_at) FROM stdin;
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: bookerbox_db_user
--

COPY public.reviews (id, user_id, book_id, rating, text, created_at) FROM stdin;
\.


--
-- Data for Name: shelves; Type: TABLE DATA; Schema: public; Owner: bookerbox_db_user
--

COPY public.shelves (id, user_id, book_id, status, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: bookerbox_db_user
--

COPY public.users (id, name, email, password_hash, avatar_url, facebook_id, apple_id, created_at, google_id) FROM stdin;
1b0b755b-597c-4e68-a54f-bd4293ac9238	Thiago Lima	souza.thiagolima@gmail.com	$2b$10$f31ks0FuB1x/am2NH178ruJfqGcq3Ao29u0VOTU9ESLSs0eqb11oi	\N	\N	\N	2026-08-16 15:53:21.948918+00	\N
735ea257-0bc7-4e05-9864-178d2e23e3b5	Verena F	verenaformigosa@hotmail.com	$2b$10$DkbAidlpVvb7G/6ZHkcrXeekfD4WsAZ8MOb32HdXM0eY.GwNas9UO	\N	\N	\N	2026-08-16 17:12:26.948715+00	\N
\.


--
-- Name: books books_google_books_id_key; Type: CONSTRAINT; Schema: public; Owner: bookerbox_db_user
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_google_books_id_key UNIQUE (google_books_id);


--
-- Name: books books_pkey; Type: CONSTRAINT; Schema: public; Owner: bookerbox_db_user
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_pkey PRIMARY KEY (id);


--
-- Name: follows follows_follower_id_following_id_key; Type: CONSTRAINT; Schema: public; Owner: bookerbox_db_user
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT follows_follower_id_following_id_key UNIQUE (follower_id, following_id);


--
-- Name: follows follows_pkey; Type: CONSTRAINT; Schema: public; Owner: bookerbox_db_user
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT follows_pkey PRIMARY KEY (id);


--
-- Name: likes likes_pkey; Type: CONSTRAINT; Schema: public; Owner: bookerbox_db_user
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- Name: likes likes_user_id_review_id_key; Type: CONSTRAINT; Schema: public; Owner: bookerbox_db_user
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_user_id_review_id_key UNIQUE (user_id, review_id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: bookerbox_db_user
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: bookerbox_db_user
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: shelves shelves_pkey; Type: CONSTRAINT; Schema: public; Owner: bookerbox_db_user
--

ALTER TABLE ONLY public.shelves
    ADD CONSTRAINT shelves_pkey PRIMARY KEY (id);


--
-- Name: shelves shelves_user_id_book_id_key; Type: CONSTRAINT; Schema: public; Owner: bookerbox_db_user
--

ALTER TABLE ONLY public.shelves
    ADD CONSTRAINT shelves_user_id_book_id_key UNIQUE (user_id, book_id);


--
-- Name: users users_apple_id_key; Type: CONSTRAINT; Schema: public; Owner: bookerbox_db_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_apple_id_key UNIQUE (apple_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: bookerbox_db_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_facebook_id_key; Type: CONSTRAINT; Schema: public; Owner: bookerbox_db_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_facebook_id_key UNIQUE (facebook_id);


--
-- Name: users users_google_id_key; Type: CONSTRAINT; Schema: public; Owner: bookerbox_db_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_google_id_key UNIQUE (google_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: bookerbox_db_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_follows_follower; Type: INDEX; Schema: public; Owner: bookerbox_db_user
--

CREATE INDEX idx_follows_follower ON public.follows USING btree (follower_id);


--
-- Name: idx_follows_following; Type: INDEX; Schema: public; Owner: bookerbox_db_user
--

CREATE INDEX idx_follows_following ON public.follows USING btree (following_id);


--
-- Name: idx_notifications_user; Type: INDEX; Schema: public; Owner: bookerbox_db_user
--

CREATE INDEX idx_notifications_user ON public.notifications USING btree (user_id);


--
-- Name: idx_reviews_book; Type: INDEX; Schema: public; Owner: bookerbox_db_user
--

CREATE INDEX idx_reviews_book ON public.reviews USING btree (book_id);


--
-- Name: idx_reviews_user; Type: INDEX; Schema: public; Owner: bookerbox_db_user
--

CREATE INDEX idx_reviews_user ON public.reviews USING btree (user_id);


--
-- Name: follows follows_follower_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bookerbox_db_user
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT follows_follower_id_fkey FOREIGN KEY (follower_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: follows follows_following_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bookerbox_db_user
--

ALTER TABLE ONLY public.follows
    ADD CONSTRAINT follows_following_id_fkey FOREIGN KEY (following_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: likes likes_review_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bookerbox_db_user
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_review_id_fkey FOREIGN KEY (review_id) REFERENCES public.reviews(id) ON DELETE CASCADE;


--
-- Name: likes likes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bookerbox_db_user
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bookerbox_db_user
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bookerbox_db_user
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.books(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bookerbox_db_user
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: shelves shelves_book_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bookerbox_db_user
--

ALTER TABLE ONLY public.shelves
    ADD CONSTRAINT shelves_book_id_fkey FOREIGN KEY (book_id) REFERENCES public.books(id) ON DELETE CASCADE;


--
-- Name: shelves shelves_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bookerbox_db_user
--

ALTER TABLE ONLY public.shelves
    ADD CONSTRAINT shelves_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.armor(bytea) TO bookerbox_db_user;


--
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.armor(bytea, text[], text[]) TO bookerbox_db_user;


--
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.crypt(text, text) TO bookerbox_db_user;


--
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.dearmor(text) TO bookerbox_db_user;


--
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.decrypt(bytea, bytea, text) TO bookerbox_db_user;


--
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) TO bookerbox_db_user;


--
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.digest(bytea, text) TO bookerbox_db_user;


--
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.digest(text, text) TO bookerbox_db_user;


--
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.encrypt(bytea, bytea, text) TO bookerbox_db_user;


--
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) TO bookerbox_db_user;


--
-- Name: FUNCTION fips_mode(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.fips_mode() TO bookerbox_db_user;


--
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gen_random_bytes(integer) TO bookerbox_db_user;


--
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gen_random_uuid() TO bookerbox_db_user;


--
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gen_salt(text) TO bookerbox_db_user;


--
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gen_salt(text, integer) TO bookerbox_db_user;


--
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.hmac(bytea, bytea, text) TO bookerbox_db_user;


--
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.hmac(text, text, text) TO bookerbox_db_user;


--
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_armor_headers(text, OUT key text, OUT value text) TO bookerbox_db_user;


--
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_key_id(bytea) TO bookerbox_db_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea) TO bookerbox_db_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) TO bookerbox_db_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) TO bookerbox_db_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) TO bookerbox_db_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) TO bookerbox_db_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO bookerbox_db_user;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea) TO bookerbox_db_user;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea, text) TO bookerbox_db_user;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) TO bookerbox_db_user;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) TO bookerbox_db_user;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text) TO bookerbox_db_user;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text, text) TO bookerbox_db_user;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) TO bookerbox_db_user;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) TO bookerbox_db_user;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text) TO bookerbox_db_user;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt(text, text, text) TO bookerbox_db_user;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) TO bookerbox_db_user;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) TO bookerbox_db_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON SEQUENCES TO bookerbox_db_user;


--
-- Name: DEFAULT PRIVILEGES FOR TYPES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TYPES TO bookerbox_db_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON FUNCTIONS TO bookerbox_db_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres GRANT ALL ON TABLES TO bookerbox_db_user;


--
-- PostgreSQL database dump complete
--

\unrestrict nWZA2rnvFfC6PWjX4cMkWVmA3c2mLt4uMQU43OBWVTjp8F9nYL6LgnrdWPAWQ0b

