-- SET search_path TO A2;

-- -- If you define any views for a question (you are encouraged to), you must drop them
-- -- after you have populated the answer table for that question.
-- -- Good Luck!

-- -- Query 1 --------------------------------------------------
-- CREATE VIEW CountActive AS
-- SELECT p_id, count(monthly_rating)
-- FROM PlayerRatings
-- WHERE monthly_rating > 0
-- GROUP BY p_id;

-- CREATE VIEW Whale AS
-- SELECT p_id, playername, email
-- FROM CountActive JOIN Player ON CountActive.p_id = Player.id
-- WHERE rolls/Cast(count AS FLOAT) >= 100;

-- Query 1 --------------------------------------------------
CREATE VIEW CountActive AS
SELECT p_id, count(monthly_rating)
FROM PlayerRatings
WHERE monthly_rating > 0
GROUP BY p_id;

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

-- Query 2 --------------------------------------------------

INSERT INTO Query2
CREATE VIEW DistinctPair1 AS
SELECT p_id, l_id, element1
FROM Lilmon JOIN LilmonInventory ON Lilmon.id = LilmonInventory.l_id
WHERE LilmonInventory.in_team = true AND LilmonInventory.fav = true;

CREATE VIEW DistinctPair2 AS
SELECT p_id, l_id, element2
FROM Lilmon JOIN LilmonInventory ON Lilmon.id = LilmonInventory.l_id
WHERE LilmonInventory.in_team = true AND LilmonInventory.fav = true;

CREATE VIEW countElement1 AS
SELECT element1, count(*) AS count1
FROM (SELECT DISTINCT * FROM DistinctPair1) AS Uniq1
GROUP BY element1;

CREATE VIEW countElement2 AS
SELECT element2, count(*) AS count2
FROM (SELECT DISTINCT * FROM DistinctPair2) AS Uniq2
GROUP BY element2;

INSERT INTO Query2 (SELECT element, count1+count2 AS popularity_count FROM (countElement1 JOIN countELement2 ON countElement1.element1 = countElement2.element2) ORDER BY popularity_count DESC);

-- --Query 3 --------------------------------------------------
-- CREATE VIEW CountActive AS
-- SELECT p_id, count(monthly_rating)
-- FROM PlayerRatings
-- WHERE monthly_rating > 0
-- GROUP BY p_id;

CREATE VIEW PlayerActive AS
SELECT *
FROM CountActive RIGHT JOIN Player ON CountActive.p_id = Player.id;

CREATE VIEW PlayerAverage AS
SELECT p_id, (total_battles-losses-wins)/count AS monthlyIG
FROM PlayerActive;

INSERT INTO Query3 (SELECT avg(monthlyIG) AS avg_ig_per_month_per_player FROM PlayerAverage);

-- Query 4 --------------------------------------------------
CREATE VIEW CountPopularity AS
INSERT INTO Query3
CREATE VIEW CA AS
SELECT p_id, count(monthly_rating)
FROM PlayerRatings
WHERE monthly_rating > 0
GROUP BY p_id;

CREATE VIEW PlayerActive AS
SELECT *
FROM CA RIGHT JOIN Player ON CA.p_id = Player.id;


-- Query 4 --------------------------------------------------
INSERT INTO Query4
CREATE VIEW CP AS
SELECT l_id, count(DISTINCT p_id) AS popularity_count
FROM LilmonInventory
WHERE in_team = true AND fav = true
GROUP BY l_id;
INSERT INTO Query4 (SELECT l_id, name, rarity, popularity_count FROM (CountPopularity JOIN Lilmon ON CountPopularity.l_id = Lilmon.id) ORDER BY popularity_count DESC, rarity DESC, id DESC);

-- CREATE VIEW Last6Month AS
-- SELECT PlayerRatings.p_id, month, year, monthly_rating, all_time_rating
-- FROM RecentMonth CROSS JOIN PlayerRatings
-- WHERE (RecentMonth.p_id = PlayerRatings.p_id) AND ((year = maxYear AND maxMonth-month < 6) OR (year = maxYear-1 AND month-maxMonth < 8));

CREATE VIEW RecentMonth AS
SELECT p_id, maxYear, max(month) AS maxMonth
FROM RecentYear
GROUP BY p_id;

CREATE VIEW Last6Month AS
SELECT p_id, month, year, monthly_rating, all_time_rating
FROM RecentYear CROSS JOIN PlayerRatings
WHERE (RecentYear.p_id = PlayerRatings.p_id) AND ((year = maxYear AND maxMonth-month < 6) OR (year = maxYear-1 AND month-maxMonth < 8));

Create VIEW RatePlayer AS
SELECT p_id, playername, email, min(monthly_rating) AS min_mr, max(monthly_rating) AS max_mr
FROM Last6Month JOIN Player ON Last6Month.p_id = Player.id
GROUP BY p_id;

Create VIEW WellPlayer AS
SELECT p_id, playername, email, min_mr, max_mr
FROM RatePlayer
WHERE max_mr - min_mr <= 50 AND all_time_rating >=2000;

INSERT INTO Query5 (SELECT p_id, playername, email, min_mr, max_mr FROM WellPlayer ORDER BY max_mr DESC, min_mr DESC, p_id ASC);

CREATE VIEW LateYear AS
SELECT p_id, month, year, max(year) AS maxYear
FROM PlayerRatings
GROUP BY p_id;

CREATE VIEW RecentYear AS
SELECT p_id, month, year, maxYear
FROM LateYear
WHERE year = maxYear;

CREATE VIEW RecentMonth AS
SELECT p_id, maxYear, max(month) AS maxMonth
FROM RecentYear
GROUP BY p_id;

CREATE VIEW Last6Month AS
SELECT p_id, month, year, monthly_rating, all_time_rating
FROM RecentYear CROSS JOIN PlayerRatings
WHERE (RecentYear.p_id = PlayerRatings.p_id) AND ((year = maxYear AND maxMonth-month < 6) OR (year = maxYear-1 AND month-maxMonth < 8));

Create VIEW RatePlayer AS
SELECT p_id, playername, email, min(monthly_rating) AS min_mr, max(monthly_rating) AS max_mr
FROM Last6Month JOIN Player ON Last6Month.p_id = Player.id
GROUP BY p_id;

Create VIEW WellPlayer AS
SELECT p_id, playername, email, min_mr, max_mr
FROM RatePlayer
WHERE max_mr - min_mr <= 50 AND all_time_rating >=2000;

INSERT INTO Query5 (SELECT p_id, playername, email, min_mr, max_mr FROM WellPlayer ORDER BY max_mr DESC, min_mr DESC, p_id ASC);

-- Query 6 --------------------------------------------------
INSERT INTO Query6
CREATE VIEW TimeYear AS
SELECT g_id, month, year, all_time_rating, max(year) AS maxYear
FROM GuildRatings
GROUP BY g_id;

CREATE VIEW LatestYear AS
SELECT g_id, month, year, all_time_rating, maxYear
FROM TimeYear
WHERE year = maxYear;

CREATE VIEW TimeMonth AS
SELECT g_id, month, year, all_time_rating, max(month) AS maxMonth
FROM LatestMonth
GROUP BY g_id;
UPDATE Query6
SET Query6.size = 
CASE 
    WHEN GuildSize.sizeNum >=500 THEN 'large'

    WHEN GuildSize.sizeNum >=100 AND GuildSize.sizeNum < 500 THEN 'medium'

    ELSE 'small'
END
SET Query6.classification = 
CASE 
    WHEN (Query6.size = 'large' AND GuildSize.all_time_rating >= 2000) OR (Query6.size = 'medium' AND GuildSize.all_time_rating >= 1750) OR (Query6.size = 'small' AND GuildSize.all_time_rating >= 1500) THEN 'elite'
    WHEN (Query6.size = 'large' AND GuildSize.all_time_rating < 2000 AND GuildSize.all_time_rating >= 1500) OR (Query6.size = 'medium' AND GuildSize.all_time_rating < 1750 AND GuildSize.all_time_rating >= 1250) OR (Query6.size = 'small' AND GuildSize.all_time_rating < 1500 AND GuildSize.all_time_rating >= 1000) THEN 'average'
    WHEN (Query6.size = 'large' AND GuildSize.all_time_rating < 1500) OR (Query6.size = 'medium' AND GuildSize.all_time_rating < 1250) OR (Query6.size = 'small' AND GuildSize.all_time_rating < 1000) THEN 'casual'
    ELSE 'new'
END
FROM GuildSize;
-- Query 7 --------------------------------------------------
INSERT INTO Query7
SELECT Player.country_code as country_code,
    (SUM(PlayerRating.month)/COUNT(PlayerRating.month)) as player_retention
FROM Player JOIN PlayerRating
WHERE Player.id = PlayerRating.p_id AND PlayerRating.month <> 0
GROUP BY Player.country_code
ORDER BY player_retention DESC;
-- Query 8 --------------------------------------------------
CREATE TABLE Result(
    p_id INTEGER,
    playername VARCHAR,
    player_wr REAL,
    g_id INTEGER,
    guildname VARCHAR,
    tag VARCHAR(5),
    guild_aggregate_wr REAL
);

INSERT INTO Result
SELECT Player.id as p_id,
    Player.playername as playername,
    (Player.wins/Player.total_battles) as player_wr,
    Player.guild as g_id,
    Guild.guildname as guildname,
    Guild.tag as tag,
    (SELECT (SUM(wins)/SUM(total_battles))
    FROM Player as P
    WHERE P.guild = Player.guild) as guild_aggregate_wr
FROM Player JOIN Guild
WHERE Player.guild IS NOT NULL AND Player.guild = Guild.id;

INSERT INTO Result(p_id,playername, player_wr)
SELECT Player.id as p_id,
    Player.playername as playername,
    (Player.wins/Player.total_battles) as player_wr,
FROM Player
WHERE Player.guild IS NULL;

INSERT INTO Query8
SELECT Player.id as p_id,
    Player.playername as playername,
    (Player.wins/Player.total_battles) as player_wr,
    Player.guild as g_id,
    Guild.guildname as guildname,
    Guild.tag as tag,
    (SELECT (SUM(wins)/SUM(total_battles))
    FROM Player as P
    WHERE P.guild = Player.guild) as guild_aggregate_wr
    FROM Player JOIN Guild
    WHERE Player.guild IS NOT NULL AND Player.guild = Guild.id;

    INSERT INTO Query8(p_id,playername, player_wr)
    SELECT Player.id as p_id,
        Player.playername as playername,
        (Player.wins/Player.total_battles) as player_wr,
    FROM Player
    WHERE Player.guild IS NULL;
DROP TABLE Result;
-- Query 9 --------------------------------------------------
CREATE TABLE Result(
    g_id INTEGER,
    guildname VARCHAR,
    monthly_rating INTEGER,
    all_time_rating INTEGER,
    country_pcount INTEGER,
    total_pcount INTEGER,
    country_code CHAR(3)
);

CREATE TABLE Top_10 (
    g_id INTEGER,
    guildname VARCHAR UNIQUE NOT NULL,
    monthly_rating INTEGER NOT NULL,
    all_time_rating INTEGER NOT NULL,
);

CREATE TABLE Total_count (
    g_id INTEGER,
    total_pcount INTEGER
);

CREATE TABLE All_country_count(
    g_id INTEGER,
    c INTEGER,
    country_code CHAR(3)
)

CREATE TABLE Max_count (
    g_id INTEGER,
    country_pcount INTEGER,
    country_code CHAR(3)
);

INSERT INTO Top_10
SELECT g_id, guildname, monthly_rating, all_time_rating
FROM Guild JOIN(
    SELECT TOP 10 DISTINCT g_id, monthly_rating, all_time_rating
    FROM  GuildRatings
    ORDER BY all_time_rating DESC, monthly_rating DESC, g_id ASC
)
WHERE Guild.id = g_id;

INSERT INTO Total_count
SELECT Player.guild AS g_id,
    COUNT(Player.id) AS total_pcount
FROM Player JOIN Top_10
WHERE Player.guild = Top_10.g_id
GROUP BY Top_10.gid;

INSERT INTO All_country_count
SELECT COUNT(Player.country_code) AS c, 
    Player.country_code as country_code,
    Top_10.g_id as g_id
FROM Player JOIN Top_10
WHERE Player.guild = Top_10.g_id
GROUP BY Player.guild, Player.country_code;

INSERT INTO Max_count
SELECT All_country_count.c as country_pcount,
    All_country_count.g_id as g_id,
    All_country_count.country_code as country_code
FROM All_country_count
WHERE All_country_count.c = (
    SELECT MAX(c) as max_c
    FROM All_country_count
);

INSERT INTO Result
SELECT Top_10.g_id as g_id,
    Top_10.guildname as guildname,
    Top_10.monthly_rating as monthly_rating,
    Top_10.all_time_rating as all_time_rating,
    Max_count.country_pcount as country_pcount,
    Total_count.total_pcount as total_pcount,
    Max_count.country_code as country_code
FROM Max_count JOIN Total_count JOIN Top_10
WHERE Max_count.g_id = Total_count.g_id = Top_10.gid;

-- -- INSERT INTO Final
-- -- SELECT Leading10.g_id as g_id,
-- --     Leading10.guildname as guildname,
-- --     Leading10.monthly_rating as monthly_rating,
-- --     Leading10.all_time_rating as all_time_rating,
-- --     CountMax.country_pcount as country_pcount,
-- --     CounTolal.total_pcount as total_pcount,
-- --     CountMax.country_code as country_code
-- -- FROM CountMax JOIN CounTolal JOIN Leading10
-- -- WHERE CountMax.g_id = CounTolal.g_id = Leading10.gid;

DROP TABLE Result;
DROP TABLE Top_10;
DROP TABLE Total_count;
DROP TABLE All_country_count;
DROP TABLE Max_count;

-- Query 10 --------------------------------------------------
INSERT INTO Query10
SELECT g_id, guildname, avg_veteranness
FROM Player, Guild, (
    SELECT p_id, (COUNT(*)/12) as avg_veteranness
    FROM PlayerRating
    GROUP BY p_id
)AS Average
WHERE Average.p_id = Player.id AND Player.guild = Guild.id
ORDER BY avg_veteranness DESC, g_id ASC


-- -- -- Query 10 --------------------------------------------------
-- -- INSERT INTO Query10
-- -- SELECT g_id, guildname, avg_veteranness
-- -- FROM Player, Guild, (
-- --     SELECT p_id, SUM(month) avg_veteranness
-- --     FROM PlayerRating
-- --     GROUP BY p_id
-- -- )AS Average
-- -- WHERE Average.p_id = Player.id AND Player.guild = Guild.id
-- -- ORDER BY avg_veteranness DESC, g_id ASC;

