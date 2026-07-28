CREATE OR REPLACE PACKAGE BODY OPHARTDE.VER_PROSES_REKON_MIV AS

    PROCEDURE INSERT_ISIFILERCN_REKON_BANK(
        JSON_DATA_RCN     IN CLOB, 
        JSON_DATA_RCNCTL  IN CLOB, 
        out_cursor        OUT SYS_REFCURSOR, 
        pesan             OUT VARCHAR2
    ) AS
        vcount_sukses        INT := 0;
        vcount_totalfile    INT := 0;
        vbln_laporan        VARCHAR2(8);
        vproduk             VARCHAR2(20);
        vnamafile           VARCHAR2(100);
        vsample_nousulan    VARCHAR2(50);
        
        -- Variabel untuk menampung nilai dari JSON CTL seadanya
        vctl_lembar         VARCHAR2(20);
        vctl_rptag          VARCHAR2(30);
        vnamafile_ctl       VARCHAR2(120);
        
        vcurr_date          DATE := SYSDATE; 
    BEGIN
        -- 1. Inisialisasi format filter tanggal hari ini (YYYYMMDD)
        vbln_laporan := TO_CHAR(vcurr_date, 'YYYYMMDD');
        
        -- 2. Ambil metadata file RCN
        SELECT COUNT(1), MAX(NAMAFILE), MAX(NOUSULAN)
        INTO vcount_totalfile, vnamafile, vsample_nousulan
        FROM JSON_TABLE(
            JSON_DATA_RCN, '$[*]'
            COLUMNS (
                NAMAFILE VARCHAR2(100) PATH '$.NAMAFILE',
                NOUSULAN VARCHAR2(50)  PATH '$.NOUSULAN'
            )
        );
        
        -- Jika berkas JSON RCN kosong, hentikan proses secara dini
        IF vcount_totalfile = 0 THEN
            pesan := 'Gagal Proses: Isi berkas JSON RCN kosong atau format tidak sesuai.';
            OPEN out_cursor FOR 
                SELECT NULL AS TGLINSERT, NULL AS NAMAFILE, pesan AS MESSAGE, 'GAGAL' AS STATUS, 'UNKNOWN' AS PRODUK FROM DUAL WHERE 1=0;
            RETURN;
        END IF;

        -- 3. Ekstrak data CTL seadanya dari JSON_DATA_RCNCTL
        SELECT 
            JSON_VALUE(JSON_DATA_RCNCTL, '$.RECORD_COUNT'),
            JSON_VALUE(JSON_DATA_RCNCTL, '$.TOTAL_NOMINAL'),
            JSON_VALUE(JSON_DATA_RCNCTL, '$.NAMAFILE_CTL')
        INTO vctl_lembar, vctl_rptag, vnamafile_ctl
        FROM DUAL;

        -- 4. UTAMAKAN: Bulk Insert data detail RCN terlebih dahulu
        INSERT INTO OPHARTDE.VER_DATA_LOCKING_BANK (
            NOUSULAN, TGLUSULAN, VA, KDBANK, IDPEL, BLTH,
            RPTAG, RPBK, TGLBAYAR, JAMBAYAR, USERID, NAMAFILE,
            TGLINSERT
        )
        SELECT 
            jt.NOUSULAN, jt.TGLUSULAN, jt.VA, jt.KDBANK, jt.IDPEL, jt.BLTH,
            jt.RPTAG, jt.RPBK, jt.TGLBAYAR, jt.JAMBAYAR, jt.USERID, jt.NAMAFILE,
            vcurr_date 
        FROM JSON_TABLE(
            JSON_DATA_RCN, '$[*]'
            COLUMNS (
                NOUSULAN  VARCHAR2(25 BYTE)  PATH '$.NOUSULAN',
                TGLUSULAN VARCHAR2(8 BYTE)   PATH '$.TGLUSULAN',      
                VA        VARCHAR2(20 BYTE)  PATH '$.VA',
                KDBANK    VARCHAR2(7 BYTE)   PATH '$.KDBANK',
                IDPEL     VARCHAR2(12 BYTE)  PATH '$.IDPEL',
                BLTH      VARCHAR2(6 BYTE)   PATH '$.BLTH',
                RPTAG     NUMBER(12)         PATH '$.RPTAG',
                RPBK      NUMBER(12)         PATH '$.RPBK',
                TGLBAYAR  VARCHAR2(10 BYTE)  PATH '$.TGLBAYAR',
                JAMBAYAR  VARCHAR2(6 BYTE)   PATH '$.JAMBAYAR',
                USERID    VARCHAR2(25 BYTE)  PATH '$.USERID',  
                NAMAFILE  VARCHAR2(50 BYTE)  PATH '$.NAMAFILE',
                TGLINSERT VARCHAR2(50 BYTE)  PATH '$.TGLINSERT'
            )
        ) jt
        WHERE NOT EXISTS (
            SELECT 1 
            FROM OPHARTDE.VER_DATA_LOCKING_BANK existing
            WHERE existing.NOUSULAN   = jt.NOUSULAN
              AND existing.TGLUSULAN  = jt.TGLUSULAN
              AND existing.IDPEL      = jt.IDPEL
              AND existing.BLTH       = jt.BLTH
        );

        -- Hitung record baru yang sukses masuk database
        vcount_sukses := SQL%ROWCOUNT;

        -- 5. KEDUA: Langsung insert data CTL seadanya tanpa pengecekan silang
        INSERT INTO OPHARTDE.VER_DATA_LOCKING_BANK_CTL (
            NAMAFILE, LEMBAR, RPTAG
        )
        SELECT 
            vnm_ctl.NAMA_CTL, vctl_lembar, vctl_rptag
        FROM (SELECT vnamafile_ctl AS NAMA_CTL FROM DUAL) vnm_ctl
        WHERE NOT EXISTS (
            SELECT 1 
            FROM OPHARTDE.VER_DATA_LOCKING_BANK_CTL existing
            WHERE existing.NAMAFILE = vnm_ctl.NAMA_CTL
        );

        -- ?? PERBAIKAN: Memperbaiki syntax || || yang error dan menambahkan info total baris file sumber (vcount_totalfile)
        pesan := 'Sukses Insert DB. RCN Baru Sukses: ' || vcount_sukses || ' baris, Total Rekord File Sumber: ' || vcount_totalfile; 
        
        -- 6. Tentukan Jenis Produk
        CASE 
            WHEN UPPER(vsample_nousulan) LIKE 'POS%' THEN vproduk := 'POSTPAID';
            WHEN UPPER(vsample_nousulan) LIKE 'NTL%' THEN vproduk := 'NONTAGLIS';
            WHEN UPPER(vsample_nousulan) LIKE 'PRE%' THEN vproduk := 'PREPAID';
            ELSE vproduk := 'UNKNOWN';
        END CASE;
        
        -- 7. Catat Log Sukses
        INSERT INTO OPHARTDE.VER_DATA_LOCKING_BANK_LOG 
            (TGLINSERT, NAMAFILE, MESSAGE, STATUS, PRODUK)
        VALUES 
            (vcurr_date, vnamafile, pesan, 'SUKSES', vproduk);
            
        -- Hanya commit jika kedua insert di atas (RCN & CTL) berhasil tanpa error DB
        COMMIT;      

        -- [SUKSES]: Buka kursor log di sini sebelum end block utama
        OPEN out_cursor FOR
            SELECT TGLINSERT, NAMAFILE, MESSAGE, STATUS, PRODUK
            FROM OPHARTDE.VER_DATA_LOCKING_BANK_LOG  
            WHERE NAMAFILE = vnamafile
              AND TGLINSERT >= TRUNC(vcurr_date);
                     
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; -- Jika salah satu proses insert gagal, batalkan semuanya
            pesan := 'Gagal Insert Detail ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;   
            
            IF vproduk IS NULL THEN vproduk := 'UNKNOWN'; END IF;
            IF vnamafile IS NULL THEN vnamafile := 'UNKNOWN_FILE'; END IF;
            
            INSERT INTO OPHARTDE.VER_DATA_LOCKING_BANK_LOG 
                (TGLINSERT, NAMAFILE, MESSAGE, STATUS, PRODUK)
            VALUES 
                (vcurr_date, vnamafile, pesan, 'GAGAL', vproduk);
            COMMIT;  

            -- [GAGAL]: Buka kursor log alternatif di dalam exception agar Java tetap menerima log errornya
            OPEN out_cursor FOR
                SELECT TGLINSERT, NAMAFILE, MESSAGE, STATUS, PRODUK
                FROM OPHARTDE.VER_DATA_LOCKING_BANK_LOG  
                WHERE NAMAFILE = vnamafile
                  AND TGLINSERT >= TRUNC(vcurr_date);
    END INSERT_ISIFILERCN_REKON_BANK;
    
    PROCEDURE GET_LOG_FILERCN_PROSES(
        in_start         in number,
        in_length        in number,
        in_sort_by       in varchar2,
        in_sort_dir      in varchar2,
        in_search        in varchar2,
        vtglawal   IN VARCHAR2,  -- Format input diharapkan: YYYYMMDD
        vtglakhir  IN VARCHAR2,  -- Format input diharapkan: YYYYMMDD
        out_cursor OUT SYS_REFCURSOR, 
        pesan      OUT VARCHAR2
    ) AS
    BEGIN
        
        
        open out_cursor for
            WITH
                v_core_data AS
                (
                    SELECT TGLINSERT, NAMAFILE, MESSAGE, STATUS, PRODUK
                    FROM OPHARTDE.VER_DATA_LOCKING_BANK_LOG
                    WHERE TGLINSERT >= TO_DATE(vtglawal, 'YYYYMMDD')
                    AND TGLINSERT <  TO_DATE(vtglakhir, 'YYYYMMDD') + 1
                )
            SELECT *
            FROM (
                SELECT
                    x.*,
                    ROW_NUMBER() OVER (
                        ORDER BY 
                            CASE
                                WHEN in_sort_by = 'TGLINSERT'
                                 AND in_sort_dir = 'ASC'
                                THEN x.TGLINSERT
                            END ASC,
                            CASE
                                WHEN in_sort_by = 'TGLINSERT'
                                 AND in_sort_dir = 'DESC'
                                THEN x.TGLINSERT
                            END DESC,
                            x.TGLINSERT ASC
                    ) AS ROW_NUMBER,
                    COUNT(*) OVER () AS TOTAL_COUNT
                FROM v_core_data x
                WHERE to_char(TGLINSERT, 'YYYYMMDD') between  vtglawal and vtglakhir
                AND (
                        in_search IS NULL OR
                        UPPER(x.TGLINSERT) LIKE '%' || UPPER(in_search) || '%' OR
                        UPPER(x.NAMAFILE) LIKE '%' || UPPER(in_search) || '%' OR 
                        UPPER(x.MESSAGE) LIKE '%' || UPPER(in_search) || '%' OR 
                        UPPER(x.STATUS) LIKE '%' || UPPER(in_search) || '%' OR
                        UPPER(x.PRODUK) LIKE '%' || UPPER(in_search) || '%' 
                  )
            )
            ORDER BY ROW_NUMBER
            OFFSET ((in_start - 1) * in_length) ROWS
            FETCH NEXT in_length ROWS ONLY;
                
        pesan := 'Sukses Tampilkan Data.';

    EXCEPTION
        WHEN OTHERS THEN
            -- ROLLBACK dihapus karena tidak ada transaksi DML di blok ini
            pesan := 'Gagal Tampilkan Data : ' || SQLERRM || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;  
            
            -- Mengembalikan kursor kosong agar aplikasi (Java) tidak melempar NullPointerException saat membaca kursor
            OPEN out_cursor FOR 
                SELECT NULL AS TGLINSERT, NULL AS NAMAFILE, NULL AS MESSAGE, NULL AS STATUS, NULL AS PRODUK 
                FROM DUAL WHERE 1=0;
    END GET_LOG_FILERCN_PROSES;

END VER_PROSES_REKON_MIV;
/