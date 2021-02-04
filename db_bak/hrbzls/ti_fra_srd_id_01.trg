CREATE OR REPLACE TRIGGER HRBZLS."TI_FRA_SRD_id_01" BEFORE INSERT
ON FRA_SRD FOR EACH ROW
BEGIN
 IF :NEW.id IS NULL THEN
      SELECT  fgetsequence('FRA_SRD') INTO :new.id from dual;
 end IF;
EXCEPTION
    WHEN OTHERS  THEN
       NULL;
END;
/

