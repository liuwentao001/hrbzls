CREATE OR REPLACE TRIGGER HRBZLS."TIB_METERCHKPLANDT" BEFORE INSERT
ON METERCHKPLANDT FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
 -- DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "METERCHKPLANHD"
 CURSOR CPK1_METERCHKPLANDT(VAR_MCPDNO VARCHAR) IS
 SELECT 1
 FROM METERCHKPLANHD
 WHERE MCPHNO = VAR_MCPDNO
 AND VAR_MCPDNO IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 -- PARENT "METERCHKPLANHD" MUST EXIST WHEN INSERTING A CHILD IN "METERCHKPLANDT"
 IF :NEW.MCPDNO IS NOT NULL THEN
 OPEN CPK1_METERCHKPLANDT(:NEW.MCPDNO);
 FETCH CPK1_METERCHKPLANDT INTO DUMMY;
 FOUND := CPK1_METERCHKPLANDT%FOUND;
 CLOSE CPK1_METERCHKPLANDT;
 IF NOT FOUND THEN
 ERRNO := -20002;
 ERRMSG := 'PARENT DOES NOT EXIST IN "METERCHKPLANHD". CANNOT CREATE CHILD IN "METERCHKPLANDT".';
 RAISE INTEGRITY_ERROR;
 END IF;
 END IF;


-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

