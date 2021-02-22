CREATE OR REPLACE FUNCTION HRBZLS."FGETSYSAREAFRAME" (P_SAFID IN VARCHAR2)
 RETURN VARCHAR2
AS
 LRET varchar2(100);
BEGIN
 SELECT SAFNAME
 INTO LRET
 FROM SYSAREAFRAME
 WHERE SAFID = P_SAFID;
 RETURN LRET;
EXCEPTION WHEN OTHERS THEN
 RETURN NULL;
END;
/
