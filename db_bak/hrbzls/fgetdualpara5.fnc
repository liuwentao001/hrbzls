CREATE OR REPLACE FUNCTION HRBZLS."FGETDUALPARA5" (p_type in varchar2)
  RETURN VARCHAR2 AS

BEGIN
commit;
  RETURN 'Y';
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END;
/
