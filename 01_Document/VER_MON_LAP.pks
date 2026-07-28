CREATE OR REPLACE PACKAGE OPHARTDE.VER_MON_LAP AS
    --A combo UPI
    PROCEDURE GET_combo_UNITUPI (vkd_dist varchar2, out_cursor out SYS_REFCURSOR, pesan out VARCHAR);
    --B combo AP
    PROCEDURE GET_combo_UNITAP (vkd_dist in Varchar2,out_cursor out SYS_REFCURSOR, pesan out VARCHAR);
    --C combo BANK MIV
    PROCEDURE GET_combo_BANK_MIV (vkdbank in Varchar2,out_cursor out SYS_REFCURSOR, pesan out VARCHAR);
    
    -----------------------------------------------------------------------------------------
    --1a) Mon Rekap Rekon MIV/SAKTI PLN vs BANK
    PROCEDURE monlap_rkp_mivfalg_plnvsbank_uiw(vbln_usulan IN NUMBER, out_data out sys_refcursor, pesan out varchar2);
    --1b) Mon Daftar Rekon MIV/SAKTI PLN vs BANK
    PROCEDURE monlap_mivfalg_plnvsbank_uiw_pgs(
                    in_start         in number,
                    in_lenght        in number,
                    in_sort_by       in varchar2,
                    in_sort_dir      in varchar2,
                    in_search        in varchar2,
                    vbln_usulan IN NUMBER, vkdbank in VARCHAR, vkd_dist in VARCHAR, out_data out sys_refcursor, pesan out varchar2);  
                    
    PROCEDURE monlap_dft_mivfalg_plnvsbank_uiw_pgs(
                    in_start         in number,
                    in_lenght        in number,
                    in_sort_by       in varchar2,
                    in_sort_dir      in varchar2,
                    in_search        in varchar2,
                    vbln_usulan IN NUMBER, vkdbank in VARCHAR, vkd_dist in VARCHAR, out_data out sys_refcursor, pesan out varchar2);               
  
    --2a) Mon Rekap PERMOHONAN PENDING MIV PLN : AP2T vs P2APST
    PROCEDURE monlap_miv_rkp_mohon_pending(vbln_usulan IN NUMBER,  out_cursor out SYS_REFCURSOR, pesan out VARCHAR);
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
        out_cursor  OUT SYS_REFCURSOR, 
        pesan       OUT VARCHAR2
    );                     
END VER_MON_LAP;
/