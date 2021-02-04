CREATE OR REPLACE FUNCTION HRBZLS."FGETPBOPER" RETURN VARCHAR2 IS
  RET VARCHAR2(10);
BEGIN
  SELECT LOGIN_USER
    INTO RET
    FROM SYS_HOST T
   WHERE T.IP = SYS_CONTEXT('USERENV', 'sid');
  RETURN RET;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'system';
END;
/

