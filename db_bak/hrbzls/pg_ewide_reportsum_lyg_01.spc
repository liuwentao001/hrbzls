CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_REPORTSUM_LYG_01" IS

  -- Author  : stevewei
  -- Created : 2012-0101
  -- Purpose : 月报

  --从实例化视图生成 0--实时 1--重算
  LS_NEED_REEVAL CONSTANT INTEGER := 1;
    PROCEDURE 初始化中间表 ;
  PROCEDURE 清理数据(A_MONTH IN VARCHAR2);
  PROCEDURE 预存存档(A_MONTH IN VARCHAR2);
  PROCEDURE 抄表统计(A_MONTH IN VARCHAR2);
  PROCEDURE 账务明细统计(A_MONTH IN VARCHAR2);
  PROCEDURE 收费统计(A_MONTH IN VARCHAR2);
  PROCEDURE 综合统计(A_MONTH IN VARCHAR2);
  PROCEDURE 考核表统计(A_MONTH VARCHAR2);
  PROCEDURE 绩效考核统计(A_MONTH VARCHAR2);
  PROCEDURE 产销计划初始化(A_MONTH IN VARCHAR2);
  PROCEDURE 综合月报(A_MONTH IN VARCHAR2);
  --procedure 抄表员绩效(a_month in varchar2) ;
  PROCEDURE 综合月报初始执行(S_MONTH IN VARCHAR2, E_MONTH IN VARCHAR2);
END;
/

