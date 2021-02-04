CREATE OR REPLACE TRIGGER HRBZLS."TUB_METERREADTYPE" BEFORE UPDATE
OF SRTID
ON SYSREADTYPE FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
 -- DECLARATION OF UPDATEPARENTRESTRICT CONSTRAINT FOR "METERINFO"
 CURSOR CFK1_METERINFO(VAR_SRTID VARCHAR) IS
 SELECT 1
 FROM METERINFO
 WHERE MIRTID = VAR_SRTID
 AND VAR_SRTID IS NOT NULL;
 -- DECLARATION OF UPDATEPARENTRESTRICT CONSTRAINT FOR "RECLIST"
 CURSOR CFK2_RECLIST(VAR_SRTID VARCHAR) IS
 SELECT 1
 FROM RECLIST
 WHERE RLRTID = VAR_SRTID
 AND VAR_SRTID IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 -- CANNOT MODIFY PARENT CODE IN "SYSREADTYPE" IF CHILDREN STILL EXIST IN "METERINFO"
 IF (UPDATING('SRTID') AND :OLD.SRTID != :NEW.SRTID) THEN
 OPEN CFK1_METERINFO(:OLD.SRTID);
 FETCH CFK1_METERINFO INTO DUMMY;
 FOUND := CFK1_METERINFO%FOUND;
 close CFK1_METERINFO;
 if found then
 errno := -20005;
 errmsg := 'CHILDREN STILL EXIST IN "METERINFO". CANNOT MODIFY PARENT CODE IN "SYSREADTYPE".';
 raise integrity_error;
 end if;
 end if;

 -- Cannot modify parent code in "SYSREADTYPE" if children still exist in "RECLIST"
 if (updating('SRTID') and :old.SRTID != :new.SRTID) then
 open CFK2_RECLIST(:old.SRTID);
 fetch CFK2_RECLIST into dummy;
 found := CFK2_RECLIST%FOUND;
 CLOSE CFK2_RECLIST;
 IF FOUND THEN
 ERRNO := -20005;
 ERRMSG := 'CHILDREN STILL EXIST IN "RECLIST". CANNOT MODIFY PARENT CODE IN "SYSREADTYPE".';
 RAISE INTEGRITY_ERROR;
 END IF;
 END IF;


-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

