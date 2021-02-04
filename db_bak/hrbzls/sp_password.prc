CREATE OR REPLACE PROCEDURE HRBZLS.SP_PASSWORD (P_MIID         IN METERINFO.MIID%TYPE,
                                        P_PASSWORD      IN VARCHAR2) AS

V_PASSWORD VARCHAR2(40);

BEGIN
  SELECT MD5(P_PASSWORD) INTO V_PASSWORD FROM DUAL;

  UPDATE METERINFO SET MIYL4 = V_PASSWORD WHERE MIID = P_MIID;
  COMMIT;
EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
     DBMS_OUTPUT.PUT_LINE('�����޸�ʧ�ܣ�');

END;
/

