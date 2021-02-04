CREATE OR REPLACE FUNCTION HRBZLS."FCHECKMRRECYCMON" (P_RECYCID IN VARCHAR2,
                                            P_MRMON   IN VARCHAR2)
  RETURN VARCHAR2 AS
  VNUM NUMBER;
  LVALUE VARCHAR2(1);
BEGIN
--判断表册周期与抄表月份是否相符合
  VNUM := TO_NUMBER(SUBSTR(P_MRMON, 6, 2));
  VNUM := MOD(VNUM, 2);
  IF VNUM = 1 THEN
    IF P_RECYCID = '1' OR P_RECYCID = '3' THEN
      LVALUE := 'Y';
    ELSE
      LVALUE := 'N';
    END IF;
  ELSIF VNUM = 0 THEN
    IF P_RECYCID = '2' OR P_RECYCID = '3' THEN
      LVALUE := 'Y';
    ELSE
      LVALUE := 'N';
    END IF;
  ELSE
    LVALUE := 'N';
  END IF;
  RETURN LVALUE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END;
/

