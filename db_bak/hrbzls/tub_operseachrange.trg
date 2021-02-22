CREATE OR REPLACE TRIGGER HRBZLS."TUB_OPERSEACHRANGE" BEFORE UPDATE
OF OSROAID,
 OSRID
ON OPERSEACHRANGE FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
 SEQ NUMBER;
 -- DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "OPERACCNT"
 CURSOR CPK1_OPERSEACHRANGE(VAR_OSROAID VARCHAR) IS
 SELECT 1
 FROM OPERACCNT
 WHERE OAID = VAR_OSROAID
 AND VAR_OSROAID IS NOT NULL;

BEGIN
   if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 SEQ := INTEGRITYPACKAGE.GETNESTLEVEL;
 -- PARENT "OPERACCNT" MUST EXIST WHEN UPDATING A CHILD IN "OPERSEACHRANGE"
 IF (:NEW.OSROAID IS NOT NULL) AND (SEQ = 0) THEN
 OPEN CPK1_OPERSEACHRANGE(:NEW.OSROAID);
 FETCH CPK1_OPERSEACHRANGE INTO DUMMY;
 FOUND := CPK1_OPERSEACHRANGE%FOUND;
 CLOSE CPK1_OPERSEACHRANGE;
 IF NOT FOUND THEN
 ERRNO := -20003;
 ERRMSG := 'PARENT DOES NOT EXIST IN "OPERACCNT". CANNOT UPDATE CHILD IN "OPERSEACHRANGE".';
 RAISE INTEGRITY_ERROR;
 END IF;
 END IF;


-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/
