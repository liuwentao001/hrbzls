CREATE OR REPLACE TRIGGER HRBZLS."TIB_RECADJUSTDDT" BEFORE INSERT
ON RECADJUSTDDT FOR EACH ROW
DECLARE
    INTEGRITY_ERROR  EXCEPTION;
    ERRNO            INTEGER;
    ERRMSG           CHAR(200);
    DUMMY            INTEGER;
    FOUND            BOOLEAN;
    --  DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "RECADJUSTDT"
    CURSOR CPK1_RECADJUSTDDT(VAR_RADDNO VARCHAR,
                    VAR_RADDROWNO NUMBER) IS
       SELECT 1
       FROM   RECADJUSTDT
       WHERE  RADNO = VAR_RADDNO
        AND   RADROWNO = VAR_RADDROWNO
        AND   VAR_RADDNO IS NOT NULL
        AND   VAR_RADDROWNO IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
    --  PARENT "RECADJUSTDT" MUST EXIST WHEN INSERTING A CHILD IN "RECADJUSTDDT"
    IF :NEW.RADDNO IS NOT NULL AND
       :NEW.RADDROWNO IS NOT NULL THEN
       OPEN  CPK1_RECADJUSTDDT(:NEW.RADDNO,
                      :NEW.RADDROWNO);
       FETCH CPK1_RECADJUSTDDT INTO DUMMY;
       FOUND := CPK1_RECADJUSTDDT%FOUND;
       CLOSE CPK1_RECADJUSTDDT;
       IF NOT FOUND THEN
          ERRNO  := -20002;
          ERRMSG := 'PARENT DOES NOT EXIST IN "RECADJUSTDT". CANNOT CREATE CHILD IN "RECADJUSTDDT".';
          RAISE INTEGRITY_ERROR;
       END IF;
    END IF;


--  ERRORS HANDLING
EXCEPTION
    WHEN INTEGRITY_ERROR THEN
       RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

