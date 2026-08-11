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
      AND a.kdbank = :vkdbank
      AND substr(a.nousulan,9,6) = :vbln_usulan
      AND (b.suspect IN ('0','2') OR b.suspect IS NULL)
),
bank_data AS (
    SELECT 'bank_data' proses, a.va, a.nousulan, '2' kdproses, '1' status, a.idpel, a.blth,
           nvl(a.rptag,0) rptag, nvl(a.rpbk,0) rpbk, a.tglbayar, a.jambayar, a.userid, a.kdbank
    FROM ophartde.ver_data_locking_bank a
    WHERE a.kdbank = :vkdbank
      AND substr(a.nousulan,9,6) = :vbln_usulan
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
      AND a.kdbank = :vkdbank
      AND substr(a.nousulan,9,6) = :vbln_usulan
      AND (b.suspect IN ('0','2') OR b.suspect IS NULL)
),
bank_data_ntl AS (
    SELECT 'bank_data' proses, a.va, a.nousulan, '2' kdproses, '1' status, a.noreg idpel, null blth,
           nvl(a.rptag,0) rptag, 0 rpbk, a.tglbayar, a.jambayar, a.userid, a.kdbank
    FROM ophartde.ver_data_locking_bank_ntl a
    WHERE a.kdbank = :vkdbank
      AND substr(a.nousulan,9,6) = :vbln_usulan
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
         AND substr(b.tglbayar,1,6) = :vbln_usulan
         AND b.UNSOLD IS NULL 
         AND b.TGL_REKON IS NOT NULL
    WHERE to_char(a.tglinsert,'YYYYMM') = :vbln_usulan
      AND substr(a.nousulan,4,2) = :vkd_dist
      AND a.kdbank = :vkdbank
),
bank_data_pre AS (
    SELECT 'bank_data' proses, a.va, a.nousulan, '2' kdproses, '1' status, a.idpel, null blth,
           nvl(a.rptag,0) rptag, 0 rpbk, a.tglbayar, a.jambayar, a.userid, a.kdbank
    FROM ophartde.ver_data_locking_bank_pre a
    WHERE a.kdbank = :vkdbank
      AND substr(a.nousulan,9,6) = :vbln_usulan
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
    WHERE kd_dist = :vkd_dist
      AND (
          :in_search IS NULL OR
          to_char(pln_idpel) LIKE '%' || :in_search || '%' OR
          to_char(bank_idpel) LIKE '%' || :in_search || '%' OR
          lower(pln_nousulan) LIKE '%' || lower(:in_search) || '%' OR
          lower(tglapprove) LIKE '%' || lower(:in_search) || '%' OR
          lower(va) LIKE '%' || lower(:in_search) || '%' OR
          lower(satker) LIKE '%' || lower(:in_search) || '%' OR
          lower(bank_nousulan) LIKE '%' || lower(:in_search) || '%' OR
          lower(bank_userid) LIKE '%' || lower(:in_search) || '%' 
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
                CASE WHEN :in_sort_by = 'KD_DIST' AND :in_sort_dir = 'ASC'  THEN p.kd_dist END ASC,
                CASE WHEN :in_sort_by = 'KD_DIST' AND :in_sort_dir = 'DESC' THEN p.kd_dist END DESC
        ) AS ROW_NUMBER,
        COUNT(*) OVER () AS TOTAL_COUNT
    FROM processed_data p
)
ORDER BY ROW_NUMBER
OFFSET ((:in_start - 1) * :in_lenght) ROWS
FETCH NEXT :in_lenght ROWS ONLY;