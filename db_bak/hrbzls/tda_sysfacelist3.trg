CREATE OR REPLACE TRIGGER HRBZLS."TDA_SYSFACELIST3" AFTER DELETE
ON SYSFACELIST3 FOR EACH ROW
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
    --  DELETE ALL CHILDREN IN "SYSFACEJOIN2"
    DELETE SYSFACEJOIN2
    WHERE  AFJCID = :OLD.SFLID;

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

