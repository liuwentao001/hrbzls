CREATE OR REPLACE TRIGGER HRBZLS."TUB_METERDOC_LOG" BEFORE UPDATE
    ON "METERDOC"
    FOR EACH ROW
DECLARE
  L_IP          VARCHAR2(20);
  L_USER        VARCHAR2(20);
  LOGIN_NAME    VARCHAR(40);
  V_ID          VARCHAR(20);
  V_BS_MODI_LOG BS_MODI_LOG%ROWTYPE;
  V_CUSTINFO    CUSTINFO%ROWTYPE;
  V_METERINFO   METERINFO%ROWTYPE;
    v_count   number:=0;
BEGIN
  IF NVL(FSYSPARA('DATA'), 'N') = 'Y' THEN
    RETURN;
  END IF;
  --获取操作员客户端IP
   SELECT SYS_CONTEXT('USERENV', 'sid'),
         SYS_CONTEXT('USERENV', 'SESSION_USER')
    INTO L_IP, L_USER
    FROM DUAL;
  --获取操作员ID
  BEGIN
    SELECT LOGIN_USER INTO LOGIN_NAME FROM SYS_HOST WHERE IP = L_IP;
  EXCEPTION
    WHEN OTHERS THEN
      LOGIN_NAME := 'SYSTEM';
  END;
  SELECT * INTO V_METERINFO FROM METERINFO MI WHERE MI.MIID = :NEW.MDMID;
  SELECT *
    INTO V_CUSTINFO
    FROM CUSTINFO CI
   WHERE CI.CIID = V_METERINFO.MICID;

  ---初始化变更日志内容
  --SELECT  FGETSEQUENCE('BS_MODI_LOG') INTO V_BS_MODI_LOG.ID  FROM DUAL;
  V_BS_MODI_LOG.TPDATE    := SYSDATE;
  V_BS_MODI_LOG.OPERATOR  := LOGIN_NAME;
  V_BS_MODI_LOG.CUSTID    := :NEW.MDMID;
  V_BS_MODI_LOG.METERNO   := V_METERINFO.MICODE;
  V_BS_MODI_LOG.CUST_NAME := V_CUSTINFO.CINAME;
  ---表身码
  IF :OLD.MDNO <> :NEW.MDNO OR
     (:OLD.MDNO IS NULL AND :NEW.MDNO IS NOT NULL) OR
     (:OLD.MDNO IS NOT NULL AND :NEW.MDNO IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '资料变更.表身码';
    V_BS_MODI_LOG.VALUE_O   := :OLD.MDNO;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.MDNO;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '表身码';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'MDNO';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;
  ---表口径
  IF :OLD.MDCALIBER <> :NEW.MDCALIBER OR
     (:OLD.MDCALIBER IS NULL AND :NEW.MDCALIBER IS NOT NULL) OR
     (:OLD.MDCALIBER IS NOT NULL AND :NEW.MDCALIBER IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '资料变更.表口径';
    V_BS_MODI_LOG.VALUE_O   := :OLD.MDCALIBER;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.MDCALIBER;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '表口径';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'MDCALIBER';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;

  --- 表厂家
  IF :OLD.MDBRAND <> :NEW.MDBRAND OR
     (:OLD.MDBRAND IS NULL AND :NEW.MDBRAND IS NOT NULL) OR
     (:OLD.MDBRAND IS NOT NULL AND :NEW.MDBRAND IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '资料变更.表厂家 ';
    V_BS_MODI_LOG.VALUE_O   := FGETMETERBRAND(:OLD.MDBRAND);
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := FGETMETERBRAND(:NEW.MDBRAND);
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '表厂家';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'MDBRAND';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;
  --- 表型号
  IF :OLD.MDMODEL <> :NEW.MDMODEL OR
     (:OLD.MDMODEL IS NULL AND :NEW.MDMODEL IS NOT NULL) OR
     (:OLD.MDMODEL IS NOT NULL AND :NEW.MDMODEL IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '资料变更.表型号';
    V_BS_MODI_LOG.VALUE_O   := FGETMETERMODEL(:OLD.MDMODEL);
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := FGETMETERMODEL(:NEW.MDMODEL);
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '表型号';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := '表型号';
    V_BS_MODI_LOG.MICOLUMN  := 'MDMODEL';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;
  ---  库存位置
  IF :OLD.MDSTORE <> :NEW.MDSTORE OR
     (:OLD.MDSTORE IS NULL AND :NEW.MDSTORE IS NOT NULL) OR
     (:OLD.MDSTORE IS NOT NULL AND :NEW.MDSTORE IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '资料变更.库存位置 ';
    V_BS_MODI_LOG.VALUE_O   := :OLD.MDSTORE;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.MDSTORE;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '库存位置';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := '库存位置';
    V_BS_MODI_LOG.MICOLUMN  := 'MDSTORE';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;
  --- 首封号
  IF :OLD.SFH <> :NEW.SFH OR
     (:OLD.SFH IS NULL AND :NEW.SFH IS NOT NULL) OR
     (:OLD.SFH IS NOT NULL AND :NEW.SFH IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '资料变更.首封号 ';
    V_BS_MODI_LOG.VALUE_O   := :OLD.SFH;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.SFH;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '首封号';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := '首封号';
    V_BS_MODI_LOG.MICOLUMN  := 'SFH';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;
  --- 地区塑封号
  IF :OLD.DQSFH <> :NEW.DQSFH OR
     (:OLD.DQSFH IS NULL AND :NEW.DQSFH IS NOT NULL) OR
     (:OLD.DQSFH IS NOT NULL AND :NEW.DQSFH IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '资料变更.地区塑封号 ';
    V_BS_MODI_LOG.VALUE_O   := :OLD.DQSFH;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.DQSFH;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '地区塑封号';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := '地区塑封号';
    V_BS_MODI_LOG.MICOLUMN  := 'DQSFH';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;

  --- 地区钢封号
  IF :OLD.DQGFH <> :NEW.DQGFH OR
     (:OLD.DQGFH IS NULL AND :NEW.DQGFH IS NOT NULL) OR
     (:OLD.DQGFH IS NOT NULL AND :NEW.DQGFH IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '资料变更.地区钢封号 ';
    V_BS_MODI_LOG.VALUE_O   := :OLD.DQGFH;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.DQGFH;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '地区钢封号';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := '地区钢封号';
    V_BS_MODI_LOG.MICOLUMN  := 'DQGFH';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;
  --- 稽查刚封号
  IF :OLD.JCGFH <> :NEW.JCGFH OR
     (:OLD.JCGFH IS NULL AND :NEW.JCGFH IS NOT NULL) OR
     (:OLD.JCGFH IS NOT NULL AND :NEW.JCGFH IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '资料变更.稽查刚封号 ';
    V_BS_MODI_LOG.VALUE_O   := :OLD.JCGFH;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.JCGFH;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '稽查刚封号';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := '稽查刚封号';
    V_BS_MODI_LOG.MICOLUMN  := 'JCGFH';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;
  --- 铅封号
  IF :OLD.QFH <> :NEW.QFH OR
     (:OLD.QFH IS NULL AND :NEW.QFH IS NOT NULL) OR
     (:OLD.QFH IS NOT NULL AND :NEW.QFH IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '资料变更.铅封号 ';
    V_BS_MODI_LOG.VALUE_O   := :OLD.QFH;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.QFH;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '铅封号';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := '铅封号';
    V_BS_MODI_LOG.MICOLUMN  := 'QFH';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;
  --- 铅封钳号
  IF :OLD.QFQH <> :NEW.QFQH OR
     (:OLD.QFQH IS NULL AND :NEW.QFQH IS NOT NULL) OR
     (:OLD.QFQH IS NOT NULL AND :NEW.QFQH IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '资料变更.铅封钳号 ';
    V_BS_MODI_LOG.VALUE_O   := :OLD.QFQH;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.QFQH;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '铅封钳号';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := '铅封钳号';
    V_BS_MODI_LOG.MICOLUMN  := 'QFQH';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;
  --- 塑封钳号
  IF :OLD.DQSFQH <> :NEW.DQSFQH OR
     (:OLD.DQSFQH IS NULL AND :NEW.DQSFQH IS NOT NULL) OR
     (:OLD.DQSFQH IS NOT NULL AND :NEW.DQSFQH IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '资料变更.塑封钳号 ';
    V_BS_MODI_LOG.VALUE_O   := :OLD.DQSFQH;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.DQSFQH;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '塑封钳号';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := '塑封钳号';
    V_BS_MODI_LOG.MICOLUMN  := 'DQSFQH';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;
  --- 锁封号
  IF :OLD.LFH <> :NEW.LFH OR
     (:OLD.LFH IS NULL AND :NEW.LFH IS NOT NULL) OR
     (:OLD.LFH IS NOT NULL AND :NEW.LFH IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '资料变更.锁封号 ';
    V_BS_MODI_LOG.VALUE_O   := :OLD.LFH;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.LFH;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '锁封号';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := '锁封号';
    V_BS_MODI_LOG.MICOLUMN  := 'LFH';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;

  --- 锁封钳号
  IF :OLD.LFQH <> :NEW.LFQH OR
     (:OLD.LFQH IS NULL AND :NEW.LFQH IS NOT NULL) OR
     (:OLD.LFQH IS NOT NULL AND :NEW.LFQH IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '资料变更.锁封钳号 ';
    V_BS_MODI_LOG.VALUE_O   := :OLD.LFQH;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.LFQH;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '锁封钳号';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := '锁封钳号';
    V_BS_MODI_LOG.MICOLUMN  := 'LFQH';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;
  --- 稽查封钳号
  IF :OLD.JCGFQH <> :NEW.JCGFQH OR
     (:OLD.JCGFQH IS NULL AND :NEW.JCGFQH IS NOT NULL) OR
     (:OLD.JCGFQH IS NOT NULL AND :NEW.JCGFQH IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '资料变更.稽查封钳号 ';
    V_BS_MODI_LOG.VALUE_O   := :OLD.JCGFQH;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.JCGFQH;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '稽查封钳号';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := '稽查封钳号';
    V_BS_MODI_LOG.MICOLUMN  := 'JCGFQH';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;

   --- 条形码（迁移水账标识号CLT_NO）
  IF :OLD.BARCODE  <> :NEW.BARCODE  OR
     (:OLD.BARCODE IS NULL AND :NEW.BARCODE IS NOT NULL) OR
     (:OLD.BARCODE IS NOT NULL AND :NEW.BARCODE IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '资料变更.条形码 ';
    V_BS_MODI_LOG.VALUE_O   := :OLD.BARCODE;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.BARCODE;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '条形码';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := '条形码';
    V_BS_MODI_LOG.MICOLUMN  := 'BARCODE';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;

  --- 电子标签
  IF :OLD.RFID   <> :NEW.RFID  OR
     (:OLD.RFID IS NULL AND :NEW.RFID IS NOT NULL) OR
     (:OLD.RFID IS NOT NULL AND :NEW.RFID IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '资料变更.电子标签 ';
    V_BS_MODI_LOG.VALUE_O   := :OLD.RFID;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.RFID;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '电子标签';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := '电子标签';
    V_BS_MODI_LOG.MICOLUMN  := 'RFID';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;

   --- 是否倒表
  IF :OLD.IFDZSB   <> :NEW.IFDZSB  OR
     (:OLD.IFDZSB IS NULL AND :NEW.IFDZSB IS NOT NULL) OR
     (:OLD.IFDZSB IS NOT NULL AND :NEW.IFDZSB IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '资料变更.是否倒表 ';
    V_BS_MODI_LOG.VALUE_O   := :OLD.IFDZSB;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.IFDZSB;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '是否倒表';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := '是否倒表';
    V_BS_MODI_LOG.MICOLUMN  := 'IFDZSB';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;

  IF UPDATING THEN
     if NVL(:new.MDNO,'NULL') <> NVL(:old.MDNO,'NULL') or NVL(:new.MDCALIBER,0) <> NVL(:old.MDCALIBER,0)  or NVL(:new.MDBRAND,'NULL') <> NVL( :old.MDBRAND ,'NULL')  
     or NVL(:new.MDMODEL,'NULL') <> NVL(:old.MDMODEL,'NULL') or NVL(:new.SFH,'NULL') <> NVL(:old.SFH,'NULL')  or NVL(:new.DQSFH,'NULL') <> NVL(:old.DQSFH ,'NULL') 
     or NVL(:new.DQGFH,'NULL') <> NVL(:old.DQGFH,'NULL')       or NVL(:new.JCGFH,'NULL') <> NVL(:old.JCGFH,'NULL')      
     or NVL(:new.QFH,'NULL') <> NVL(:old.QFH,'NULL')   or NVL(:new.QFQH,'NULL') <> NVL(:old.QFQH ,'NULL') 
     or NVL(:new.DQSFQH,'NULL') <> NVL(:old.DQSFQH,'NULL')  or NVL(:new.LFH,'NULL') <> NVL(:old.LFH,'NULL')  
     or NVL(:new.LFQH,'NULL')  <> NVL(:old.LFQH,'NULL')  or NVL(:new.JCGFQH ,'NULL')<> NVL(:old.JCGFQH ,'NULL') 
     or NVL(:new.BARCODE,'NULL')  <> NVL(:old.BARCODE,'NULL')  or NVL(:new.RFID,'NULL') <> NVL(:old.RFID,'NULL') 
     or NVL(:new.ifdzsb,'NULL')  <> NVL(:old.ifdzsb,'NULL')     THEN  --抄表注记有变更

             begin 
             select count(*)
             into v_count
             from meterinfo_sjcbup  where miid =:new.MDMID AND UPDATE_MK='2' ;
             if v_count is null then
                 v_count:=0;
             end if ;
             exception when others then
                v_count:=0;
             end ;
             if v_count = 0 then
                insert into meterinfo_sjcbup(MIID,CIID,UPDATE_MK) values(:NEW.MDMID,:NEW.MDMID,'2');--更新
             end if ; 
     END IF ;
  end if ;
END;
/

