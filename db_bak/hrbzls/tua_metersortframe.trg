CREATE OR REPLACE TRIGGER HRBZLS."TUA_METERSORTFRAME" AFTER UPDATE
OF MSFID
ON METERSORTFRAME FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 INTEGRITYPACKAGE.NEXTNESTLEVEL;
 -- MODIFY PARENT CODE OF "METERSORTFRAME" FOR ALL CHILDREN IN "METERCHKPLANPARA"
 IF (UPDATING('MSFID') AND :OLD.MSFID != :NEW.MSFID) THEN
 UPDATE METERCHKPLANPARA
 SET MCPPSORT = :NEW.MSFID
 WHERE MCPPSORT = :OLD.MSFID;
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

