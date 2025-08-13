<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String user = request.getParameter("user");
%>
<!DOCTYPE html>
<html>
<head>
    <title>You Won!</title>
    <style>
        body {
            background: linear-gradient(to right, #001f3f, #000);
            color: #00ff00;
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
    <h1>🏆 Congratulations <%= user %>! You reached Planet Zeta!</h1>
    <p>You have won the Galaxy Dice Game!</p>
    <br>
    <a href="index.jsp">Start New Game</a>
</body>
</html>
