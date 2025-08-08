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
    List<String> players = new ArrayList<>();
    String currentTurn = "";

    try {
        DBManager db = new DBManager("localhost:3306", "root", "1234");
        conn = db.connectToDatabase("galaxygame");

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

        rs = stmt.executeQuery("SELECT username, roll FROM rolls ORDER BY timestamp DESC LIMIT 4");
        while (rs.next()) {
            lastRolls.put(rs.getString("username"), rs.getInt("roll"));
        }

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Galaxy Dice – Spectator</title>
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

        .player {
            width: 20px;
            height: 20px;
            border-radius: 50%;
            position: absolute;
        }

        .player-0 { background-color: orange; top: 5px; left: 5px; }
        .player-1 { background-color: cyan; bottom: 5px; right: 5px; }
        .player-2 { background-color: lime; top: 5px; right: 5px; }
        .player-3 { background-color: violet; bottom: 5px; left: 5px; }

        .dice-history div {
            background-color: rgba(255, 255, 255, 0.1);
            padding: 10px;
            border-radius: 8px;
            display: inline-block;
            margin: 5px;
        }

        .panel {
            margin-top: 20px;
        }

        ul {
            list-style: none;
            padding: 0;
        }
    </style>
</head>
<body>

<h1>👁 Spectator Mode – Galaxy Dice Game</h1>
<h3>Welcome, <%= username %>. You're watching the match.</h3>

<div class="panel">
    <h3>🎮 Players & Positions</h3>
    <% 
        int colorIndex = 0;
        String[] colors = {"orange", "cyan", "lime", "violet"};
    %>
    <ul>
    <% for (String p : players) { %>
        <li>
            <span style="color: <%= colors[colorIndex % colors.length] %>;">⬤</span>
            <%= p %> – Position: <%= positions.get(p) %>
        </li>
        <% colorIndex++; %>
    <% } %>
    </ul>
</div>

<div class="dice-history">
    <h3>🎲 Recent Rolls</h3>
    <% for (Map.Entry<String, Integer> entry : lastRolls.entrySet()) { %>
        <div><b><%= entry.getKey() %></b> rolled <%= entry.getValue() %></div>
    <% } %>
</div>

<div class="status">
    <h3>🔁 Current Turn: <%= currentTurn %></h3>
    <p>This page auto-refreshes every 5 seconds</p>
</div>

<div id="board"></div>

<script>
    const board = document.getElementById("board");

    // Build 10x10 board in snake pattern
    for (let row = 9; row >= 0; row--) {
        for (let col = 0; col < 10; col++) {
            const cellNum = row % 2 === 0 ? row * 10 + col : row * 10 + (9 - col);
            const cell = document.createElement("div");
            cell.className = "cell";
            cell.id = "cell-" + cellNum;
            cell.textContent = cellNum;
            board.appendChild(cell);
        }
    }

    const positions = {
        <% int i = 0;
        for (Map.Entry<String, Integer> entry : positions.entrySet()) {
            String p = entry.getKey().replace("\"", "\\\"");
            int pos = entry.getValue();
        %>
        "<%= p %>": <%= pos %><%= (++i < positions.size()) ? "," : "" %>
        <% } %>
    };

    function placePlayers() {
        let index = 0;
        for (const [player, pos] of Object.entries(positions)) {
            const piece = document.createElement("div");
            piece.className = "player player-" + index;
            const cell = document.getElementById("cell-" + pos);
            if (cell) cell.appendChild(piece);
            index++;
        }
    }

    placePlayers();

    // Refresh page every 5 seconds
    setInterval(() => location.reload(), 5000);
</script>

</body>
</html>
