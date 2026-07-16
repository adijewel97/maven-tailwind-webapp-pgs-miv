package com.example.service;

import org.apache.commons.net.ftp.FTP;
import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPFile;
import org.apache.commons.net.ftp.FTPReply;
import org.apache.commons.net.ftp.FTPSClient;

import com.example.utils.FTPSClientWithSessionReuse;

import javax.sql.DataSource;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.*;
import java.util.logging.Logger;

public class FtpStrukService {

    private final String host;
    private final int port;
    private final String username;
    private final String password;
    private final boolean useTls;       // PERBAIKAN: Deklarasikan variabel global

    private static final Logger logger = Logger.getLogger(FtpStrukService.class.getName());

    public FtpStrukService(String host, int port, String username, String password, boolean useTls, DataSource dataSource) {
        this.host = host;
        this.port = port;
        this.username = username;
        this.password = password;
        this.useTls = useTls;
    }

    // Method internal untuk membuka koneksi baru secara dinamis
    private FTPClient createConnection() throws Exception {
        FTPClient ftpClient;
        
        if (useTls) {
            // Menggunakan FTPSClient dengan Session Reuse untuk kompatibilitas TLS modern
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

        // PERBAIKAN: Perintah proteksi data TLS dipindah SEBELUM login agar kredensial aman
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
        ftpClient.setFileType(FTP.BINARY_FILE_TYPE); // PERBAIKAN: Set ke binary secara global agar PDF aman
        
        return ftpClient;
    }

    // ================================
    // LIST FILES
    // ================================
    public List<String> listStrukFiles(String bank, String swbank, String up3, String blth, String idtrans) 
            throws Exception { // PERBAIKAN: Exception disesuaikan dengan createConnection()

        List<String> result = new ArrayList<>();
        FTPClient ftp = createConnection(); // PERBAIKAN: Panggil nama method yang benar (bukan connect())

        try {
            String[] produkFolder = {"NTLS", "POSTPAID", "PREPAID"};
            String idFilter = (idtrans == null) ? "" : idtrans.trim().toLowerCase();

            for (String produk : produkFolder) {
                String basePath = "/vertikal/" + bank + "/" + swbank + "/" + produk + "/lunas/struk/";
                FTPFile[] files = ftp.listFiles(basePath);
                if (files == null) continue;

                for (FTPFile f : files) {
                    if (!f.isFile()) continue;

                    String name = f.getName();
                    String lower = name.toLowerCase();

                    if (!lower.endsWith(".pdf")) continue;

                    // wajib mengandung up3 + blth
                    if (!lower.contains((up3 + blth).toLowerCase())) continue;

                    // jika idtransaksi ada → filter juga
                    if (!idFilter.isEmpty() && !idFilter.equals("*")) {
                        if (!lower.contains(idFilter)) continue;
                    }

                    // return full path untuk download
                    String fullpath = basePath + name;
                    result.add(fullpath);
                }
            }
            logger.info("[FTP] Total files loaded. struk PDF=" + result.size());
        } finally {
            // PERBAIKAN: Pastikan selalu putus koneksi di block finally
            if (ftp.isConnected()) {
                ftp.logout();
                ftp.disconnect();
            }
        }
        return result;
    }

    // ================================
    // DOWNLOAD FILE
    // ================================
    public void downloadFile(String filePath, OutputStream os) throws Exception {
        // PERBAIKAN: Menggunakan createConnection() agar mematuhi parameter useTls
        FTPClient ftp = createConnection(); 
        try {
            InputStream in = ftp.retrieveFileStream(filePath);
            if (in == null) {
                throw new IOException("File tidak ditemukan di FTP atau koneksi gagal: " + filePath);
            }

            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                os.write(buffer, 0, bytesRead);
            }

            in.close();
            ftp.completePendingCommand();
            logger.info("[FTP] Berhasil download file: " + filePath);

        } finally {
            if (ftp.isConnected()) {
                ftp.logout();
                ftp.disconnect();
            }
        }
    }
}