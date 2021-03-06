CREATE OR REPLACE FUNCTION HRBZLS.FGETFUNCMETHODNAME(FUNCID   IN VARCHAR2,
                                              METHODID IN VARCHAR2)
  RETURN VARCHAR2 AS
  METHODNAME VARCHAR2(100);
BEGIN
  SELECT EFM.EFMNAME
    INTO METHODNAME
    FROM ERPFUNCMETHOD EFM
   WHERE TRIM(EFM.EFMFID) = TRIM(FUNCID)
     AND TRIM(EFM.EFMMID) = TRIM(METHODID);
  RETURN METHODNAME;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
/

