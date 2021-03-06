CREATE OR REPLACE TRIGGER HRBZLS."TIB_RECADJUSTDT" BEFORE INSERT
ON RECADJUSTDT FOR EACH ROW
DECLARE
    INTEGRITY_ERROR  EXCEPTION;
    ERRNO            INTEGER;
    ERRMSG           CHAR(200);
    DUMMY            INTEGER;
    FOUND            BOOLEAN;
    --  DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "RECADJUSTHD"
    CURSOR CPK1_RECADJUSTDT(VAR_RADNO VARCHAR) IS
       SELECT 1
       FROM   RECADJUSTHD
       WHERE  RAHNO = VAR_RADNO
        AND   VAR_RADNO IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
    --  PARENT "RECADJUSTHD" MUST EXIST WHEN INSERTING A CHILD IN "RECADJUSTDT"
    IF :NEW.RADNO IS NOT NULL THEN
       OPEN  CPK1_RECADJUSTDT(:NEW.RADNO);
       FETCH CPK1_RECADJUSTDT INTO DUMMY;
       FOUND := CPK1_RECADJUSTDT%FOUND;
       CLOSE CPK1_RECADJUSTDT;
       IF NOT FOUND THEN
          ERRNO  := -20002;
          ERRMSG := 'PARENT DOES NOT EXIST IN "RECADJUSTHD". CANNOT CREATE CHILD IN "RECADJUSTDT".';
          RAISE INTEGRITY_ERROR;
       END IF;
    END IF;


--  ERRORS HANDLING
EXCEPTION
    WHEN INTEGRITY_ERROR THEN
       RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

