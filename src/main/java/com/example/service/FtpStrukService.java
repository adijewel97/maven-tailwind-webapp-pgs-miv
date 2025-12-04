package com.example.service;

import org.apache.commons.net.ftp.FTP;
import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPFile;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;
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
    public List<String> listStrukFiles(String bank, String swbank, String up3, String blth) throws IOException {

        List<String> result = new ArrayList<>();
        FTPClient ftp = connect();

        String[] produkFolder = {"NTLS", "POSTPAID", "PREPAID"};

        for (String produk : produkFolder) {

            String basePath = "/vertikal/" + bank + "/" + swbank + "/" + produk + "/lunas/struk/";

            logger.info("[SCAN PATH] " + basePath);

            FTPFile[] files = ftp.listFiles(basePath);
            if (files == null) continue;

            for (FTPFile f : files) {
                String name = f.getName();
                if (name.toLowerCase().endsWith(".pdf") && name.contains(blth)) {
                    result.add(basePath + name);
                }
            }
        }

        ftp.logout();
        ftp.disconnect();

        return result;
    }

    // ================================
    // DOWNLOAD FILE
    // ================================
    /**
     * Download file dari FTP dan tulis langsung ke OutputStream.
     *
     * @param filePath Path lengkap file di FTP, misal: /vertikal/2000001/.../file.pdf
     * @param os       OutputStream dari HttpServletResponse
     * @throws IOException jika koneksi FTP gagal atau file tidak ada
     */
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

            logger.info("→ Mengecek file di FTP: " + filePath);
            InputStream in = ftp.retrieveFileStream(filePath);
            if (in == null) {
                throw new IOException("File tidak ditemukan di FTP: " + filePath);
            }

            logger.info("→ Mulai transfer file ke browser...");
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                os.write(buffer, 0, bytesRead);
            }

            in.close();
            ftp.completePendingCommand(); // penting untuk memastikan file selesai ditransfer
            logger.info("→ Download selesai: " + filePath);

        } catch (IOException e) {
            logger.severe("Error download file dari FTP: " + e.getMessage());
            throw e;
        } finally {
            if (ftp.isConnected()) {
                try {
                    ftp.logout();
                    ftp.disconnect();
                } catch (IOException e) {
                    logger.warning("Gagal disconnect FTP: " + e.getMessage());
                }
            }
        }
    }
}
