CREATE OR REPLACE FUNCTION HRBZLS."FPARA" (P_SMPID IN VARCHAR2,P_SMPPID IN VARCHAR2)
 RETURN VARCHAR2
AS
 LRET VARCHAR2(4000);
BEGIN
 SELECT SMPPVALUE
 INTO LRET
 FROM SYSMANAPARA
 WHERE SMPID = P_SMPID AND SMPPID = P_SMPPID;
 RETURN LRET;
EXCEPTION WHEN OTHERS THEN
 RETURN NULL;
END;
/

