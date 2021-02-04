CREATE OR REPLACE TRIGGER HRBZLS."TUB_OPERRFMETHOD" BEFORE UPDATE
OF ORFMRID,
 ORFMFID,
 ORFMETHOD
ON OPERRFMETHOD FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
 SEQ NUMBER;
 -- DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "ERPFUNCMETHOD"
 CURSOR CPK1_OPERRFMETHOD(VAR_ORFMFID VARCHAR,
 VAR_ORFMETHOD CHAR) IS
 SELECT 1
 FROM ERPFUNCMETHOD
 WHERE EFMFID = VAR_ORFMFID
 AND EFMMID = VAR_ORFMETHOD
 AND VAR_ORFMFID IS NOT NULL
 AND VAR_ORFMETHOD IS NOT NULL;
 -- DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "OPERROLE"
 CURSOR CPK2_OPERRFMETHOD(VAR_ORFMRID VARCHAR) IS
 SELECT 1
 FROM OPERROLE
 WHERE ORID = VAR_ORFMRID
 AND VAR_ORFMRID IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 SEQ := INTEGRITYPACKAGE.GETNESTLEVEL;
 -- PARENT "ERPFUNCMETHOD" MUST EXIST WHEN UPDATING A CHILD IN "OPERRFMETHOD"
 IF (:NEW.ORFMFID IS NOT NULL) AND
 (:NEW.ORFMETHOD IS NOT NULL) AND (SEQ = 0) THEN
 OPEN CPK1_OPERRFMETHOD(:NEW.ORFMFID,
 :NEW.ORFMETHOD);
 FETCH CPK1_OPERRFMETHOD INTO DUMMY;
 FOUND := CPK1_OPERRFMETHOD%FOUND;
 close CPK1_OPERRFMETHOD;
 if not found then
 errno := -20003;
 errmsg := 'PARENT DOES NOT EXIST IN "ERPFUNCMETHOD". CANNOT UPDATE CHILD IN "OPERRFMETHOD".';
 raise integrity_error;
 end if;
 end if;

 -- Parent "OPERROLE" must exist when updating a child in "OPERRFMETHOD"
 if (:new.ORFMRID is not null) and (seq = 0) then
 open CPK2_OPERRFMETHOD(:new.ORFMRID);
 fetch CPK2_OPERRFMETHOD into dummy;
 found := CPK2_OPERRFMETHOD%FOUND;
 CLOSE CPK2_OPERRFMETHOD;
 IF NOT FOUND THEN
 ERRNO := -20003;
 ERRMSG := 'PARENT DOES NOT EXIST IN "OPERROLE". CANNOT UPDATE CHILD IN "OPERRFMETHOD".';
 RAISE INTEGRITY_ERROR;
 END IF;
 END IF;


-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

