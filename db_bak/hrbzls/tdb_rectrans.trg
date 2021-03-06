CREATE OR REPLACE TRIGGER HRBZLS."TDB_RECTRANS" BEFORE DELETE
ON RECTRANS FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
 -- DECLARATION OF DELETEPARENTRESTRICT CONSTRAINT FOR "RECLIST"
 CURSOR CFK1_RECLIST(VAR_RTID VARCHAR) IS
 SELECT 1
 FROM RECLIST
 WHERE RLTRANS = VAR_RTID
 AND VAR_RTID IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 -- CANNOT DELETE PARENT "RECTRANS" IF CHILDREN STILL EXIST IN "RECLIST"
 OPEN CFK1_RECLIST(:OLD.RTID);
 FETCH CFK1_RECLIST INTO DUMMY;
 FOUND := CFK1_RECLIST%FOUND;
 CLOSE CFK1_RECLIST;
 IF FOUND THEN
 ERRNO := -20006;
 ERRMSG := 'CHILDREN STILL EXIST IN "RECLIST". CANNOT DELETE PARENT "RECTRANS".';
 RAISE INTEGRITY_ERROR;
 END IF;


-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

