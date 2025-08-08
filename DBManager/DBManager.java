package DBManager;

import java.sql.*;

public class DBManager {
    private String jdbcURL;
    private String username;
    private String password;

    public DBManager(String host, String user, String pass) {
        this.jdbcURL = "jdbc:mysql://" + host + "/";
        this.username = user;
        this.password = pass;
    }

    public Connection connectToServer() throws SQLException {
        return DriverManager.getConnection(jdbcURL, username, password);
    }

    public Connection connectToDatabase(String dbName) throws SQLException {
        return DriverManager.getConnection(jdbcURL + dbName, username, password);
    }

    // ✅ Initialize DB
    public boolean initDatabase(String dbName) {
        try (Connection conn = connectToServer();
             Statement stmt = conn.createStatement()) {
            stmt.executeUpdate("CREATE DATABASE IF NOT EXISTS " + dbName);
            System.out.println("Database '" + dbName + "' created or already exists.");
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ✅ Create Table
    public boolean createTable(String dbName, String createSQL) 
    {
        try (Connection conn = connectToDatabase(dbName);
             Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(createSQL);
            System.out.println("Table created.");
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ✅ Insert Data
    public boolean insertData(String dbName, String insertSQL) {
        try (Connection conn = connectToDatabase(dbName);
             Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(insertSQL);
            System.out.println("Data inserted.");
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ✅ Query Data
    public void queryData(String dbName, String querySQL) {
        try (Connection conn = connectToDatabase(dbName);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(querySQL)) {

            ResultSetMetaData meta = rs.getMetaData();
            int colCount = meta.getColumnCount();

            while (rs.next()) {
                for (int i = 1; i <= colCount; i++) {
                    System.out.print(rs.getString(i) + "\t");
                }
                System.out.println();
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // ✅ Update or Delete
    public boolean executeUpdate(String dbName, String updateSQL) {
        try (Connection conn = connectToDatabase(dbName);
             Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(updateSQL);
            System.out.println("Update executed.");
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
