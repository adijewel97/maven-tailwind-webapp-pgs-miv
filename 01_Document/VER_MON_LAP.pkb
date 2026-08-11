CREATE OR REPLACE PACKAGE BODY OPHARTDE.VER_MON_LAP IS
    --A combo UPI
    PROCEDURE GET_combo_UNITUPI (vkd_dist varchar2, out_cursor out SYS_REFCURSOR, pesan out VARCHAR) IS
        vEmsg varchar2(50) default null;
    BEGIN
        pesan:='Gagal Tampilkan Data '; 
        vEmsg:= 'Gagal Tampilkan Data ';      
        open out_cursor for
                select DISTINCT kd_dist,kd_dist ||' - '|| NAMA_DIST as NAMA_DIST
                from OPHARTDE.VER_MASTER_UNIT x
                where decode(nvl(upper(vkd_dist),'ALL'),'ALL','1',x.kd_dist) =  decode(nvl(upper(vkd_dist),'ALL'),'ALL','1',vkd_dist)
                order by kd_DIST;
        pesan :='Sukses Tampilkan Data Ada';
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           pesan:='Gagal Proses Data Tdak Ada, '||vEmsg||'  '||SQLERRM;
        WHEN OTHERS THEN
           pesan:='Gagal Proses Data ' ||SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;  
    END;
    
    --B combo AP
    PROCEDURE GET_combo_UNITAP (vkd_dist in Varchar2,out_cursor out SYS_REFCURSOR, pesan out VARCHAR) IS
    vEmsg varchar2(50) default null;
    BEGIN
        pesan:='Gagal Tampilkan Data '; 
        vEmsg:= 'Gagal Tampilkan Data ';      
        open out_cursor for
                select '00' kd_dist,null NAMA_DIST,'ALL' UNITAP,'PILIH SEMUA'  NAMA_AREA from dual 
                union  
                select DISTINCT kd_dist,NAMA_DIST,KD_DIST||UNITAP_AP2T UNITAP,  KD_DIST||UNITAP_AP2T||' - '||NAMA_AREA as NAMA_AREA
                from OPHARTDE.VER_MASTER_UNIT
                where kd_dist = vkd_dist;
        pesan :='Sukses Tampilkan Data Ada';
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           pesan:='Gagal Proses Data Tdak Ada, '||vEmsg||'  '||SQLERRM;
        WHEN OTHERS THEN
           pesan:='Gagal Proses Data ' ||SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;  
    END;
  
    --C combo BANK MIV
    PROCEDURE GET_combo_BANK_MIV (vkdbank in Varchar2,out_cursor out SYS_REFCURSOR, pesan out VARCHAR) IS
    vEmsg varchar2(50) default null;
    BEGIN
        pesan:='Gagal Tampilkan Data '; 
        vEmsg:= 'Gagal Tampilkan Data ';      
        open out_cursor for
            select *
            from
            (
                select '0000000' as KODE_ERP, 'ALL' as KODE_BANK, 'PILIH SEMUA' as NAMA_BANK,'1'  STATUS
                from dual
                union
                select DISTINCT KODE_ERP, KODE_BANK, NAMA_BANK, STATUS
                from ophartde.VER_MASTER_BANK
                where STATUS = 1
            ) x
            where decode(nvl(upper(vkdbank),'ALL'),'ALL','1',x.KODE_BANK) =  decode(nvl(upper(vkdbank),'ALL'),'ALL','1',vkdbank);
        pesan :='Sukses Tampilkan Data Ada';
        
    EXCEPTION
          WHEN NO_DATA_FOUND THEN
           pesan:='Gagal Proses Data Tdak Ada, '||vEmsg||'  '||SQLERRM;
        WHEN OTHERS THEN
           pesan:='Gagal Proses Data ' ||SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;  
    END;
    
    -----------------------------------------------------------------------------------------
    --1a) Mon Rekap Rekon MIV/SAKTI PLN vs BANK
    PROCEDURE monlap_rkp_mivfalg_plnvsbank_uiw(vbln_usulan IN NUMBER, out_data out sys_refcursor, pesan out varchar2) is
        vEmsg varchar2(50) default null;
    BEGIN
        vEmsg := 'Gagal Tampilkan Data ';
        pesan := 'Gagal Tampilkan Data ';
        open out_data for
            --------------------------------------------------------------------
            --  REKAP MIV/SAKTI PerDISTRIBUSI/PerWILAYAH (Gabung Produk  TOTAL)
            --------------------------------------------------------------------
            WITH 
            pln_data AS (
                SELECT TO_CHAR(a.tglinsert,'YYYYMMDD HH24:MI') tglapprove, NVL(SUBSTR(a.nousulan,4,2),a.kd_dist) kddist, a.va, a.nousulan, a.idpel, a.blth,
                       CASE WHEN b.suspect IN ('0','2') THEN NVL(b.rptag,0) ELSE 0 END rptag, 
                       CASE WHEN b.suspect IN ('0','2') THEN NVL(b.rpbk,0) ELSE 0 END rpbk,
                       a.kdbank, (b.tglbayar||' '||b.jambayar||' '||b.userid) lunas_H0
                FROM ophartde.ver_temp_data_locking a
                LEFT JOIN olap.h2h b ON a.idpel = b.idpel AND a.blth = b.blth
                WHERE a.kdproses = '2' AND SUBSTR(a.nousulan,9,6) = TO_CHAR(vbln_usulan) AND a.status = '1'
            ),
            bank_data AS (
                SELECT a.va, a.nousulan, a.idpel, a.blth, NVL(a.rptag,0) rptag, NVL(a.rpbk,0) rpbk, a.kdbank
                FROM ophartde.ver_data_locking_bank a
                WHERE SUBSTR(a.nousulan,9,6) = TO_CHAR(vbln_usulan)
            ),
            pln_data_ntl AS (
                SELECT TO_CHAR(a.tglinsert,'YYYYMMDD HH24:MI') tglapprove, NVL(SUBSTR(a.nousulan,4,2),a.kd_dist) kddist, a.va, a.nousulan, a.noreg idpel,
                       CASE WHEN b.suspect IN ('0','2') THEN NVL(b.rptag,0) ELSE 0 END rptag, a.kdbank, (b.tglbayar||' '||b.jambayar||' '||b.userid) lunas_H0
                FROM ophartde.ver_temp_data_locking_ntl a
                LEFT JOIN olap.transaksi_nontaglis b ON a.noreg = b.nomor_registrasi
                WHERE a.kdproses = '2' AND SUBSTR(a.nousulan,9,6) = TO_CHAR(vbln_usulan) AND a.status = '1'
            ),
            bank_data_ntl AS (
                SELECT a.va, a.nousulan, a.noreg idpel, NVL(a.rptag,0) rptag, a.kdbank
                FROM ophartde.ver_data_locking_bank_ntl a
                WHERE SUBSTR(a.nousulan,9,6) = TO_CHAR(vbln_usulan)
            ),
            pln_data_pre AS (
                SELECT (SELECT DISTINCT TO_CHAR(tglinsert,'YYYYMMDD HH24:MI') FROM OPHARTDE.VER_TEMP_DATA_LOCKING_PRE WHERE nousulan = m.nousulan AND ROWNUM = 1) tglapprove,
                       SUBSTR(m.nousulan,4,2) kddist, m.va, m.nousulan, m.idpel,
                       m.rptag, m.kdbank,
                       (SELECT (b.tglbayar||' '||b.jambayar||' '||b.userid) 
                        FROM OLAP.TRANSAKSI_PREPAID b 
                        WHERE m.idpel = b.idpel AND m.rptag = b.rptag AND TO_CHAR(m.tglinsert,'YYYYMMDD') <= b.tglbayar 
                          AND SUBSTR(b.tglbayar,1,6) = TO_CHAR(vbln_usulan) AND b.UNSOLD IS NULL AND b.TGL_REKON IS NOT NULL AND ROWNUM = 1) lunas_H0
                FROM OPHARTDE.VER_TEMP_DATA_LOCKING_PRE m
                WHERE TO_CHAR(tglinsert,'YYYYMM') = TO_CHAR(vbln_usulan)
            ),
            bank_data_pre AS (
                SELECT a.va, a.nousulan, a.idpel, NVL(a.rptag,0) rptag, a.kdbank
                FROM ophartde.ver_data_locking_bank_pre a
                WHERE SUBSTR(a.nousulan,9,6) = TO_CHAR(vbln_usulan)
            ),
            all_matched_data AS (
                SELECT NVL(p.kddist, SUBSTR(b.nousulan,4,2)) as kd_dist, 'POSTPAID' as produk, NVL(p.kdbank, b.kdbank) as kdbank, 
                       SUBSTR(NVL(p.nousulan, b.nousulan), 9, 6) as bln_usulan,
                       p.idpel as pln_idpel, p.rptag as pln_rptag, p.lunas_H0 as pln_lunas_H0, b.idpel as bank_idpel, b.rptag as bank_rptag
                FROM pln_data p 
                FULL JOIN bank_data b ON p.nousulan = b.nousulan AND p.idpel = b.idpel AND p.blth = b.blth    
                UNION ALL    
                SELECT NVL(p.kddist, SUBSTR(b.nousulan,4,2)) as kd_dist, 'NONTAGLIS' as produk, NVL(p.kdbank, b.kdbank) as kdbank, 
                       SUBSTR(NVL(p.nousulan, b.nousulan), 9, 6) as bln_usulan,
                       p.idpel as pln_idpel, p.rptag as pln_rptag, p.lunas_H0 as pln_lunas_H0, b.idpel as bank_idpel, b.rptag as bank_rptag
                FROM pln_data_ntl p 
                FULL JOIN bank_data_ntl b ON p.nousulan = b.nousulan AND p.idpel = b.idpel    
                UNION ALL    
                SELECT NVL(p.kddist, SUBSTR(b.nousulan,4,2)) as kd_dist, 'PREPAID' as produk, NVL(p.kdbank, b.kdbank) as kdbank, 
                       SUBSTR(NVL(p.nousulan, b.nousulan), 9, 6) as bln_usulan,
                       p.idpel as pln_idpel, p.rptag as pln_rptag, p.lunas_H0 as pln_lunas_H0, b.idpel as bank_idpel, b.rptag as bank_rptag
                FROM pln_data_pre p 
                FULL JOIN bank_data_pre b ON p.nousulan = b.nousulan AND p.idpel = b.idpel
            ),
            summary_per_produk AS (
                SELECT 
                    kd_dist,
                    kdbank,
                    bln_usulan,
                    MAX(CASE WHEN produk = 'POSTPAID' AND (pln_idpel IS NOT NULL OR bank_idpel IS NOT NULL) THEN 'POS' ELSE '-' END) as has_pos,
                    MAX(CASE WHEN produk = 'NONTAGLIS' AND (pln_idpel IS NOT NULL OR bank_idpel IS NOT NULL) THEN 'NTL' ELSE '-' END) as has_ntl,
                    MAX(CASE WHEN produk = 'PREPAID' AND (pln_idpel IS NOT NULL OR bank_idpel IS NOT NULL) THEN 'PRE' ELSE '-' END) as has_pre,
                    COUNT(pln_idpel) AS PLN_IDPEL, 
                    SUM(NVL(pln_rptag, 0)) AS PLN_RPTAG,
                    SUM(CASE WHEN pln_lunas_H0 IS NOT NULL THEN 1 ELSE 0 END) AS PLN_LEBAR_LUNAS,
                    SUM(CASE WHEN pln_lunas_H0 IS NOT NULL THEN NVL(pln_rptag, 0) ELSE 0 END) AS PLN_RPTAG_LUNAS,
                    COUNT(bank_idpel) AS BANK_IDPEL, 
                    SUM(NVL(bank_rptag, 0)) AS BANK_RPTAG,
                    SUM(NVL(pln_rptag, 0) - NVL(bank_rptag, 0)) AS SELISIH_RPTAG
                FROM all_matched_data
                GROUP BY kd_dist, kdbank, bln_usulan
            ),
            aggregated_data AS (
                SELECT 
                    1 urut,
                    kd_dist,
                    kdbank,
                    bln_usulan,
                    MAX(has_pos) || '/' || MAX(has_ntl) || '/' || MAX(has_pre) AS produk_gabung,
                    SUM(PLN_IDPEL) AS PLN_IDPEL, 
                    SUM(PLN_RPTAG) AS PLN_RPTAG,
                    SUM(PLN_LEBAR_LUNAS) AS PLN_LEBAR_LUNAS,
                    SUM(PLN_RPTAG_LUNAS) AS PLN_RPTAG_LUNAS,
                    SUM(BANK_IDPEL) AS BANK_IDPEL, 
                    SUM(BANK_RPTAG) AS BANK_RPTAG,
                    SUM(SELISIH_RPTAG) AS SELISIH_RPTAG,
                    GROUPING(kd_dist) as grp_dist,
                    GROUPING(kdbank) as grp_bank
                FROM summary_per_produk
                GROUP BY ROLLUP(kd_dist, kdbank, bln_usulan)
            )
            -- TAHAP 3 OPTIMASI: Menggunakan LEFT JOIN menggantikan Subquery Skalar
            SELECT 
                CASE WHEN a.grp_dist = 1 THEN '' ELSE NVL(a.kd_dist, '') END AS KD_DIST,
                CASE 
                    WHEN a.grp_dist = 1 THEN 'TOTAL'
                    WHEN a.kd_dist = '00' THEN 'SAKTI'
                    ELSE NVL(d.NAMA_DIST, 'TIDAK DIKETAHUI')
                END AS NAMA_DIST,
                CASE WHEN a.grp_dist = 1 THEN 5 ELSE 1 END as urut,
                CASE WHEN a.grp_dist = 1 THEN 'POS/NTL/PRE' ELSE a.produk_gabung END AS PRODUK,
                CASE 
                    WHEN a.grp_dist = 1 THEN ''
                    ELSE a.kdbank || '-' || NVL(b.NAMA_BANK, '')
                END AS BANK,
                CASE WHEN a.grp_dist = 1 THEN '' ELSE NVL(a.bln_usulan, TO_CHAR(bln_usulan)) END AS BLN_USULAN,
                a.PLN_IDPEL, 
                a.PLN_RPTAG,
                a.PLN_LEBAR_LUNAS,
                a.PLN_RPTAG_LUNAS,
                a.BANK_IDPEL, 
                a.BANK_RPTAG,
                a.SELISIH_RPTAG
            FROM aggregated_data a
            LEFT JOIN OLAP.MASTER_DISTRIBUSI d ON a.kd_dist = d.KD_DIST
            LEFT JOIN OPHARTDE.VER_MASTER_BANK b ON a.kdbank = b.KODE_BANK
            WHERE (a.grp_dist = 0 AND a.grp_bank = 0 AND a.bln_usulan IS NOT NULL) OR a.grp_dist = 1
            ORDER BY a.kd_dist ASC, a.kdbank ASC;
            
        pesan := 'Sukses tampilkan data.';
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           pesan:='Gagal Tampilkan Data Tdak Ada, '||vEmsg||'  '||SQLERRM;
        WHEN OTHERS THEN
           pesan:='Gagal Tampilkan Data ' ||SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; 
    END;
    
    --1b) Mon Daftar Rekon MIV/SAKTI PLN vs BANK                   
    PROCEDURE monlap_dft_mivfalg_plnvsbank_uiw_pgs(
                    in_start         in number,
                    in_lenght        in number,
                    in_sort_by       in varchar2,
                    in_sort_dir      in varchar2,
                    in_search        in varchar2,
                    vbln_usulan IN NUMBER, vkdbank in VARCHAR, vkd_dist in VARCHAR, out_data out sys_refcursor, pesan out varchar2) is
        vEmsg varchar2(50) default null;
    BEGIN
        vEmsg := 'Gagal Tampilkan Data ';
        pesan := 'Gagal Tampilkan Data ';
        open out_data for
            --------------------------------------------------------------------
            --  DETAIL MIV/SAKTI PerDISTRIBUSI/PerWILAYAH 
            --------------------------------------------------------------------
            WITH pln_data AS (
                SELECT to_char(a.tglinsert,'YYYYMMDD HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist, 'pln_data' proses, a.va, 
                       a.nousulan, a.kdproses, a.status, a.idpel, a.blth, c.nama,
                       nvl(b.rptag,0) rptag, nvl(b.rpbk,0) rpbk, b.tglbayar, b.jambayar, b.userid, a.kdbank, a.satker, 
                       (b.tglbayar||'  '||b.jambayar||'  '||b.userid) lunas_H0
                FROM ophartde.ver_temp_data_locking a
                LEFT JOIN plngatepost.dpp c ON a.idpel = c.idpel AND a.blth = c.blth
                LEFT JOIN olap.h2h b ON a.idpel = b.idpel AND a.blth = b.blth
                WHERE a.kdproses = '2'
                  AND a.status = '1'
                  AND a.kdbank = vkdbank
                  AND substr(a.nousulan,9,6) = vbln_usulan
                  AND (b.suspect IN ('0','2') OR b.suspect IS NULL)
            ),
            bank_data AS (
                SELECT 'bank_data' proses, a.va, a.nousulan, '2' kdproses, '1' status, a.idpel, a.blth,
                       nvl(a.rptag,0) rptag, nvl(a.rpbk,0) rpbk, a.tglbayar, a.jambayar, a.userid, a.kdbank
                FROM ophartde.ver_data_locking_bank a
                WHERE a.kdbank = vkdbank
                  AND substr(a.nousulan,9,6) = vbln_usulan
            ),
            pln_data_ntl AS (
                SELECT to_char(a.tglinsert,'YYYYMMDD  HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist, 'pln_data' proses, a.va, 
                       a.nousulan, a.kdproses, a.status, a.noreg idpel, null blth, B.NAMA,
                       nvl(b.rptag,0) rptag, 0 rpbk, b.tglbayar, b.jambayar, b.userid, a.kdbank, a.satker, 
                       (b.tglbayar||' '||b.jambayar||' '||b.userid) lunas_H0
                FROM ophartde.ver_temp_data_locking_ntl a
                LEFT JOIN olap.transaksi_nontaglis b ON a.noreg = b.nomor_registrasi
                WHERE a.kdproses = '2'
                  AND a.status = '1'
                  AND a.kdbank = vkdbank
                  AND substr(a.nousulan,9,6) = vbln_usulan
                  AND (b.suspect IN ('0','2') OR b.suspect IS NULL)
            ),
            bank_data_ntl AS (
                SELECT 'bank_data' proses, a.va, a.nousulan, '2' kdproses, '1' status, a.noreg idpel, null blth,
                       nvl(a.rptag,0) rptag, 0 rpbk, a.tglbayar, a.jambayar, a.userid, a.kdbank
                FROM ophartde.ver_data_locking_bank_ntl a
                WHERE a.kdbank = vkdbank
                  AND substr(a.nousulan,9,6) = vbln_usulan
            ),
            pln_data_pre AS (
                SELECT to_char(a.tglinsert,'YYYYMMDD  HH24:MI') tglapprove, substr(a.nousulan,4,2) kddist, 'pln_data_pre' proses, a.va, 
                       a.nousulan, '2' kdproses, a.status, a.idpel, null blth, B.NAMA,
                       nvl(a.rptag,0) rptag, 0 rpbk, b.tglbayar, b.jambayar, b.userid, a.kdbank, a.satker,
                       CASE WHEN b.tglbayar IS NOT NULL THEN (b.tglbayar||' '||b.jambayar||' '||b.userid) ELSE NULL END lunas_H0
                FROM OPHARTDE.VER_TEMP_DATA_LOCKING_PRE a
                LEFT JOIN OLAP.TRANSAKSI_PREPAID b ON a.idpel = b.idpel 
                     AND a.rptag = b.rptag 
                     AND to_char(a.tglinsert,'YYYYMMDD') <= b.tglbayar
                     AND substr(b.tglbayar,1,6) = vbln_usulan
                     AND b.UNSOLD IS NULL 
                     AND b.TGL_REKON IS NOT NULL
                WHERE to_char(a.tglinsert,'YYYYMM') = vbln_usulan
                  AND substr(a.nousulan,4,2) = vkd_dist
                  AND a.kdbank = vkdbank
            ),
            bank_data_pre AS (
                SELECT 'bank_data' proses, a.va, a.nousulan, '2' kdproses, '1' status, a.idpel, null blth,
                       nvl(a.rptag,0) rptag, 0 rpbk, a.tglbayar, a.jambayar, a.userid, a.kdbank
                FROM ophartde.ver_data_locking_bank_pre a
                WHERE a.kdbank = vkdbank
                  AND substr(a.nousulan,9,6) = vbln_usulan
            ),
            all_products AS (
                -- 1. POSTPAID
                SELECT 1 urut, 'POSTPAID' produk, nvl(a.tglapprove, b.tglbayar) tglapprove, nvl(a.kddist, substr(b.nousulan,4,2)) kd_dist, nvl(a.va, b.va) va, a.satker,
                       a.nousulan pln_nousulan, a.kdproses pln_kdproses, a.status pln_status, a.idpel pln_idpel, a.blth pln_blth, a.nama pln_nama, 
                       a.lunas_H0 pln_lunas_H0,
                       nvl(a.rptag,0) pln_rptag, nvl(a.rpbk,0) pln_rpbk, a.tglbayar pln_tglbayar, a.jambayar pln_jambayar, a.userid pln_userid, a.kdbank pln_kdbank,
                       b.proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                       nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar, b.jambayar bank_jambayar, b.userid bank_userid, b.kdbank bank_kdbank
                FROM pln_data a
                FULL OUTER JOIN bank_data b ON a.idpel = b.idpel AND a.blth = b.blth    
                UNION ALL    
                -- 2. NONTAGLIS
                SELECT 2 urut, 'NONTAGLIS' produk, nvl(a.tglapprove, b.tglbayar) tglapprove, nvl(a.kddist, substr(b.nousulan,4,2)) kd_dist, nvl(a.va, b.va) va, a.satker,
                       a.nousulan pln_nousulan, a.kdproses pln_kdproses, a.status pln_status, a.idpel pln_idpel, a.blth pln_blth, a.nama pln_nama, 
                       a.lunas_H0 pln_lunas_H0,
                       nvl(a.rptag,0) pln_rptag, 0 pln_rpbk, a.tglbayar pln_tglbayar, a.jambayar pln_jambayar, a.userid pln_userid, a.kdbank pln_kdbank,
                       b.proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                       nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar, b.jambayar bank_jambayar, b.userid bank_userid, b.kdbank bank_kdbank
                FROM pln_data_ntl a
                FULL OUTER JOIN bank_data_ntl b ON a.idpel = b.idpel    
                UNION ALL    
                -- 3. PREPAID
                SELECT 3 urut, 'PREPAID' produk, nvl(a.tglapprove, b.tglbayar) tglapprove, nvl(a.kddist, substr(b.nousulan,4,2)) kd_dist, nvl(a.va, b.va) va, a.satker,
                       a.nousulan pln_nousulan, a.kdproses pln_kdproses, a.status pln_status, a.idpel pln_idpel, a.blth pln_blth, a.nama pln_nama, 
                       a.lunas_H0 pln_lunas_H0,
                       nvl(a.rptag,0) pln_rptag, 0 pln_rpbk, a.tglbayar pln_tglbayar, a.jambayar pln_jambayar, a.userid pln_userid, a.kdbank pln_kdbank,
                       b.proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                       nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar, b.jambayar bank_jambayar, b.userid bank_userid, b.kdbank bank_kdbank
                FROM pln_data_pre a
                FULL OUTER JOIN bank_data_pre b ON a.idpel = b.idpel
            ),
            processed_data AS (
                SELECT x.*,
                       (nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) selisih_rptag,
                       (nvl(x.pln_rpbk,0) - nvl(x.bank_rpbk,0)) selisih_bk,
                       CASE
                            WHEN (nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0) = 0) AND (pln_idpel = bank_idpel) AND (nvl(pln_blth,'X') = nvl(bank_blth,'X')) THEN ''
                            WHEN pln_idpel IS NULL AND bank_idpel IS NOT NULL THEN 'selisih - data usulan pln (tidak ada), data pelunasan bank (ada)'
                            WHEN pln_idpel IS NOT NULL AND pln_tglbayar IS NULL AND bank_idpel IS NULL THEN 'selisih - data usulan pln (ada)/tidak lunas, data pelunasan bank (tidak ada)/tidak lunas (Belum Flag Bank/belum rekon)'
                            WHEN (pln_idpel IS NOT NULL AND bank_idpel IS NOT NULL) AND (pln_tglbayar IS NULL AND bank_tglbayar IS NOT NULL) THEN 'selisih - data usulan pln (ada)/tidak lunas , data pelunasan bank (ada)/lunas (Chek Reversal Sukses Dijawab PLN)'
                            WHEN (nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0) > 0) AND (substr(pln_userid,1,3) = pln_kdbank) THEN 'selisih - data usulan pln (ada)/lunas , data pelunasan bank (Tidak ada)/Tidak lunas (Konfirmasi/Log Bank/Belum Rekon)'
                            WHEN (nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0) > 0) AND (substr(pln_userid,1,3) <> pln_kdbank) AND (bank_tglbayar IS NULL) THEN 'selisih - data usulan pln (ada)/lunas (ppob/bukan miv), data pelunasan bank (Tidak ada)/Tidak lunas'
                            WHEN (nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0) > 0) AND (substr(pln_userid,1,3) <> pln_kdbank) AND (bank_tglbayar IS NOT NULL) THEN 'selisih - data usulan pln (ada)/lunas (Bank Lain), data pelunasan bank (ada)/lunas (Konfirmasi/Log Bank)'
                            ELSE 'selisih - belum teridentifikasi'
                       END AS keterangan
                FROM all_products x
                WHERE kd_dist = vkd_dist
                  AND (
                      in_search IS NULL OR
                      to_char(pln_idpel) LIKE '%' || in_search || '%' OR
                      to_char(bank_idpel) LIKE '%' || in_search || '%' OR
                      lower(pln_nousulan) LIKE '%' || lower(in_search) || '%' OR
                      lower(tglapprove) LIKE '%' || lower(in_search) || '%' OR
                      lower(va) LIKE '%' || lower(in_search) || '%' OR
                      lower(satker) LIKE '%' || lower(in_search) || '%' OR
                      lower(bank_nousulan) LIKE '%' || lower(in_search) || '%' OR
                      lower(bank_userid) LIKE '%' || lower(in_search) || '%' 
                  )
            )
            SELECT *
            FROM (
                SELECT 
                    p.*,
                    ROW_NUMBER() OVER (
                        ORDER BY 
                            p.urut ASC, 
                            p.pln_nousulan ASC, 
                            p.pln_idpel ASC, 
                            p.pln_blth DESC,
                            CASE WHEN in_sort_by = 'KD_DIST' AND in_sort_dir = 'ASC'  THEN p.kd_dist END ASC,
                            CASE WHEN in_sort_by = 'KD_DIST' AND in_sort_dir = 'DESC' THEN p.kd_dist END DESC
                    ) AS ROW_NUMBER,
                    COUNT(*) OVER () AS TOTAL_COUNT
                FROM processed_data p
            )
            ORDER BY ROW_NUMBER
            OFFSET ((in_start - 1) * in_lenght) ROWS
            FETCH NEXT in_lenght ROWS ONLY;
                      
        pesan := 'Sukses tampilkan data.';
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           pesan:='Gagal Tampilkan Data Tdak Ada, '||vEmsg||'  '||SQLERRM;
        WHEN OTHERS THEN
           pesan:='Gagal Tampilkan Data ' ||SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; 
    END;
    
    --2a) Mon Rekap PERMOHONAN PENDING MIV PLN : AP2T vs P2APST
    PROCEDURE monlap_miv_rkp_mohon_pending(vbln_usulan IN NUMBER,  out_cursor out SYS_REFCURSOR, pesan out VARCHAR) as
        vEmsg varchar2(50) default null;
    BEGIN
          
        vEmsg := 'Mohon Pending MIV';
        pesan := 'Gagal Tampilkan Data ';
        open out_cursor for
            --2a) Rekap Data Permohonan Pending MIV
            WITH DATA_TRANSAKSI AS (
                -- Subquery 1: Bagian SAKTI
                SELECT 
                    '00' AS KD_DIST, 
                    'SAKTI' AS NAMA_DIST, 
                    NVL(TO_CHAR(a.TGLINSERT, 'YYYYMM'), vbln_usulan) AS BLTH_USULAN, 
                    a.ID_USUL as NOUSULAN, 
                    a.IDPEL, 
                    b.RPTAG,  
                    OLAP.HITUNGBK(TO_CHAR(SYSDATE,'ddmmyyyy'), B.BLTH, B.TGLJTTEMPO, B.RPBK1, B.RPBK2, B.RPBK3) as RPBK,
                    a.KDBANK, 
                    DECODE(b.PRAQTIS, 0, 'PENDING', 'UNPENDING') AS KET_PENDING
                FROM OPHARTDE.VER_TEMP_DATA_LOCKING_SAKTI a
                LEFT JOIN PLNGATEPOST.DPP b ON a.IDPEL = b.IDPEL AND a.BLTH = b.BLTH
                WHERE a.TGLINSERT >= TO_DATE(vbln_usulan, 'YYYYMM')
                  AND a.TGLINSERT < ADD_MONTHS(TO_DATE(vbln_usulan, 'YYYYMM'), 1)
                  AND a.KDPROSES = '1'
                  -- Pengecekan 1: Pastikan belum diproses (2 atau 3) di tabel SAKTI itu sendiri
                  AND NOT EXISTS 
                  (
                      SELECT 1 
                      FROM OPHARTDE.VER_TEMP_DATA_LOCKING_SAKTI c 
                      WHERE c.KDPROSES in ('2', '3')
                        AND c.ID_USUL = a.ID_USUL AND c.idpel = a.idpel AND c.blth = a.blth
                  )
                  -- Pengecekan 2 (Pemisahan UNION): Cek ke tabel Temp biasa (POS00SKT...)
                  -- Menggunakan LIKE atau substring jika NOUSULAN di temp biasa polanya dinamis
                  AND NOT EXISTS
                  (
                      SELECT 1 
                      FROM OPHARTDE.VER_TEMP_DATA_LOCKING d
                      WHERE d.KDPROSES in ('1', '2', '3')
                        AND d.idpel = a.idpel AND d.blth = a.blth
                        AND d.NOUSULAN LIKE 'POS00SKT%'
                  )
                UNION ALL
                -- Subquery 2: Bagian Non-SAKTI
                SELECT 
                    decode(substr(a.NOUSULAN,4,2), '00', '00', a.KD_DIST) as KD_DIST, 
                    decode(substr(a.NOUSULAN,4,2), '00', 'SAKTI-MIV', x.NAMA_DIST) as NAMA_DIST, 
                    NVL(TO_CHAR(a.TGLINSERT, 'YYYYMM'), vbln_usulan) AS BLTH_USULAN, 
                    a.NOUSULAN, 
                    a.IDPEL, 
                    b.RPTAG,  
                    OLAP.HITUNGBK(TO_CHAR(SYSDATE,'ddmmyyyy'), B.BLTH, B.TGLJTTEMPO, B.RPBK1, B.RPBK2, B.RPBK3) as RPBK,
                    a.KDBANK, 
                    DECODE(b.PRAQTIS, 0, 'PENDING', 'UNPENDING') AS KET_PENDING
                FROM OPHARTDE.VER_TEMP_DATA_LOCKING a
                LEFT JOIN OLAP.MASTER_DISTRIBUSI X ON a.KD_DIST = X.KD_DIST
                LEFT JOIN PLNGATEPOST.DPP b ON a.IDPEL = b.IDPEL AND a.BLTH = b.BLTH
                WHERE a.TGLINSERT >= TO_DATE(vbln_usulan, 'YYYYMM')
                  AND a.TGLINSERT < ADD_MONTHS(TO_DATE(vbln_usulan, 'YYYYMM'), 1)
                  AND a.KDPROSES = '1'
                  AND NOT EXISTS 
                  (
                      SELECT 1 
                      FROM OPHARTDE.VER_TEMP_DATA_LOCKING c 
                      WHERE c.KDPROSES in ('2', '3')
                        AND c.NOUSULAN = a.NOUSULAN AND c.idpel = a.idpel AND c.blth = a.blth
                  )
            ),
            DATA_REKAP AS (
                SELECT 
                    KD_DIST, 
                    NAMA_DIST, 
                    BLTH_USULAN, 
                    COUNT(DISTINCT NOUSULAN) AS JML_USULAN, 
                    COUNT(IDPEL) AS JML_LBR,
                    SUM(RPTAG) AS RPTAG,
                    SUM(RPBK) AS RPBK,
                    KDBANK, 
                    KET_PENDING
                FROM DATA_TRANSAKSI
                GROUP BY KD_DIST, NAMA_DIST, BLTH_USULAN, KDBANK, KET_PENDING
            ),
            DATA_REKAP_WITH_BANK AS (
                SELECT 
                    r.KD_DIST, r.NAMA_DIST, r.BLTH_USULAN, r.JML_USULAN, r.JML_LBR, r.RPTAG, r.RPBK, r.KDBANK, r.KET_PENDING,
                    CASE WHEN r.KDBANK IS NULL THEN ''
                         ELSE r.KDBANK || ' - ' || mb.NAMA_BANK 
                    END AS NAMA_BANK
                FROM DATA_REKAP r
                LEFT JOIN OPHARTDE.VER_MASTER_BANK mb ON r.KDBANK = mb.KODE_BANK
            )
            -- 1) Tampilkan Data Rekap Akhir
            SELECT 
                1 AS URUT, KD_DIST, NAMA_DIST, BLTH_USULAN, 
                JML_USULAN, JML_LBR, RPTAG, RPBK, NAMA_BANK, KET_PENDING
            FROM DATA_REKAP_WITH_BANK
            UNION ALL
            -- 2) Tampilkan Baris Total
            SELECT 
                5 AS URUT, '' AS KD_DIST, '' AS NAMA_DIST, 'TOTAL' AS BLTH_USULAN, 
                SUM(JML_USULAN) AS JML_USULAN, SUM(JML_LBR) AS JML_LBR, 
                SUM(NVL(RPTAG,0)) as RPTAG, SUM(NVL(RPBK,0)) RPBK, '' AS NAMA_BANK, '' AS KET_PENDING
            FROM DATA_REKAP_WITH_BANK
            ORDER BY URUT, KD_DIST, KET_PENDING;
            
        pesan :='Sukses Tampilkan Data.';
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            pesan:='Gagal Proses Data Tdak Ada, '||vEmsg||'  '||SQLERRM;
        WHEN OTHERS THEN
            pesan:='Gagal Proses Data ' ||SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;          
    END;
    
    --2b) on Daftar PERMOHONAN PENDING MIV PLN : AP2T vs P2APST
    PROCEDURE monlap_miv_dft_mohon_pending(
        in_start    IN NUMBER,
        in_length   IN NUMBER,
        in_sort_by  IN VARCHAR2,
        in_sort_dir IN VARCHAR2,
        in_search   IN VARCHAR2,
        vbln_usulan IN NUMBER, 
        vkdbank     IN VARCHAR2, 
        vkd_dist    IN VARCHAR2, 
        vket_pending IN VARCHAR2, 
        out_cursor  OUT SYS_REFCURSOR, 
        pesan       OUT VARCHAR2
    ) AS
        vEmsg VARCHAR2(50) DEFAULT NULL;
    BEGIN
        vEmsg := 'Mohon Pending MIV';
        pesan := 'Gagal Tampilkan Data';

        OPEN out_cursor FOR
            --2b) monlap_miv_dft_mohon_pending -- Menapilkan daftar per prob/bank pengaujuan pending dari AP2T ke P2APST
            WITH v_params AS 
            (
                -- Pre-calculate variabel tanggal, string, dan offset pagination
                SELECT 
                    TO_CHAR(vbln_usulan) AS BLN_STR,
                    TO_DATE(TO_CHAR(vbln_usulan), 'YYYYMM') AS BLN_DT,
                    -- Kalkulasi batas baris berdasarkan nomor halaman (:in_start) dan ukuran halaman (:in_length)
                    ((NVL(in_start, 1) - 1) * NVL(in_length, 10)) + 1 AS START_ROW,
                     (NVL(in_start, 1) *      NVL(in_length, 10)) AS END_ROW
                FROM DUAL
            ),
            v_raw_data AS
            (
                -- 1. Subquery SAKTI
                SELECT /*+ INDEX(a) INDEX(b) */ 
                    NVL(TO_CHAR(a.TGLINSERT, 'YYYYMM'), p.BLN_STR) AS BLTH_USULAN,
                    '00' AS KD_DIST, 
                    b.unitup, 
                    a.ID_USUL AS NOUSULAN, 
                    a.BLTH_USUL AS TGLUSULAN, 
                    a.IDPEL, 
                    a.BLTH,
                    b.NAMA, 
                    b.RPTAG, 
                    b.TGLJTTEMPO, b.RPBK1, b.RPBK2, b.RPBK3,
                    b.TGLBAYAR,
                    'SYSTEM' AS USERID, 
                    a.KDPROSES, 
                    a.USERID_LOCK, 
                    a.STATUS, 
                    a.KETERANGAN, 
                    a.VA, 
                    a.SATKER, 
                    a.KDBANK, 
                    a.TGLINSERT, 
                    a.IDKIRIM,
                    DECODE(b.PRAQTIS, 0, 'PENDING', 'UNPENDING') AS KET_PENDING
                FROM OPHARTDE.VER_TEMP_DATA_LOCKING_SAKTI a
                CROSS JOIN v_params p
                INNER JOIN PLNGATEPOST.DPP b 
                    ON a.IDPEL = b.IDPEL AND a.BLTH = b.BLTH
                WHERE a.TGLINSERT   >= p.BLN_DT
                  AND a.TGLINSERT   < ADD_MONTHS(p.BLN_DT, 1)
                  AND a.KDPROSES    = '1'
                  AND b.PRAQTIS     = DECODE(vket_pending,'PENDING',0,1)
                  AND '00'          = vkd_dist
                  AND (a.KDBANK     = vkdbank OR (vkdbank IS NULL AND a.KDBANK IS NULL))
                  AND NOT EXISTS 
                  (
                    SELECT 1 
                    FROM OPHARTDE.VER_TEMP_DATA_LOCKING_SAKTI c 
                    WHERE c.KDPROSES IN ('2', '3')
                      AND c.ID_USUL = a.ID_USUL
                      AND c.idpel   = a.idpel
                      AND c.blth    = a.blth
                  )
                  AND NOT EXISTS
                  (
                    SELECT 1 
                    FROM OPHARTDE.VER_TEMP_DATA_LOCKING d
                    WHERE d.idpel = a.idpel 
                      AND d.blth  = a.blth
                      AND d.NOUSULAN LIKE 'POS00SKT%'
                  )     
                UNION ALL      
                -- 2. Subquery NON-SAKTI
                SELECT /*+ INDEX(a) INDEX(b) */ 
                    NVL(TO_CHAR(a.TGLINSERT, 'YYYYMM'), p.BLN_STR) AS BLTH_USULAN,
                    DECODE(SUBSTR(a.NOUSULAN, 4, 2), '00', '00', a.KD_DIST) AS KD_DIST, 
                    b.unitup, 
                    a.NOUSULAN, 
                    a.TGLUSULAN, 
                    a.IDPEL, 
                    a.BLTH, 
                    b.NAMA,
                    b.RPTAG, 
                    b.TGLJTTEMPO, b.RPBK1, b.RPBK2, b.RPBK3,
                    b.TGLBAYAR,
                    a.USERID, 
                    a.KDPROSES, 
                    a.USERID_LOCK, 
                    a.STATUS, 
                    a.KETERANGAN, 
                    a.VA, 
                    a.SATKER, 
                    a.KDBANK, 
                    a.TGLINSERT, 
                    a.IDKIRIM,
                    DECODE(b.PRAQTIS, 0, 'PENDING', 'UNPENDING') AS KET_PENDING
                FROM OPHARTDE.VER_TEMP_DATA_LOCKING a
                CROSS JOIN v_params p
                INNER JOIN PLNGATEPOST.DPP b 
                    ON a.IDPEL = b.IDPEL AND a.BLTH = b.BLTH
                WHERE a.TGLINSERT   >= p.BLN_DT
                  AND a.TGLINSERT   < ADD_MONTHS(p.BLN_DT, 1)
                  AND a.KDPROSES    = '1' 
                  AND a.KD_DIST     = vkd_dist
                  AND a.NOUSULAN LIKE 'POS' ||     vkd_dist || '%'
                  AND (a.KDBANK     = vkdbank OR (vkdbank IS NULL AND a.KDBANK IS NULL))
                  AND  b.PRAQTIS    = DECODE(vket_pending,'PENDING',0,1)
                  AND NOT EXISTS 
                  (
                      SELECT 1 
                      FROM OPHARTDE.VER_TEMP_DATA_LOCKING c 
                      WHERE c.KDPROSES IN ('2', '3')
                        AND c.NOUSULAN = a.NOUSULAN
                        AND c.idpel    = a.idpel
                        AND c.blth     = a.blth
                  )
            ),
            v_core_data AS
            (
                SELECT 
                    Y.BLTH_USULAN,
                    Y.KD_DIST, 
                    DECODE(SUBSTR(Y.NOUSULAN, 4, 2), '00', 'SAKTI-MIV', DECODE(Y.KD_DIST, '00', 'SAKTI', X.NAMA_DIST)) AS NAMA_DIST,
                    (U.KD_DIST || U.UNITAP_AP2T) AS UNITAP,
                    U.NAMA_AREA AS NAMA_UNITAP,
                    Y.UNITUP, 
                    U.NAMA_UNIT AS NAMA_UNITUP,
                    Y.NOUSULAN, Y.TGLUSULAN, Y.IDPEL, Y.BLTH, Y.NAMA,
                    Y.KET_PENDING AS STATUS_PENDING, 
                    Y.RPTAG, 
                    Y.TGLJTTEMPO, Y.RPBK1, Y.RPBK2, Y.RPBK3,
                    Y.TGLBAYAR,
                    Y.USERID, Y.KDPROSES, Y.USERID_LOCK, Y.STATUS, Y.KETERANGAN, 
                    Y.VA, Y.SATKER, 
                    Y.KDBANK, 
                    B.NAMA_BANK,
                    Y.TGLINSERT, Y.IDKIRIM    
                FROM v_raw_data Y
                CROSS JOIN v_params p
                LEFT JOIN OLAP.MASTER_DISTRIBUSI X ON Y.KD_DIST = X.KD_DIST
                LEFT JOIN OPHARTDE.VER_MASTER_UNIT U ON Y.UNITUP = U.UNITUP
                LEFT JOIN OPHARTDE.VER_MASTER_BANK B ON Y.KDBANK = B.KODE_BANK
                WHERE Y.BLTH_USULAN = p.BLN_STR
            ),
            v_paged_data AS
            (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        ORDER BY 
                            CASE WHEN in_sort_by = 'KD_DIST' AND UPPER(in_sort_dir) = 'ASC'  THEN x.KD_DIST END ASC NULLS LAST,
                            CASE WHEN in_sort_by = 'KD_DIST' AND UPPER(in_sort_dir) = 'DESC' THEN x.KD_DIST END DESC NULLS LAST,
                            x.UNITAP   ASC,
                            x.UNITUP   ASC,
                            x.NOUSULAN ASC,
                            x.IDPEL    ASC,
                            x.BLTH     ASC
                    ) AS RNUM,
                    COUNT(*) OVER () AS TOTAL_COUNT
                FROM v_core_data x
                WHERE (
                    in_search IS NULL OR
                    UPPER(x.NOUSULAN) LIKE '%' ||                               UPPER(in_search) || '%' OR
                    UPPER(x.KD_DIST) LIKE '%' ||                                UPPER(in_search) || '%' OR
                    UPPER(x.NAMA_DIST) LIKE '%' ||                              UPPER(in_search) || '%' OR
                    UPPER(x.IDPEL) LIKE '%' ||                                  UPPER(in_search) || '%' OR 
                    UPPER(x.BLTH) LIKE '%' ||                                   UPPER(in_search) || '%' OR 
                    UPPER(x.STATUS_PENDING) LIKE '%' ||                         UPPER(in_search) || '%' OR
                    UPPER(x.KETERANGAN) LIKE '%' ||                             UPPER(in_search) || '%' OR 
                    UPPER(x.KDBANK) LIKE '%' ||                                 UPPER(in_search) || '%' OR
                    UPPER(x.SATKER) LIKE '%' ||                                 UPPER(in_search) || '%' OR             
                    TO_CHAR(x.TGLINSERT, 'YYYY-MM-DD HH24:MI:SS') LIKE '%' ||   UPPER(in_search) || '%'
                )
            )
            SELECT 
                p.BLTH_USULAN, p.KD_DIST, p.NAMA_DIST, p.UNITAP, p.NAMA_UNITAP, 
                p.UNITUP, p.NAMA_UNITUP, p.NOUSULAN, p.TGLUSULAN, p.IDPEL, p.BLTH, p.NAMA,
                p.STATUS_PENDING, p.RPTAG, 
                OLAP.HITUNGBK(TO_CHAR(SYSDATE, 'ddmmyyyy'), p.BLTH, p.TGLJTTEMPO, p.RPBK1, p.RPBK2, p.RPBK3) AS RPBK,
                p.TGLBAYAR, p.USERID, p.KDPROSES, p.USERID_LOCK, p.STATUS, p.KETERANGAN, 
                p.VA, p.SATKER, p.KDBANK, p.NAMA_BANK, p.TGLINSERT, p.IDKIRIM, 
                p.RNUM AS ROW_NUMBER, p.TOTAL_COUNT
            FROM v_paged_data p
            CROSS JOIN v_params params
            WHERE p.RNUM BETWEEN params.START_ROW AND params.END_ROW
            ORDER BY p.RNUM;

        pesan := 'Sukses Tampilkan Data.';

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            pesan := 'Gagal Proses Data Tidak Ada, ' || vEmsg || ' ' || SQLERRM;
        WHEN OTHERS THEN
            pesan := 'Gagal Proses Data ' || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;         
    END monlap_miv_dft_mohon_pending;

END VER_MON_LAP;
/