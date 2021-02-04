CREATE OR REPLACE FUNCTION HRBZLS."FGETPRICEITEM" (P_PIID IN VARCHAR2 )
 RETURN VARCHAR2
AS
 LRET VARCHAR2(30);
BEGIN
 SELECT PINAME
 INTO LRET
 FROM PRICEITEM
 WHERE PIID = P_PIID;
 RETURN LRET;
EXCEPTION WHEN OTHERS THEN
 RETURN NULL;
END;
/

