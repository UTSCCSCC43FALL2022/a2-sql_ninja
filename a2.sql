SET search_path TO A2;

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
SELECT element1, count(*) AS count1
FROM (SELECT DISTINCT * FROM DistinctPair1) AS Uniq1
GROUP BY element1;

CREATE VIEW countElement2 AS
SELECT element2, count(*) AS count2
FROM (SELECT DISTINCT * FROM DistinctPair2) AS Uniq2
GROUP BY element2;

INSERT INTO Query2 (SELECT element, count1+count2 AS popularity_count FROM (countElement1 JOIN countELement2 ON countElement1.element1 = countElement2.element2) ORDER BY popularity_count DESC);

-- Query 3 --------------------------------------------------
-- CREATE VIEW CountActive AS
-- SELECT p_id, count(monthly_rating)
-- FROM PlayerRatings
-- WHERE monthly_rating > 0
-- GROUP BY p_id;

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

-- Query 4 --------------------------------------------------
CREATE VIEW CountPopularity AS
SELECT l_id, count(DISTINCT p_id) AS popularity_count
FROM LilmonInventory
WHERE in_team = true AND fav = true
GROUP BY l_id;

INSERT INTO Query4 (SELECT l_id, name, rarity, popularity_count FROM (CountPopularity JOIN Lilmon ON CountPopularity.l_id = Lilmon.id) ORDER BY popularity_count DESC, rarity DESC, id DESC);

-- Query 5 --------------------------------------------------

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

CREATE VIEW LatestMonth AS
SELECT g_id, month, year, all_time_rating, maxMonth
FROM TimeMonth
WHERE month = maxMonth;

CREATE VIEW GuildSize AS
SELECT guild as g_id, guildname, tag, leader, all_time_rating, count(DISTINCT Player.id) AS sizeNum
FROM (Player JOIN LatestMonth ON Player.g_id = LatestMonth.g_id AS Result) JOIN Guild ON Guild.id = Result.g_id
GROUP BY g_id;

INSERT INTO Query6 (SELECT g_id, guildname, tag, leader AS leader_id, playername AS leader_name, country_code AS leader_country FROM GuildSize JOIN Player ON GuildSize.leader = Player.id ORDER BY g_id ASC);

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
INSERT INTO Query7 (SELECT * FROM Player);

-- Query 8 --------------------------------------------------
INSERT INTO Query8 (SELECT * FROM Player);

-- Query 9 --------------------------------------------------
INSERT INTO Query9 (SELECT * FROM Player);

-- Query 10 --------------------------------------------------
INSERT INTO Query10 (SELECT * FROM Player);

