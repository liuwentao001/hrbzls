CREATE OR REPLACE TRIGGER HRBZLS."TUB_SYSMANAPARA" BEFORE UPDATE
OF SMPID,
 SMPPID
ON SYSMANAPARA FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
 SEQ NUMBER;
 -- DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "SYSMANAFRAME"
 CURSOR CPK1_SYSMANAPARA(VAR_SMPID VARCHAR) IS
 SELECT 1
 FROM SYSMANAFRAME
 WHERE SMFID = VAR_SMPID
 AND VAR_SMPID IS NOT NULL;

BEGIN
   if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 SEQ := INTEGRITYPACKAGE.GETNESTLEVEL;
 -- PARENT "SYSMANAFRAME" MUST EXIST WHEN UPDATING A CHILD IN "SYSMANAPARA"
 IF (:NEW.SMPID IS NOT NULL) AND (SEQ = 0) THEN
 OPEN CPK1_SYSMANAPARA(:NEW.SMPID);
 FETCH CPK1_SYSMANAPARA INTO DUMMY;
 FOUND := CPK1_SYSMANAPARA%FOUND;
 CLOSE CPK1_SYSMANAPARA;
 IF NOT FOUND THEN
 ERRNO := -20003;
 ERRMSG := 'PARENT DOES NOT EXIST IN "SYSMANAFRAME". CANNOT UPDATE CHILD IN "SYSMANAPARA".';
 RAISE INTEGRITY_ERROR;
 END IF;
 END IF;


-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

