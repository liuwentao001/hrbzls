CREATE OR REPLACE TRIGGER HRBZLS."TUA_MACHINELIST" AFTER UPDATE
OF MLMACHINETYPE,
 MLMACHINEID
ON MACHINELIST FOR EACH ROW
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
 -- MODIFY PARENT CODE OF "MACHINELIST" FOR ALL CHILDREN IN "MACHINEIOLOG"
 IF (UPDATING('MLMACHINETYPE') AND :OLD.MLMACHINETYPE != :NEW.MLMACHINETYPE) OR
 (UPDATING('MLMACHINEID') AND :OLD.MLMACHINEID != :NEW.MLMACHINEID) THEN
 UPDATE MACHINEIOLOG
 SET MILMACHINETYPE = :NEW.MLMACHINETYPE,
 MILMACHINEID = :NEW.MLMACHINEID
 WHERE MILMACHINETYPE = :OLD.MLMACHINETYPE
 AND MILMACHINEID = :OLD.MLMACHINEID;
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
