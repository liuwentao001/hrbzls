CREATE OR REPLACE FUNCTION HRBZLS.F_CHR10(P_STR IN VARCHAR2)
--ȥ��tab��
RETURN VARCHAR2 AS
  V_TMP VARCHAR2(4000);
BEGIN 
  V_TMP:=   ( case when instr( P_STR,CHR(10)) > 0  then 
  REPLACE(P_STR,chr(10),'')   else P_STR end ) ;
  RETURN V_TMP;
END F_CHR10;
/

