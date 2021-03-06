CREATE OR REPLACE TRIGGER HRBZLS."TUB_RECADJUSTHD" BEFORE UPDATE
OF RAHNO
ON RECADJUSTHD FOR EACH ROW
DECLARE
    INTEGRITY_ERROR  EXCEPTION;
    ERRNO            INTEGER;
    ERRMSG           CHAR(200);
    DUMMY            INTEGER;
    FOUND            BOOLEAN;
    --  DECLARATION OF UPDATEPARENTRESTRICT CONSTRAINT FOR "RECADJUSTDT"
    CURSOR CFK1_RECADJUSTDT(VAR_RAHNO VARCHAR) IS
       SELECT 1
       FROM   RECADJUSTDT
       WHERE  RADNO = VAR_RAHNO
        AND   VAR_RAHNO IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
    --  CANNOT MODIFY PARENT CODE IN "RECADJUSTHD" IF CHILDREN STILL EXIST IN "RECADJUSTDT"
    IF (UPDATING('RAHNO') AND :OLD.RAHNO != :NEW.RAHNO) THEN
       OPEN  CFK1_RECADJUSTDT(:OLD.RAHNO);
       FETCH CFK1_RECADJUSTDT INTO DUMMY;
       FOUND := CFK1_RECADJUSTDT%FOUND;
       CLOSE CFK1_RECADJUSTDT;
       IF FOUND THEN
          ERRNO  := -20005;
          ERRMSG := 'CHILDREN STILL EXIST IN "RECADJUSTDT". CANNOT MODIFY PARENT CODE IN "RECADJUSTHD".';
          RAISE INTEGRITY_ERROR;
       END IF;
    END IF;


--  ERRORS HANDLING
EXCEPTION
    WHEN INTEGRITY_ERROR THEN
       RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

