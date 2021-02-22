CREATE OR REPLACE TRIGGER HRBZLS."TUB_ACCOUNTCD" BEFORE UPDATE
OF ACDID
ON ACCOUNTCD FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
 -- DECLARATION OF UPDATEPARENTRESTRICT CONSTRAINT FOR "RECLIST"
 CURSOR CFK1_RECLIST(VAR_ACDID VARCHAR) IS
 SELECT 1
 FROM RECLIST
 WHERE RLCD = VAR_ACDID
 AND VAR_ACDID IS NOT NULL;
 -- DECLARATION OF UPDATEPARENTRESTRICT CONSTRAINT FOR "INVOICELIST"
 CURSOR CFK2_INVOICELIST(VAR_ACDID VARCHAR) IS
 SELECT 1
 FROM INVOICELIST
 WHERE ILCD = VAR_ACDID
 AND VAR_ACDID IS NOT NULL;
 -- DECLARATION OF UPDATEPARENTRESTRICT CONSTRAINT FOR "RECLIST"
 CURSOR CFK3_RECLIST(VAR_ACDID VARCHAR) IS
 SELECT 1
 FROM RECLIST
 WHERE RLCD = VAR_ACDID
 AND VAR_ACDID IS NOT NULL;
 -- DECLARATION OF UPDATEPARENTRESTRICT CONSTRAINT FOR "PAYMENT"
 CURSOR CFK4_PAYMENT(VAR_ACDID VARCHAR) IS
 SELECT 1
 FROM PAYMENT
 WHERE PCD = VAR_ACDID
 AND VAR_ACDID IS NOT NULL;

BEGIN
   if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 -- CANNOT MODIFY PARENT CODE IN "ACCOUNTCD" IF CHILDREN STILL EXIST IN "RECLIST"
 IF (UPDATING('ACDID') AND :OLD.ACDID != :NEW.ACDID) THEN
 OPEN CFK1_RECLIST(:OLD.ACDID);
 FETCH CFK1_RECLIST INTO DUMMY;
 FOUND := CFK1_RECLIST%FOUND;
 close CFK1_RECLIST;
 if found then
 errno := -20005;
 errmsg := 'CHILDREN STILL EXIST IN "RECLIST". CANNOT MODIFY PARENT CODE IN "ACCOUNTCD".';
 raise integrity_error;
 end if;
 end if;

 -- Cannot modify parent code in "ACCOUNTCD" if children still exist in "INVOICELIST"
 if (updating('ACDID') and :old.ACDID != :new.ACDID) then
 open CFK2_INVOICELIST(:old.ACDID);
 fetch CFK2_INVOICELIST into dummy;
 found := CFK2_INVOICELIST%FOUND;
 CLOSE CFK2_INVOICELIST;
 IF FOUND THEN
 ERRNO := -20005;
 ERRMSG := 'CHILDREN STILL EXIST IN "INVOICELIST". CANNOT MODIFY PARENT CODE IN "ACCOUNTCD".';
 RAISE INTEGRITY_ERROR;
 END IF;
 END IF;

 -- CANNOT MODIFY PARENT CODE IN "ACCOUNTCD" IF CHILDREN STILL EXIST IN "RECLIST"
 IF (UPDATING('ACDID') AND :OLD.ACDID != :NEW.ACDID) THEN
 OPEN CFK3_RECLIST(:OLD.ACDID);
 FETCH CFK3_RECLIST INTO DUMMY;
 FOUND := CFK3_RECLIST%FOUND;
 close CFK3_RECLIST;
 if found then
 errno := -20005;
 errmsg := 'CHILDREN STILL EXIST IN "RECLIST". CANNOT MODIFY PARENT CODE IN "ACCOUNTCD".';
 raise integrity_error;
 end if;
 end if;

 -- Cannot modify parent code in "ACCOUNTCD" if children still exist in "PAYMENT"
 if (updating('ACDID') and :old.ACDID != :new.ACDID) then
 open CFK4_PAYMENT(:old.ACDID);
 fetch CFK4_PAYMENT into dummy;
 found := CFK4_PAYMENT%FOUND;
 CLOSE CFK4_PAYMENT;
 IF FOUND THEN
 ERRNO := -20005;
 ERRMSG := 'CHILDREN STILL EXIST IN "PAYMENT". CANNOT MODIFY PARENT CODE IN "ACCOUNTCD".';
 RAISE INTEGRITY_ERROR;
 END IF;
 END IF;


-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/
