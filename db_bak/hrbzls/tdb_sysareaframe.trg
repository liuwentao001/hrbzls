CREATE OR REPLACE TRIGGER HRBZLS."TDB_SYSAREAFRAME" BEFORE DELETE
ON SYSAREAFRAME FOR EACH ROW
DECLARE
  INTEGRITY_ERROR EXCEPTION;
  ERRNO  INTEGER;
  ERRMSG CHAR(200);
  DUMMY  INTEGER;
  FOUND  BOOLEAN;
  --  DECLARATION OF DELETEPARENTRESTRICT CONSTRAINT FOR "METERINFO"
  CURSOR CFK1_METERINFO(VAR_SAFID VARCHAR) IS
    SELECT 1
      FROM METERINFO
     WHERE MISAFID = VAR_SAFID
       AND VAR_SAFID IS NOT NULL;

BEGIN
  IF NVL(FSYSPARA('data'), 'N') = 'Y' THEN
    RETURN;
  END IF;
  --  CANNOT DELETE PARENT "SYSAREAFRAME" IF CHILDREN STILL EXIST IN "METERINFO"
  OPEN CFK1_METERINFO(:OLD.SAFID);
  FETCH CFK1_METERINFO
    INTO DUMMY;
  FOUND := CFK1_METERINFO%FOUND;
  CLOSE CFK1_METERINFO;
  IF FOUND THEN
    ERRNO  := -20006;
    ERRMSG := 'CHILDREN STILL EXIST IN "METERINFO". CANNOT DELETE PARENT "SYSAREAFRAME".';
    RAISE INTEGRITY_ERROR;
  END IF;

  DELETE SYSAREAPARA WHERE SMPID = :OLD.SAFID;
  --  ERRORS HANDLING
EXCEPTION
  WHEN INTEGRITY_ERROR THEN
    RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

