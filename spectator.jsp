<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Galaxy Dice Game - Spectator</title>
    <style>
        body {
            background: radial-gradient(ellipse at bottom, #1b2735 0%, #090a0f 100%);
            color: #ffffff;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            text-align: center;
            margin: 0;
            padding: 0;
        }

        h1 {
            margin: 20px 0;
            font-size: 2.5em;
            color: #FFD700;
            text-shadow: 0 0 10px #FFD700, 0 0 20px #ffdd33;
        }

        table {
            margin: auto;
            border-collapse: collapse;
            background: rgba(255, 255, 255, 0.05);
            box-shadow: 0 0 20px rgba(255, 255, 255, 0.2);
            border-radius: 10px;
            overflow: hidden;
        }

        th, td {
            padding: 12px 20px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }

        th {
            background: rgba(0, 0, 0, 0.5);
            color: #FFD700;
            font-size: 1.1em;
        }

        tr:hover {
            background: rgba(255, 255, 255, 0.1);
        }

        /* Star animation background effect */
       .stars {
        position: fixed;
        top: 0; left: 0;
        width: 100%; height: 100%;
        z-index: -1;
        background: radial-gradient(white 1px, transparent 1px),
                    radial-gradient(white 1px, transparent 1px);
        background-position: 0 0, 50px 50px;
        background-size: 100px 100px;
        animation: moveStars 200s linear infinite;
}


        @keyframes moveStars {
            from { background-position: 0 0; }
            to { background-position: -10000px 5000px; }
        }
    </style>
</head>
<body>
    <div class="stars"></div>
    <h1>Galaxy Dice Game - Spectator View</h1>

    <table>
        <thead>
            <tr>
                <th>Username</th>
                <th>Roll</th>
                <th>Timestamp</th>
            </tr>
        </thead>
        <tbody>
        <%
            Connection conn = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                String url = "jdbc:mysql://localhost:3306/GalaxyGame";
                String user = "root";
                String password = "bpsdoha";
                conn = DriverManager.getConnection(url, user, password);

                String sql = "SELECT r.username, r.roll, r.timestamp FROM rolls r";
                stmt = conn.prepareStatement(sql);
                rs = stmt.executeQuery();

                while (rs.next()) {
        %>
                    <tr>
                        <td><%= rs.getString("username") %></td>
                        <td><%= rs.getInt("roll") %></td>
                        <td><%= rs.getTimestamp("timestamp") %></td>
                    </tr>
        <%
                }
            } catch (Exception e) {
                out.println("<tr><td colspan='3'>Error: " + e.getMessage() + "</td></tr>");
            } finally {
                try { if (rs != null) rs.close(); } catch (Exception ignored) {}
                try { if (stmt != null) stmt.close(); } catch (Exception ignored) {}
                try { if (conn != null) conn.close(); } catch (Exception ignored) {}
            }
        %>
        </tbody>
    </table>
</body>
</html>
