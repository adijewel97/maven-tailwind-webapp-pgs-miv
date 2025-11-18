package com.example.controller;

import com.example.service.DbService;
import com.example.service.MstGlobalService;
import com.example.utils.LoggerUtil;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class MstGlobalController extends HttpServlet {
    private MstGlobalService service;
    private static final Logger logger = LoggerUtil.getLogger(MstGlobalController.class);
    private final Gson gson = new Gson();

    @Override
    public void init() throws ServletException {
        super.init();
        try {
            DbService dbService = new DbService();
            service = new MstGlobalService(dbService.getDataSource());
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Gagal inisialisasi koneksi DB di init()", e);
            throw new ServletException("Gagal inisialisasi koneksi DB", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String act = req.getParameter("act");

        switch (act) {
            case "getNamaUnitUPI":
                handleGetNamaUnitUPI(req, resp);
                break;
            case "getNamaArea":
                handleGetNamaArea(req, resp);
                break;
            case "getNamaBank":
                handleGetBank(req, resp);
                break;
            default:
                sendError(resp, "Aksi tidak dikenal: " + act);
        }
    }

    private void handleGetNamaUnitUPI(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String kd_dist = req.getParameter("kd_dist");
        Map<String, Object> result = new HashMap<>();

        resp.setContentType("application/json;charset=UTF-8");

        try (PrintWriter out = resp.getWriter()) {
            List<Map<String, Object>> data = service.getDataUnitUPI(kd_dist);

            result.put("status", "success");
            result.put("data", data);
            out.print(gson.toJson(result));

            logger.info("✅ Berhasil ambil data UNITUPI, jumlah data: " + (data != null ? data.size() : 0));

        } catch (Exception e) {
            logger.log(Level.SEVERE, "❌ Gagal ambil nama UNITUPI", e);
            result.put("status", "error");
            result.put("message", "Gagal mengambil data UNITUPI");
            try (PrintWriter out = resp.getWriter()) {
                out.print(gson.toJson(result));
            }
        }
    }

    private void handleGetNamaArea(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String kd_dist = req.getParameter("kd_dist");
        Map<String, Object> result = new HashMap<>();
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try (PrintWriter out = resp.getWriter()) {
            List<Map<String, Object>> data = service.getDataAreaUP3(kd_dist);
            result.put("status", "success");
            result.put("data", data);
            out.print(gson.toJson(result));
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Gagal ambil data UP3", e);
            result.put("status", "error");
            result.put("message", "Gagal mengambil data UP3");
            try (PrintWriter out = resp.getWriter()) {
                out.print(gson.toJson(result));
            }
        }
    }

    private void handleGetBank(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Map<String, Object> result = new HashMap<>();
        resp.setContentType("application/json;charset=UTF-8");

        String kdbank = req.getParameter("kdbank");
        logger.info("🔍 Memanggil service.getMasterBank(" + kdbank + ")...");

        try (PrintWriter out = resp.getWriter()) {
            List<Map<String, Object>> data = service.getMasterBank(kdbank);
            logger.info("✅ Berhasil ambil data bank. Jumlah data: " + (data != null ? data.size() : 0));

            result.put("status", "success");
            result.put("data", data);
            out.print(gson.toJson(result));

        } catch (Exception e) {
            logger.log(Level.SEVERE, "❌ Gagal ambil master bank", e);
            result.put("status", "error");
            result.put("message", "Gagal mengambil data bank");

            try (PrintWriter out = resp.getWriter()) {
                out.print(gson.toJson(result));
            }
        }
    }

    private void sendError(HttpServletResponse resp, String msg) throws IOException {
        Map<String, Object> error = new HashMap<>();
        error.put("status", "error");
        error.put("message", msg);

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try (PrintWriter out = resp.getWriter()) {
            out.print(gson.toJson(error));
        }
    }
}
