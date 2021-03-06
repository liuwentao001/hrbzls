CREATE OR REPLACE FUNCTION HRBZLS."FGETOPERRANGE" (P_OAID     IN VARCHAR2,
                                         P_OPERTYPE IN VARCHAR2)
  RETURN VARCHAR2 AS
  LRANGFLAG VARCHAR2(10);
  LRET      VARCHAR2(4000);
BEGIN
  SELECT OADRANGE INTO LRANGFLAG FROM OPERACCNT WHERE OAID = P_OAID;
  IF LRANGFLAG = 'Y' THEN
    --全部营业所能增删改查
    SELECT REPLACE(CONNSTR(SMFID), '/', ''',''')
      INTO LRET
      FROM SYSMANAFRAME T
     WHERE SUBSTR(SMFPID, 1, 2) = '02'
       AND T.SMFSTATUS = 'Y'
       AND T.SMFCLASS = '2';
  ELSE
    --自定义
    SELECT REPLACE(CONNSTR(SMFID), '/', ''',''')
      INTO LRET
      FROM SYSMANAFRAME, OPERSEACHRANGE
     WHERE OSROAID = P_OAID
       AND OSRID = SMFID
       AND INSTR(OSRTYPELIST, UPPER(P_OPERTYPE)) > 0
       AND OSRSORT = 'S'
       AND SMFTYPE = '1';

  END IF;

  RETURN '''' || LRET || '''';
EXCEPTION
  WHEN OTHERS THEN
    RETURN '''''';
END;
/

