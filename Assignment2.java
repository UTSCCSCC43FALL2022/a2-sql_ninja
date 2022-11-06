import java.sql.*;

import javax.swing.plaf.synth.SynthIcon;

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
		if (! checkcountrycode(countryCode)) return false;
		if (existPlayer(id)){
			System.out.println("Already exist such a player has the same id");
			return false;
		}if (connection != null) {
			System.out.println("You are ready to work with your database!");
		} else {
			System.out.println("Failed to make connection!");
		}
		try{
			Statement stat;
			//Create a Statement for executing SQL queries
			stat = connection.createStatement(); 
			String query = "INSERT INTO Player " +
                "(id, playername, emial, country_code) " +
                "VALUES " +
                "(%d, '%s', '%s', '%s')";
        	query = String.format(query, id, playerName, email, countryCode);
       		stat.executeUpdate(query);
        	System.out.println("++ inserted user: " + playerName);
			return true;
		} catch (SQLException e) {
			System.out.println("Inert Execution failed!");
		}
		return false;
	}


	public static boolean checkcountrycode(String str) {
		char ch;
		if (str.length() != 3) return false;
		for(int i=0;i < str.length();i++) {
			ch = str.charAt(i);
			if (! Character.isUpperCase(ch)) {
				return false;
			}
		}
		return true;
	}


	public boolean existPlayer(int id){
		Statement stat;
		try{
			stat = connection.createStatement();
			String query = "SELECT * FROM Player WHERE rid=%d";
			query = String.format(query, id);
			ResultSet rs = stat.executeQuery(query);
			if (rs.next()) return true;
			else{
				return false;
			}
		} catch(SQLException e) {
			System.out.println("Fail to query this player");
		}
		return false;
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
		throw new RuntimeException("Function Not Implemented");
	}


	public String listAllTimePlayerRatings() {
		throw new RuntimeException("Function Not Implemented");
	}


	public boolean updateMonthlyRatings() {
		throw new RuntimeException("Function Not Implemented");
	}


	public boolean createSquidTable() {
		throw new RuntimeException("Function Not Implemented");
	}
	
	
	public boolean deleteSquidTable() {
		throw new RuntimeException("Function Not Implemented");
	}
}
