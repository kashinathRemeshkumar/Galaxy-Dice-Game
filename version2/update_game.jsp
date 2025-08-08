<%@ page import="DBManager.DBManager, java.sql.*" %>
<%
    String user = request.getParameter("user");
    int position = Integer.parseInt(request.getParameter("position"));

    DBManager db = new DBManager("localhost:3306", "root", "1234");
    Connection conn = db.connectToDatabase("GalaxyGame");

    // Update current player's position
    PreparedStatement update = conn.prepareStatement("UPDATE game_state SET position = ?, turn = FALSE WHERE username = ?");
    update.setInt(1, position);
    update.setString(2, user);
    update.executeUpdate();
    update.close();

    // Switch turn to other player
    PreparedStatement switchTurn = conn.prepareStatement("UPDATE game_state SET turn = TRUE WHERE username != ?");
    switchTurn.setString(1, user);
    switchTurn.executeUpdate();

    conn.close();
%>
