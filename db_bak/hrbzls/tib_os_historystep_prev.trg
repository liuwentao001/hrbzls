CREATE OR REPLACE TRIGGER HRBZLS."TIB_OS_HISTORYSTEP_PREV" BEFORE INSERT
ON OS_HISTORYSTEP_PREV FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
 -- DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "OS_HISTORYSTEP"
 CURSOR CPK1_OS_HISTORYSTEP_PREV(VAR_ID NUMBER) IS
 SELECT 1
 FROM OS_HISTORYSTEP
 WHERE ID = VAR_ID
 AND VAR_ID IS NOT NULL;
 -- DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "OS_HISTORYSTEP"
 CURSOR CPK2_OS_HISTORYSTEP_PREV(VAR_PREVIOUS_ID NUMBER) IS
 SELECT 1
 FROM OS_HISTORYSTEP
 WHERE ID = VAR_PREVIOUS_ID
 AND VAR_PREVIOUS_ID IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 -- PARENT "OS_HISTORYSTEP" MUST EXIST WHEN INSERTING A CHILD IN "OS_HISTORYSTEP_PREV"
 IF :NEW.ID IS NOT NULL THEN
 OPEN CPK1_OS_HISTORYSTEP_PREV(:NEW.ID);
 FETCH CPK1_OS_HISTORYSTEP_PREV INTO DUMMY;
 FOUND := CPK1_OS_HISTORYSTEP_PREV%FOUND;
 close CPK1_OS_HISTORYSTEP_PREV;
 if not found then
 errno := -20002;
 errmsg := 'PARENT DOES NOT EXIST IN "OS_HISTORYSTEP". CANNOT CREATE CHILD IN "OS_HISTORYSTEP_PREV".';
 raise integrity_error;
 end if;
 end if;

 -- Parent "OS_HISTORYSTEP" must exist when inserting a child in "OS_HISTORYSTEP_PREV"
 if :new.PREVIOUS_ID is not null then
 open CPK2_OS_HISTORYSTEP_PREV(:new.PREVIOUS_ID);
 fetch CPK2_OS_HISTORYSTEP_PREV into dummy;
 found := CPK2_OS_HISTORYSTEP_PREV%FOUND;
 CLOSE CPK2_OS_HISTORYSTEP_PREV;
 IF NOT FOUND THEN
 ERRNO := -20002;
 ERRMSG := 'PARENT DOES NOT EXIST IN "OS_HISTORYSTEP". CANNOT CREATE CHILD IN "OS_HISTORYSTEP_PREV".';
 RAISE INTEGRITY_ERROR;
 END IF;
 END IF;


-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

