package com.example.service;

import java.sql.*;
import java.util.*;
import java.util.logging.Logger;
import javax.sql.DataSource;

import com.example.utils.HttpStatusHelper;
import com.example.utils.HttpStatusHelper.StatusInfo;
import com.example.utils.LoggerUtil;
import oracle.jdbc.OracleTypes;

public class MonPendingService {
    private DataSource dataSource;
    private static final Logger logger = LoggerUtil.getLogger(MonPendingService.class);

    //1 service koneksi kan dengan DB INIT/SETTING
    public MonPendingService(DataSource dataSource) {
        this.dataSource = dataSource;
    }
    
    //2 service untuk panggil package/sql db "REKAP LAORAN REKON PLN VS BANK"
    public List<Map<String, Object>> getDataMonRkpPending(String vbln_usulan, List<String> pesanMsg, List<Boolean> statusMsg) {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "{call OPHARTDE.VER_MON_LAP.monlap_miv_rkp_mohon_pending( ?, ?, ?)}";
        
        logger.info("Memulai panggilan prosedur Oracle: " + sql);
        logger.info("Parameter vbln_usulan: " + vbln_usulan);        

        try (Connection conn = dataSource.getConnection();
            CallableStatement stmt = conn.prepareCall(sql)) {
            
            // 1. Set Parameter Input dan Register Parameter Output
            stmt.setString(1, vbln_usulan);
            stmt.registerOutParameter(2, OracleTypes.CURSOR); // out_data (SYS_REFCURSOR)
            stmt.registerOutParameter(3, Types.VARCHAR);      // pesan

            // 2. Eksekusi Prosedur
            stmt.execute();
            logger.info("Prosedur Rekap Pending berhasil dieksekusi");

            // 3. Mapping ResultSet ke List Map (ResultSet otomatis close setelah blok ini)
            try (ResultSet rs = (ResultSet) stmt.getObject(2)) {
                if (rs != null) {
                    while (rs.next()) {
                        Map<String, Object> row = new HashMap<>();
                        row.put("URUT", rs.getString("URUT"));
                        row.put("KD_DIST", rs.getString("KD_DIST"));
                        row.put("NAMA_DIST", rs.getString("NAMA_DIST"));
                        row.put("BLTH_USULAN", rs.getString("BLTH_USULAN"));
                        row.put("JML_USULAN", rs.getString("JML_USULAN"));
                        row.put("JML_LBR", rs.getString("JML_LBR"));
                        row.put("RPTAG", rs.getString("RPTAG"));
                        row.put("RPBK", rs.getString("RPBK"));
                        row.put("NAMA_BANK", rs.getString("NAMA_BANK"));
                        row.put("KET_PENDING", rs.getString("KET_PENDING"));
                        
                        result.add(row);
                    }
                }
            } catch (SQLException e) {
                // Skenario: Koneksi aman, tapi gagal saat membaca/mapping data (HTTP 400 atau 500 internal mapping)
                logger.severe("Kesalahan Eksekusi Query/Mapping Parameter: " + e.getMessage());
                StatusInfo badRequestInfo = HttpStatusHelper.getInfo(400);
                pesanMsg.add("400|" + badRequestInfo.getCodeMessage() + " -> " + e.getMessage()); 
                statusMsg.add(false);
                return result; // Langsung return agar tidak mengeksekusi logika success di bawah
            }

            // 4. Ambil Parameter OUT (Dilakukan SETELAH ResultSet close demi keamanan data)
            String pesanDb = stmt.getString(3);
            if (pesanDb != null && !pesanDb.trim().isEmpty()) {
                pesanMsg.add(pesanDb); 
            } else {
                StatusInfo successInfo = HttpStatusHelper.getInfo(200);
                pesanMsg.add("200|" + successInfo.getCodeMessage()); 
            }
            statusMsg.add(true);

        } catch (SQLException e) {
            // Skenario: Gagal koneksi ke database atau error fatal level atas (HTTP 503)
            logger.severe("Kesalahan database (Rekap PLN vs Bank): " + e.getMessage());
            pesanMsg.add("503|Terjadi kesalahan koneksi ke database: " + e.getMessage());
            statusMsg.add(false);
        }

        return result;
    }

    //3 service untuk panggil package/sql db "DETAIL LAORAN REKON PLN VS BANK"
    public List<Map<String, Object>> getDataMonDftPending(int start, int length, String sortBy, String sortDir, String search,
                                                        String vbln_usulan, String vkd_bank, String vkd_dist, 
                                                        List<String> pesanMsg, List<Boolean> statusMsg) {

        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "{call OPHARTDE.VER_MON_LAP.monlap_miv_dft_mohon_pending(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}";
        
        logger.info("Memulai panggilan prosedur Oracle " + sql);
        
        pesanMsg.clear();
        statusMsg.clear();

        try (Connection conn = dataSource.getConnection()) {            
            
            try (CallableStatement stmt = conn.prepareCall(sql)) {
                // 1. Set Parameter Input dan Register Parameter Output
                stmt.setInt(1, start);
                stmt.setInt(2, length);
                stmt.setString(3, sortDir);
                stmt.setString(4, sortBy);
                stmt.setString(5, search);
                stmt.setString(6, vbln_usulan);
                stmt.setString(7, vkd_bank);
                stmt.setString(8, vkd_dist);
                stmt.registerOutParameter(9, OracleTypes.CURSOR);
                stmt.registerOutParameter(10, Types.VARCHAR);

                // 2. Eksekusi Prosedur
                stmt.execute();
                logger.info("Prosedur Detail Pending berhasil dieksekusi");

                // 3. Mapping ResultSet ke List Map (ResultSet otomatis close setelah blok ini)
                try (ResultSet rs = (ResultSet) stmt.getObject(9)) {
                    while (rs.next()) {
                        Map<String, Object> row = new HashMap<>();
                        row.put("BLTH_USULAN", rs.getString("BLTH_USULAN") == null ? "" : rs.getString("BLTH_USULAN"));
                        row.put("KD_DIST", rs.getString("KD_DIST") == null ? "" : rs.getString("KD_DIST"));
                        row.put("NAMA_DIST", rs.getString("NAMA_DIST") == null ? "" : rs.getString("NAMA_DIST"));
                        row.put("UNITAP", rs.getString("UNITAP") == null ? "" : rs.getString("UNITAP"));
                        row.put("NAMA_UNITAP", rs.getString("NAMA_UNITAP") == null ? "" : rs.getString("NAMA_UNITAP"));
                        row.put("UNITUP", rs.getString("UNITUP") == null ? "" : rs.getString("UNITUP"));
                        row.put("NAMA_UNITUP", rs.getString("NAMA_UNITUP") == null ? "" : rs.getString("NAMA_UNITUP"));
                        row.put("NOUSULAN", rs.getString("NOUSULAN") == null ? "" : rs.getString("NOUSULAN"));
                        row.put("TGLUSULAN", rs.getString("TGLUSULAN") == null ? "" : rs.getString("TGLUSULAN"));
                        row.put("IDPEL", rs.getString("IDPEL") == null ? "" : rs.getString("IDPEL"));
                        row.put("BLTH", rs.getString("BLTH") == null ? "" : rs.getString("BLTH"));
                        row.put("STATUS_PENDING", rs.getString("STATUS_PENDING") == null ? "" : rs.getString("STATUS_PENDING"));
                        row.put("RPTAG", rs.getString("RPTAG") == null ? "" : rs.getString("RPTAG"));
                        row.put("RPBK", rs.getString("RPBK") == null ? "" : rs.getString("RPBK"));
                        row.put("TGLBAYAR", rs.getString("TGLBAYAR") == null ? "" : rs.getString("TGLBAYAR"));
                        row.put("USERID", rs.getString("USERID") == null ? "" : rs.getString("USERID"));
                        row.put("KDPROSES", rs.getString("KDPROSES") == null ? "" : rs.getString("KDPROSES"));
                        row.put("USERID_LOCK", rs.getString("USERID_LOCK") == null ? "" : rs.getString("USERID_LOCK"));
                        row.put("STATUS", rs.getString("STATUS") == null ? "" : rs.getString("STATUS"));
                        row.put("KETERANGAN", rs.getString("KETERANGAN") == null ? "" : rs.getString("KETERANGAN"));
                        row.put("VA", rs.getString("VA") == null ? "" : rs.getString("VA"));
                        row.put("SATKER", rs.getString("SATKER") == null ? "" : rs.getString("SATKER"));
                        row.put("KDBANK", rs.getString("KDBANK") == null ? "" : rs.getString("KDBANK"));
                        row.put("NAMA_BANK", rs.getString("NAMA_BANK") == null ? "" : rs.getString("NAMA_BANK"));
                        row.put("TGLINSERT", rs.getString("TGLINSERT") == null ? "" : rs.getString("TGLINSERT"));
                        row.put("IDKIRIM", rs.getString("IDKIRIM") == null ? "" : rs.getString("IDKIRIM"));
                        row.put("ROW_NUMBER", rs.getString("ROW_NUMBER") == null ? "" : rs.getString("ROW_NUMBER"));
                        row.put("TOTAL_COUNT", rs.getString("TOTAL_COUNT") == null ? "" : rs.getString("TOTAL_COUNT"));
                        result.add(row);
                    }
                }

                // AMBIL PESAN DARI OUT PARAMETER DB (JIKA ADA) ATAU DEFAULT 200
                String pesanDb = stmt.getString(10);
                if (pesanDb != null && !pesanDb.trim().isEmpty()) {
                    pesanMsg.add(pesanDb); // Pakai pesan kustom bawaan store procedure jika ada
                } else {
                    StatusInfo successInfo = HttpStatusHelper.getInfo(200);
                    pesanMsg.add(successInfo.getCodeMessage()); // "Berhasil"
                }
                statusMsg.add(true);

            } catch (SQLException e) {
                // SKENARIO 1: KONEKSI AMAN, TAPI QUERY/PARAMETER SALAH (HTTP 400)
                logger.severe("Kesalahan Eksekusi Query/Parameter: " + e.getMessage());
                
                StatusInfo badRequestInfo = HttpStatusHelper.getInfo(400);
                // Anda bisa menggabungkan pesan standar util dengan detail log error asli dari DB
                pesanMsg.add("400|" + badRequestInfo.getCodeMessage() + " -> " + e.getMessage()); 
                statusMsg.add(false);
            }

        } catch (SQLException e) {
            // SKENARIO 2: GAGAL KONEKSI DATABASE (HTTP 503)
            logger.severe("Kesalahan Koneksi Database: " + e.getMessage());     

            // StatusInfo dbDownInfo = HttpStatusHelper.getInfo(503);
            pesanMsg.add("503|" +"Terjadi kesalahan koneksi ke database: " + e.getMessage());
            statusMsg.add(false);
        }

        return result;
    }

    public Map<String, Object> getDataBank(String kdbank) throws SQLException {
        Map<String, Object> result = new HashMap<>();

        try (
            Connection conn = dataSource.getConnection();
            CallableStatement stmt = conn.prepareCall("{call OPHARTDE.VER_MON_LAP.GET_combo_BANK_MIV(?, ?, ?)}")
        ) {
            stmt.setString(1, kdbank);
            stmt.registerOutParameter(2, OracleTypes.CURSOR);
            stmt.registerOutParameter(3, Types.VARCHAR);
            stmt.execute();

            try (ResultSet rs = (ResultSet) stmt.getObject(2)) {
                if (rs.next()) {
                    result.put("KODE_ERP", rs.getString("KODE_ERP"));
                    result.put("KODE_BANK", rs.getString("KODE_BANK"));
                    result.put("NAMA_BANK", rs.getString("NAMA_BANK"));
                    result.put("STATUS", rs.getString("STATUS"));
                }
            }
        }

        return result;
    }

    public Map<String, Object> getDataUnitUPI(String kd_dist) throws SQLException {
        Map<String, Object> result = new HashMap<>();

        try (
            Connection conn = dataSource.getConnection();
            CallableStatement stmt = conn.prepareCall("{call OPHARTDE.VER_MON_LAP.GET_combo_UNITUPI(?, ?, ?)}")
        ) {
            stmt.setString(1, kd_dist);
            stmt.registerOutParameter(2, OracleTypes.CURSOR);
            stmt.registerOutParameter(3, Types.VARCHAR);
            stmt.execute();

            try (ResultSet rs = (ResultSet) stmt.getObject(2)) {
                if (rs.next()) {
                    result.put("KD_DIST", rs.getString("KD_DIST"));
                    result.put("NAMA_DIST", rs.getString("NAMA_DIST"));
                }
            }
        }

        return result;
    }

}
