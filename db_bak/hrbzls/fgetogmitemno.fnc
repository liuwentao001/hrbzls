CREATE OR REPLACE FUNCTION HRBZLS."FGETOGMITEMNO" (P_GROUP IN VARCHAR2,P_OGMID IN VARCHAR2)
  RETURN VARCHAR2
AS
  VPID  VARCHAR2(10);
  I     INTEGER;
BEGIN
  IF P_OGMID=P_GROUP THEN
    RETURN 'item';
  ELSE
    SELECT OGMPID,ITEMNO INTO VPID,I FROM (
    SELECT OGMID,OGMPID,ROW_NUMBER() OVER (PARTITION BY OGMPID ORDER BY OGMID) AS ITEMNO
     FROM (
            SELECT OGMID OGMID,OGMPID
              FROM OPERGROUPMOD
             WHERE OGMGID = P_GROUP
/*             UNION ALL
            SELECT EFID OGMID,  OGFID OGMPID
              FROM ERPFUNCTION,OPERGROUPFUNC
             WHERE EFID = OGFFID AND EFVISIBLE='Y' AND OGFGID=P_GROUP*/
             
           ))
     WHERE OGMID = P_OGMID;

    RETURN FGETOGMITEMNO(P_GROUP,VPID)||'_'||TO_CHAR(I);
  END IF;
EXCEPTION WHEN OTHERS THEN
  RETURN NULL;
END;
/

