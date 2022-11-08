"CREATE TABLE UpdateGuildRating(" +
		"    g_id INTEGER ," +
		"    month INTEGER NOT NULL," +
		"    year INTEGER NOT NULL," +
		"    monthly_rating INTEGER NOT NULL," +
		"    all_time_rating INTEGER NOT NULL," +
		"    CHECK (month BETWEEN 1 AND 12)" +
		");" +
		"INSERT INTO UpdateGuildRating " +
		"SELECT g_id, month, year, monthly_rating, all_time_rating" +
		"FROM GuildRatings" +
		"WHERE ( month = 9 AND year = 2020);" +
		"UPDATE UpdateGuildRating" +
		"SET monthly_rating = 1000, " +
		"    all_time_rating = 1000, " +
		"    month = 10" +
		"FROM UpdateGuildRating" +
		"WHERE monthly_rating IS NULL;" +
		"UPDATE UpdateGuildRating" +
		"SET monthly_rating = monthly_rating*1.1, all_time_rating = all_time_rating*1.1, month = 10" +
		"FROM UpdateGuildRating" +
		"WHERE monthly_rating IS NOT NULL;" +
		"INSERT INTO GuildRatings" +
		"SELECT *" +
		"FROM UpdateGuildRating;");