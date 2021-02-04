CREATE OR REPLACE FUNCTION HRBZLS."FGETYYWBS"(P_MIID IN VARCHAR2) RETURN NUMBER IS
  V_NUM NUMBER(5);
BEGIN
  SELECT COUNT(RLID)
    INTO V_NUM
    FROM RECLIST T
   WHERE T.RLMID = P_MIID
     AND RLPAIDFLAG = 'N'
     AND RLOUTFLAG = 'N'
     AND RLBADFLAG = 'N'
     AND RLREVERSEFLAG = 'N'
     AND RLTRANS = 'T'
     AND RLJE + DECODE(RLZNJREDUCFLAG, 'Y', RLZNJ, 0) > 0;
  RETURN V_NUM;
END FGETYYWBS;
/

