package com.example.controller;

import com.example.service.FtpStrukService;
import com.example.utils.FTPConfig;
import com.google.gson.Gson;

import javax.annotation.Resource;
import javax.sql.DataSource;
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

    // PERBAIKAN: Mengambil dataSource (contoh menggunakan standard Java EE Resource Injection)
    // Jika Anda menggunakan Spring, gunakan @Autowired. Jika plain Servlet, sesuaikan cara fetch-nya.
    @Resource(name = "jdbc/YourDataSource") 
    private DataSource dataSource;

    @Override
    public void init() throws ServletException {
        // PERBAIKAN: Tambahkan parameter useTls dan dataSource agar sesuai dengan constructor baru
        // Asumsi di FTPConfig Anda memiliki method getUseTls() atau isUseTls() bernilai boolean
        boolean useTls = FTPConfig.getUseTls(); 

        ftpStrukService = new FtpStrukService(
                FTPConfig.getHost(),
                FTPConfig.getPort(),
                FTPConfig.getUsername(),
                FTPConfig.getPassword(),
                useTls,         // Ditambahkan
                dataSource      // Ditambahkan
        );
        logger.info("=== Mon02StrukBankController INIT OK (TLS Mode: " + useTls + ") ===");
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
                // Sekarang melempar Exception, otomatis ditangkap oleh catch (Exception e) di bawah
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

                // Menggunakan penanganan auto-close resource untuk OutputStream
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