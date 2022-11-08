SET search_path TO A2;

-- If you define any views for a question (you are encouraged to), you must drop them
-- after you have populated the answer table for that question.
-- Good Luck!

-- Query 1 --------------------------------------------------
-- CREATE VIEW CountActive AS
-- SELECT p_id, count(monthly_rating)
-- FROM PlayerRatings
-- WHERE monthly_rating > 0
-- GROUP BY p_id;

-- CREATE VIEW CountRarity5Lilmon AS
-- SELECT LilmonInventory.p_id, count(LilmonInventory.id)
-- FROM LilmonInventory JOIN Lilmon ON LilmonInventory.p_id = Lilmon.id
-- GROUP BY LilmonInventory.p_id, rarity
-- HAVING rarity = 5;


-- CREATE VIEW Lucky AS
-- SELECT p_id, playername, email
-- FROM CountRarity5Lilmon JOIN Player ON CountRarity5Lilmon.p_id = Player.id
-- WHERE count/rolls >= 0.05;

-- CREATE VIEW Class3 AS
-- SELECT *
-- FROM Whale
-- UNION
-- SELECT *
-- FROM lucky
-- UNION
-- SELECT *
-- FROM Hoarder;

-- INSERT INTO Query1  (SELECT DISTINCT p_id, playername, email FROM Class3 ORDER BY p_id ASC);

-- UPDATE Query1
-- SET classification =
-- Case
--     WHEN (Query1.p_id IN (SELECT p_id FROM Whale) AND Query1.p_id IN (SELECT p_id FROM Lucky) AND Query1.p_id IN (SELECT p_id FROM Hoarder)) THEN 'whale-lucky-hoarder'
--     WHEN (Query1.p_id NOT IN (SELECT p_id FROM Whale) AND Query1.p_id IN (SELECT p_id FROM Lucky) AND Query1.p_id IN (SELECT p_id FROM Hoarder)) THEN '-lucky-hoarder'
--     WHEN (Query1.p_id IN (SELECT p_id FROM Whale) AND Query1.p_id NOT IN (SELECT p_id FROM Lucky) AND Query1.p_id IN (SELECT p_id FROM Hoarder)) THEN 'whale--hoarder'
--     WHEN (Query1.p_id IN (SELECT p_id FROM Whale) AND Query1.p_id IN (SELECT p_id FROM Lucky) AND Query1.p_id NOT IN (SELECT p_id FROM Hoarder)) THEN 'whale-lucky-'
--     WHEN (Query1.p_id NOT IN (SELECT p_id FROM Whale) AND Query1.p_id NOT IN (SELECT p_id FROM Lucky) AND Query1.p_id IN (SELECT p_id FROM Hoarder)) THEN '--hoarder'
--     WHEN (Query1.p_id IN (SELECT p_id FROM Whale) AND Query1.p_id NOT IN (SELECT p_id FROM Lucky) AND Query1.p_id NOT IN (SELECT p_id FROM Hoarder)) THEN 'whale--'
--     WHEN (Query1.p_id NOT IN (SELECT p_id FROM Whale) AND Query1.p_id IN (SELECT p_id FROM Lucky) AND Query1.p_id NOT IN (SELECT p_id FROM Hoarder)) THEN '-lucky-'
--     ELSE '--'
-- END;

-- -- Query 2 --------------------------------------------------
-- CREATE VIEW DistinctPair1 AS
-- SELECT p_id, l_id, element1
-- FROM Lilmon JOIN LilmonInventory ON Lilmon.id = LilmonInventory.l_id
-- WHERE LilmonInventory.in_team = true AND LilmonInventory.fav = true;

-- CREATE VIEW DistinctPair2 AS
-- SELECT p_id, l_id, element2
-- FROM Lilmon JOIN LilmonInventory ON Lilmon.id = LilmonInventory.l_id
-- WHERE LilmonInventory.in_team = true AND LilmonInventory.fav = true;

-- CREATE VIEW countElement1 AS
-- SELECT element1, count(*) AS count1
-- FROM (SELECT DISTINCT * FROM DistinctPair1) AS Uniq1
-- GROUP BY element1;

-- CREATE VIEW countElement2 AS
-- SELECT element2, count(*) AS count2
-- FROM (SELECT DISTINCT * FROM DistinctPair2) AS Uniq2
-- GROUP BY element2;

-- INSERT INTO Query2 (SELECT element, count1+count2 AS popularity_count FROM (countElement1 JOIN countELement2 ON countElement1.element1 = countElement2.element2) ORDER BY popularity_count DESC);

-- Query 3 --------------------------------------------------
-- CREATE VIEW CountActive AS
-- SELECT p_id, count(monthly_rating)
-- FROM PlayerRatings
-- WHERE monthly_rating > 0
-- GROUP BY p_id;

-- CREATE VIEW PlayerActive AS
-- SELECT *
-- FROM CountActive RIGHT JOIN Player ON CountActive.p_id = Player.id;

-- CREATE VIEW PlayerAverage AS
-- SELECT p_id, (total_battles-losses-wins)/count AS monthlyIG
-- FROM PlayerActive;

-- INSERT INTO Query3 (SELECT avg(monthlyIG) AS avg_ig_per_month_per_player FROM PlayerAverage);

-- Query 4 --------------------------------------------------
-- CREATE VIEW CountPopularity AS
-- SELECT l_id, count(DISTINCT p_id) AS popularity_count
-- FROM LilmonInventory
-- WHERE in_team = true AND fav = true
-- GROUP BY l_id;

-- INSERT INTO Query4 (SELECT l_id, name, rarity, popularity_count FROM (CountPopularity JOIN Lilmon ON CountPopularity.l_id = Lilmon.id) ORDER BY popularity_count DESC, rarity DESC, id DESC);

-- Query 5 --------------------------------------------------

-- CREATE VIEW RecentMonth AS
-- SELECT p_id, maxYear, max(month) AS maxMonth
-- FROM RecentYear
-- GROUP BY p_id;

-- CREATE VIEW Last6Month AS
-- SELECT p_id, month, year, monthly_rating, all_time_rating
-- FROM RecentYear CROSS JOIN PlayerRatings
-- WHERE (RecentYear.p_id = PlayerRatings.p_id) AND ((year = maxYear AND maxMonth-month < 6) OR (year = maxYear-1 AND month-maxMonth < 8));

-- Create VIEW RatePlayer AS
-- SELECT p_id, playername, email, min(monthly_rating) AS min_mr, max(monthly_rating) AS max_mr
-- FROM Last6Month JOIN Player ON Last6Month.p_id = Player.id
-- GROUP BY p_id;

-- Create VIEW WellPlayer AS
-- SELECT p_id, playername, email, min_mr, max_mr
-- FROM RatePlayer
-- WHERE max_mr - min_mr <= 50 AND all_time_rating >=2000;

-- INSERT INTO Query5 (SELECT p_id, playername, email, min_mr, max_mr FROM WellPlayer ORDER BY max_mr DESC, min_mr DESC, p_id ASC);

-- -- Query 6 --------------------------------------------------

-- CREATE VIEW LatestMonth AS
-- SELECT g_id, month, year, all_time_rating, maxMonth
-- FROM TimeMonth
-- WHERE month = maxMonth;

-- CREATE VIEW GuildSize AS
-- SELECT guild as g_id, guildname, tag, leader, all_time_rating, count(DISTINCT Player.id) AS sizeNum
-- FROM (Player JOIN LatestMonth ON Player.g_id = LatestMonth.g_id AS Result) JOIN Guild ON Guild.id = Result.g_id
-- GROUP BY g_id;

-- INSERT INTO Query6 (SELECT g_id, guildname, tag, leader AS leader_id, playername AS leader_name, country_code AS leader_country FROM GuildSize JOIN Player ON GuildSize.leader = Player.id ORDER BY g_id ASC);

-- UPDATE Query6
-- SET Query6.size = 
-- CASE 
--     WHEN GuildSize.sizeNum >=500 THEN 'large'

--     WHEN GuildSize.sizeNum >=100 AND GuildSize.sizeNum < 500 THEN 'medium'

--     ELSE 'small'
-- END
-- SET Query6.classification = 
-- CASE 
--     WHEN (Query6.size = 'large' AND GuildSize.all_time_rating >= 2000) OR (Query6.size = 'medium' AND GuildSize.all_time_rating >= 1750) OR (Query6.size = 'small' AND GuildSize.all_time_rating >= 1500) THEN 'elite'
--     WHEN (Query6.size = 'large' AND GuildSize.all_time_rating < 2000 AND GuildSize.all_time_rating >= 1500) OR (Query6.size = 'medium' AND GuildSize.all_time_rating < 1750 AND GuildSize.all_time_rating >= 1250) OR (Query6.size = 'small' AND GuildSize.all_time_rating < 1500 AND GuildSize.all_time_rating >= 1000) THEN 'average'
--     WHEN (Query6.size = 'large' AND GuildSize.all_time_rating < 1500) OR (Query6.size = 'medium' AND GuildSize.all_time_rating < 1250) OR (Query6.size = 'small' AND GuildSize.all_time_rating < 1000) THEN 'casual'
--     ELSE 'new'
-- END
-- FROM GuildSize;

-- Query 7 --------------------------------------------------good
INSERT INTO Query7
SELECT Player.country_code as country_code,
    (SUM(PlayerRatings.month)/COUNT(PlayerRatings.month)) as player_retention
FROM Player, PlayerRatings
WHERE Player.id = PlayerRatings.p_id AND PlayerRatings.month <> 0
GROUP BY Player.country_code
ORDER BY player_retention DESC;

-- Query 8 --------------------------------------------------
DROP TABLE IF EXISTS Result;
CREATE TABLE Result (
    p_id INTEGER,
    playername VARCHAR(255),
    player_wr REAL,
    g_id INTEGER,
    guildname VARCHAR(255),
    tag VARCHAR(5),
    guild_aggregate_wr REAL
);

INSERT INTO 
    Result (p_id, playername, player_wr, g_id, guildname, tag, guild_aggregate_wr)
SELECT 
    Player.id as p_id,
    Player.playername as playername,
    (Player.wins/Player.total_battles) as player_wr,
    Player.guild as g_id,
    Guild.guildname as guildname,
    Guild.tag as tag,
    (SELECT (SUM(wins)/SUM(total_battles))
    FROM Player as P
    WHERE P.guild = Player.guild) as guild_aggregate_wr
FROM Player, Guild
WHERE Player.guild = Guild.id AND Player.guild IS NOT NULL;

INSERT INTO 
  Result (p_id, playername, player_wr, g_id, guildname, tag, guild_aggregate_wr)
SELECT
  Player.id as p_id,
  Player.playername as playername,
  (Player.wins / Player.total_battles) as player_wr,
  Player.guild as g_id,
  NULL,
  NULL,
  NULL
FROM
  Player
WHERE
  Player.guild IS NULL;

INSERT INTO Query8
SELECT *
FROM Result
ORDER BY player_wr DESC, guild_aggregate_wr DESC;

DROP TABLE Result;
-- Query 9 --------------------------------------------------

DROP TABLE IF EXISTS topten;
DROP TABLE IF EXISTS Result;
DROP TABLE IF EXISTS totalcount;
DROP TABLE IF EXISTS allcountrycount;
DROP TABLE IF EXISTS maxcount;
CREATE TABLE Result(
    g_id INTEGER,
    guildname VARCHAR(255),
    monthly_rating INTEGER,
    all_time_rating INTEGER,
    country_pcount INTEGER,
    total_pcount INTEGER,
    country_code CHAR(3)
);

CREATE TABLE topten(
    g_id INTEGER,
    guildname VARCHAR(255) UNIQUE NOT NULL,
    monthly_rating INTEGER NOT NULL,
    all_time_rating INTEGER NOT NULL
);

CREATE TABLE totalcount(
    g_id INTEGER,
    total_pcount INTEGER
);

CREATE TABLE allcountrycount(
    g_id INTEGER,
    c INTEGER,
    country_code CHAR(3)
);

CREATE TABLE maxcount(
    g_id INTEGER,
    country_pcount INTEGER,
    country_code CHAR(3)
);

INSERT INTO topten
SELECT temp.g_id, Guild.guildname, temp.monthly_rating, temp.all_time_rating
FROM Guild, (
    SELECT DISTINCT g_id, monthly_rating, all_time_rating
    FROM  GuildRatings
    ORDER BY all_time_rating DESC, monthly_rating DESC, g_id ASC
    FETCH FIRST 10 ROWS ONLY)temp
WHERE Guild.id = temp.g_id;

INSERT INTO totalcount
SELECT topten.g_id AS g_id,
    COUNT(Player.id) AS total_pcount
FROM Player, topten
WHERE Player.guild = topten.g_id
GROUP BY topten.g_id;

INSERT INTO allcountrycount
SELECT 
    Player.guild as g_id,
    COUNT(Player.country_code) AS c, 
    Player.country_code as country_code
FROM Player, topten
WHERE Player.guild = topten.g_id
GROUP BY Player.guild, Player.country_code;

INSERT INTO maxcount
SELECT allcountrycount.c as country_pcount,
    allcountrycount.g_id as g_id,
    allcountrycount.country_code as country_code
FROM allcountrycount
WHERE allcountrycount.c = (
    SELECT MAX(c) as max_c
    FROM allcountrycount
);

INSERT INTO Result
SELECT topten.g_id as g_id,
    topten.guildname as guildname,
    topten.monthly_rating as monthly_rating,
    topten.all_time_rating as all_time_rating,
    maxcount.country_pcount as country_pcount,
    totalcount.total_pcount as total_pcount,
    maxcount.country_code as country_code
FROM maxcount, totalcount, topten
WHERE maxcount.g_id = totalcount.g_id AND totalcount.g_id = topten.g_id;

INSERT INTO Query9
SELECT *
FROM Result
ORDER BY all_time_rating DESC, monthly_rating DESC, g_id ASC;

DROP TABLE Result;
DROP TABLE topten;
DROP TABLE totalcount;
DROP TABLE allcountrycount;
DROP TABLE maxcount;

-- Query 10 --------------------------------------------------good
INSERT INTO Query10
SELECT Guild.id as g_id, guildname, avg_veteranness
FROM Player, Guild, (
    SELECT p_id, (COUNT(*)/12) as avg_veteranness
    FROM PlayerRatings
    GROUP BY p_id
)AS Average
WHERE Average.p_id = Player.id AND Player.guild = Guild.id
ORDER BY avg_veteranness DESC, g_id ASC


