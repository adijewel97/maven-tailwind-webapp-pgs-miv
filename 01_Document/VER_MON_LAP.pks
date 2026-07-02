CREATE OR REPLACE PACKAGE OPHARTDE.VER_MON_LAP AS
    PROCEDURE GET_combo_UNITUPI (vkd_dist varchar2, out_cursor out SYS_REFCURSOR, pesan out VARCHAR);
    PROCEDURE GET_combo_UNITAP (vkd_dist in Varchar2,out_cursor out SYS_REFCURSOR, pesan out VARCHAR);
    PROCEDURE GET_combo_BANK_MIV (vkdbank in Varchar2,out_cursor out SYS_REFCURSOR, pesan out VARCHAR);
    PROCEDURE monlap_mivbelumflag_plnvsbank(vbln_usulan IN NUMBER, pilih in VARCHAR,  out_cursor out SYS_REFCURSOR, pesan out VARCHAR);
    PROCEDURE monlap_mivflag_plnvsbank_pusat(vbln_usulan IN NUMBER,  out_cursor out SYS_REFCURSOR, pesan out VARCHAR) ;
    PROCEDURE monlap_mivfalg_plnvsbank_uiw(vbln_usulan IN NUMBER, vkdbank in VARCHAR, vkddist in VARCHAR,vkdarea in VARCHAR, out_cursor out SYS_REFCURSOR, pesan out VARCHAR);
 
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
  
    PROCEDURE monlap_saktiStatus_UnPending_pusat(vbln_usulan IN NUMBER,  out_cursor out SYS_REFCURSOR, pesan out VARCHAR);
    PROCEDURE monlap_saktiDaftar_UnPending_pusat(vbln_usulan IN NUMBER, vkdgol in varchar2, vkdgerak in varchar2,vprqatis in varchar2, out_cursor out SYS_REFCURSOR, pesan out VARCHAR);
  
END VER_MON_LAP;
/