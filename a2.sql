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

-- Query 8 --------------------------------------------------
INSERT INTO Query8

-- Query 9 --------------------------------------------------
INSERT INTO Query9(
    
)

-- Query 10 --------------------------------------------------
INSERT INTO Query10(
    SELECT g_id, guildname, avg_veteranness
    FROM Player, Guild, (
        SELECT p_id, SUM(month) avg_veteranness
        FROM PlayerRating
        GROUP BY p_id
    )AS Average
    WHERE Average.p_id = Player.id AND Player.guild = Guild.id
)

