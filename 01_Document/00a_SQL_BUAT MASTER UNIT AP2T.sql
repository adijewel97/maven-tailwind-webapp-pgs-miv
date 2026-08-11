--0
create table adi_setiadi.ZVER_MASTER_UNIT_202607 as
select *
from OPHARTDE.VER_MASTER_UNIT;

--1
--create table adi_setiadi.VER_MASTER_UNIT as 
select *
from OPHARTDE.VER_MASTER_UNIT
where rownum = 1;


--2
select *
from adi_setiadi.VER_MASTER_UNIT;

--3
declare cursor data is
    select UNITUP, AREA, KD_ERP
    from OLAP.MASTER_UNIT;
BEGIN
    FOR c1 in data loop
       UPDATE adi_setiadi.VER_MASTER_UNIT
       SET  UNITAP_P2APST  = c1.AREA,
            KD_ERP         = c1.KD_ERP
       WHERE unitup = c1.unitup;
       COMMIT;
    END LOOP;
END;

--4


--5
--insert into OPHARTDE.VER_MASTER_UNIT (KD_DIST, UNITAP_P2APST, UNITAP_AP2T, KD_ERP, UNITUP, NAMA_DIST, NAMA_AREA, NAMA_UNIT, ALAMAT_UNIT, KET)
select KD_DIST, UNITAP_P2APST, UNITAP_AP2T, KD_ERP, UNITUP, NAMA_DIST, NAMA_AREA, NAMA_UNIT, ALAMAT_UNIT, decode(UNITAP_P2APST,UNITAP_AP2T,'SAMA','BEDA') KET
from adi_setiadi.VER_MASTER_UNIT
where UNITUP in
(
    select UNITUP
    from adi_setiadi.VER_MASTER_UNIT
    minus
    select UNITUP
    from OPHARTDE.VER_MASTER_UNIT
)


--6
select 'DELETE OPHARTDE.VER_MASTER_UNIT where UNITUP = '''||UNITUP||''';' as UNITUP
FROM
(
    select UNITUP
    from OPHARTDE.VER_MASTER_UNIT
    minus
    select UNITUP
    from adi_setiadi.VER_MASTER_UNIT
)

