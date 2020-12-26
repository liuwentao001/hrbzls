﻿CREATE OR REPLACE FUNCTION "FGETSEQUENCE"(AS_TAB_NAME IN VARCHAR2)
  RETURN VARCHAR2 IS
  ----------------------------------------------------------------------------
  -- 函数：GET_SEQUENCE
  -- 按照在SEQ LIST 表中定义的细节返回序列值
  -- INPUT： AS_TAB_NAME 数据表名
  -- RETURN：VARCHAR2 返回的序列值
  ----------------------------------------------------------------------------
  LN_SEQ_NUM    NUMBER;
  V_SQL         VARCHAR2(500);
  LS_SEQ_NUM    VARCHAR2(20);
  AS_SEQ_NAME   VARCHAR2(30);
  TEMP_ID       VARCHAR2(40);
  LS_CUR_SYNTAX VARCHAR(200);
  LR_SEQLIST    SYS_SEQLIST%ROWTYPE;
  PRELEN        NUMBER;
BEGIN

  --获得当前的序列相关的定义
  SELECT SSLSEQNAME, NVL(SSLPREFIX, ' '), SSLWIDTH, SSLSTARTNO
    INTO LR_SEQLIST.SSLSEQNAME,
         LR_SEQLIST.SSLPREFIX,
         LR_SEQLIST.SSLWIDTH,
         LR_SEQLIST.SSLSTARTNO
    FROM SYS_SEQLIST
   WHERE SSLTBLNAME = AS_TAB_NAME;

  IF TRIM(LR_SEQLIST.SSLPREFIX) IS NULL THEN
    PRELEN := 0;
  ELSE
    PRELEN := LENGTH(TRIM(LR_SEQLIST.SSLPREFIX));
  END IF;

  --动态SQL取序列的值
  AS_SEQ_NAME   := LR_SEQLIST.SSLSEQNAME;
  LS_CUR_SYNTAX := 'SELECT ' || AS_SEQ_NAME || '.NEXTVAL FROM DUAL';

  -- 按照预定的格式返回序列值
  TEMP_ID    := '000000000000000000000000000000' ||
                TO_CHAR(LR_SEQLIST.SSLSTARTNO);
  LS_SEQ_NUM := TRIM(LR_SEQLIST.SSLPREFIX ||
                     SUBSTR(TEMP_ID,
                            LENGTH(TEMP_ID) - LR_SEQLIST.SSLWIDTH + PRELEN + 1,
                            LR_SEQLIST.SSLWIDTH - PRELEN));
  V_SQL      := 'UPDATE SYS_SEQLIST A SET A.SSLSTARTNO=' || (LS_SEQ_NUM + 1) ||' WHERE A.SSLSEQNAME = UPPER(''' || AS_SEQ_NAME || ''')';
  EXECUTE IMMEDIATE V_SQL;
  COMMIT;

  RETURN(LS_SEQ_NUM);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    LS_SEQ_NUM := 'seq not exist!';
    RETURN LS_SEQ_NUM;
  WHEN OTHERS THEN
    BEGIN
      -- 如果序列不存在，则按SEQ LIST数据表中的定义动态生成序列
      LS_CUR_SYNTAX := 'CREATE SEQUENCE ' || AS_SEQ_NAME ||
                       ' MINVALUE 1
                            MAXVALUE 9999999999999999999999999999 START WITH ' ||
                       TO_CHAR(LR_SEQLIST.SSLSTARTNO + 1);
      EXECUTE IMMEDIATE (LS_CUR_SYNTAX);
      LN_SEQ_NUM := LR_SEQLIST.SSLSTARTNO;
    
      -- 按照预定的格式返回序列的初始值
      TEMP_ID    := '000000000000000000000000000000' || TO_CHAR(LN_SEQ_NUM);
      LS_SEQ_NUM := TRIM(LR_SEQLIST.SSLPREFIX ||
                         SUBSTR(TEMP_ID,
                                LENGTH(TEMP_ID) - LR_SEQLIST.SSLWIDTH +
                                PRELEN + 1,
                                LR_SEQLIST.SSLWIDTH - PRELEN));
      RETURN LS_SEQ_NUM;
    EXCEPTION
      WHEN OTHERS THEN
        LS_SEQ_NUM := 'seq error!';
        RETURN LS_SEQ_NUM;
    END;
END;
/

