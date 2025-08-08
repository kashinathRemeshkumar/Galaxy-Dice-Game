<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="DBManager.DBManager" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>


<%
    String username = request.getParameter("user");
    if (username == null || username.trim().isEmpty()) {
        response.sendRedirect("index.jsp");
        return;
    }

    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    Map<String, Integer> positions = new HashMap<>();
    Map<String, Integer> lastRolls = new HashMap<>();
    String currentTurn = "";
    List<String> players = new ArrayList<>();

    try {
        DBManager db = new DBManager("localhost:3306", "root", "1234");
        conn = db.connectToDatabase("galaxygame");

        // Check if 2 players are playing
        Statement countStmt = conn.createStatement();
        ResultSet countRs = countStmt.executeQuery("SELECT COUNT(*) FROM game_state");
        countRs.next();
        int playerCount = countRs.getInt(1);
        countRs.close();
        countStmt.close();

        if (playerCount < 2) {
            conn.close();
            response.sendRedirect("lobby.jsp?user=" + username);
            return;
        }

        stmt = conn.createStatement();
        rs = stmt.executeQuery("SELECT username, position, turn FROM game_state");

        while (rs.next()) {
            String user = rs.getString("username");
            players.add(user);
            positions.put(user, rs.getInt("position"));
            if (rs.getBoolean("turn")) {
                currentTurn = user;
            }
        }
        rs.close();

        rs = stmt.executeQuery("SELECT username, roll FROM rolls ORDER BY timestamp DESC LIMIT 2");
        while (rs.next()) {
            lastRolls.put(rs.getString("username"), rs.getInt("roll"));
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }

    String opponent = "";
    for (String p : players) {
        if (!p.equals(username)) {
            opponent = p;
            break;
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Galaxy Dice Game</title>
    <style>
        body {
            background: linear-gradient(to right, #0f2027, #203a43, #2c5364);
            color: white;
            font-family: Arial, sans-serif;
            text-align: center;
        }

        #board {
            display: grid;
            grid-template-columns: repeat(10, 50px);
            grid-template-rows: repeat(10, 50px);
            gap: 1px;
            width: fit-content;
            margin: 20px auto;
        }

        .cell {
            width: 50px;
            height: 50px;
            border: 1px solid #ccc;
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 12px;
            position: relative;
            background-color: #111;
        }

        .player1, .player2 {
            width: 20px;
            height: 20px;
            border-radius: 50%;
            position: absolute;
        }

        .player1 {
            background-color: orange;
            top: 5px;
            left: 5px;
        }

        .player2 {
            background-color: cyan;
            bottom: 5px;
            right: 5px;
        }

        .panel, .status, .dice-history {
            margin-top: 20px;
        }

        button {
            padding: 10px 20px;
            font-size: 16px;
            margin: 10px;
            cursor: pointer;
        }

        .dice-history div {
            background-color: rgba(255, 255, 255, 0.1);
            padding: 10px;
            border-radius: 8px;
            display: inline-block;
            margin: 5px;
        }

        .quit-button {
            background-color: red;
            color: white;
            border: none;
        }
    </style>
</head>
<body>

<h1>🌌 Welcome, <%= username %>!</h1>
<h2>Reach Planet Zeta! 🚀</h2>

<div class="panel">
    <div>🧑 Your Color: <span style="color:orange;">Orange</span></div>
    <div>👽 Opponent: <span style="color:cyan;">Cyan</span></div>
</div>

<div class="dice-history">
    <% for (Map.Entry<String, Integer> entry : lastRolls.entrySet()) { %>
        <div><b><%= entry.getKey() %></b> rolled 🎲 <%= entry.getValue() %></div>
    <% } %>
</div>

<div id="board"></div>

<div class="status">
    <% if (username.equals(currentTurn)) { %>
        <button onclick="rollDice()">🎲 Roll Dice</button>
    <% } else { %>
        <p>⏳ Waiting for <%= currentTurn %> to roll...</p>
    <% } %>

    <form method="post" action="quit.jsp" style="display:inline;">
        <input type="hidden" name="user" value="<%= username %>">
        <button type="submit" class="quit-button">❌ Quit Game</button>
    </form>
</div>

<script>
    const board = document.getElementById("board");

    // Build 10x10 grid in snake pattern
    for (let row = 9; row >= 0; row--) {
        for (let col = 0; col < 10; col++) {
            let cellNum = row % 2 === 0 ? row * 10 + col : row * 10 + (9 - col);
            const cell = document.createElement("div");
            cell.className = "cell";
            cell.id = "cell-" + cellNum;
            cell.textContent = cellNum;
            board.appendChild(cell);
        }
    }

    const positions = {
        <% int c = 0; for (Map.Entry<String, Integer> entry : positions.entrySet()) {
            String u = entry.getKey().replace("\"", "\\\"");
            int pos = entry.getValue();
        %>"<%= u %>": <%= pos %><%= (++c < positions.size()) ? "," : "" %><% } %>
    };

    const username = "<%= username %>";
    const opponent = "<%= opponent %>";

    function placePlayers() {
        for (const [player, pos] of Object.entries(positions)) {
            const piece = document.createElement("div");
            piece.className = (player === username) ? 'player1' : 'player2';
            const cell = document.getElementById("cell-" + pos);
            if (cell) cell.appendChild(piece);
        }
    }

    function rollDice() {
        fetch("roll_dice.jsp?user=" + username)
            .then(() => setTimeout(() => location.reload(), 1000));
    }

    placePlayers();

    // Auto-refresh every 5 seconds
    setInterval(() => location.reload(), 5000);
</script>

</body>
</html>
