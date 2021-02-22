CREATE OR REPLACE TRIGGER HRBZLS."TUB_METERACCOUNT_LOG"
  BEFORE UPDATE ON "METERACCOUNT"
  FOR EACH ROW
DECLARE
  L_IP          VARCHAR2(20);
  L_USER        VARCHAR2(20);
  LOGIN_NAME    VARCHAR(40);
--  V_ID          VARCHAR(20);
  V_BS_MODI_LOG BS_MODI_LOG%ROWTYPE;
  V_METERINFO   METERINFO%ROWTYPE;
BEGIN
  IF NVL(FSYSPARA('data'), 'N') = 'Y' THEN
    RETURN;
  END IF;
  --��ȡ����Ա�ͻ���ip
   SELECT SYS_CONTEXT('USERENV', 'sid'),
         SYS_CONTEXT('USERENV', 'SESSION_USER')
    INTO L_IP, L_USER
    FROM DUAL;
  --��ȡ����ԱID
  BEGIN
    SELECT LOGIN_USER INTO LOGIN_NAME FROM SYS_HOST WHERE IP = L_IP ;
  EXCEPTION
    WHEN OTHERS THEN
      LOGIN_NAME := 'system';
  END;
  SELECT * INTO V_METERINFO FROM METERINFO MI WHERE MI.MIID = :NEW.MAMID;
  ---��ʼ�������־����
  --select  fgetsequence('bs_modi_log') INTO v_bs_modi_log.id  from dual;
  V_BS_MODI_LOG.TPDATE    := SYSDATE;
  V_BS_MODI_LOG.OPERATOR  := LOGIN_NAME;
  V_BS_MODI_LOG.CUSTID    := :NEW.MAMID;
  V_BS_MODI_LOG.METERNO   := :NEW.MAMICODE;
  V_BS_MODI_LOG.CUST_NAME := V_METERINFO.MINAME;
  ---�����У����У�
  IF :OLD.MABANKID <> :NEW.MABANKID OR
     (:OLD.MABANKID IS NULL AND :NEW.MABANKID IS NOT NULL) OR
     (:OLD.MABANKID IS NOT NULL AND :NEW.MABANKID IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.������';
    V_BS_MODI_LOG.VALUE_O   := FGETSYSMANAFRAME(:OLD.MABANKID);
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := FGETSYSMANAFRAME(:NEW.MABANKID);
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '������';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'MABANKID';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;
  ---�����ʺţ����У�
  IF :OLD.MAACCOUNTNO <> :NEW.MAACCOUNTNO OR
     (:OLD.MAACCOUNTNO IS NULL AND :NEW.MAACCOUNTNO IS NOT NULL) OR
     (:OLD.MAACCOUNTNO IS NOT NULL AND :NEW.MAACCOUNTNO IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.�����ʺ�';
    V_BS_MODI_LOG.VALUE_O   := :OLD.MAACCOUNTNO;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.MAACCOUNTNO;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '�����ʺ�';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'MAACCOUNTNO';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;

  ---  �����������У�
  IF :OLD.MAACCOUNTNAME <> :NEW.MAACCOUNTNAME OR
     (:OLD.MAACCOUNTNAME IS NULL AND :NEW.MAACCOUNTNAME IS NOT NULL) OR
     (:OLD.MAACCOUNTNAME IS NOT NULL AND :NEW.MAACCOUNTNAME IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.������';
    V_BS_MODI_LOG.VALUE_O   := :OLD.MAACCOUNTNAME;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.MAACCOUNTNAME;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '������';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'MAACCOUNTNAME';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;
  ---  �����кţ��У�
  IF :OLD.MATSBANKID <> :NEW.MATSBANKID OR
     (:OLD.MATSBANKID IS NULL AND :NEW.MATSBANKID IS NOT NULL) OR
     (:OLD.MATSBANKID IS NOT NULL AND :NEW.MATSBANKID IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.�����к�';
    V_BS_MODI_LOG.VALUE_O   := FGETSYSMANAFRAME(:OLD.MATSBANKID);
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := FGETSYSMANAFRAME(:NEW.MATSBANKID);
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '�����к�';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'MATSBANKID';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;
  ---  ƾ֤���У��У�
  IF :OLD.MATSBANKNAME <> :NEW.MATSBANKNAME OR
     (:OLD.MATSBANKNAME IS NULL AND :NEW.MATSBANKNAME IS NOT NULL) OR
     (:OLD.MATSBANKNAME IS NOT NULL AND :NEW.MATSBANKNAME IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.ƾ֤���� ';
    V_BS_MODI_LOG.VALUE_O   := :OLD.MATSBANKNAME;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.MATSBANKNAME;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := 'ƾ֤����';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'MATSBANKNAME';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;
  ---  С��֧�����У�
  IF :OLD.MAIFXEZF <> :NEW.MAIFXEZF OR
     (:OLD.MAIFXEZF IS NULL AND :NEW.MAIFXEZF IS NOT NULL) OR
     (:OLD.MAIFXEZF IS NOT NULL AND :NEW.MAIFXEZF IS NULL) THEN
    IF :NEW.MAIFXEZF = 'Y' THEN
      V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.С��֧��';
    ELSE
      V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.ȡ��С��֧��';
    END IF;
    V_BS_MODI_LOG.VALUE_O   := :OLD.MAIFXEZF;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.MAIFXEZF;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := 'С��֧�� ';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'MAIFXEZF';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;
END;
/
