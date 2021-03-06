CREATE OR REPLACE TRIGGER HRBZLS."TUB_BILLDEFINE" BEFORE UPDATE
OF BDBILLID,
 BDCOLNAME
ON BILLDEFINE FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
 SEQ NUMBER;
 -- DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "BILLMAIN"
 CURSOR CPK1_BILLDEFINE(VAR_BDBILLID VARCHAR) IS
 SELECT 1
 FROM BILLMAIN
 WHERE BMID = VAR_BDBILLID
 AND VAR_BDBILLID IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 SEQ := INTEGRITYPACKAGE.GETNESTLEVEL;
 -- PARENT "BILLMAIN" MUST EXIST WHEN UPDATING A CHILD IN "BILLDEFINE"
 IF (:NEW.BDBILLID IS NOT NULL) AND (SEQ = 0) THEN
 OPEN CPK1_BILLDEFINE(:NEW.BDBILLID);
 FETCH CPK1_BILLDEFINE INTO DUMMY;
 FOUND := CPK1_BILLDEFINE%FOUND;
 CLOSE CPK1_BILLDEFINE;
 IF NOT FOUND THEN
 ERRNO := -20003;
 ERRMSG := 'PARENT DOES NOT EXIST IN "BILLMAIN". CANNOT UPDATE CHILD IN "BILLDEFINE".';
 RAISE INTEGRITY_ERROR;
 END IF;
 END IF;


-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

