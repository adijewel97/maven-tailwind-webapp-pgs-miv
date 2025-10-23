package com.example.service;

import oracle.jdbc.pool.OracleDataSource;

import javax.sql.DataSource;
import java.io.InputStream;
import java.sql.Connection;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DbService {
    private static final Logger logger = Logger.getLogger(DbService.class.getName());
    private DataSource dataSource;

    public DbService() throws Exception {
        this.dataSource = initDataSource();
    }

    private DataSource initDataSource() throws Exception {
        Properties props = new Properties();

        try (InputStream input = getClass().getClassLoader().getResourceAsStream("db.properties")) {
            if (input == null) {
                throw new Exception("File db.properties tidak ditemukan di classpath.");
            }
            props.load(input);
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Gagal membaca file db.properties", e);
            throw e;
        }

        OracleDataSource ods = new OracleDataSource();
        ods.setURL(props.getProperty("db.url"));
        ods.setUser(props.getProperty("db.user"));
        ods.setPassword(props.getProperty("db.password"));

        // ====== OPTIMASI KONEKSI ======
        Properties connProps = new Properties();

        // Matikan Fast Connection Failover / ONS
        connProps.setProperty("oracle.jdbc.fanEnabled", "false");

        // Timeout koneksi & baca
        connProps.setProperty("oracle.net.CONNECT_TIMEOUT", "10000"); // 10 detik konek
        connProps.setProperty("oracle.net.READ_TIMEOUT", "30000");    // 30 detik baca

        // Validasi koneksi (jaga idle connection tetap sehat)
        connProps.setProperty("oracle.jdbc.ReadTimeout", "30000");

        ods.setConnectionProperties(connProps);

        // ====== ENABLE CONNECTION POOLING BAWAAN ORACLE ======
        ods.setImplicitCachingEnabled(true);
        ods.setFastConnectionFailoverEnabled(false); // pastikan ONS tidak dicoba lagi

        return ods;
    }

    public Connection getConnection() throws Exception {
        return dataSource.getConnection();
    }

    public boolean testConnection() {
        try (Connection conn = getConnection()) {
            logger.info("Koneksi ke database berhasil!");
            return true;
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Gagal koneksi ke database", e);
            return false;
        }
    }

    public DataSource getDataSource() {
        return this.dataSource;
    }

    // MAIN METHOD FOR TESTING
    public static void main(String[] args) {
        try {
            DbService dbService = new DbService();
            boolean result = dbService.testConnection();
            if (result) {
                System.out.println("Tes koneksi berhasil.");
            } else {
                System.out.println("Tes koneksi gagal.");
            }
        } catch (Exception e) {
            System.err.println("Terjadi kesalahan saat inisialisasi DbService:");
            e.printStackTrace();
        }
    }
}
