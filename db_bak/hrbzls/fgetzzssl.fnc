CREATE OR REPLACE FUNCTION HRBZLS."FGETZZSSL" ( p_pfid in varchar2) return number
is
  ret number;
  v_pdj number;
begin
  v_pdj:=FGETPRICEITEMDJ(p_pfid,'01');
  select v_pdj /1.06 * 0.6 into ret from dual;
  return ret;
exception
  when others then
    return 0;
end;
/

