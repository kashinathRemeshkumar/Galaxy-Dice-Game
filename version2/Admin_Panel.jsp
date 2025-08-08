<%@ page import="DBManager.DBManager, java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Galaxy Dice Admin Panel</title>
    <style>
        body {
            background-color: #0d1117;
            color: #c9d1d9;
            font-family: Arial, sans-serif;
        }
        h1 {
            color: #58a6ff;
            text-align: center;
        }
        table {
            margin: 30px auto;
            width: 90%;
            border-collapse: collapse;
            background-color: #161b22;
            border: 1px solid #30363d;
        }
        th, td {
            padding: 10px;
            border-bottom: 1px solid #30363d;
            text-align: center;
        }
        tr:hover {
            background-color: #21262d;
        }
        .actions button {
            margin: 2px;
            padding: 5px 10px;
            border: none;
            border-radius: 5px;
            color: white;
            cursor: pointer;
        }
        .promote { background-color: #238636; }
        .demote { background-color: #d73a49; }
        .delete { background-color: #f85149; }
        .pagination {
            text-align: center;
            margin: 20px;
        }
        .pagination a {
            color: #58a6ff;
            text-decoration: none;
            margin: 0 5px;
        }
    </style>
</head>
<body>

<h1>🌌 Galaxy Dice Admin Panel</h1>

<%
    String username = request.getParameter("user");
    if (username == null || username.trim().isEmpty()) {
        response.sendRedirect("index.jsp");
        return;
    }

    DBManager db = new DBManager("localhost:3306", "root", "1234");
    Connection conn = db.connectToDatabase("GalaxyGame");

    // ✅ Handle admin actions
    String action = request.getParameter("action");
    String target = request.getParameter("target");
    if (action != null && target != null) {
        try {
            PreparedStatement stmt = null;
            if ("promote".equals(action)) {
                stmt = conn.prepareStatement("UPDATE users SET isadmin=1 WHERE username=?");
            } else if ("demote".equals(action)) {
                stmt = conn.prepareStatement("UPDATE users SET isadmin=0 WHERE username=?");
            } else if ("delete".equals(action)) {
                stmt = conn.prepareStatement("DELETE FROM users WHERE username=?");
            }
            if (stmt != null) {
                stmt.setString(1, target);
                stmt.executeUpdate();
                stmt.close();
            }
        } catch (Exception e) {
            out.println("<p style='color:red;text-align:center;'>Error: " + e.getMessage() + "</p>");
        }
    }

    // ✅ Pagination setup
    int usersPerPage = 10;
    int pageNum = 1;
    try {
        String pageParam = request.getParameter("page");
        if (pageParam != null) pageNum = Integer.parseInt(pageParam);
    } catch (Exception ignored) {}

    int offset = (pageNum - 1) * usersPerPage;

    // ✅ Fetch paginated users
    PreparedStatement countStmt = conn.prepareStatement("SELECT COUNT(*) FROM users");
    ResultSet countRS = countStmt.executeQuery();
    countRS.next();
    int totalUsers = countRS.getInt(1);
    countRS.close();
    countStmt.close();

    int totalPages = (int) Math.ceil(totalUsers / (double) usersPerPage);

    PreparedStatement userStmt = conn.prepareStatement("SELECT * FROM users ORDER BY id LIMIT ? OFFSET ?");
    userStmt.setInt(1, usersPerPage);
    userStmt.setInt(2, offset);
    ResultSet rs = userStmt.executeQuery();
%>

<table>
    <thead>
    <tr>
        <th>ID</th>
        <th>Username</th>
        <th>Password</th>
        <th>Score</th>
        <th>Admin?</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <%
        while (rs.next()) {
            String user = rs.getString("username");
            int isadmin = rs.getInt("isadmin");
    %>
    <tr>
        <td><%= rs.getInt("id") %></td>
        <td><%= user %></td>
        <td><%= rs.getString("password") %></td>
        <td><%= rs.getInt("score") %></td>
        <td><%= isadmin == 1 ? "✅" : "❌" %></td>
        <td class="actions">
            <% if (isadmin == 0) { %>
                <form method="post" style="display:inline;">
                    <input type="hidden" name="user" value="<%= username %>"/>
                    <input type="hidden" name="target" value="<%= user %>"/>
                    <button name="action" value="promote" class="promote">Promote</button>
                </form>
            <% } else { %>
                <form method="post" style="display:inline;">
                    <input type="hidden" name="user" value="<%= username %>"/>
                    <input type="hidden" name="target" value="<%= user %>"/>
                    <button name="action" value="demote" class="demote">Demote</button>
                </form>
            <% } %>
            <form method="post" style="display:inline;">
                <input type="hidden" name="user" value="<%= username %>"/>
                <input type="hidden" name="target" value="<%= user %>"/>
                <button name="action" value="delete" class="delete">Delete</button>
            </form>
        </td>
    </tr>
    <% } %>
    </tbody>
</table>

<!-- Pagination Links -->
<div class="pagination">
    <% for (int i = 1; i <= totalPages; i++) { %>
        <a href="Admin_Panel.jsp?user=<%= username %>&page=<%= i %>"><%= i %></a>
    <% } %>
</div>

<%
    rs.close();
    userStmt.close();
    conn.close();
%>

</body>
</html>
