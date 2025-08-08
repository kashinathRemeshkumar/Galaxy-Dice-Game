<%@ page import="java.sql.*, DBManager.DBManager" %>
<%
    String username = request.getParameter("username");
    int score = Integer.parseInt(request.getParameter("score"));
    boolean passTurn = "true".equals(request.getParameter("next"));

    DBManager db = new DBManager("localhost:3306", "root", "1234");
    Connection conn = db.connectToDatabase("GalaxyGame");

    PreparedStatement updateStmt = conn.prepareStatement(
        "UPDATE game_state SET position = ?, turn = 0 WHERE username = ?"
    );
    updateStmt.setInt(1, score);
    updateStmt.setString(2, username);
    updateStmt.executeUpdate();

    if (passTurn) {
        // Switch turn to the other player
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT username FROM game_state WHERE username != '" + username + "'");

        if (rs.next()) {
            String nextPlayer = rs.getString("username");
            PreparedStatement turnStmt = conn.prepareStatement(
                "UPDATE game_state SET turn = 1 WHERE username = ?"
            );
            turnStmt.setString(1, nextPlayer);
            turnStmt.executeUpdate();
            turnStmt.close();
        }

        rs.close();
        stmt.close();
    }

    updateStmt.close();
    conn.close();
%>
