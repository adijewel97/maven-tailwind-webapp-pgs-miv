package com.example.controller;

import com.example.utils.FTPConfig;
import com.example.utils.FTPUtil;
import com.example.utils.LoggerUtil;
import com.google.gson.Gson;

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

@WebServlet("/mon3ChekfileTxt")
public class Mon03ChekFileTxtController extends HttpServlet {

    private static final Logger logger = LoggerUtil.getLogger(Mon03ChekFileTxtController.class);

    // private final FTPUtil ftpUtil =
    //         new FTPUtil("10.71.1.177", 21, "rekon", "rekon");
    private final FTPUtil ftpUtil =
        new FTPUtil(
            FTPConfig.getHost(),
            FTPConfig.getPort(),
            FTPConfig.getUsername(),
            FTPConfig.getPassword()
        );

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
            case "listtxt":
                handleListTxt(request, response);
                break;
            
            case "listrcn":
                handleListRcn(request, response);
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
    //  LIST FILE TXT FTP (NTLS, POSTPAID, PREPAID)
    // ===============================================================
    private void handleListTxt(HttpServletRequest request, HttpServletResponse response)
        throws IOException {

        String bankmiv = request.getParameter("bankmiv");
        String thbl    = request.getParameter("thbl");     // contoh: 202502
        String idtrans = request.getParameter("idtrans");  // contoh: POS53DPK20250212003

        logger.info("=== [handleListTxt] PARAM REQUEST ===");
        logger.info("bankmiv = " + bankmiv);
        logger.info("thbl    = " + thbl);
        logger.info("idtrans = " + idtrans);
        logger.info("===================================");

        if (bankmiv == null || bankmiv.length() < 3) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"bankmiv tidak valid\"}");
            return;
        }

        if (thbl == null || thbl.length() != 6) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"thbl harus 6 digit (YYYYMM)\"}");
            return;
        }

        String kdbankmiv = bankmiv.substring(0, 3) + "CA01";
        String[] produkArray = {"NTLS", "POSTPAID", "PREPAID"};
        List<String> allFiles = new ArrayList<>();

        for (String produk : produkArray) {

            String remoteDir = "/vertikal/" + bankmiv + "/" + kdbankmiv + "/" + produk + "/daftar/";
            logger.info("📂 Scan FTP Folder: " + remoteDir);

            List<String> files = ftpUtil.listAllFiles(remoteDir);
            if (files == null) continue;

            for (String fullpath : files) {

                String filename = fullpath.substring(fullpath.lastIndexOf("/") + 1).toUpperCase();
                // boolean match = false;

                logger.info("-------------------------------------------");
                logger.info("🔍 Periksa file: " + fullpath);
                logger.info("   PRODUK : " + produk);
                logger.info("   BLTH   : " + thbl);
                logger.info("   IDTRANS: " + idtrans);

                // Jika IDTRANS kosong → hanya filter BLTH
                if (idtrans == null || idtrans.trim().equals("") || idtrans.equals("*")) {
                    if (filename.contains(thbl)) {
                        logger.info("✓ BLTH cocok tanpa IDTRANS → ADD");
                        allFiles.add(fullpath);
                    } else {
                        logger.info("✗ BLTH tidak cocok → SKIP");
                    }
                    continue;
                }

                // Normalisasi IDTRANS
                String id = idtrans.trim().toUpperCase();

                // 1) Jika filename mengandung IDTRANS → OK
                if (filename.contains(id)) {
                    logger.info("✓ MATCH by IDTRANS → ADD");
                    allFiles.add(fullpath);
                    continue;
                }

                // 2) Cari pola BLTH
                // contoh file: POS53DPK20250212003-20250224-200CA01.TXT
                // kita ambil BLTH dari IDTRANS = 202502 (sudah dikirim requester)

                if (filename.contains(thbl)) {
                    logger.info("✓ MATCH by BLTH → ADD");
                    allFiles.add(fullpath);
                    continue;
                }

                logger.info("✗ Tidak cocok filter apapun → SKIP");
            }
        }

        logger.info("=== TOTAL FILE LOLOS FILTER: " + allFiles.size() + " ===");

        String json = new Gson().toJson(allFiles);
        response.setContentType("application/json");
        response.getWriter().write(json);
    }

    // ===============================================================
    //  LIST FILE RCN FTP (NTLS, POSTPAID, PREPAID)
    // ===============================================================
    private void handleListRcn(HttpServletRequest request, HttpServletResponse response)
        throws IOException {

        String bankmiv = request.getParameter("bankmiv");
        String thbl    = request.getParameter("thbl");     // contoh: 202502
        String idtrans = request.getParameter("idtrans");  // contoh: POS53DPK20250212003

        logger.info("=== [handleListTxt] PARAM REQUEST ===");
        logger.info("bankmiv = " + bankmiv);
        logger.info("thbl    = " + thbl);
        logger.info("idtrans = " + idtrans);
        logger.info("===================================");

        if (bankmiv == null || bankmiv.length() < 3) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"bankmiv tidak valid\"}");
            return;
        }

        if (thbl == null || thbl.length() != 6) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"thbl harus 6 digit (YYYYMM)\"}");
            return;
        }

        String kdbankmiv = bankmiv.substring(0, 3) + "CA01";
        String[] produkArray = {"NTLS", "POSTPAID", "PREPAID"};
        List<String> allFiles = new ArrayList<>();

        for (String produk : produkArray) {

            String remoteDir = "/vertikal/" + bankmiv + "/" + kdbankmiv + "/" + produk + "/lunas/";
            logger.info("📂 Scan FTP Folder: " + remoteDir);

            List<String> files = ftpUtil.listAllFiles(remoteDir);
            if (files == null) continue;

            for (String fullpath : files) {

                String filename = fullpath.substring(fullpath.lastIndexOf("/") + 1).toUpperCase();
                // boolean match = false;

                logger.info("-------------------------------------------");
                logger.info("🔍 Periksa file: " + fullpath);
                logger.info("   PRODUK : " + produk);
                logger.info("   BLTH   : " + thbl);
                logger.info("   IDTRANS: " + idtrans);

                // Jika IDTRANS kosong → hanya filter BLTH
                if (idtrans == null || idtrans.trim().equals("") || idtrans.equals("*")) {
                    if (filename.contains(thbl)) {
                        logger.info("✓ BLTH cocok tanpa IDTRANS → ADD");
                        allFiles.add(fullpath);
                    } else {
                        logger.info("✗ BLTH tidak cocok → SKIP");
                    }
                    continue;
                }

                // Normalisasi IDTRANS
                String id = idtrans.trim().toUpperCase();

                // 1) Jika filename mengandung IDTRANS → OK
                if (filename.contains(id)) {
                    logger.info("✓ MATCH by IDTRANS → ADD");
                    allFiles.add(fullpath);
                    continue;
                }

                // 2) Cari pola BLTH
                // contoh file: POS53DPK20250212003-20250224-200CA01.TXT
                // kita ambil BLTH dari IDTRANS = 202502 (sudah dikirim requester)

                if (filename.contains(thbl)) {
                    logger.info("✓ MATCH by BLTH → ADD");
                    allFiles.add(fullpath);
                    continue;
                }

                logger.info("✗ Tidak cocok filter apapun → SKIP");
            }
        }

        logger.info("=== TOTAL FILE LOLOS FILTER: " + allFiles.size() + " ===");

        String json = new Gson().toJson(allFiles);
        response.setContentType("application/json");
        response.getWriter().write(json);
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
