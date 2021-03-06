CREATE OR REPLACE TRIGGER HRBZLS."TIUDA_PAIDTRANS" AFTER INSERT OR UPDATE OR DELETE
ON PAIDTRANS FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER:=-20002;
 ERRMSG CHAR(200):='报表数据库数据同步异常';
BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 CMDPUSH('pg_report.CopyPaidtrans',NULL);
EXCEPTION WHEN INTEGRITY_ERROR THEN
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

