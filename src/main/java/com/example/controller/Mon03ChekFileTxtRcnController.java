package com.example.controller;

import com.example.service.FtpTxtRcnService;
import com.example.utils.FTPConfig;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.OutputStream;
import java.util.*;
import java.util.logging.Logger;

@WebServlet("/mon3ChekFileTxt")
public class Mon03ChekFileTxtRcnController extends HttpServlet {

    private FtpTxtRcnService ftpService;
    private static final Logger logger = Logger.getLogger(Mon03ChekFileTxtRcnController.class.getName());

    @Override
    public void init() throws ServletException {
        super.init();
        ftpService = new FtpTxtRcnService(
                FTPConfig.getHost(),
                FTPConfig.getPort(),
                FTPConfig.getUsername(),
                FTPConfig.getPassword()
        );
        logger.info("[INIT] FtpTxtRcnService initialized");
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
        Gson gson = new Gson();

        try {
            if ("listtxt".equalsIgnoreCase(act) || "listrcn".equalsIgnoreCase(act)) {

                String thbl   = request.getParameter("thbl");
                String bank   = request.getParameter("bankmiv");
                String swBank = bank.substring(0,3) + "CA01";
                String jenis  = request.getParameter("jenis"); // wajib dikirim dari JS
                String idtrans= request.getParameter("idtrans");

                logger.info("[REQUEST] act=" + act + ", thbl=" + thbl + ", bank=" + bank +
                        ", swBank=" + swBank + ", jenis=" + jenis + ", idtrans=" + idtrans);

                Map<String, List<String>> hasilMap = ftpService.listFiles(bank, swBank, thbl, idtrans, jenis);

                List<String> listSukses = hasilMap.getOrDefault("SUKSES", new ArrayList<>());
                List<String> listGagal  = hasilMap.getOrDefault("GAGAL", new ArrayList<>());

                // filter IDTransaksi
                if(idtrans != null && !idtrans.trim().isEmpty() && !"*".equals(idtrans.trim())){
                    String pola = idtrans.trim().toLowerCase();
                    listSukses.removeIf(f -> !f.toLowerCase().contains(pola));
                    listGagal.removeIf(f  -> !f.toLowerCase().contains(pola));
                }

                Map<String, Object> result = new HashMap<>();
                result.put("listSukses", listSukses);
                result.put("listGagal", listGagal);

                response.getWriter().print(gson.toJson(result));

            } else if ("download".equalsIgnoreCase(act)) {

                String filePath = request.getParameter("file");
                if(filePath == null || filePath.trim().isEmpty()){
                    response.setContentType("application/json");
                    response.getWriter().print("{\"status\":\"error\",\"message\":\"File path tidak valid!\"}");
                    return;
                }

                // ambil nama file terakhir
                String fileName = filePath.substring(filePath.lastIndexOf("/") + 1);

                response.setContentType("application/octet-stream");
                response.setHeader("Content-Disposition","attachment; filename=\"" + fileName + "\"");

                OutputStream os = response.getOutputStream();
                boolean success = ftpService.downloadFile(filePath, os);
                os.flush();
                os.close();

                if(!success){
                    logger.warning("[DOWNLOAD] Gagal download file: " + filePath);
                }

            } else {
                response.getWriter().print("{\"error\":\"Invalid act parameter\"}");
            }

        } catch (Exception e){
            logger.severe("[ERROR] " + e.getMessage());
            response.getWriter().print("{\"status\":\"error\",\"message\":\""+e.getMessage()+"\"}");
        }
    }
}
