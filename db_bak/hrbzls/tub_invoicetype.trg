CREATE OR REPLACE TRIGGER HRBZLS."TUB_INVOICETYPE" BEFORE UPDATE
OF ITID
ON INVOICETYPE FOR EACH ROW
DECLARE
    INTEGRITY_ERROR  EXCEPTION;
    ERRNO            INTEGER;
    ERRMSG           CHAR(200);
    DUMMY            INTEGER;
    FOUND            BOOLEAN;
    --  DECLARATION OF UPDATEPARENTRESTRICT CONSTRAINT FOR "INVOICELIST"
    CURSOR CFK1_INVOICELIST(VAR_ITID VARCHAR) IS
       SELECT 1
       FROM   INVOICELIST
       WHERE  ILTYPE = VAR_ITID
        AND   VAR_ITID IS NOT NULL;
    --  DECLARATION OF UPDATEPARENTRESTRICT CONSTRAINT FOR "WORKPRINTSET"
    CURSOR CFK2_WORKPRINTSET(VAR_ITID VARCHAR) IS
       SELECT 1
       FROM   WORKPRINTSET
       WHERE  WPSITID = VAR_ITID
        AND   VAR_ITID IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
    --  CANNOT MODIFY PARENT CODE IN "INVOICETYPE" IF CHILDREN STILL EXIST IN "INVOICELIST"
    IF (UPDATING('ITID') AND :OLD.ITID != :NEW.ITID) THEN
       OPEN  CFK1_INVOICELIST(:OLD.ITID);
       FETCH CFK1_INVOICELIST INTO DUMMY;
       FOUND := CFK1_INVOICELIST%FOUND;
       close CFK1_INVOICELIST;
       if found then
          errno  := -20005;
          errmsg := 'CHILDREN STILL EXIST IN "INVOICELIST". CANNOT MODIFY PARENT CODE IN "INVOICETYPE".';
          raise integrity_error;
       end if;
    end if;

    --  Cannot modify parent code in "INVOICETYPE" if children still exist in "WORKPRINTSET"
    if (updating('ITID') and :old.ITID != :new.ITID) then
       open  CFK2_WORKPRINTSET(:old.ITID);
       fetch CFK2_WORKPRINTSET into dummy;
       found := CFK2_WORKPRINTSET%FOUND;
       CLOSE CFK2_WORKPRINTSET;
       IF FOUND THEN
          ERRNO  := -20005;
          ERRMSG := 'CHILDREN STILL EXIST IN "WORKPRINTSET". CANNOT MODIFY PARENT CODE IN "INVOICETYPE".';
          RAISE INTEGRITY_ERROR;
       END IF;
    END IF;


--  ERRORS HANDLING
EXCEPTION
    WHEN INTEGRITY_ERROR THEN
       RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

