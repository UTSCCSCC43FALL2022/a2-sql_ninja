SET search_path TO A2;
--TESTING Data
INSERT INTO Lilmon Values (00, 'Pikachu', 'Electric', 'Light', 3);
INSERT INTO Lilmon Values (01, 'XiaoHuoLong', 'Fire', 'Earth', 5);
INSERT INTO Lilmon Values (02, 'MiaoWaZhongZi', 'Earth', 'Electric', 5);
INSERT INTO Lilmon Values (03, 'JieNiGui', 'Water', 'Fire', 4);
INSERT INTO Lilmon Values (04, 'MengHuan', 'Light', 'Water', 5);

INSERT INTO Player Values (10, 'XiaoZhi', 'XiaoZhi@gmail.com', 'CHN', 30000, 700, 6, 10, 20);
INSERT INTO Guild Values (123, 'Pokemon', 'ABCDE', 10);

UPDATE Player
SET guild = 123;

INSERT INTO Player Values (20, 'XiaoXia', 'XiaoXia@gmail.com', 'CHN', 40000, 600, 8, 10, 24, 123);
INSERT INTO Player Values (30, 'XiaoMing', 'XiaoMing@gmail.com', 'CHN', 50000, 400, 5, 10, 15, 123);
INSERT INTO Player Values (40, 'XiaoGang', 'XiaoGang@gmail.com', 'CHN', 10000, 300, 7, 10, 20, 123);
INSERT INTO Player Values (50, 'XiaoHong', 'XiaoHong@gmail.com', 'CHN', 20000, 500, 6, 6, 20, 123);

INSERT INTO LilmonInventory Values (06, 00, 10, true, true);
INSERT INTO LilmonInventory Values (07, 01, 20, true, true);
INSERT INTO LilmonInventory Values (08, 02, 30, true, true);
INSERT INTO LilmonInventory Values (09, 03, 40, true, true);
INSERT INTO LilmonInventory Values (90, 04, 50, true, true);

INSERT INTO PlayerRatings Values (34, 10, 5, 2020, 2000, 2000);
INSERT INTO PlayerRatings Values (35, 10, 6, 2020, 2000, 2000);
INSERT INTO PlayerRatings Values (36, 10, 7, 2020, 2000, 2000);
INSERT INTO PlayerRatings Values (37, 20, 5, 2019, 2000, 2000);
INSERT INTO PlayerRatings Values (38, 20, 6, 2019, 2000, 2000);
INSERT INTO PlayerRatings Values (39, 20, 7, 2019, 2000, 2000);
INSERT INTO PlayerRatings Values (44, 30, 12, 2019, 2000, 2000);
INSERT INTO PlayerRatings Values (45, 30, 1, 2020, 2000, 2000);
INSERT INTO PlayerRatings Values (46, 30, 2, 2020, 2000, 2000);
INSERT INTO PlayerRatings Values (47, 40, 2, 2020, 1000, 2000);
INSERT INTO PlayerRatings Values (48, 40, 3, 2020, 2000, 2000);
INSERT INTO PlayerRatings Values (49, 40, 11, 2019, 2000, 2000);
INSERT INTO PlayerRatings Values (55, 50, 5, 2020, 2000, 2000);
INSERT INTO PlayerRatings Values (56, 50, 6, 2020, 1000, 2000);
INSERT INTO PlayerRatings Values (57, 50, 7, 2020, 2000, 2000);

INSERT INTO GuildRatings Values (66, 123, 5, 2020, 2000, 2000);
INSERT INTO GuildRatings Values (67, 123, 6, 2020, 1000, 1500);
INSERT INTO GuildRatings Values (68, 123, 7, 2020, 2000, 2000);


-- If you define any views for a question (you are encouraged to), you must drop them
-- after you have populated the answer table for that question.
-- Good Luck!

-- Query 1 --------------------------------------------------
CREATE VIEW CountActive AS
SELECT p_id, count(monthly_rating)
FROM PlayerRatings
WHERE monthly_rating > 0
GROUP BY p_id;

CREATE VIEW Whale AS
SELECT p_id, playername, email
FROM CountActive JOIN Player ON CountActive.p_id = Player.id
WHERE rolls/count >= 100;

CREATE VIEW Hoarder AS
SELECT p_id, playername, email
FROM CountActive JOIN Player ON CountActive.p_id = Player.id
WHERE coins/count >= 10000;

CREATE VIEW CountRarity5Lilmon AS
SELECT LilmonInventory.p_id, count(LilmonInventory.id)
FROM LilmonInventory JOIN Lilmon ON LilmonInventory.p_id = Lilmon.id
GROUP BY LilmonInventory.p_id, rarity
HAVING rarity = 5;


CREATE VIEW Lucky AS
SELECT p_id, playername, email
FROM CountRarity5Lilmon JOIN Player ON CountRarity5Lilmon.p_id = Player.id
WHERE count/rolls >= 0.05;

CREATE VIEW Class3 AS
SELECT *
FROM Whale
UNION
SELECT *
FROM lucky
UNION
SELECT *
FROM Hoarder;

INSERT INTO Query1  (SELECT DISTINCT p_id, playername, email FROM Class3 ORDER BY p_id ASC);

UPDATE Query1
SET classification =
Case
    WHEN (Query1.p_id IN (SELECT p_id FROM Whale) AND Query1.p_id IN (SELECT p_id FROM Lucky) AND Query1.p_id IN (SELECT p_id FROM Hoarder)) THEN 'whale-lucky-hoarder'
    WHEN (Query1.p_id NOT IN (SELECT p_id FROM Whale) AND Query1.p_id IN (SELECT p_id FROM Lucky) AND Query1.p_id IN (SELECT p_id FROM Hoarder)) THEN '-lucky-hoarder'
    WHEN (Query1.p_id IN (SELECT p_id FROM Whale) AND Query1.p_id NOT IN (SELECT p_id FROM Lucky) AND Query1.p_id IN (SELECT p_id FROM Hoarder)) THEN 'whale--hoarder'
    WHEN (Query1.p_id IN (SELECT p_id FROM Whale) AND Query1.p_id IN (SELECT p_id FROM Lucky) AND Query1.p_id NOT IN (SELECT p_id FROM Hoarder)) THEN 'whale-lucky-'
    WHEN (Query1.p_id NOT IN (SELECT p_id FROM Whale) AND Query1.p_id NOT IN (SELECT p_id FROM Lucky) AND Query1.p_id IN (SELECT p_id FROM Hoarder)) THEN '--hoarder'
    WHEN (Query1.p_id IN (SELECT p_id FROM Whale) AND Query1.p_id NOT IN (SELECT p_id FROM Lucky) AND Query1.p_id NOT IN (SELECT p_id FROM Hoarder)) THEN 'whale--'
    WHEN (Query1.p_id NOT IN (SELECT p_id FROM Whale) AND Query1.p_id IN (SELECT p_id FROM Lucky) AND Query1.p_id NOT IN (SELECT p_id FROM Hoarder)) THEN '-lucky-'
    ELSE '--'
END;

DROP VIEW IF EXISTS Class3 CASCADE;
DROP VIEW IF EXISTS CountRarity5Lilmon CASCADE;
DROP VIEW IF EXISTS Hoarder CASCADE; 
DROP VIEW IF EXISTS Lucky CASCADE; 
DROP VIEW IF EXISTS Whale CASCADE;
DROP VIEW IF EXISTS CountActive CASCADE;

-- Query 2 --------------------------------------------------
CREATE VIEW DistinctPair1 AS
SELECT p_id, l_id, element1
FROM Lilmon JOIN LilmonInventory ON Lilmon.id = LilmonInventory.l_id
WHERE LilmonInventory.in_team = true AND LilmonInventory.fav = true;

CREATE VIEW DistinctPair2 AS
SELECT p_id, l_id, element2
FROM Lilmon JOIN LilmonInventory ON Lilmon.id = LilmonInventory.l_id
WHERE LilmonInventory.in_team = true AND LilmonInventory.fav = true;

CREATE VIEW countElement1 AS
SELECT element1 AS element, count(*) AS count1
FROM (SELECT DISTINCT * FROM DistinctPair1) AS Uniq1
GROUP BY element1;

CREATE VIEW countElement2 AS
SELECT element2 AS element, count(*) AS count2
FROM (SELECT DISTINCT * FROM DistinctPair2) AS Uniq2
GROUP BY element2;

INSERT INTO Query2 (SELECT countElement1.element, count1+count2 AS popularity_count FROM (countElement1 JOIN countELement2 ON countElement1.element = countElement2.element) ORDER BY popularity_count DESC);

DROP VIEW IF EXISTS countElement1 CASCADE;
DROP VIEW IF EXISTS countElement2 CASCADE;
DROP VIEW IF EXISTS DistinctPair1 CASCADE;
DROP VIEW IF EXISTS DistinctPair2 CASCADE;

--Query 3 --------------------------------------------------
CREATE VIEW CountActive AS
SELECT p_id, count(monthly_rating)
FROM PlayerRatings
WHERE monthly_rating > 0
GROUP BY p_id;

CREATE VIEW PlayerActive AS
SELECT *
FROM CountActive RIGHT JOIN Player ON CountActive.p_id = Player.id;

-- UPDATE PlayerActive
-- SET count = 1
-- WHERE count = NULL;

CREATE VIEW PlayerAverage AS
SELECT p_id, (total_battles-losses-wins)/count AS monthlyIG
FROM PlayerActive;

INSERT INTO Query3 (SELECT avg(monthlyIG) AS avg_ig_per_month_per_player FROM PlayerAverage);

DROP VIEW IF EXISTS CountActive CASCADE;
DROP VIEW IF EXISTS PlayerActive CASCADE;
DROP VIEW IF EXISTS PlayerAverage CASCADE;

-- Query 4 --------------------------------------------------
CREATE VIEW CountPopularity AS
SELECT l_id, count(DISTINCT p_id) AS popularity_count
FROM LilmonInventory
WHERE in_team = true AND fav = true
GROUP BY l_id;

INSERT INTO Query4 (SELECT l_id, name, rarity, popularity_count FROM (CountPopularity JOIN Lilmon ON CountPopularity.l_id = Lilmon.id) ORDER BY popularity_count DESC, rarity DESC, id DESC);

DROP VIEW IF EXISTS CountPopularity CASCADE;

-- Query 5 --------------------------------------------------

CREATE VIEW LateYear AS
SELECT p_id, month, year, max(year) AS maxYear
FROM PlayerRatings
GROUP BY p_id, month, year;

CREATE VIEW RecentYear AS
SELECT p_id, month, year, maxYear
FROM LateYear
WHERE year = maxYear;

CREATE VIEW RecentMonth AS
SELECT p_id, maxYear, max(month) AS maxMonth
FROM RecentYear
GROUP BY p_id, maxYear;

CREATE VIEW Last6Month AS
SELECT PlayerRatings.p_id, month, year, monthly_rating, all_time_rating
FROM RecentMonth CROSS JOIN PlayerRatings
WHERE (RecentMonth.p_id = PlayerRatings.p_id) AND ((year = maxYear AND maxMonth-month < 6) OR (year = maxYear-1 AND month-maxMonth < 8));

Create VIEW RatePlayer AS
SELECT Last6Month.p_id, playername, email, all_time_rating, min(monthly_rating) AS min_mr, max(monthly_rating) AS max_mr
FROM Last6Month JOIN Player ON Last6Month.p_id = Player.id
GROUP BY p_id, playername, email, all_time_rating;

Create VIEW WellPlayer AS
SELECT p_id, playername, email, min_mr, max_mr
FROM RatePlayer
WHERE max_mr - min_mr <= 50 AND all_time_rating >=2000;

INSERT INTO Query5 (SELECT p_id, playername, email, min_mr, max_mr FROM WellPlayer ORDER BY max_mr DESC, min_mr DESC, p_id ASC);

DROP VIEW IF EXISTS LateYear CASCADE;
DROP VIEW IF EXISTS RecentYear CASCADE;
DROP VIEW IF EXISTS RecentMonth CASCADE;
DROP VIEW IF EXISTS Last6Month CASCADE;
DROP VIEW IF EXISTS RatePlayer CASCADE;
DROP VIEW IF EXISTS WellPlayer CASCADE;

-- Query 6 --------------------------------------------------
CREATE VIEW TimeYear AS
SELECT g_id, month, year, all_time_rating, max(year) AS maxYear
FROM GuildRatings
GROUP BY g_id, month, year, all_time_rating;

CREATE VIEW LatestYear AS
SELECT g_id, month, year, all_time_rating, maxYear
FROM TimeYear
WHERE year = maxYear;

CREATE VIEW TimeMonth AS
SELECT g_id, month, year, all_time_rating, max(month) AS maxMonth
FROM LatestYear
GROUP BY g_id, month, year, all_time_rating;

CREATE VIEW LatestMonth AS
SELECT g_id, month, year, all_time_rating, maxMonth
FROM TimeMonth
WHERE month = maxMonth;

CREATE VIEW GuildSize AS
SELECT guild as g_id, guildname, tag, leader, all_time_rating, count(DISTINCT Player.id) AS sizeNum
FROM (Player JOIN LatestMonth ON Player.guild = LatestMonth.g_id) JOIN Guild ON Guild.id = LatestMonth.g_id
GROUP BY guild, guildname, tag, leader, all_time_rating;

INSERT INTO Query6 (SELECT g_id, guildname, tag, leader AS leader_id, playername AS leader_name, country_code AS leader_country FROM GuildSize JOIN Player ON GuildSize.leader = Player.id ORDER BY g_id ASC);

UPDATE Query6
SET size = 
CASE 
    WHEN GuildSize.sizeNum >=500 THEN 'large'

    WHEN GuildSize.sizeNum >=100 AND GuildSize.sizeNum < 500 THEN 'medium'

    ELSE 'small'
END
FROM GuildSize;

UPDATE Query6
SET classification = 
CASE 
    WHEN (Query6.size = 'large' AND GuildSize.all_time_rating >= 2000) OR (Query6.size = 'medium' AND GuildSize.all_time_rating >= 1750) OR (Query6.size = 'small' AND GuildSize.all_time_rating >= 1500) THEN 'elite'
    WHEN (Query6.size = 'large' AND GuildSize.all_time_rating < 2000 AND GuildSize.all_time_rating >= 1500) OR (Query6.size = 'medium' AND GuildSize.all_time_rating < 1750 AND GuildSize.all_time_rating >= 1250) OR (Query6.size = 'small' AND GuildSize.all_time_rating < 1500 AND GuildSize.all_time_rating >= 1000) THEN 'average'
    WHEN (Query6.size = 'large' AND GuildSize.all_time_rating < 1500) OR (Query6.size = 'medium' AND GuildSize.all_time_rating < 1250) OR (Query6.size = 'small' AND GuildSize.all_time_rating < 1000) THEN 'casual'
    ELSE 'new'
END
FROM GuildSize;

DROP VIEW IF EXISTS TimeYear CASCADE;
DROP VIEW IF EXISTS LatestYear CASCADE;
DROP VIEW IF EXISTS TimeMonth CASCADE;
DROP VIEW IF EXISTS LatestMonth CASCADE;
DROP VIEW IF EXISTS GuildSize CASCADE;

-- -- Query 7 --------------------------------------------------
-- INSERT INTO Query7
-- SELECT Player.country_code AS country_code, (sum(PlayerRating.month)/count(PlayerRating.month)) AS player_retention
-- FROM Player JOIN PlayerRating
-- WHERE Player.id = PlayerRating.p_id AND PlayerRating.month <> 0
-- GROUP BY Player.country_code
-- ORDER BY player_retention DESC;

-- -- Query 8 --------------------------------------------------
-- CREATE TABLE TempTable(
--     p_id INTEGER,
--     playername VARCHAR,
--     player_wr REAL,
--     g_id INTEGER,
--     guildname VARCHAR,
--     tag VARCHAR(5),
--     guild_aggregate_wr REAL
-- );

-- INSERT INTO TempTable
-- SELECT Player.id as p_id,
--     Player.playername as playername,
--     (Player.wins/Player.total_battles) as player_wr,
--     Player.guild as g_id,
--     Guild.guildname as guildname,
--     Guild.tag as tag,
--     (SELECT (SUM(wins)/SUM(total_battles))
--     FROM Player as P
--     WHERE P.guild = Player.guild) as guild_aggregate_wr
-- FROM Player JOIN Guild
-- WHERE Player.guild IS NOT NULL AND Player.guild = Guild.id;

-- INSERT INTO TempTable(p_id,playername, player_wr)
-- SELECT Player.id as p_id,
--     Player.playername as playername,
--     (Player.wins/Player.total_battles) as player_wr,
-- FROM Player
-- WHERE Player.guild IS NULL;

-- INSERT INTO Query8
-- SELECT *
-- FROM TempTable
-- ORDER BY player_wr DESC, guild_aggregate_wr DESC;

-- DROP TABLE TempTable;

-- -- Query 9 --------------------------------------------------
-- CREATE TABLE Final(
--     g_id INTEGER,
--     guildname VARCHAR,
--     monthly_rating INTEGER,
--     all_time_rating INTEGER,
--     country_pcount INTEGER,
--     total_pcount INTEGER,
--     country_code CHAR(3)
-- );

-- CREATE TABLE Leading10 (
--     g_id INTEGER,
--     guildname VARCHAR UNIQUE NOT NULL,
--     monthly_rating INTEGER NOT NULL,
--     all_time_rating INTEGER NOT NULL,
-- );

-- CREATE TABLE CounTolal (
--     g_id INTEGER,
--     total_pcount INTEGER
-- );

-- CREATE TABLE AllCtyCount(
--     g_id INTEGER,
--     c INTEGER,
--     country_code CHAR(3)
-- )

-- CREATE TABLE CountMax (
--     g_id INTEGER,
--     country_pcount INTEGER,
--     country_code CHAR(3)
-- );

-- INSERT INTO Leading10
-- SELECT g_id, guildname, monthly_rating, all_time_rating
-- FROM Guild JOIN(
--     SELECT TOP 10 DISTINCT g_id, monthly_rating, all_time_rating
--     FROM  GuildRatings
--     ORDER BY all_time_rating DESC, monthly_rating DESC, g_id ASC
-- )
-- WHERE Guild.id = g_id;

-- INSERT INTO CounTolal
-- SELECT Player.guild AS g_id,
--     COUNT(Player.id) AS total_pcount
-- FROM Player JOIN Leading10
-- WHERE Player.guild = Leading10.g_id
-- GROUP BY Leading10.gid;

-- INSERT INTO AllCtyCount
-- SELECT COUNT(Player.country_code) AS c, 
--     Player.country_code as country_code,
--     Leading10.g_id as g_id
-- FROM Player JOIN Leading10
-- WHERE Player.guild = Leading10.g_id
-- GROUP BY Player.guild, Player.country_code;

-- INSERT INTO CountMax
-- SELECT AllCtyCount.c as country_pcount,
--     AllCtyCount.g_id as g_id,
--     AllCtyCount.country_code as country_code
-- FROM AllCtyCount
-- WHERE AllCtyCount.c = (
--     SELECT MAX(c) as max_c
--     FROM AllCtyCount
-- );

-- INSERT INTO Final
-- SELECT Leading10.g_id as g_id,
--     Leading10.guildname as guildname,
--     Leading10.monthly_rating as monthly_rating,
--     Leading10.all_time_rating as all_time_rating,
--     CountMax.country_pcount as country_pcount,
--     CounTolal.total_pcount as total_pcount,
--     CountMax.country_code as country_code
-- FROM CountMax JOIN CounTolal JOIN Leading10
-- WHERE CountMax.g_id = CounTolal.g_id = Leading10.gid;

-- INSERT INTO Query9
-- SELECT *
-- FROM Final
-- ORDER BY all_time_rating DESC, monthly_rating DESC, g_id ASC;

-- DROP TABLE Final;
-- DROP TABLE Leading10;
-- DROP TABLE CounTolal;
-- DROP TABLE AllCtyCount;
-- DROP TABLE CountMax;


-- -- Query 10 --------------------------------------------------
-- INSERT INTO Query10
-- SELECT g_id, guildname, avg_veteranness
-- FROM Player, Guild, (
--     SELECT p_id, SUM(month) avg_veteranness
--     FROM PlayerRating
--     GROUP BY p_id
-- )AS Average
-- WHERE Average.p_id = Player.id AND Player.guild = Guild.id
-- ORDER BY avg_veteranness DESC, g_id ASC;

