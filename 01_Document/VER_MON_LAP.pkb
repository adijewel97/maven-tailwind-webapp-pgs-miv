CREATE OR REPLACE PACKAGE BODY OPHARTDE.VER_MON_LAP IS
    PROCEDURE GET_combo_UNITUPI (vkd_dist varchar2, out_cursor out SYS_REFCURSOR, pesan out VARCHAR) IS
    vEmsg varchar2(50) default null;
    BEGIN
    pesan:='Gagal Tampilkan Data '; 
    vEmsg:= 'Gagal Tampilkan Data ';      
    open out_cursor for
            select DISTINCT kd_dist,kd_dist ||' - '|| NAMA_DIST as NAMA_DIST
            from OPHARTDE.VER_MASTER_UNIT x
            where decode(nvl(upper(vkd_dist),'ALL'),'ALL','1',x.kd_dist) =  decode(nvl(upper(vkd_dist),'ALL'),'ALL','1',vkd_dist)
            order by kd_DIST;
    pesan :='Sukses Tampilkan Data Ada';
        
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          pesan:='Gagal Proses Data Sudah Ada '||SQLERRM;
          WHEN NO_DATA_FOUND THEN
           pesan:='Gagal Proses Data Tdak Ada, '||vEmsg||'  '||SQLERRM;
        WHEN OTHERS THEN
           pesan:='Gagal Proses Data ' ||SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;  
    END;
  
    PROCEDURE GET_combo_UNITAP (vkd_dist in Varchar2,out_cursor out SYS_REFCURSOR, pesan out VARCHAR) IS
    vEmsg varchar2(50) default null;
    BEGIN
    pesan:='Gagal Tampilkan Data '; 
    vEmsg:= 'Gagal Tampilkan Data ';      
    open out_cursor for
            select '00' kd_dist,null NAMA_DIST,'ALL' UNITAP,'PILIH SEMUA'  NAMA_AREA from dual 
            union  
            select DISTINCT kd_dist,NAMA_DIST,KD_DIST||UNITAP_AP2T UNITAP,  KD_DIST||UNITAP_AP2T||' - '||NAMA_AREA as NAMA_AREA
            from OPHARTDE.VER_MASTER_UNIT
            where kd_dist = vkd_dist;
    pesan :='Sukses Tampilkan Data Ada';
        
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          pesan:='Gagal Proses Data Sudah Ada '||SQLERRM;
          WHEN NO_DATA_FOUND THEN
           pesan:='Gagal Proses Data Tdak Ada, '||vEmsg||'  '||SQLERRM;
        WHEN OTHERS THEN
           pesan:='Gagal Proses Data ' ||SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;  
    END;
  
    PROCEDURE GET_combo_BANK_MIV (vkdbank in Varchar2,out_cursor out SYS_REFCURSOR, pesan out VARCHAR) IS
    vEmsg varchar2(50) default null;
    BEGIN
    pesan:='Gagal Tampilkan Data '; 
    vEmsg:= 'Gagal Tampilkan Data ';      
    open out_cursor for
        select *
        from
        (
            select '0000000' as KODE_ERP, 'ALL' as KODE_BANK, 'PILIH SEMUA' as NAMA_BANK,'1'  STATUS
            from dual
            union
            select DISTINCT KODE_ERP, KODE_BANK, NAMA_BANK, STATUS
            from ophartde.VER_MASTER_BANK
        ) x
        where decode(nvl(upper(vkdbank),'ALL'),'ALL','1',x.KODE_BANK) =  decode(nvl(upper(vkdbank),'ALL'),'ALL','1',vkdbank);
    pesan :='Sukses Tampilkan Data Ada';
        
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          pesan:='Gagal Proses Data Sudah Ada '||SQLERRM;
          WHEN NO_DATA_FOUND THEN
           pesan:='Gagal Proses Data Tdak Ada, '||vEmsg||'  '||SQLERRM;
        WHEN OTHERS THEN
           pesan:='Gagal Proses Data ' ||SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;  
    END;
      
    PROCEDURE monlap_mivbelumflag_plnvsbank(vbln_usulan IN NUMBER, pilih in VARCHAR,  out_cursor out SYS_REFCURSOR, pesan out VARCHAR) IS
    vEmsg varchar2(50) default null;
    cursor data_post  is
     select  a.idpel,a.blth, a.rptag , OLAP.hitungbk (
          sysdate,
           a.blth,
           a.TGLJTTEMPO,
           a.RPBK1,
           a.RPBK2,
           a.RPBK3
        ) rpbk,
        b.nousulan, b.tglinsert, b.rptag rptag_lock
        from plngatepost.dpp a, OPHARTDE.VER_TEMP_DATA_LOCKING b
        where b.idpel = a.idpel
        and b.blth = a.blth
        and substr(b.nousulan,9,6)    = vbln_usulan
        and  b.kdproses = '2'
        and nvl( b.rptag,0) <> nvl( a.rptag,0);

    cursor data_ntl is
        select  a.NOMOR_REGISTRASI ,substr(b.nousulan,9,6)  blth, a.rptag , 0 rpbk,
        b.nousulan, b.tglinsert, b.rptag rptag_lock
        from plngatentl.transaksi_nontaglis a, OPHARTDE.VER_TEMP_DATA_LOCKING_NTL b
        where b.NOREG = a.NOMOR_REGISTRASI
        and substr(b.nousulan,9,6)    = vbln_usulan
        and  b.kdproses = '2'
        and nvl( b.rptag,0) <> nvl( a.rptag,0);

    --        and nvl( b.rptag,0) = 0;
    BEGIN              
    --     vEmsg := 'Error : Hub. Admin, Tidak Bisa Tampilkan Data.';
     for c1 in data_post loop       
            update OPHARTDE.VER_TEMP_DATA_LOCKING
            set rptag = c1.rptag,
                 rpbk   = c1.rpbk
            where  nousulan = c1. nousulan
            and idpel = c1.idpel
            and blth = c1.blth;     
            commit;    
     end loop;
     
     for c1 in data_NTL loop       
            update OPHARTDE.VER_TEMP_DATA_LOCKING_NTL
            set rptag = c1.rptag            
            where  nousulan = c1. nousulan
            and  NOREG = c1.NOMOR_REGISTRASI;     
           commit;    
     end loop;
     
     pesan:='Gagal Tampilkan Data ';
     open out_cursor for
                select   DECODE(substr(p.PLN_NOUSULAN,4,2),'00','SAKTI','MIV') proses,
      ---tampilkan utama 1
        NVL((select
               KD_DIST||' - '||NAMA_DIST KD_DIST from olap.master_distribusi where  KD_DIST= p. KD_DIST and rownum < 2),'00 - PLN PUSAT') KD_DIST
              , p.TGLAPPROVE, p.PLN_NOUSULAN NOUSULAN, p.SATKER
              , (select KODE_BANK||' - '||NAMA_BANK  from OPHARTDE.VER_MASTER_BANK where KODE_BANK = p.PLN_KDBANK and rownum < 2) as Bank
              , p.jml JmlBelumLunas
        --         p.PLN_KDBANK, ,LUNAS_BANK, pln_tglbayar ,BANK_TGLBAYAR
        ,DataUnPending 
        , rptag
        ,Datalbih4lbr
        --, to_char(sysdate,'YYYYMMDD') - substr(p.tglapprove,1,8) Lama_hari
        , to_date(to_char(sysdate,'YYYYMMDD'),'YYYYMMDD') - to_date(substr(p.tglapprove,1,8),'YYYYMMDD') Lama_hari
        ,case  
            WHEN pln_kdbank = '009' THEN
                 case
                    WHEN (p.Datalbih4lbr > 0) and (p.DataUnPending >= p.Datalbih4lbr)  and (P.DataUnPending >= p.jml)  and (p.jml > 4) THEN  '02 - Permohonan ulang Ap2t daftar tanpa >4lb (Khusus BNI)'
                     WHEN (p.Datalbih4lbr = 0)  and (P.DataUnPending = p.jml)  and (to_date(to_char(sysdate,'YYYYMMDD'),'YYYYMMDD') - to_date(substr(p.tglapprove,1,8),'YYYYMMDD')  <= 1)THEN  '00 - Proses Flag Di Bank'
                    else 
                       '01 - Permohonan Ulang AP2T'
                 END
            WHEN (pln_kdbank = '111') or (pln_kdbank = '200')  THEN
                case
                    WHEN  (P.DataUnPending = p.jml)   and  (to_date(to_char(sysdate,'YYYYMMDD'),'YYYYMMDD') - to_date(substr(p.tglapprove,1,8),'YYYYMMDD')  <= 1)THEN  '00 - Proses Flag Di Bank'
                    WHEN  (P.DataUnPending >= p.jml) THEN  '01 - Permohonan Ulang AP2T'
                    else decode(substr(p.PLN_NOUSULAN,1,3),'NTL', '03 - Produk Nontaglis','PRE', '03 - Produk Prepaid')
                 END
             ELSE  'Chek Kode Bank'
        END INDIKASI
        from(
            select w.*
                  , CASE 
                     WHEN  substr( w.pln_nousulan,1,3) = 'POS' THEN 
                       nvl( (
                            select count(*) 
                            from OPHARTDE.VER_TEMP_DATA_LOCKING a
                            where nousulan = w.pln_nousulan
                            and kdproses = '2'
                         ),0) 
                    ELSE 
                     0
                    END DataUnPending
                    , CASE 
                       WHEN  substr( w.pln_nousulan,1,3) = 'POS' THEN                           
                                nvl( (
                                select sum(nvl(rptag,0)+nvl(RPBK,0)) 
                                from OPHARTDE.VER_TEMP_DATA_LOCKING a
                                where nousulan = w.pln_nousulan
                                and kdproses = '2'
                                and STATUS = '1'
                            ),0)  
                         WHEN  substr( w.pln_nousulan,1,3) = 'NTL' THEN  
                              nvl( (
                                    select sum(nvl(rptag,0)) 
                                    from OPHARTDE.VER_TEMP_DATA_LOCKING_NTL a
                                    where nousulan = w.pln_nousulan
                                    and kdproses = '2'
                                    and STATUS = '1'
                                ),0)  
                    ELSE 
                        0
                    END  rptag
                    , nvl( (
                                select sum(count(*)) jml
                                from OPHARTDE.VER_TEMP_DATA_LOCKING a
                                where nousulan = w.pln_nousulan
                                and kdproses = '2'
                                group by idpel 
                                having count(*) > 4
                    ),0) Datalbih4lbr
            from
            (
                With pln_data as
                            (
                                select to_char(tglinsert,'YYYYMMDD HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data' proses,a.va, a.nousulan, a.kdproses, a.status,a.idpel, a.blth,
                                       nvl(b.rptag,0) rptag, nvl(b.rpbk,0) rpbk,b.tglbayar,b.jambayar, b.userid, a.kdbank kdbank
                                       ,a.satker,  (b.tglbayar||'  '||b.jambayar||'  '||b.userid) lunas_H0
                                from ophartde.ver_temp_data_locking a, olap.h2h b
                                where a.idpel       = b.idpel (+)
                                and   a.blth        = b.blth  (+)
                                and   a.kdproses    = '2'
                                and   substr(a.nousulan,9,6)    =  vbln_usulan --'$bln_usulan'
            --                     and   a.kdbank                    = :bank --'$bank'
                                and   a.status                  = '1'
                                --and   nvl(b.suspect,0)  in ('0','2')
                                and   b.suspect  in ('0','2')
                                union
                                select to_char(tglinsert,'YYYYMMDD  HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data' proses,a.va, a.nousulan, a.kdproses, a.status,a.idpel, a.blth,
                                        0 rptag, 0 rpbk,null tglbayar, null jambayar,null userid, a.kdbank kdbank
                                       ,a.satker,  (b.tglbayar||' '||b.jambayar||' '||b.userid) lunas_H0
                                from ophartde.ver_temp_data_locking a, olap.h2h b
                                where a.idpel       = b.idpel (+)
                                and   a.blth        = b.blth  (+)
                                and   a.kdproses    = '2'
                                and   substr(a.nousulan,9,6)    = vbln_usulan --'$bln_usulan'
            --                     and   a.kdbank                    = :bank --'$bank'
                                and   a.status                  = '1'
                                and   b.suspect is null
                            ),
                           bank_data as
                            (
                                select
                                  'bank_data' proses,a.va, a.nousulan, '2' kdproses, '1'  status,a.idpel, a.blth,
                                  nvl(a.rptag,0) rptag, nvl(a.rpbk,0) rpbk,a.tglbayar,a.jambayar, a.userid, a.kdbank kdbank
                                from ophartde.ver_data_locking_bank a
                                where   substr(a.nousulan,9,6)  =  vbln_usulan --'$bln_usulan'
                                -- and tglbayar = '$tglbayar'
            --                    and a.kdbank                     = :bank --'$bank'
                            ),
                           pln_data_ntl as
                            (
                                select to_char(tglinsert,'YYYYMMDD  HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data' proses,a.va, a.nousulan, a.kdproses, a.status,a.noreg idpel, null blth
                                       ,nvl(b.rptag,0) rptag, 0 rpbk,b.tglbayar,b.jambayar, b.userid, a.kdbank kdbank
                                       ,a.satker,  (b.tglbayar||' '||b.jambayar||' '||b.userid) lunas_H0
                                from ophartde.ver_temp_data_locking_ntl a, olap.transaksi_nontaglis b
                                where a.noreg       = b.nomor_registrasi (+)
                                and   a.kdproses    = '2'
                                and   substr(a.nousulan,9,6)    =  vbln_usulan --'$bln_usulan'
            --                     and   a.kdbank                 = :bank --'$bank'
                                and   a.status                  = '1'
                                and   b.suspect  in ('0','2')
                                union
                                select to_char(tglinsert,'YYYYMMDD  HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data' proses,a.va, a.nousulan,
                                 a.kdproses, a.status,a.noreg idpel, null blth, 
                                  0 rptag, 0 rpbk, null tglbayar, null jambayar, null userid, a.kdbank kdbank
                                 ,a.satker,  (b.tglbayar||' '||b.jambayar||' '||b.userid) lunas_H0
                                from ophartde.ver_temp_data_locking_ntl a, olap.transaksi_nontaglis b
                                where a.noreg       = b.nomor_registrasi (+)
                                and   a.kdproses    = '2'
                                and   substr(a.nousulan,9,6)    =  vbln_usulan --'$bln_usulan'
            --                     and   a.kdbank                 = :bank --'$bank'
                                and   a.status                  = '1'
                                and   b.suspect is null
                            ),
                           bank_data_ntl as
                            (
                                select
                                  'bank_data' proses,a.va, a.nousulan, '2' kdproses, '1'  status,a.noreg idpel, null blth,
                                  nvl(a.rptag,0) rptag, 0 rpbk,a.tglbayar,a.jambayar, a.userid, a.kdbank kdbank
                                from ophartde.ver_data_locking_bank_ntl a
                                where   substr(a.nousulan,9,6)    =  vbln_usulan --'$bln_usulan'
                                --and tglbayar = '$tglbayar'
            --                    and a.kdbank = :bank --'$bank'
                            ),
                           pln_data_pre as
                            (
                                select (select distinct to_char(tglinsert,'YYYYMMDD  HH24:MI') from OPHARTDE.VER_TEMP_DATA_LOCKING_PRE where nousulan = z.nousulan) tglapprove,
                                        z.kddist, z.proses, z.va, z.nousulan, z.kdproses, z.status, z.idpel, null blth,
                                       nvl(z.rptag,0) rptag, 0 rpbk, z.tglbayar, z.jambayar, z.userid, z.kdbank, z.satker, z.lunas_H0
                                from
                                (
                                    (
                                        select
                                            rownum baris, f.kddist,f.proses,
                                            f.va, f.nousulan, f.kdproses, f.status, f.idpel, f.rptag,
                                            null tglbayar, null jambayar,
                                            f.userid,  f.KDBANK, f.satker, decode(f.lunas_H0,1,null,f.lunas_H0) lunas_H0
                                        from
                                        (
                                                select  substr(a.nousulan,4,2) kddist,'pln_data_pre' proses,a.va,
                                                        a.nousulan, '2' kdproses, a.status,a.idpel,
                                                        a.rptag, A.KDBANK||'CA01' userid,A.KDBANK,a.satker, '1' lunas_H0
                                                from OPHARTDE.VER_TEMP_DATA_LOCKING_PRE a
                                                where to_char(tglinsert,'YYYYMM') =  vbln_usulan --'$bln_usulan'
                                                and    substr(a.nousulan,4,2)  in (select distinct kd_dist from OLAP.MASTER_DISTRIBUSI )  --=  :apj 
                                                minus
                                                select  substr(a.nousulan,4,2) kddist,'pln_data_pre' proses,a.va,
                                                a.nousulan, '2' kdproses, a.status,a.idpel, a.rptag,
                                                b.userid,  a.KDBANK,a.satker,  '1' lunas_H0
                                                from
                                                    (
                                                       select  count(*) jml,  substr(m.nousulan,4,2) kd_dist, m.nousulan, m.tglusulan, m.idpel, m.rptag ,
                                                             m.kdbank, m.satker, m.va, m.status, m.KDBANK userid,
                                                             to_char(tglinsert,'YYYYMMDD') tglapprove
                                                       -- to_char(tglinsert,'YYYYMMDD') tglapprove, to_char(tglinsert+4,'YYYYMMDD') maxtgltgltrans
                                                       from OPHARTDE.VER_TEMP_DATA_LOCKING_PRE m
                                                       where to_char(tglinsert,'YYYYMM') =  vbln_usulan --'$bln_usulan'
                                                       group by  substr(m.nousulan,4,2) , m.nousulan, m.tglusulan, m.idpel, m.rptag,m.kdbank,
                                                                m.satker, m.va, status, m.KDBANK,
                                                                to_char(m.tglinsert,'YYYYMMDD')
                                                    ) a, OLAP.TRANSAKSI_PREPAID b
                                                    where  a.idpel    = b.idpel(+)
                                                    and    a.rptag    = b.rptag
                                                    and    a.TGLAPPROVE <= b.tglbayar
                                                    and    substr(b.tglbayar,1,6)  =  vbln_usulan --'$bln_usulan'
                                                    and    substr(a.nousulan,4,2)  in (select distinct kd_dist from OLAP.MASTER_DISTRIBUSI )  --=  :apj  -- '$apj'
            --                                        and    a.kdbank    = :bank --'$bank'
                                                    and    b.UNSOLD is null
                                                    and    B.TGL_REKON is not null
                                            ) f
                                    )
                                    union
                                    ( 
                                       select rownum baris, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data_pre' proses,
                                         a.va, a.nousulan, '2' kdproses, a.status,a.idpel, a.rptag,
                                         b.tglbayar,b.jambayar,
                                         b.userid,  a.KDBANK, a.satker,  (b.tglbayar||' '||b.Jambayar||' '||b.Userid) lunas_H0
                                        from
                                            (
                                               select  count(*) jml, substr(m.nousulan,4,2) kd_dist, m.nousulan, m.tglusulan, m.idpel, m.rptag ,
                                                     m.kdbank, m.satker, m.va, m.status, m.KDBANK userid,
                                                     to_char(tglinsert,'YYYYMMDD') tglapprove
                                               from OPHARTDE.VER_TEMP_DATA_LOCKING_PRE m
                                               where to_char(tglinsert,'YYYYMM') =  vbln_usulan --'$bln_usulan'
                                               group by  substr(m.nousulan,4,2), m.nousulan, m.tglusulan, m.idpel, m.rptag,m.kdbank,
                                                        m.satker, m.va, status, m.KDBANK,
                                                        to_char(m.tglinsert,'YYYYMMDD')
                                            ) a, OLAP.TRANSAKSI_PREPAID b
                                            where  a.idpel    = b.idpel(+)
                                            and    a.rptag    = b.rptag
                                            and    a.TGLAPPROVE <= b.tglbayar
                                            and    substr(b.tglbayar,1,6)  = vbln_usulan --'$bln_usulan'
                                            --and    b.kd_dist   =  :apj  -- '$apj'
                                            and    substr(a.nousulan,4,2)   in (select distinct kd_dist from OLAP.MASTER_DISTRIBUSI )  --=  :apj  -- '$apj'  
            --                                and    a.kdbank    = :bank --'$bank'
                                            and    b.UNSOLD is null
                                            and    B.TGL_REKON is not null
                                       )
                                ) z
                            ),
                           bank_data_pre as
                            (
                                select
                                  'bank_data' proses,a.va, a.nousulan, '2' kdproses, '1'  status,a.idpel, null blth,
                                  nvl(a.rptag,0) rptag, 0 rpbk,a.tglbayar,a.jambayar, a.userid, a.kdbank kdbank
                                from ophartde.ver_data_locking_bank_pre a
                                where   substr(a.nousulan,9,6)    =  vbln_usulan --'$bln_usulan'
            --                    and a.kdbank = :bank --'$bank'
                            )
                --tampilkan data
                select 
                   KD_DIST,max(TGLAPPROVE) TGLAPPROVE , PLN_NOUSULAN , SATKER, decode(PLN_KDBANK,'009', PLN_KDBANK||' - '||'BNI','111',PLN_KDBANK||' - '||'BANK DKI','200',PLN_KDBANK||' - '||'BTN')  Bank
                   , PLN_KDBANK, count(*) jml, substr(trim(PLN_LUNAS_H0),17,3) LUNAS_BANK
                   , pln_tglbayar ,BANK_TGLBAYAR
                from
                (
                    (
                        select 1 urut,'POSTPAID' produk, x.*,
                        nvl(x.pln_rptag,0)-nvl(x.bank_rptag,0) selisih_rptag,
                        nvl(x.pln_rpbk,0)-nvl(x.bank_rpbk,0) selisih_bk,
                        case
                            when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) = 0) and (pln_idpel = bank_idpel )
                                 and (pln_blth = bank_blth )
                               then ''
                            when (pln_idpel is null) and (bank_idpel is not null)
                               then 'selisih - data usulan pln (tidak ada), data pelunasan bank (ada)'
                            when (pln_idpel is not null) and (pln_tglbayar is null) and (bank_idpel is null)
                               then 'selisih - data usulan pln (ada)/tidak lunas, data pelunasan bank (tidak ada)/tidak lunas (Belum Flag Bank/belum rekon)'
                            when (pln_idpel is not null and bank_idpel is not null ) and (pln_tglbayar is null and bank_tglbayar is not null)
                               then 'selisih - data usulan pln (ada)/tidak lunas , data pelunasan bank (ada)/lunas (Chek Reversal Sukses Dijawab PLN)'
                            when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) = PLN_KDBANK)
                                then 'selisih - data usulan pln (ada)/lunas , data pelunasan bank (Tidak ada)/Tidak lunas (Konfirmasi/Log Bank/Belum Rekon)'
                            when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is null)
                                then 'selisih - data usulan pln (ada)/lunas (ppob/bukan miv), data pelunasan bank (Tidak ada)/Tidak lunas'
                            when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is not null)
                                then 'selisih - data usulan pln (ada)/lunas (Bank Lain), data pelunasan bank (ada)/lunas (Konfirmasi/Log Bank)'
                            else 'selisih - belum teridentifikasi'
                         end as keterangan
                        from
                         (
                            select a.tglapprove,
                                 nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker, a.nousulan pln_nousulan, a.kdproses pln_kdproses, a.status pln_status, a.idpel pln_idpel, a.blth pln_blth
                                 , lunas_H0 pln_lunas_H0,a.rptag pln_rptag, a.rpbk pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,a.kdbank pln_kdbank,
                                 b. Proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                                 nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,
                                 b.kdbank bank_kdbank
                            from pln_data a, bank_data b
                            where a.nousulan = b.nousulan (+)
                            and   a.idpel    = b.idpel (+)
                            and   a.blth     = b.blth (+)
                        union
                        select a.tglapprove,
                             nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va,a.satker,nvl(a.nousulan,b.nousulan) pln_nousulan, nvl(a.kdproses,'2') pln_kdproses, nvl(a.status,1) pln_status, a.idpel pln_idpel, a.blth pln_blth
                             ,lunas_H0 pln_lunas_H0, nvl(a.rptag,0) pln_rptag, nvl(a.rpbk,0) pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,nvl(a.kdbank,b.kdbank) pln_kdbank,
                             b.proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                             nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,nvl(b.kdbank,a.kdbank) bank_kdbank
                        from pln_data a, bank_data b
                        where b.nousulan = a.nousulan (+)
                        and   b.idpel    = a.idpel (+)
                        and   b.blth     = a.blth (+)
                        and   a.kdbank is null
                     ) x
                        where kd_dist in (select distinct kd_dist from OLAP.MASTER_DISTRIBUSI )  --=  :apj  -- '$apj'
                        or kd_dist = '00'
                    )
                    union
                    (
                        select 2 urut,'NONTAGLIS' produk, x.*,
                        nvl(x.pln_rptag,0)-nvl(x.bank_rptag,0) selisih_rptag,
                        nvl(x.pln_rpbk,0)-nvl(x.bank_rpbk,0) selisih_bk,
                        case
                            when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) = 0) and (pln_idpel = bank_idpel )
                               then ''
                            when (pln_idpel is null) and (bank_idpel is not null)
                               then 'selisih - data usulan pln (tidak ada), data pelunasan bank (ada)'
                            when (pln_idpel is not null) and (pln_tglbayar is null) and (bank_idpel is null)
                               then 'selisih - data usulan pln (ada), data pelunasan bank (tidak ada)/tidak lunas'
                            when (pln_idpel is not null and bank_idpel is not null ) and (pln_tglbayar is null and bank_tglbayar is not null)
                               then 'selisih - data usulan pln (ada)/tidak lunas , data pelunasan bank (ada)/lunas (Chek Reversal Sukses Dijawab PLN)'
                            when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) = PLN_KDBANK)
                                then 'selisih - data usulan pln (ada)/lunas , data pelunasan bank (Tidak ada)/Tidak lunas (Konfirmasi/Log Bank/Belum Rekon)'
                            when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is null)
                                then 'selisih - data usulan pln (ada)/lunas (ppob/bukan miv), data pelunasan bank (Tidak ada)/Tidak lunas'
                            when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is not null)
                                then 'selisih - data usulan pln (ada)/lunas (Bank Lain), data pelunasan bank (ada)/lunas (Konfirmasi/Log Bank)'
                            else 'selisih - belum teridentifikasi'
                         end as keterangan
                        from
                        (
                            select a.tglapprove,
                                 nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va,a.satker, a.nousulan pln_nousulan, a.kdproses pln_kdproses, a.status pln_status,
                                 a.idpel pln_idpel, a.blth pln_blth
                                 ,lunas_H0 pln_lunas_H0,
                                 a.rptag pln_rptag, a.rpbk pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,a.kdbank pln_kdbank,
                                 b. Proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                                 nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,
                                 b.kdbank bank_kdbank
                            from pln_data_ntl a, bank_data_ntl b
                            where a.nousulan = b.nousulan (+)
                            and   a.idpel    = b.idpel (+)
                            union
                            select a.tglapprove,
                                 nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker,nvl(a.nousulan,b.nousulan) pln_nousulan, nvl(a.kdproses,'2') pln_kdproses, nvl(a.status,1) pln_status, a.idpel pln_idpel, a.blth pln_blth
                                 ,lunas_H0 pln_lunas_H0,nvl(a.rptag,0) pln_rptag, nvl(a.rpbk,0) pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,nvl(a.kdbank,b.kdbank) pln_kdbank,
                                 b.proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                                 nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,nvl(b.kdbank,a.kdbank) bank_kdbank
                            from pln_data_ntl a, bank_data_ntl b
                            where b.nousulan = a.nousulan (+)
                            and   b.idpel    = a.idpel (+)
                            and   a.kdbank is null
                         ) x
                        where kd_dist in (select distinct kd_dist from OLAP.MASTER_DISTRIBUSI )  --=  :apj  -- '$apj'
                     )
                    union
                    (
                        select 3 urut,'PREPAID' produk, x.*,
                        nvl(x.pln_rptag,0)-nvl(x.bank_rptag,0) selisih_rptag,
                        nvl(x.pln_rpbk,0)-nvl(x.bank_rpbk,0) selisih_bk,
                        case
                            when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) = 0) and (pln_idpel = bank_idpel )
                               then ''
                            when (pln_idpel is null) and (bank_idpel is not null)
                               then 'selisih - data usulan pln (tidak ada), data pelunasan bank (ada)'
                            when (pln_idpel is not null) and (pln_tglbayar is null) and (bank_idpel is null)
                               then 'selisih - data usulan pln (ada), data pelunasan bank (tidak ada)/tidak lunas'
                            when (pln_idpel is not null and bank_idpel is not null ) and (pln_tglbayar is null and bank_tglbayar is not null)
                               then 'selisih - data usulan pln (ada)/tidak lunas , data pelunasan bank (ada)/lunas (Chek Reversal Sukses Dijawab PLN)'
                            when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) = PLN_KDBANK)
                                then 'selisih - data usulan pln (ada)/lunas , data pelunasan bank (Tidak ada)/Tidak lunas (Konfirmasi/Log Bank/Belum Rekon)'
                            when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is null)
                                then 'selisih - data usulan pln (ada)/lunas (ppob/bukan miv), data pelunasan bank (Tidak ada)/Tidak lunas'
                            when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is not null)
                                then 'selisih - data usulan pln (ada)/lunas (Bank Lain), data pelunasan bank (ada)/lunas (Konfirmasi/Log Bank)'
                            else 'selisih - belum teridentifikasi'
                         end as keterangan
                        from
                        (
                            select a.tglapprove,
                                 nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker, a.nousulan pln_nousulan, a.kdproses pln_kdproses, a.status pln_status,
                                 a.idpel pln_idpel, a.blth pln_blth
                                 ,lunas_H0 pln_lunas_H0,a.rptag pln_rptag, a.rpbk pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,a.kdbank pln_kdbank,
                                 b. Proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                                 nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,
                                 b.kdbank bank_kdbank
                            from pln_data_pre a, bank_data_pre b
                            where a.nousulan = b.nousulan (+)
                            and   a.idpel    = b.idpel (+)
                            union
                            select a.tglapprove,
                                 nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker,nvl(a.nousulan,b.nousulan) pln_nousulan, nvl(a.kdproses,'2') pln_kdproses, nvl(a.status,1) pln_status, a.idpel pln_idpel, a.blth pln_blth
                                 ,lunas_H0 pln_lunas_H0, nvl(a.rptag,0) pln_rptag, nvl(a.rpbk,0) pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,nvl(a.kdbank,b.kdbank) pln_kdbank,
                                 b.proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                                 nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,nvl(b.kdbank,a.kdbank) bank_kdbank
                            from pln_data_pre a, bank_data_pre b
                            where b.nousulan = a.nousulan (+)
                            and   b.idpel    = a.idpel (+)
                            and   a.kdbank is null
                         ) x
                         where kd_dist in (select distinct kd_dist from OLAP.MASTER_DISTRIBUSI )  --=  :apj  -- '$apj'
                    )   
                 )
                where PLN_TGLBAYAR is null  
                --or PLN_TGLBAYAR is not null   --jika ada pelunasan tapi tidak ada RCN bank
                and BANK_TGLBAYAR is null
                and trim(substr(PLN_LUNAS_H0,17,3)) is null  -- chek h0
                --and lunas_bank <> '009'
                --where PLN_TGLBAYAR is not null 
                --and BANK_TGLBAYAR is not null
                --and NVL(PLN_LUNAS_H0,'X') = '  '
                --and  trim(substr(PLN_LUNAS_H0,17,3))  is null
                --where BANK_TGLBAYAR is not null
                --and kd_dist = '51'http://10.71.1.159/P2APST/rekon/fileRekonH2h#fcn
                --and substr(tglapprove,1,8) >= '20210216'
                --and PLN_NOUSULAN = 'POS5210020210920065'
                group by  KD_DIST,PLN_NOUSULAN, SATKER,PLN_KDBANK,substr(trim(PLN_LUNAS_H0),17,3)
                ,PLN_TGLBAYAR,BANK_TGLBAYAR
                order by tglapprove, KD_DIST,PLN_NOUSULAN
            )    w
        ) P
        where decode(nvl(upper(pilih),'ALL'),'ALL','1',p.PLN_KDBANK) =  decode(nvl(upper(pilih),'ALL'),'ALL','1',pilih)
        order by pln_kdbank,  tglapprove, kd_DIST;
        pesan:='Sukses Tampilkan Data Ada ' ;
        
         EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                  pesan:='Gagal Proses Data Sudah Ada '||SQLERRM;
                  WHEN NO_DATA_FOUND THEN
                   pesan:='Gagal Proses Data Tdak Ada, '||vEmsg||'  '||SQLERRM;
                WHEN OTHERS THEN
                   pesan:='Gagal Proses Data ' ||SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;      
    END;

    PROCEDURE monlap_mivflag_plnvsbank_pusat(vbln_usulan IN NUMBER,  out_cursor out SYS_REFCURSOR, pesan out VARCHAR) IS
    vEmsg varchar2(50) default null;
    BEGIN
          
    --     vEmsg := 'Error : Hub. Admin, Tidak Bisa Tampilkan Data.';
     pesan:='Gagal Tampilkan Data ';
     open out_cursor for
            With pln_data as
                    (
                        select                                   
                               to_char(tglinsert,'YYYYMMDD HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data' proses,a.va, a.nousulan, a.kdproses, a.status,a.idpel, a.blth,
                               nvl(b.rptag,0) rptag, nvl(b.rpbk,0) rpbk,b.tglbayar,b.jambayar, b.userid, a.kdbank kdbank
                               ,a.satker,  (b.tglbayar||'  '||b.jambayar||'  '||b.userid) lunas_H0
                        from ophartde.ver_temp_data_locking a, olap.h2h b
                        where a.idpel       = b.idpel (+)
                        and   a.blth        = b.blth  (+)
                        and   a.kdproses    = '2'
    --                                and   substr(a.nousulan,9,6)    = :vbln_usulan 
                        and   to_char(tglinsert,'YYYYMM') = vbln_usulan
        --                 and   a.kdbank                    = :bank --'$bank'
                        and   a.status                  = '1'
                        --and   nvl(b.suspect,0)  in ('0','2')
                        and   b.suspect  in ('0','2')
                        union
                        select to_char(tglinsert,'YYYYMMDD  HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data' proses,a.va, a.nousulan, a.kdproses, a.status,a.idpel, a.blth,
                                0 rptag, 0 rpbk,null tglbayar, null jambayar,null userid, a.kdbank kdbank
                               ,a.satker,  (b.tglbayar||' '||b.jambayar||' '||b.userid) lunas_H0
                        from ophartde.ver_temp_data_locking a, olap.h2h b
                        where a.idpel       = b.idpel (+)
                        and   a.blth        = b.blth  (+)
                        and   a.kdproses    = '2'
                        --and   substr(a.nousulan,9,6)    = :vbln_usulan --'$bln_usulan'
                        and to_char(tglinsert,'YYYYMM') = vbln_usulan
        --                 and   a.kdbank                    = :bank --'$bank'
                        and   a.status                  = '1'
                        and   b.suspect is null
                    ),
                   bank_data as
                    (
                        select
                          'bank_data' proses,a.va, a.nousulan, '2' kdproses, '1'  status,a.idpel, a.blth,
                          nvl(a.rptag,0) rptag, nvl(a.rpbk,0) rpbk,a.tglbayar,a.jambayar, a.userid, a.kdbank kdbank
                        from ophartde.ver_data_locking_bank a
                        --where   substr(a.nousulan,9,6)  = :vbln_usulan --'$bln_usulan'
                        where  to_char(tglinsert,'YYYYMM') = vbln_usulan
                        -- and tglbayar = '$tglbayar'
        --                and a.kdbank                     = :bank --'$bank'
                    ),
                   pln_data_ntl as
                    (
                        select to_char(tglinsert,'YYYYMMDD  HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data' proses,a.va, a.nousulan, a.kdproses, a.status,a.noreg idpel, null blth
                               ,nvl(b.rptag,0) rptag, 0 rpbk,b.tglbayar,b.jambayar, b.userid, a.kdbank kdbank
                               ,a.satker,  (b.tglbayar||' '||b.jambayar||' '||b.userid) lunas_H0
                        from ophartde.ver_temp_data_locking_ntl a, olap.transaksi_nontaglis b
                        where a.noreg       = b.nomor_registrasi (+)
                        and   a.kdproses    = '2'
                        --and   substr(a.nousulan,9,6)    = :vbln_usulan --'$bln_usulan'
                        and to_char(tglinsert,'YYYYMM') = vbln_usulan
        --                 and   a.kdbank                 = :bank --'$bank'
                        and   a.status                  = '1'
                        and   b.suspect  in ('0','2')
                        union
                        select to_char(tglinsert,'YYYYMMDD  HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data' proses,a.va, a.nousulan,
                         a.kdproses, a.status,a.noreg idpel, null blth, 
                          0 rptag, 0 rpbk, null tglbayar, null jambayar, null userid, a.kdbank kdbank
                         ,a.satker,  (b.tglbayar||' '||b.jambayar||' '||b.userid) lunas_H0
                        from ophartde.ver_temp_data_locking_ntl a, olap.transaksi_nontaglis b
                        where a.noreg       = b.nomor_registrasi (+)
                        and   a.kdproses    = '2'
                        --and   substr(a.nousulan,9,6)    = :vbln_usulan --'$bln_usulan'
                        and to_char(tglinsert,'YYYYMM') = vbln_usulan
        --                 and   a.kdbank                 = :bank --'$bank'
                        and   a.status                  = '1'
                        and   b.suspect is null
                    ),
                   bank_data_ntl as
                    (
                        select
                          'bank_data' proses,a.va, a.nousulan, '2' kdproses, '1'  status,a.noreg idpel, null blth,
                          nvl(a.rptag,0) rptag, 0 rpbk,a.tglbayar,a.jambayar, a.userid, a.kdbank kdbank
                        from ophartde.ver_data_locking_bank_ntl a
                        --where   substr(a.nousulan,9,6)    = :vbln_usulan --'$bln_usulan'
                        where to_char(tglinsert,'YYYYMM') = vbln_usulan
                        --and tglbayar = '$tglbayar'
        --                and a.kdbank = :bank --'$bank'
                    ),
                   pln_data_pre as
                    (
                        select (select distinct to_char(tglinsert,'YYYYMMDD  HH24:MI') from ophartde.VER_TEMP_DATA_LOCKING_PRE where nousulan = z.nousulan) tglapprove,
                                z.kddist, z.proses, z.va, z.nousulan, z.kdproses, z.status, z.idpel, null blth,
                               nvl(z.rptag,0) rptag, 0 rpbk, z.tglbayar, z.jambayar, z.userid, z.kdbank, z.satker, z.lunas_H0
                        from
                        (
                            (
                                select
                                    rownum baris, f.kddist,f.proses,
                                    f.va, f.nousulan, f.kdproses, f.status, f.idpel, f.rptag,
                                    null tglbayar, null jambayar,
                                    f.userid,  f.KDBANK, f.satker, decode(f.lunas_H0,1,null,f.lunas_H0) lunas_H0
                                from
                                (
                                        select  substr(a.nousulan,4,2) kddist,'pln_data_pre' proses,a.va,
                                                a.nousulan, '2' kdproses, a.status,a.idpel,
                                                a.rptag, A.KDBANK||'CA01' userid,A.KDBANK,a.satker, '1' lunas_H0
                                        from ophartde.VER_TEMP_DATA_LOCKING_PRE a
                                        where to_char(tglinsert,'YYYYMM') = vbln_usulan --'$bln_usulan'
                                        and    substr(a.nousulan,4,2)  in (select distinct kd_dist from olap.MASTER_DISTRIBUSI )  --=  :apj 
                                        minus
                                        select  substr(a.nousulan,4,2) kddist,'pln_data_pre' proses,a.va,
                                        a.nousulan, '2' kdproses, a.status,a.idpel, a.rptag,
                                        b.userid,  a.KDBANK,a.satker,  '1' lunas_H0
                                        from
                                            (
                                               select  count(*) jml,  substr(m.nousulan,4,2) kd_dist, m.nousulan, m.tglusulan, m.idpel, m.rptag ,
                                                     m.kdbank, m.satker, m.va, m.status, m.KDBANK userid,
                                                     to_char(tglinsert,'YYYYMMDD') tglapprove
                                               -- to_char(tglinsert,'YYYYMMDD') tglapprove, to_char(tglinsert+4,'YYYYMMDD') maxtgltgltrans
                                               from ophartde.VER_TEMP_DATA_LOCKING_PRE m
                                               where to_char(tglinsert,'YYYYMM') = vbln_usulan --'$bln_usulan'
                                               group by  substr(m.nousulan,4,2) , m.nousulan, m.tglusulan, m.idpel, m.rptag,m.kdbank,
                                                        m.satker, m.va, status, m.KDBANK,
                                                        to_char(m.tglinsert,'YYYYMMDD')
                                            ) a, olap.TRANSAKSI_PREPAID b
                                            where  a.idpel    = b.idpel(+)
                                            and    a.rptag    = b.rptag
                                            and    a.TGLAPPROVE <= b.tglbayar
                                            and    substr(b.tglbayar,1,6)  = vbln_usulan --'$bln_usulan'
                                            and    substr(a.nousulan,4,2)  in (select distinct kd_dist from olap.MASTER_DISTRIBUSI )  --=  :apj  -- '$apj'
        --                                    and    a.kdbank    = :bank --'$bank'
                                            and    b.UNSOLD is null
                                            and    B.TGL_REKON is not null
                                    ) f
                            )
                            union
                            ( 
                               select rownum baris, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data_pre' proses,
                                 a.va, a.nousulan, '2' kdproses, a.status,a.idpel, a.rptag,
                                 b.tglbayar,b.jambayar,
                                 b.userid,  a.KDBANK, a.satker,  (b.tglbayar||' '||b.Jambayar||' '||b.Userid) lunas_H0
                                from
                                    (
                                       select  count(*) jml, substr(m.nousulan,4,2) kd_dist, m.nousulan, m.tglusulan, m.idpel, m.rptag ,
                                             m.kdbank, m.satker, m.va, m.status, m.KDBANK userid,
                                             to_char(tglinsert,'YYYYMMDD') tglapprove
                                       from ophartde.VER_TEMP_DATA_LOCKING_PRE m
                                       where to_char(tglinsert,'YYYYMM') = vbln_usulan --'$bln_usulan'
                                       group by  substr(m.nousulan,4,2), m.nousulan, m.tglusulan, m.idpel, m.rptag,m.kdbank,
                                                m.satker, m.va, status, m.KDBANK,
                                                to_char(m.tglinsert,'YYYYMMDD')
                                    ) a, olap.TRANSAKSI_PREPAID b
                                    where  a.idpel    = b.idpel(+)
                                    and    a.rptag    = b.rptag
                                    and    a.TGLAPPROVE <= b.tglbayar
                                    and    substr(b.tglbayar,1,6)  = vbln_usulan --'$bln_usulan'
                                    --and    b.kd_dist   =  :apj  -- '$apj'
                                    and    substr(a.nousulan,4,2)   in (select distinct kd_dist from olap.MASTER_DISTRIBUSI )  --=  :apj  -- '$apj'  
        --                            and    a.kdbank    = :bank --'$bank'
                                    and    b.UNSOLD is null
                                    and    B.TGL_REKON is not null
                               )
                        ) z
                    ),
                   bank_data_pre as
                    (
                        select
                          'bank_data' proses,a.va, a.nousulan, '2' kdproses, '1'  status,a.idpel, null blth,
                          nvl(a.rptag,0) rptag, 0 rpbk,a.tglbayar,a.jambayar, a.userid, a.kdbank kdbank
                        from ophartde.ver_data_locking_bank_pre a
                        --where   substr(a.nousulan,9,6)    = :vbln_usulan --'$bln_usulan'
                        where to_char(tglinsert,'YYYYMM') = vbln_usulan
        --                and a.kdbank = :bank --'$bank'
                    )
        --tampilkan data
        select Y.KD_DIST, Y.nama_dist DIST, 
    --                         w.pln_tglbayar, w.bank_tglbayar,
                 case 
                   when (sum(nvl(pln_rptag,0)) > 0) 
                   then  (select KODE_BANK||' - '||NAMA_BANK   from ophartde.VER_MASTER_BANK where KODE_BANK =  w.pln_kdbank)  else null
                 end NAMA_BANK,                         
                 case 
                   when sum(nvl(pln_rptag,0)) > 0 
                   then  count(*)  else 0
                 end jml,                           
                 to_char(
                 case 
                   when sum(nvl(pln_rptag,0)) > 0 
                   then  sum(nvl(pln_rptag,0))  else 0
                 end,'999999999999')  rptag,
                 count(w.bank_tglbayar) bank_lbr,
                 sum(nvl(bank_rptag,0)) bank_rptag,
                 (( case 
                   when sum(nvl(pln_rptag,0)) > 0 
                   then  count(*)  else 0
                 end ) -  count(w.bank_tglbayar)) as blmrekon_lbr,
                 ( (
                     case 
                       when sum(nvl(pln_rptag,0)) > 0 
                       then  sum(nvl(pln_rptag,0))  else 0
                     end ) - sum(nvl(bank_rptag,0)) ) as blmrekon_rptag                   
        from
        (
            (
                select 1 urut,'POSTPAID' produk, x.*,
                nvl(x.pln_rptag,0)-nvl(x.bank_rptag,0) selisih_rptag,
                nvl(x.pln_rpbk,0)-nvl(x.bank_rpbk,0) selisih_bk,
                case
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) = 0) and (pln_idpel = bank_idpel )
                         and (pln_blth = bank_blth )
                       then ''
                    when (pln_idpel is null) and (bank_idpel is not null)
                       then 'selisih - data usulan pln (tidak ada), data pelunasan bank (ada)'
                    when (pln_idpel is not null) and (pln_tglbayar is null) and (bank_idpel is null)
                       then 'selisih - data usulan pln (ada)/tidak lunas, data pelunasan bank (tidak ada)/tidak lunas (Belum Flag Bank/belum rekon)'
                    when (pln_idpel is not null and bank_idpel is not null ) and (pln_tglbayar is null and bank_tglbayar is not null)
                       then 'selisih - data usulan pln (ada)/tidak lunas , data pelunasan bank (ada)/lunas (Chek Reversal Sukses Dijawab PLN)'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) = PLN_KDBANK)
                        then 'selisih - data usulan pln (ada)/lunas , data pelunasan bank (Tidak ada)/Tidak lunas (Konfirmasi/Log Bank/Belum Rekon)'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is null)
                        then 'selisih - data usulan pln (ada)/lunas (ppob/bukan miv), data pelunasan bank (Tidak ada)/Tidak lunas'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is not null)
                        then 'selisih - data usulan pln (ada)/lunas (Bank Lain), data pelunasan bank (ada)/lunas (Konfirmasi/Log Bank)'
                    else 'selisih - belum teridentifikasi'
                 end as keterangan
                from
                 (
                    select a.tglapprove,
                         nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker, a.nousulan pln_nousulan, a.kdproses pln_kdproses, a.status pln_status, a.idpel pln_idpel, a.blth pln_blth
                         , lunas_H0 pln_lunas_H0,a.rptag pln_rptag, a.rpbk pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,a.kdbank pln_kdbank,
                         b. Proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                         nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,
                         b.kdbank bank_kdbank
                    from pln_data a, bank_data b
                    where a.nousulan = b.nousulan (+)
                    and   a.idpel    = b.idpel (+)
                    and   a.blth     = b.blth (+)
                union
                select a.tglapprove,
                     nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va,a.satker,nvl(a.nousulan,b.nousulan) pln_nousulan, nvl(a.kdproses,'2') pln_kdproses, nvl(a.status,1) pln_status, a.idpel pln_idpel, a.blth pln_blth
                     ,lunas_H0 pln_lunas_H0, nvl(a.rptag,0) pln_rptag, nvl(a.rpbk,0) pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,nvl(a.kdbank,b.kdbank) pln_kdbank,
                     b.proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                     nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,nvl(b.kdbank,a.kdbank) bank_kdbank
                from pln_data a, bank_data b
                where b.nousulan = a.nousulan (+)
                and   b.idpel    = a.idpel (+)
                and   b.blth     = a.blth (+)
                and   a.kdbank is null
             ) x
                where kd_dist in (select distinct kd_dist from olap.MASTER_DISTRIBUSI )  --=  :apj  -- '$apj'
            )
            union
            (
                select 2 urut,'NONTAGLIS' produk, x.*,
                nvl(x.pln_rptag,0)-nvl(x.bank_rptag,0) selisih_rptag,
                nvl(x.pln_rpbk,0)-nvl(x.bank_rpbk,0) selisih_bk,
                case
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) = 0) and (pln_idpel = bank_idpel )
                       then ''
                    when (pln_idpel is null) and (bank_idpel is not null)
                       then 'selisih - data usulan pln (tidak ada), data pelunasan bank (ada)'
                    when (pln_idpel is not null) and (pln_tglbayar is null) and (bank_idpel is null)
                       then 'selisih - data usulan pln (ada), data pelunasan bank (tidak ada)/tidak lunas'
                    when (pln_idpel is not null and bank_idpel is not null ) and (pln_tglbayar is null and bank_tglbayar is not null)
                       then 'selisih - data usulan pln (ada)/tidak lunas , data pelunasan bank (ada)/lunas (Chek Reversal Sukses Dijawab PLN)'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) = PLN_KDBANK)
                        then 'selisih - data usulan pln (ada)/lunas , data pelunasan bank (Tidak ada)/Tidak lunas (Konfirmasi/Log Bank/Belum Rekon)'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is null)
                        then 'selisih - data usulan pln (ada)/lunas (ppob/bukan miv), data pelunasan bank (Tidak ada)/Tidak lunas'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is not null)
                        then 'selisih - data usulan pln (ada)/lunas (Bank Lain), data pelunasan bank (ada)/lunas (Konfirmasi/Log Bank)'
                    else 'selisih - belum teridentifikasi'
                 end as keterangan
                from
                (
                    select a.tglapprove,
                         nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va,a.satker, a.nousulan pln_nousulan, a.kdproses pln_kdproses, a.status pln_status,
                         a.idpel pln_idpel, a.blth pln_blth
                         ,lunas_H0 pln_lunas_H0,
                         a.rptag pln_rptag, a.rpbk pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,a.kdbank pln_kdbank,
                         b. Proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                         nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,
                         b.kdbank bank_kdbank
                    from pln_data_ntl a, bank_data_ntl b
                    where a.nousulan = b.nousulan (+)
                    and   a.idpel    = b.idpel (+)
                    union
                    select a.tglapprove,
                         nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker,nvl(a.nousulan,b.nousulan) pln_nousulan, nvl(a.kdproses,'2') pln_kdproses, nvl(a.status,1) pln_status, a.idpel pln_idpel, a.blth pln_blth
                         ,lunas_H0 pln_lunas_H0,nvl(a.rptag,0) pln_rptag, nvl(a.rpbk,0) pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,nvl(a.kdbank,b.kdbank) pln_kdbank,
                         b.proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                         nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,nvl(b.kdbank,a.kdbank) bank_kdbank
                    from pln_data_ntl a, bank_data_ntl b
                    where b.nousulan = a.nousulan (+)
                    and   b.idpel    = a.idpel (+)
                    and   a.kdbank is null
                 ) x
                where kd_dist in (select distinct kd_dist from olap.MASTER_DISTRIBUSI )  --=  :apj  -- '$apj'
             )
            union
            (
                select 3 urut,'PREPAID' produk, x.*,
                nvl(x.pln_rptag,0)-nvl(x.bank_rptag,0) selisih_rptag,
                nvl(x.pln_rpbk,0)-nvl(x.bank_rpbk,0) selisih_bk,
                case
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) = 0) and (pln_idpel = bank_idpel )
                       then ''
                    when (pln_idpel is null) and (bank_idpel is not null)
                       then 'selisih - data usulan pln (tidak ada), data pelunasan bank (ada)'
                    when (pln_idpel is not null) and (pln_tglbayar is null) and (bank_idpel is null)
                       then 'selisih - data usulan pln (ada), data pelunasan bank (tidak ada)/tidak lunas'
                    when (pln_idpel is not null and bank_idpel is not null ) and (pln_tglbayar is null and bank_tglbayar is not null)
                       then 'selisih - data usulan pln (ada)/tidak lunas , data pelunasan bank (ada)/lunas (Chek Reversal Sukses Dijawab PLN)'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) = PLN_KDBANK)
                        then 'selisih - data usulan pln (ada)/lunas , data pelunasan bank (Tidak ada)/Tidak lunas (Konfirmasi/Log Bank/Belum Rekon)'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is null)
                        then 'selisih - data usulan pln (ada)/lunas (ppob/bukan miv), data pelunasan bank (Tidak ada)/Tidak lunas'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is not null)
                        then 'selisih - data usulan pln (ada)/lunas (Bank Lain), data pelunasan bank (ada)/lunas (Konfirmasi/Log Bank)'
                    else 'selisih - belum teridentifikasi'
                 end as keterangan
                from
                (
                    select a.tglapprove,
                         nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker, a.nousulan pln_nousulan, a.kdproses pln_kdproses, a.status pln_status,
                         a.idpel pln_idpel, a.blth pln_blth
                         ,lunas_H0 pln_lunas_H0,a.rptag pln_rptag, a.rpbk pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,a.kdbank pln_kdbank,
                         b. Proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                         nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,
                         b.kdbank bank_kdbank
                    from pln_data_pre a, bank_data_pre b
                    where a.nousulan = b.nousulan (+)
                    and   a.idpel    = b.idpel (+)
                    union
                    select a.tglapprove,
                         nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker,nvl(a.nousulan,b.nousulan) pln_nousulan, nvl(a.kdproses,'2') pln_kdproses, nvl(a.status,1) pln_status, a.idpel pln_idpel, a.blth pln_blth
                         ,lunas_H0 pln_lunas_H0, nvl(a.rptag,0) pln_rptag, nvl(a.rpbk,0) pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,nvl(a.kdbank,b.kdbank) pln_kdbank,
                         b.proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                         nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,nvl(b.kdbank,a.kdbank) bank_kdbank
                    from pln_data_pre a, bank_data_pre b
                    where b.nousulan = a.nousulan (+)
                    and   b.idpel    = a.idpel (+)
                    and   a.kdbank is null
                 ) x
                 where kd_dist in (select distinct kd_dist from olap.MASTER_DISTRIBUSI )  --=  :apj  -- '$apj'
            )   
         ) w, olap.master_distribusi y
        where Y.kd_dist = W.kd_dist (+)
        and Y.kd_dist not in ('15','25')
        group by y.KD_DIST, Y.nama_dist, w.pln_kdbank
    --                , w.pln_tglbayar, w.bank_tglbayar
        order by y.KD_DIST, Y.nama_dist, w.pln_kdbank;
       
         pesan:='Sukses Tampilkan Data Ada ';
        
         EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                  pesan:='Gagal Proses Data Sudah Ada '||SQLERRM;
                  WHEN NO_DATA_FOUND THEN
                   pesan:='Gagal Proses Data Tdak Ada, '||vEmsg||'  '||SQLERRM;
                WHEN OTHERS THEN
                   pesan:='Gagal Proses Data ' ||SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;      
    END;
  
    PROCEDURE monlap_mivfalg_plnvsbank_uiw(vbln_usulan IN NUMBER, vkdbank in VARCHAR, vkddist in VARCHAR,vkdarea in VARCHAR, out_cursor out SYS_REFCURSOR, pesan out VARCHAR) IS
    --   TMPCUR_OUT SYS_REFCURSOR;
    vEmsg varchar2(50) default null;
    sql_text  CLOB;
    BEGIN
          
        vEmsg := 'Error : Hub. Admin, Gagal Tampilkan Proses Data.';
        pesan:='Gagal Tampilkan Proses Data';   
         
        open out_cursor  for 
            With pln_data as
                    (
                        select to_char(tglinsert,'YYYYMMDD HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data' proses,a.va, a.nousulan, a.kdproses, a.status,a.idpel, a.blth,
                               nvl(b.rptag,0) rptag, nvl(b.rpbk,0) rpbk,b.tglbayar,b.jambayar, b.userid, a.kdbank kdbank
                               ,a.satker,  (b.tglbayar||'  '||b.jambayar||'  '||b.userid) lunas_H0
                        from ophartde.ver_temp_data_locking a, olap.h2h b
                        where a.idpel       = b.idpel (+)
                        and   a.blth        = b.blth  (+)
                        and   a.kdproses    = '2'
                        --and   substr(a.nousulan,9,6)    =   :vbln_usulan
                        and to_char(tglinsert,'YYYYMM') = vbln_usulan
                        and   a.kdbank                    = vkdbank
                        and   a.status                  = '1'
                        --and   nvl(b.suspect,0)  in ('0','2')
                        and   b.suspect  in ('0','2')
                        union
                        select to_char(tglinsert,'YYYYMMDD  HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data' proses,a.va, a.nousulan, a.kdproses, a.status,a.idpel, a.blth,
                                0 rptag, 0 rpbk,null tglbayar, null jambayar,null userid, a.kdbank kdbank
                               ,a.satker,  (b.tglbayar||' '||b.jambayar||' '||b.userid) lunas_H0
                        from ophartde.ver_temp_data_locking a, olap.h2h b
                        where a.idpel       = b.idpel (+)
                        and   a.blth        = b.blth  (+)
                        and   a.kdproses    = '2'
                        --and   substr(a.nousulan,9,6)    =   :vbln_usulan
                         and to_char(tglinsert,'YYYYMM') = vbln_usulan
                         and   a.kdbank                    =vkdbank
                        and   a.status                  = '1'
                        and   b.suspect is null
                    ),
                    bank_data as
                    (
                        select
                          'bank_data' proses,a.va, a.nousulan, '2' kdproses, '1'  status,a.idpel, a.blth,
                          nvl(a.rptag,0) rptag, nvl(a.rpbk,0) rpbk,a.tglbayar,a.jambayar, a.userid, a.kdbank kdbank
                        from ophartde.ver_data_locking_bank a
                        --where   substr(a.nousulan,9,6)  =   :vbln_usulan
                         WHERE to_char(tglinsert,'YYYYMM') = vbln_usulan
                        -- and tglbayar = '$tglbayar'
                        and a.kdbank                     =vkdbank
                    ),
                    pln_data_ntl as
                    (
                        select to_char(tglinsert,'YYYYMMDD  HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data' proses,a.va, a.nousulan, a.kdproses, a.status,a.noreg idpel, null blth
                               ,nvl(b.rptag,0) rptag, 0 rpbk,b.tglbayar,b.jambayar, b.userid, a.kdbank kdbank
                               ,a.satker,  (b.tglbayar||' '||b.jambayar||' '||b.userid) lunas_H0
                        from ophartde.ver_temp_data_locking_ntl a, olap.transaksi_nontaglis b
                        where a.noreg       = b.nomor_registrasi (+)
                        and   a.kdproses    = '2'
                        --and   substr(a.nousulan,9,6)    =   :vbln_usulan
                        and to_char(tglinsert,'YYYYMM') = vbln_usulan
                        and   a.kdbank                 =vkdbank
                        and   a.status                  = '1'
                        and   b.suspect  in ('0','2')
                        union
                        select to_char(tglinsert,'YYYYMMDD  HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data' proses,a.va, a.nousulan,
                         a.kdproses, a.status,a.noreg idpel, null blth,
                          0 rptag, 0 rpbk, null tglbayar, null jambayar, null userid, a.kdbank kdbank
                         ,a.satker,  (b.tglbayar||' '||b.jambayar||' '||b.userid) lunas_H0
                        from ophartde.ver_temp_data_locking_ntl a, olap.transaksi_nontaglis b
                        where a.noreg       = b.nomor_registrasi (+)
                        and   a.kdproses    = '2'
                        --and   substr(a.nousulan,9,6)    =   :vbln_usulan
                        and to_char(tglinsert,'YYYYMM') = vbln_usulan
                        and   a.kdbank                 =vkdbank
                        and   a.status                  = '1'
                        and   b.suspect is null
                    ),
                    bank_data_ntl as
                    (
                        select
                          'bank_data' proses,a.va, a.nousulan, '2' kdproses, '1'  status,a.noreg idpel, null blth,
                          nvl(a.rptag,0) rptag, 0 rpbk,a.tglbayar,a.jambayar, a.userid, a.kdbank kdbank
                        from ophartde.ver_data_locking_bank_ntl a
                        --where   substr(a.nousulan,9,6)    =   :vbln_usulan
                        where  to_char(tglinsert,'YYYYMM') = vbln_usulan
                        --and tglbayar = '$tglbayar'
                        and a.kdbank =vkdbank
                    ),
                    pln_data_pre as
                    (
                        select (select distinct to_char(tglinsert,'YYYYMMDD  HH24:MI') from OPHARTDE.VER_TEMP_DATA_LOCKING_PRE where nousulan = z.nousulan) tglapprove,
                                z.kddist, z.proses, z.va, z.nousulan, z.kdproses, z.status, z.idpel, null blth,
                               nvl(z.rptag,0) rptag, 0 rpbk, z.tglbayar, z.jambayar, z.userid, z.kdbank, z.satker, z.lunas_H0
                        from
                        (
                            (
                                select
                                    rownum baris, f.kddist,f.proses,
                                    f.va, f.nousulan, f.kdproses, f.status, f.idpel, f.rptag,
                                    null tglbayar, null jambayar,
                                    f.userid,  f.KDBANK, f.satker, decode(f.lunas_H0,1,null,f.lunas_H0) lunas_H0
                                from
                                (
                                        select  substr(a.nousulan,4,2) kddist,'pln_data_pre' proses,a.va,
                                                a.nousulan, '2' kdproses, a.status,a.idpel,
                                                a.rptag, A.KDBANK||'CA01' userid,A.KDBANK,a.satker, '1' lunas_H0
                                        from OPHARTDE.VER_TEMP_DATA_LOCKING_PRE a
                                        where to_char(tglinsert,'YYYYMM') =   vbln_usulan
                                        and    substr(a.nousulan,4,2)  = vkddist
                                        minus
                                        select  substr(a.nousulan,4,2) kddist,'pln_data_pre' proses,a.va,
                                        a.nousulan, '2' kdproses, a.status,a.idpel, a.rptag,
                                        b.userid,  a.KDBANK,a.satker,  '1' lunas_H0
                                        from
                                            (
                                               select  count(*) jml,  substr(m.nousulan,4,2) kd_dist, m.nousulan, m.tglusulan, m.idpel, m.rptag ,
                                                     m.kdbank, m.satker, m.va, m.status, m.KDBANK userid,
                                                     to_char(tglinsert,'YYYYMMDD') tglapprove
                                               -- to_char(tglinsert,'YYYYMMDD') tglapprove, to_char(tglinsert+4,'YYYYMMDD') maxtgltgltrans
                                               from OPHARTDE.VER_TEMP_DATA_LOCKING_PRE m
                                               where to_char(tglinsert,'YYYYMM') =   vbln_usulan
                                               group by  substr(m.nousulan,4,2) , m.nousulan, m.tglusulan, m.idpel, m.rptag,m.kdbank,
                                                        m.satker, m.va, status, m.KDBANK,
                                                        to_char(m.tglinsert,'YYYYMMDD')
                                            ) a, OLAP.TRANSAKSI_PREPAID b
                                            where  a.idpel    = b.idpel(+)
                                            and    a.rptag    = b.rptag
                                            and    a.TGLAPPROVE <= b.tglbayar
                                            and    substr(b.tglbayar,1,6)  =   vbln_usulan
                                            and    substr(a.nousulan,4,2)  =   vkddist
                                            and    a.kdbank    =vkdbank
                                            and    b.UNSOLD is null
                                            and    B.TGL_REKON is not null
                                    ) f
                            )
                            union
                            (
                               select rownum baris, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data_pre' proses,
                                 a.va, a.nousulan, '2' kdproses, a.status,a.idpel, a.rptag,
                                 b.tglbayar,b.jambayar,
                                 b.userid,  a.KDBANK, a.satker,  (b.tglbayar||' '||b.Jambayar||' '||b.Userid) lunas_H0
                                from
                                    (
                                       select  count(*) jml, substr(m.nousulan,4,2) kd_dist, m.nousulan, m.tglusulan, m.idpel, m.rptag ,
                                             m.kdbank, m.satker, m.va, m.status, m.KDBANK userid,
                                             to_char(tglinsert,'YYYYMMDD') tglapprove
                                       from OPHARTDE.VER_TEMP_DATA_LOCKING_PRE m
                                       where to_char(tglinsert,'YYYYMM') =   vbln_usulan
                                       group by  substr(m.nousulan,4,2), m.nousulan, m.tglusulan, m.idpel, m.rptag,m.kdbank,
                                                m.satker, m.va, status, m.KDBANK,
                                                to_char(m.tglinsert,'YYYYMMDD')
                                    ) a, OLAP.TRANSAKSI_PREPAID b
                                    where  a.idpel    = b.idpel(+)
                                    and    a.rptag    = b.rptag
                                    and    a.TGLAPPROVE <= b.tglbayar
                                    and    substr(b.tglbayar,1,6)  =   vbln_usulan
                                    --and    b.kd_dist   =   :vkddist
                                    and    substr(a.nousulan,4,2)   =   vkddist
                                    and    a.kdbank    =vkdbank
                                    and    b.UNSOLD is null
                                    and    B.TGL_REKON is not null
                               )
                        ) z
                    ),
                    bank_data_pre as
                    (
                        select
                          'bank_data' proses,a.va, a.nousulan, '2' kdproses, '1'  status,a.idpel, null blth,
                          nvl(a.rptag,0) rptag, 0 rpbk,a.tglbayar,a.jambayar, a.userid, a.kdbank kdbank
                        from ophartde.ver_data_locking_bank_pre a
                        --where   substr(a.nousulan,9,6)    =   :vbln_usulan
                        where to_char(tglinsert,'YYYYMM') = vbln_usulan
                        and a.kdbank =vkdbank
                    )
                    select * from
                    (
                        (
                        select 1 urut,'POSTPAID' produk, x.*,
                        nvl(x.pln_rptag,0)-nvl(x.bank_rptag,0) selisih_rptag,
                        nvl(x.pln_rpbk,0)-nvl(x.bank_rpbk,0) selisih_bk,
                        case
                        when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) = 0) and (pln_idpel = bank_idpel )
                             and (pln_blth = bank_blth )
                           then ''
                        when (pln_idpel is null) and (bank_idpel is not null)
                           then 'selisih - data usulan pln (tidak ada), data pelunasan bank (ada)'
                        when (pln_idpel is not null) and (pln_tglbayar is null) and (bank_idpel is null)
                           then 'selisih - data usulan pln (ada)/tidak lunas, data pelunasan bank (tidak ada)/tidak lunas (Belum Flag Bank/belum rekon)'
                        when (pln_idpel is not null and bank_idpel is not null ) and (pln_tglbayar is null and bank_tglbayar is not null)
                           then 'selisih - data usulan pln (ada)/tidak lunas , data pelunasan bank (ada)/lunas (Chek Reversal Sukses Dijawab PLN)'
                        when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) = PLN_KDBANK)
                            then 'selisih - data usulan pln (ada)/lunas , data pelunasan bank (Tidak ada)/Tidak lunas (Konfirmasi/Log Bank/Belum Rekon)'
                        when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is null)
                            then 'selisih - data usulan pln (ada)/lunas (ppob/bukan miv), data pelunasan bank (Tidak ada)/Tidak lunas'
                        when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is not null)
                            then 'selisih - data usulan pln (ada)/lunas (Bank Lain), data pelunasan bank (ada)/lunas (Konfirmasi/Log Bank)'
                        else 'selisih - belum teridentifikasi'
                        end as keterangan
                        from
                        (
                        select a.tglapprove,
                             nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker, a.nousulan pln_nousulan, a.kdproses pln_kdproses, a.status pln_status, a.idpel pln_idpel, a.blth pln_blth
                             , lunas_H0 pln_lunas_H0,a.rptag pln_rptag, a.rpbk pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,a.kdbank pln_kdbank,
                             b. Proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                             nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,
                             b.kdbank bank_kdbank
                        from pln_data a, bank_data b
                        where a.nousulan = b.nousulan (+)
                        and   a.idpel    = b.idpel (+)
                        and   a.blth     = b.blth (+)
                        union
                        select a.tglapprove,
                         nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va,a.satker,nvl(a.nousulan,b.nousulan) pln_nousulan, nvl(a.kdproses,'2') pln_kdproses, nvl(a.status,1) pln_status, a.idpel pln_idpel, a.blth pln_blth
                         ,lunas_H0 pln_lunas_H0, nvl(a.rptag,0) pln_rptag, nvl(a.rpbk,0) pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,nvl(a.kdbank,b.kdbank) pln_kdbank,
                         b.proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                         nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,nvl(b.kdbank,a.kdbank) bank_kdbank
                        from pln_data a, bank_data b
                        where b.nousulan = a.nousulan (+)
                        and   b.idpel    = a.idpel (+)
                        and   b.blth     = a.blth (+)
                        and   a.kdbank is null
                        ) x
                        where kd_dist =   vkddist
                        )
                        union
                        (
                        select 2 urut,'NONTAGLIS' produk, x.*,
                        nvl(x.pln_rptag,0)-nvl(x.bank_rptag,0) selisih_rptag,
                        nvl(x.pln_rpbk,0)-nvl(x.bank_rpbk,0) selisih_bk,
                        case
                        when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) = 0) and (pln_idpel = bank_idpel )
                           then ''
                        when (pln_idpel is null) and (bank_idpel is not null)
                           then 'selisih - data usulan pln (tidak ada), data pelunasan bank (ada)'
                        when (pln_idpel is not null) and (pln_tglbayar is null) and (bank_idpel is null)
                           then 'selisih - data usulan pln (ada), data pelunasan bank (tidak ada)/tidak lunas'
                        when (pln_idpel is not null and bank_idpel is not null ) and (pln_tglbayar is null and bank_tglbayar is not null)
                           then 'selisih - data usulan pln (ada)/tidak lunas , data pelunasan bank (ada)/lunas (Chek Reversal Sukses Dijawab PLN)'
                        when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) = PLN_KDBANK)
                            then 'selisih - data usulan pln (ada)/lunas , data pelunasan bank (Tidak ada)/Tidak lunas (Konfirmasi/Log Bank/Belum Rekon)'
                        when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is null)
                            then 'selisih - data usulan pln (ada)/lunas (ppob/bukan miv), data pelunasan bank (Tidak ada)/Tidak lunas'
                        when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is not null)
                            then 'selisih - data usulan pln (ada)/lunas (Bank Lain), data pelunasan bank (ada)/lunas (Konfirmasi/Log Bank)'
                        else 'selisih - belum teridentifikasi'
                        end as keterangan
                        from
                        (
                        select a.tglapprove,
                             nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va,a.satker, a.nousulan pln_nousulan, a.kdproses pln_kdproses, a.status pln_status,
                             a.idpel pln_idpel, a.blth pln_blth
                             ,lunas_H0 pln_lunas_H0,
                             a.rptag pln_rptag, a.rpbk pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,a.kdbank pln_kdbank,
                             b. Proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                             nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,
                             b.kdbank bank_kdbank
                        from pln_data_ntl a, bank_data_ntl b
                        where a.nousulan = b.nousulan (+)
                        and   a.idpel    = b.idpel (+)
                        union
                        select a.tglapprove,
                             nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker,nvl(a.nousulan,b.nousulan) pln_nousulan, nvl(a.kdproses,'2') pln_kdproses, nvl(a.status,1) pln_status, a.idpel pln_idpel, a.blth pln_blth
                             ,lunas_H0 pln_lunas_H0,nvl(a.rptag,0) pln_rptag, nvl(a.rpbk,0) pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,nvl(a.kdbank,b.kdbank) pln_kdbank,
                             b.proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                             nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,nvl(b.kdbank,a.kdbank) bank_kdbank
                        from pln_data_ntl a, bank_data_ntl b
                        where b.nousulan = a.nousulan (+)
                        and   b.idpel    = a.idpel (+)
                        and   a.kdbank is null
                        ) x
                        --                where kd_dist =   :vkddist
                        )
                        union
                        (
                        select 3 urut,'PREPAID' produk, x.*,
                        nvl(x.pln_rptag,0)-nvl(x.bank_rptag,0) selisih_rptag,
                        nvl(x.pln_rpbk,0)-nvl(x.bank_rpbk,0) selisih_bk,
                        case
                        when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) = 0) and (pln_idpel = bank_idpel )
                           then ''
                        when (pln_idpel is null) and (bank_idpel is not null)
                           then 'selisih - data usulan pln (tidak ada), data pelunasan bank (ada)'
                        when (pln_idpel is not null) and (pln_tglbayar is null) and (bank_idpel is null)
                           then 'selisih - data usulan pln (ada), data pelunasan bank (tidak ada)/tidak lunas'
                        when (pln_idpel is not null and bank_idpel is not null ) and (pln_tglbayar is null and bank_tglbayar is not null)
                           then 'selisih - data usulan pln (ada)/tidak lunas , data pelunasan bank (ada)/lunas (Chek Reversal Sukses Dijawab PLN)'
                        when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) = PLN_KDBANK)
                            then 'selisih - data usulan pln (ada)/lunas , data pelunasan bank (Tidak ada)/Tidak lunas (Konfirmasi/Log Bank/Belum Rekon)'
                        when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is null)
                            then 'selisih - data usulan pln (ada)/lunas (ppob/bukan miv), data pelunasan bank (Tidak ada)/Tidak lunas'
                        when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is not null)
                            then 'selisih - data usulan pln (ada)/lunas (Bank Lain), data pelunasan bank (ada)/lunas (Konfirmasi/Log Bank)'
                        else 'selisih - belum teridentifikasi'
                        end as keterangan
                        from
                        (
                        select a.tglapprove,
                             nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker, a.nousulan pln_nousulan, a.kdproses pln_kdproses, a.status pln_status,
                             a.idpel pln_idpel, a.blth pln_blth
                             ,lunas_H0 pln_lunas_H0,a.rptag pln_rptag, a.rpbk pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,a.kdbank pln_kdbank,
                             b. Proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                             nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,
                             b.kdbank bank_kdbank
                        from pln_data_pre a, bank_data_pre b
                        where a.nousulan = b.nousulan (+)
                        and   a.idpel    = b.idpel (+)
                        union
                        select a.tglapprove,
                             nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker,nvl(a.nousulan,b.nousulan) pln_nousulan, nvl(a.kdproses,'2') pln_kdproses, nvl(a.status,1) pln_status, a.idpel pln_idpel, a.blth pln_blth
                             ,lunas_H0 pln_lunas_H0, nvl(a.rptag,0) pln_rptag, nvl(a.rpbk,0) pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,nvl(a.kdbank,b.kdbank) pln_kdbank,
                             b.proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                             nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,nvl(b.kdbank,a.kdbank) bank_kdbank
                        from pln_data_pre a, bank_data_pre b
                        where b.nousulan = a.nousulan (+)
                        and   b.idpel    = a.idpel (+)
                        and   a.kdbank is null
                        ) x
                        where kd_dist =   vkddist
                        )
                     )
                     where decode(nvl(vkdarea,'ALL'),'ALL','ALL',substr(PLN_NOUSULAN,4,5) ) = decode(nvl(vkdarea,'ALL'),'ALL','ALL',vkdarea);
            
        IF vkdarea = 'SEMUA' or vkdarea = 'ALL' THEN
             pesan :='Sukses Tampilkan Data Ada All';
        ELSE
             pesan :='Sukses Tampilkan Data Ada Area Layanan';
        END IF;
        
         EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                  pesan:='Gagal Proses Data Sudah Ada '||SQLERRM;
                  WHEN NO_DATA_FOUND THEN
                   pesan:='Gagal Proses Data Tdak Ada, '||vEmsg||'  '||SQLERRM;
                WHEN OTHERS THEN
                   pesan:='Gagal Proses Data ' ||SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;      
    END;
  
  

    PROCEDURE monlap_saktiStatus_UnPending_pusat(vbln_usulan IN NUMBER,  out_cursor out SYS_REFCURSOR, pesan out VARCHAR) IS
    vEmsg varchar2(50) default null;
    BEGIN
          
     vEmsg := ' SAKTI ';
     pesan:='Gagal Tampilkan Data ';
     open out_cursor for
        select PROSES, KOGOL, sum(JML) jml, to_char(sum(RPTAG),'999999999999') RPTAG, KDGERAK, STATUS, USERID, BANK_MIV
                 , case 
                  when (BANK_MIV = '01 - MIV') THEN
                      'BATAL SAKTI= '||sum(batal_sakti)||', UPENDING AP2T PLN='|| abs(sum(batal_sakti)-sum(jml))
                  when (BANK_MIV <> '01 - MIV') and ( sum(batal_sakti) = 0) THEN 
                      'BATAL SAKTI= '||sum(batal_sakti)||', BATAL MANUAL PLN='|| sum(jml)
                  when (BANK_MIV is null) and ( sum(batal_sakti) > 0)  and  (STATUS ='PENDING') THEN 
                     'BATAL SAKTI='||sum(batal_sakti)
                  when (BANK_MIV is null) and ( sum(batal_sakti) = 0) THEN 
                    NULL
                  else
                      'BATAL SAKTI='||sum(batal_sakti)||', BATAL MANUAL PLN='|| abs(sum(batal_sakti)-sum(jml))
                    end KETERANGAN
        from
        (
            select 
                   'SAKTI' Proses, substr(LTRIM(a.KOGOL),1,1) KOGOL
                   , count(*) jml,  sum(a.RPTAG) RPTAG
                   , decode(kdgerak,'12','11',kdgerak)||' - '||decode(kdgerak,'11','BELUM LUNAS','12','BELUM LUNAS','13','BELUM LUNAS','22','LUNAS ONLINE'
                                  ,'21','LUNAS OFFLINE','24','LUNAS BEBAN KTR','25','LUNAS LEGALISASI', '31','BATAL MURNI',null) kdgerak
                   ,  decode(praqtis,0,'PENDING','UNPENDING') STATUS
                   , decode(a.userid,'UNLOCK',null, (select NAMA_BANK from OLAP.MASTER_BANK  where KODE_BANK = substr(a.userid,1,3) and rownum < 2)) userid
                   , case 
                       when substr(a.userid,1,3) = '111' and (a.tgltrans < to_char(sysdate,'YYYYMM')||'18' )then
                           '02 - MIV/NON-MIV (TGL.LUNAS < 18)'
                       when substr(a.userid,1,3) = '111' and (a.tgltrans >= to_char(sysdate,'YYYYMM')||'18' )then
                           '01 - MIV'
                       when (a.userid is null or a.userid  =  'UNLOCK') then 
                            null                       
                       ELSE
                           '03 - NON-MIV'
                       END BANK_MIV
                       , sum(decode(KDPROSES,3,1,0)) batal_sakti
            from OPHARTDE.VER_TEMP_DATA_LOCKING_SAKTI b, plngatepost.dpp a
            where b.idpel = a.idpel
            and b.blth = a.blth
            and  b.BLTH_USUL = vbln_usulan
            group by substr(a.userid,1,3), a.tgltrans, substr(LTRIM(a.KOGOL),1,1)
                     ,  a.kdgerak, a.praqtis, A.USERID
        ) x
        group by PROSES, KOGOL, KDGERAK, STATUS, USERID, BANK_MIV
        order by BANK_MIV , USERID;
    pesan :='Sukses Tampilkan Data Ada';
        
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          pesan:='Gagal Proses Data Sudah Ada '||SQLERRM;
          WHEN NO_DATA_FOUND THEN
           pesan:='Gagal Proses Data Tdak Ada, '||vEmsg||'  '||SQLERRM;
        WHEN OTHERS THEN
           pesan:='Gagal Proses Data ' ||SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;      

    END;
    
    --1a) Mon Rekap Rekon MIV/SAKTI PLN vs BANK
    PROCEDURE monlap_rkp_mivfalg_plnvsbank_uiw(vbln_usulan IN NUMBER, out_data out sys_refcursor, pesan out varchar2) is
        vEmsg varchar2(50) default null;
    BEGIN
        vEmsg := 'Gagal Tampilkan Data ';
        pesan := 'Gagal Tampilkan Data ';
        open out_data for
             --------------------------------------------------------------------
            --  REKAP MIV/SAKTI PerDISTRIBUSI/PerWILAYAH
            --  contoh input tarik data rekon sakti BANK vs P2APST
            --  Tekan ctrl+enter mausukan :
            ---    bln_usulan : 202503 -- Tahun Bulan Falging Sakti yang diminta
            ---    bank       : 111    -- kode bank DKI 3 digit
            ---    apj        : 00     -- sakti seluruh UID/UIW seindonesia
            --------------------------------------------------------------------
            With pln_data as
                (
                    select to_char(tglinsert,'YYYYMMDD HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data' proses,a.va, a.nousulan, a.kdproses, a.status,a.idpel, a.blth,
                           nvl(b.rptag,0) rptag, nvl(b.rpbk,0) rpbk,b.tglbayar,b.jambayar, b.userid, a.kdbank kdbank
                           ,a.satker,  (b.tglbayar||'  '||b.jambayar||'  '||b.userid) lunas_H0
                    from ophartde.ver_temp_data_locking a, olap.h2h b
                    where a.idpel       = b.idpel (+)
                    and   a.blth        = b.blth  (+)
                    and   a.kdproses    = '2'
                    and   substr(a.nousulan,9,6)       = vbln_usulan
            --        and  a.kdbank                      = :vkdbank
                    and   a.status                     = '1'
                    --and   nvl(b.suspect,0)  in ('0','2')
                    and   b.suspect  in ('0','2')
                    union
                    select to_char(tglinsert,'YYYYMMDD  HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data' proses,a.va, a.nousulan, a.kdproses, a.status,a.idpel, a.blth,
                            0 rptag, 0 rpbk,null tglbayar, null jambayar,null userid, a.kdbank kdbank
                           ,a.satker,  (b.tglbayar||' '||b.jambayar||' '||b.userid) lunas_H0
                    from ophartde.ver_temp_data_locking a, olap.h2h b
                    where a.idpel       = b.idpel (+)
                    and   a.blth        = b.blth  (+)
                    and   a.kdproses    = '2'
                    and   substr(a.nousulan,9,6)       = vbln_usulan
            --        and   a.kdbank                     = :vkdbank
                    and   a.status                     = '1'
                    and   b.suspect is null
                ),
               bank_data as
                (
                    select
                      'bank_data' proses,a.va, a.nousulan, '2' kdproses, '1'  status,a.idpel, a.blth,
                      nvl(a.rptag,0) rptag, nvl(a.rpbk,0) rpbk,a.tglbayar,a.jambayar, a.userid, a.kdbank kdbank
                    from ophartde.ver_data_locking_bank a
                    where   substr(a.nousulan,9,6)  = vbln_usulan
                    -- and tglbayar = '$tglbayar'
            --        and a.kdbank                    = :vkdbank
                ),
               pln_data_ntl as
                (
                    select to_char(tglinsert,'YYYYMMDD  HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data' proses,a.va, a.nousulan, a.kdproses, a.status,a.noreg idpel, null blth
                           ,nvl(b.rptag,0) rptag, 0 rpbk,b.tglbayar,b.jambayar, b.userid, a.kdbank kdbank
                           ,a.satker,  (b.tglbayar||' '||b.jambayar||' '||b.userid) lunas_H0
                    from ophartde.ver_temp_data_locking_ntl a, olap.transaksi_nontaglis b
                    where a.noreg       = b.nomor_registrasi (+)
                    and   a.kdproses    = '2'
                    and   substr(a.nousulan,9,6)    = vbln_usulan
            --        and   a.kdbank                  = :vkdbank
                    and   a.status                  = '1'
                    and   b.suspect  in ('0','2')
                    union
                    select to_char(tglinsert,'YYYYMMDD  HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data' proses,a.va, a.nousulan,
                     a.kdproses, a.status,a.noreg idpel, null blth,
                      0 rptag, 0 rpbk, null tglbayar, null jambayar, null userid, a.kdbank kdbank
                     ,a.satker,  (b.tglbayar||' '||b.jambayar||' '||b.userid) lunas_H0
                    from ophartde.ver_temp_data_locking_ntl a, olap.transaksi_nontaglis b
                    where a.noreg       = b.nomor_registrasi (+)
                    and   a.kdproses    = '2'
                    and   substr(a.nousulan,9,6)   =  vbln_usulan
            --        and   a.kdbank                 =  :vkdbank
                    and   a.status                 =  '1'
                    and   b.suspect is null
                ),
               bank_data_ntl as
                (
                    select
                      'bank_data' proses,a.va, a.nousulan, '2' kdproses, '1'  status,a.noreg idpel, null blth,
                      nvl(a.rptag,0) rptag, 0 rpbk,a.tglbayar,a.jambayar, a.userid, a.kdbank kdbank
                    from ophartde.ver_data_locking_bank_ntl a
                    where   substr(a.nousulan,9,6)    = vbln_usulan
            --        and a.kdbank                      = :vkdbank
                ),
               pln_data_pre as
                (
                    select (select distinct to_char(tglinsert,'YYYYMMDD  HH24:MI') from OPHARTDE.VER_TEMP_DATA_LOCKING_PRE where nousulan = z.nousulan) tglapprove,
                            z.kddist, z.proses, z.va, z.nousulan, z.kdproses, z.status, z.idpel, null blth,
                           nvl(z.rptag,0) rptag, 0 rpbk, z.tglbayar, z.jambayar, z.userid, z.kdbank, z.satker, z.lunas_H0
                    from
                    (
                        (
                            select
                                rownum baris, f.kddist,f.proses,
                                f.va, f.nousulan, f.kdproses, f.status, f.idpel, f.rptag,
                                null tglbayar, null jambayar,
                                f.userid,  f.KDBANK, f.satker, decode(f.lunas_H0,1,null,f.lunas_H0) lunas_H0
                            from
                            (
                                    select  substr(a.nousulan,4,2) kddist,'pln_data_pre' proses,a.va,
                                            a.nousulan, '2' kdproses, a.status,a.idpel,
                                            a.rptag, A.KDBANK||'CA01' userid,A.KDBANK,a.satker, '1' lunas_H0
                                    from OPHARTDE.VER_TEMP_DATA_LOCKING_PRE a
                                    where to_char(tglinsert,'YYYYMM') =  vbln_usulan
            --                        and    substr(a.nousulan,4,2)     = :vkd_dist
                                    minus
                                    select  substr(a.nousulan,4,2) kddist,'pln_data_pre' proses,a.va,
                                    a.nousulan, '2' kdproses, a.status,a.idpel, a.rptag,
                                    b.userid,  a.KDBANK,a.satker,  '1' lunas_H0
                                    from
                                        (
                                           select  count(*) jml,  substr(m.nousulan,4,2) kd_dist, m.nousulan, m.tglusulan, m.idpel, m.rptag ,
                                                 m.kdbank, m.satker, m.va, m.status, m.KDBANK userid,
                                                 to_char(tglinsert,'YYYYMMDD') tglapprove
                                           -- to_char(tglinsert,'YYYYMMDD') tglapprove, to_char(tglinsert+4,'YYYYMMDD') maxtgltgltrans
                                           from OPHARTDE.VER_TEMP_DATA_LOCKING_PRE m
                                           where to_char(tglinsert,'YYYYMM') =  vbln_usulan
                                           group by  substr(m.nousulan,4,2) , m.nousulan, m.tglusulan, m.idpel, m.rptag,m.kdbank,
                                                    m.satker, m.va, status, m.KDBANK,
                                                    to_char(m.tglinsert,'YYYYMMDD')
                                        ) a, OLAP.TRANSAKSI_PREPAID b
                                        where  a.idpel    = b.idpel(+)
                                        and    a.rptag    = b.rptag
                                        and    a.TGLAPPROVE <= b.tglbayar
                                        and    substr(b.tglbayar,1,6)  = vbln_usulan
            --                            and    substr(a.nousulan,4,2)  = :vkd_dist
            --                            and    a.kdbank                =  :vkdbank
                                        and    b.UNSOLD is null
                                        and    B.TGL_REKON is not null
                                ) f
                        )
                        union
                        (
                           select rownum baris, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data_pre' proses,
                             a.va, a.nousulan, '2' kdproses, a.status,a.idpel, a.rptag,
                             b.tglbayar,b.jambayar,
                             b.userid,  a.KDBANK, a.satker,  (b.tglbayar||' '||b.Jambayar||' '||b.Userid) lunas_H0
                            from
                                (
                                   select  count(*) jml, substr(m.nousulan,4,2) kd_dist, m.nousulan, m.tglusulan, m.idpel, m.rptag ,
                                         m.kdbank, m.satker, m.va, m.status, m.KDBANK userid,
                                         to_char(tglinsert,'YYYYMMDD') tglapprove
                                   from OPHARTDE.VER_TEMP_DATA_LOCKING_PRE m
                                   where to_char(tglinsert,'YYYYMM') =  vbln_usulan
                                   group by  substr(m.nousulan,4,2), m.nousulan, m.tglusulan, m.idpel, m.rptag,m.kdbank,
                                            m.satker, m.va, status, m.KDBANK,
                                            to_char(m.tglinsert,'YYYYMMDD')
                                ) a, OLAP.TRANSAKSI_PREPAID b
                                where  a.idpel    = b.idpel(+)
                                and    a.rptag    = b.rptag
                                and    a.TGLAPPROVE <= b.tglbayar
                                and    substr(b.tglbayar,1,6)  = vbln_usulan
            --                    and    substr(a.nousulan,4,2)  = :vkd_dist
            --                    and    a.kdbank                = :vkdbank
                                and    b.UNSOLD is null
                                and    B.TGL_REKON is not null
                           )
                    ) z
                ),
               bank_data_pre as
                (
                    select
                      'bank_data' proses,a.va, a.nousulan, '2' kdproses, '1'  status,a.idpel, null blth,
                      nvl(a.rptag,0) rptag, 0 rpbk,a.tglbayar,a.jambayar, a.userid, a.kdbank kdbank
                    from ophartde.ver_data_locking_bank_pre a
                    where substr(a.nousulan,9,6)    = vbln_usulan
            --        and   a.kdbank                  = :vkdbank
                )
            select  KD_DIST, decode(KD_DIST,'00','SAKTI',( select NAMA_DIST from OLAP.MASTER_DISTRIBUSI where KD_DIST = x.KD_DIST and rownum = 1)) NAMA_DIST,
                    1 urut, 
                    NVL(MAX(CASE WHEN PRODUK = 'POSTPAID' THEN 'POS' END), '-') ||
                    '/' ||
                    NVL(MAX(CASE WHEN PRODUK = 'NONTAGLIS' THEN 'NTL' END), '-') ||
                    '/' ||
                    NVL(MAX(CASE WHEN PRODUK = 'PREPAID' THEN 'PRE' END), '-') AS PRODUK,
                    PLN_KDBANK||'-'||(select NAMA_BANK from OPHARTDE.VER_MASTER_BANK where KODE_BANK = x.PLN_KDBANK and rownum =1) BANK,
                    substr(x.pln_nousulan,9,6) bln_usulan, 
                    count(PLN_IDPEL) PLN_IDPEL , sum(PLN_RPTAG) PLN_RPTAG,
                    sum(
                        Case when (PLN_LUNAS_H0 is not null) 
                             then 1
                             else 0            
                        end
                    ) PLN_LEBAR_LUNAS,
                    sum(
                        Case when (PLN_LUNAS_H0 is not null) 
                             then PLN_RPTAG
                             else 0            
                        end
                    ) PLN_RPTAG_LUNAS,
                    count(BANK_IDPEL) BANK_IDPEL , sum(BANK_RPTAG) BANK_RPTAG,
                    sum(SELISIH_RPTAG) SELISIH_RPTAG
            from
            (
                (
                select 1 urut,'POSTPAID' produk, x.*,
                nvl(x.pln_rptag,0)-nvl(x.bank_rptag,0) selisih_rptag,
                nvl(x.pln_rpbk,0)-nvl(x.bank_rpbk,0) selisih_bk,
                case
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) = 0) and (pln_idpel = bank_idpel )
                         and (pln_blth = bank_blth )
                       then ''
                    when (pln_idpel is null) and (bank_idpel is not null)
                       then 'selisih - data usulan pln (tidak ada), data pelunasan bank (ada)'
                    when (pln_idpel is not null) and (pln_tglbayar is null) and (bank_idpel is null)
                       then 'selisih - data usulan pln (ada)/tidak lunas, data pelunasan bank (tidak ada)/tidak lunas (Belum Flag Bank/belum rekon)'
                    when (pln_idpel is not null and bank_idpel is not null ) and (pln_tglbayar is null and bank_tglbayar is not null)
                       then 'selisih - data usulan pln (ada)/tidak lunas , data pelunasan bank (ada)/lunas (Chek Reversal Sukses Dijawab PLN)'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) = PLN_KDBANK)
                        then 'selisih - data usulan pln (ada)/lunas , data pelunasan bank (Tidak ada)/Tidak lunas (Konfirmasi/Log Bank/Belum Rekon)'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is null)
                        then 'selisih - data usulan pln (ada)/lunas (ppob/bukan miv), data pelunasan bank (Tidak ada)/Tidak lunas'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is not null)
                        then 'selisih - data usulan pln (ada)/lunas (Bank Lain), data pelunasan bank (ada)/lunas (Konfirmasi/Log Bank)'
                    else 'selisih - belum teridentifikasi'
                 end as keterangan
                from
                 (
                    select a.tglapprove,
                         nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker, a.nousulan pln_nousulan, a.kdproses pln_kdproses, a.status pln_status, a.idpel pln_idpel, a.blth pln_blth
                         , lunas_H0 pln_lunas_H0,a.rptag pln_rptag, a.rpbk pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,a.kdbank pln_kdbank,
                         b. Proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                         nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,
                         b.kdbank bank_kdbank
                    from pln_data a, bank_data b
                    where a.nousulan = b.nousulan (+)
                    and   a.idpel    = b.idpel (+)
                    and   a.blth     = b.blth (+)
                union
                select a.tglapprove,
                     nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va,a.satker,nvl(a.nousulan,b.nousulan) pln_nousulan, nvl(a.kdproses,'2') pln_kdproses, nvl(a.status,1) pln_status, a.idpel pln_idpel, a.blth pln_blth
                     ,lunas_H0 pln_lunas_H0, nvl(a.rptag,0) pln_rptag, nvl(a.rpbk,0) pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,nvl(a.kdbank,b.kdbank) pln_kdbank,
                     b.proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                     nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,nvl(b.kdbank,a.kdbank) bank_kdbank
                from pln_data a, bank_data b
                where b.nousulan = a.nousulan (+)
                and   b.idpel    = a.idpel (+)
                and   b.blth     = a.blth (+)
                and   a.kdbank is null
                ) x
            --    where kd_dist =   :vkd_dist
                )
                union
                (
                select 2 urut,'NONTAGLIS' produk, x.*,
                nvl(x.pln_rptag,0)-nvl(x.bank_rptag,0) selisih_rptag,
                nvl(x.pln_rpbk,0)-nvl(x.bank_rpbk,0) selisih_bk,
                case
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) = 0) and (pln_idpel = bank_idpel )
                       then ''
                    when (pln_idpel is null) and (bank_idpel is not null)
                       then 'selisih - data usulan pln (tidak ada), data pelunasan bank (ada)'
                    when (pln_idpel is not null) and (pln_tglbayar is null) and (bank_idpel is null)
                       then 'selisih - data usulan pln (ada), data pelunasan bank (tidak ada)/tidak lunas'
                    when (pln_idpel is not null and bank_idpel is not null ) and (pln_tglbayar is null and bank_tglbayar is not null)
                       then 'selisih - data usulan pln (ada)/tidak lunas , data pelunasan bank (ada)/lunas (Chek Reversal Sukses Dijawab PLN)'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) = PLN_KDBANK)
                        then 'selisih - data usulan pln (ada)/lunas , data pelunasan bank (Tidak ada)/Tidak lunas (Konfirmasi/Log Bank/Belum Rekon)'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is null)
                        then 'selisih - data usulan pln (ada)/lunas (ppob/bukan miv), data pelunasan bank (Tidak ada)/Tidak lunas'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is not null)
                        then 'selisih - data usulan pln (ada)/lunas (Bank Lain), data pelunasan bank (ada)/lunas (Konfirmasi/Log Bank)'
                    else 'selisih - belum teridentifikasi'
                 end as keterangan
                from
                (
                    select a.tglapprove,
                         nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va,a.satker, a.nousulan pln_nousulan, a.kdproses pln_kdproses, a.status pln_status,
                         a.idpel pln_idpel, a.blth pln_blth
                         ,lunas_H0 pln_lunas_H0,
                         a.rptag pln_rptag, a.rpbk pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,a.kdbank pln_kdbank,
                         b. Proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                         nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,
                         b.kdbank bank_kdbank
                    from pln_data_ntl a, bank_data_ntl b
                    where a.nousulan = b.nousulan (+)
                    and   a.idpel    = b.idpel (+)
                    union
                    select a.tglapprove,
                         nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker,nvl(a.nousulan,b.nousulan) pln_nousulan, nvl(a.kdproses,'2') pln_kdproses, nvl(a.status,1) pln_status, a.idpel pln_idpel, a.blth pln_blth
                         ,lunas_H0 pln_lunas_H0,nvl(a.rptag,0) pln_rptag, nvl(a.rpbk,0) pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,nvl(a.kdbank,b.kdbank) pln_kdbank,
                         b.proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                         nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,nvl(b.kdbank,a.kdbank) bank_kdbank
                    from pln_data_ntl a, bank_data_ntl b
                    where b.nousulan = a.nousulan (+)
                    and   b.idpel    = a.idpel (+)
                    and   a.kdbank is null
                 ) x
            --    where kd_dist =   :vkd_dist
                )
                union
                (
                select 3 urut,'PREPAID' produk, x.*,
                nvl(x.pln_rptag,0)-nvl(x.bank_rptag,0) selisih_rptag,
                nvl(x.pln_rpbk,0)-nvl(x.bank_rpbk,0) selisih_bk,
                case
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) = 0) and (pln_idpel = bank_idpel )
                       then ''
                    when (pln_idpel is null) and (bank_idpel is not null)
                       then 'selisih - data usulan pln (tidak ada), data pelunasan bank (ada)'
                    when (pln_idpel is not null) and (pln_tglbayar is null) and (bank_idpel is null)
                       then 'selisih - data usulan pln (ada), data pelunasan bank (tidak ada)/tidak lunas'
                    when (pln_idpel is not null and bank_idpel is not null ) and (pln_tglbayar is null and bank_tglbayar is not null)
                       then 'selisih - data usulan pln (ada)/tidak lunas , data pelunasan bank (ada)/lunas (Chek Reversal Sukses Dijawab PLN)'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) = PLN_KDBANK)
                        then 'selisih - data usulan pln (ada)/lunas , data pelunasan bank (Tidak ada)/Tidak lunas (Konfirmasi/Log Bank/Belum Rekon)'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is null)
                        then 'selisih - data usulan pln (ada)/lunas (ppob/bukan miv), data pelunasan bank (Tidak ada)/Tidak lunas'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is not null)
                        then 'selisih - data usulan pln (ada)/lunas (Bank Lain), data pelunasan bank (ada)/lunas (Konfirmasi/Log Bank)'
                    else 'selisih - belum teridentifikasi'
                 end as keterangan
                from
                (
                    select a.tglapprove,
                         nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker, a.nousulan pln_nousulan, a.kdproses pln_kdproses, a.status pln_status,
                         a.idpel pln_idpel, a.blth pln_blth
                         ,lunas_H0 pln_lunas_H0,a.rptag pln_rptag, a.rpbk pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,a.kdbank pln_kdbank,
                         b. Proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                         nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,
                         b.kdbank bank_kdbank
                    from pln_data_pre a, bank_data_pre b
                    where a.nousulan = b.nousulan (+)
                    and   a.idpel    = b.idpel (+)
                    union
                    select a.tglapprove,
                         nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker,nvl(a.nousulan,b.nousulan) pln_nousulan, nvl(a.kdproses,'2') pln_kdproses, nvl(a.status,1) pln_status, a.idpel pln_idpel, a.blth pln_blth
                         ,lunas_H0 pln_lunas_H0, nvl(a.rptag,0) pln_rptag, nvl(a.rpbk,0) pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,nvl(a.kdbank,b.kdbank) pln_kdbank,
                         b.proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                         nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,nvl(b.kdbank,a.kdbank) bank_kdbank
                    from pln_data_pre a, bank_data_pre b
                    where b.nousulan = a.nousulan (+)
                    and   b.idpel    = a.idpel (+)
                    and   a.kdbank is null
                 ) x
            --     where kd_dist =   :vkd_dist
                )
            ) x
            --where kd_dist =   :vkd_dist
            group by substr(x.pln_nousulan,9,6), x.PLN_KDBANK, x.KD_DIST
            union
            select  '' KD_DIST, '' NAMA_DIST,
                    5 urut, 'POS/NTL/PRE' PRODUK, 
                    '' BANK,
                    'TOTAL' bln_usulan, 
                    count(PLN_IDPEL) PLN_IDPEL , sum(PLN_RPTAG) PLN_RPTAG,
                    sum(
                        Case when (PLN_LUNAS_H0 is not null) 
                             then 1
                             else 0            
                        end
                    ) PLN_LEBAR_LUNAS,
                    sum(
                        Case when (PLN_LUNAS_H0 is not null) 
                             then PLN_RPTAG
                             else 0            
                        end
                    ) PLN_RPTAG_LUNAS,
                    count(BANK_IDPEL) BANK_IDPEL , sum(BANK_RPTAG) BANK_RPTAG,
                    sum(SELISIH_RPTAG) SELISIH_RPTAG
            from
            (
                (
                select 1 urut,'POSTPAID' produk, x.*,
                nvl(x.pln_rptag,0)-nvl(x.bank_rptag,0) selisih_rptag,
                nvl(x.pln_rpbk,0)-nvl(x.bank_rpbk,0) selisih_bk,
                case
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) = 0) and (pln_idpel = bank_idpel )
                         and (pln_blth = bank_blth )
                       then ''
                    when (pln_idpel is null) and (bank_idpel is not null)
                       then 'selisih - data usulan pln (tidak ada), data pelunasan bank (ada)'
                    when (pln_idpel is not null) and (pln_tglbayar is null) and (bank_idpel is null)
                       then 'selisih - data usulan pln (ada)/tidak lunas, data pelunasan bank (tidak ada)/tidak lunas (Belum Flag Bank/belum rekon)'
                    when (pln_idpel is not null and bank_idpel is not null ) and (pln_tglbayar is null and bank_tglbayar is not null)
                       then 'selisih - data usulan pln (ada)/tidak lunas , data pelunasan bank (ada)/lunas (Chek Reversal Sukses Dijawab PLN)'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) = PLN_KDBANK)
                        then 'selisih - data usulan pln (ada)/lunas , data pelunasan bank (Tidak ada)/Tidak lunas (Konfirmasi/Log Bank/Belum Rekon)'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is null)
                        then 'selisih - data usulan pln (ada)/lunas (ppob/bukan miv), data pelunasan bank (Tidak ada)/Tidak lunas'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is not null)
                        then 'selisih - data usulan pln (ada)/lunas (Bank Lain), data pelunasan bank (ada)/lunas (Konfirmasi/Log Bank)'
                    else 'selisih - belum teridentifikasi'
                 end as keterangan
                from
                 (
                    select a.tglapprove,
                         nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker, a.nousulan pln_nousulan, a.kdproses pln_kdproses, a.status pln_status, a.idpel pln_idpel, a.blth pln_blth
                         , lunas_H0 pln_lunas_H0,a.rptag pln_rptag, a.rpbk pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,a.kdbank pln_kdbank,
                         b. Proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                         nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,
                         b.kdbank bank_kdbank
                    from pln_data a, bank_data b
                    where a.nousulan = b.nousulan (+)
                    and   a.idpel    = b.idpel (+)
                    and   a.blth     = b.blth (+)
                union
                select a.tglapprove,
                     nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va,a.satker,nvl(a.nousulan,b.nousulan) pln_nousulan, nvl(a.kdproses,'2') pln_kdproses, nvl(a.status,1) pln_status, a.idpel pln_idpel, a.blth pln_blth
                     ,lunas_H0 pln_lunas_H0, nvl(a.rptag,0) pln_rptag, nvl(a.rpbk,0) pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,nvl(a.kdbank,b.kdbank) pln_kdbank,
                     b.proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                     nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,nvl(b.kdbank,a.kdbank) bank_kdbank
                from pln_data a, bank_data b
                where b.nousulan = a.nousulan (+)
                and   b.idpel    = a.idpel (+)
                and   b.blth     = a.blth (+)
                and   a.kdbank is null
                ) x
            --    where kd_dist =   :vkd_dist
                )
                union
                (
                select 2 urut,'NONTAGLIS' produk, x.*,
                nvl(x.pln_rptag,0)-nvl(x.bank_rptag,0) selisih_rptag,
                nvl(x.pln_rpbk,0)-nvl(x.bank_rpbk,0) selisih_bk,
                case
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) = 0) and (pln_idpel = bank_idpel )
                       then ''
                    when (pln_idpel is null) and (bank_idpel is not null)
                       then 'selisih - data usulan pln (tidak ada), data pelunasan bank (ada)'
                    when (pln_idpel is not null) and (pln_tglbayar is null) and (bank_idpel is null)
                       then 'selisih - data usulan pln (ada), data pelunasan bank (tidak ada)/tidak lunas'
                    when (pln_idpel is not null and bank_idpel is not null ) and (pln_tglbayar is null and bank_tglbayar is not null)
                       then 'selisih - data usulan pln (ada)/tidak lunas , data pelunasan bank (ada)/lunas (Chek Reversal Sukses Dijawab PLN)'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) = PLN_KDBANK)
                        then 'selisih - data usulan pln (ada)/lunas , data pelunasan bank (Tidak ada)/Tidak lunas (Konfirmasi/Log Bank/Belum Rekon)'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is null)
                        then 'selisih - data usulan pln (ada)/lunas (ppob/bukan miv), data pelunasan bank (Tidak ada)/Tidak lunas'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is not null)
                        then 'selisih - data usulan pln (ada)/lunas (Bank Lain), data pelunasan bank (ada)/lunas (Konfirmasi/Log Bank)'
                    else 'selisih - belum teridentifikasi'
                 end as keterangan
                from
                (
                    select a.tglapprove,
                         nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va,a.satker, a.nousulan pln_nousulan, a.kdproses pln_kdproses, a.status pln_status,
                         a.idpel pln_idpel, a.blth pln_blth
                         ,lunas_H0 pln_lunas_H0,
                         a.rptag pln_rptag, a.rpbk pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,a.kdbank pln_kdbank,
                         b. Proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                         nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,
                         b.kdbank bank_kdbank
                    from pln_data_ntl a, bank_data_ntl b
                    where a.nousulan = b.nousulan (+)
                    and   a.idpel    = b.idpel (+)
                    union
                    select a.tglapprove,
                         nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker,nvl(a.nousulan,b.nousulan) pln_nousulan, nvl(a.kdproses,'2') pln_kdproses, nvl(a.status,1) pln_status, a.idpel pln_idpel, a.blth pln_blth
                         ,lunas_H0 pln_lunas_H0,nvl(a.rptag,0) pln_rptag, nvl(a.rpbk,0) pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,nvl(a.kdbank,b.kdbank) pln_kdbank,
                         b.proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                         nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,nvl(b.kdbank,a.kdbank) bank_kdbank
                    from pln_data_ntl a, bank_data_ntl b
                    where b.nousulan = a.nousulan (+)
                    and   b.idpel    = a.idpel (+)
                    and   a.kdbank is null
                 ) x
            --    where kd_dist =   :vkd_dist
                )
                union
                (
                select 3 urut,'PREPAID' produk, x.*,
                nvl(x.pln_rptag,0)-nvl(x.bank_rptag,0) selisih_rptag,
                nvl(x.pln_rpbk,0)-nvl(x.bank_rpbk,0) selisih_bk,
                case
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) = 0) and (pln_idpel = bank_idpel )
                       then ''
                    when (pln_idpel is null) and (bank_idpel is not null)
                       then 'selisih - data usulan pln (tidak ada), data pelunasan bank (ada)'
                    when (pln_idpel is not null) and (pln_tglbayar is null) and (bank_idpel is null)
                       then 'selisih - data usulan pln (ada), data pelunasan bank (tidak ada)/tidak lunas'
                    when (pln_idpel is not null and bank_idpel is not null ) and (pln_tglbayar is null and bank_tglbayar is not null)
                       then 'selisih - data usulan pln (ada)/tidak lunas , data pelunasan bank (ada)/lunas (Chek Reversal Sukses Dijawab PLN)'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) = PLN_KDBANK)
                        then 'selisih - data usulan pln (ada)/lunas , data pelunasan bank (Tidak ada)/Tidak lunas (Konfirmasi/Log Bank/Belum Rekon)'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is null)
                        then 'selisih - data usulan pln (ada)/lunas (ppob/bukan miv), data pelunasan bank (Tidak ada)/Tidak lunas'
                    when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is not null)
                        then 'selisih - data usulan pln (ada)/lunas (Bank Lain), data pelunasan bank (ada)/lunas (Konfirmasi/Log Bank)'
                    else 'selisih - belum teridentifikasi'
                 end as keterangan
                from
                (
                    select a.tglapprove,
                         nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker, a.nousulan pln_nousulan, a.kdproses pln_kdproses, a.status pln_status,
                         a.idpel pln_idpel, a.blth pln_blth
                         ,lunas_H0 pln_lunas_H0,a.rptag pln_rptag, a.rpbk pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,a.kdbank pln_kdbank,
                         b. Proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                         nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,
                         b.kdbank bank_kdbank
                    from pln_data_pre a, bank_data_pre b
                    where a.nousulan = b.nousulan (+)
                    and   a.idpel    = b.idpel (+)
                    union
                    select a.tglapprove,
                         nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker,nvl(a.nousulan,b.nousulan) pln_nousulan, nvl(a.kdproses,'2') pln_kdproses, nvl(a.status,1) pln_status, a.idpel pln_idpel, a.blth pln_blth
                         ,lunas_H0 pln_lunas_H0, nvl(a.rptag,0) pln_rptag, nvl(a.rpbk,0) pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,nvl(a.kdbank,b.kdbank) pln_kdbank,
                         b.proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                         nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,nvl(b.kdbank,a.kdbank) bank_kdbank
                    from pln_data_pre a, bank_data_pre b
                    where b.nousulan = a.nousulan (+)
                    and   b.idpel    = a.idpel (+)
                    and   a.kdbank is null
                 ) x
            --     where kd_dist =   :vkd_dist
                )
            ) x
            --where kd_dist =   :vkd_dist
            ;
            
        pesan := 'Sukses tampilkan data.';
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           pesan:='Gagal Tampilkan Data Tdak Ada, '||vEmsg||'  '||SQLERRM;
        WHEN OTHERS THEN
           pesan:='Gagal Tampilkan Data ' ||SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; 
    END;
    
    --1b) Mon Daftar Rekon MIV/SAKTI PLN vs BANK
    PROCEDURE monlap_mivfalg_plnvsbank_uiw_pgs(
                    in_start         in number,
                    in_lenght        in number,
                    in_sort_by       in varchar2,
                    in_sort_dir      in varchar2,
                    in_search        in varchar2,
                    vbln_usulan IN NUMBER, vkdbank in VARCHAR, vkd_dist in VARCHAR, out_data out sys_refcursor, pesan out varchar2) is
        vEmsg varchar2(50) default null;
    BEGIN
        vEmsg := 'Gagal Tampilkan Data ';
        pesan := 'Gagal Tampilkan Data ';
        open out_data for
            -- PGS DAFTAR
            SELECT *
            FROM (
              SELECT x.*, ROWNUM AS ROW_NUMBER
              FROM (
                ----------------------------------------------------------------------------    
                -- begin query utama
                --------------------------------------------------------------------
                --  contoh input tarik data rekon sakti BANK vs P2APST
                --  Tekan ctrl+enter mausukan :
                ---    bln_usulan : 202503 -- Tahun Bulan Falging Sakti yang diminta
                ---    bank       : 111    -- kode bank DKI 3 digit
                ---    apj        : 00     -- sakti seluruh UID/UIW seindonesia
                --------------------------------------------------------------------
                With pln_data as
                    (
                        select to_char(tglinsert,'YYYYMMDD HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data' proses,a.va, a.nousulan, a.kdproses, a.status,a.idpel, a.blth,
                               nvl(b.rptag,0) rptag, nvl(b.rpbk,0) rpbk,b.tglbayar,b.jambayar, b.userid, a.kdbank kdbank
                               ,a.satker,  (b.tglbayar||'  '||b.jambayar||'  '||b.userid) lunas_H0
                        from ophartde.ver_temp_data_locking a, olap.h2h b
                        where a.idpel       = b.idpel (+)
                        and   a.blth        = b.blth  (+)
                        and   a.kdproses    = '2'
                        and   substr(a.nousulan,9,6)       = vbln_usulan
                        and  a.kdbank                      = vkdbank
                        and   a.status                     = '1'
                        --and   nvl(b.suspect,0)  in ('0','2')
                        and   b.suspect  in ('0','2')
                        union
                        select to_char(tglinsert,'YYYYMMDD  HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data' proses,a.va, a.nousulan, a.kdproses, a.status,a.idpel, a.blth,
                                0 rptag, 0 rpbk,null tglbayar, null jambayar,null userid, a.kdbank kdbank
                               ,a.satker,  (b.tglbayar||' '||b.jambayar||' '||b.userid) lunas_H0
                        from ophartde.ver_temp_data_locking a, olap.h2h b
                        where a.idpel       = b.idpel (+)
                        and   a.blth        = b.blth  (+)
                        and   a.kdproses    = '2'
                        and   substr(a.nousulan,9,6)       = vbln_usulan
                        and   a.kdbank                     = vkdbank
                        and   a.status                     = '1'
                        and   b.suspect is null
                    ),
                   bank_data as
                    (
                        select
                          'bank_data' proses,a.va, a.nousulan, '2' kdproses, '1'  status,a.idpel, a.blth,
                          nvl(a.rptag,0) rptag, nvl(a.rpbk,0) rpbk,a.tglbayar,a.jambayar, a.userid, a.kdbank kdbank
                        from ophartde.ver_data_locking_bank a
                        where   substr(a.nousulan,9,6)  = vbln_usulan
                        -- and tglbayar = '$tglbayar'
                        and a.kdbank                    = vkdbank
                    ),
                   pln_data_ntl as
                    (
                        select to_char(tglinsert,'YYYYMMDD  HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data' proses,a.va, a.nousulan, a.kdproses, a.status,a.noreg idpel, null blth
                               ,nvl(b.rptag,0) rptag, 0 rpbk,b.tglbayar,b.jambayar, b.userid, a.kdbank kdbank
                               ,a.satker,  (b.tglbayar||' '||b.jambayar||' '||b.userid) lunas_H0
                        from ophartde.ver_temp_data_locking_ntl a, olap.transaksi_nontaglis b
                        where a.noreg       = b.nomor_registrasi (+)
                        and   a.kdproses    = '2'
                        and   substr(a.nousulan,9,6)    = vbln_usulan
                        and   a.kdbank                  = vkdbank
                        and   a.status                  = '1'
                        and   b.suspect  in ('0','2')
                        union
                        select to_char(tglinsert,'YYYYMMDD  HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data' proses,a.va, a.nousulan,
                         a.kdproses, a.status,a.noreg idpel, null blth,
                          0 rptag, 0 rpbk, null tglbayar, null jambayar, null userid, a.kdbank kdbank
                         ,a.satker,  (b.tglbayar||' '||b.jambayar||' '||b.userid) lunas_H0
                        from ophartde.ver_temp_data_locking_ntl a, olap.transaksi_nontaglis b
                        where a.noreg       = b.nomor_registrasi (+)
                        and   a.kdproses    = '2'
                        and   substr(a.nousulan,9,6)   =  vbln_usulan
                        and   a.kdbank                 =  vkdbank
                        and   a.status                 =  '1'
                        and   b.suspect is null
                    ),
                   bank_data_ntl as
                    (
                        select
                          'bank_data' proses,a.va, a.nousulan, '2' kdproses, '1'  status,a.noreg idpel, null blth,
                          nvl(a.rptag,0) rptag, 0 rpbk,a.tglbayar,a.jambayar, a.userid, a.kdbank kdbank
                        from ophartde.ver_data_locking_bank_ntl a
                        where   substr(a.nousulan,9,6)    = vbln_usulan
                        and a.kdbank                      = vkdbank
                    ),
                   pln_data_pre as
                    (
                        select (select distinct to_char(tglinsert,'YYYYMMDD  HH24:MI') from OPHARTDE.VER_TEMP_DATA_LOCKING_PRE where nousulan = z.nousulan) tglapprove,
                                z.kddist, z.proses, z.va, z.nousulan, z.kdproses, z.status, z.idpel, null blth,
                               nvl(z.rptag,0) rptag, 0 rpbk, z.tglbayar, z.jambayar, z.userid, z.kdbank, z.satker, z.lunas_H0
                        from
                        (
                            (
                                select
                                    rownum baris, f.kddist,f.proses,
                                    f.va, f.nousulan, f.kdproses, f.status, f.idpel, f.rptag,
                                    null tglbayar, null jambayar,
                                    f.userid,  f.KDBANK, f.satker, decode(f.lunas_H0,1,null,f.lunas_H0) lunas_H0
                                from
                                (
                                        select  substr(a.nousulan,4,2) kddist,'pln_data_pre' proses,a.va,
                                                a.nousulan, '2' kdproses, a.status,a.idpel,
                                                a.rptag, A.KDBANK||'CA01' userid,A.KDBANK,a.satker, '1' lunas_H0
                                        from OPHARTDE.VER_TEMP_DATA_LOCKING_PRE a
                                        where to_char(tglinsert,'YYYYMM') =  vbln_usulan
                                        and    substr(a.nousulan,4,2)     = vkd_dist
                                        minus
                                        select  substr(a.nousulan,4,2) kddist,'pln_data_pre' proses,a.va,
                                        a.nousulan, '2' kdproses, a.status,a.idpel, a.rptag,
                                        b.userid,  a.KDBANK,a.satker,  '1' lunas_H0
                                        from
                                            (
                                               select  count(*) jml,  substr(m.nousulan,4,2) kd_dist, m.nousulan, m.tglusulan, m.idpel, m.rptag ,
                                                     m.kdbank, m.satker, m.va, m.status, m.KDBANK userid,
                                                     to_char(tglinsert,'YYYYMMDD') tglapprove
                                               -- to_char(tglinsert,'YYYYMMDD') tglapprove, to_char(tglinsert+4,'YYYYMMDD') maxtgltgltrans
                                               from OPHARTDE.VER_TEMP_DATA_LOCKING_PRE m
                                               where to_char(tglinsert,'YYYYMM') =  vbln_usulan
                                               group by  substr(m.nousulan,4,2) , m.nousulan, m.tglusulan, m.idpel, m.rptag,m.kdbank,
                                                        m.satker, m.va, status, m.KDBANK,
                                                        to_char(m.tglinsert,'YYYYMMDD')
                                            ) a, OLAP.TRANSAKSI_PREPAID b
                                            where  a.idpel    = b.idpel(+)
                                            and    a.rptag    = b.rptag
                                            and    a.TGLAPPROVE <= b.tglbayar
                                            and    substr(b.tglbayar,1,6)  = vbln_usulan
                                            and    substr(a.nousulan,4,2)  = vkd_dist
                                            and    a.kdbank                =  vkdbank
                                            and    b.UNSOLD is null
                                            and    B.TGL_REKON is not null
                                    ) f
                            )
                            union
                            (
                               select rownum baris, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data_pre' proses,
                                 a.va, a.nousulan, '2' kdproses, a.status,a.idpel, a.rptag,
                                 b.tglbayar,b.jambayar,
                                 b.userid,  a.KDBANK, a.satker,  (b.tglbayar||' '||b.Jambayar||' '||b.Userid) lunas_H0
                                from
                                    (
                                       select  count(*) jml, substr(m.nousulan,4,2) kd_dist, m.nousulan, m.tglusulan, m.idpel, m.rptag ,
                                             m.kdbank, m.satker, m.va, m.status, m.KDBANK userid,
                                             to_char(tglinsert,'YYYYMMDD') tglapprove
                                       from OPHARTDE.VER_TEMP_DATA_LOCKING_PRE m
                                       where to_char(tglinsert,'YYYYMM') =  vbln_usulan
                                       group by  substr(m.nousulan,4,2), m.nousulan, m.tglusulan, m.idpel, m.rptag,m.kdbank,
                                                m.satker, m.va, status, m.KDBANK,
                                                to_char(m.tglinsert,'YYYYMMDD')
                                    ) a, OLAP.TRANSAKSI_PREPAID b
                                    where  a.idpel    = b.idpel(+)
                                    and    a.rptag    = b.rptag
                                    and    a.TGLAPPROVE <= b.tglbayar
                                    and    substr(b.tglbayar,1,6)  = vbln_usulan
                                    and    substr(a.nousulan,4,2)  = vkd_dist
                                    and    a.kdbank                = vkdbank
                                    and    b.UNSOLD is null
                                    and    B.TGL_REKON is not null
                               )
                        ) z
                    ),
                   bank_data_pre as
                    (
                        select
                          'bank_data' proses,a.va, a.nousulan, '2' kdproses, '1'  status,a.idpel, null blth,
                          nvl(a.rptag,0) rptag, 0 rpbk,a.tglbayar,a.jambayar, a.userid, a.kdbank kdbank
                        from ophartde.ver_data_locking_bank_pre a
                        where substr(a.nousulan,9,6)    = vbln_usulan
                        and   a.kdbank                  = vkdbank
                    )
                select  count(x.KD_DIST) over () TOTAL_COUNT, x.* 
                from
                (
                    (
                    select 1 urut,'POSTPAID' produk, x.*,
                    nvl(x.pln_rptag,0)-nvl(x.bank_rptag,0) selisih_rptag,
                    nvl(x.pln_rpbk,0)-nvl(x.bank_rpbk,0) selisih_bk,
                    case
                        when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) = 0) and (pln_idpel = bank_idpel )
                             and (pln_blth = bank_blth )
                           then ''
                        when (pln_idpel is null) and (bank_idpel is not null)
                           then 'selisih - data usulan pln (tidak ada), data pelunasan bank (ada)'
                        when (pln_idpel is not null) and (pln_tglbayar is null) and (bank_idpel is null)
                           then 'selisih - data usulan pln (ada)/tidak lunas, data pelunasan bank (tidak ada)/tidak lunas (Belum Flag Bank/belum rekon)'
                        when (pln_idpel is not null and bank_idpel is not null ) and (pln_tglbayar is null and bank_tglbayar is not null)
                           then 'selisih - data usulan pln (ada)/tidak lunas , data pelunasan bank (ada)/lunas (Chek Reversal Sukses Dijawab PLN)'
                        when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) = PLN_KDBANK)
                            then 'selisih - data usulan pln (ada)/lunas , data pelunasan bank (Tidak ada)/Tidak lunas (Konfirmasi/Log Bank/Belum Rekon)'
                        when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is null)
                            then 'selisih - data usulan pln (ada)/lunas (ppob/bukan miv), data pelunasan bank (Tidak ada)/Tidak lunas'
                        when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is not null)
                            then 'selisih - data usulan pln (ada)/lunas (Bank Lain), data pelunasan bank (ada)/lunas (Konfirmasi/Log Bank)'
                        else 'selisih - belum teridentifikasi'
                     end as keterangan
                    from
                     (
                        select a.tglapprove,
                             nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker, a.nousulan pln_nousulan, a.kdproses pln_kdproses, a.status pln_status, a.idpel pln_idpel, a.blth pln_blth
                             , lunas_H0 pln_lunas_H0,a.rptag pln_rptag, a.rpbk pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,a.kdbank pln_kdbank,
                             b. Proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                             nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,
                             b.kdbank bank_kdbank
                        from pln_data a, bank_data b
                        where a.nousulan = b.nousulan (+)
                        and   a.idpel    = b.idpel (+)
                        and   a.blth     = b.blth (+)
                    union
                    select a.tglapprove,
                         nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va,a.satker,nvl(a.nousulan,b.nousulan) pln_nousulan, nvl(a.kdproses,'2') pln_kdproses, nvl(a.status,1) pln_status, a.idpel pln_idpel, a.blth pln_blth
                         ,lunas_H0 pln_lunas_H0, nvl(a.rptag,0) pln_rptag, nvl(a.rpbk,0) pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,nvl(a.kdbank,b.kdbank) pln_kdbank,
                         b.proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                         nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,nvl(b.kdbank,a.kdbank) bank_kdbank
                    from pln_data a, bank_data b
                    where b.nousulan = a.nousulan (+)
                    and   b.idpel    = a.idpel (+)
                    and   b.blth     = a.blth (+)
                    and   a.kdbank is null
                    ) x
                    where kd_dist =   vkd_dist
                    )
                    union
                    (
                    select 2 urut,'NONTAGLIS' produk, x.*,
                    nvl(x.pln_rptag,0)-nvl(x.bank_rptag,0) selisih_rptag,
                    nvl(x.pln_rpbk,0)-nvl(x.bank_rpbk,0) selisih_bk,
                    case
                        when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) = 0) and (pln_idpel = bank_idpel )
                           then ''
                        when (pln_idpel is null) and (bank_idpel is not null)
                           then 'selisih - data usulan pln (tidak ada), data pelunasan bank (ada)'
                        when (pln_idpel is not null) and (pln_tglbayar is null) and (bank_idpel is null)
                           then 'selisih - data usulan pln (ada), data pelunasan bank (tidak ada)/tidak lunas'
                        when (pln_idpel is not null and bank_idpel is not null ) and (pln_tglbayar is null and bank_tglbayar is not null)
                           then 'selisih - data usulan pln (ada)/tidak lunas , data pelunasan bank (ada)/lunas (Chek Reversal Sukses Dijawab PLN)'
                        when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) = PLN_KDBANK)
                            then 'selisih - data usulan pln (ada)/lunas , data pelunasan bank (Tidak ada)/Tidak lunas (Konfirmasi/Log Bank/Belum Rekon)'
                        when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is null)
                            then 'selisih - data usulan pln (ada)/lunas (ppob/bukan miv), data pelunasan bank (Tidak ada)/Tidak lunas'
                        when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is not null)
                            then 'selisih - data usulan pln (ada)/lunas (Bank Lain), data pelunasan bank (ada)/lunas (Konfirmasi/Log Bank)'
                        else 'selisih - belum teridentifikasi'
                     end as keterangan
                    from
                    (
                        select a.tglapprove,
                             nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va,a.satker, a.nousulan pln_nousulan, a.kdproses pln_kdproses, a.status pln_status,
                             a.idpel pln_idpel, a.blth pln_blth
                             ,lunas_H0 pln_lunas_H0,
                             a.rptag pln_rptag, a.rpbk pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,a.kdbank pln_kdbank,
                             b. Proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                             nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,
                             b.kdbank bank_kdbank
                        from pln_data_ntl a, bank_data_ntl b
                        where a.nousulan = b.nousulan (+)
                        and   a.idpel    = b.idpel (+)
                        union
                        select a.tglapprove,
                             nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker,nvl(a.nousulan,b.nousulan) pln_nousulan, nvl(a.kdproses,'2') pln_kdproses, nvl(a.status,1) pln_status, a.idpel pln_idpel, a.blth pln_blth
                             ,lunas_H0 pln_lunas_H0,nvl(a.rptag,0) pln_rptag, nvl(a.rpbk,0) pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,nvl(a.kdbank,b.kdbank) pln_kdbank,
                             b.proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                             nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,nvl(b.kdbank,a.kdbank) bank_kdbank
                        from pln_data_ntl a, bank_data_ntl b
                        where b.nousulan = a.nousulan (+)
                        and   b.idpel    = a.idpel (+)
                        and   a.kdbank is null
                     ) x
                    where kd_dist =   vkd_dist
                    )
                    union
                    (
                    select 3 urut,'PREPAID' produk, x.*,
                    nvl(x.pln_rptag,0)-nvl(x.bank_rptag,0) selisih_rptag,
                    nvl(x.pln_rpbk,0)-nvl(x.bank_rpbk,0) selisih_bk,
                    case
                        when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) = 0) and (pln_idpel = bank_idpel )
                           then ''
                        when (pln_idpel is null) and (bank_idpel is not null)
                           then 'selisih - data usulan pln (tidak ada), data pelunasan bank (ada)'
                        when (pln_idpel is not null) and (pln_tglbayar is null) and (bank_idpel is null)
                           then 'selisih - data usulan pln (ada), data pelunasan bank (tidak ada)/tidak lunas'
                        when (pln_idpel is not null and bank_idpel is not null ) and (pln_tglbayar is null and bank_tglbayar is not null)
                           then 'selisih - data usulan pln (ada)/tidak lunas , data pelunasan bank (ada)/lunas (Chek Reversal Sukses Dijawab PLN)'
                        when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) = PLN_KDBANK)
                            then 'selisih - data usulan pln (ada)/lunas , data pelunasan bank (Tidak ada)/Tidak lunas (Konfirmasi/Log Bank/Belum Rekon)'
                        when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is null)
                            then 'selisih - data usulan pln (ada)/lunas (ppob/bukan miv), data pelunasan bank (Tidak ada)/Tidak lunas'
                        when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is not null)
                            then 'selisih - data usulan pln (ada)/lunas (Bank Lain), data pelunasan bank (ada)/lunas (Konfirmasi/Log Bank)'
                        else 'selisih - belum teridentifikasi'
                     end as keterangan
                    from
                    (
                        select a.tglapprove,
                             nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker, a.nousulan pln_nousulan, a.kdproses pln_kdproses, a.status pln_status,
                             a.idpel pln_idpel, a.blth pln_blth
                             ,lunas_H0 pln_lunas_H0,a.rptag pln_rptag, a.rpbk pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,a.kdbank pln_kdbank,
                             b. Proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                             nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,
                             b.kdbank bank_kdbank
                        from pln_data_pre a, bank_data_pre b
                        where a.nousulan = b.nousulan (+)
                        and   a.idpel    = b.idpel (+)
                        union
                        select a.tglapprove,
                             nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker,nvl(a.nousulan,b.nousulan) pln_nousulan, nvl(a.kdproses,'2') pln_kdproses, nvl(a.status,1) pln_status, a.idpel pln_idpel, a.blth pln_blth
                             ,lunas_H0 pln_lunas_H0, nvl(a.rptag,0) pln_rptag, nvl(a.rpbk,0) pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,nvl(a.kdbank,b.kdbank) pln_kdbank,
                             b.proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                             nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,nvl(b.kdbank,a.kdbank) bank_kdbank
                        from pln_data_pre a, bank_data_pre b
                        where b.nousulan = a.nousulan (+)
                        and   b.idpel    = a.idpel (+)
                        and   a.kdbank is null
                     ) x
                     where kd_dist =   vkd_dist
                    )
                ) x
                ORDER BY
                  CASE WHEN in_sort_dir = 'ASC'  AND in_sort_by = 'KD_DIST' THEN x.KD_DIST END ASC,
                  CASE WHEN in_sort_dir = 'DESC' AND in_sort_by = 'KD_DIST' THEN x.KD_DIST END DESC 
                -- end query utama
                ----------------------------------------------------------------------------    
              ) x
              WHERE ROWNUM <= (in_start + in_lenght)
            )
            WHERE ROW_NUMBER > in_start
            AND (
              in_search IS NULL OR
              TO_CHAR(PLN_IDPEL) LIKE '%' || in_search || '%' OR
              TO_CHAR(BANK_IDPEL) LIKE '%' || in_search || '%' OR
              LOWER(PLN_NOUSULAN) LIKE '%' || LOWER(in_search) || '%' OR
              LOWER(TGLAPPROVE) LIKE '%' || LOWER(in_search) || '%' OR
              LOWER(VA) LIKE '%' || LOWER(in_search) || '%' OR
              LOWER(SATKER) LIKE '%' || LOWER(in_search) || '%' OR
              LOWER(BANK_NOUSULAN) LIKE '%' || LOWER(in_search) || '%' OR
              LOWER(BANK_USERID) LIKE '%' || LOWER(in_search) || '%' 
            );
                      
        pesan := 'Sukses tampilkan data.';
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           pesan:='Gagal Tampilkan Data Tdak Ada, '||vEmsg||'  '||SQLERRM;
        WHEN OTHERS THEN
           pesan:='Gagal Tampilkan Data ' ||SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; 
    END;
                    
    PROCEDURE monlap_dft_mivfalg_plnvsbank_uiw_pgs(
                    in_start         in number,
                    in_lenght        in number,
                    in_sort_by       in varchar2,
                    in_sort_dir      in varchar2,
                    in_search        in varchar2,
                    vbln_usulan IN NUMBER, vkdbank in VARCHAR, vkd_dist in VARCHAR, out_data out sys_refcursor, pesan out varchar2) is
        vEmsg varchar2(50) default null;
    BEGIN
        vEmsg := 'Gagal Tampilkan Data ';
        pesan := 'Gagal Tampilkan Data ';
        open out_data for
            --------------------------------------------------------------------
            --  contoh input tarik data rekon sakti BANK vs P2APST
            --  Tekan ctrl+enter mausukan :
            ---    bln_usulan : 202503 -- Tahun Bulan Falging Sakti yang diminta
            ---    bank       : 111    -- kode bank DKI 3 digit
            ---    apj        : 00     -- sakti seluruh UID/UIW seindonesia
            --------------------------------------------------------------------
            With pln_data as
                (
                    select to_char(tglinsert,'YYYYMMDD HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data' proses,a.va, a.nousulan, a.kdproses, a.status,a.idpel, a.blth,
                           nvl(b.rptag,0) rptag, nvl(b.rpbk,0) rpbk,b.tglbayar,b.jambayar, b.userid, a.kdbank kdbank
                           ,a.satker,  (b.tglbayar||'  '||b.jambayar||'  '||b.userid) lunas_H0
                    from ophartde.ver_temp_data_locking a, olap.h2h b
                    where a.idpel       = b.idpel (+)
                    and   a.blth        = b.blth  (+)
                    and   a.kdproses    = '2'
                    and   substr(a.nousulan,9,6)       = vbln_usulan
                    and  a.kdbank                      = vkdbank
                    and   a.status                     = '1'
                    --and   nvl(b.suspect,0)  in ('0','2')
                    and   b.suspect  in ('0','2')
                    union
                    select to_char(tglinsert,'YYYYMMDD  HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data' proses,a.va, a.nousulan, a.kdproses, a.status,a.idpel, a.blth,
                            0 rptag, 0 rpbk,null tglbayar, null jambayar,null userid, a.kdbank kdbank
                           ,a.satker,  (b.tglbayar||' '||b.jambayar||' '||b.userid) lunas_H0
                    from ophartde.ver_temp_data_locking a, olap.h2h b
                    where a.idpel       = b.idpel (+)
                    and   a.blth        = b.blth  (+)
                    and   a.kdproses    = '2'
                    and   substr(a.nousulan,9,6)       = vbln_usulan
                    and   a.kdbank                     = vkdbank
                    and   a.status                     = '1'
                    and   b.suspect is null
                ),
               bank_data as
                (
                    select
                      'bank_data' proses,a.va, a.nousulan, '2' kdproses, '1'  status,a.idpel, a.blth,
                      nvl(a.rptag,0) rptag, nvl(a.rpbk,0) rpbk,a.tglbayar,a.jambayar, a.userid, a.kdbank kdbank
                    from ophartde.ver_data_locking_bank a
                    where   substr(a.nousulan,9,6)  = vbln_usulan
                    -- and tglbayar = '$tglbayar'
                    and a.kdbank                    = vkdbank
                ),
               pln_data_ntl as
                (
                    select to_char(tglinsert,'YYYYMMDD  HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data' proses,a.va, a.nousulan, a.kdproses, a.status,a.noreg idpel, null blth
                           ,nvl(b.rptag,0) rptag, 0 rpbk,b.tglbayar,b.jambayar, b.userid, a.kdbank kdbank
                           ,a.satker,  (b.tglbayar||' '||b.jambayar||' '||b.userid) lunas_H0
                    from ophartde.ver_temp_data_locking_ntl a, olap.transaksi_nontaglis b
                    where a.noreg       = b.nomor_registrasi (+)
                    and   a.kdproses    = '2'
                    and   substr(a.nousulan,9,6)    = vbln_usulan
                    and   a.kdbank                  = vkdbank
                    and   a.status                  = '1'
                    and   b.suspect  in ('0','2')
                    union
                    select to_char(tglinsert,'YYYYMMDD  HH24:MI') tglapprove, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data' proses,a.va, a.nousulan,
                     a.kdproses, a.status,a.noreg idpel, null blth,
                      0 rptag, 0 rpbk, null tglbayar, null jambayar, null userid, a.kdbank kdbank
                     ,a.satker,  (b.tglbayar||' '||b.jambayar||' '||b.userid) lunas_H0
                    from ophartde.ver_temp_data_locking_ntl a, olap.transaksi_nontaglis b
                    where a.noreg       = b.nomor_registrasi (+)
                    and   a.kdproses    = '2'
                    and   substr(a.nousulan,9,6)   =  vbln_usulan
                    and   a.kdbank                 =  vkdbank
                    and   a.status                 =  '1'
                    and   b.suspect is null
                ),
               bank_data_ntl as
                (
                    select
                      'bank_data' proses,a.va, a.nousulan, '2' kdproses, '1'  status,a.noreg idpel, null blth,
                      nvl(a.rptag,0) rptag, 0 rpbk,a.tglbayar,a.jambayar, a.userid, a.kdbank kdbank
                    from ophartde.ver_data_locking_bank_ntl a
                    where   substr(a.nousulan,9,6)    = vbln_usulan
                    and a.kdbank                      = vkdbank
                ),
               pln_data_pre as
                (
                    select (select distinct to_char(tglinsert,'YYYYMMDD  HH24:MI') from OPHARTDE.VER_TEMP_DATA_LOCKING_PRE where nousulan = z.nousulan) tglapprove,
                            z.kddist, z.proses, z.va, z.nousulan, z.kdproses, z.status, z.idpel, null blth,
                           nvl(z.rptag,0) rptag, 0 rpbk, z.tglbayar, z.jambayar, z.userid, z.kdbank, z.satker, z.lunas_H0
                    from
                    (
                        (
                            select
                                rownum baris, f.kddist,f.proses,
                                f.va, f.nousulan, f.kdproses, f.status, f.idpel, f.rptag,
                                null tglbayar, null jambayar,
                                f.userid,  f.KDBANK, f.satker, decode(f.lunas_H0,1,null,f.lunas_H0) lunas_H0
                            from
                            (
                                    select  substr(a.nousulan,4,2) kddist,'pln_data_pre' proses,a.va,
                                            a.nousulan, '2' kdproses, a.status,a.idpel,
                                            a.rptag, A.KDBANK||'CA01' userid,A.KDBANK,a.satker, '1' lunas_H0
                                    from OPHARTDE.VER_TEMP_DATA_LOCKING_PRE a
                                    where to_char(tglinsert,'YYYYMM') =  vbln_usulan
                                    and    substr(a.nousulan,4,2)     = vkd_dist
                                    minus
                                    select  substr(a.nousulan,4,2) kddist,'pln_data_pre' proses,a.va,
                                    a.nousulan, '2' kdproses, a.status,a.idpel, a.rptag,
                                    b.userid,  a.KDBANK,a.satker,  '1' lunas_H0
                                    from
                                        (
                                           select  count(*) jml,  substr(m.nousulan,4,2) kd_dist, m.nousulan, m.tglusulan, m.idpel, m.rptag ,
                                                 m.kdbank, m.satker, m.va, m.status, m.KDBANK userid,
                                                 to_char(tglinsert,'YYYYMMDD') tglapprove
                                           -- to_char(tglinsert,'YYYYMMDD') tglapprove, to_char(tglinsert+4,'YYYYMMDD') maxtgltgltrans
                                           from OPHARTDE.VER_TEMP_DATA_LOCKING_PRE m
                                           where to_char(tglinsert,'YYYYMM') =  vbln_usulan
                                           group by  substr(m.nousulan,4,2) , m.nousulan, m.tglusulan, m.idpel, m.rptag,m.kdbank,
                                                    m.satker, m.va, status, m.KDBANK,
                                                    to_char(m.tglinsert,'YYYYMMDD')
                                        ) a, OLAP.TRANSAKSI_PREPAID b
                                        where  a.idpel    = b.idpel(+)
                                        and    a.rptag    = b.rptag
                                        and    a.TGLAPPROVE <= b.tglbayar
                                        and    substr(b.tglbayar,1,6)  = vbln_usulan
                                        and    substr(a.nousulan,4,2)  = vkd_dist
                                        and    a.kdbank                =  vkdbank
                                        and    b.UNSOLD is null
                                        and    B.TGL_REKON is not null
                                ) f
                        )
                        union
                        (
                           select rownum baris, nvl(substr(a.nousulan,4,2),a.kd_dist) kddist,'pln_data_pre' proses,
                             a.va, a.nousulan, '2' kdproses, a.status,a.idpel, a.rptag,
                             b.tglbayar,b.jambayar,
                             b.userid,  a.KDBANK, a.satker,  (b.tglbayar||' '||b.Jambayar||' '||b.Userid) lunas_H0
                            from
                                (
                                   select  count(*) jml, substr(m.nousulan,4,2) kd_dist, m.nousulan, m.tglusulan, m.idpel, m.rptag ,
                                         m.kdbank, m.satker, m.va, m.status, m.KDBANK userid,
                                         to_char(tglinsert,'YYYYMMDD') tglapprove
                                   from OPHARTDE.VER_TEMP_DATA_LOCKING_PRE m
                                   where to_char(tglinsert,'YYYYMM') =  vbln_usulan
                                   group by  substr(m.nousulan,4,2), m.nousulan, m.tglusulan, m.idpel, m.rptag,m.kdbank,
                                            m.satker, m.va, status, m.KDBANK,
                                            to_char(m.tglinsert,'YYYYMMDD')
                                ) a, OLAP.TRANSAKSI_PREPAID b
                                where  a.idpel    = b.idpel(+)
                                and    a.rptag    = b.rptag
                                and    a.TGLAPPROVE <= b.tglbayar
                                and    substr(b.tglbayar,1,6)  = vbln_usulan
                                and    substr(a.nousulan,4,2)  = vkd_dist
                                and    a.kdbank                = vkdbank
                                and    b.UNSOLD is null
                                and    B.TGL_REKON is not null
                           )
                    ) z
                ),
               bank_data_pre as
                (
                    select
                      'bank_data' proses,a.va, a.nousulan, '2' kdproses, '1'  status,a.idpel, null blth,
                      nvl(a.rptag,0) rptag, 0 rpbk,a.tglbayar,a.jambayar, a.userid, a.kdbank kdbank
                    from ophartde.ver_data_locking_bank_pre a
                    where substr(a.nousulan,9,6)    = vbln_usulan
                    and   a.kdbank                  = vkdbank
                )
            select *
            from 
            (
                select inner_result.*, rownum row_number
                from
                (
                    select  count(x.KD_DIST) over () total_count, x.*
                    from
                    (
                        (
                        select 1 urut,'POSTPAID' produk, x.*,
                        nvl(x.pln_rptag,0)-nvl(x.bank_rptag,0) selisih_rptag,
                        nvl(x.pln_rpbk,0)-nvl(x.bank_rpbk,0) selisih_bk,
                        case
                            when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) = 0) and (pln_idpel = bank_idpel )
                                 and (pln_blth = bank_blth )
                               then ''
                            when (pln_idpel is null) and (bank_idpel is not null)
                               then 'selisih - data usulan pln (tidak ada), data pelunasan bank (ada)'
                            when (pln_idpel is not null) and (pln_tglbayar is null) and (bank_idpel is null)
                               then 'selisih - data usulan pln (ada)/tidak lunas, data pelunasan bank (tidak ada)/tidak lunas (Belum Flag Bank/belum rekon)'
                            when (pln_idpel is not null and bank_idpel is not null ) and (pln_tglbayar is null and bank_tglbayar is not null)
                               then 'selisih - data usulan pln (ada)/tidak lunas , data pelunasan bank (ada)/lunas (Chek Reversal Sukses Dijawab PLN)'
                            when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) = PLN_KDBANK)
                                then 'selisih - data usulan pln (ada)/lunas , data pelunasan bank (Tidak ada)/Tidak lunas (Konfirmasi/Log Bank/Belum Rekon)'
                            when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is null)
                                then 'selisih - data usulan pln (ada)/lunas (ppob/bukan miv), data pelunasan bank (Tidak ada)/Tidak lunas'
                            when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is not null)
                                then 'selisih - data usulan pln (ada)/lunas (Bank Lain), data pelunasan bank (ada)/lunas (Konfirmasi/Log Bank)'
                            else 'selisih - belum teridentifikasi'
                         end as keterangan
                        from
                         (
                            select a.tglapprove,
                                 nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker, a.nousulan pln_nousulan, a.kdproses pln_kdproses, a.status pln_status, a.idpel pln_idpel, a.blth pln_blth
                                 , lunas_H0 pln_lunas_H0,a.rptag pln_rptag, a.rpbk pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,a.kdbank pln_kdbank,
                                 b. Proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                                 nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,
                                 b.kdbank bank_kdbank
                            from pln_data a, bank_data b
                            where a.nousulan = b.nousulan (+)
                            and   a.idpel    = b.idpel (+)
                            and   a.blth     = b.blth (+)
                        union
                        select a.tglapprove,
                             nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va,a.satker,nvl(a.nousulan,b.nousulan) pln_nousulan, nvl(a.kdproses,'2') pln_kdproses, nvl(a.status,1) pln_status, a.idpel pln_idpel, a.blth pln_blth
                             ,lunas_H0 pln_lunas_H0, nvl(a.rptag,0) pln_rptag, nvl(a.rpbk,0) pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,nvl(a.kdbank,b.kdbank) pln_kdbank,
                             b.proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                             nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,nvl(b.kdbank,a.kdbank) bank_kdbank
                        from pln_data a, bank_data b
                        where b.nousulan = a.nousulan (+)
                        and   b.idpel    = a.idpel (+)
                        and   b.blth     = a.blth (+)
                        and   a.kdbank is null
                        ) x
                        where kd_dist =   vkd_dist
                        )
                        union
                        (
                        select 2 urut,'NONTAGLIS' produk, x.*,
                        nvl(x.pln_rptag,0)-nvl(x.bank_rptag,0) selisih_rptag,
                        nvl(x.pln_rpbk,0)-nvl(x.bank_rpbk,0) selisih_bk,
                        case
                            when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) = 0) and (pln_idpel = bank_idpel )
                               then ''
                            when (pln_idpel is null) and (bank_idpel is not null)
                               then 'selisih - data usulan pln (tidak ada), data pelunasan bank (ada)'
                            when (pln_idpel is not null) and (pln_tglbayar is null) and (bank_idpel is null)
                               then 'selisih - data usulan pln (ada), data pelunasan bank (tidak ada)/tidak lunas'
                            when (pln_idpel is not null and bank_idpel is not null ) and (pln_tglbayar is null and bank_tglbayar is not null)
                               then 'selisih - data usulan pln (ada)/tidak lunas , data pelunasan bank (ada)/lunas (Chek Reversal Sukses Dijawab PLN)'
                            when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) = PLN_KDBANK)
                                then 'selisih - data usulan pln (ada)/lunas , data pelunasan bank (Tidak ada)/Tidak lunas (Konfirmasi/Log Bank/Belum Rekon)'
                            when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is null)
                                then 'selisih - data usulan pln (ada)/lunas (ppob/bukan miv), data pelunasan bank (Tidak ada)/Tidak lunas'
                            when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is not null)
                                then 'selisih - data usulan pln (ada)/lunas (Bank Lain), data pelunasan bank (ada)/lunas (Konfirmasi/Log Bank)'
                            else 'selisih - belum teridentifikasi'
                         end as keterangan
                        from
                        (
                            select a.tglapprove,
                                 nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va,a.satker, a.nousulan pln_nousulan, a.kdproses pln_kdproses, a.status pln_status,
                                 a.idpel pln_idpel, a.blth pln_blth
                                 ,lunas_H0 pln_lunas_H0,
                                 a.rptag pln_rptag, a.rpbk pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,a.kdbank pln_kdbank,
                                 b. Proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                                 nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,
                                 b.kdbank bank_kdbank
                            from pln_data_ntl a, bank_data_ntl b
                            where a.nousulan = b.nousulan (+)
                            and   a.idpel    = b.idpel (+)
                            union
                            select a.tglapprove,
                                 nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker,nvl(a.nousulan,b.nousulan) pln_nousulan, nvl(a.kdproses,'2') pln_kdproses, nvl(a.status,1) pln_status, a.idpel pln_idpel, a.blth pln_blth
                                 ,lunas_H0 pln_lunas_H0,nvl(a.rptag,0) pln_rptag, nvl(a.rpbk,0) pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,nvl(a.kdbank,b.kdbank) pln_kdbank,
                                 b.proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                                 nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,nvl(b.kdbank,a.kdbank) bank_kdbank
                            from pln_data_ntl a, bank_data_ntl b
                            where b.nousulan = a.nousulan (+)
                            and   b.idpel    = a.idpel (+)
                            and   a.kdbank is null
                         ) x
                        where kd_dist =   vkd_dist
                        )
                        union
                        (
                            select 3 urut,'PREPAID' produk, x.*,
                            nvl(x.pln_rptag,0)-nvl(x.bank_rptag,0) selisih_rptag,
                            nvl(x.pln_rpbk,0)-nvl(x.bank_rpbk,0) selisih_bk,
                            case
                                when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) = 0) and (pln_idpel = bank_idpel )
                                   then ''
                                when (pln_idpel is null) and (bank_idpel is not null)
                                   then 'selisih - data usulan pln (tidak ada), data pelunasan bank (ada)'
                                when (pln_idpel is not null) and (pln_tglbayar is null) and (bank_idpel is null)
                                   then 'selisih - data usulan pln (ada), data pelunasan bank (tidak ada)/tidak lunas'
                                when (pln_idpel is not null and bank_idpel is not null ) and (pln_tglbayar is null and bank_tglbayar is not null)
                                   then 'selisih - data usulan pln (ada)/tidak lunas , data pelunasan bank (ada)/lunas (Chek Reversal Sukses Dijawab PLN)'
                                when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) = PLN_KDBANK)
                                    then 'selisih - data usulan pln (ada)/lunas , data pelunasan bank (Tidak ada)/Tidak lunas (Konfirmasi/Log Bank/Belum Rekon)'
                                when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is null)
                                    then 'selisih - data usulan pln (ada)/lunas (ppob/bukan miv), data pelunasan bank (Tidak ada)/Tidak lunas'
                                when ((nvl(x.pln_rptag,0) - nvl(x.bank_rptag,0)) > 0) and (substr(pln_userid,1,3) <> PLN_KDBANK) and (bank_tglbayar is not null)
                                    then 'selisih - data usulan pln (ada)/lunas (Bank Lain), data pelunasan bank (ada)/lunas (Konfirmasi/Log Bank)'
                                else 'selisih - belum teridentifikasi'
                             end as keterangan
                            from
                            (
                                select a.tglapprove,
                                        nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker, a.nousulan pln_nousulan, a.kdproses pln_kdproses, a.status pln_status,
                                        a.idpel pln_idpel, a.blth pln_blth
                                        ,lunas_H0 pln_lunas_H0,a.rptag pln_rptag, a.rpbk pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,a.kdbank pln_kdbank,
                                        b. Proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                                        nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,
                                        b.kdbank bank_kdbank
                                from pln_data_pre a, bank_data_pre b
                                where a.nousulan = b.nousulan (+)
                                and   a.idpel    = b.idpel (+)
                                union
                                select a.tglapprove,
                                     nvl(a.kddist,substr(b.nousulan,4,2)) kd_dist,nvl(a.va,b.va) va, a.satker,nvl(a.nousulan,b.nousulan) pln_nousulan, nvl(a.kdproses,'2') pln_kdproses, nvl(a.status,1) pln_status, a.idpel pln_idpel, a.blth pln_blth
                                     ,lunas_H0 pln_lunas_H0, nvl(a.rptag,0) pln_rptag, nvl(a.rpbk,0) pln_rpbk, a.tglbayar pln_tglbayar,a.jambayar pln_jambayar,a.userid pln_userid,nvl(a.kdbank,b.kdbank) pln_kdbank,
                                     b.proses bank_keterangan, b.nousulan bank_nousulan, b.idpel bank_idpel, b.blth bank_blth,
                                     nvl(b.rptag,0) bank_rptag, nvl(b.rpbk,0) bank_rpbk, b.tglbayar bank_tglbayar,b.jambayar bank_jambayar,b.userid bank_userid,nvl(b.kdbank,a.kdbank) bank_kdbank
                                from pln_data_pre a, bank_data_pre b
                                where b.nousulan = a.nousulan (+)
                                and   b.idpel    = a.idpel (+)
                                and   a.kdbank is null
                            ) x
                            where kd_dist =   vkd_dist
                        )
                    ) x
                    WHERE (
                      in_search IS NULL OR
                      TO_CHAR(PLN_IDPEL) LIKE '%' || in_search || '%' OR
                      TO_CHAR(BANK_IDPEL) LIKE '%' || in_search || '%' OR
                      LOWER(PLN_NOUSULAN) LIKE '%' || LOWER(in_search) || '%' OR
                      LOWER(TGLAPPROVE) LIKE '%' || LOWER(in_search) || '%' OR
                      LOWER(VA) LIKE '%' || LOWER(in_search) || '%' OR
                      LOWER(SATKER) LIKE '%' || LOWER(in_search) || '%' OR
                      LOWER(BANK_NOUSULAN) LIKE '%' || LOWER(in_search) || '%' OR
                      LOWER(BANK_USERID) LIKE '%' || LOWER(in_search) || '%' 
                    )
                    ORDER BY x.pln_idpel, x.pln_blth desc, 
                        CASE WHEN in_sort_dir = 'ASC'  AND in_sort_by = 'KD_DIST' THEN x.KD_DIST END ASC,
                        CASE WHEN in_sort_dir = 'DESC' AND in_sort_by = 'KD_DIST' THEN x.KD_DIST END DESC 
                )  inner_result
                where rownum <= in_start * in_lenght
            )
            where row_number > ((in_start - 1) * in_lenght);
                      
        pesan := 'Sukses tampilkan data.';
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           pesan:='Gagal Tampilkan Data Tdak Ada, '||vEmsg||'  '||SQLERRM;
        WHEN OTHERS THEN
           pesan:='Gagal Tampilkan Data ' ||SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; 
    END;
    
    PROCEDURE monlap_saktiDaftar_UnPending_pusat(vbln_usulan IN NUMBER, vkdgol in varchar2, vkdgerak in varchar2,vprqatis in varchar2, out_cursor out SYS_REFCURSOR, pesan out VARCHAR) IS
        vEmsg varchar2(50) default null;
    BEGIN
          
     vEmsg := ' SAKTI ';
     pesan:='Gagal Tampilkan Data ';
     open out_cursor for
            select 'SAKTI' Proses
                     , (select KD_DIST||' -  '||NAMA_DIST NAMA_DIST from OLAP.MASTER_DISTRIBUSI where kd_dist = a.kd_dist and rownum < 2) NAMA_DIST
                     , (select UNITUP||' - '||NAMA NAMA_ULP from OLAP.MASTER_unit where  UNITUP = a.UNITUP and rownum < 2) NAMA_ULP
                     , Idpel, blth, Nama, rptag
                     , kdgerak, TGLBAYAR, JAMBAYAR
                     , decode(praqtis,0,'PENDING','UNPENDING') STAUS
                     , decode(a.userid,'UNLOCK',null, (select a.userid||' - '||NAMA_BANK from OLAP.MASTER_BANK  where KODE_BANK = substr(a.userid,1,3) and rownum < 2)) userid
            from plngatepost.dpp a
            where (idpel, blth) in
            (
                select idpel,blth
                from OPHARTDE.VER_TEMP_DATA_LOCKING_SAKTI a
                where  BLTH_USUL = vbln_usulan
                and status = '1'
                and kdproses = '1'  --area
            )
            and substr(LTRIM(KOGOL),1,1) = vkdgol
            and KDGERAK = vkdgerak
            and praqtis = vprqatis;
            
             pesan :='Sukses Tampilkan Data Ada';
        
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          pesan:='Gagal Proses Data Sudah Ada '||SQLERRM;
          WHEN NO_DATA_FOUND THEN
           pesan:='Gagal Proses Data Tdak Ada, '||vEmsg||'  '||SQLERRM;
        WHEN OTHERS THEN
           pesan:='Gagal Proses Data ' ||SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;          
    END;

END VER_MON_LAP;
/