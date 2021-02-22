CREATE OR REPLACE TRIGGER HRBZLS."TUB_METERTRANSDT" BEFORE UPDATE
OF MTDNO,
   MTDROWNO
ON METERTRANSDT FOR EACH ROW
DECLARE
    INTEGRITY_ERROR  EXCEPTION;
    ERRNO            INTEGER;
    ERRMSG           CHAR(200);
    DUMMY            INTEGER;
    FOUND            BOOLEAN;
    SEQ NUMBER;
    --  DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "METERTRANSHD"
    CURSOR CPK1_METERTRANSDT(VAR_MTDNO VARCHAR) IS
       SELECT 1
       FROM   METERTRANSHD
       WHERE  MTHNO = VAR_MTDNO
        AND   VAR_MTDNO IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
    SEQ := INTEGRITYPACKAGE.GETNESTLEVEL;
    --  PARENT "METERTRANSHD" MUST EXIST WHEN UPDATING A CHILD IN "METERTRANSDT"
    IF (:NEW.MTDNO IS NOT NULL) AND (SEQ = 0) THEN
       OPEN  CPK1_METERTRANSDT(:NEW.MTDNO);
       FETCH CPK1_METERTRANSDT INTO DUMMY;
       FOUND := CPK1_METERTRANSDT%FOUND;
       CLOSE CPK1_METERTRANSDT;
       IF NOT FOUND THEN
          ERRNO  := -20003;
          ERRMSG := 'PARENT DOES NOT EXIST IN "METERTRANSHD". CANNOT UPDATE CHILD IN "METERTRANSDT".';
          RAISE INTEGRITY_ERROR;
       END IF;
    END IF;


--  ERRORS HANDLING
EXCEPTION
    WHEN INTEGRITY_ERROR THEN
       RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/
