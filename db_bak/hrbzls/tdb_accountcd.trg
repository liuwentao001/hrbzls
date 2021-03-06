CREATE OR REPLACE TRIGGER HRBZLS."TDB_ACCOUNTCD" BEFORE DELETE
ON ACCOUNTCD FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
 -- DECLARATION OF DELETEPARENTRESTRICT CONSTRAINT FOR "RECLIST"
 CURSOR CFK1_RECLIST(VAR_ACDID VARCHAR) IS
 SELECT 1
 FROM RECLIST
 WHERE RLCD = VAR_ACDID
 AND VAR_ACDID IS NOT NULL;
 -- DECLARATION OF DELETEPARENTRESTRICT CONSTRAINT FOR "INVOICELIST"
 CURSOR CFK2_INVOICELIST(VAR_ACDID VARCHAR) IS
 SELECT 1
 FROM INVOICELIST
 WHERE ILCD = VAR_ACDID
 AND VAR_ACDID IS NOT NULL;
 -- DECLARATION OF DELETEPARENTRESTRICT CONSTRAINT FOR "RECLIST"
 CURSOR CFK3_RECLIST(VAR_ACDID VARCHAR) IS
 SELECT 1
 FROM RECLIST
 WHERE RLCD = VAR_ACDID
 AND VAR_ACDID IS NOT NULL;
 -- DECLARATION OF DELETEPARENTRESTRICT CONSTRAINT FOR "PAYMENT"
 CURSOR CFK4_PAYMENT(VAR_ACDID VARCHAR) IS
 SELECT 1
 FROM PAYMENT
 WHERE PCD = VAR_ACDID
 AND VAR_ACDID IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 -- CANNOT DELETE PARENT "ACCOUNTCD" IF CHILDREN STILL EXIST IN "RECLIST"
 OPEN CFK1_RECLIST(:OLD.ACDID);
 FETCH CFK1_RECLIST INTO DUMMY;
 FOUND := CFK1_RECLIST%FOUND;
 close CFK1_RECLIST;
 if found then
 errno := -20006;
 errmsg := 'CHILDREN STILL EXIST IN "RECLIST". CANNOT DELETE PARENT "ACCOUNTCD".';
 raise integrity_error;
 end if;

 -- Cannot delete parent "ACCOUNTCD" if children still exist in "INVOICELIST"
 open CFK2_INVOICELIST(:old.ACDID);
 fetch CFK2_INVOICELIST into dummy;
 found := CFK2_INVOICELIST%FOUND;
 CLOSE CFK2_INVOICELIST;
 IF FOUND THEN
 ERRNO := -20006;
 ERRMSG := 'CHILDREN STILL EXIST IN "INVOICELIST". CANNOT DELETE PARENT "ACCOUNTCD".';
 RAISE INTEGRITY_ERROR;
 END IF;

 -- CANNOT DELETE PARENT "ACCOUNTCD" IF CHILDREN STILL EXIST IN "RECLIST"
 OPEN CFK3_RECLIST(:OLD.ACDID);
 FETCH CFK3_RECLIST INTO DUMMY;
 FOUND := CFK3_RECLIST%FOUND;
 close CFK3_RECLIST;
 if found then
 errno := -20006;
 errmsg := 'CHILDREN STILL EXIST IN "RECLIST". CANNOT DELETE PARENT "ACCOUNTCD".';
 raise integrity_error;
 end if;

 -- Cannot delete parent "ACCOUNTCD" if children still exist in "PAYMENT"
 open CFK4_PAYMENT(:old.ACDID);
 fetch CFK4_PAYMENT into dummy;
 found := CFK4_PAYMENT%FOUND;
 CLOSE CFK4_PAYMENT;
 IF FOUND THEN
 ERRNO := -20006;
 ERRMSG := 'CHILDREN STILL EXIST IN "PAYMENT". CANNOT DELETE PARENT "ACCOUNTCD".';
 RAISE INTEGRITY_ERROR;
 END IF;


-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

