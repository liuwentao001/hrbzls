CREATE OR REPLACE FUNCTION HRBZLS."FGETBOOKFRAME" (P_BFID IN VARCHAR2)
 RETURN VARCHAR2
AS
 LRET VARCHAR2(60);
BEGIN
 SELECT BFNAME
 INTO LRET
 FROM BOOKFRAME
 WHERE BFID = P_BFID;
 RETURN LRET;
EXCEPTION WHEN OTHERS THEN
 RETURN NULL;
END;
/
