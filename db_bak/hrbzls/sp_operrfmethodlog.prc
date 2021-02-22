CREATE OR REPLACE PROCEDURE HRBZLS.SP_OPERRFMETHODLOG(V_RID    IN VARCHAR2,
                                               V_VERID  IN NUMBER,
                                               V_OPERID IN VARCHAR2,
                                               V_WS     IN VARCHAR2,
                                               V_FUNCID IN VARCHAR2) AS
  CURSOR C_ADD IS
    SELECT ORFMRID, ORFMFID, ORFMETHOD,orfmstartdate,  ORFMEXPIRYDATE
      FROM OPERRFMETHOD_EX T
     WHERE ORFMRID = V_RID
    MINUS
    SELECT ORFMRID, ORFMFID, ORFMETHOD,orfmstartdate,  ORFMEXPIRYDATE
      FROM OPERRFMETHOD_EXHIS T
     WHERE ORFMRID = V_RID
       AND VERID = V_VERID;

  CURSOR C_DELETE IS
    SELECT ORFMRID, ORFMFID, ORFMETHOD,orfmstartdate , ORFMEXPIRYDATE
      FROM OPERRFMETHOD_EXHIS T
     WHERE ORFMRID = V_RID
       AND VERID = V_VERID
    MINUS
    SELECT ORFMRID, ORFMFID, ORFMETHOD,orfmstartdate,  ORFMEXPIRYDATE
      FROM OPERRFMETHOD_EX T
     WHERE ORFMRID = V_RID;
  VHIS   OPERRFMETHOD_EXHIS%ROWTYPE;
  V_DESC VARCHAR2(1000);
BEGIN
  VHIS := NULL;
  OPEN C_ADD;
  LOOP
    FETCH C_ADD
      INTO VHIS.ORFMRID, VHIS.ORFMFID, VHIS.ORFMETHOD,VHIS.ORFMSTARTDATE, VHIS.ORFMEXPIRYDATE;
    EXIT WHEN C_ADD%NOTFOUND OR C_ADD%NOTFOUND IS NULL;
    V_DESC := '�����ɫ[' || VHIS.ORFMRID || ']' || FGETFUNCNAME(VHIS.ORFMFID) ||
              '���ܵ�' || FGETFUNCMETHODNAME(VHIS.ORFMFID, VHIS.ORFMETHOD) ||
              '��������Ч����'|| TO_CHAR(VHIS.ORFMSTARTDATE, 'YYYY-MM-DD')||'��' || TO_CHAR(VHIS.ORFMEXPIRYDATE, 'YYYY-MM-DD');
    SP_OPERLOG(V_OPERID, V_WS, V_FUNCID, V_DESC);
  END LOOP;
  CLOSE C_ADD;

  VHIS := NULL;
  OPEN C_DELETE;
  LOOP
    FETCH C_DELETE
      INTO VHIS.ORFMRID, VHIS.ORFMFID, VHIS.ORFMETHOD, VHIS.ORFMSTARTDATE, VHIS.ORFMEXPIRYDATE;
    EXIT WHEN C_DELETE%NOTFOUND OR C_DELETE%NOTFOUND IS NULL;
    V_DESC := '�ջؽ�ɫ[' || VHIS.ORFMRID || ']' || FGETFUNCNAME(VHIS.ORFMFID) ||
              '���ܵ�' || FGETFUNCMETHODNAME(VHIS.ORFMFID, VHIS.ORFMETHOD) || '����';
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
