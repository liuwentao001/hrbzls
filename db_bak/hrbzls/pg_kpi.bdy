CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_KPI" IS
  --指标执行   p_kt_id 指标id
  PROCEDURE KPI_EXC(P_KT_ID IN VARCHAR2) IS
    --指标定议
    CURSOR C_KPI_DEFINE IS
      SELECT *
        FROM KPI_DEFINE
       WHERE ISACTIVE = 'Y'
         AND KT_ID = P_KT_ID;
    --指票定阅人员
    CURSOR C_KPI_SUBSCRIBE(P_ID IN VARCHAR2) IS
      SELECT * FROM KPI_SUBSCRIBE WHERE KT_ID = P_ID FOR UPDATE;

    V_KPI_DEFINE    KPI_DEFINE%ROWTYPE;
    V_KPI_SUBSCRIBE KPI_SUBSCRIBE%ROWTYPE;

    V_SQL   VARCHAR(3000);
    V_VALUE VARCHAR(100);
  BEGIN
    --取指标
    OPEN C_KPI_DEFINE;
    LOOP
      FETCH C_KPI_DEFINE
        INTO V_KPI_DEFINE;
      EXIT WHEN C_KPI_DEFINE%NOTFOUND OR C_KPI_DEFINE%NOTFOUND IS NULL;
      --取数据源sql 及 where 语句
      V_SQL := V_KPI_DEFINE.KT_DATASOURCE || V_KPI_DEFINE.WHERE_CAUSE;
      --取定阅信息
      OPEN C_KPI_SUBSCRIBE(V_KPI_DEFINE.KT_ID);
      LOOP
        FETCH C_KPI_SUBSCRIBE
          INTO V_KPI_SUBSCRIBE;
        EXIT WHEN C_KPI_SUBSCRIBE%NOTFOUND OR C_KPI_SUBSCRIBE%NOTFOUND IS NULL;
        --处理定阅人员管理范围
        V_KPI_SUBSCRIBE.KT_PARA := FGETOPERRANGE(V_KPI_SUBSCRIBE.USER_ID,
                                                 'C');
        V_SQL                   := V_KPI_DEFINE.KT_DATASOURCE || ' ' ||
                                   V_KPI_DEFINE.WHERE_CAUSE;
        IF V_KPI_DEFINE.WHERE_CAUSE IS NOT NULL THEN
          IF INSTR(V_SQL, '@PARM1', 1) > 0 THEN
            --参数
            V_SQL := REPLACE(V_SQL, '@PARM1', '');
            V_SQL := V_SQL || '(' || V_KPI_SUBSCRIBE.KT_PARA || ')';
          END IF;
          IF INSTR(V_SQL, '@PARM2', 1) > 0 THEN
            --参数
            V_SQL := REPLACE(V_SQL, '@PARM2', V_KPI_SUBSCRIBE.USER_ID);
          END IF;
        END IF;
        BEGIN
          EXECUTE IMMEDIATE V_SQL
            INTO V_VALUE;
        EXCEPTION
          WHEN OTHERS THEN
            V_VALUE := 0;
        END;
        --更新指标id
        UPDATE KPI_SUBSCRIBE
           SET KT_VALUE = V_VALUE, KT_PARA = V_KPI_SUBSCRIBE.KT_PARA
         WHERE CURRENT OF C_KPI_SUBSCRIBE;
      END LOOP;
      IF C_KPI_SUBSCRIBE%ISOPEN THEN
        CLOSE C_KPI_SUBSCRIBE;
      END IF;
    END LOOP;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_KPI_DEFINE%ISOPEN THEN
        CLOSE C_KPI_DEFINE;
      END IF;
      IF C_KPI_SUBSCRIBE%ISOPEN THEN
        CLOSE C_KPI_SUBSCRIBE;
      END IF;
  END;
  --指标任务
  PROCEDURE KPI_JOB IS
    --指标定议
    CURSOR C_KPI_DEFINE IS
      SELECT * FROM KPI_DEFINE WHERE ISACTIVE = 'Y';
    --指票定阅人员
    CURSOR C_KPI_SUBSCRIBE(P_ID IN VARCHAR2) IS
      SELECT * FROM KPI_SUBSCRIBE WHERE KT_ID = P_ID FOR UPDATE;
    CURSOR C_JOB(JOBWHAT IN VARCHAR2) IS
      SELECT * FROM ALL_JOBS AL WHERE AL.WHAT = JOBWHAT;
    V_KPI_DEFINE    KPI_DEFINE%ROWTYPE;
    V_KPI_SUBSCRIBE KPI_SUBSCRIBE%ROWTYPE;
    V_JOB           ALL_JOBS%ROWTYPE;
    JOB_WHAT        VARCHAR2(100);
    JOB_NEXTTIME    VARCHAR2(100);
  BEGIN
    --取指标
    OPEN C_KPI_DEFINE;
    LOOP
      FETCH C_KPI_DEFINE
        INTO V_KPI_DEFINE;
      EXIT WHEN C_KPI_DEFINE%NOTFOUND OR C_KPI_DEFINE%NOTFOUND IS NULL;
      ---添加指标任务
      JOB_WHAT     := 'PG_KPI.KPI_EXC(' || '''' || V_KPI_DEFINE.KT_ID || '''' || ');';
      JOB_NEXTTIME := 'sysdate+' || TO_CHAR(V_KPI_DEFINE.KT_PERIOD) ||
                      '/1440';

      --添加指标job
      OPEN C_JOB(JOB_WHAT);
      LOOP
        FETCH C_JOB
          INTO V_JOB;
        EXIT WHEN C_JOB%NOTFOUND OR C_JOB%NOTFOUND IS NULL;
        IF V_JOB.INTERVAL <> JOB_NEXTTIME THEN
          JOB_REMOVE(V_JOB.JOB);
          JOB_SUBMIT(JOB_WHAT,
                     TO_CHAR(SYSDATE, 'yyyymmdd hh24:mi:ss'),
                     JOB_NEXTTIME);
        END IF;
      END LOOP;
      IF C_JOB%ROWCOUNT = 0 THEN
        JOB_SUBMIT(JOB_WHAT,
                   TO_CHAR(SYSDATE, 'yyyymmdd hh24:mi:ss'),
                   JOB_NEXTTIME);
      END IF;
      IF C_JOB%ISOPEN THEN
        CLOSE C_JOB;
      END IF;
    END LOOP;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20012, SQLERRM);
      IF C_KPI_DEFINE%ISOPEN THEN
        CLOSE C_KPI_DEFINE;
      END IF;
      IF C_KPI_SUBSCRIBE%ISOPEN THEN
        CLOSE C_KPI_SUBSCRIBE;
      END IF;
  END;

  --指标任务单行 作用于触发器
  PROCEDURE KPI_JOB_ROW(P_KPI KPI_DEFINE%ROWTYPE) IS
    --指标定议
    CURSOR C_KPI_DEFINE IS
      SELECT * FROM KPI_DEFINE WHERE ISACTIVE = 'Y';
    --指票定阅人员
    CURSOR C_KPI_SUBSCRIBE(P_ID IN VARCHAR2) IS
      SELECT * FROM KPI_SUBSCRIBE WHERE KT_ID = P_ID FOR UPDATE;
    CURSOR C_JOB(JOBWHAT IN VARCHAR2) IS
      SELECT * FROM ALL_JOBS AL WHERE AL.WHAT = JOBWHAT;
    V_KPI_DEFINE    KPI_DEFINE%ROWTYPE;
    V_KPI_SUBSCRIBE KPI_SUBSCRIBE%ROWTYPE;
    V_JOB           ALL_JOBS%ROWTYPE;
    JOB_WHAT        VARCHAR2(100);
    JOB_NEXTTIME    VARCHAR2(100);
  BEGIN
    V_KPI_DEFINE := P_KPI;

    ---添加指标任务
    JOB_WHAT     := 'PG_KPI.KPI_EXC(' || '''' || V_KPI_DEFINE.KT_ID || '''' || ');';
    JOB_NEXTTIME := 'sysdate+' || TO_CHAR(V_KPI_DEFINE.KT_PERIOD) ||
                    '/1440';
    --添加指标job
    OPEN C_JOB(JOB_WHAT);
    LOOP
      FETCH C_JOB
        INTO V_JOB;
      EXIT WHEN C_JOB%NOTFOUND OR C_JOB%NOTFOUND IS NULL;
      IF V_JOB.INTERVAL <> JOB_NEXTTIME THEN
        DBMS_JOB.REMOVE(JOB => V_JOB.JOB);
        JOB_SUBMIT(JOB_WHAT,
                   TO_CHAR(SYSDATE, 'yyyymmdd hh24:mi:ss'),
                   JOB_NEXTTIME);
      END IF;
    END LOOP;
    IF C_JOB%ROWCOUNT = 0 THEN
      JOB_SUBMIT(JOB_WHAT,
                 TO_CHAR(SYSDATE, 'yyyymmdd hh24:mi:ss'),
                 JOB_NEXTTIME);
    END IF;
    IF C_JOB%ISOPEN THEN
      CLOSE C_JOB;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20012, SQLERRM);
      IF C_KPI_DEFINE%ISOPEN THEN
        CLOSE C_KPI_DEFINE;
      END IF;
      IF C_KPI_SUBSCRIBE%ISOPEN THEN
        CLOSE C_KPI_SUBSCRIBE;
      END IF;
  END;
BEGIN
  NULL;
END PG_KPI;
/

