CREATE OR REPLACE TRIGGER HRBZLS."TUB_RECTRANSHD" BEFORE UPDATE
OF RTHNO
ON RECTRANSHD FOR EACH ROW
DECLARE
    INTEGRITY_ERROR  EXCEPTION;
    ERRNO            INTEGER;
    ERRMSG           CHAR(200);
    DUMMY            INTEGER;
    FOUND            BOOLEAN;
    --  DECLARATION OF UPDATEPARENTRESTRICT CONSTRAINT FOR "RECTRANSDT"
    CURSOR CFK1_RECTRANSDT(VAR_RTHNO VARCHAR) IS
       SELECT 1
       FROM   RECTRANSDT
       WHERE  RTDNO = VAR_RTHNO
        AND   VAR_RTHNO IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
    --  CANNOT MODIFY PARENT CODE IN "RECTRANSHD" IF CHILDREN STILL EXIST IN "RECTRANSDT"
    IF (UPDATING('RTHNO') AND :OLD.RTHNO != :NEW.RTHNO) THEN
       OPEN  CFK1_RECTRANSDT(:OLD.RTHNO);
       FETCH CFK1_RECTRANSDT INTO DUMMY;
       FOUND := CFK1_RECTRANSDT%FOUND;
       CLOSE CFK1_RECTRANSDT;
       IF FOUND THEN
          ERRNO  := -20005;
          ERRMSG := 'CHILDREN STILL EXIST IN "RECTRANSDT". CANNOT MODIFY PARENT CODE IN "RECTRANSHD".';
          RAISE INTEGRITY_ERROR;
       END IF;
    END IF;


--  ERRORS HANDLING
EXCEPTION
    WHEN INTEGRITY_ERROR THEN
       RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

