CREATE OR REPLACE FUNCTION HRBZLS."FGETBFORDER" (P_MID IN VARCHAR2)
  return varchar2 is
  V_ORDER VARCHAR2(20);
begin
  SELECT TRIM(TO_CHAR(M.MIBFID,'00000000'))||TRIM(TO_CHAR(M.MIRORDER,'00000')) INTO V_ORDER FROM METERINFO M WHERE M.MIID=P_MID;

  RETURN V_ORDER;
exception
  when others then
    return '9999999999999';
end;
/

