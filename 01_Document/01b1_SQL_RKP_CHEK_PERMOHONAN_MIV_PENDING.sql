--2a) Rekap Data Permohonan Pending MIV
WITH DATA_TRANSAKSI AS (
    -- Subquery 1: Bagian SAKTI
    SELECT 
        '00' AS KD_DIST, 
        'SAKTI' AS NAMA_DIST, 
        NVL(TO_CHAR(a.TGLINSERT, 'YYYYMM'), :vbln_usulan) AS BLTH_USULAN, 
        a.ID_USUL as NOUSULAN, 
        a.IDPEL, 
        b.RPTAG,  
        OLAP.HITUNGBK(TO_CHAR(SYSDATE,'ddmmyyyy'), B.BLTH, B.TGLJTTEMPO, B.RPBK1, B.RPBK2, B.RPBK3) as RPBK,
        a.KDBANK, 
        DECODE(b.PRAQTIS, 0, 'PENDING', 'UNPENDING') AS KET_PENDING
    FROM OPHARTDE.VER_TEMP_DATA_LOCKING_SAKTI a
    LEFT JOIN PLNGATEPOST.DPP b ON a.IDPEL = b.IDPEL AND a.BLTH = b.BLTH
    WHERE a.TGLINSERT >= TO_DATE(:vbln_usulan, 'YYYYMM')
      AND a.TGLINSERT < ADD_MONTHS(TO_DATE(:vbln_usulan, 'YYYYMM'), 1)
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
        NVL(TO_CHAR(a.TGLINSERT, 'YYYYMM'), :vbln_usulan) AS BLTH_USULAN, 
        a.NOUSULAN, 
        a.IDPEL, 
        b.RPTAG,  
        OLAP.HITUNGBK(TO_CHAR(SYSDATE,'ddmmyyyy'), B.BLTH, B.TGLJTTEMPO, B.RPBK1, B.RPBK2, B.RPBK3) as RPBK,
        a.KDBANK, 
        DECODE(b.PRAQTIS, 0, 'PENDING', 'UNPENDING') AS KET_PENDING
    FROM OPHARTDE.VER_TEMP_DATA_LOCKING a
    LEFT JOIN OLAP.MASTER_DISTRIBUSI X ON a.KD_DIST = X.KD_DIST
    LEFT JOIN PLNGATEPOST.DPP b ON a.IDPEL = b.IDPEL AND a.BLTH = b.BLTH
    WHERE a.TGLINSERT >= TO_DATE(:vbln_usulan, 'YYYYMM')
      AND a.TGLINSERT < ADD_MONTHS(TO_DATE(:vbln_usulan, 'YYYYMM'), 1)
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