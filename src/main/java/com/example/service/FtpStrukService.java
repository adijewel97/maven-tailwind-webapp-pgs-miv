package com.example.service;

import org.apache.commons.net.ftp.FTP;
import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPFile;

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

    private static final Logger logger = Logger.getLogger(FtpStrukService.class.getName());

    public FtpStrukService(String host, int port, String username, String password) {
        this.host = host;
        this.port = port;
        this.username = username;
        this.password = password;
    }

    private FTPClient connect() throws IOException {
        FTPClient ftp = new FTPClient();
        ftp.connect(host, port);
        boolean login = ftp.login(username, password);
        if (!login) {
            throw new IOException("Gagal login ke FTP: " + host);
        }
        ftp.enterLocalPassiveMode();
        ftp.setFileType(FTP.BINARY_FILE_TYPE);
        return ftp;
    }

    // ================================
    // LIST FILES
    // ================================
    public List<String> listStrukFiles(String bank, String swbank, String up3, String blth, String idtrans) 
            throws IOException {

        List<String> result = new ArrayList<>();
        FTPClient ftp = connect();

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

        logger.info("[FTP] Total files loaded. struk PDF=" + result.size() );
        ftp.logout();
        ftp.disconnect();
        return result;
    }

    // ================================
    // DOWNLOAD FILE
    // ================================
    public void downloadFile(String filePath, OutputStream os) throws IOException {
        FTPClient ftp = new FTPClient();
        try {
            ftp.connect(host, port);
            boolean login = ftp.login(username, password);
            if (!login) {
                throw new IOException("Gagal login ke FTP: " + host);
            }

            ftp.enterLocalPassiveMode();
            ftp.setFileType(FTP.BINARY_FILE_TYPE);

            InputStream in = ftp.retrieveFileStream(filePath);
            if (in == null) {
                throw new IOException("File tidak ditemukan di FTP: " + filePath);
            }

            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                os.write(buffer, 0, bytesRead);
            }

            in.close();
            ftp.completePendingCommand();

        } finally {
            if (ftp.isConnected()) {
                ftp.logout();
                ftp.disconnect();
            }
        }
    }
}
