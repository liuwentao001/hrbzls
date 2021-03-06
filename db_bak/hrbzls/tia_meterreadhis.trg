CREATE OR REPLACE TRIGGER HRBZLS."TIA_METERREADHIS"
  AFTER INSERT ON METERREADHIS
  FOR EACH ROW
DECLARE
  MT METERTGL%ROWTYPE;
BEGIN
  IF NVL(FSYSPARA('data'), 'N') = 'Y' THEN
    RETURN;
  END IF;
  --20160801 等针用户处理
  IF :NEW.MRDZFLAG = 'Y' AND :NEW.MRDZSL > 0 THEN
    SELECT * INTO MT FROM METERTGL WHERE MTMID = :NEW.MRMID;
    UPDATE METERTGL
       SET MTCURCODE = :NEW.MRECODE,
           MTTGL     = MTTGL - :NEW.MRDZSL,
           MTSTATUS = CASE
                        WHEN :NEW.MRECODE >= MTSYSCODE OR
                             MTTGL - :NEW.MRDZSL <= 0 THEN
                         'N'
                        ELSE
                         MTSTATUS
                      END
     WHERE MTMID = :NEW.MRMID;
    --更新meterinfo的等针标志
    IF :NEW.MRECODE >= MT.MTSYSCODE OR MT.MTTGL - :NEW.MRDZSL <= 0 THEN
      UPDATE METERINFO SET MIYL1 = 'N' WHERE MIID = :NEW.MRMID;
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR('-20001', SQLERRM);
END;
/

