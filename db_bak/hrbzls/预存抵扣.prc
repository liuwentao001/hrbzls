CREATE OR REPLACE PROCEDURE HRBZLS."预存抵扣" IS
  V_SMFID VARCHAR(10);
  V_ALOG  AUTOEXEC_LOG%ROWTYPE;
  CURSOR YYS IS
    SELECT SMFID
      FROM SYSMANAFRAME T
     WHERE SMFTYPE = '1'
       AND SMFSTATUS = 'Y'
       AND SUBSTR(SMFID, 1, 2) = '02';
BEGIN
  V_ALOG.O_TYPE := '预存抵扣';
  /*************天门预存抵扣job调用过程 20120502 by 刘光波********************/

  /*******打开营业所游标*********/
  OPEN YYS;
  LOOP
    FETCH YYS
      INTO V_SMFID;
    EXIT WHEN YYS%NOTFOUND OR YYS%NOTFOUND IS NULL;
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
      /******调用抵扣主过程**/
      SP_RLSAVING_XY(V_SMFID);
      V_ALOG.O_RESULT := V_SMFID || '成功';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_RESULT := V_SMFID || '失败';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    V_ALOG.O_TIME_2 := SYSDATE;
    V_ALOG.O_TIME_2 := SYSDATE;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    /********记录操作日志*****/
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;
  END LOOP;
  IF YYS%ISOPEN THEN
    CLOSE YYS;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF YYS%ISOPEN THEN
      CLOSE YYS;
    END IF;
END;
/

