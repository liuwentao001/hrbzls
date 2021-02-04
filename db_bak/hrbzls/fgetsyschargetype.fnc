CREATE OR REPLACE FUNCTION HRBZLS."FGETSYSCHARGETYPE" (P_SCTID IN VARCHAR2 )
 RETURN VARCHAR2
AS
 LRET VARCHAR2(20);
BEGIN
 SELECT SCTNAME
 INTO LRET
 FROM SYSCHARGETYPE
 WHERE SCTID = P_SCTID;
 RETURN LRET;
EXCEPTION WHEN OTHERS THEN
 RETURN NULL;
END;
/

