CREATE OR REPLACE TRIGGER HRBZLS."TDB_PAIDTRANS" BEFORE DELETE
ON PAIDTRANS FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
 -- DECLARATION OF DELETEPARENTRESTRICT CONSTRAINT FOR "PAYMENT"
 CURSOR CFK1_PAYMENT(VAR_PTID VARCHAR) IS
 SELECT 1
 FROM PAYMENT
 WHERE PTRANS = VAR_PTID
 AND VAR_PTID IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 -- CANNOT DELETE PARENT "PAIDTRANS" IF CHILDREN STILL EXIST IN "PAYMENT"
 OPEN CFK1_PAYMENT(:OLD.PTID);
 FETCH CFK1_PAYMENT INTO DUMMY;
 FOUND := CFK1_PAYMENT%FOUND;
 CLOSE CFK1_PAYMENT;
 IF FOUND THEN
 ERRNO := -20006;
 ERRMSG := 'CHILDREN STILL EXIST IN "PAYMENT". CANNOT DELETE PARENT "PAIDTRANS".';
 RAISE INTEGRITY_ERROR;
 END IF;


-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

