CREATE OR REPLACE FUNCTION HRBZLS."FGETRECTRANS" (P_RTID IN VARCHAR2 )
 RETURN VARCHAR2
AS
 LRET VARCHAR2(20);
BEGIN
 SELECT RTNAME
 INTO LRET
 FROM RECTRANS
 WHERE RTID = P_RTID;
 RETURN LRET;
EXCEPTION WHEN OTHERS THEN
 RETURN NULL;
END;
/

