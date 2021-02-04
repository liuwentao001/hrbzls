CREATE OR REPLACE PROCEDURE HRBZLS."SP_PROCEDURE_RUN_LOG"
   (
   SP_NAME VARCHAR2,---- 存储过程名
   OK_FLAG CHAR,    ---- 成功标志
   ERR_MSG VARCHAR2 ----错误信息
   )
AS
---- 记录存储过程运行日志
BEGIN
   INSERT INTO SYSPROCEDURERUNLOG----记录运行日志
          (
          SPRLENDDATE,SPRLSPNAME,SPRLOKFLAG,SPRLERRMSG,SPRLOTHMSG,
          SPRLIP,SPRLOSUSER,SPRLMACHINE,SPRLSESSIONUSER)
   SELECT SYSDATE,SP_NAME,OK_FLAG,ERR_MSG,
          ' ',SYS_CONTEXT('USERENV','IP_ADDRESS'),SYS_CONTEXT('USERENV','OS_USER'),SYS_CONTEXT

('USERENV','HOST'),
          SYS_CONTEXT('USERENV','SESSION_USER') FROM DUAL;
   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
  NULL;
END;
/

