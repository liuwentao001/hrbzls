CREATE OR REPLACE FUNCTION HRBZLS."FGETPRICEDJ" (P_PFID IN VARCHAR2 )
 RETURN number
AS
 v_dj number(12,3);
BEGIN
 SELECT SUM(nvl(T.PDDJ,0))
 INTO v_dj
 FROM pricedetail t
 WHERE t.PDPFID = P_PFID;
 RETURN v_dj;
EXCEPTION WHEN OTHERS THEN
 RETURN 0;
END;
/

