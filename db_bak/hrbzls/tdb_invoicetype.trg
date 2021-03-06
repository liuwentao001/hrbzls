CREATE OR REPLACE TRIGGER HRBZLS."TDB_INVOICETYPE" BEFORE DELETE
ON INVOICETYPE FOR EACH ROW
DECLARE
    INTEGRITY_ERROR  EXCEPTION;
    ERRNO            INTEGER;
    ERRMSG           CHAR(200);
    DUMMY            INTEGER;
    FOUND            BOOLEAN;
    --  DECLARATION OF DELETEPARENTRESTRICT CONSTRAINT FOR "INVOICELIST"
    CURSOR CFK1_INVOICELIST(VAR_ITID VARCHAR) IS
       SELECT 1
       FROM   INVOICELIST
       WHERE  ILTYPE = VAR_ITID
        AND   VAR_ITID IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
    --  CANNOT DELETE PARENT "INVOICETYPE" IF CHILDREN STILL EXIST IN "INVOICELIST"
    OPEN  CFK1_INVOICELIST(:OLD.ITID);
    FETCH CFK1_INVOICELIST INTO DUMMY;
    FOUND := CFK1_INVOICELIST%FOUND;
    CLOSE CFK1_INVOICELIST;
    IF FOUND THEN
       ERRNO  := -20006;
       ERRMSG := 'CHILDREN STILL EXIST IN "INVOICELIST". CANNOT DELETE PARENT "INVOICETYPE".';
       RAISE INTEGRITY_ERROR;
    END IF;


--  ERRORS HANDLING
EXCEPTION
    WHEN INTEGRITY_ERROR THEN
       RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

