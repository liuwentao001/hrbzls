CREATE OR REPLACE TRIGGER HRBZLS."TUB_PRICEADJUSTMETHOD" BEFORE UPDATE
OF PAMID
ON PRICEADJUSTMETHOD FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
 -- DECLARATION OF UPDATEPARENTRESTRICT CONSTRAINT FOR "PRICEADJUSTLIST"
 CURSOR CFK1_PRICEADJUSTLIST(VAR_PAMID VARCHAR) IS
 SELECT 1
 FROM PRICEADJUSTLIST
 WHERE PALMETHOD = VAR_PAMID
 AND VAR_PAMID IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 -- CANNOT MODIFY PARENT CODE IN "PRICEADJUSTMETHOD" IF CHILDREN STILL EXIST IN "PRICEADJUSTLIST"
 IF (UPDATING('PAMID') AND :OLD.PAMID != :NEW.PAMID) THEN
 OPEN CFK1_PRICEADJUSTLIST(:OLD.PAMID);
 FETCH CFK1_PRICEADJUSTLIST INTO DUMMY;
 FOUND := CFK1_PRICEADJUSTLIST%FOUND;
 CLOSE CFK1_PRICEADJUSTLIST;
 IF FOUND THEN
 ERRNO := -20005;
 ERRMSG := 'CHILDREN STILL EXIST IN "PRICEADJUSTLIST". CANNOT MODIFY PARENT CODE IN "PRICEADJUSTMETHOD".';
 RAISE INTEGRITY_ERROR;
 END IF;
 END IF;


-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/
