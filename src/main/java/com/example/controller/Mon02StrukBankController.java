package com.example.controller;

import com.example.utils.FTPUtil;
import com.example.utils.LoggerUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@WebServlet("/mon2strukbank")
public class Mon02StrukBankController extends HttpServlet {

    private static final Logger logger = LoggerUtil.getLogger(Mon02StrukBankController.class);

    private final FTPUtil ftpUtil =
            new FTPUtil("10.71.1.177", 21, "rekon", "rekon");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String act = request.getParameter("act");

        if (act == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Missing parameter 'act'");
            return;
        }

        switch (act) {

            // ===========================================================
            // =========== 1. LIST FILE FROM FTP ==========================
            // ===========================================================
            case "list":
                handleList(request, response);
                break;

            // ===========================================================
            // =========== 2. DOWNLOAD FILE FROM FTP ======================
            // ===========================================================
            case "download":
                handleDownload(request, response);
                break;

            default:
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Invalid act parameter");
        }
    }

    // ===============================================================
    //  LIST FILE FTP (NTLS, POSTPAID, PREPAID)
    // ===============================================================
    private void handleList(HttpServletRequest request, HttpServletResponse response)
        throws IOException {

        String bankmiv = request.getParameter("bankmiv");   // contoh: 2000001
        String thbl    = request.getParameter("thbl");      // contoh: 202511
        String upi     = request.getParameter("upi");       // contoh: 14
        String up3     = request.getParameter("up3");       // contoh: 14BKL

        String kdbankmiv = bankmiv.substring(0, 3) + "CA01";   // contoh: 200CA01

        logger.info("=== FILTER PARAM ===");
        logger.info("THBL       = " + thbl);
        logger.info("BANK_MIV   = " + bankmiv);
        logger.info("UPI        = " + upi);
        logger.info("UP3        = " + up3);
        logger.info("KDBANKMIV  = " + kdbankmiv);

        // Folder array
        String[] produkArray = {"NTLS", "POSTPAID", "PREPAID"};

        List<String> allFiles = new ArrayList<>();

        for (String produk : produkArray) {

            String remoteDir = "/vertikal/" + bankmiv + "/" + kdbankmiv + "/" + produk + "/lunas/struk/";
            logger.info("📂 Scan folder FTP: " + remoteDir);

            List<String> files = ftpUtil.listAllFiles(remoteDir);

            if (files == null) continue;

            // ========== FILTER FILE ================
            for (String f : files) {

                // filter (versi contains)
                boolean match =
                    f.contains("POS" + up3 + thbl) &&
                    f.contains(kdbankmiv + ".pdf");

                if (match) {
                    allFiles.add(f);
                }
            }
        }

        // --- Convert List<String> to JSON ---
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < allFiles.size(); i++) {
            json.append("\"").append(allFiles.get(i)).append("\"");
            if (i < allFiles.size() - 1) json.append(",");
        }
        json.append("]");

        response.setContentType("application/json");
        response.getWriter().write(json.toString());
    }

    // ===============================================================
    //  DOWNLOAD FILE FTP
    // ===============================================================
    private void handleDownload(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String filePath = request.getParameter("file");

        if (filePath == null || filePath.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Parameter 'file' kosong");
            return;
        }

        String fileName = filePath.substring(filePath.lastIndexOf('/') + 1);

        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition",
                "attachment; filename=\"" + fileName + "\"");

        OutputStream os = response.getOutputStream();

        boolean ok = ftpUtil.downloadFile(filePath, os);

        if (!ok) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.getWriter().write("File tidak ditemukan di FTP!");
        }

        os.flush();
    }
}
