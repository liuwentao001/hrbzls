CREATE OR REPLACE FUNCTION HRBZLS."FGETREPLACEINFO" (P_REPLACE IN VARCHAR2)
 RETURN VARCHAR2
AS

BEGIN
IF INSTR(P_REPLACE,'��')>0 OR INSTR(P_REPLACE,'��')>0 THEN
 RETURN  REPLACE(REPLACE(P_REPLACE,'��','('),'��',')');
END IF;
EXCEPTION WHEN OTHERS THEN
 RETURN P_REPLACE;
END;
/

