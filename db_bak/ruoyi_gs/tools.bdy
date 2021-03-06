﻿CREATE OR REPLACE PACKAGE BODY "TOOLS" IS

  FUNCTION FGETREADMONTH(P_SMFID IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    --抄表月份
    RETURN FPARA(P_SMFID, '000009');
  END;

  --取当前系统年月日'YYYY/MM/DD'
  FUNCTION FGETSYSDATE RETURN DATE AS
    XTRQ DATE;
  BEGIN
    SELECT TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYY/MM/DD')
      INTO XTRQ
      FROM DUAL;
    RETURN XTRQ;
  END;

  FUNCTION GETMAX(N1 IN NUMBER, N2 IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF NVL(N1, 0) >= NVL(N2, 0) THEN
      RETURN NVL(N1, 0);
    ELSE
      RETURN NVL(N2, 0);
    END IF;
  END GETMAX;

  FUNCTION GETMIN(N1 IN NUMBER, N2 IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF NVL(N1, 0) <= NVL(N2, 0) THEN
      RETURN NVL(N1, 0);
    ELSE
      RETURN NVL(N2, 0);
    END IF;
  END GETMIN;

END TOOLS;
/

