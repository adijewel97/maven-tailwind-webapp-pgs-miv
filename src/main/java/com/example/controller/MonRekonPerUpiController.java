package com.example.controller;

import com.example.service.DbService;
import com.example.service.MonRekonPerUpiService;
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
public class MonRekonPerUpiController extends HttpServlet {
    private MonRekonPerUpiService service;
    private static final Logger logger = LoggerUtil.getLogger(MonRekonPerUpiController.class);
    private final Gson gson = new Gson();

    // private static final String ACT_JENIS_LAPORAN = "handleGetJenisLaporan";
    // private static final String ACT_SUMBER_DATA = "handleGetsumberdata";

    @Override
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
        prosesMonPerUpi(req, resp);
    }

    private void prosesMonPerUpi(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String vbln_usulan = req.getParameter("vbln_usulan");
        // String vtahun = req.getParameter("vtahun");
        int vkode;

        // WAJIB untuk DataTables server-side
        int draw = Integer.parseInt(req.getParameter("draw") != null ? req.getParameter("draw") : "1");

        logger.info("vbln_usulan: " + vbln_usulan);
        // logger.info("vtahun: " + vtahun);

        List<Map<String, Object>> data = Collections.emptyList();
        int totalCount = 0;
        String pesan;

       try {
            List<String> pesanOutput = new ArrayList<>();
            data = service.getDataMPerPerUpi(vbln_usulan, pesanOutput);
            logger.info("Jumlah data dikembalikan: " + data.size());

            String pesanRaw = pesanOutput.isEmpty() ? "" : pesanOutput.get(0).toLowerCase().trim();
            if (pesanRaw.contains("kesalahan")) {
                vkode = 402;
                pesan = "Error:"+pesanOutput.get(0);
                data = new ArrayList<>();
            } else {
                totalCount = data.size();
                vkode = 200;
                pesan = "Sukses: Tampikan data";
            }
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error: Gagal mendapatkan data: " + e.getMessage(), e);
            vkode = 402;
            pesan = "Error: Terjadi kesalahan: " + e.getMessage();
        }

        // Format JSON sesuai DataTables server-side
        Map<String, Object> jsonResponse = new HashMap<>();
        jsonResponse.put("draw", draw); // WAJIB
        jsonResponse.put("recordsTotal", totalCount); // WAJIB
        jsonResponse.put("recordsFiltered", totalCount); // WAJIB
        jsonResponse.put("data", data); // WAJIB
        jsonResponse.put("status", "success");
        jsonResponse.put("kode", vkode);
        jsonResponse.put("pesan", pesan);


        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try (PrintWriter out = resp.getWriter()) {
            out.print(gson.toJson(jsonResponse));
        }
    }

    private void handleGetDetailData(HttpServletRequest req, HttpServletResponse resp) throws IOException {
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

        logger.info("draw = " + draw);
        logger.info("offset (startIndex) = " + startIndex);
        logger.info("limit (length) = " + length);
        logger.info("sortBy = " + sortBy + " " + sortDir);
        logger.info("searchValue = " + searchValue);
        logger.info("vbln_usulan = " + vbln_usulan);
        logger.info("vkd_bank = " + vkd_bank);
        logger.info("vkd_dist = " + vkd_dist);

        List<String> pesanOutput = new ArrayList<>();

        List<Map<String, Object>> data = service.getDataMDftPerUpi(
            start, length, sortBy, sortDir, searchValue, vbln_usulan, vkd_bank, vkd_dist, pesanOutput
        );

        System.out.println("Jumlah data yang dikembalikan untuk ekspor: " + data.size());

        int totalRecords = 0;
        if (!data.isEmpty() && data.get(0).get("TOTAL_COUNT") != null) {
            totalRecords = Integer.parseInt(data.get(0).get("TOTAL_COUNT").toString());
        }

        Map<String, Object> jsonResponse = new HashMap<>();
        jsonResponse.put("draw", draw);
        jsonResponse.put("recordsTotal", totalRecords);
        jsonResponse.put("recordsFiltered", totalRecords);
        jsonResponse.put("data", data);

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try (PrintWriter out = resp.getWriter()) {
            out.print(gson.toJson(jsonResponse));
        }
    }

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

            List<String> pesanOutput = new ArrayList<>();

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

                List<Map<String, Object>> detail = service.getDataMDftPerUpi(
                        start, length, sortBy, sortDir, search,
                        vbln_usulan, vkd_bank, vkd_dist, pesanOutput
                );

                System.out.println("Jumlah data detail: " + detail.size());

                for (Map<String, Object> row : detail) {
                    System.out.println(row);
                }

            } else {
                System.out.println("== TEST MODE: REKAP ==");

                String vbln_usulan = "202505";
                List<Map<String, Object>> rekap = service.getDataMPerPerUpi(vbln_usulan, pesanOutput);

                for (Map<String, Object> row : rekap) {
                    System.out.println(row);
                }
            }

            System.out.println("Pesan Output: " + (pesanOutput.isEmpty() ? "Tidak ada pesan" : pesanOutput.get(0)));

        } catch (Exception e) {
            System.err.println("Error saat testing: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
