import java.sql.*;

public class Assignment2 {


	public Connection connection;


	public Assignment2() {

	}


	public boolean connectDB(String URL, String username, String password) {
		try {
			// Load JDBC driver
		   Class.forName("org.postgresql.Driver");
		   connection = DriverManager.getConnection(URL, username, password);
		   System.out.println("Connected to the PostgreSQL server successfully.");
	   } catch (ClassNotFoundException e) {
		   System.out.println("Include PostgreSQL JDBC Driver in your library path!");
		   e.printStackTrace();
		   return false;
	   } catch (SQLException e) {
			System.out.println("Connection Failed! Check output console");
            e.printStackTrace();
			return false;
        }
        return true;
	}


	public boolean disconnectDB() {
		try{
			connection.close();
			return connection.isClosed();
		} catch(Exception ex) {
			System.out.println(ex.getMessage());
		}
		return false;
	}


	public boolean insertPlayer(int id, String playerName, String email, String countryCode) {
		return true;
	}


	public int getMembersCount(int gid) {
		try{
			Statement stat = connection.createStatement();
			String query = "SELECT COUNT(*) AS COUNT FROM Player where guild='%d'";
			query = String.format(query,gid);
			ResultSet rs = stat.executeQuery(query);
			if(rs.next()){
				System.out.println(rs.getInt("COUNT"));
			}
			return rs.getInt("COUNT");

		} catch (SQLException e) {
			System.out.println("Failed to query the count");
			return -1;
		} 
	}


	public String getPlayerInfo(int id) {
		return null;
	}


	public boolean changeGuild(String oldName, String newName) {
		// check if newName is legal -- cannot duplicate with other guild names
		if (existThisGuild(newName)) return false;
		// then update the guild name
		try{
			Statement stat = connection.createStatement();
			String query = "UPDATE Guild SET guildname = %s WHERE guildname = '%s'";
			query = String.format(query, newName, oldName);
			stat.executeUpdate(query);
			stat.close();
			return true;
		} catch (SQLException e) {
			e.printStackTrace();
		}


		return false;
	}

	public boolean existThisGuild(String guildName){
		Statement stat;
		try{
			stat = connection.createStatement();
			String query = "SELECT * FROM Guild WHERE guildname=%s";
			query = String.format(query, guildName);
			ResultSet rs = stat.executeQuery(query);
			if (rs.next()) return true;
			else{
				return false;
			}
		} catch(SQLException e) {
			System.out.println("Fail to query this guild");
		}
		return false;
	}


	public boolean deleteGuild(String guildName) {
		try{
			Statement stat = connection.createStatement();
			String query = "DELETE FROM Guild WHERE guildname = %s";
			query = String.format(query, guildName);
			stat.executeUpdate(query);
			return true;
		} catch (Exception e){
			e.getStackTrace();
			return false;
		}
	}


	public String listAllTimePlayerRatings() {
		String res = "";
		try{
			Statement stat = connection.createStatement();
			stat.executeUpdate(
					"CREATE TEMP VIEW PR AS " +
					"SELECT * " +
					"FROM a2.PlayerRatings " +
					"WHERE PlayerRatings.year IN (SELECT year AS yeara " +
					"FROM a2.PlayerRatings WHERE year NOT IN (SELECT A.year " +
					"FROM a2.PlayerRatings AS A CROSS JOIN a2.PlayerRatings AS B " +
					"WHERE A.year < B.year)); ");

			ResultSet rs = stat.executeQuery(
					"SELECT playername, all_time_rating " +
					"FROM a2.PlayerRatings INNER JOIN a2.Player " +
					"ON PlayerRatings.p_id = Player.id " +
					"WHERE month IN " +
					"(SELECT month " +
					"FROM PR WHERE month NOT IN  " +
					"(SELECT C.month " +
					"FROM (SELECT PR.month as month " +
					"FROM PR CROSS JOIN PR AS PR1 " +
					"WHERE PR.month < PR1.month) AS C)) " +
					"ORDER BY all_time_rating DESC; ");
			while(rs.next()){
				res += rs.getString(1);
				res += ":";
				res += rs.getString(2);
				res += ":";
			}
			if (res.isEmpty()) {
				rs.close(); 
				stat.close(); 
				return "";
			}
			rs.close(); 
			stat.close();
			res = res.substring(0,res.length() - 1);
			return res;
		} catch (SQLException e){
			e.getStackTrace();
			return "";
		}
		
	}


	public boolean updateMonthlyRatings() {
		try {
			Statement st = connection.createStatement();
			st.executeUpdate(
					"CREATE TEMP VIEW Players AS " +
							"SELECT * " +
							"FROM a2.PlayerRatings " +
							"WHERE PlayerRatings.year = '2022' AND PlayerRatings.month = '9'; ");
			st.executeUpdate(
					"CREATE TEMP VIEW Guilds AS " +
							"SELECT * " +
							"FROM a2.GuildRatings " +
							"WHERE GuildRatings.year = '2022' AND GuildRatings.month = '9'; ");
			int num = st.executeUpdate(
					"INSERT INTO a2.PlayerRatings (p_id, month, year, monthly_rating, all_time_rating) " +
							"SELECT p_id, 10 AS month, 2022 AS year, monthly_rating*1.1 AS monthly_rating, all_time_rating*1.1 AS all_time_rating " +
							"FROM Players; " +
							" " +
							"INSERT INTO a2.PlayerRatings (p_id, month, year, monthly_rating, all_time_rating) " +
							"SELECT Player.id AS p_id, 10 AS month, 2022 AS year, 1000 AS monthly_rating, 1000 AS all_time_rating " +
							"FROM a2.Player " +
							"WHERE Player.id NOT IN (SELECT p_id FROM Players); " +
							" " +
							"INSERT INTO a2.GuildRatings (g_id, month, year, monthly_rating, all_time_rating) " +
							"SELECT g_id, 10 AS month, 2022 AS year, monthly_rating*1.1 AS monthly_rating, all_time_rating*1.1 AS all_time_rating " +
							"FROM Guilds; " +
							" " +
							"INSERT INTO a2.GuildRatings (g_id, month, year, monthly_rating, all_time_rating) " +
							"SELECT Guild.id AS g_id, 10 AS month, 2022 AS year, 1000 AS monthly_rating, 1000 AS all_time_rating " +
							"FROM a2.Guild " +
							"WHERE Guild.id NOT IN (SELECT g_id FROM Guilds); ");
			st.executeUpdate("DROP VIEW Players");
			st.executeUpdate("DROP VIEW Guilds");
			st.close();
			return num >= 1;
		} catch (SQLException e) {
			System.out.println("UpdateMonthlyRatings unsuccessful: " + e);
			return false;
		}
	}


	public boolean createSquidTable() {

	}
}