CREATE OR REPLACE TRIGGER HRBZLS."TUB_METERSORTFRAME" BEFORE UPDATE
OF MSFID
ON METERSORTFRAME FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
 -- DECLARATION OF UPDATEPARENTRESTRICT CONSTRAINT FOR "METERINFO"
 CURSOR CFK1_METERINFO(VAR_MSFID VARCHAR) IS
 SELECT 1
 FROM METERINFO
 WHERE MISTID = VAR_MSFID
 AND VAR_MSFID IS NOT NULL;
 -- DECLARATION OF UPDATEPARENTRESTRICT CONSTRAINT FOR "RECLIST"
 CURSOR CFK2_RECLIST(VAR_MSFID VARCHAR) IS
 SELECT 1
 FROM RECLIST
 WHERE RLMSFID = VAR_MSFID
 AND VAR_MSFID IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 -- CANNOT MODIFY PARENT CODE IN "METERSORTFRAME" IF CHILDREN STILL EXIST IN "METERINFO"
 IF (UPDATING('MSFID') AND :OLD.MSFID != :NEW.MSFID) THEN
 OPEN CFK1_METERINFO(:OLD.MSFID);
 FETCH CFK1_METERINFO INTO DUMMY;
 FOUND := CFK1_METERINFO%FOUND;
 close CFK1_METERINFO;
 if found then
 errno := -20005;
 errmsg := 'CHILDREN STILL EXIST IN "METERINFO". CANNOT MODIFY PARENT CODE IN "METERSORTFRAME".';
 raise integrity_error;
 end if;
 end if;

 -- Cannot modify parent code in "METERSORTFRAME" if children still exist in "RECLIST"
 if (updating('MSFID') and :old.MSFID != :new.MSFID) then
 open CFK2_RECLIST(:old.MSFID);
 fetch CFK2_RECLIST into dummy;
 found := CFK2_RECLIST%FOUND;
 CLOSE CFK2_RECLIST;
 IF FOUND THEN
 ERRNO := -20005;
 ERRMSG := 'CHILDREN STILL EXIST IN "RECLIST". CANNOT MODIFY PARENT CODE IN "METERSORTFRAME".';
 RAISE INTEGRITY_ERROR;
 END IF;
 END IF;


-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/
