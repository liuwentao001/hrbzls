CREATE OR REPLACE TRIGGER HRBZLS."TUB_RECLISTtemp" BEFORE UPDATE
OF RLID,
 RLSMFID,
 RLCID,
 RLMSMFID,
 RLCSMFID,
 RLCSTATUS,
 RLMSFID,
 RLCALIBER,
 RLRTID,
 RLMSTATUS,
 RLMTYPE,
 RLTRANS,
 RLCD,
 RLYSCHARGETYPE
ON RECLISTtemp FOR EACH ROW
DECLARE
  INTEGRITY_ERROR EXCEPTION;
  ERRNO  INTEGER;
  ERRMSG CHAR(200);
  DUMMY  INTEGER;
  FOUND  BOOLEAN;
  SEQ    NUMBER;
  -- DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "CUSTINFO"
  CURSOR CPK1_RECLIST(VAR_RLCID VARCHAR) IS
    SELECT 1
      FROM CUSTINFO
     WHERE CIID = VAR_RLCID
       AND VAR_RLCID IS NOT NULL;
  -- DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "SYSMANAFRAME"
  CURSOR CPK2_RECLIST(VAR_RLSMFID VARCHAR) IS
    SELECT 1
      FROM SYSMANAFRAME
     WHERE SMFID = VAR_RLSMFID
       AND VAR_RLSMFID IS NOT NULL;
  -- DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "SYSMANAFRAME"
  CURSOR CPK3_RECLIST(VAR_RLCSMFID VARCHAR) IS
    SELECT 1
      FROM SYSMANAFRAME
     WHERE SMFID = VAR_RLCSMFID
       AND VAR_RLCSMFID IS NOT NULL;
  -- DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "SYSMANAFRAME"
  CURSOR CPK4_RECLIST(VAR_RLMSMFID VARCHAR) IS
    SELECT 1
      FROM SYSMANAFRAME
     WHERE SMFID = VAR_RLMSMFID
       AND VAR_RLMSMFID IS NOT NULL;
  -- DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "ACCOUNTCD"
  CURSOR CPK5_RECLIST(VAR_RLCD VARCHAR) IS
    SELECT 1
      FROM ACCOUNTCD
     WHERE ACDID = VAR_RLCD
       AND VAR_RLCD IS NOT NULL;
  -- DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "METERCALIBER"
  CURSOR CPK6_RECLIST(VAR_RLCALIBER NUMBER) IS
    SELECT 1
      FROM METERCALIBER
     WHERE MCID = VAR_RLCALIBER
       AND VAR_RLCALIBER IS NOT NULL;
  -- DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "SYSCUSTSTATUS"
  CURSOR CPK7_RECLIST(VAR_RLCSTATUS VARCHAR) IS
    SELECT 1
      FROM SYSCUSTSTATUS
     WHERE SCSID = VAR_RLCSTATUS
       AND VAR_RLCSTATUS IS NOT NULL;
  -- DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "SYSMETERSTATUS"
  CURSOR CPK8_RECLIST(VAR_RLMSTATUS VARCHAR) IS
    SELECT 1
      FROM SYSMETERSTATUS
     WHERE SMSID = VAR_RLMSTATUS
       AND VAR_RLMSTATUS IS NOT NULL;
  -- DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "SYSREADTYPE"
  CURSOR CPK9_RECLIST(VAR_RLRTID VARCHAR) IS
    SELECT 1
      FROM SYSREADTYPE
     WHERE SRTID = VAR_RLRTID
       AND VAR_RLRTID IS NOT NULL;
  -- DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "SYSCHARGETYPE"
  CURSOR CPK10_RECLIST(VAR_RLYSCHARGETYPE VARCHAR) IS
    SELECT 1
      FROM SYSCHARGETYPE
     WHERE SCTID = VAR_RLYSCHARGETYPE
       AND VAR_RLYSCHARGETYPE IS NOT NULL;
  -- DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "METERSORTFRAME"
  CURSOR CPK11_RECLIST(VAR_RLMSFID VARCHAR) IS
    SELECT 1
      FROM METERSORTFRAME
     WHERE MSFID = VAR_RLMSFID
       AND VAR_RLMSFID IS NOT NULL;
  -- DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "SYSMETERTYPE"
  CURSOR CPK12_RECLIST(VAR_RLMTYPE VARCHAR) IS
    SELECT 1
      FROM SYSMETERTYPE
     WHERE SMTID = VAR_RLMTYPE
       AND VAR_RLMTYPE IS NOT NULL;
  -- DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "ACCOUNTCD"
  CURSOR CPK13_RECLIST(VAR_RLCD VARCHAR) IS
    SELECT 1
      FROM ACCOUNTCD
     WHERE ACDID = VAR_RLCD
       AND VAR_RLCD IS NOT NULL;
  -- DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "RECTRANS"
  CURSOR CPK14_RECLIST(VAR_RLTRANS VARCHAR) IS
    SELECT 1
      FROM RECTRANS
     WHERE RTID = VAR_RLTRANS
       AND VAR_RLTRANS IS NOT NULL;

BEGIN
  IF NVL(FSYSPARA('data'), 'N') = 'Y' THEN
    RETURN;
  END IF;
  SEQ := INTEGRITYPACKAGE.GETNESTLEVEL;
  -- PARENT "CUSTINFO" MUST EXIST WHEN UPDATING A CHILD IN "RECLIST"
  IF (:NEW.RLCID IS NOT NULL) AND (SEQ = 0) THEN
    OPEN CPK1_RECLIST(:NEW.RLCID);
    FETCH CPK1_RECLIST
      INTO DUMMY;
    FOUND := CPK1_RECLIST%FOUND;
    CLOSE CPK1_RECLIST;
    IF NOT FOUND THEN
      ERRNO  := -20003;
      ERRMSG := 'PARENT DOES NOT EXIST IN "CUSTINFO". CANNOT UPDATE CHILD IN "RECLIST".';
      RAISE INTEGRITY_ERROR;
    END IF;
  END IF;

  -- Parent "SYSMANAFRAME" must exist when updating a child in "RECLIST"
  IF (:NEW.RLSMFID IS NOT NULL) AND (SEQ = 0) THEN
    OPEN CPK2_RECLIST(:NEW.RLSMFID);
    FETCH CPK2_RECLIST
      INTO DUMMY;
    FOUND := CPK2_RECLIST%FOUND;
    CLOSE CPK2_RECLIST;
    IF NOT FOUND THEN
      ERRNO  := -20003;
      ERRMSG := 'PARENT DOES NOT EXIST IN "SYSMANAFRAME". CANNOT UPDATE CHILD IN "RECLIST".';
      RAISE INTEGRITY_ERROR;
    END IF;
  END IF;

  -- PARENT "SYSMANAFRAME" MUST EXIST WHEN UPDATING A CHILD IN "RECLIST"
  IF (:NEW.RLCSMFID IS NOT NULL) AND (SEQ = 0) THEN
    OPEN CPK3_RECLIST(:NEW.RLCSMFID);
    FETCH CPK3_RECLIST
      INTO DUMMY;
    FOUND := CPK3_RECLIST%FOUND;
    CLOSE CPK3_RECLIST;
    IF NOT FOUND THEN
      ERRNO  := -20003;
      ERRMSG := 'PARENT DOES NOT EXIST IN "SYSMANAFRAME". CANNOT UPDATE CHILD IN "RECLIST".';
      RAISE INTEGRITY_ERROR;
    END IF;
  END IF;

  -- Parent "SYSMANAFRAME" must exist when updating a child in "RECLIST"
  IF (:NEW.RLMSMFID IS NOT NULL) AND (SEQ = 0) THEN
    OPEN CPK4_RECLIST(:NEW.RLMSMFID);
    FETCH CPK4_RECLIST
      INTO DUMMY;
    FOUND := CPK4_RECLIST%FOUND;
    CLOSE CPK4_RECLIST;
    IF NOT FOUND THEN
      ERRNO  := -20003;
      ERRMSG := 'PARENT DOES NOT EXIST IN "SYSMANAFRAME". CANNOT UPDATE CHILD IN "RECLIST".';
      RAISE INTEGRITY_ERROR;
    END IF;
  END IF;

  -- PARENT "ACCOUNTCD" MUST EXIST WHEN UPDATING A CHILD IN "RECLIST"
  IF (:NEW.RLCD IS NOT NULL) AND (SEQ = 0) THEN
    OPEN CPK5_RECLIST(:NEW.RLCD);
    FETCH CPK5_RECLIST
      INTO DUMMY;
    FOUND := CPK5_RECLIST%FOUND;
    CLOSE CPK5_RECLIST;
    IF NOT FOUND THEN
      ERRNO  := -20003;
      ERRMSG := 'PARENT DOES NOT EXIST IN "ACCOUNTCD". CANNOT UPDATE CHILD IN "RECLIST".';
      RAISE INTEGRITY_ERROR;
    END IF;
  END IF;

  -- Parent "METERCALIBER" must exist when updating a child in "RECLIST"
  IF (:NEW.RLCALIBER IS NOT NULL) AND (SEQ = 0) THEN
    OPEN CPK6_RECLIST(:NEW.RLCALIBER);
    FETCH CPK6_RECLIST
      INTO DUMMY;
    FOUND := CPK6_RECLIST%FOUND;
    CLOSE CPK6_RECLIST;
    IF NOT FOUND THEN
      ERRNO  := -20003;
      ERRMSG := 'PARENT DOES NOT EXIST IN "METERCALIBER". CANNOT UPDATE CHILD IN "RECLIST".';
      RAISE INTEGRITY_ERROR;
    END IF;
  END IF;

  -- PARENT "SYSCUSTSTATUS" MUST EXIST WHEN UPDATING A CHILD IN "RECLIST"
  IF (:NEW.RLCSTATUS IS NOT NULL) AND (SEQ = 0) THEN
    OPEN CPK7_RECLIST(:NEW.RLCSTATUS);
    FETCH CPK7_RECLIST
      INTO DUMMY;
    FOUND := CPK7_RECLIST%FOUND;
    CLOSE CPK7_RECLIST;
    IF NOT FOUND THEN
      ERRNO  := -20003;
      ERRMSG := 'PARENT DOES NOT EXIST IN "SYSCUSTSTATUS". CANNOT UPDATE CHILD IN "RECLIST".';
      RAISE INTEGRITY_ERROR;
    END IF;
  END IF;

  -- Parent "SYSMETERSTATUS" must exist when updating a child in "RECLIST"
  IF (:NEW.RLMSTATUS IS NOT NULL) AND (SEQ = 0) THEN
    OPEN CPK8_RECLIST(:NEW.RLMSTATUS);
    FETCH CPK8_RECLIST
      INTO DUMMY;
    FOUND := CPK8_RECLIST%FOUND;
    CLOSE CPK8_RECLIST;
    IF NOT FOUND THEN
      ERRNO  := -20003;
      ERRMSG := 'PARENT DOES NOT EXIST IN "SYSMETERSTATUS". CANNOT UPDATE CHILD IN "RECLIST".';
      RAISE INTEGRITY_ERROR;
    END IF;
  END IF;

  -- PARENT "SYSREADTYPE" MUST EXIST WHEN UPDATING A CHILD IN "RECLIST"
  IF (:NEW.RLRTID IS NOT NULL) AND (SEQ = 0) THEN
    OPEN CPK9_RECLIST(:NEW.RLRTID);
    FETCH CPK9_RECLIST
      INTO DUMMY;
    FOUND := CPK9_RECLIST%FOUND;
    CLOSE CPK9_RECLIST;
    IF NOT FOUND THEN
      ERRNO  := -20003;
      ERRMSG := 'PARENT DOES NOT EXIST IN "SYSREADTYPE". CANNOT UPDATE CHILD IN "RECLIST".';
      RAISE INTEGRITY_ERROR;
    END IF;
  END IF;

  -- Parent "SYSCHARGETYPE" must exist when updating a child in "RECLIST"
  IF (:NEW.RLYSCHARGETYPE IS NOT NULL) AND (SEQ = 0) THEN
    OPEN CPK10_RECLIST(:NEW.RLYSCHARGETYPE);
    FETCH CPK10_RECLIST
      INTO DUMMY;
    FOUND := CPK10_RECLIST%FOUND;
    CLOSE CPK10_RECLIST;
    IF NOT FOUND THEN
      ERRNO  := -20003;
      ERRMSG := 'PARENT DOES NOT EXIST IN "SYSCHARGETYPE". CANNOT UPDATE CHILD IN "RECLIST".';
      RAISE INTEGRITY_ERROR;
    END IF;
  END IF;

  -- PARENT "METERSORTFRAME" MUST EXIST WHEN UPDATING A CHILD IN "RECLIST"
  IF (:NEW.RLMSFID IS NOT NULL) AND (SEQ = 0) THEN
    OPEN CPK11_RECLIST(:NEW.RLMSFID);
    FETCH CPK11_RECLIST
      INTO DUMMY;
    FOUND := CPK11_RECLIST%FOUND;
    CLOSE CPK11_RECLIST;
    IF NOT FOUND THEN
      ERRNO  := -20003;
      ERRMSG := 'PARENT DOES NOT EXIST IN "METERSORTFRAME". CANNOT UPDATE CHILD IN "RECLIST".';
      RAISE INTEGRITY_ERROR;
    END IF;
  END IF;

  -- Parent "SYSMETERTYPE" must exist when updating a child in "RECLIST"
  IF (:NEW.RLMTYPE IS NOT NULL) AND (SEQ = 0) THEN
    OPEN CPK12_RECLIST(:NEW.RLMTYPE);
    FETCH CPK12_RECLIST
      INTO DUMMY;
    FOUND := CPK12_RECLIST%FOUND;
    CLOSE CPK12_RECLIST;
    IF NOT FOUND THEN
      ERRNO  := -20003;
      ERRMSG := 'PARENT DOES NOT EXIST IN "SYSMETERTYPE". CANNOT UPDATE CHILD IN "RECLIST".';
      RAISE INTEGRITY_ERROR;
    END IF;
  END IF;

  -- PARENT "ACCOUNTCD" MUST EXIST WHEN UPDATING A CHILD IN "RECLIST"
  IF (:NEW.RLCD IS NOT NULL) AND (SEQ = 0) THEN
    OPEN CPK13_RECLIST(:NEW.RLCD);
    FETCH CPK13_RECLIST
      INTO DUMMY;
    FOUND := CPK13_RECLIST%FOUND;
    CLOSE CPK13_RECLIST;
    IF NOT FOUND THEN
      ERRNO  := -20003;
      ERRMSG := 'PARENT DOES NOT EXIST IN "ACCOUNTCD". CANNOT UPDATE CHILD IN "RECLIST".';
      RAISE INTEGRITY_ERROR;
    END IF;
  END IF;

  -- Parent "RECTRANS" must exist when updating a child in "RECLIST"
  /*IF (:NEW.RLTRANS IS NOT NULL) AND (SEQ = 0) THEN
    OPEN CPK14_RECLIST(:NEW.RLTRANS);
    FETCH CPK14_RECLIST
      INTO DUMMY;
    FOUND := CPK14_RECLIST%FOUND;
    CLOSE CPK14_RECLIST;
    IF NOT FOUND THEN
      ERRNO  := -20003;
      ERRMSG := 'PARENT DOES NOT EXIST IN "RECTRANS". CANNOT UPDATE CHILD IN "RECLIST".';
      RAISE INTEGRITY_ERROR;
    END IF;
  END IF;*/

  -- ERRORS HANDLING
EXCEPTION
  WHEN INTEGRITY_ERROR THEN
    RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

