CREATE OR REPLACE FUNCTION HRBZLS."FGETSYSCUSTSTATUS" (P_SCSID IN VARCHAR2 )
 RETURN VARCHAR2
AS
 LRET VARCHAR2(20);
BEGIN
 SELECT SCSNAME
 INTO LRET
 FROM SYSCUSTSTATUS
 WHERE SCSID = P_SCSID;
 RETURN LRET;
EXCEPTION WHEN OTHERS THEN
 RETURN NULL;
END;
/

