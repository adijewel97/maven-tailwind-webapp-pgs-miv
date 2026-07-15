CREATE OR REPLACE FUNCTION OPHARTDE.VER_F_UNPENDING_NORMAL_CLOB (
    clob_in     IN CLOB, 
    tmpcur_out  OUT SYS_REFCURSOR
) RETURN VARCHAR2 IS
    msg             VARCHAR2(500);
    xKdProses       INT := 3;
    vconter         INT := 0;
    vconter_sukses  INT := 0;
    vconter_gagal   INT := 0;
    zidkirim        VARCHAR2(60);
    v_tglinsert     DATE := SYSDATE;
BEGIN
    -- Generasi ID Kirim Unik di setiap pemanggilan function
    zidkirim := SYS_GUID();

    ----------------------------------------------------------------------------
    -- 1. MERGE DATA (ANTISIPASI DUPLIKAT INTERNAL XML & RE-SUBMIT)
    ----------------------------------------------------------------------------
    MERGE INTO OPHARTDE.VER_TEMP_DATA_LOCKING t
    USING (
        -- GROUP BY mengeliminasi jika ada data idpel + blth yang kembar di dalam SATU XML yang sama
        SELECT 
            UNITUPI AS kd_dist,
            IDTRANS AS nousulan,
            TGLTRANS AS tglusulan,
            IDPEL AS idpel,
            BLTH AS blth,
            MAX(IDUSER) AS userid_lock,
            MAX(VA) AS va,
            MAX(KDBANK) AS kdbank,
            MAX(NAMASATKER) AS satker
        FROM XMLTABLE('/ROWSET/ROW' PASSING XMLTYPE(clob_in)
            COLUMNS 
                UNITUPI      VARCHAR2(100) PATH './UNITUPI',
                IDTRANS      VARCHAR2(100) PATH './IDTRANS',
                TGLTRANS     VARCHAR2(100) PATH './TGLTRANS',
                IDUSER       VARCHAR2(100) PATH './IDUSER',
                VA           VARCHAR2(100) PATH './VA',
                KDBANK       VARCHAR2(100) PATH './KDBANK',
                NAMASATKER   VARCHAR2(100) PATH './NAMASATKER',
                IDPEL        VARCHAR2(100) PATH './IDPEL',
                BLTH         VARCHAR2(100) PATH './BLTH'
        )
        GROUP BY UNITUPI, IDTRANS, TGLTRANS, IDPEL, BLTH
    ) src
    ON (
            t.NOUSULAN   = src.nousulan
        AND t.TGLUSULAN  = src.tglusulan
        AND t.IDPEL      = src.idpel
        AND t.BLTH       = src.blth
        AND t.KDPROSES   = xKdProses
    )
    WHEN MATCHED THEN
        -- Skenario data sama dikirim ulang: idkirim lama ditimpa dengan GUID baru, status direset ke 0
        UPDATE SET 
            t.idkirim     = zidkirim,
            t.status      = 0,
            t.keterangan  = 'RE-SUBMIT DATA (GUID UPDATED)',
            t.tglinsert   = v_tglinsert
    WHEN NOT MATCHED THEN
        -- Skenario data baru / beda bulan: insert baris baru dengan GUID baru
        INSERT (kd_dist, nousulan, tglusulan, idpel, blth, rptag, rpbk, userid, kdproses, userid_lock, status, keterangan, va, kdbank, satker, tglinsert, idkirim)
        VALUES (src.kd_dist, src.nousulan, src.tglusulan, src.idpel, src.blth, 0, 0, NULL, xKdProses, src.userid_lock, 0, NULL, src.va, src.kdbank, src.satker, v_tglinsert, zidkirim);

    ----------------------------------------------------------------------------
    -- 2. VALIDASI MASSAL BERBASIS GUID BARU (zidkirim)
    ----------------------------------------------------------------------------
    -- A1) Reset status data batch GUID ini
    UPDATE OPHARTDE.VER_TEMP_DATA_LOCKING
    SET status = 0, keterangan = NULL
    WHERE idkirim = zidkirim AND KDPROSES = xKdProses AND status <> 3;

    -- A2) Validasi KOGOL selain 1, 2, 3
    UPDATE OPHARTDE.VER_TEMP_DATA_LOCKING b
    SET b.status = '2', 
        b.keterangan = 'IDPEL VERTIKAL ADA SALDO DPP KOGOL SELAIN : 1, 2, 3'
    WHERE b.idkirim = zidkirim
      AND b.KDPROSES = xKdProses
      AND EXISTS (
          SELECT 1 
          FROM plngatepost.dpp a
          WHERE a.idpel = b.idpel 
            AND a.blth = b.blth
            AND SUBSTR(a.kogol,1,1) NOT IN ('1','2','3')
            AND a.kdgerak IN ('11','12','13')
      );

    ----------------------------------------------------------------------------
    -- 3. LOG BACKUP & UPDATE DPP (MASSAL)
    ----------------------------------------------------------------------------
    INSERT INTO OPHARTDE.VER_DATA_LOCKING
    SELECT 
        a.KD_DIST, a.UNITUP, a.IDPEL, a.NAMA, a.KOGOL, a.BLTH, a.KDPP, a.KDGERAK, 
        a.TGLBAYAR, a.RPTAG,
        OLAP.hitungbk(TO_CHAR(SYSDATE,'YYYYMMDD'), a.BLTH, a.TGLJTTEMPO, a.RPBK1, a.RPBK2, a.RPBK3) AS RPBK,
        a.PRAQTIS AS PRAQTIS_AWAL, 1 AS PRAQTIS, a.USERID,
        '1' STATUS_LOCK, TO_CHAR(SYSDATE,'YYYYMMDD') TGLOCK, TO_CHAR(SYSDATE,'HH24MISS') JAMLOCK,
        NULL KIRIM, NULL RC, 'PENDING-VERTIKAL-AP2T' KETERANGAN,
        '3' KDPROSES, 'UNPENDING-CLEAR' PROSES,
        b.userid_lock, b.nousulan, b.tglusulan, b.va, b.kdbank, b.satker
    FROM plngatepost.dpp a
    JOIN OPHARTDE.VER_TEMP_DATA_LOCKING b 
      ON a.idpel = b.idpel AND a.blth = b.blth
    WHERE b.idkirim = zidkirim
      AND b.KDPROSES = xKdProses
      AND b.status IN ('0','1')
      AND SUBSTR(LTRIM(a.kogol),1,1) IN ('1','2','3')
      AND a.kdgerak IN ('11','12','13')
      -- Mencegah dobel insert di tabel log permanen jika data usulan+idpel+blth yang sama sudah pernah sukses di-backup dulu
      AND NOT EXISTS (
          SELECT 1 FROM OPHARTDE.VER_DATA_LOCKING dl
          WHERE dl.IDPEL = a.idpel AND dl.BLTH = a.blth 
            AND dl.KDPROSES = '3' AND dl.NOUSULAN = b.nousulan AND dl.TGLUSULAN = b.tglusulan
      );

    -- Update status PRAQTIS di tabel dpp
    UPDATE plngatepost.dpp a
    SET a.PRAQTIS = 1
    WHERE EXISTS (
        SELECT 1 FROM OPHARTDE.VER_TEMP_DATA_LOCKING b
        WHERE b.idkirim = zidkirim
          AND b.idpel = a.idpel
          AND b.KDPROSES = xKdProses
          AND b.status = '0'
    )
    AND SUBSTR(LTRIM(a.kogol),1,1) IN ('1','2','3')
    AND a.kdgerak IN ('11','12','13');

    -- Flag log sukses massal
    UPDATE OPHARTDE.VER_TEMP_DATA_LOCKING
    SET status = '1', keterangan = 'SUKSES'
    WHERE idkirim = zidkirim 
      AND KDPROSES = xKdProses 
      AND status = '0';

    -- Flag jika data sudah lunas (tidak ada di dpp atau gagal ter-backup)
    UPDATE OPHARTDE.VER_TEMP_DATA_LOCKING b
    SET b.status = '4', 
        b.keterangan = 'SUDAH LUNAS/BUKAN SALDO P2APST'
    WHERE b.idkirim = zidkirim
      AND b.KDPROSES = xKdProses
      AND b.status IN ('0','1')
      AND NOT EXISTS (
          SELECT 1 FROM OPHARTDE.VER_DATA_LOCKING dl
          WHERE dl.idpel = b.idpel 
            AND dl.blth = b.blth
            AND dl.NOUSULAN = b.nousulan
            AND dl.TGLUSULAN = b.tglusulan
            AND dl.KDPROSES = xKdProses
      );

    -- Hitung summary khusus untuk batch GUID saat ini
    SELECT 
        COUNT(*), 
        SUM(DECODE(status, '1', 1, 0)), 
        SUM(DECODE(status, '1', 0, 1))
    INTO vconter, vconter_sukses, vconter_gagal
    FROM OPHARTDE.VER_TEMP_DATA_LOCKING
    WHERE idkirim = zidkirim AND KDPROSES = xKdProses;

    msg := 'Sukses: P2APST - UnPending IDPEL GOL. Vertikal Jumlah : '||vconter||' = Proses : '||vconter_sukses||', Gagal : ' ||vconter_gagal;
    
    COMMIT;

    -- Kembalikan cursor hanya untuk baris data yang diproses oleh GUID ini
    OPEN tmpcur_out FOR
        SELECT KD_DIST, NOUSULAN, TGLUSULAN, IDPEL, BLTH, RPTAG, RPBK, USERID, 
               KDPROSES, USERID_LOCK, STATUS, KETERANGAN, VA, KDBANK, SATKER, TGLINSERT
        FROM OPHARTDE.VER_TEMP_DATA_LOCKING
        WHERE KDPROSES = xKdProses AND idkirim = zidkirim
        ORDER BY NOUSULAN, TGLUSULAN DESC, idpel, blth DESC;
               
    RETURN msg;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        OPEN tmpcur_out FOR 
            SELECT KD_DIST, NOUSULAN, TGLUSULAN, IDPEL, BLTH, RPTAG, RPBK, USERID, 
                   KDPROSES, USERID_LOCK, STATUS, KETERANGAN, VA, KDBANK, SATKER, TGLINSERT
            FROM OPHARTDE.VER_TEMP_DATA_LOCKING
            WHERE KDPROSES = xKdProses AND idkirim = zidkirim
            ORDER BY NOUSULAN, TGLUSULAN DESC, idpel, blth DESC;
        RETURN 'Error: P2APST - Proses UnPending Normalisasi IDPEL GOL. Vertikal bermasalah. ' ||SQLERRM;
END;
/