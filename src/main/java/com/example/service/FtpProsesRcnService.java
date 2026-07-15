package com.example.service;

import org.apache.commons.net.ftp.FTP;
import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPReply;
import org.apache.commons.net.ftp.FTPSClient;

import com.example.utils.FTPSClientWithSessionReuse;
import com.example.utils.HttpStatusHelper;
import com.example.utils.HttpStatusHelper.StatusInfo;

import oracle.jdbc.OracleTypes;

import java.io.IOException;
import java.io.OutputStream;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Types;
// Pastikan ini di-import jika belum ada
import java.util.*;
import java.util.logging.Logger;

import javax.sql.DataSource;

public class FtpProsesRcnService {
    private static final Logger logger = Logger.getLogger(FtpProsesRcnService.class.getName());
    private static final String[] PRODUK_LIST = {"NTLS", "POSTPAID", "PREPAID"};
    
    private final String host;
    private final int port;
    private final String username;
    private final String password;
    private final boolean useTls;
    private final DataSource dataSource;
    
    // A) Progres mnggunakan FTP Proses file RCN dan CTL 
    // -------------------------------------------------
    public FtpProsesRcnService(String host, int port, String username, String password, boolean useTls, DataSource dataSource) {
        this.host = host;
        this.port = port;
        this.username = username;
        this.password = password;
        this.useTls = useTls;
        this.dataSource = dataSource;
    }

    // Method internal untuk membuka koneksi baru dinamis berbasis Environment
    private FTPClient createConnection() throws Exception {
        FTPClient ftpClient;
        
        if (useTls) {
            // PERBAIKAN: Gunakan FTPSClientWithSessionReuse buatan kita
            FTPSClientWithSessionReuse ftps = new FTPSClientWithSessionReuse("TLS", false); 
            
            ftps.setTrustManager(org.apache.commons.net.util.TrustManagerUtils.getAcceptAllTrustManager());
            
            ftpClient = ftps;
            logger.info("Mode FTP: Menggunakan Explicit TLS dengan Session Reuse (Secure)");
        } else {
            ftpClient = new FTPClient();
            logger.info("Mode FTP: Plain FTP (Non-TLS)");
        }
        
        ftpClient.setConnectTimeout(10000);
        ftpClient.setDefaultTimeout(10000);
        
        ftpClient.connect(host, port);
        
        int reply = ftpClient.getReplyCode();
        if (!FTPReply.isPositiveCompletion(reply)) {
            ftpClient.disconnect();
            throw new Exception("FTP server refused connection. Reply code: " + reply);
        }

        if (useTls) {
            FTPSClient secureClient = (FTPSClient) ftpClient;
            secureClient.execPBSZ(0);
            secureClient.execPROT("P");
        }

        boolean success = ftpClient.login(username, password);
        if (!success) {
            ftpClient.disconnect();
            throw new Exception("Gagal login ke FTP Server. Cek username/password.");
        }

        ftpClient.enterLocalPassiveMode();
        
        return ftpClient;
    }

    public Map<String, List<String>> listRcnFiles() throws IOException {
        Map<String, List<String>> result = new HashMap<>();
        List<String> listSukses = new ArrayList<>();
        
        FTPClient ftp = null;
        try {
            ftp = createConnection(); 

            for(String produk : PRODUK_LIST){
                String basePath = "/vertikal/*/" + produk;
                String[] suksesFolders = new String[]{
                        basePath + "/lunas"
                };

                for(String folder : suksesFolders){
                    List<String> files = listFilesFromFolder(ftp, folder);
                    listSukses.addAll(files);
                }
            }

            result.put("SUKSES", listSukses);
            logger.info("[FTP] Total files loaded. Sukses=" + listSukses.size());

        } catch (Exception e) {
            logger.severe("[FTP] Gagal listRcnFiles: " + e.getMessage());
            throw new IOException(e);
        } finally {
            if(ftp != null && ftp.isConnected()){
                try {
                    ftp.logout();
                    ftp.disconnect();
                } catch (IOException ignored) {}
            }
        }

        return result;
    }

    private List<String> listFilesFromFolder(FTPClient ftp, String folderPath) throws IOException {
        List<String> result = new ArrayList<>();
        
        if(!ftp.changeWorkingDirectory(folderPath)){
            logger.warning("[FTP] Folder tidak ditemukan: " + folderPath);
            return result;
        }

        String[] files = ftp.listNames();
        if(files == null) return result;

        for(String file : files){
            result.add(folderPath + "/" + file);
        }
        return result;
    }

    public List<String> listFilesFromDir(String folderPath) {
        List<String> result = new ArrayList<>();
        FTPClient ftp = null;

        try {
            ftp = createConnection(); 
            ftp.setFileType(FTP.BINARY_FILE_TYPE);

            logger.info("[FTP] Mengakses direktori: " + folderPath);
            if (!ftp.changeWorkingDirectory(folderPath)) {
                logger.warning("[FTP] Folder tidak ditemukan : " + folderPath);
                return result;
            }

            String[] files = ftp.listNames();
            if (files != null) {
                for (String file : files) {
                    // PERBAIKAN: Hanya masukkan berkas yang berakhiran .rcn (case-insensitive)
                    if (file != null && file.toLowerCase().endsWith(".rcn")) {
                        result.add(folderPath + "/" + file);
                    }
                }
            }

        } catch (Exception e) {
            logger.warning("[FTP] Error membaca folder " + folderPath + " : " + e.getMessage());
        } finally {
            if (ftp != null && ftp.isConnected()) {
                try {
                    ftp.logout(); 
                    ftp.disconnect();
                } catch (Exception ignored) {}
            }
        }

        return result;
    }

    public boolean downloadFile(String ftpPath, OutputStream outputStream){
        FTPClient ftp = null;
        try {
            ftp = createConnection();
            ftp.setFileType(FTP.BINARY_FILE_TYPE);
            
            boolean success = ftp.retrieveFile(ftpPath, outputStream);
            ftp.logout();
            return success;
        } catch (Exception e){
            logger.severe("[FTP] Gagal mengunduh file: " + e.getMessage());
            return false;
        } finally {
            try{
                if(ftp != null && ftp.isConnected()){
                    ftp.disconnect();
                }
            } catch (Exception ignored){}
        }
    }

    // 📌 SIMPAN / GANTI DI SINI
    public String pindahkanFileRcn(String pathAsal) {
        FTPClient ftp = null;
        try {
            int indexSlashTerakhir = pathAsal.lastIndexOf("/");
            if (indexSlashTerakhir == -1) {
                return "ERROR: Format path asal tidak valid";
            }
            
            String folderLunas = pathAsal.substring(0, indexSlashTerakhir); 
            String namaFileAsli = pathAsal.substring(indexSlashTerakhir + 1); 

            String folderProses = folderLunas + "/proses";
            String pathTujuanBaru = folderProses + "/" + namaFileAsli;

            ftp = createConnection();
            ftp.setFileType(FTP.BINARY_FILE_TYPE);

            if (!ftp.changeWorkingDirectory(folderProses)) {
                logger.info("[FTP] Folder /proses tidak ditemukan. Mencoba membuat folder: " + folderProses);
                if (ftp.makeDirectory(folderProses)) {
                    logger.info("[FTP] Folder /proses berhasil dibuat.");
                } else {
                    return "ERROR: Gagal membuat folder tujuan /proses di FTP Server";
                }
            }

            String[] existingFiles = ftp.listNames(pathTujuanBaru);
            
            if (existingFiles != null && existingFiles.length > 0) {
                logger.info("[FTP] File " + namaFileAsli + " sudah ada di folder /proses. Membuat nama random...");
                
                int indexTitik = namaFileAsli.lastIndexOf(".");
                String namaTanpaEkstensi = (indexTitik != -1) ? namaFileAsli.substring(0, indexTitik) : namaFileAsli;
                String ekstensi = (indexTitik != -1) ? namaFileAsli.substring(indexTitik) : "";

                Random rand = new Random();
                int angkaRandom = 100 + rand.nextInt(900);

                String namaFileBaruRandom = namaTanpaEkstensi + "_" + angkaRandom + ekstensi;
                pathTujuanBaru = folderProses + "/" + namaFileBaruRandom;
            }

            logger.info("[FTP] Memindahkan file dari: " + pathAsal + " ke: " + pathTujuanBaru);
            boolean successMove = ftp.rename(pathAsal, pathTujuanBaru);

            if (successMove) {
                logger.info("[FTP] File sukses dipindahkan.");
                return "SUCCESS_MOVED: " + pathTujuanBaru;
            } else {
                int replyCode = ftp.getReplyCode();
                logger.warning("[FTP] Gagal memindahkan file. Reply Code: " + replyCode);
                return "FAILED_TO_MOVE (Reply Code: " + replyCode + ")";
            }

        } catch (Exception e) {
            logger.severe("[FTP] Kendala sistem saat memindahkan file: " + e.getMessage());
            return "ERROR: " + e.getMessage();
        } finally {
            if (ftp != null && ftp.isConnected()) {
                try {
                    ftp.logout();
                    ftp.disconnect();
                } catch (IOException ignored) {}
            }
        }
    }

    public Map<String, String> pindahkanSepasangFileRcnDanCtl(String pathRcn, String pathCtl) {
        Map<String, String> resultPaths = new HashMap<>();
        FTPClient ftp = null;
        try {
            int indexSlash = pathRcn.lastIndexOf("/");
            if (indexSlash == -1) {
                resultPaths.put("ERROR", "Format path asal tidak valid");
                return resultPaths;
            }
            
            String folderLunas = pathRcn.substring(0, indexSlash); 
            String namaRcnAsli = pathRcn.substring(indexSlash + 1); 
            String namaCtlAsli = pathCtl.substring(pathCtl.lastIndexOf("/") + 1);

            String folderProses = folderLunas + "/proses";
            String targetRcn = folderProses + "/" + namaRcnAsli;
            String targetCtl = folderProses + "/" + namaCtlAsli;

            ftp = createConnection();
            ftp.setFileType(FTP.BINARY_FILE_TYPE);

            if (!ftp.changeWorkingDirectory(folderProses)) {
                if (!ftp.makeDirectory(folderProses)) {
                    resultPaths.put("ERROR", "Gagal membuat folder /proses di FTP");
                    return resultPaths;
                }
            }

            // Pengecekan duplikasi file berdasarkan nama RCN utama
            String[] existingFiles = ftp.listNames(targetRcn);
            if (existingFiles != null && existingFiles.length > 0) {
                logger.info("[FTP] File " + namaRcnAsli + " duplikat di /proses. Generate satu angka acak bersama...");
                
                int indexTitik = namaRcnAsli.lastIndexOf(".");
                String namaTanpaEkstensi = (indexTitik != -1) ? namaRcnAsli.substring(0, indexTitik) : namaRcnAsli;
                String ekstensiRcn = (indexTitik != -1) ? namaRcnAsli.substring(indexTitik) : ".rcn";

                // Ambil satu angka acak tunggal
                Random rand = new Random();
                int angkaRandom = 100 + rand.nextInt(900);

                // 📌 KUNCI PERBAIKAN: Penamaan baru yang serasi (.rcn dan .rcn.ctl)
                String namaRcnBaru = namaTanpaEkstensi + "_" + angkaRandom + ekstensiRcn;
                String namaCtlBaru = namaTanpaEkstensi + "_" + angkaRandom + ekstensiRcn + ".ctl"; 

                targetRcn = folderProses + "/" + namaRcnBaru;
                targetCtl = folderProses + "/" + namaCtlBaru;
            }

            logger.info("[FTP] Memindahkan sepasang file ke /proses...");
            boolean successRcn = ftp.rename(pathRcn, targetRcn);
            boolean successCtl = ftp.rename(pathCtl, targetCtl);

            if (successRcn && successCtl) {
                resultPaths.put("status", "SUCCESS");
                resultPaths.put("pathRcn", targetRcn);
                resultPaths.put("pathCtl", targetCtl);
            } else {
                resultPaths.put("status", "FAILED");
                resultPaths.put("message", "Gagal me-rename salah satu file di FTP server.");
            }

        } catch (Exception e) {
            logger.severe("[FTP] Kendala sistem: " + e.getMessage());
            resultPaths.put("status", "ERROR");
            resultPaths.put("message", e.getMessage());
        } finally {
            if (ftp != null && ftp.isConnected()) {
                try { ftp.logout(); ftp.disconnect(); } catch (IOException ignored) {}
            }
        }
        return resultPaths;
    }

    // B) PRogres Insert data ke DB dari isi file RCN dan CTL
    // -------------------------------------------------
    public List<Map<String, Object>> SetProsesInsertFileRcnkeDb(String jsonfilercn, String jsonfilercnctl, List<String> pesanMsg, List<Boolean> statusMsg) {
        List<Map<String, Object>> result = new ArrayList<>();
        
        // PERBAIKAN 1: Pastikan ada 4 tanda tanya (?) sesuai jumlah parameter procedure
        String sql = "{ call OPHARTDE.VER_PROSES_REKON_MIV.INSERT_ISIFILERCN_REKON_BANK(?, ?, ?, ?)}";

        logger.info("Memulai panggilan prosedur Oracle: " + sql);

        try (Connection conn = dataSource.getConnection();
            CallableStatement stmt = conn.prepareCall(sql)) {

            // Proteksi jika payload kosong agar tidak melemparkan null pointer
            String rcnString = (jsonfilercn != null) ? jsonfilercn : "[]";
            String ctlString = (jsonfilercnctl != null) ? jsonfilercnctl : "{}";

            // PERBAIKAN 2: Petakan parameter sesuai urutan input-output DB
            stmt.setString(1, rcnString);                     // JSON_DATA_RCN (Input 1)
            stmt.setString(2, ctlString);                     // JSON_DATA_RCNCTL (Input 2)
            stmt.registerOutParameter(3, OracleTypes.CURSOR);  // out_cursor (Output 3)
            stmt.registerOutParameter(4, Types.VARCHAR);       // pesan (Output 4)

            logger.info("Prosedur Insert file Pelunasan RCN BANK Dimulai.");
            stmt.execute();

            // Ambil pesan output string terlebih dahulu
            String pesanDariDb = stmt.getString(4);

            // PERBAIKAN 3: Ambil objek kursor dari indeks ke-3 (bukan indeks ke-2)
            try (ResultSet rs = (ResultSet) stmt.getObject(3)) {
                if (rs != null) {
                    while (rs.next()) {
                        Map<String, Object> row = new HashMap<>();
                        row.put("TGLINSERT", rs.getString("TGLINSERT"));
                        row.put("NAMAFILE",  rs.getString("NAMAFILE"));
                        row.put("MESSAGE",   rs.getString("MESSAGE"));
                        row.put("STATUS",    rs.getString("STATUS"));
                        row.put("PRODUK",    rs.getString("PRODUK"));
                        result.add(row);
                    }
                }
                
                logger.info(pesanDariDb);
                pesanMsg.add("200|" + pesanDariDb);
                statusMsg.add(true);

            } catch (Exception e) {
                logger.severe("Kesalahan Eksekusi Query/Mapping Parameter: " + e.getMessage());
                StatusInfo badRequestInfo = HttpStatusHelper.getInfo(400);
                pesanMsg.add("400|" + badRequestInfo.getCodeMessage() + " -> " + e.getMessage()); 
                statusMsg.add(false);
                return result; 
            }

        } catch (Exception e) {
            logger.severe("Kesalahan database : " + e.getMessage());
            pesanMsg.add("503|Terjadi kesalahan koneksi ke database: " + e.getMessage());
            statusMsg.add(false);
        }
        
        return result; 
    }

    public List<Map<String, Object>> GetLogProsesInsertFileRcnkeDb(
        int start, 
        int length, 
        String sortBy, 
        String sortDir, 
        String search, 
        String tglawal, 
        String tglakhir, 
        List<String> pesanMsg, 
        List<Boolean> statusMsg) {
            
        List<Map<String, Object>> result = new ArrayList<>();
        
        // Pastikan tanda tanya (?) berjumlah 9 sesuai tanda tangan Prosedur di DB
        String sql = "{ call OPHARTDE.VER_PROSES_REKON_MIV.GET_LOG_FILERCN_PROSES(?, ?, ?, ?, ?, ?, ?, ?, ?)}";

        logger.info("Memulai panggilan prosedur Oracle (Server-Side): " + sql);

        try (Connection conn = dataSource.getConnection();
            CallableStatement stmt = conn.prepareCall(sql)) {

            // 📌 PERBAIKAN URUTAN PARAMETER (Sesuai dengan Spesifikasi Stored Procedure DB)
            stmt.setInt(1, start);                            // in_start
            stmt.setInt(2, length);                           // in_length
            stmt.setString(3, sortBy);                        // in_sort_by
            stmt.setString(4, sortDir);                       // in_sort_dir
            stmt.setString(5, search);                        // in_search
            stmt.setString(6, tglawal);                       // vtglawal
            stmt.setString(7, tglakhir);                      // vtglakhir
            stmt.registerOutParameter(8, OracleTypes.CURSOR);  // out_cursor
            stmt.registerOutParameter(9, Types.VARCHAR);       // pesan

            logger.info("Get LOG file Pelunasan RCN BANK Server-side Dimulai.");
            stmt.execute();

            // Ambil pesan output string terlebih dahulu
            String pesanDariDb = stmt.getString(9);
            boolean isDbError = (pesanDariDb != null && pesanDariDb.startsWith("Gagal Tampilkan Data"));

            // Ambil objek kursor dari indeks ke-8
            try (ResultSet rs = (ResultSet) stmt.getObject(8)) {
                if (rs != null) {
                    while (rs.next()) {
                        Map<String, Object> row = new HashMap<>();
                        row.put("TGLINSERT", rs.getString("TGLINSERT"));
                        row.put("NAMAFILE",  rs.getString("NAMAFILE"));
                        row.put("MESSAGE",   rs.getString("MESSAGE"));
                        row.put("STATUS",    rs.getString("STATUS"));
                        row.put("PRODUK",    rs.getString("PRODUK"));
                        
                        // 📌 Ambil kolom TOTAL_COUNT dari SQL window function untuk Server-side DataTables
                        row.put("TOTAL_COUNT", rs.getObject("TOTAL_COUNT")); 
                        
                        result.add(row);
                    }
                }
                
                logger.info("Hasil DB Message: " + pesanDariDb);
                
                if (isDbError) {
                    pesanMsg.add("500|" + pesanDariDb);
                    statusMsg.add(false);
                } else {
                    pesanMsg.add("200|" + pesanDariDb);
                    statusMsg.add(true);
                }

            } catch (Exception e) {
                logger.severe("Kesalahan Eksekusi Query/Mapping Parameter: " + e.getMessage());
                
                // 📌 PERBAIKAN: Menggunakan penanganan standar Java yang aman tanpa 'typeof'
                pesanMsg.add("400|Bad Request -> " + e.getMessage());
                statusMsg.add(false);
                return result; 
            }

        } catch (Exception e) {
            logger.severe("Kesalahan database : " + e.getMessage());
            pesanMsg.add("503|Terjadi kesalahan koneksi ke database: " + e.getMessage());
            statusMsg.add(false);
        }
        
        return result; 
    }

}