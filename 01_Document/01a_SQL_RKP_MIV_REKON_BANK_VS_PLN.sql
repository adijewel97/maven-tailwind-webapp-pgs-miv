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
    WHERE a.kdproses = '2' AND SUBSTR(a.nousulan,9,6) = TO_CHAR(:vbln_usulan) AND a.status = '1'
),
bank_data AS (
    SELECT a.va, a.nousulan, a.idpel, a.blth, NVL(a.rptag,0) rptag, NVL(a.rpbk,0) rpbk, a.kdbank
    FROM ophartde.ver_data_locking_bank a
    WHERE SUBSTR(a.nousulan,9,6) = TO_CHAR(:vbln_usulan)
),
pln_data_ntl AS (
    SELECT TO_CHAR(a.tglinsert,'YYYYMMDD HH24:MI') tglapprove, NVL(SUBSTR(a.nousulan,4,2),a.kd_dist) kddist, a.va, a.nousulan, a.noreg idpel,
           CASE WHEN b.suspect IN ('0','2') THEN NVL(b.rptag,0) ELSE 0 END rptag, a.kdbank, (b.tglbayar||' '||b.jambayar||' '||b.userid) lunas_H0
    FROM ophartde.ver_temp_data_locking_ntl a
    LEFT JOIN olap.transaksi_nontaglis b ON a.noreg = b.nomor_registrasi
    WHERE a.kdproses = '2' AND SUBSTR(a.nousulan,9,6) = TO_CHAR(:vbln_usulan) AND a.status = '1'
),
bank_data_ntl AS (
    SELECT a.va, a.nousulan, a.noreg idpel, NVL(a.rptag,0) rptag, a.kdbank
    FROM ophartde.ver_data_locking_bank_ntl a
    WHERE SUBSTR(a.nousulan,9,6) = TO_CHAR(:vbln_usulan)
),
pln_data_pre AS (
    SELECT (SELECT DISTINCT TO_CHAR(tglinsert,'YYYYMMDD HH24:MI') FROM OPHARTDE.VER_TEMP_DATA_LOCKING_PRE WHERE nousulan = m.nousulan AND ROWNUM = 1) tglapprove,
           SUBSTR(m.nousulan,4,2) kddist, m.va, m.nousulan, m.idpel,
           m.rptag, m.kdbank,
           (SELECT (b.tglbayar||' '||b.jambayar||' '||b.userid) 
            FROM OLAP.TRANSAKSI_PREPAID b 
            WHERE m.idpel = b.idpel AND m.rptag = b.rptag AND TO_CHAR(m.tglinsert,'YYYYMMDD') <= b.tglbayar 
              AND SUBSTR(b.tglbayar,1,6) = TO_CHAR(:vbln_usulan) AND b.UNSOLD IS NULL AND b.TGL_REKON IS NOT NULL AND ROWNUM = 1) lunas_H0
    FROM OPHARTDE.VER_TEMP_DATA_LOCKING_PRE m
    WHERE TO_CHAR(tglinsert,'YYYYMM') = TO_CHAR(:vbln_usulan)
),
bank_data_pre AS (
    SELECT a.va, a.nousulan, a.idpel, NVL(a.rptag,0) rptag, a.kdbank
    FROM ophartde.ver_data_locking_bank_pre a
    WHERE SUBSTR(a.nousulan,9,6) = TO_CHAR(:vbln_usulan)
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
    CASE WHEN a.grp_dist = 1 THEN '' ELSE NVL(a.bln_usulan, TO_CHAR(:vbln_usulan)) END AS BLN_USULAN,
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