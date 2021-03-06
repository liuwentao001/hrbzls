CREATE OR REPLACE TRIGGER HRBZLS."TUB_OS_CURRENTSTEP_PREV" BEFORE UPDATE
OF ID,
 PREVIOUS_ID
ON OS_CURRENTSTEP_PREV FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
 SEQ NUMBER;
 -- DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "OS_HISTORYSTEP"
 CURSOR CPK1_OS_CURRENTSTEP_PREV(VAR_PREVIOUS_ID NUMBER) IS
 SELECT 1
 FROM OS_HISTORYSTEP
 WHERE ID = VAR_PREVIOUS_ID
 AND VAR_PREVIOUS_ID IS NOT NULL;
 -- DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "OS_CURRENTSTEP"
 CURSOR CPK2_OS_CURRENTSTEP_PREV(VAR_ID NUMBER) IS
 SELECT 1
 FROM OS_CURRENTSTEP
 WHERE ID = VAR_ID
 AND VAR_ID IS NOT NULL;

BEGIN
   if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 SEQ := INTEGRITYPACKAGE.GETNESTLEVEL;
 -- PARENT "OS_HISTORYSTEP" MUST EXIST WHEN UPDATING A CHILD IN "OS_CURRENTSTEP_PREV"
 IF (:NEW.PREVIOUS_ID IS NOT NULL) AND (SEQ = 0) THEN
 OPEN CPK1_OS_CURRENTSTEP_PREV(:NEW.PREVIOUS_ID);
 FETCH CPK1_OS_CURRENTSTEP_PREV INTO DUMMY;
 FOUND := CPK1_OS_CURRENTSTEP_PREV%FOUND;
 close CPK1_OS_CURRENTSTEP_PREV;
 if not found then
 errno := -20003;
 errmsg := 'PARENT DOES NOT EXIST IN "OS_HISTORYSTEP". CANNOT UPDATE CHILD IN "OS_CURRENTSTEP_PREV".';
 raise integrity_error;
 end if;
 end if;

 -- Parent "OS_CURRENTSTEP" must exist when updating a child in "OS_CURRENTSTEP_PREV"
 if (:new.ID is not null) and (seq = 0) then
 open CPK2_OS_CURRENTSTEP_PREV(:new.ID);
 fetch CPK2_OS_CURRENTSTEP_PREV into dummy;
 found := CPK2_OS_CURRENTSTEP_PREV%FOUND;
 CLOSE CPK2_OS_CURRENTSTEP_PREV;
 IF NOT FOUND THEN
 ERRNO := -20003;
 ERRMSG := 'PARENT DOES NOT EXIST IN "OS_CURRENTSTEP". CANNOT UPDATE CHILD IN "OS_CURRENTSTEP_PREV".';
 RAISE INTEGRITY_ERROR;
 END IF;
 END IF;


-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

