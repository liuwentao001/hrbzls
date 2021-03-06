CREATE OR REPLACE TRIGGER HRBZLS."TIB_SYSFACEJOIN2" BEFORE INSERT
ON SYSFACEJOIN2 FOR EACH ROW
DECLARE
    INTEGRITY_ERROR  EXCEPTION;
    ERRNO            INTEGER;
    ERRMSG           CHAR(200);
    DUMMY            INTEGER;
    FOUND            BOOLEAN;
    --  DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "SYSFACELIST2"
    CURSOR CPK1_SYSFACEJOIN2(VAR_AFJPID VARCHAR) IS
       SELECT 1
       FROM   SYSFACELIST2
       WHERE  SFLID = VAR_AFJPID
        AND   VAR_AFJPID IS NOT NULL;
    --  DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "SYSFACELIST3"
    CURSOR CPK2_SYSFACEJOIN2(VAR_AFJCID VARCHAR) IS
       SELECT 1
       FROM   SYSFACELIST3
       WHERE  SFLID = VAR_AFJCID
        AND   VAR_AFJCID IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
    --  PARENT "SYSFACELIST2" MUST EXIST WHEN INSERTING A CHILD IN "SYSFACEJOIN2"
    IF :NEW.AFJPID IS NOT NULL THEN
       OPEN  CPK1_SYSFACEJOIN2(:NEW.AFJPID);
       FETCH CPK1_SYSFACEJOIN2 INTO DUMMY;
       FOUND := CPK1_SYSFACEJOIN2%FOUND;
       close CPK1_SYSFACEJOIN2;
       if not found then
          errno  := -20002;
          errmsg := 'PARENT DOES NOT EXIST IN "SYSFACELIST2". CANNOT CREATE CHILD IN "SYSFACEJOIN2".';
          raise integrity_error;
       end if;
    end if;

    --  Parent "SYSFACELIST3" must exist when inserting a child in "SYSFACEJOIN2"
    if :new.AFJCID is not null then
       open  CPK2_SYSFACEJOIN2(:new.AFJCID);
       fetch CPK2_SYSFACEJOIN2 into dummy;
       found := CPK2_SYSFACEJOIN2%FOUND;
       CLOSE CPK2_SYSFACEJOIN2;
       IF NOT FOUND THEN
          ERRNO  := -20002;
          ERRMSG := 'PARENT DOES NOT EXIST IN "SYSFACELIST3". CANNOT CREATE CHILD IN "SYSFACEJOIN2".';
          RAISE INTEGRITY_ERROR;
       END IF;
    END IF;


--  ERRORS HANDLING
EXCEPTION
    WHEN INTEGRITY_ERROR THEN
       RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

