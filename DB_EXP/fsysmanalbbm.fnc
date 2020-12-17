﻿CREATE OR REPLACE FUNCTION "FSYSMANALBBM"
 (TCODE IN CHAR,LLB IN CHAR)
 RETURN CHAR
 AS
 LCODE VARCHAR2(15);
 BEGIN
 SELECT SMFID INTO LCODE FROM SYSMANAFRAME WHERE SMFTYPE=LLB
 START WITH SMFID=TCODE CONNECT BY PRIOR SMFPID=SMFID;
 RETURN LCODE;
 EXCEPTION WHEN OTHERS THEN
 RETURN TCODE;
 END FSYSMANALBBM;
/

