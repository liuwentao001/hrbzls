CREATE OR REPLACE TRIGGER HRBZLS."TDB_OPERROLE" BEFORE DELETE
ON OPERROLE FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
 -- DECLARATION OF DELETEPARENTRESTRICT CONSTRAINT FOR "OPERACCNTROLE"
 CURSOR CFK1_OPERACCNTROLE(VAR_ORID VARCHAR) IS
 SELECT 1
 FROM OPERACCNTROLE
 WHERE OARRID = VAR_ORID
 AND VAR_ORID IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 -- CANNOT DELETE PARENT "OPERROLE" IF CHILDREN STILL EXIST IN "OPERACCNTROLE"
 OPEN CFK1_OPERACCNTROLE(:OLD.ORID);
 FETCH CFK1_OPERACCNTROLE INTO DUMMY;
 FOUND := CFK1_OPERACCNTROLE%FOUND;
 CLOSE CFK1_OPERACCNTROLE;
 IF FOUND THEN
 ERRNO := -20006;
 ERRMSG := '存在下级关联用户，不能删除角色';
 RAISE INTEGRITY_ERROR;
 END IF;


-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

