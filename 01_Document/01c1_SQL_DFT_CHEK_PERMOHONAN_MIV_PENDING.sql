--2b) monlap_miv_dft_mohon_pending -- Menapilkan daftar per prob/bank pengaujuan pending dari AP2T ke P2APST
WITH v_params AS 
(
    -- Pre-calculate variabel tanggal, string, dan offset pagination
    SELECT 
        TO_CHAR(:vbln_usulan) AS BLN_STR,
        TO_DATE(TO_CHAR(:vbln_usulan), 'YYYYMM') AS BLN_DT,
        -- Kalkulasi batas baris berdasarkan nomor halaman (:in_start) dan ukuran halaman (:in_length)
        ((NVL(:in_start, 1) - 1) * NVL(:in_length, 10)) + 1 AS START_ROW,
         (NVL(:in_start, 1) *      NVL(:in_length, 10)) AS END_ROW
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
      AND b.PRAQTIS     = DECODE(:vket_pending,'PENDING',0,1)
      AND '00'          = :vkd_dist
      AND (a.KDBANK     = :vkdbank OR (:vkdbank IS NULL AND a.KDBANK IS NULL))
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
      AND a.KD_DIST     = :vkd_dist
      AND a.NOUSULAN LIKE 'POS' ||     :vkd_dist || '%'
      AND (a.KDBANK     = :vkdbank OR (:vkdbank IS NULL AND a.KDBANK IS NULL))
      AND  b.PRAQTIS    = DECODE(:vket_pending,'PENDING',0,1)
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
                CASE WHEN :in_sort_by = 'KD_DIST' AND UPPER(:in_sort_dir) = 'ASC'  THEN x.KD_DIST END ASC NULLS LAST,
                CASE WHEN :in_sort_by = 'KD_DIST' AND UPPER(:in_sort_dir) = 'DESC' THEN x.KD_DIST END DESC NULLS LAST,
                x.UNITAP   ASC,
                x.UNITUP   ASC,
                x.NOUSULAN ASC,
                x.IDPEL    ASC,
                x.BLTH     ASC
        ) AS RNUM,
        COUNT(*) OVER () AS TOTAL_COUNT
    FROM v_core_data x
    WHERE (
        :in_search IS NULL OR
        UPPER(x.NOUSULAN) LIKE '%' ||                               UPPER(:in_search) || '%' OR
        UPPER(x.KD_DIST) LIKE '%' ||                                UPPER(:in_search) || '%' OR
        UPPER(x.NAMA_DIST) LIKE '%' ||                              UPPER(:in_search) || '%' OR
        UPPER(x.IDPEL) LIKE '%' ||                                  UPPER(:in_search) || '%' OR 
        UPPER(x.BLTH) LIKE '%' ||                                   UPPER(:in_search) || '%' OR 
        UPPER(x.STATUS_PENDING) LIKE '%' ||                         UPPER(:in_search) || '%' OR
        UPPER(x.KETERANGAN) LIKE '%' ||                             UPPER(:in_search) || '%' OR 
        UPPER(x.KDBANK) LIKE '%' ||                                 UPPER(:in_search) || '%' OR
        UPPER(x.SATKER) LIKE '%' ||                                 UPPER(:in_search) || '%' OR             
        TO_CHAR(x.TGLINSERT, 'YYYY-MM-DD HH24:MI:SS') LIKE '%' ||   UPPER(:in_search) || '%'
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