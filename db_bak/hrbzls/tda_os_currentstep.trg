CREATE OR REPLACE TRIGGER HRBZLS."TDA_OS_CURRENTSTEP" AFTER DELETE
ON OS_CURRENTSTEP FOR EACH ROW
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
 -- DELETE ALL CHILDREN IN "OS_CURRENTINFO"
 DELETE OS_CURRENTINFO
 WHERE ID = :OLD.ID;

 -- DELETE ALL CHILDREN IN "OS_CURRENTOWNER"
 DELETE OS_CURRENTOWNER
 WHERE ID = :OLD.ID;

 -- DELETE ALL CHILDREN IN "OS_CURRENTSTEP_PREV"
 DELETE OS_CURRENTSTEP_PREV
 WHERE ID = :OLD.ID;

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

