CREATE OR REPLACE TRIGGER HRBZLS."TDB_PRICEMETHOD" BEFORE DELETE
ON PRICEMETHOD FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
 -- DECLARATION OF DELETEPARENTRESTRICT CONSTRAINT FOR "PRICEDETAIL"
 CURSOR CFK1_PRICEDETAIL(VAR_PMID VARCHAR) IS
 SELECT 1
 FROM PRICEDETAIL
 WHERE PDMETHOD = VAR_PMID
 AND VAR_PMID IS NOT NULL;
 -- DECLARATION OF DELETEPARENTRESTRICT CONSTRAINT FOR "RECDETAIL"
 CURSOR CFK2_RECDETAIL(VAR_PMID VARCHAR) IS
 SELECT 1
 FROM RECDETAIL
 WHERE RDMETHOD = VAR_PMID
 AND VAR_PMID IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 -- CANNOT DELETE PARENT "PRICEMETHOD" IF CHILDREN STILL EXIST IN "PRICEDETAIL"
 OPEN CFK1_PRICEDETAIL(:OLD.PMID);
 FETCH CFK1_PRICEDETAIL INTO DUMMY;
 FOUND := CFK1_PRICEDETAIL%FOUND;
 close CFK1_PRICEDETAIL;
 if found then
 errno := -20006;
 errmsg := 'CHILDREN STILL EXIST IN "PRICEDETAIL". CANNOT DELETE PARENT "PRICEMETHOD".';
 raise integrity_error;
 end if;

 -- Cannot delete parent "PRICEMETHOD" if children still exist in "RECDETAIL"
 open CFK2_RECDETAIL(:old.PMID);
 fetch CFK2_RECDETAIL into dummy;
 found := CFK2_RECDETAIL%FOUND;
 CLOSE CFK2_RECDETAIL;
 IF FOUND THEN
 ERRNO := -20006;
 ERRMSG := 'CHILDREN STILL EXIST IN "RECDETAIL". CANNOT DELETE PARENT "PRICEMETHOD".';
 RAISE INTEGRITY_ERROR;
 END IF;


-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

