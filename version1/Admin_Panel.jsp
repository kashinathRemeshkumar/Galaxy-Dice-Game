<%@ page import="java.util.*, javax.servlet.http.*, javax.servlet.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Galaxy Dice Admin Panel</title>
    <style>
        body {
            background-color: #0d1117;
            color: #c9d1d9;
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
        }

        h1, h2 {
            color: #58a6ff;
        }

        .container {
            padding: 20px 50px;
        }

        .player-section {
            display: flex;
            gap: 30px;
            margin-bottom: 30px;
        }

        .table-container {
            background-color: #161b22;
            padding: 10px;
            border-radius: 8px;
            border: 1px solid #30363d;
            width: 45%;
            max-height: 300px;
            overflow-y: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            color: #c9d1d9;
        }

        th, td {
            padding: 10px;
            border-bottom: 1px solid #30363d;
        }

        tr:hover {
            background-color: #21262d;
            cursor: pointer;
        }

        .action-panel {
            background-color: #161b22;
            padding: 20px;
            border-radius: 8px;
            border: 1px solid #30363d;
            margin-bottom: 30px;
            display: none;
        }

        .action-panel button {
            background-color: #238636;
            color: white;
            border: none;
            padding: 10px 15px;
            margin-right: 10px;
            border-radius: 4px;
            cursor: pointer;
        }

        .action-panel button.demote {
            background-color: #d73a49;
        }

        #logsContainer {
            background-color: #161b22;
            color: #c9d1d9;
            border: 1px solid #333;
            border-radius: 8px;
            padding: 10px;
            height: 200px;
            overflow-y: scroll;
            font-family: monospace;
            white-space: pre-line;
        }
    </style>
</head>
<body>
<div class="container">
    <h1>Galaxy Dice Admin Panel</h1>

    <div class="player-section">
        <!-- Online Players -->
        <div class="table-container">
            <h2>Online Players</h2>
            <table id="onlinePlayers">
                <thead>
                    <tr>
                        <th>Username</th>
                        <th>Password</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    List<String[]> onlinePlayers = (List<String[]>) application.getAttribute("onlinePlayers");
                    if (onlinePlayers != null) {
                        for (String[] user : onlinePlayers) {
                %>
                    <tr onclick="selectPlayer('<%= user[0] %>', '<%= user[1] %>', true)">
                        <td><%= user[0] %></td>
                        <td><%= user[1] %></td>
                        <td>Online</td>
                    </tr>
                <%
                        }
                    }
                %>
                </tbody>
            </table>
        </div>

        <!-- Offline Players -->
        <div class="table-container">
            <h2>Offline Players</h2>
            <table id="offlinePlayers">
                <thead>
                    <tr>
                        <th>Username</th>
                        <th>Password</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    List<String[]> offlinePlayers = (List<String[]>) application.getAttribute("offlinePlayers");
                    if (offlinePlayers != null) {
                        for (String[] user : offlinePlayers) {
                %>
                    <tr onclick="selectPlayer('<%= user[0] %>', '<%= user[1] %>', false)">
                        <td><%= user[0] %></td>
                        <td><%= user[1] %></td>
                        <td>Offline</td>
                    </tr>
                <%
                        }
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Action Panel -->
    <div id="actionPanel" class="action-panel">
        <h2>Selected Player: <span id="selectedUser"></span></h2>
        <form method="post" action="AdminServlet">
            <input type="hidden" name="username" id="formUsername" />
            <input type="hidden" name="status" id="formStatus" />
            <button type="submit" name="action" value="update">Update</button>
            <button type="submit" name="action" value="delete">Delete</button>
            <button type="submit" name="action" value="promote">Promote to Admin</button>
            <button type="submit" name="action" value="demote" class="demote">Demote from Admin</button>
        </form>
    </div>

    <!-- Logs Section -->
    <div>
        <h2>System Logs</h2>
        <div id="logsContainer">
            Loading logs...
        </div>
    </div>
</div>

<!-- JavaScript -->
<script>
    function selectPlayer(username, password, isOnline) {
        document.getElementById("actionPanel").style.display = "block";
        document.getElementById("selectedUser").innerText = username;
        document.getElementById("formUsername").value = username;
        document.getElementById("formStatus").value = isOnline ? "online" : "offline";
    }

    function fetchLogs() {
        fetch('logs.jsp')
            .then(response => response.text())
            .then(data => {
                const logDiv = document.getElementById('logsContainer');
                logDiv.innerText = data;
                logDiv.scrollTop = logDiv.scrollHeight;
            })
            .catch(err => console.error('Log fetch error:', err));
    }

    // Initial log fetch and auto-refresh
    fetchLogs();
    setInterval(fetchLogs, 5000);
</script>
</body>
</html>