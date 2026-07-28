CREATE OR REPLACE PACKAGE OPHARTDE.VER_PROSES_REKON_MIV AS

    PROCEDURE INSERT_ISIFILERCN_REKON_BANK(
        JSON_DATA_RCN  IN CLOB, 
        JSON_DATA_RCNCTL  IN CLOB, 
        out_cursor OUT SYS_REFCURSOR, 
        pesan      OUT VARCHAR2
    );
    
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
    );
    
END VER_PROSES_REKON_MIV;
/