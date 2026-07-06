package com.example.controller;

import com.example.service.DbService;
import com.example.service.MonRekonPerUpiService;
import com.example.utils.HttpStatusHelper;
import com.example.utils.LoggerUtil;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "MonRekonPerUpiController", urlPatterns = {"/mon-rekon-bankvsperupi"})
public class Mon01RekonPerUpiController extends HttpServlet {
    private MonRekonPerUpiService service;
    private static final Logger logger = LoggerUtil.getLogger(Mon01RekonPerUpiController.class);
    private final Gson gson = new Gson();

    // private static final String ACT_JENIS_LAPORAN = "handleGetJenisLaporan";
    // private static final String ACT_SUMBER_DATA = "handleGetsumberdata";

    @Override
    //1 inisilisasi konkesi DB
    public void init() throws ServletException {
        super.init();
        try {
            DbService dbService = new DbService();
            service = new MonRekonPerUpiService(dbService.getDataSource());
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Gagal inisialisasi koneksi DB di init()", e);
            throw new ServletException("Gagal inisialisasi koneksi DB", e);
        }
    }

    @Override
    //2 Main Utama Pemangilaan POST Service
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String act = req.getParameter("act");

        if ("detailData".equalsIgnoreCase(act)) {
            handleGetDetailData(req, resp);
            return;
        }

        if ("getNamaBank".equalsIgnoreCase(act)) {
            handleGetNamaBank(req, resp);
            return;
        }

        if ("getNamaUnitUPI".equalsIgnoreCase(act)) {
            handleGetNamaUnitUPI(req, resp);
            return;
        }

        // Default
        prosesMonRekapPerUpi(req, resp);
    }

    // 3 Panggil Service Monitoring Rekap Per-UPI PLN VS BANK 
    private void prosesMonRekapPerUpi(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String vbln_usulan = req.getParameter("vbln_usulan");
        int vkode = 200; // Default sukses
        
        // 1. Antisipasi error jika parameter 'draw' kosong atau bukan angka
        int draw = 1;
        String drawParam = req.getParameter("draw");
        if (drawParam != null && !drawParam.trim().isEmpty()) {
            try {
                draw = Integer.parseInt(drawParam);
            } catch (NumberFormatException e) {
                logger.warning("Format parameter 'draw' tidak valid, di-set ke default 1");
            }
        }

        List<Map<String, Object>> data = Collections.emptyList();
        int totalCount = 0;

        List<String> pesanMsg = new ArrayList<>();
        List<Boolean> statusMsg = new ArrayList<>();

        try {
            // Panggil service rekap
            data = service.getDataMonRkpPerPerUpi(vbln_usulan, pesanMsg, statusMsg);

            // Ambil status keberhasilan dari service
            boolean isSuccess = !statusMsg.isEmpty() && statusMsg.get(0);
            String pesanRaw = pesanMsg.isEmpty() ? "" : pesanMsg.get(0).toLowerCase();

            if (!isSuccess) {
                data = new ArrayList<>(); // Pastikan data kosong jika gagal
                
                 // 🟢 STANDARISASI BARU: Split berdasarkan tanda "|"
                if (pesanRaw.contains("|")) {
                    String[] parts = pesanRaw.split("\\|", 2);
                    try {
                        vkode     = Integer.parseInt(parts[0]); // Mengambil angka 503 atau 400 langsung dari Service
                        pesanMsg.set(0, parts[1]);  // Bersihkan string pesanMsg agar bersih tanpa angka kode lagi
                    } catch ( NumberFormatException e){
                        vkode = 400; // Database/server tidak aktif
                    }
                } else {
                    vkode = 400; // Parameter request salah / Bad Request
                }
            } else {
                totalCount = (data != null) ? data.size() : 0;
                vkode = 200;
            }            
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error: Gagal mendapatkan data Rekap UPI: " + e.getMessage(), e);
            vkode = 500; 
            data = new ArrayList<>();
        }

         // Ambil detail status berdasarkan code dari HttpStatusHelper
        HttpStatusHelper.StatusInfo statusInfo = HttpStatusHelper.getInfo(vkode);

        // Format JSON dengan label yang diminta
        Map<String, Object> jsonResponse = new HashMap<>();
        jsonResponse.put("draw", draw);
        jsonResponse.put("recordsTotal", totalCount);
        jsonResponse.put("recordsFiltered", totalCount);
        jsonResponse.put("data", data); // Sekarang aman diakses di sini
        
        // Inject label baru ke object JSON sesuai standarisasi util
        jsonResponse.put("code", vkode);
        jsonResponse.put("code_Status", statusInfo.getCodeStatus());        
        // Sekarang pesanMsg sudah bisa diakses dengan aman di sini
        String finalMessage = (vkode != 200 && !pesanMsg.isEmpty()) ? pesanMsg.get(0) : statusInfo.getCodeMessage();
        jsonResponse.put("code_message", finalMessage); 

        // 🔴 BERSIHKAN DUPLIKAT: Cukup panggil PrintWriter satu kali saja di akhir proses
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try (PrintWriter out = resp.getWriter()) {
            out.print(gson.toJson(jsonResponse));
        }
    }

    //4 Panggile Service Monitoring Detail Per-UPI PLN VS BANK
    private void handleGetDetailData(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        // Inisilisasi Paramater Input
        int draw = 1;
        try {
            draw = Integer.parseInt(req.getParameter("draw"));
        } catch (NumberFormatException e) {
            logger.info("Parameter 'draw' tidak ditemukan atau tidak valid. Default: 1");
        }
        int startIndex = Integer.parseInt(req.getParameter("start")); // 0, 10, ...
        int length = Integer.parseInt(req.getParameter("length"));
        int start = (startIndex / length) + 1;
        String sortColumnIndex = req.getParameter("order[0][column]");
        String sortDir = req.getParameter("order[0][dir]");
        String searchValue = req.getParameter("search[value]");
        String sortBy = req.getParameter("columns[" + sortColumnIndex + "][data]");
        if (sortBy == null || sortBy.trim().isEmpty()) {
            sortBy = "KD_DIST";
            sortDir = "ASC";
        }
        String vbln_usulan = req.getParameter("vbln_usulan");
        String vkd_bank = req.getParameter("vkd_bank");
        String vkd_dist = req.getParameter("vkd_dist");
        
        int vkode = 200; // Default sukses
        int totalCount = 0;
        List<String> pesanMsg = new ArrayList<>();
        List<Boolean> statusMsg = new ArrayList<>();

        // chek parameter input
        logger.info("draw = " + draw);
        logger.info("offset (startIndex) = " + startIndex);
        logger.info("limit (length) = " + length);
        logger.info("sortBy = " + sortBy + " " + sortDir);
        logger.info("searchValue = " + searchValue);
        logger.info("vbln_usulan = " + vbln_usulan);
        logger.info("vkd_bank = " + vkd_bank);
        logger.info("vkd_dist = " + vkd_dist);

        // 🟢 DEKLARASI DI LUAR TRY AGAR BISA DIAKSES DI CATCH & KODE DI BAWAHNYA
        List<Map<String, Object>> data = new ArrayList<>(); 

        try {
            // Isi variabel data tanpa menuliskan tipe datanya lagi
            data = service.getDataMonDftPerUpi(
                start, length, sortBy, sortDir, searchValue, vbln_usulan, vkd_bank, vkd_dist, pesanMsg, statusMsg
            );
        
            // Ambil status keberhasilan dari service
            boolean isSuccess = !statusMsg.isEmpty() && statusMsg.get(0);
            String pesanRaw   = pesanMsg.isEmpty() ? "" : pesanMsg.get(0);

            if (!isSuccess) {
                // JIKA SERVICE GAGAL, DETEKSI JENIS ERROR DARI ISI PESANNYA
                data = new ArrayList<>(); // Kosongkan data
                
                // 🟢 STANDARISASI BARU: Split berdasarkan tanda "|"
                if (pesanRaw.contains("|")) {
                    String[] parts = pesanRaw.split("\\|", 2);
                    try {
                        vkode     = Integer.parseInt(parts[0]); // Mengambil angka 503 atau 400 langsung dari Service
                        pesanMsg.set(0, parts[1]);  // Bersihkan string pesanMsg agar bersih tanpa angka kode lagi
                    } catch ( NumberFormatException e){
                        vkode = 400; // Database/server tidak aktif
                    }
                } else {
                    vkode = 400; // Parameter request salah / Bad Request
                }
            } else {
                // JIKA BERHASIL
                totalCount = data.size();
                vkode = 200;
            }            
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error: Gagal mendapatkan data: " + e.getMessage(), e);
            vkode = 500; // Internal Server Error untuk error java/program lainnya
            data = new ArrayList<>(); // Sekarang baris ini tidak akan error lagi
        }

         // Ambil detail status berdasarkan code dari HttpStatusHelper
        HttpStatusHelper.StatusInfo statusInfo = HttpStatusHelper.getInfo(vkode);

        // Format JSON dengan label yang diminta
        Map<String, Object> jsonResponse = new HashMap<>();
        jsonResponse.put("draw", draw);
        jsonResponse.put("recordsTotal", totalCount);
        jsonResponse.put("recordsFiltered", totalCount);
        jsonResponse.put("data", data); // Sekarang aman diakses di sini
        
        // Inject label baru ke object JSON sesuai standarisasi util
        jsonResponse.put("code", vkode);
        jsonResponse.put("code_Status", statusInfo.getCodeStatus());        
        // Sekarang pesanMsg sudah bisa diakses dengan aman di sini
        String finalMessage = (vkode != 200 && !pesanMsg.isEmpty()) ? pesanMsg.get(0) : statusInfo.getCodeMessage();
        jsonResponse.put("code_message", finalMessage); 

        // 🔴 BERSIHKAN DUPLIKAT: Cukup panggil PrintWriter satu kali saja di akhir proses
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try (PrintWriter out = resp.getWriter()) {
            out.print(gson.toJson(jsonResponse));
        }
    }

    //5 Ambil Refrensi master Bank
    private void handleGetNamaBank(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String kdbank = req.getParameter("kdbank");
        Map<String, Object> result = new HashMap<>();

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try (PrintWriter out = resp.getWriter()) {
            Map<String, Object> UnitUPIData = service.getDataBank(kdbank); // Panggil ke service
            result.put("status", "success");
            result.put("data", UnitUPIData);
            out.print(gson.toJson(result));
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Gagal ambil nama bank", e);
            result.put("status", "error");
            result.put("message", "Gagal mengambil data bank");
            try (PrintWriter out = resp.getWriter()) {
                out.print(gson.toJson(result));
            }
        }
    }

    //6 Ambil Refrensi master UPI WILAYAH/DISTRIBUSI
    private void handleGetNamaUnitUPI(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String kd_dist = req.getParameter("kd_dist");
        Map<String, Object> result = new HashMap<>();

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try (PrintWriter out = resp.getWriter()) {
            Map<String, Object> UnitUPIData = service.getDataUnitUPI(kd_dist); // Panggil ke service
            result.put("status", "success");
            result.put("data", UnitUPIData);
            out.print(gson.toJson(result));
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Gagal ambil nama bank", e);
            result.put("status", "error");
            result.put("message", "Gagal mengambil data bank");
            try (PrintWriter out = resp.getWriter()) {
                out.print(gson.toJson(result));
            }
        }
    }
       
    public static void main(String[] args) {
        try {
            // Setup
            DbService dbService = new DbService();
            MonRekonPerUpiService service = new MonRekonPerUpiService(dbService.getDataSource());

            // Cek mode run: "rekap" atau "detail"
            String mode = "detail"; //(args.length > 0) ? args[0] : "rekap";

            List<String>  pesanMsg   = new ArrayList<>();
            List<Boolean> statusMsg  = new ArrayList<>();

            if ("detail".equalsIgnoreCase(mode)) {
                System.out.println("== TEST MODE: DETAIL ==");

                // Parameter detail
                int start = 1;
                int length = 10;
                String sortBy = "KD_DIST";
                String sortDir = "ASC";
                String search = "";
                String vbln_usulan = "202505";
                String vkd_bank = "200";
                String vkd_dist = "11";

                List<Map<String, Object>> detail = service.getDataMonDftPerUpi(
                        start, length, sortBy, sortDir, search,
                        vbln_usulan, vkd_bank, vkd_dist, 
                        pesanMsg, statusMsg
                );

                System.out.println("Jumlah data detail: " + detail.size());

                for (Map<String, Object> row : detail) {
                    System.out.println(row);
                }

            } else {
                System.out.println("== TEST MODE: REKAP ==");

                String vbln_usulan = "202505";
                List<Map<String, Object>> rekap = service.getDataMonRkpPerPerUpi(vbln_usulan, pesanMsg, statusMsg);

                for (Map<String, Object> row : rekap) {
                    System.out.println(row);
                }
            }

            System.out.println("Pesan Output: " + (pesanMsg.isEmpty() ? "Tidak ada pesan" : pesanMsg.get(0)));

        } catch (Exception e) {
            System.err.println("Error saat testing: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
