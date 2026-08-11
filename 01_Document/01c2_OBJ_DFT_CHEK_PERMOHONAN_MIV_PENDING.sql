VARIABLE   OUT_DATA   REFCURSOR;
DECLARE
   IN_START      NUMBER;
   IN_LENGHT     NUMBER;
   IN_SORT_BY    VARCHAR2 (32767);
   IN_SORT_DIR   VARCHAR2 (32767);
   IN_SEARCH     VARCHAR2 (32767);
   VBLN_USULAN   NUMBER;
   VKDBANK       VARCHAR2 (32767);
   VKD_DIST      VARCHAR2 (32767);
   VKET_PENDING  VARCHAR2 (32767);
   OUT_DATA      SYS_REFCURSOR;
   PESAN         VARCHAR2 (32767);
BEGIN
        --
        IN_START         := 1;
        IN_LENGHT        := 10;
        IN_SORT_BY       := 'KD_DIST';
        IN_SORT_DIR      := 'ASC';
        IN_SEARCH        := '';
        VBLN_USULAN      := '202608'; -- blth laporam miv jika
        VKDBANK          := '111'; -- kode bank
        VKD_DIST         := '00';  -- kode wilayah bank DIK 54 dan 56 jika SAKTI KDWILA/DOST = '00', selain bank dki wilayah bank BTN
        VKET_PENDING     := 'UNPENDING';
        OUT_DATA         := NULL;
        PESAN            := NULL;

    -- 1. Panggil Procedure    
    OPHARTDE.VER_MON_LAP.monlap_miv_dft_mohon_pending (
      IN_START,
      IN_LENGHT,
      IN_SORT_BY,
      IN_SORT_DIR,
      IN_SEARCH,
      VBLN_USULAN,
      VKDBANK,
      VKD_DIST,
      VKET_PENDING,
      :OUT_DATA,
      PESAN);

    -- 2. Tampilkan Pesan Status di Output Log (Ctrl+Shift+O untuk lihat)
    DBMS_OUTPUT.PUT_LINE('Status Eksekusi: ' || PESAN);
END;
PRINT OUT_DATA;