CREATE OR REPLACE TRIGGER HRBZLS."tbi_rpt_sum_total" BEFORE INSERT
ON rpt_sum_total FOR EACH ROW

BEGIN
  IF :NEW.ID IS NULL THEN
    SELECT SEQ_RPT.NEXTVAL INTO :NEW.ID FROM DUAL;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
/

