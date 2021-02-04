CREATE OR REPLACE TRIGGER HRBZLS."TIA_BILLMAIN"
  AFTER INSERT ON BILLMAIN
  FOR EACH ROW
DECLARE

BEGIN
  INSERT INTO BILLMAIN_EX
    (BMID, BMSTATUS, BMNAME, BMTYPE, BMUSEROBJECT, BMFLOWID)
  VALUES
    (:NEW.BMID,
     :NEW.BMSTATUS,
     :NEW.BMNAME,
     :NEW.BMTYPE,
     :NEW.BMUSEROBJECT,
     :NEW.BMFLAG2);
END;
/

