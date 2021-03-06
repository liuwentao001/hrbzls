CREATE OR REPLACE TRIGGER HRBZLS."TDB_METERBRAND" BEFORE DELETE
ON METERBRAND FOR EACH ROW
DECLARE
    INTEGRITY_ERROR  EXCEPTION;
    ERRNO            INTEGER;
    ERRMSG           CHAR(200);
    DUMMY            INTEGER;
    FOUND            BOOLEAN;
    --  DECLARATION OF DELETEPARENTRESTRICT CONSTRAINT FOR "METERMAXCODE"
    CURSOR CFK1_METERMAXCODE(VAR_MBID VARCHAR) IS
       SELECT 1
       FROM   METERMAXCODE
       WHERE  MMCMBID = VAR_MBID
        AND   VAR_MBID IS NOT NULL;
    --  DECLARATION OF DELETEPARENTRESTRICT CONSTRAINT FOR "METERDOC"
    CURSOR CFK2_METERDOC(VAR_MBID VARCHAR) IS
       SELECT 1
       FROM   METERDOC
       WHERE  MDBRAND = VAR_MBID
        AND   VAR_MBID IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
    --  CANNOT DELETE PARENT "METERBRAND" IF CHILDREN STILL EXIST IN "METERMAXCODE"
    OPEN  CFK1_METERMAXCODE(:OLD.MBID);
    FETCH CFK1_METERMAXCODE INTO DUMMY;
    FOUND := CFK1_METERMAXCODE%FOUND;
    close CFK1_METERMAXCODE;
    if found then
       errno  := -20006;
       errmsg := 'CHILDREN STILL EXIST IN "METERMAXCODE". CANNOT DELETE PARENT "METERBRAND".';
       raise integrity_error;
    end if;

    --  Cannot delete parent "METERBRAND" if children still exist in "METERDOC"
    open  CFK2_METERDOC(:old.MBID);
    fetch CFK2_METERDOC into dummy;
    found := CFK2_METERDOC%FOUND;
    CLOSE CFK2_METERDOC;
    IF FOUND THEN
       ERRNO  := -20006;
       ERRMSG := 'CHILDREN STILL EXIST IN "METERDOC". CANNOT DELETE PARENT "METERBRAND".';
       RAISE INTEGRITY_ERROR;
    END IF;


--  ERRORS HANDLING
EXCEPTION
    WHEN INTEGRITY_ERROR THEN
       RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

