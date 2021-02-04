CREATE OR REPLACE FUNCTION HRBZLS."FMIJCBM"
 (TCODE IN CHAR,TCLASS IN NUMBER)
 RETURN CHAR
 AS
 LCODE VARCHAR2(10);
 BEGIN
 SELECT MIID INTO LCODE FROM METERINFO WHERE MICLASS=TCLASS
 START WITH MIID=TCODE CONNECT BY PRIOR MIPID=MIID;
 RETURN LCODE;
 EXCEPTION WHEN OTHERS THEN
 LCODE := TCODE;
 RETURN LCODE;
 END FMIJCBM;
/

