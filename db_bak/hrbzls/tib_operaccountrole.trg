CREATE OR REPLACE TRIGGER HRBZLS."TIB_OPERACCOUNTROLE" BEFORE INSERT
ON OPERACCNTROLE FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
 -- DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "OPERACCNT"
 CURSOR CPK1_OPERACCNTROLE(VAR_OAROAID VARCHAR) IS
 SELECT 1
 FROM OPERACCNT
 WHERE OAID = VAR_OAROAID
 AND VAR_OAROAID IS NOT NULL;
 -- DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "OPERROLE"
 CURSOR CPK2_OPERACCNTROLE(VAR_OARRID VARCHAR) IS
 SELECT 1
 FROM OPERROLE
 WHERE ORID = VAR_OARRID
 AND VAR_OARRID IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 -- PARENT "OPERACCNT" MUST EXIST WHEN INSERTING A CHILD IN "OPERACCNTROLE"
 IF :NEW.OAROAID IS NOT NULL THEN
 OPEN CPK1_OPERACCNTROLE(:NEW.OAROAID);
 FETCH CPK1_OPERACCNTROLE INTO DUMMY;
 FOUND := CPK1_OPERACCNTROLE%FOUND;
 close CPK1_OPERACCNTROLE;
 if not found then
 errno := -20002;
 errmsg := 'PARENT DOES NOT EXIST IN "OPERACCNT". CANNOT CREATE CHILD IN "OPERACCNTROLE".';
 raise integrity_error;
 end if;
 end if;

 -- Parent "OPERROLE" must exist when inserting a child in "OPERACCNTROLE"
 if :new.OARRID is not null then
 open CPK2_OPERACCNTROLE(:new.OARRID);
 fetch CPK2_OPERACCNTROLE into dummy;
 found := CPK2_OPERACCNTROLE%FOUND;
 CLOSE CPK2_OPERACCNTROLE;
 IF NOT FOUND THEN
 ERRNO := -20002;
 ERRMSG := 'PARENT DOES NOT EXIST IN "OPERROLE". CANNOT CREATE CHILD IN "OPERACCNTROLE".';
 RAISE INTEGRITY_ERROR;
 END IF;
 END IF;


-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

