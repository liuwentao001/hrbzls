CREATE OR REPLACE FUNCTION HRBZLS.FGETOROLECLASS (P_ORID IN VARCHAR2)
  RETURN VARCHAR2 IS
  V_RET VARCHAR2(10);
BEGIN
  SELECT ORCLASS INTO V_RET FROM OPERROLE WHERE ORID = P_ORID;
  RETURN V_RET;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
/

