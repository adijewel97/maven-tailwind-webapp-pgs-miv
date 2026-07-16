package com.example.service;

import java.sql.*;
import java.util.*;
import java.util.logging.Logger;
import javax.sql.DataSource;

import com.example.utils.HttpStatusHelper;
import com.example.utils.HttpStatusHelper.StatusInfo;
import com.example.utils.LoggerUtil;
import oracle.jdbc.OracleTypes;

public class MonRekonPerUpiService {
    private DataSource dataSource;
    private static final Logger logger = LoggerUtil.getLogger(MonRekonPerUpiService.class);

    //1 service koneksi kan dengan DB INIT/SETTING
    public MonRekonPerUpiService(DataSource dataSource) {
        this.dataSource = dataSource;
    }
    
    //2 service untuk panggil package/sql db "REKAP LAORAN REKON PLN VS BANK"
    public List<Map<String, Object>> getDataMonRkpPerPerUpi(String vbln_usulan, List<String> pesanMsg, List<Boolean> statusMsg) {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "{call OPHARTDE.VER_MON_LAP.monlap_rkp_mivfalg_plnvsbank_uiw( ?, ?, ?)}";
        
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
            logger.info("Prosedur Rekap Rekon PPLN VS BANK berhasil dieksekusi");

            // 3. Mapping ResultSet ke List Map (ResultSet otomatis close setelah blok ini)
            try (ResultSet rs = (ResultSet) stmt.getObject(2)) {
                if (rs != null) {
                    while (rs.next()) {
                        Map<String, Object> row = new HashMap<>();
                        row.put("KD_DIST", rs.getString("KD_DIST"));
                        row.put("NAMA_DIST", rs.getString("NAMA_DIST"));
                        row.put("URUT", rs.getString("URUT"));
                        row.put("PRODUK", rs.getString("PRODUK"));
                        row.put("BANK", rs.getString("BANK"));
                        row.put("BLN_USULAN", rs.getString("BLN_USULAN"));
                        row.put("PLN_IDPEL", rs.getString("PLN_IDPEL"));
                        row.put("PLN_RPTAG", rs.getString("PLN_RPTAG"));
                        row.put("PLN_LEBAR_LUNAS", rs.getString("PLN_LEBAR_LUNAS"));
                        row.put("PLN_RPTAG_LUNAS", rs.getString("PLN_RPTAG_LUNAS"));
                        row.put("BANK_IDPEL", rs.getString("BANK_IDPEL"));
                        row.put("BANK_RPTAG", rs.getString("BANK_RPTAG"));
                        row.put("SELISIH_RPTAG", rs.getString("SELISIH_RPTAG"));
                        
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
            logger.severe("Kesalahan database M_BPBLPRASURVEY_PROV (Rekap PLN vs Bank): " + e.getMessage());
            pesanMsg.add("503|Terjadi kesalahan koneksi ke database: " + e.getMessage());
            statusMsg.add(false);
        }

        return result;
    }

    //3 service untuk panggil package/sql db "DETAIL LAORAN REKON PLN VS BANK"
    public List<Map<String, Object>> getDataMonDftPerUpi(int start, int length, String sortBy, String sortDir, String search,
                                                        String vbln_usulan, String vkd_bank, String vkd_dist, 
                                                        List<String> pesanMsg, List<Boolean> statusMsg) {

        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "{call OPHARTDE.VER_MON_LAP.monlap_dft_mivfalg_plnvsbank_uiw_pgs(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}";
        
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
                logger.info("Prosedur Detail Rekon PPLN VS BANK berhasil dieksekusi");

                // 3. Mapping ResultSet ke List Map (ResultSet otomatis close setelah blok ini)
                try (ResultSet rs = (ResultSet) stmt.getObject(9)) {
                    while (rs.next()) {
                        Map<String, Object> row = new HashMap<>();
                        row.put("URUT", rs.getString("URUT") == null ? "" : rs.getString("URUT"));
                        row.put("PRODUK", rs.getString("PRODUK") == null ? "" : rs.getString("PRODUK"));
                        row.put("TGLAPPROVE", rs.getString("TGLAPPROVE") == null ? "" : rs.getString("TGLAPPROVE"));
                        row.put("KD_DIST", rs.getString("KD_DIST") == null ? "" : rs.getString("KD_DIST"));
                        row.put("VA", rs.getString("VA") == null ? "" : rs.getString("VA"));
                        row.put("SATKER", rs.getString("SATKER") == null ? "" : rs.getString("SATKER"));
                        row.put("PLN_NOUSULAN", rs.getString("PLN_NOUSULAN") == null ? "" : rs.getString("PLN_NOUSULAN"));
                        row.put("PLN_KDPROSES", rs.getString("PLN_KDPROSES") == null ? "" : rs.getString("PLN_KDPROSES"));
                        row.put("PLN_STATUS", rs.getString("PLN_STATUS") == null ? "" : rs.getString("PLN_STATUS"));
                        row.put("PLN_IDPEL", rs.getString("PLN_IDPEL") == null ? "" : rs.getString("PLN_IDPEL"));
                        row.put("PLN_BLTH", rs.getString("PLN_BLTH") == null ? "" : rs.getString("PLN_BLTH"));
                        row.put("PLN_LUNAS_H0", rs.getString("PLN_LUNAS_H0") == null ? "" : rs.getString("PLN_LUNAS_H0"));
                        row.put("PLN_RPTAG", rs.getString("PLN_RPTAG") == null ? "" : rs.getString("PLN_RPTAG"));
                        row.put("PLN_RPBK", rs.getString("PLN_RPBK") == null ? "" : rs.getString("PLN_RPBK"));
                        row.put("PLN_TGLBAYAR", rs.getString("PLN_TGLBAYAR") == null ? "" : rs.getString("PLN_TGLBAYAR"));
                        row.put("PLN_JAMBAYAR", rs.getString("PLN_JAMBAYAR") == null ? "" : rs.getString("PLN_JAMBAYAR"));
                        row.put("PLN_USERID", rs.getString("PLN_USERID") == null ? "" : rs.getString("PLN_USERID"));
                        row.put("PLN_KDBANK", rs.getString("PLN_KDBANK") == null ? "" : rs.getString("PLN_KDBANK"));
                        row.put("BANK_KETERANGAN", rs.getString("BANK_KETERANGAN") == null ? "" : rs.getString("BANK_KETERANGAN"));
                        row.put("BANK_NOUSULAN", rs.getString("BANK_NOUSULAN") == null ? "" : rs.getString("BANK_NOUSULAN"));
                        row.put("BANK_IDPEL", rs.getString("BANK_IDPEL") == null ? "" : rs.getString("BANK_IDPEL"));
                        row.put("BANK_BLTH", rs.getString("BANK_BLTH") == null ? "" : rs.getString("BANK_BLTH"));
                        row.put("BANK_RPTAG", rs.getString("BANK_RPTAG") == null ? "0" : rs.getString("BANK_RPTAG"));
                        row.put("BANK_RPBK", rs.getString("BANK_RPBK") == null ? "0" : rs.getString("BANK_RPBK"));
                        row.put("BANK_TGLBAYAR", rs.getString("BANK_TGLBAYAR") == null ? "" : rs.getString("BANK_TGLBAYAR"));
                        row.put("BANK_JAMBAYAR", rs.getString("BANK_JAMBAYAR") == null ? "" : rs.getString("BANK_JAMBAYAR"));
                        row.put("BANK_USERID", rs.getString("BANK_USERID") == null ? "" : rs.getString("BANK_USERID"));
                        row.put("BANK_KDBANK", rs.getString("BANK_KDBANK") == null ? "" : rs.getString("BANK_KDBANK"));
                        row.put("SELISIH_RPTAG", rs.getString("SELISIH_RPTAG") == null ? "" : rs.getString("SELISIH_RPTAG"));
                        row.put("SELISIH_BK", rs.getString("SELISIH_BK") == null ? "" : rs.getString("SELISIH_BK"));
                        row.put("KETERANGAN", rs.getString("KETERANGAN") == null ? "" : rs.getString("KETERANGAN"));
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
