CREATE OR REPLACE PROCEDURE HRBZLS."SP_SEQLIST"
IS
BEGIN
 DELETE SYSSEQLIST;
 INSERT INTO SYSSEQLIST
 SELECT SUBSTR(OBJECT_NAME,5),
 OBJECT_NAME,
 NULL,
 10,
 SUBSTR(OBJECT_NAME,5),
 1000000000
 FROM USER_OBJECTS WHERE OBJECT_TYPE='SEQUENCE';
 COMMIT;
EXCEPTION WHEN OTHERS THEN
 RAISE;
END SP_SEQLIST;
/

