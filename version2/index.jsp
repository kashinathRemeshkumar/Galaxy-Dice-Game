<%@ page import="DBManager.DBManager, java.sql.*" %>
<%
    boolean loginFailed = false;
    boolean doLogin = "POST".equalsIgnoreCase(request.getMethod());
    String username = request.getParameter("user");
    String password = request.getParameter("pass");

    if (doLogin && username != null && password != null) {
        Connection conn = null;
        try {
            DBManager db = new DBManager("localhost:3306", "root", "1234");
            conn = db.connectToDatabase("GalaxyGame");

            // Check if user exists
            PreparedStatement checkStmt = conn.prepareStatement("SELECT * FROM users WHERE username=?");
            checkStmt.setString(1, username);
            ResultSet rs = checkStmt.executeQuery();

            boolean userExists = rs.next();
            rs.close();
            checkStmt.close();

            // Auto-register if not exists
            if (!userExists) {
                PreparedStatement insertStmt = conn.prepareStatement("INSERT INTO users (username, password, score, isadmin, isOnline) VALUES (?, ?, 0, 0, 1)");
                insertStmt.setString(1, username);
                insertStmt.setString(2, password);
                insertStmt.executeUpdate();
                insertStmt.close();
            }

            // Validate credentials
            PreparedStatement loginStmt = conn.prepareStatement("SELECT isadmin FROM users WHERE username=? AND password=?");
            loginStmt.setString(1, username);
            loginStmt.setString(2, password);
            ResultSet loginRs = loginStmt.executeQuery();

            if (loginRs.next()) {
                int isAdmin = loginRs.getInt("isadmin");
                loginRs.close();

                // ✅ Set ONLY current user online
                PreparedStatement setOnline = conn.prepareStatement("UPDATE users SET isOnline=1 WHERE username=?");
                setOnline.setString(1, username);
                setOnline.executeUpdate();
                setOnline.close();

                conn.close();

                if (isAdmin == 1) {
                    response.sendRedirect("Admin_Panel.jsp?user=" + username);
                } else {
                    response.sendRedirect("main_game.jsp?user=" + username);
                }
                return;
            } else {
                loginFailed = true;
            }
        } catch (Exception e) {
            loginFailed = true;
        } finally {
            if (conn != null) conn.close();
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Galaxy Dice - Login</title>
    <style>
        body {
            background-color: #0d1117;
            font-family: Arial, sans-serif;
            color: #c9d1d9;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }

        .login-box {
            background-color: #161b22;
            border: 1px solid #30363d;
            border-radius: 10px;
            padding: 30px 40px;
            box-shadow: 0 0 20px rgba(255, 255, 255, 0.05);
            width: 350px;
            text-align: center;
        }

        .login-box h2 {
            color: #58a6ff;
            margin-bottom: 25px;
        }

        .login-box input[type="text"],
        .login-box input[type="password"] {
            width: 100%;
            padding: 12px;
            margin: 10px 0;
            border: none;
            border-radius: 6px;
            background-color: #21262d;
            color: #c9d1d9;
        }

        .login-box input[type="submit"] {
            width: 100%;
            padding: 12px;
            border: none;
            border-radius: 6px;
            background-color: #238636;
            color: white;
            font-size: 16px;
            cursor: pointer;
            margin-top: 10px;
        }

        .login-box input[type="submit"]:hover {
            background-color: #2ea043;
        }

        .error {
            color: #ff6b6b;
            margin-bottom: 10px;
        }

        .admin-link {
            margin-top: 15px;
            display: block;
            font-size: 14px;
            color: #58a6ff;
            text-decoration: none;
        }

        .admin-link:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
<div class="login-box">
    <h2>Login to Galaxy Dice</h2>

    <% if (loginFailed) { %>
        <div class="error">❌ Invalid username or password</div>
    <% } %>

    <form method="post">
        <input type="text" name="user" placeholder="Username" required>
        <input type="password" name="pass" placeholder="Password" required>
        <input type="submit" value="Login">
    </form>

    <a class="admin-link" href="index.jsp">Admin Login</a>
</div>
</body>
</html>
