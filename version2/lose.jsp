<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String user = request.getParameter("user");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Game Over</title>
    <style>
        body {
            background: linear-gradient(to right, #1a1a1a, #000);
            color: #ff4d4d;
            font-family: Arial;
            text-align: center;
            padding-top: 100px;
        }
        a {
            color: #58a6ff;
            text-decoration: none;
            font-size: 18px;
            background: #111;
            padding: 10px 20px;
            border: 1px solid #58a6ff;
            border-radius: 5px;
        }
        a:hover {
            background: #222;
        }
    </style>
</head>
<body>
    <h1>💥 Sorry <%= user %>, You Lost!</h1>
    <p>Another player reached Planet Zeta first.</p>
    <br>
    <a href="index.jsp">Start New Game</a>
</body>
</html>
