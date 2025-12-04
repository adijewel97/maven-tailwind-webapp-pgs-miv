package com.example.service;

import org.apache.commons.net.ftp.FTPClient;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

public class FtpTxtService {

    private final String host;
    private final int port;
    private final String username;
    private final String password;

    private static final Logger logger = Logger.getLogger(FtpTxtService.class.getName());

    private static final String[] PRODUK_LIST = {"NTL", "POSTPAID", "PREPAID"};

    public FtpTxtService(String host, int port, String username, String password) {
        this.host = host;
        this.port = port;
        this.username = username;
        this.password = password;
    }

    /**
     * ====================================================================
     * READ TXT FILES UNTUK CHEK FILE TXT MIV BANK
     * ====================================================================
     */
    public List<String> listTxtFiles(String bank, String swBank, String thbl) throws IOException {

        List<String> hasil = new ArrayList<>();

        FTPClient ftp = new FTPClient();

        try {
            ftp.connect(host, port);
            ftp.login(username, password);
            ftp.enterLocalPassiveMode();

            logger.info("[FTP] Connected to FTP for TXT reading");

            // Loop semua produk: NTL, POSTPAID, PREPAID
            for (String produk : PRODUK_LIST) {

                // Folder sukses
                String pathDaftar = "/vertikal/" + bank + "/" + swBank + "/" + produk + "/daftar/" + thbl;

                // Folder gagal
                String pathGagal = "/vertikal/" + bank + "/" + swBank + "/" + produk + "/daftar/gagal/" + thbl;

                logger.info("[SCAN] Folder Sukses: " + pathDaftar);
                logger.info("[SCAN] Folder Gagal : " + pathGagal);

                // ================================
                // AMBIL FILE SUKSES
                // ================================
                try {
                    String[] suksesList = ftp.listNames(pathDaftar);

                    if (suksesList != null) {
                        for (String f : suksesList) {
                            if (f.contains(thbl) && f.endsWith(".txt")) {
                                hasil.add("SUKSES|" + produk + "|" + f);
                            }
                        }
                    }
                } catch (Exception e) {
                    logger.warning("[WARN] Tidak ada file sukses: " + pathDaftar);
                }

                // ================================
                // AMBIL FILE GAGAL
                // ================================
                try {
                    String[] gagalList = ftp.listNames(pathGagal);

                    if (gagalList != null) {
                        for (String f : gagalList) {
                            if (f.contains(thbl) && f.endsWith(".txt")) {
                                hasil.add("GAGAL|" + produk + "|" + f);
                            }
                        }
                    }
                } catch (Exception e) {
                    logger.warning("[WARN] Tidak ada file gagal: " + pathGagal);
                }
            }

            return hasil;

        } catch (IOException e) {
            logger.severe("[ERROR] FTP listTxtFiles error: " + e.getMessage());
            throw e;

        } finally {
            try {
                ftp.logout();
                ftp.disconnect();
            } catch (IOException ignored) {
            }
        }
    }
}
