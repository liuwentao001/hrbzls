CREATE OR REPLACE TRIGGER HRBZLS."TUA_PAYMENT" AFTER UPDATE
   OF PREVERSEFLAG ON PAYMENT FOR EACH ROW
DECLARE
  INTEGRITY_ERROR EXCEPTION;
  ERRNO  INTEGER;
  ERRMSG CHAR(200);
  DUMMY  INTEGER;
  FOUND  BOOLEAN;

BEGIN
  IF NVL(FSYSPARA('data'), 'N') = 'Y' THEN
    RETURN;
  END IF;
  INTEGRITYPACKAGE.NEXTNESTLEVEL;
  IF (UPDATING('PREVERSEFLAG') AND :OLD.PREVERSEFLAG != :NEW.PREVERSEFLAG) THEN

    UPDATE INV_INFO
       SET REVERSEFLAG = :NEW.PREVERSEFLAG,
           CZPER       = :NEW.PPAYEE,
           CZDATE      = :NEW.PDATE,
           STATUS      = DECODE(:NEW.PREVERSEFLAG, 'Y', 1, STATUS),
           STATUSMEMO  = DECODE(:NEW.PREVERSEFLAG,
                                'Y',
                                '实收作废',
                                '正常打票')
     WHERE BATCH = :OLD.PBATCH
       AND STATUS = '0';

  END IF;
  INTEGRITYPACKAGE.PREVIOUSNESTLEVEL;

  -- ERRORS HANDLING
EXCEPTION
  WHEN INTEGRITY_ERROR THEN
    BEGIN
      INTEGRITYPACKAGE.INITNESTLEVEL;
      RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
    END;
END;
/

