CREATE OR REPLACE FUNCTION HRBZLS."FGETACCOUNTCD" (P_acdid IN CHAR )
 RETURN VARCHAR2
AS
 LRET VARCHAR2(20);
BEGIN
 SELECT acdname
 INTO LRET
 FROM ACCOUNTCD
 WHERE acdid = P_acdid;
 RETURN LRET;
EXCEPTION WHEN OTHERS THEN
 RETURN NULL;
END;
/
