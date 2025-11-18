package com.example.service;


import org.apache.commons.net.ftp.FTP;
import org.apache.commons.net.ftp.FTPClient;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

public class FtpService {

    private String server = "10.71.1.177";
    private int port = 21;
    private String user = "rekon";
    private String pass = "rekon";

    /**
     * Download file PDF dari FTP
     */
    public boolean downloadFile(String remoteFilePath, String localFilePath) {
        FTPClient ftpClient = new FTPClient();
        try {
            ftpClient.connect(server, port);
            ftpClient.login(user, pass);
            ftpClient.enterLocalPassiveMode(); // penting jika ada firewall

            ftpClient.setFileType(FTP.BINARY_FILE_TYPE);

            try (OutputStream outputStream = new FileOutputStream(localFilePath)) {
                return ftpClient.retrieveFile(remoteFilePath, outputStream);
            }

        } catch (IOException ex) {
            ex.printStackTrace();
            return false;
        } finally {
            try {
                if (ftpClient.isConnected()) {
                    ftpClient.logout();
                    ftpClient.disconnect();
                }
            } catch (IOException ex) {
                ex.printStackTrace();
            }
        }
    }
}
