SET search_path TO A2;

-- If you define any views for a question (you are encouraged to), you must drop them
-- after you have populated the answer table for that question.
-- Good Luck!

-- Query 1 --------------------------------------------------
INSERT INTO Query1

-- Query 2 --------------------------------------------------
INSERT INTO Query2

-- Query 3 --------------------------------------------------
INSERT INTO Query3

-- Query 4 --------------------------------------------------
INSERT INTO Query4

-- Query 5 --------------------------------------------------
INSERT INTO Query5

-- Query 6 --------------------------------------------------
INSERT INTO Query6

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
SELECT *
FROM Result
ORDER BY player_wr DESC, guild_aggregate_wr DESC;

DROP TABLE Result;
-- Query 9 --------------------------------------------------
INSERT INTO Query9

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

CREATE VIEW All_country_count AS
SELECT COUNT(*) AS c, 
    Player.country_code as country_code,
    Top_10.g_id as g_id
FROM Player JOIN Top_10
WHERE Player.guild = Top_10.g_id
GROUP BY Player.country_code;

DECLARE @Counter INTEGER 
SET @Counter=1
WHILE ( @Counter <= 10)
BEGIN
    DECLARE @gid INTEGER 
    SET @gid = (
        SELECT TOP 1 g_id FROM Top_10;
    )

    CREATE VIEW All_country_count AS
    SELECT COUNT(*) AS c, country_code, gid
    FROM Player
    WHERE Player.guild = Top_10.g_id
    GROUP BY country_code;

    CREATE VIEW Max_count AS
    SELECT gid, c, country_code
    FROM All_country_count JOIN (
        SELECT MAX(c) as max_c, country_code, gid, c
        FROM All_country_count
    )Max_count_num
    WHERE c = max_c AND All_country_count.gid = Max_count_num.gid;


    INSERT INTO Result
    SELECT DISTINCT Total_count.gid as g_id, 
        Top_10.guildname as guildname, 
        Top_10.monthly_rating as monthly_rating,
        Top_10.all_time_rating as all_time_rating,
        Max_count.c as country_pcount,
        Total_count.total_c as total_pcount,
        Max_count.country_code as country_code
    FROM Total_count JOIN Max_count JOIN Top_10
    WHERE Total_count.gid = Max_count.gid = Top_10.g_id

    DELETE FROM Top_10 WHERE Top_10.g_id = @gid
    DROP VIEW All_country_count
    DROP VIEW Max_count
    DROP VIEW Total_count
    SET @Counter  = @Counter  + 1
END

DROP TABLE Top_10;

SELECT *
FROM Result
ORDER BY all_time_rating DESC,
    monthly_rating DESC,
    g_id ASC
;

DROP TABLE Result;


-- Query 10 --------------------------------------------------
INSERT INTO Query10
SELECT g_id, guildname, avg_veteranness
FROM Player, Guild, (
    SELECT p_id, SUM(month) avg_veteranness
    FROM PlayerRating
    GROUP BY p_id
)AS Average
WHERE Average.p_id = Player.id AND Player.guild = Guild.id
ORDER BY avg_veteranness DESC, g_id ASC


