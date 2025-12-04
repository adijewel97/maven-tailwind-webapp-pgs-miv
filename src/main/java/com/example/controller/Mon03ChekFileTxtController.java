package com.example.controller;

import com.example.service.FtpTxtService;
import com.example.utils.FTPConfig;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;
import java.util.logging.Logger;

@WebServlet("/mon3ChekFileTxt")
public class Mon03ChekFileTxtController extends HttpServlet {

    private FtpTxtService ftpTxtService;
    private static final Logger logger = Logger.getLogger(Mon03ChekFileTxtController.class.getName());

    @Override
    public void init() throws ServletException {
        super.init();

        ftpTxtService = new FtpTxtService(
                FTPConfig.getHost(),
                FTPConfig.getPort(),
                FTPConfig.getUsername(),
                FTPConfig.getPassword()
        );

        logger.info("[INIT] FtpTxtService initialized for TXT checking");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String act = request.getParameter("act");

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        Gson gson = new Gson();

        logger.info("[REQUEST] act=" + act);

        if (!"listtxt".equalsIgnoreCase(act)) {
            out.print("{\"error\":\"Invalid act parameter\"}");
            return;
        }

        String thbl    = request.getParameter("thbl");
        String bank    = request.getParameter("bankmiv");
        String swbank  = request.getParameter("idtrans");

        logger.info("[PARAM] thbl=" + thbl + ", bank=" + bank + ", swbank=" + swbank);

        try {
            // ==================================================================
            // CALL SERVICE UNTUK BACA FILE TXT
            // ==================================================================
            List<String> hasil = ftpTxtService.listTxtFiles(bank, swbank, thbl);

            List<String> listSukses = new ArrayList<>();
            List<String> listGagal  = new ArrayList<>();

            for (String row : hasil) {
                if (row.startsWith("SUKSES")) listSukses.add(row);
                if (row.startsWith("GAGAL"))  listGagal.add(row);
            }

            logger.info("[RESULT] sukses=" + listSukses.size() +
                        ", gagal=" + listGagal.size());

            Map<String, Object> result = new HashMap<>();
            result.put("listSukses", listSukses);
            result.put("listGagal", listGagal);

            out.print(gson.toJson(result));

        } catch (Exception e) {

            logger.severe("[ERROR] " + e.getMessage());

            Map<String, String> err = new HashMap<>();
            err.put("status", "error");
            err.put("message", e.getMessage());

            out.print(gson.toJson(err));
        } finally {
            out.flush();
            out.close();
        }
    }
}
