package com.example.utils;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public class FTPConfig {
    private static final Properties props = new Properties();

    static {
        try(InputStream input = FTPConfig.class.getClassLoader().getResourceAsStream("ftp.properties")) {
            if(input == null){
                throw new RuntimeException("ftp.properties tidak ditemukan!");
            }
            props.load(input);
        } catch(IOException e){
            throw new RuntimeException("Gagal membaca ftp.properties", e);
        }
    }

    public static String getHost()     { return props.getProperty("ftp.host"); }
    public static int getPort()        { return Integer.parseInt(props.getProperty("ftp.port")); }
    public static String getUsername() { return props.getProperty("ftp.username"); }
    public static String getPassword() { return props.getProperty("ftp.password"); }
    public static String getBaseDir()  { return props.getProperty("ftp.base.dir","/"); }
}
