CREATE OR REPLACE TRIGGER HRBZLS."TUA_PAYMENT_LOG"
  AFTER  UPDATE ON "PAYMENT"
  FOR EACH ROW
DECLARE
  L_IP          VARCHAR2(40);
  L_USER        VARCHAR2(40);
  LOGIN_NAME    VARCHAR(40);
--  V_ID          VARCHAR(20);
  V_BS_MODI_LOG BS_MODI_LOG%ROWTYPE;
  V_CUSTINFO    CUSTINFO%ROWTYPE;
BEGIN
  IF NVL(FSYSPARA('data'), 'N') = 'Y' THEN
    RETURN;
  END IF;
  --获取操作员客户端ip
   SELECT SYS_CONTEXT('USERENV', 'sid'),
         SYS_CONTEXT('USERENV', 'SESSION_USER')
    INTO L_IP, L_USER
    FROM DUAL;
  --获取操作员ID
  BEGIN
    SELECT LOGIN_USER INTO LOGIN_NAME FROM SYS_HOST WHERE IP = L_IP ;
  EXCEPTION
    WHEN OTHERS THEN
      LOGIN_NAME := 'system';
  END;
  SELECT * INTO V_CUSTINFO FROM CUSTINFO CI WHERE CI.CIID = :NEW.PCID;
  ---初始化变更日志内容
  --  select fgetsequence('bs_modi_log') INTO v_bs_modi_log.id from dual;
  V_BS_MODI_LOG.TPDATE    := SYSDATE;
  V_BS_MODI_LOG.OPERATOR  := LOGIN_NAME;
  V_BS_MODI_LOG.CUSTID    := :NEW.PCID;
  V_BS_MODI_LOG.METERNO   := :NEW.PMID;
  V_BS_MODI_LOG.CUST_NAME := V_CUSTINFO.CINAME;

  ---【哈尔滨】实收冲正
  IF (:OLD.PREVERSEFLAG <> :NEW.PREVERSEFLAG) OR
     (:OLD.PREVERSEFLAG IS NULL AND :NEW.PREVERSEFLAG IS NOT NULL) OR
     (:OLD.PREVERSEFLAG IS NOT NULL AND :NEW.PREVERSEFLAG IS NULL) THEN
    IF :OLD.PTRANS = 'B' THEN
      V_BS_MODI_LOG.MODI_TYPE := '账务变更.实收冲正【银行】';
    ELSE
      V_BS_MODI_LOG.MODI_TYPE := '账务变更.实收冲正';
    END IF;
    V_BS_MODI_LOG.VALUE_O   := '付款金额：' || :OLD.PPAYMENT;
    V_BS_MODI_LOG.REMARK_O  := '实收流水：' || :OLD.PID;
    V_BS_MODI_LOG.VALUE_N   := '';
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '实收冲正';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'PREVERSEFLAG';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;

END;
/

