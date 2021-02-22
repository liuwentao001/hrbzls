CREATE OR REPLACE TRIGGER HRBZLS."TIB_METERMAXCODE" BEFORE INSERT
ON METERMAXCODE FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
 -- DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "METERCALIBER"
 CURSOR CPK1_METERMAXCODE(VAR_MMCMCID NUMBER) IS
 SELECT 1
 FROM METERCALIBER
 WHERE MCID = VAR_MMCMCID
 AND VAR_MMCMCID IS NOT NULL;
 -- DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "METERMODEL"
 CURSOR CPK2_METERMAXCODE(VAR_MMCMMID VARCHAR) IS
 SELECT 1
 FROM METERMODEL
 WHERE MMID = VAR_MMCMMID
 AND VAR_MMCMMID IS NOT NULL;
 -- DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "METERBRAND"
 CURSOR CPK3_METERMAXCODE(VAR_MMCMBID VARCHAR) IS
 SELECT 1
 FROM METERBRAND
 WHERE MBID = VAR_MMCMBID
 AND VAR_MMCMBID IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 -- PARENT "METERCALIBER" MUST EXIST WHEN INSERTING A CHILD IN "METERMAXCODE"
 IF :NEW.MMCMCID IS NOT NULL THEN
 OPEN CPK1_METERMAXCODE(:NEW.MMCMCID);
 FETCH CPK1_METERMAXCODE INTO DUMMY;
 FOUND := CPK1_METERMAXCODE%FOUND;
 close CPK1_METERMAXCODE;
 if not found then
 errno := -20002;
 errmsg := 'PARENT DOES NOT EXIST IN "METERCALIBER". CANNOT CREATE CHILD IN "METERMAXCODE".';
 raise integrity_error;
 end if;
 end if;

 -- Parent "METERMODEL" must exist when inserting a child in "METERMAXCODE"
 if :new.MMCMMID is not null then
 open CPK2_METERMAXCODE(:new.MMCMMID);
 fetch CPK2_METERMAXCODE into dummy;
 found := CPK2_METERMAXCODE%FOUND;
 CLOSE CPK2_METERMAXCODE;
 IF NOT FOUND THEN
 ERRNO := -20002;
 ERRMSG := 'PARENT DOES NOT EXIST IN "METERMODEL". CANNOT CREATE CHILD IN "METERMAXCODE".';
 RAISE INTEGRITY_ERROR;
 END IF;
 END IF;

 -- PARENT "METERBRAND" MUST EXIST WHEN INSERTING A CHILD IN "METERMAXCODE"
 IF :NEW.MMCMBID IS NOT NULL THEN
 OPEN CPK3_METERMAXCODE(:NEW.MMCMBID);
 FETCH CPK3_METERMAXCODE INTO DUMMY;
 FOUND := CPK3_METERMAXCODE%FOUND;
 CLOSE CPK3_METERMAXCODE;
 IF NOT FOUND THEN
 ERRNO := -20002;
 ERRMSG := 'PARENT DOES NOT EXIST IN "METERBRAND". CANNOT CREATE CHILD IN "METERMAXCODE".';
 RAISE INTEGRITY_ERROR;
 END IF;
 END IF;


-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/
