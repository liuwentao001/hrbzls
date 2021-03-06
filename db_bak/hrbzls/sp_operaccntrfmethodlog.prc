CREATE OR REPLACE PROCEDURE HRBZLS.SP_OPERACCNTRFMETHODLOG(V_OAID   IN VARCHAR2,--帐号
                                                    V_VERID  IN NUMBER,
                                                    V_OPERID IN VARCHAR2,
                                                    V_WS     IN VARCHAR2,
                                                    V_FUNCID IN VARCHAR2) AS
  CURSOR C_ADD IS
    SELECT ORFMFID, ORFMETHOD, ORFMRID, ORFMSTARTDATE, ORFMEXPIRYDATE
      FROM OPERACCNTRFMETHOD_EX T
     WHERE ORFMRID = V_OAID
    MINUS
    SELECT ORFMFID, ORFMETHOD, ORFMRID, ORFMSTARTDATE, ORFMEXPIRYDATE
      FROM OPERACCNTRFMETHOD_EXHIS T
     WHERE ORFMRID = V_OAID
       AND VERID = V_VERID;

  CURSOR C_DELETE IS
    SELECT ORFMFID, ORFMETHOD, ORFMRID, ORFMSTARTDATE, ORFMEXPIRYDATE
      FROM OPERACCNTRFMETHOD_EXHIS T
     WHERE ORFMRID = V_OAID
       AND VERID = V_VERID
    MINUS
    SELECT ORFMFID, ORFMETHOD, ORFMRID, ORFMSTARTDATE, ORFMEXPIRYDATE
      FROM OPERACCNTRFMETHOD_EX T
     WHERE ORFMRID = V_OAID;
  VHIS   OPERACCNTRFMETHOD_EXHIS%ROWTYPE;
  V_DESC VARCHAR2(1000);
BEGIN
  VHIS := NULL;
  OPEN C_ADD;
  LOOP
    FETCH C_ADD
      INTO VHIS.ORFMFID, VHIS.ORFMETHOD, VHIS.ORFMRID, VHIS.ORFMSTARTDATE, VHIS.ORFMEXPIRYDATE;
    EXIT WHEN C_ADD%NOTFOUND OR C_ADD%NOTFOUND IS NULL;
    V_DESC := '赋予操作员' || FGETOPERNAME(VHIS.ORFMRID) || '[' || VHIS.ORFMRID || ']' ||
              FGETFUNCNAME(VHIS.ORFMFID) || '功能的' ||
              FGETFUNCMETHODNAME(VHIS.ORFMFID, VHIS.ORFMETHOD) ||
              '方法，有效期限'||TO_CHAR(VHIS.ORFMSTARTDATE, 'YYYY-MM-DD')||'至' || TO_CHAR(VHIS.ORFMEXPIRYDATE, 'YYYY-MM-DD');
    SP_OPERLOG(V_OPERID, V_WS, V_FUNCID, V_DESC);
  END LOOP;
  CLOSE C_ADD;

  VHIS := NULL;
  OPEN C_DELETE;
  LOOP
    FETCH C_DELETE
      INTO VHIS.ORFMFID, VHIS.ORFMETHOD, VHIS.ORFMRID, VHIS.ORFMSTARTDATE, VHIS.ORFMEXPIRYDATE;
    EXIT WHEN C_DELETE%NOTFOUND OR C_DELETE%NOTFOUND IS NULL;
    V_DESC := '收回操作员' || FGETOPERNAME(VHIS.ORFMRID) || '[' || VHIS.ORFMRID || ']' ||
              FGETFUNCNAME(VHIS.ORFMFID) || '功能的' ||
              FGETFUNCMETHODNAME(VHIS.ORFMFID, VHIS.ORFMETHOD) || '方法';
    SP_OPERLOG(V_OPERID, V_WS, V_FUNCID, V_DESC);
  END LOOP;
  CLOSE C_DELETE;

EXCEPTION
  WHEN OTHERS THEN
    IF C_ADD%ISOPEN THEN
      CLOSE C_ADD;
    END IF;
    IF C_DELETE%ISOPEN THEN
      CLOSE C_DELETE;
    END IF;
    ROLLBACK;
    RAISE;
END;
/

