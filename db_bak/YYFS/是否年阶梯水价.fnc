﻿CREATE OR REPLACE FUNCTION 是否年阶梯水价(P_PFNO IN VARCHAR2) RETURN VARCHAR2 AS
  VCOUNT NUMBER := 0;
BEGIN
  --先检查是否年阶梯账务
  SELECT COUNT(*)
    INTO VCOUNT
    FROM BAS_PRICE_DETAIL
   WHERE METHOD IN ('njt')
     AND PRICE_NO = P_PFNO;
  IF VCOUNT > 0 THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END;
/

