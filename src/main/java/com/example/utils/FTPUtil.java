package com.example.utils;

import org.apache.commons.net.ftp.FTP;
import org.apache.commons.net.ftp.FTPClient;

import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

public class FTPUtil {

    private static final Logger logger = Logger.getLogger(FTPUtil.class.getName());

    private String server;
    private int port;
    private String user;
    private String pass;

    // === CONSTRUCTOR YANG DIBUTUHKAN ===
    public FTPUtil(String server, int port, String user, String pass) {
        this.server = server;
        this.port = port;
        this.user = user;
        this.pass = pass;
    }

    public List<String> listAllFiles(String remoteDirOrPattern) {
        FTPClient ftp = new FTPClient();
        List<String> result = new ArrayList<>();

        try {
            ftp.connect(server, port);
            ftp.login(user, pass);
            ftp.enterLocalPassiveMode();

            String[] names = ftp.listNames(remoteDirOrPattern);
            if (names != null) {
                for (String n : names) {
                    result.add(n.replace("\\", "/"));
                }
            }

        } catch (Exception e) {
            logger.severe("FTP list error: " + e.getMessage());
        } finally {
            try { ftp.disconnect(); } catch (Exception ignored) {}
        }

        return result;
    }

    public boolean downloadFile(String remoteFilePath, OutputStream outputStream) {
        FTPClient ftp = new FTPClient();
        try {
            ftp.connect(server, port);
            ftp.login(user, pass);
            ftp.enterLocalPassiveMode();
            ftp.setFileType(FTP.BINARY_FILE_TYPE);

            boolean ok = ftp.retrieveFile(remoteFilePath, outputStream);

            try { ftp.disconnect(); } catch (Exception ignored) {}

            return ok;

        } catch (Exception e) {
            logger.severe("FTP download error: " + e.getMessage());
            try { ftp.disconnect(); } catch (Exception ignored) {}
            return false;
        }
    }
}
