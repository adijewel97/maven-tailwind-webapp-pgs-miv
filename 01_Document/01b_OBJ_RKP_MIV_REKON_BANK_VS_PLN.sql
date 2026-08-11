VARIABLE   OUT_DATA   REFCURSOR;
DECLARE
   VBLN_USULAN   NUMBER;
   OUT_DATA      SYS_REFCURSOR;
   PESAN         VARCHAR2 (32767);
BEGIN
        --
        VBLN_USULAN      := '202607'; -- blth laporam miv jika
        OUT_DATA         := NULL;
        PESAN            := NULL;

    -- 1. Panggil Procedure    
    OPHARTDE.VER_MON_LAP.monlap_rkp_mivfalg_plnvsbank_uiw (
      VBLN_USULAN,
      :OUT_DATA,
      PESAN);

    -- 2. Tampilkan Pesan Status di Output Log (Ctrl+Shift+O untuk lihat)
    DBMS_OUTPUT.PUT_LINE('Status Eksekusi: ' || PESAN);
END;
PRINT OUT_DATA;