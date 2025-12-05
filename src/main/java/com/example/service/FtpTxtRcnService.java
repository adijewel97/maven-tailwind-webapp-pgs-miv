package com.example.service;

import org.apache.commons.net.ftp.FTP;
import org.apache.commons.net.ftp.FTPClient;

import java.io.IOException;
import java.io.OutputStream;
import java.util.*;
import java.util.logging.Logger;

public class FtpTxtRcnService {

    private String host;
    private int port;
    private String username;
    private String password;

    private static final Logger logger = Logger.getLogger(FtpTxtRcnService.class.getName());

    private static final String[] PRODUK_LIST = {"NTLS", "POSTPAID", "PREPAID"};

    public FtpTxtRcnService(String host, int port, String username, String password) {
        this.host = host;
        this.port = port;
        this.username = username;
        this.password = password;
    }

    public Map<String, List<String>> listFiles(String bank, String swBank, String thbl, String idtrans, String jenis) throws IOException {

        Map<String, List<String>> result = new HashMap<>();
        List<String> listSukses = new ArrayList<>();
        List<String> listGagal  = new ArrayList<>();

        if(jenis == null || (!"TXT".equalsIgnoreCase(jenis) && !"RCN".equalsIgnoreCase(jenis))){
            logger.warning("[FTP] Jenis tidak valid: " + jenis);
            result.put("SUKSES", listSukses);
            result.put("GAGAL", listGagal);
            return result;
        }

        FTPClient ftp = new FTPClient();
        try {
            ftp.connect(host, port);
            boolean login = ftp.login(username, password);
            if(!login) throw new IOException("Gagal login ke FTP");

            logger.info("[FTP] Connected to FTP. Param: bank="+bank+", swBank="+swBank+", thbl="+thbl+", idtrans="+idtrans+", jenis="+jenis);

            for(String produk : PRODUK_LIST){
                String basePath = "/vertikal/" + bank + "/" + swBank + "/" + produk;

                String[] suksesFolders;
                String gagalFolder = basePath + "/gagal";

                if("TXT".equalsIgnoreCase(jenis)){
                    suksesFolders = new String[]{
                            basePath + "/daftar",
                            basePath + "/daftar/proses"  // perbaikan path
                    };
                } else { // RCN
                    suksesFolders = new String[]{
                            basePath + "/lunas",
                            basePath + "/lunas/proses"
                    };
                    gagalFolder = basePath + "/lunas/gagal";
                }

                for(String folder : suksesFolders){
                    List<String> files = listFilesFromFolder(ftp, folder, idtrans, thbl);
                    listSukses.addAll(files);
                }

                listGagal.addAll(listFilesFromFolder(ftp, gagalFolder, idtrans, thbl));
            }

            result.put("SUKSES", listSukses);
            result.put("GAGAL", listGagal);

            logger.info("[FTP] Total files loaded. Sukses=" + listSukses.size() + ", Gagal=" + listGagal.size());

        } finally {
            if(ftp.isConnected()){
                ftp.logout();
                ftp.disconnect();
            }
        }

        return result;
    }

    private List<String> listFilesFromFolder(FTPClient ftp, String folderPath, String idtrans, String thbl) throws IOException {
        List<String> result = new ArrayList<>();
        if(!ftp.changeWorkingDirectory(folderPath)){
            logger.warning("[FTP] Folder tidak ditemukan: " + folderPath);
            return result;
        }

        String[] files = ftp.listNames();
        if(files == null) return result;

        for(String file : files){
            boolean matchThbl = thbl == null || thbl.isEmpty() || file.contains(thbl);
            boolean matchId   = idtrans == null || idtrans.isEmpty() || "*".equals(idtrans) || file.contains(idtrans);
            if(matchThbl && matchId){
                result.add(folderPath + "/" + file);
            }
        }
        return result;
    }

    public boolean downloadFile(String ftpPath, OutputStream outputStream){
        FTPClient ftp = new FTPClient();
        try {
            ftp.connect(host, port);
            ftp.login(username, password);
            ftp.setFileType(FTP.BINARY_FILE_TYPE);
            boolean success = ftp.retrieveFile(ftpPath, outputStream);
            ftp.logout();
            ftp.disconnect();
            return success;
        } catch (Exception e){
            e.printStackTrace();
            try{
                if(ftp.isConnected()){
                    ftp.logout();
                    ftp.disconnect();
                }
            } catch (IOException ex){
                ex.printStackTrace();
            }
            return false;
        }
    }
}
