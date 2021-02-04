CREATE OR REPLACE TRIGGER HRBZLS."TBI_XT_FTP_FILE" BEFORE INSERT
ON XT_FTP_FILE FOR EACH ROW

BEGIN
 IF :NEW.ID IS NULL THEN
      SELECT  fgetsequence('XT_FTP_FILE') INTO :new.ID from dual;
 end IF;
EXCEPTION
    WHEN OTHERS  THEN
       NULL;
END;
/

