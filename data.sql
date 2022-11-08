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