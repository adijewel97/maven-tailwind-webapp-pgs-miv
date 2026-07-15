package com.example.controller;

import com.example.service.DbService;
import com.example.service.FtpProsesRcnService;
import com.example.service.MstGlobalService;
import com.example.utils.FTPConfig;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import java.io.IOException;
import java.io.OutputStream;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/mon4ProsesFileRcn")
public class Mon04ProsesRcnController extends HttpServlet {

    private FtpProsesRcnService ftpService;
    private MstGlobalService mstGlobalService;
    private static final Logger logger =
            Logger.getLogger(Mon04ProsesRcnController.class.getName());
    private final Gson gson = new Gson();
    
    @Override
    public void init() throws ServletException {
        super.init();
        try {
            // 1. Inisialisasi DbService terlebih dahulu untuk mendapatkan DataSource
            DbService dbService = new DbService();
            
            // 2. Kirim dbService.getDataSource() ke parameter ke-5 FtpProsesRcnService
            ftpService = new FtpProsesRcnService(
                    FTPConfig.getHost(),
                    FTPConfig.getPort(),
                    FTPConfig.getUsername(),
                    FTPConfig.getPassword(),
                    FTPConfig.getUseTls(),
                    dbService.getDataSource() // <-- PERBAIKAN: Parameter ke-5 ditambahkan di sini
            );
            
            mstGlobalService = new MstGlobalService(dbService.getDataSource());
            logger.info("[INIT] Mon04ProsesRcnController berhasil diinisialisasi.");
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Gagal inisialisasi service", e);
            throw new ServletException(e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        String act = request.getParameter("act");
        try {
            switch (act == null ? "" : act.toLowerCase()) {
                case "listrcn":
                    handleListRcn(request, response);
                    break;
                case "download":
                    handleDownload(request, response);
                    break;
                case "readfilercn":
                    handleReadFileRCN(request, response);
                    break;
                case "readfilercnctl":
                    handleReadFileRCNCTL(request, response);
                    break;
                case "insertdb": // <--- TAMBAHKAN CASE BARU INI
                    handleInsertDb(request, response);
                    break;
                case "getlogdbrcn": // <--- TAMBAHKAN CASE BARU INI
                    handleGetlogCRNDb(request, response);
                    break;
                default:
                    Map<String,Object> result = new HashMap<>();
                    result.put("status","error");
                    result.put("message","Invalid act parameter");
                    response.getWriter().print(gson.toJson(result));
            }
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error", e);
            Map<String,Object> result = new HashMap<>();
            result.put("status","error");
            result.put("message",e.getMessage());
            response.getWriter().print(gson.toJson(result));
        }
    }

    private void handleListRcn(HttpServletRequest request,
                               HttpServletResponse response) throws Exception {
        List<String> listSuksesRcn = new ArrayList<>();
        String[] daftarProduk = {
                "POSTPAID",
                "NTLS",
                "PREPAID"
        };

        String bankParam = request.getParameter("bankmiv");
        List<Map<String,Object>> targetBanks;
        if (bankParam == null
                || bankParam.trim().isEmpty()
                || "SEMUA".equalsIgnoreCase(bankParam)
                || "ALL".equalsIgnoreCase(bankParam)) {
            targetBanks = mstGlobalService.getMasterBank("SEMUA");
            // Hapus record default "ALL"
            targetBanks.removeIf(bank ->
                "ALL".equalsIgnoreCase(
                    Objects.toString(bank.get("KODE_BANK"), "").trim()
                )
            );
        } else {
            targetBanks = mstGlobalService.getMasterBank(bankParam);
        }

        for (Map<String,Object> bankItem : targetBanks) {
            String kodeErp = Objects.toString(bankItem.get("KODE_ERP"), "");
            String kodeBank = Objects.toString(bankItem.get("KODE_BANK"), "");
            if (kodeBank.isEmpty())
                continue;
            String folderCA =
                    (kodeBank.length() >= 3
                            ? kodeBank.substring(0,3)
                            : kodeBank)
                            + "CA01";
            for(String produk : daftarProduk){
                String path =
                        "/vertikal/"
                        + kodeErp
                        + "/"
                        + folderCA
                        + "/"
                        + produk
                        + "/lunas";
                List<String> files =
                        ftpService.listFilesFromDir(path);
                if(files != null){
                    listSuksesRcn.addAll(files);
                }
            }
        }

        Map<String,Object> result = new HashMap<>();
        result.put("status","success");
        result.put("listSuksesRcn",listSuksesRcn);
        response.getWriter().print(gson.toJson(result));
    }

    private void handleDownload(HttpServletRequest request,
                                HttpServletResponse response)
            throws IOException {

        String filePath = request.getParameter("file");

        if(filePath == null || filePath.trim().isEmpty()){
            Map<String,Object> result = new HashMap<>();
            result.put("status","error");
            result.put("message","File path tidak valid");
            response.getWriter().print(gson.toJson(result));
            return;
        }

        String fileName =
                filePath.substring(filePath.lastIndexOf("/") + 1);

        response.setContentType("application/octet-stream");
        response.setHeader(
                "Content-Disposition",
                "attachment; filename=\"" + fileName + "\"");

        try(OutputStream os = response.getOutputStream()){
            boolean success =
                    ftpService.downloadFile(filePath, os);

            if(!success){
                logger.warning("Gagal download : " + filePath);
            }
        }
    }

    private void handleReadFileRCN(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        String filePath = request.getParameter("file");
        Map<String, Object> result = new HashMap<>();

        if (filePath == null || filePath.trim().isEmpty()) {
            result.put("status", "error");
            result.put("message", "File path tidak valid");
            response.getWriter().print(gson.toJson(result));
            return;
        }

        // Gunakan ByteArrayOutputStream untuk menangkap isi file teks dari FTP ke memori
        try (java.io.ByteArrayOutputStream os = new java.io.ByteArrayOutputStream()) {
            boolean success = ftpService.downloadFile(filePath, os);

            if (success) {
                // Ubah byte stream menjadi String teks standar UTF-8 / ASCII
                String fileContent = os.toString("UTF-8");
                
                result.put("status", "success");
                result.put("fileContent", fileContent);
            } else {
                result.put("status", "error");
                result.put("message", "Gagal mengambil data file RCN dari FTP");
            }
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Gagal memproses pembacaan file RCN", e);
            result.put("status", "error");
            result.put("message", e.getMessage());
        }

        response.getWriter().print(gson.toJson(result));
    }

    private void handleReadFileRCNCTL(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        String filePath = request.getParameter("file");
        Map<String, Object> result = new HashMap<>();

        if (filePath == null || filePath.trim().isEmpty()) {
            result.put("status", "error");
            result.put("message", "File path tidak valid");
            response.getWriter().print(gson.toJson(result));
            return;
        }

        // Gunakan ByteArrayOutputStream untuk menangkap isi file teks dari FTP ke memori
        try (java.io.ByteArrayOutputStream os = new java.io.ByteArrayOutputStream()) {
            boolean success = ftpService.downloadFile(filePath, os);

            if (success) {
                // Ubah byte stream menjadi String teks standar UTF-8 / ASCII
                String fileContent = os.toString("UTF-8");
                
                result.put("status", "success");
                result.put("fileContent", fileContent);
            } else {
                result.put("status", "error");
                result.put("message", "Gagal mengambil data file RCN.CTL dari FTP");
            }
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Gagal memproses pembacaan file RCN.CTL", e);
            result.put("status", "error");
            result.put("message", e.getMessage());
        }

        response.getWriter().print(gson.toJson(result));
    }

    private void handleInsertDb(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        Map<String, Object> responseJson = new HashMap<>();
        
        // 1. Ambil data JSON string (RCN & RCNCTL) serta path file masing-masing dari JSP
        String jsonPayload = request.getParameter("jsonData");       // Detail RCN
        String jsonPayloadCtl = request.getParameter("jsonDataCtl"); // Control RCNCTL
        String filePath = request.getParameter("file");              // Path RCN (.rcn)
        String filePathCtl = request.getParameter("fileCtl");        // Path CTL (.ctl)
        
        // Validasi payload utama
        if (jsonPayload == null || jsonPayload.trim().isEmpty()) {
            responseJson.put("status", "error");
            responseJson.put("message", "Data JSON RCN kosong atau tidak valid!");
            response.getWriter().print(gson.toJson(responseJson));
            return;
        }

        // 2. Siapkan penampung pesan sesuai tanda tangan metode service
        List<String> pesanMsg = new ArrayList<>();
        List<Boolean> statusMsg = new ArrayList<>();

        try {
            // Default nama file murni (fallback jika FTP proses dilewati/gagal)
            String namaFileBaru = (filePath != null && filePath.contains("/")) 
                    ? filePath.substring(filePath.lastIndexOf("/") + 1) : filePath;
            
            String namaFileCtlBaru = (filePathCtl != null && filePathCtl.contains("/")) 
                    ? filePathCtl.substring(filePathCtl.lastIndexOf("/") + 1) : filePathCtl;

            // 📌 KUNCI PERBAIKAN 1: Hapus blok FTP single yang lama. Pindahkan sepasang sekaligus di sini.
            if (filePath != null && !filePath.trim().isEmpty() && filePathCtl != null && !filePathCtl.trim().isEmpty()) {
                try {
                    // Panggil fungsi pemindahan sepasang file sekaligus agar angka acak sinkron (_229)
                    Map<String, String> hasilPindahSepasang = ftpService.pindahkanSepasangFileRcnDanCtl(filePath, filePathCtl);
                    
                    if ("SUCCESS".equals(hasilPindahSepasang.get("status"))) {
                        String pathRcnBaru = hasilPindahSepasang.get("pathRcn");
                        String pathCtlBaru = hasilPindahSepasang.get("pathCtl");

                        logger.info("📌 [FTP MOVE] RCN baru: " + pathRcnBaru);
                        logger.info("📌 [FTP MOVE] CTL baru: " + pathCtlBaru);

                        responseJson.put("ftpMessage", "SUCCESS_MOVED: " + pathRcnBaru);
                        
                        // Ekstrak nama file murni untuk di-save ke DB
                        namaFileBaru = pathRcnBaru.substring(pathRcnBaru.lastIndexOf("/") + 1);
                        namaFileCtlBaru = pathCtlBaru.substring(pathCtlBaru.lastIndexOf("/") + 1);
                    } else {
                        String errMsg = hasilPindahSepasang.get("message") != null ? hasilPindahSepasang.get("message") : "Gagal memindahkan file berpasangan";
                        responseJson.put("ftpError", errMsg);
                    }
                } catch (Exception ftpEx) {
                    logger.log(Level.WARNING, "Gagal memproses sinkronisasi pasangan file di FTP", ftpEx);
                    responseJson.put("ftpError", "Gagal sinkronisasi FTP: " + ftpEx.getMessage());
                }
            }

            // 📌 KUNCI PERBAIKAN 2: Update field "NAMAFILE" dengan nama baru yang serasi di dalam array detail RCN
            try {
                java.lang.reflect.Type listType = new com.google.gson.reflect.TypeToken<List<Map<String, Object>>>(){}.getType();
                List<Map<String, Object>> jsonList = gson.fromJson(jsonPayload, listType);
                
                if (jsonList != null) {
                    for (Map<String, Object> rowData : jsonList) {
                        rowData.put("NAMAFILE", namaFileBaru); 
                    }
                    jsonPayload = gson.toJson(jsonList);
                }
            } catch (Exception jsonEx) {
                logger.log(Level.WARNING, "Gagal mengupdate NAMAFILE di dalam payload JSON RCN", jsonEx);
            }

            // 📌 MANIPULASI JSON PAYLOAD CTL: Masukkan nama file CTL baru (NAMAFILE_CTL) ke objek JSON CTL
            try {
                if (jsonPayloadCtl != null && !jsonPayloadCtl.trim().isEmpty()) {
                    java.lang.reflect.Type mapType = new com.google.gson.reflect.TypeToken<Map<String, Object>>(){}.getType();
                    Map<String, Object> ctlMap = gson.fromJson(jsonPayloadCtl, mapType);
                    
                    if (ctlMap != null) {
                        ctlMap.put("NAMAFILE_CTL", namaFileCtlBaru); 
                        jsonPayloadCtl = gson.toJson(ctlMap);
                    }
                } else {
                    jsonPayloadCtl = "{\"NAMAFILE_CTL\":\"" + namaFileCtlBaru + "\",\"RECORD_COUNT\":\"0\",\"TOTAL_NOMINAL\":\"0\"}";
                }
            } catch (Exception jsonCtlEx) {
                logger.log(Level.WARNING, "Gagal mengupdate NAMAFILE_CTL di dalam payload JSON CTL", jsonCtlEx);
            }

            // 📌 3. Panggil metode service dengan nama file payload yang sudah tersinkronisasi sempurna
            List<Map<String, Object>> dbResultList = ftpService.SetProsesInsertFileRcnkeDb(
                    jsonPayload, 
                    jsonPayloadCtl, 
                    pesanMsg, 
                    statusMsg
            );

            // 4. Ambil status dan pesan out parameter dari list penampung
            boolean isSuccess = !statusMsg.isEmpty() && statusMsg.get(0);
            String dbMessage = !pesanMsg.isEmpty() ? pesanMsg.get(0) : "No message returned";

            if (isSuccess && dbResultList != null) {
                for (Map<String, Object> row : dbResultList) {
                    String rowStatus = (String) row.get("STATUS");
                    if (rowStatus != null && rowStatus.equalsIgnoreCase("GAGAL")) {
                        isSuccess = false; 
                        break;
                    }
                }
            }

            logger.info("status sukses: " + isSuccess + ", RCN: " + namaFileBaru + ", CTL: " + namaFileCtlBaru);

            // 5. Susun response untuk frontend
            responseJson.put("status", isSuccess ? "success" : "error");
            responseJson.put("dbMessage", dbMessage);
            responseJson.put("dbDetails", dbResultList);

        } catch (Exception e) {
            logger.log(Level.SEVERE, "Gagal memproses insert ke database", e);
            responseJson.put("status", "error");
            responseJson.put("message", "Terjadi kesalahan sistem: " + e.getMessage());
        }

        // Kirim kembali respons ke JSP
        response.getWriter().print(gson.toJson(responseJson));
    }

    private void handleGetlogCRNDb(HttpServletRequest req, HttpServletResponse resp) 
            throws IOException {        
        Map<String, Object> responseJson = new HashMap<>();
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        
        // 1. Inisialisasi Parameter Input Bawaan DataTables
        int draw = 1;
        try {
            if (req.getParameter("draw") != null) {
                draw = Integer.parseInt(req.getParameter("draw"));
            }
        } catch (NumberFormatException e) {
            logger.info("Parameter 'draw' tidak ditemukan atau tidak valid. Default: 1");
        }
        
        int startIndex = 0;
        int length = 10;
        try {
            if (req.getParameter("start") != null) startIndex = Integer.parseInt(req.getParameter("start"));
            if (req.getParameter("length") != null) length = Integer.parseInt(req.getParameter("length"));
        } catch (NumberFormatException e) {
            logger.info("Parameter start/length tidak valid. Menggunakan default (0, 10).");
        }
        
        // Konversi dari index baris awal ke Halaman (karena SP Oracle Anda menggunakan nomor page)
        int startPage = (length > 0) ? (startIndex / length) + 1 : 1;
        
        String sortColumnIndex  = req.getParameter("order[0][column]");
        String sortDir          = req.getParameter("order[0][dir]");
        String searchValue      = req.getParameter("search[value]");
        
        // Menentukan nama kolom database berdasarkan kolom yang diklik di front-end
        String sortBy = null;
        if (sortColumnIndex != null) {
            sortBy = req.getParameter("columns[" + sortColumnIndex + "][data]");
        }
        
        // Fallback jika property kolom tidak ditemukan (Arahkan ke TGLINSERT, bukan KD_DIST)
        if (sortBy == null || sortBy.trim().isEmpty()) {
            sortBy = "TGLINSERT"; 
            sortDir = "DESC";
        } else {
            sortBy = sortBy.toUpperCase(); // Samakan dengan nama kolom di database Oracle (Uppercase)
        }
        
        if (sortDir == null || sortDir.trim().isEmpty()) {
            sortDir = "DESC";
        }
        
        // 2. Ambil data range tanggal dari JSP
        String tglawal          = req.getParameter("vtglawal");       // format: YYYYMMDD
        String tglakhir         = req.getParameter("vtglakhir");     // format: YYYYMMDD
        
        // Validasi input parameter tanggal
        if (tglawal == null || tglawal.trim().isEmpty() || tglakhir == null || tglakhir.trim().isEmpty()) {
            responseJson.put("status", "error");
            responseJson.put("draw", draw);
            responseJson.put("recordsTotal", 0);
            responseJson.put("recordsFiltered", 0);
            responseJson.put("data", new ArrayList<>());
            responseJson.put("message", "Tanggal Awal atau Tanggal Akhir Masih Kosong!");
            resp.getWriter().print(gson.toJson(responseJson));
            return;
        }

        // 3. Siapkan penampung sesuai tanda tangan metode service
        List<String> pesanMsg = new ArrayList<>();
        List<Boolean> statusMsg = new ArrayList<>();
        int recordsTotalCount = 0;

        try {
            // Panggil service ter-update dengan 9 parameter
            List<Map<String, Object>> dbResultList = ftpService.GetLogProsesInsertFileRcnkeDb(
                    startPage, length, sortBy, sortDir, searchValue,
                    tglawal, tglakhir, pesanMsg, statusMsg
            );

            // Ambil status dan pesan out parameter dari list penampung
            boolean isSuccess = !statusMsg.isEmpty() && statusMsg.get(0);
            String dbMessage = !pesanMsg.isEmpty() ? pesanMsg.get(0) : "No message returned";

            if (isSuccess && dbResultList != null && !dbResultList.isEmpty()) {
                // 📌 KUNCI UTAMA: Ambil nilai TOTAL_COUNT dari record pertama hasil query SQL Window Function
                Map<String, Object> firstRow = dbResultList.get(0);
                if (firstRow.containsKey("TOTAL_COUNT")) {
                    Object totalObj = firstRow.get("TOTAL_COUNT");
                    if (totalObj instanceof Number) {
                        recordsTotalCount = ((Number) totalObj).intValue();
                    } else if (totalObj != null) {
                        recordsTotalCount = Integer.parseInt(String.valueOf(totalObj));
                    }
                }
            }

            // 4. Susun response JSON sesuai standar Baku DataTables Server-Side
            if (isSuccess) {
                responseJson.put("status", "success");
                responseJson.put("draw", draw);
                responseJson.put("recordsTotal", recordsTotalCount);
                responseJson.put("recordsFiltered", recordsTotalCount); // Nilai filter disamakan dengan total record data server-side
                responseJson.put("data", dbResultList != null ? dbResultList : new ArrayList<>());
                responseJson.put("dbMessage", dbMessage);
                responseJson.put("dbDetails", dbResultList); // Untuk backward compatibility jika JSP Anda masih memakai property ini
            } else {
                responseJson.put("status", "error");
                responseJson.put("draw", draw);
                responseJson.put("recordsTotal", 0);
                responseJson.put("recordsFiltered", 0);
                responseJson.put("data", new ArrayList<>());
                responseJson.put("message", "Gagal mengambil log: " + dbMessage);
            }

        } catch (Exception e) {
            logger.log(Level.SEVERE, "Gagal mengambil data log dari database", e);
            responseJson.put("status", "error");
            responseJson.put("draw", draw);
            responseJson.put("recordsTotal", 0);
            responseJson.put("recordsFiltered", 0);
            responseJson.put("data", new ArrayList<>());
            responseJson.put("message", "Terjadi kesalahan sistem backend: " + e.getMessage());
        }

        // Kirim kembali respons ke JSP
        resp.getWriter().print(gson.toJson(responseJson));
    }


}