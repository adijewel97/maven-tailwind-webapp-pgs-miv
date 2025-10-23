package com.example.controller;

import com.example.service.DbService;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import javax.sql.DataSource;
import java.io.IOException;
import java.security.MessageDigest;
import java.sql.*;
import java.util.Base64;

public class LoginServlet extends HttpServlet {

    private DataSource dataSource;

    @Override
    public void init() throws ServletException {
        try {
            // Ambil DataSource dari DbService (bukan JNDI)
            DbService dbService = new DbService();
            dataSource = dbService.getDataSource();
        } catch (Exception e) {
            throw new ServletException("Gagal inisialisasi koneksi database.", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try (Connection conn = dataSource.getConnection()) {

            // 1️⃣ Hash password ke MD5 + Base64 (tanpa "=")
            String hashedPassword = md5ToBase64(password);

            // 2️⃣ Query user
            String sql = "SELECT user_name, group_id, password FROM eis.user_id WHERE user_name = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, username);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        String dbPassword = rs.getString("password");
                        String groupId = rs.getString("group_id");

                        // 3️⃣ Validasi login
                        if (hashedPassword.equals(dbPassword) && "RKN".equalsIgnoreCase(groupId)) {
                            HttpSession session = request.getSession();
                            session.setAttribute("username", username);
                            session.setAttribute("userRole", groupId);
                            response.sendRedirect(request.getContextPath() + "/index.jsp");
                        } else {
                            response.sendRedirect(request.getContextPath() + "/views/templates/login.jsp?error=invalid");
                        }

                    } else {
                        response.sendRedirect(request.getContextPath() + "/views/templates/login.jsp?error=notfound");
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/views/templates/login.jsp?error=server");
        }
    }

    // 🔐 Konversi password ke MD5 lalu Base64 (tanpa tanda '=' di akhir)
    private String md5ToBase64(String input) throws Exception {
        MessageDigest md = MessageDigest.getInstance("MD5");
        byte[] md5Bytes = md.digest(input.getBytes("UTF-8"));
        String base64 = Base64.getEncoder().encodeToString(md5Bytes);
        return base64.replace("=", ""); // Samakan dengan Oracle RTRIM '='
    }
}
