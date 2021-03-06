CREATE OR REPLACE TRIGGER HRBZLS."TIB_PRICEMULTIDETAIL" BEFORE INSERT
ON PRICEMULTIDETAIL FOR EACH ROW
DECLARE
    INTEGRITY_ERROR  EXCEPTION;
    ERRNO            INTEGER;
    ERRMSG           CHAR(200);
    DUMMY            INTEGER;
    FOUND            BOOLEAN;
    --  DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "METERINFO"
    CURSOR CPK1_PRICEMULTIDETAIL(VAR_PMDCID VARCHAR,
                    VAR_PMDMID VARCHAR) IS
       SELECT 1
       FROM   METERINFO
       WHERE  MICID = VAR_PMDCID
        AND   MIID = VAR_PMDMID
        AND   VAR_PMDCID IS NOT NULL
        AND   VAR_PMDMID IS NOT NULL;
    --  DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "PRICEFRAME"
    CURSOR CPK2_PRICEMULTIDETAIL(VAR_PMDPFID VARCHAR) IS
       SELECT 1
       FROM   PRICEFRAME
       WHERE  PFID = VAR_PMDPFID
        AND   VAR_PMDPFID IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
    --  PARENT "METERINFO" MUST EXIST WHEN INSERTING A CHILD IN "PRICEMULTIDETAIL"
    IF :NEW.PMDCID IS NOT NULL AND
       :NEW.PMDMID IS NOT NULL THEN
       OPEN  CPK1_PRICEMULTIDETAIL(:NEW.PMDCID,
                      :NEW.PMDMID);
       FETCH CPK1_PRICEMULTIDETAIL INTO DUMMY;
       FOUND := CPK1_PRICEMULTIDETAIL%FOUND;
       close CPK1_PRICEMULTIDETAIL;
       if not found then
          errno  := -20002;
          errmsg := 'PARENT DOES NOT EXIST IN "METERINFO". CANNOT CREATE CHILD IN "PRICEMULTIDETAIL".';
          raise integrity_error;
       end if;
    end if;

    --  Parent "PRICEFRAME" must exist when inserting a child in "PRICEMULTIDETAIL"
    if :new.PMDPFID is not null then
       open  CPK2_PRICEMULTIDETAIL(:new.PMDPFID);
       fetch CPK2_PRICEMULTIDETAIL into dummy;
       found := CPK2_PRICEMULTIDETAIL%FOUND;
       CLOSE CPK2_PRICEMULTIDETAIL;
       IF NOT FOUND THEN
          ERRNO  := -20002;
          ERRMSG := 'PARENT DOES NOT EXIST IN "PRICEFRAME". CANNOT CREATE CHILD IN "PRICEMULTIDETAIL".';
          RAISE INTEGRITY_ERROR;
       END IF;
    END IF;

    UPDATE METERINFO SET MIIFMP='Y' WHERE MICID=:NEW.PMDCID AND MIID=:NEW.PMDMID;
--  ERRORS HANDLING
EXCEPTION
    WHEN INTEGRITY_ERROR THEN
       RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

