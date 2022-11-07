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
		// check country code's format, must be 3 uppercase characters
		if (countryCode.length() != 3 || !countryCode.equals(countryCode.toUpperCase())) return false;
		// check if there already exists same playe's name, email, or countrycode
		try{
			PreparedStatement stat = connection.prepareStatement("SELECT * FROM a2.Player WHERE id = ? " +
			"OR playername = ? OR  email = ?");
			stat.setInt(1, id);
			stat.setString(2, playerName);
			stat.setString(3, email);
			ResultSet rs = stat.executeQuery();
			rs.close();
			stat.close();
			if (rs.next()) return false;
		} catch (SQLException e){
			e.getStackTrace();
		}
		try{
			Statement st;
			//Create a Statement for executing SQL queries
			st = connection.createStatement(); 
			String query = "INSERT INTO Player " +
                "(id, playername, emial, country_code) " +
                "VALUES " +
                "(%d, '%s', '%s', '%s')";
        	query = String.format(query, id, playerName, email, countryCode);
       		st.executeUpdate(query);
        	System.out.println("++ inserted user: " + playerName);
			return true;
		} catch (SQLException e) {
			System.out.println("Inert Execution failed!");
		}
		return false;
	}


	// public boolean existPlayer(int id){
	// 	Statement stat;
	// 	try{
	// 		stat = connection.createStatement();
	// 		String query = "SELECT * FROM Player WHERE rid=%d";
	// 		query = String.format(query, id);
	// 		ResultSet rs = stat.executeQuery(query);
	// 		if (rs.next()) return true;
	// 		else{
	// 			return false;
	// 		}
	// 	} catch(SQLException e) {
	// 		System.out.println("Fail to query this player");
	// 	}
	// 	return false;
	// }


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
		//“id: playername: email: countrycode: coins: rolls: wins: losses: total_battles: guild”
		String res = "%d:%s:%s:%s:%d:%d:%d:%d:%d:%d";
		try{
			Statement stat = connection.createStatement();
			String query = "SELECT * FROM Player WHERE rid=%d";
			query = String.format(query, id);
			ResultSet rs = stat.executeQuery(query);
			// check if cannot find this player
			if (!rs.next()) return "";
			String[] r = new String[3];
            r[0] = rs.getString("playername");
            r[1] = rs.getString("email");
            r[2] = rs.getString("country_code");
			int num[] = new int[7];
			num[0] = rs.getInt("id");
			num[1] = rs.getInt("coins");
			num[2] = rs.getInt("rolls");
			num[3] = rs.getInt("wins");
			num[4] = rs.getInt("losses");
			num[5] = rs.getInt("total_battles");
			num[6] = rs.getInt("guild");
			res = String.format(res, num[0], r[0], r[1], r[2], num[1], num[2], num[3], num[4], num[5], num[6]);
			rs.close();
			stat.close();
			return res;
		} catch (SQLException exception) {
			System.out.println("Fail to find this player's info");
			return "";
		}
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
			PreparedStatement stat = connection.prepareStatement("");
			return true;
		} catch (SQLException e) {
			System.out.println("UpdateMonthlyRatings unsuccessful: " + e);
//			e.printStackTrace();
			return false;
		}
	}


	public boolean createSquidTable() {
		try{
			Statement stat = connection.createStatement();
			

			String query = 
					"CREATE TABLE SQUID_GAME"
					"SELECT id, playername, email, coins, rolls, wins, losses, total_battles " +
					"FROM Player " +
					"WHERE country_code = 'KOR' and " +
					"guild = (SELECT id FROM Guild WHERE guildname = 'Squid Game') "
					
					;
			
			
			ResultSet rs = stat.executeQuery(	
			rs.close(); 
			stat.close();
			return true;
		} catch (SQLException e){
			e.getStackTrace();
			return false;
		}


	}
	
	
	public boolean deleteSquidTable() {
		try {
			Statement st = connection.createStatement();
			st.executeUpdate("DROP VIEW Players");
			return true;
		} catch (SQLException e) {
			System.out.println("DeleteSquidTable unsuccessful: " + e);
			return false;
		}
	}
}
