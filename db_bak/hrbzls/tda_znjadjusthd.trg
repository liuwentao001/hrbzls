CREATE OR REPLACE TRIGGER HRBZLS."TDA_ZNJADJUSTHD" AFTER DELETE
ON ZNJADJUSTHD FOR EACH ROW
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
    --  DELETE ALL CHILDREN IN "ZNJADJUSTDT"
    DELETE ZNJADJUSTDT
    WHERE  ZADNO = :OLD.ZAHNO;

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

