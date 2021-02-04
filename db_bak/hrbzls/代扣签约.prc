CREATE OR REPLACE PROCEDURE HRBZLS."代扣签约" IS
  V_ENTRUSTFILE ENTRUSTFILE%ROWTYPE;
  --需要签约的资料
  CURSOR C_ENTRUSTFILE IS
    SELECT *
      FROM ENTRUSTFILE EF
     WHERE UPPER(SUBSTR(EF.EFFILENAME, 1, 4)) = 'DKQY'
       AND EF.EFFLAG = '2';
  --签约明细
  CURSOR C_QYMX IS
    SELECT TOOLS.FMID(C1, 2, 'Y', '|') MIID, --水表号码
           TOOLS.FMID(C1, 3, 'Y', '|') MABANKID, --银行编码
           TOOLS.FMID(C1, 4, 'Y', '|') MAACCOUNTNO, --银行账号
           TOOLS.FMID(C1, 5, 'Y', '|') MAACCOUNTNAME, --银行账号
           TOOLS.FMID(C1, 6, 'Y', '|') QYZT, --签约状态1.签约，2.解约
           TO_DATE(TOOLS.FMID(C1, 7, 'Y', '|'), 'yyyymmdd') ZTSJ, --状态时间
           TOOLS.FMID(C1, 8, 'Y', '|') CLRY, --处理人员
           C1
      FROM PBPARMTEMP_TEST;
  --用户信息
  CURSOR C_MI(P_MICOE VARCHAR2) IS
    SELECT * FROM METERINFO WHERE MICODE = P_MICOE;
  --银行参数信息
  CURSOR C_SM(P_SMPPVALUE VARCHAR2) IS
    SELECT *
      FROM SYSMANAPARA T
     WHERE T.SMPPID = 'BCODE'
       AND SUBSTR(SMPID, 1, 2) = '03'
       AND T.SMPPVALUE = P_SMPPVALUE;
  V_BANKQYLOG   BANKQYLOG%ROWTYPE;
  V_MIID        METERINFO.MIID%TYPE;
  V_MI          METERINFO%ROWTYPE;
  V_MA          METERACCOUNT%ROWTYPE;
  V_NUMBER      NUMBER;
  FOUND         BOOLEAN;
  V_MX          PBPARMTEMP.C1%TYPE;
  V_SYSMANAPARA SYSMANAPARA%ROWTYPE;
  V_EF          ENTRUSTFILE%ROWTYPE;
  V_TEMPSTR     VARCHAR2(30000);
  V_CLOB        CLOB;
BEGIN
  DBMS_LOB.CREATETEMPORARY(V_CLOB, TRUE);
  OPEN C_ENTRUSTFILE;
  LOOP
    FETCH C_ENTRUSTFILE
      INTO V_ENTRUSTFILE;
    EXIT WHEN C_ENTRUSTFILE%NOTFOUND OR C_ENTRUSTFILE%NOTFOUND IS NULL;
    --导入签约文件到临时表
    SP_DZ_IMP(V_ENTRUSTFILE.EFID);
    --处理
    OPEN C_QYMX;
    LOOP
      FETCH C_QYMX
        INTO V_BANKQYLOG.MICODE,
             V_BANKQYLOG.BANKID,
             V_BANKQYLOG.ACCOUNTNO,
             V_BANKQYLOG.ACCOUNTNAME,
             V_BANKQYLOG.QYZT,
             V_BANKQYLOG.ZTRQ,
             V_BANKQYLOG.CLRY,
             V_MX;
      EXIT WHEN C_QYMX%NOTFOUND OR C_QYMX%NOTFOUND IS NULL;
      V_BANKQYLOG.XYZT := 'Y';
      V_BANKQYLOG.ZTYY := '处理成功!';
      V_BANKQYLOG.ID   := V_ENTRUSTFILE.EFID;
      --检查用户信息
      OPEN C_MI(V_BANKQYLOG.MICODE);
      FETCH C_MI
        INTO V_MI;
      FOUND := C_MI%FOUND;
      CLOSE C_MI;
      IF NOT FOUND THEN
        V_BANKQYLOG.ZTYY := '不存在此用户信息';
        V_BANKQYLOG.XYZT := 'N';
      END IF;
      IF V_MI.MICHARGETYPE = 'T' THEN
        V_BANKQYLOG.ZTYY := '托收用户不许签约';
        V_BANKQYLOG.XYZT := 'N';
      END IF;

      --检查银行信息
      OPEN C_SM(V_BANKQYLOG.BANKID);
      FETCH C_SM
        INTO V_SYSMANAPARA;
      FOUND := C_SM%FOUND;
      CLOSE C_SM;
      IF NOT FOUND THEN
        V_BANKQYLOG.ZTYY := '此银行编码不存在' || V_MA.MABANKID;
        V_BANKQYLOG.XYZT := 'N';
      END IF;

      --更新用户银行信息
      IF V_BANKQYLOG.XYZT = 'Y' THEN
        BEGIN
          IF V_BANKQYLOG.QYZT = '1' THEN
            UPDATE METERINFO MI
               SET MI.MICHARGETYPE = 'D'
             WHERE MI.MICODE = V_BANKQYLOG.MICODE;
          ELSE
            UPDATE METERINFO MI
               SET MI.MICHARGETYPE = 'X'
             WHERE MI.MICODE = V_BANKQYLOG.MICODE;
          END IF;
          UPDATE METERACCOUNT MA
             SET MA.MABANKID      = V_SYSMANAPARA.SMPID, --  开户行（代托）
                 MA.MAACCOUNTNO   = V_BANKQYLOG.ACCOUNTNO, --开户帐号（代托）
                 MA.MAACCOUNTNAME = V_BANKQYLOG.ACCOUNTNAME, --开户名（代托）
                 MA.MAREGDATE     = V_BANKQYLOG.ZTRQ --签约日期
           WHERE MA.MAMID = V_BANKQYLOG.MICODE;

        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
            V_BANKQYLOG.XYZT := 'N';
            V_BANKQYLOG.ZTYY := SQLERRM;
        END;
      END IF;
      V_BANKQYLOG.XYSJ := SYSDATE;
      --记录处理日志
      INSERT INTO BANKQYLOG VALUES V_BANKQYLOG;
      V_TEMPSTR := REPLACE(REPLACE(V_MX, CHR(13), ''), CHR(10), '') ||
                   V_BANKQYLOG.XYZT || '|' ||
                   TO_CHAR(V_BANKQYLOG.XYSJ, 'yyyymmdd') || '|' ||
                   V_BANKQYLOG.ZTYY || '|' || CHR(13) || CHR(10);
      DBMS_LOB.WRITEAPPEND(V_CLOB, LENGTH(V_TEMPSTR), V_TEMPSTR);
    END LOOP;
    IF C_QYMX%ISOPEN THEN
      CLOSE C_QYMX;
    END IF;
    -- V_EF.EFID           := 0;
    V_EF.EFSRVID        := V_ENTRUSTFILE.EFSRVID;
    V_EF.EFPATH         := V_ENTRUSTFILE.EFPATH;
    V_EF.EFFILENAME     := SUBSTR(V_ENTRUSTFILE.EFFILENAME, 1, 4) || 'R' ||
                           SUBSTR(V_ENTRUSTFILE.EFFILENAME, 5);
    V_EF.EFELBATCH      := V_ENTRUSTFILE.EFELBATCH;
    V_EF.EFFILEDATA     := V_ENTRUSTFILE.EFFILEDATA;
    V_EF.EFSOURCE       := '自来水公司系统自动生成';
    V_EF.EFFILEDATA     := C2B(V_CLOB);
    V_EF.EFNEWDATETIME  := SYSDATE;
    V_EF.EFSYNDATETIME  := NULL;
    V_EF.EFFLAG         := '0';
    V_EF.EFREADDATETIME := NULL;
    V_EF.EFMEMO         := '自来水公司系统自动生成';
    V_EF.EFEDITDATETIME := NULL;
    INSERT INTO ENTRUSTFILE VALUES V_EF;
    --处理文档标志位（0：生成；1：同步；2：回传；3：回传已处理）
    UPDATE ENTRUSTFILE SET EFFLAG = '3' WHERE EFID = V_ENTRUSTFILE.EFID;
    COMMIT;
  END LOOP;
  IF C_ENTRUSTFILE%ISOPEN THEN
    CLOSE C_ENTRUSTFILE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF C_ENTRUSTFILE%ISOPEN THEN
      CLOSE C_ENTRUSTFILE;
    END IF;
    IF C_QYMX%ISOPEN THEN
      CLOSE C_QYMX;
    END IF;
    RAISE;
END;
/

