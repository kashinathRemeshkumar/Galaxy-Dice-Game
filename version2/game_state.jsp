<%@ page import="java.sql.*, DBManager.DBManager, java.util.*, org.json.JSONObject" %>
<%@ page contentType="application/json;charset=UTF-8" %>
<%
    DBManager db = new DBManager("localhost:3306", "root", "1234");
    Connection conn = db.connectToDatabase("GalaxyGame");

    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("SELECT username, position, turn FROM game_state");

    Map<String, Integer> positions = new HashMap<>();
    String currentTurn = null;

    while (rs.next()) {
        String user = rs.getString("username");
        int pos = rs.getInt("position");
        positions.put(user, pos);

        if (rs.getInt("turn") == 1) {
            currentTurn = user;
        }
    }

    rs.close();
    stmt.close();
    conn.close();

    JSONObject json = new JSONObject();
    json.put("positions", positions);
    json.put("currentTurn", currentTurn);

    out.print(json.toString());
%>
