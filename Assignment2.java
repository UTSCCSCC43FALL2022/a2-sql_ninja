import java.sql.*;

public class Assignment2 {


	public Connection connection;


	public Assignment2() {

	}


	public boolean connectDB(String URL, String username, String password) {
		// throw new RuntimeException("Function Not Implemented");

		try {
			
			// Load JDBC driver
		   Class.forName("org.postgresql.Driver");

	   } catch (ClassNotFoundException e) {

		   System.out.println("Include PostgreSQL JDBC Driver in your library path!");
		   e.printStackTrace();
		   return false;
	   }

		boolean suc = false;
        try {
            connection = DriverManager.getConnection(URL, username, password);
            System.out.println("Connected to the PostgreSQL server successfully.");
			suc = true;
        } catch (SQLException e) {
			System.out.println("Connection Failed! Check output console");
            e.printStackTrace();
        }
        return suc;
	}


	public boolean disconnectDB() {
		// throw new RuntimeException("Function Not Implemented");
		boolean suc = false;
		try{
			connection.close();
			suc = true;
		} catch(Exception ex) {
			System.out.println(ex.getMessage());
		}
		return suc;
	}


	public boolean insertPlayer(int id, String playerName, String email, String countryCode) {
		if (connection != null) {
			System.out.println("You are ready to work with your database!");
		} else {
			System.out.println("Failed to make connection!");
		}
		try{
			Statement stat;
			//Create a Statement for executing SQL queries
			stat = connection.createStatement(); 
			String query = "INSERT INTO users " +
                "(id, playername, emial, country_code) " +
                "VALUES " +
                "(%d, '%s', '%s', '%s', '%s', %d)";
        	query = String.format(query, id, playerName, email, countryCode);
       		stat.executeUpdate(query);
        	System.out.println("++ inserted user: " + playerName);
			return true;
		} catch (SQLException e) {
			System.out.println("Inert Execution failed!");
		}
		return false;
	}


	public int getMembersCount(int gid) {
		throw new RuntimeException("Function Not Implemented");
	}


	public String getPlayerInfo(int id) {
		throw new RuntimeException("Function Not Implemented");
	}


	public boolean changeGuild(String oldName, String newName) {
		throw new RuntimeException("Function Not Implemented");
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
