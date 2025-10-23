package com.example.controller;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.http.*;

public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Hapus session jika ada
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        // Tambahkan header agar browser tidak men-cache halaman sebelumnya
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
        response.setHeader("Pragma", "no-cache"); // HTTP 1.0
        response.setDateHeader("Expires", 0); // Proxies

        // Redirect ke halaman login
        response.sendRedirect(request.getContextPath() + "/views/templates/login.jsp");
    }
}
