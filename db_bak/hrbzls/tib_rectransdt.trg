CREATE OR REPLACE TRIGGER HRBZLS."TIB_RECTRANSDT" BEFORE INSERT
ON RECTRANSDT FOR EACH ROW
DECLARE
    INTEGRITY_ERROR  EXCEPTION;
    ERRNO            INTEGER;
    ERRMSG           CHAR(200);
    DUMMY            INTEGER;
    FOUND            BOOLEAN;
    --  DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "RECTRANSHD"
    CURSOR CPK1_RECTRANSDT(VAR_RTDNO VARCHAR) IS
       SELECT 1
       FROM   RECTRANSHD
       WHERE  RTHNO = VAR_RTDNO
        AND   VAR_RTDNO IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
    --  PARENT "RECTRANSHD" MUST EXIST WHEN INSERTING A CHILD IN "RECTRANSDT"
    IF :NEW.RTDNO IS NOT NULL THEN
       OPEN  CPK1_RECTRANSDT(:NEW.RTDNO);
       FETCH CPK1_RECTRANSDT INTO DUMMY;
       FOUND := CPK1_RECTRANSDT%FOUND;
       CLOSE CPK1_RECTRANSDT;
       IF NOT FOUND THEN
          ERRNO  := -20002;
          ERRMSG := 'PARENT DOES NOT EXIST IN "RECTRANSHD". CANNOT CREATE CHILD IN "RECTRANSDT".';
          RAISE INTEGRITY_ERROR;
       END IF;
    END IF;


--  ERRORS HANDLING
EXCEPTION
    WHEN INTEGRITY_ERROR THEN
       RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

