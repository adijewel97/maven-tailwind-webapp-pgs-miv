--1) Rekap Data Permohonan Pending MIV
WITH DATA_REKAP AS (
    SELECT 
        '00' KD_DIST, 
        'SAKTI' NAMA_DIST, 
        NVL(TO_CHAR(Y.TGLINSERT, 'YYYYMM'), :vbln_usulan) AS BLTH_USULAN, 
        COUNT(DISTINCT Y.NOUSULAN) AS JML_USULAN, 
        COUNT(Y.IDPEL) AS JML_LBR,
        sum(Y.RPTAG) RPTAG,
        sum(Y.RPBK) RPBK,
        Y.KDBANK, 
        (select NAMA_BANK FROM OPHARTDE.VER_MASTER_BANK where KODE_BANK = Y.KDBANK and rownum = 1) as NAMA_BANK,
        NVL(Y.KET_PENDING, '') AS KET_PENDING
    FROM OLAP.MASTER_DISTRIBUSI X, (
        SELECT a.KD_DIST, a.TGLINSERT, a.ID_USUL as NOUSULAN, a.IDPEL, a.KDBANK,
               b.RPTAG,  
               OLAP.HITUNGBK(
                to_char(sysdate,'ddmmyyyy'),
                    B.BLTH,
                    B.TGLJTTEMPO,
                    B.RPBK1,
                    B.RPBK2,
                    B.RPBK3
                ) as RPBK,
               DECODE(b.PRAQTIS, 0, 'PENDING', 'UNPENDING') AS KET_PENDING
        FROM OPHARTDE.VER_TEMP_DATA_LOCKING_SAKTI a
        LEFT JOIN PLNGATEPOST.DPP b 
          ON a.IDPEL = b.IDPEL AND a.BLTH = b.BLTH
        WHERE a.TGLINSERT >= TO_DATE(:vbln_usulan, 'YYYYMM')
          AND a.TGLINSERT < ADD_MONTHS(TO_DATE(:vbln_usulan, 'YYYYMM'), 1)
          AND a.KDPROSES = '1'
          AND NOT EXISTS 
          (
              SELECT 1 
              FROM OPHARTDE.VER_TEMP_DATA_LOCKING_SAKTI c 
              WHERE c.KDPROSES in ('2', '3')
                AND c.ID_USUL = a.ID_USUL
                AND c.idpel    = a.idpel
                AND c.blth     = a.blth
          )
    ) Y
    WHERE X.KD_DIST = Y.KD_DIST
    GROUP BY 
--        X.KD_DIST, X.NAMA_DIST, 
        TO_CHAR(Y.TGLINSERT, 'YYYYMM'), 
        Y.KDBANK, 
        Y.KET_PENDING
    UNION ALL
    SELECT 
        X.KD_DIST, 
        X.NAMA_DIST, 
        NVL(TO_CHAR(Y.TGLINSERT, 'YYYYMM'), :vbln_usulan) AS BLTH_USULAN, 
        COUNT(DISTINCT Y.NOUSULAN) AS JML_USULAN, 
        COUNT(Y.IDPEL) AS JML_LBR,
        sum(Y.RPTAG) RPTAG,
        sum(Y.RPBK) RPBK,
        Y.KDBANK, 
        (select NAMA_BANK FROM OPHARTDE.VER_MASTER_BANK where KODE_BANK = Y.KDBANK and rownum = 1) as NAMA_BANK,
        NVL(Y.KET_PENDING, '') AS KET_PENDING
    FROM OLAP.MASTER_DISTRIBUSI X
    LEFT JOIN (
        SELECT a.KD_DIST, a.TGLINSERT, a.NOUSULAN, a.IDPEL, a.KDBANK,
            b.RPTAG,  
            OLAP.HITUNGBK(
            to_char(sysdate,'ddmmyyyy'),
                B.BLTH,
                B.TGLJTTEMPO,
                B.RPBK1,
                B.RPBK2,
                B.RPBK3
            ) as RPBK,
            DECODE(b.PRAQTIS, 0, 'PENDING', 'UNPENDING') AS KET_PENDING
        FROM OPHARTDE.VER_TEMP_DATA_LOCKING a
        LEFT JOIN PLNGATEPOST.DPP b 
          ON a.IDPEL = b.IDPEL AND a.BLTH = b.BLTH
        WHERE a.TGLINSERT >= TO_DATE(:vbln_usulan, 'YYYYMM')
          AND a.TGLINSERT < ADD_MONTHS(TO_DATE(:vbln_usulan, 'YYYYMM'), 1)
          AND a.KDPROSES = '1'
          AND NOT EXISTS 
          (
              SELECT 1 
              FROM OPHARTDE.VER_TEMP_DATA_LOCKING c 
              WHERE c.KDPROSES in ('2', '3')
                AND c.NOUSULAN = a.NOUSULAN
                AND c.idpel    = a.idpel
                AND c.blth     = a.blth
          )
    ) Y ON X.KD_DIST = Y.KD_DIST
    GROUP BY 
        X.KD_DIST, X.NAMA_DIST, 
        TO_CHAR(Y.TGLINSERT, 'YYYYMM'), 
        Y.KDBANK, 
        Y.KET_PENDING
)
-- 1) Tampilkan Data Rekap
SELECT 
    1 AS URUT, KD_DIST, NAMA_DIST, BLTH_USULAN, 
    JML_USULAN, JML_LBR, RPTAG, RPBK,
    CASE WHEN KDBANK is null THEN 
           '' 
         ELSE 
          KDBANK||' - '||NAMA_BANK
    END NAMA_BANK, KET_PENDING
FROM DATA_REKAP
--WHERE KD_DIST <> '15'
UNION ALL
-- 2) Tampilkan Baris Total (Akan berada di baris paling bawah)
SELECT 
     5 AS URUT, '' AS KD_DIST, '' AS NAMA_DIST, 'TOTAL' AS BLTH_USULAN, 
    SUM(JML_USULAN) AS JML_USULAN, SUM(JML_LBR) AS JML_LBR, 
    SUM(NVL(RPTAG,0)) as RPTAG, SUM(NVL(RPBK,0)) RPBK, '' AS KDBANK, '' AS KET_PENDING
FROM DATA_REKAP
--WHERE KD_DIST <> '15'
ORDER BY URUT, KD_DIST, KET_PENDING;



--2) Detail Data Permohonan Pending MIV
SELECT 
    Y.BLTH_USULAN,
    X.KD_DIST, X.NAMA_DIST, 
    (SELECT KD_DIST||UNITAP_AP2T FROM OPHARTDE.VER_MASTER_UNIT WHERE UNITUP = Y.unitup AND ROWNUM = 1) as UNITAP,
    (SELECT NAMA_AREA FROM OPHARTDE.VER_MASTER_UNIT WHERE UNITUP = Y.unitup AND ROWNUM = 1) as NAMA_UNITAP,
    Y.unitup, (SELECT NAMA_UNIT FROM OPHARTDE.VER_MASTER_UNIT WHERE UNITUP = Y.unitup AND ROWNUM = 1) as NAMA_UNITUP,
    Y.NOUSULAN, Y.TGLUSULAN, Y.IDPEL, Y.BLTH,
    Y.KET_PENDING STATUS_PENDING, 
    Y.RPTAG, Y.RPBK, Y.USERID, Y.KDPROSES, Y.USERID_LOCK, Y.STATUS, Y.KETERANGAN, 
    Y.VA, Y.SATKER, 
    Y.KDBANK, (  select NAMA_BANK FROM OPHARTDE.VER_MASTER_BANK where KODE_BANK = Y.KDBANK and rownum = 1) as NAMA_BANK,
    Y.TGLINSERT, Y.IDKIRIM    
FROM OLAP.MASTER_DISTRIBUSI X, 
(
    SELECT  
           NVL(TO_CHAR(a.TGLINSERT, 'YYYYMM'), TO_CHAR(TO_DATE(:vbln_usulan, 'YYYYMM'), 'YYYYMM')) AS BLTH_USULAN,
           a.KD_DIST, b.unitup, a.NOUSULAN, a.TGLUSULAN, a.IDPEL, a.BLTH, 
           b.RPTAG, 
           OLAP.HITUNGBK(
                to_char(sysdate,'ddmmyyyy'),
                B.BLTH,
                B.TGLJTTEMPO,
                B.RPBK1,
                B.RPBK2,
                B.RPBK3
            ) as RPBK, 
           a.USERID, a.KDPROSES, a.USERID_LOCK, a.STATUS, a.KETERANGAN, 
           a.VA, a.SATKER, 
           a.KDBANK, 
           a.TGLINSERT, a.IDKIRIM,
           DECODE(b.PRAQTIS, 0, 'PENDING', 'UNPENDING') AS KET_PENDING
    FROM OPHARTDE.VER_TEMP_DATA_LOCKING a, PLNGATEPOST.DPP b 
    WHERE a.IDPEL = b.IDPEL AND a.BLTH = b.BLTH
      AND a.TGLINSERT >= TO_DATE(:vbln_usulan, 'YYYYMM')
      AND a.TGLINSERT < ADD_MONTHS(TO_DATE(:vbln_usulan, 'YYYYMM'), 1)
      AND a.KDPROSES in ('1', '3') 
      AND NOT EXISTS 
      (
          SELECT 1 
          FROM OPHARTDE.VER_TEMP_DATA_LOCKING c -- Diubah ke alias 'c' agar tidak bentrok dengan alias 'b' (DPP)
          WHERE c.KDPROSES = '2'
            AND c.NOUSULAN = a.NOUSULAN
            AND c.idpel    = a.idpel
            AND c.blth     = a.blth
      )
) Y 
WHERE X.KD_DIST = Y.KD_DIST
ORDER BY X.KD_DIST, X.NAMA_DIST, Y.unitup,
         Y.NOUSULAN, Y.TGLUSULAN, Y.IDPEL, Y.BLTH;
         
--2a DAFTAR PEGING DATA PROSES PENDING P2APST
WITH
v_core_data AS
(
    --2) Detail Data Permohonan Pending MIV
    SELECT 
        Y.BLTH_USULAN,
        Y.KD_DIST, DECODE(Y.KD_DIST,'00','SAKTI', X.NAMA_DIST) NAMA_DIST, 
        (SELECT KD_DIST||UNITAP_AP2T FROM OPHARTDE.VER_MASTER_UNIT WHERE UNITUP = Y.unitup AND ROWNUM = 1) as UNITAP,
        (SELECT NAMA_AREA FROM OPHARTDE.VER_MASTER_UNIT WHERE UNITUP = Y.unitup AND ROWNUM = 1) as NAMA_UNITAP,
        Y.UNITUP, (SELECT NAMA_UNIT FROM OPHARTDE.VER_MASTER_UNIT WHERE UNITUP = Y.unitup AND ROWNUM = 1) as NAMA_UNITUP,
        Y.NOUSULAN, Y.TGLUSULAN, Y.IDPEL, Y.BLTH,
        Y.KET_PENDING STATUS_PENDING, 
        Y.RPTAG, Y.RPBK, Y.TGLBAYAR,
        Y.USERID, Y.KDPROSES, Y.USERID_LOCK, Y.STATUS, Y.KETERANGAN, 
        Y.VA, Y.SATKER, 
        Y.KDBANK, (  select NAMA_BANK FROM OPHARTDE.VER_MASTER_BANK where KODE_BANK = Y.KDBANK and rownum = 1) as NAMA_BANK,
        Y.TGLINSERT, Y.IDKIRIM    
    FROM OLAP.MASTER_DISTRIBUSI X, 
    (
        SELECT  
           NVL(TO_CHAR(a.TGLINSERT, 'YYYYMM'), TO_CHAR(TO_DATE(:vbln_usulan, 'YYYYMM'), 'YYYYMM')) AS BLTH_USULAN,
           '00' KD_DIST, b.unitup, a.ID_USUL as NOUSULAN, a.BLTH_USUL as TGLUSULAN, a.IDPEL, a.BLTH, 
           b.RPTAG, 
           OLAP.HITUNGBK(
                to_char(sysdate,'ddmmyyyy'),
                B.BLTH,
                B.TGLJTTEMPO,
                B.RPBK1,
                B.RPBK2,
                B.RPBK3
            ) as RPBK, 
           TGLBAYAR,
           'SYSTEM' as USERID, a.KDPROSES, a.USERID_LOCK, a.STATUS, a.KETERANGAN, 
           a.VA, a.SATKER, 
           a.KDBANK, 
           a.TGLINSERT, a.IDKIRIM,
           DECODE(b.PRAQTIS, 0, 'PENDING', 'UNPENDING') AS KET_PENDING
        FROM OPHARTDE.VER_TEMP_DATA_LOCKING_SAKTI a, PLNGATEPOST.DPP b 
        WHERE a.IDPEL = b.IDPEL AND a.BLTH = b.BLTH
        AND a.TGLINSERT >= TO_DATE(:vbln_usulan, 'YYYYMM')
        AND a.TGLINSERT < ADD_MONTHS(TO_DATE(:vbln_usulan, 'YYYYMM'), 1)
        AND a.KDPROSES = '1'
        AND NOT EXISTS 
        (
          SELECT 1 
          FROM OPHARTDE.VER_TEMP_DATA_LOCKING_SAKTI c -- Diubah ke alias 'c' agar tidak bentrok dengan alias 'b' (DPP)
          WHERE c.KDPROSES in ('2', '3')
            AND c.ID_USUL = a.ID_USUL
            AND c.idpel    = a.idpel
            AND c.blth     = a.blth
        )
        UNION
        SELECT  
               NVL(TO_CHAR(a.TGLINSERT, 'YYYYMM'), TO_CHAR(TO_DATE(:vbln_usulan, 'YYYYMM'), 'YYYYMM')) AS BLTH_USULAN,
               a.KD_DIST, b.unitup, a.NOUSULAN, a.TGLUSULAN, a.IDPEL, a.BLTH, 
               b.RPTAG, 
               OLAP.HITUNGBK(
                    to_char(sysdate,'ddmmyyyy'),
                    B.BLTH,
                    B.TGLJTTEMPO,
                    B.RPBK1,
                    B.RPBK2,
                    B.RPBK3
                ) as RPBK, 
               TGLBAYAR,
               a.USERID, a.KDPROSES, a.USERID_LOCK, a.STATUS, a.KETERANGAN, 
               a.VA, a.SATKER, 
               a.KDBANK, 
               a.TGLINSERT, a.IDKIRIM,
               DECODE(b.PRAQTIS, 0, 'PENDING', 'UNPENDING') AS KET_PENDING
        FROM OPHARTDE.VER_TEMP_DATA_LOCKING a, PLNGATEPOST.DPP b 
        WHERE a.IDPEL = b.IDPEL AND a.BLTH = b.BLTH
          AND a.TGLINSERT >= TO_DATE(:vbln_usulan, 'YYYYMM')
          AND a.TGLINSERT < ADD_MONTHS(TO_DATE(:vbln_usulan, 'YYYYMM'), 1)
          AND a.KDPROSES  = '1' 
          AND NOT EXISTS 
          (
              SELECT 1 
              FROM OPHARTDE.VER_TEMP_DATA_LOCKING c -- Diubah ke alias 'c' agar tidak bentrok dengan alias 'b' (DPP)
              WHERE c.KDPROSES in ('2', '3')
                AND c.NOUSULAN = a.NOUSULAN
                AND c.idpel    = a.idpel
                AND c.blth     = a.blth
          )
    ) Y 
    WHERE Y.KD_DIST = X.KD_DIST(+)
    ORDER BY X.KD_DIST, X.NAMA_DIST, Y.unitup,
             Y.NOUSULAN, Y.TGLUSULAN, Y.IDPEL, Y.BLTH
)
SELECT *
FROM (
    SELECT
        x.*,
        ROW_NUMBER() OVER (
            ORDER BY 
                CASE
                    WHEN :in_sort_by = 'KD_DIST'
                     AND :in_sort_dir = 'ASC'
                    THEN x.KD_DIST
                END ASC,
                CASE
                    WHEN :in_sort_by = 'KD_DIST'
                     AND :in_sort_dir = 'DESC'
                    THEN x.KD_DIST
                END DESC,
                x.UNITAP  ASC,
                x.UNITUP ASC,
                x.NOUSULAN ASC,
                x.IDPEL ASC,
                x.BLTH ASC
        ) AS ROW_NUMBER,
        COUNT(*) OVER () AS TOTAL_COUNT
    FROM v_core_data x
    WHERE x.BLTH_USULAN = :vbln_usulan
    AND   x.KD_DIST     = :vkd_dist
    AND   x.KDBANK      = :vkdbank
    AND (
            :in_search IS NULL OR
            UPPER(x.NOUSULAN) LIKE '%' || UPPER(:in_search) || '%' OR
            UPPER(x.IDPEL) LIKE '%' || UPPER(:in_search) || '%' OR 
            UPPER(x.BLTH) LIKE '%' || UPPER(:in_search) || '%' OR 
            UPPER(x.STATUS_PENDING) LIKE '%' || UPPER(:in_search) || '%' OR
            UPPER(x.KETERANGAN) LIKE '%' || UPPER(:in_search) || '%' OR 
            UPPER(x.KDBANK) LIKE '%' || UPPER(:in_search) || '%' OR
            UPPER(x.SATKER) LIKE '%' || UPPER(:in_search) || '%' OR            
            UPPER(x.TGLINSERT) LIKE '%' || UPPER(:in_search) || '%'
      )
)
ORDER BY ROW_NUMBER
OFFSET ((:in_start - 1) * :in_length) ROWS
FETCH NEXT :in_length ROWS ONLY;