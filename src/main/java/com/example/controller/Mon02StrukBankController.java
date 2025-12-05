package com.example.controller;

import com.example.service.FtpStrukService;
import com.example.utils.FTPConfig;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.util.*;
import java.util.logging.Logger;
import java.util.logging.Level;

@WebServlet("/mon2strukbank")
public class Mon02StrukBankController extends HttpServlet {

    private FtpStrukService ftpStrukService;
    private static final Logger logger = Logger.getLogger(Mon02StrukBankController.class.getName());
    private static final Gson gson = new Gson();

    @Override
    public void init() throws ServletException {
        ftpStrukService = new FtpStrukService(
                FTPConfig.getHost(),
                FTPConfig.getPort(),
                FTPConfig.getUsername(),
                FTPConfig.getPassword()
        );
        logger.info("=== Mon02StrukBankController INIT OK ===");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        process(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        process(req, resp);
    }

    private void process(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        try {
            String act = request.getParameter("act");

            String bank = request.getParameter("bankmiv");
            if (bank == null || bank.length() < 3) bank = "200";
            String swbank = bank.substring(0, 3) + "CA01";

            String up3 = request.getParameter("up3");
            String blth = request.getParameter("thbl");
            String idtrans = request.getParameter("idtransaksi");
            String file = request.getParameter("file");

            // =============================
            // LIST FILES
            // =============================
            if ("list".equalsIgnoreCase(act)) {
                List<String> listFiles = ftpStrukService.listStrukFiles(bank, swbank, up3, blth, idtrans);
                Map<String, Object> result = new HashMap<>();
                result.put("files", listFiles != null ? listFiles : Collections.emptyList());

                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().print(gson.toJson(result));
                return;
            }

            // =============================
            // DOWNLOAD ONLY FILE SELECTED
            // =============================
            if ("download".equalsIgnoreCase(act)) {

                if (file == null || file.trim().isEmpty()) {
                    sendJsonError(response, "Parameter file kosong");
                    return;
                }

                String filename = file.substring(file.lastIndexOf('/') + 1);

                response.setContentType("application/pdf");
                response.setHeader("Content-Disposition",
                        "attachment; filename=\"" + filename + "\"");

                try (OutputStream os = response.getOutputStream()) {
                    ftpStrukService.downloadFile(file, os);
                }

                return;
            }

            sendJsonError(response, "Action tidak dikenali: " + act);

        } catch (Exception e) {
            logger.log(Level.SEVERE, "ERROR CONTROLLER", e);
            sendJsonError(response, e.getMessage());
        }
    }

    private void sendJsonError(HttpServletResponse response, String msg) throws IOException {
        Map<String, String> error = new HashMap<>();
        error.put("status", "error");
        error.put("message", msg);

        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().print(gson.toJson(error));
    }
}
