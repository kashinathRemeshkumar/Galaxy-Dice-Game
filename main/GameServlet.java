package com.galaxy.servlets;

import java.io.IOException;
import java.util.Random;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/game")
public class GameServlet extends HttpServlet {
    private static final int GOAL = 100;
    private Random rand = new Random();

    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(true);
        Integer pos = (Integer) session.getAttribute("position");
        Integer score = (Integer) session.getAttribute("score");
        if (pos == null) { pos = 0; score = 0; }

        int roll = rand.nextInt(6) + 1;
        pos += roll;
        score += roll;

        String event = null;
        int eventRoll = rand.nextInt(100);
        if (eventRoll < 5) {
            pos += 10;
            event = "🚀 Wormhole! Jumped ahead 10 units!";
        } else if (eventRoll < 20) {
            score -= 2;
            event = "☄️ Asteroid belt! Lost 2 score.";
        } else if (eventRoll < 25) {
            pos -= 20;
            event = "🕳️ Black hole! Pulled back 20 units!";
        }

        session.setAttribute("position", pos);
        session.setAttribute("score", score);
        session.setAttribute("roll", roll);
        session.setAttribute("event", event);

        // Redirect to quiz if on a quiz cell
        if (pos % 10 == 0 && pos != 0) {
            resp.sendRedirect("quiz?cell=" + pos);
        } else if (pos >= GOAL) {
            resp.getWriter().println("<h1>You reached Planet Zeta! 🎉</h1>");
        } else {
            req.getRequestDispatcher("/index.html").forward(req, resp);
        }
    }
}
