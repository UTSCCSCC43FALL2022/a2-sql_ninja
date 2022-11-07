import java.sql.*;

public class Assignment2 {


	public Connection connection;


	public Assignment2() {

	}


	public boolean connectDB(String URL, String username, String password) {
		throw new RuntimeException("Function Not Implemented");
	}


	public boolean disconnectDB() {
		throw new RuntimeException("Function Not Implemented");
	}


	public boolean insertPlayer(int id, String playerName, String email, String countryCode) {
		throw new RuntimeException("Function Not Implemented");
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
