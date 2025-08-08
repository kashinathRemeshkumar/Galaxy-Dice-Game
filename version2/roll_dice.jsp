<%@ page import="DBManager.DBManager, java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String username = request.getParameter("user");
    if (username == null || username.trim().isEmpty()) {
        response.sendRedirect("index.jsp");
        return;
    }

    DBManager db = new DBManager("localhost:3306", "root", "1234");
    Connection conn = db.connectToDatabase("GalaxyGame");

    // Roll dice
    int dice = (int)(Math.random() * 6) + 1;

    // Wormholes and asteroids
    Map<Integer, Integer> wormholes = new HashMap<>();
    wormholes.put(3, 22);
    wormholes.put(8, 26);
    wormholes.put(20, 38);
    wormholes.put(55, 70);

    Map<Integer, Integer> asteroids = new HashMap<>();
    asteroids.put(99, 10);
    asteroids.put(65, 25);
    asteroids.put(50, 5);

    // Get current position
    int position = 0;
    PreparedStatement getPos = conn.prepareStatement("SELECT position FROM game_state WHERE username = ?");
    getPos.setString(1, username);
    ResultSet rs = getPos.executeQuery();
    if (rs.next()) {
        position = rs.getInt("position");
    }
    rs.close();
    getPos.close();

    // Move forward
    position += dice;

    // Apply jump only if still in range
    if (wormholes.containsKey(position)) {
        position = wormholes.get(position);
    } else if (asteroids.containsKey(position)) {
        position = asteroids.get(position);
    }

    if (position > 99) position = 99;

    // Update position in DB
    PreparedStatement update = conn.prepareStatement("UPDATE game_state SET position = ? WHERE username = ?");
    update.setInt(1, position);
    update.setString(2, username);
    update.executeUpdate();
    update.close();

    // Check for win condition
    if (position >= 99) {
        // Set scores
        PreparedStatement updateScore = conn.prepareStatement("UPDATE users SET score = score + 10000 WHERE username = ?");
        updateScore.setString(1, username);
        updateScore.executeUpdate();
        updateScore.close();

        // Remove game_state or mark game ended (optional)
        // Redirect winner and loser
        Statement stmt = conn.createStatement();
        ResultSet others = stmt.executeQuery("SELECT username FROM game_state WHERE username != '" + username + "'");
        String otherPlayer = null;
        if (others.next()) {
            otherPlayer = others.getString("username");
        }
        stmt.close();

        // Clear game state (optional)
        conn.prepareStatement("DELETE FROM game_state").executeUpdate();

        conn.close();

        // Send result info to frontend
        out.print("WINNER:" + username + "|LOSER:" + otherPlayer);
        return;
    }

    // Switch turn
    Statement stmt = conn.createStatement();
    stmt.executeUpdate("UPDATE game_state SET turn = 0");
    PreparedStatement switchTurn = conn.prepareStatement("UPDATE game_state SET turn = 1 WHERE username != ?");
    switchTurn.setString(1, username);
    switchTurn.executeUpdate();
    switchTurn.close();

    conn.close();

    out.print("ROLL:" + dice);
%>
