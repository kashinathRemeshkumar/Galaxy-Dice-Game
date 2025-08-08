<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="DBManager.DBManager" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String username = request.getParameter("user");
    if (username == null || username.trim().isEmpty()) {
        response.sendRedirect("index.jsp"); // Redirect to login if no user is specified
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    List<String> onlineUsers = new ArrayList<>();
    List<String> gamePlayers = new ArrayList<>();
    boolean isInGame = false;
    boolean isGameFull = false;

    try {
        DBManager db = new DBManager("localhost:3306", "root", "1234");
        conn = db.connectToDatabase("galaxygame");

        // 1. Set the user online
        ps = conn.prepareStatement("UPDATE users SET isOnline = 1 WHERE username = ?");
        ps.setString(1, username);
        ps.executeUpdate();
        ps.close();

        // 2. Get players currently in the game
        ps = conn.prepareStatement("SELECT username FROM game_state");
        rs = ps.executeQuery();
        while (rs.next()) {
            gamePlayers.add(rs.getString("username"));
        }
        rs.close();
        ps.close();

        // 3. Determine game state and user status
        isInGame = gamePlayers.contains(username);
        isGameFull = (gamePlayers.size() >= 2);

        // 4. Conditional logic to join the game
        if (!isInGame && !isGameFull) {
            // Game is not full and user is not in it, so add them
            boolean isFirstPlayer = gamePlayers.isEmpty();
            ps = conn.prepareStatement("INSERT INTO game_state (username, position, turn) VALUES (?, 0, ?)");
            ps.setString(1, username);
            ps.setBoolean(2, isFirstPlayer);
            ps.executeUpdate();
            ps.close();

            // The user is now in the game
            isInGame = true;
            isGameFull = true; // After adding the second player, the game is full
        }
        
        // 5. Check if the game is now full. If so, and the user is a player, redirect them.
        if(isGameFull && isInGame) {
            // The game has 2 players, and the current user is one of them.
            response.sendRedirect("main_game.jsp?user=" + username);
            return;
        } else if (isGameFull && !isInGame) {
            // The game has 2 players, and the current user is not one of them.
            response.sendRedirect("spectator.jsp?user=" + username);
            return;
        }

        // Get all online users (only needed for the waiting screen)
        ps = conn.prepareStatement("SELECT username FROM users WHERE isOnline = 1");
        rs = ps.executeQuery();
        while (rs.next()) {
            onlineUsers.add(rs.getString("username"));
        }
        rs.close();
        ps.close();


    } catch (Exception e) {
        out.println("<h3 style='color:red;'>Error: " + e.getMessage() + "</h3>");
    } finally {
        try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
        try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
        try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Galaxy Dice Lobby</title>
    <style>
        body {
            background-color: #0d1117;
            color: #c9d1d9;
            font-family: Arial, sans-serif;
            text-align: center;
            padding: 50px;
        }
        /* ... (rest of your CSS) ... */
    </style>
    <meta http-equiv="refresh" content="3"> </head>
<body>
    <h1>Welcome, <%= username %>!</h1>

    <div class="player-list">
        <h2>Online Players:</h2>
        <ul>
            <% for (String user : onlineUsers) { %>
                <li><%= user %></li>
            <% } %>
        </ul>
    </div>
    
    <p>Waiting for more players to join...</p>

    <form method="post" action="quit.jsp" style="margin-top: 20px;">
        <input type="hidden" name="user" value="<%= username %>">
        <button class="start-btn quit-btn">❌ Quit Queue</button>
    </form>
</body>
</html>