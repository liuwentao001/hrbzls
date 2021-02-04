CREATE OR REPLACE TRIGGER HRBZLS."TUA_INV_INFO_SP"
  AFTER UPDATE ON INV_INFO_SP
  FOR EACH ROW
BEGIN
  IF :NEW.STATUS = '1' THEN
    UPDATE INVSTOCK_SP T
       SET ISPSTATUS      = ISSTATUS,
           ISPSTATUSDATEP = ISSTATUSDATE,
           ISPTATUSPER    = ISSTATUSPER,
           T.ISSTATUS     = '2',
           ISSTATUSDATE   = SYSDATE,
           ISSTATUSPER    = FGETPBOPER,
           ISSTATUSMEMO   = :NEW.STATUSMEMO
     WHERE TO_CHAR(T.ISID) = :NEW.ISID;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
/

