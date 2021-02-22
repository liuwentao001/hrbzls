CREATE OR REPLACE TRIGGER HRBZLS."TUB_CUSTINSHD" BEFORE UPDATE
OF CIHNO
ON CUSTINSHD FOR EACH ROW
DECLARE
    INTEGRITY_ERROR  EXCEPTION;
    ERRNO            INTEGER;
    ERRMSG           CHAR(200);
    DUMMY            INTEGER;
    FOUND            BOOLEAN;
    --  DECLARATION OF UPDATEPARENTRESTRICT CONSTRAINT FOR "CUSTINSDT"
    CURSOR CFK1_CUSTINSDT(VAR_CIHNO VARCHAR) IS
       SELECT 1
       FROM   CUSTINSDT
       WHERE  CIDNO = VAR_CIHNO
        AND   VAR_CIHNO IS NOT NULL;

BEGIN
   if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
    --  CANNOT MODIFY PARENT CODE IN "CUSTINSHD" IF CHILDREN STILL EXIST IN "CUSTINSDT"
    IF (UPDATING('CIHNO') AND :OLD.CIHNO != :NEW.CIHNO) THEN
       OPEN  CFK1_CUSTINSDT(:OLD.CIHNO);
       FETCH CFK1_CUSTINSDT INTO DUMMY;
       FOUND := CFK1_CUSTINSDT%FOUND;
       CLOSE CFK1_CUSTINSDT;
       IF FOUND THEN
          ERRNO  := -20005;
          ERRMSG := 'CHILDREN STILL EXIST IN "CUSTINSDT". CANNOT MODIFY PARENT CODE IN "CUSTINSHD".';
          RAISE INTEGRITY_ERROR;
       END IF;
    END IF;


--  ERRORS HANDLING
EXCEPTION
    WHEN INTEGRITY_ERROR THEN
       RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/
