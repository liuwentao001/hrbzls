CREATE OR REPLACE FUNCTION HRBZLS.FGETROLEFUNCDATE1(VRID IN VARCHAR2,
                                            VFID IN VARCHAR2) RETURN DATE AS
  LDATE DATE;
BEGIN
  SELECT ORFSTARTDATE
    INTO LDATE
    FROM OPERROLEFUNC_EX
   WHERE ORFRID = VRID
     AND ORFFID = VFID;
  RETURN LDATE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
/

