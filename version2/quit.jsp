<%@ page import="DBManager.DBManager, java.sql.*" %>
<%
    String username = request.getParameter("user");
    if (username != null && !username.trim().isEmpty()) {
        DBManager db = new DBManager("localhost:3306", "root", "1234");
        Connection conn = db.connectToDatabase("GalaxyGame");

        // Remove from game_state and set isOnline = 0
        PreparedStatement deleteStmt = conn.prepareStatement("DELETE FROM game_state WHERE username = ?");
        deleteStmt.setString(1, username);
        deleteStmt.executeUpdate();

        PreparedStatement offlineStmt = conn.prepareStatement("UPDATE users SET isOnline = 0 WHERE username = ?");
        offlineStmt.setString(1, username);
        offlineStmt.executeUpdate();

        deleteStmt.close();
        offlineStmt.close();
        conn.close();
    }

    response.sendRedirect("index.jsp");
%>
