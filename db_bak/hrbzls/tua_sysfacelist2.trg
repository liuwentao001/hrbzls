CREATE OR REPLACE TRIGGER HRBZLS."TUA_SYSFACELIST2" AFTER UPDATE
OF SFLID
ON SYSFACELIST2 FOR EACH ROW
DECLARE
    INTEGRITY_ERROR  EXCEPTION;
    ERRNO            INTEGER;
    ERRMSG           CHAR(200);
    DUMMY            INTEGER;
    FOUND            BOOLEAN;
BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
    INTEGRITYPACKAGE.NEXTNESTLEVEL;
    --  MODIFY PARENT CODE OF "SYSFACELIST2" FOR ALL CHILDREN IN "SYSFACEJOIN1"
    IF (UPDATING('SFLID') AND :OLD.SFLID != :NEW.SFLID) THEN
       UPDATE SYSFACEJOIN1
        SET   AFJPID = :NEW.SFLID
       WHERE  AFJPID = :OLD.SFLID;
    END IF;

    --  MODIFY PARENT CODE OF "SYSFACELIST2" FOR ALL CHILDREN IN "SYSFACEJOIN2"
    IF (UPDATING('SFLID') AND :OLD.SFLID != :NEW.SFLID) THEN
       UPDATE SYSFACEJOIN2
        SET   AFJPID = :NEW.SFLID
       WHERE  AFJPID = :OLD.SFLID;
    END IF;

    --  MODIFY PARENT CODE OF "SYSFACELIST2" FOR ALL CHILDREN IN "SYSFACEJOIN3"
    IF (UPDATING('SFLID') AND :OLD.SFLID != :NEW.SFLID) THEN
       UPDATE SYSFACEJOIN3
        SET   AFJPID = :NEW.SFLID
       WHERE  AFJPID = :OLD.SFLID;
    END IF;

    INTEGRITYPACKAGE.PREVIOUSNESTLEVEL;

--  ERRORS HANDLING
EXCEPTION
    WHEN INTEGRITY_ERROR THEN
       BEGIN
       INTEGRITYPACKAGE.INITNESTLEVEL;
       RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
       END;
END;
/

