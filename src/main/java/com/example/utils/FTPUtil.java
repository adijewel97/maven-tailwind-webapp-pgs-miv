package com.example.utils;

import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPFile;

import java.io.OutputStream;     // ← WAJIB ADA!
import java.io.IOException;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;



public class FTPUtil {

    private static final Logger logger = Logger.getLogger(FTPUtil.class.getName());

    private String server;
    private int port;
    private String user;
    private String pass;

    public FTPUtil(String server, int port, String user, String pass) {
        this.server = server;
        this.port = port;
        this.user = user;
        this.pass = pass;
    }

    public List<String> listAllFiles(String remoteDirPath) {
        FTPClient ftpClient = new FTPClient();
        List<String> allFiles = new ArrayList<>();
        try {
            logger.info("Connecting to FTP server " + server + ":" + port);
            ftpClient.connect(server, port);
            ftpClient.login(user, pass);
            ftpClient.enterLocalPassiveMode();

            logger.info("Start traversing folder: " + remoteDirPath);
            traverseFiles(ftpClient, remoteDirPath, allFiles);

        } catch (IOException ex) {
            logger.severe("FTP error: " + ex.getMessage());
            ex.printStackTrace();
        } finally {
            try {
                if (ftpClient.isConnected()) {
                    ftpClient.logout();
                    ftpClient.disconnect();
                    logger.info("Disconnected from FTP server");
                }
            } catch (IOException ex) {
                ex.printStackTrace();
            }
        }
        logger.info("Total files found: " + allFiles.size());
        return allFiles;
    }

    private void traverseFiles(FTPClient ftpClient, String dirPath, List<String> allFiles) throws IOException {
        logger.info("Checking folder: " + dirPath);
        FTPFile[] ftpFiles = ftpClient.listFiles(dirPath);

        for (FTPFile file : ftpFiles) {
            if (file.isDirectory()) {
                if (!file.getName().equals(".") && !file.getName().equals("..")) {
                    traverseFiles(ftpClient, dirPath + "/" + file.getName(), allFiles);
                }
            } else if (file.isFile()) {
                String filePath = dirPath + "/" + file.getName();
                logger.info("Found file: " + filePath);
                allFiles.add(filePath);
            }
        }
    }

    public boolean downloadFile(String remoteFilePath, OutputStream outputStream) {
        FTPClient ftpClient = new FTPClient();

        try {
            logger.info("Connecting to FTP server " + server + ":" + port);
            ftpClient.connect(server, port);
            ftpClient.login(user, pass);
            ftpClient.enterLocalPassiveMode();
            ftpClient.setFileType(FTPClient.BINARY_FILE_TYPE);

            logger.info("Start downloading: " + remoteFilePath);

            boolean success = ftpClient.retrieveFile(remoteFilePath, outputStream);

            ftpClient.logout();
            ftpClient.disconnect();

            return success;

        } catch (IOException ex) {
            logger.severe("FTP download error: " + ex.getMessage());
            return false;
        }
    }


}
