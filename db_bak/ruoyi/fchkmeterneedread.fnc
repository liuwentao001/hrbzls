﻿CREATE OR REPLACE FUNCTION "FCHKMETERNEEDREAD"
   (VMIID IN VARCHAR2)
   RETURN CHAR
AS
   LRET       CHAR(1);
   VMISTATUS  BS_METERINFO.MISTATUS%TYPE;
   VMITYPE    BS_CUSTINFO.MICHARGETYPE%TYPE;
   VMIIFSL    BS_METERINFO.MIIFSL%TYPE;
   VMIIFCHK   BS_METERINFO.MIIFCHK%TYPE;
   MI         BS_METERINFO%ROWTYPE;
BEGIN
   SELECT MISTATUS,NVL(MICHARGETYPE,'1'),MIIFSL,NVL(MIIFCHK,'N')
     INTO VMISTATUS,VMITYPE,VMIIFSL,VMIIFCHK
     FROM BS_METERINFO,BS_CUSTINFO
    WHERE MIID=CIID AND MIID=VMIID;
   --非抄表类型的表状态水表不抄
   --SELECT SMSMEMO INTO LRET FROM SYSMETERSTATUS WHERE SMSID=VMISTATUS;
   --对应值暂时无法取出默认为Y   SELECT A.DICT_TYPE INTO LRET FROM SYS_DICT_DATA A WHERE A.DICT_TYPE='sys_sysmeterstatus';
   LRET:='Y';
   IF LRET='N' THEN
      RETURN 'N';
   END IF;
   --非抄表类型的表类型水表不抄
   --SELECT SMTIFREAD INTO LRET FROM SYSMETERTYPE WHERE SMTID=VMITYPE;
   --对应值暂时无法取出默认为Y   SELECT A.DICT_TYPE INTO LRET FROM SYS_DICT_DATA A WHERE A.DICT_TYPE='sys_sysmetertype';
   IF LRET='N' THEN
      RETURN 'N';
   END IF;
   --一表多户分表水表不抄 ZHB
   --暂不考虑多表情况
   /*SELECT * INTO MI FROM BS_METERINFO WHERE MIID=VMIID;
   IF MI.MICOLUMN9='Y' AND MI.MICODE <> MI.MIPRIID  THEN
      RETURN 'N';
   END IF;*/

   RETURN 'Y';
EXCEPTION

WHEN OTHERS THEN
   RETURN 'N';
END;
/

