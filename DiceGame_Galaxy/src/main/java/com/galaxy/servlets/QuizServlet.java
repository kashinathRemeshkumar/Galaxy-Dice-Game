package com.galaxy.servlets;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/quiz")
public class QuizServlet extends HttpServlet {
    private Map<Integer,String> answers = new HashMap<>();
    public QuizServlet() {
        answers.put(1, "Mercury");
        answers.put(2, "Jupiter");
        // add more quiz Q&A
    }

    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int cell = Integer.parseInt(req.getParameter("cell"));
        req.setAttribute("cell", cell);
        req.setAttribute("question", "Which planet is closest to the Sun?");
        req.getRequestDispatcher("/quiz.html").forward(req, resp);
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String answer = req.getParameter("answer");
        HttpSession session = req.getSession();
        Integer pos = (Integer) session.getAttribute("position");
        if ("Mercury".equalsIgnoreCase(answer)) {
            int bonus = 3 + new Random().nextInt(3); // 3–5
            pos += bonus;
            session.setAttribute("position", pos);
            session.setAttribute("bonus", bonus);
        }
        resp.sendRedirect("game");
    }
}