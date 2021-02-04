CREATE OR REPLACE TRIGGER HRBZLS."TUB_PRICEDETAIL" BEFORE UPDATE
OF PDPSCID,
 PDPFID,
 PDPIID,
 PDMETHOD
ON PRICEDETAIL FOR EACH ROW
DECLARE
 INTEGRITY_ERROR EXCEPTION;
 ERRNO INTEGER;
 ERRMSG CHAR(200);
 DUMMY INTEGER;
 FOUND BOOLEAN;
 SEQ NUMBER;
 -- DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "PRICEFRAME"
 CURSOR CPK1_PRICEDETAIL(VAR_PDPFID VARCHAR) IS
 SELECT 1
 FROM PRICEFRAME
 WHERE PFID = VAR_PDPFID
 AND VAR_PDPFID IS NOT NULL;
 -- DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "PRICEMETHOD"
 CURSOR CPK2_PRICEDETAIL(VAR_PDMETHOD VARCHAR) IS
 SELECT 1
 FROM PRICEMETHOD
 WHERE PMID = VAR_PDMETHOD
 AND VAR_PDMETHOD IS NOT NULL;
 -- DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "PRICEITEM"
 CURSOR CPK3_PRICEDETAIL(VAR_PDPIID VARCHAR) IS
 SELECT 1
 FROM PRICEITEM
 WHERE PIID = VAR_PDPIID
 AND VAR_PDPIID IS NOT NULL;
 -- DECLARATION OF UPDATEPARENTRESTRICT CONSTRAINT FOR "PRICESTEP"
 CURSOR CFK1_PRICESTEP(VAR_PDPFID VARCHAR,
 VAR_PDPIID VARCHAR,
 VAR_PDPSCID NUMBER) IS
 SELECT 1
 FROM PRICESTEP
 WHERE PSPFID = VAR_PDPFID
 AND PSPIID = VAR_PDPIID
 AND PSPSCID = VAR_PDPSCID
 AND VAR_PDPFID IS NOT NULL
 AND VAR_PDPIID IS NOT NULL
 AND VAR_PDPSCID IS NOT NULL;
 -- DECLARATION OF UPDATEPARENTRESTRICT CONSTRAINT FOR "RECDETAIL"
 CURSOR CFK2_RECDETAIL(VAR_PDPFID VARCHAR,
 VAR_PDPIID VARCHAR,
 VAR_PDPSCID NUMBER) IS
 SELECT 1
 FROM RECDETAIL
 WHERE RDPFID = VAR_PDPFID
 AND RDPIID = VAR_PDPIID
 AND RDPSCID = VAR_PDPSCID
 AND VAR_PDPFID IS NOT NULL
 AND VAR_PDPIID IS NOT NULL
 AND VAR_PDPSCID IS NOT NULL;

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
 SEQ := INTEGRITYPACKAGE.GETNESTLEVEL;
 -- PARENT "PRICEFRAME" MUST EXIST WHEN UPDATING A CHILD IN "PRICEDETAIL"
 IF (:NEW.PDPFID IS NOT NULL) AND (SEQ = 0) THEN
 OPEN CPK1_PRICEDETAIL(:NEW.PDPFID);
 FETCH CPK1_PRICEDETAIL INTO DUMMY;
 FOUND := CPK1_PRICEDETAIL%FOUND;
 close CPK1_PRICEDETAIL;
 if not found then
 errno := -20003;
 errmsg := 'PARENT DOES NOT EXIST IN "PRICEFRAME". CANNOT UPDATE CHILD IN "PRICEDETAIL".';
 raise integrity_error;
 end if;
 end if;

 -- Parent "PRICEMETHOD" must exist when updating a child in "PRICEDETAIL"
 if (:new.PDMETHOD is not null) and (seq = 0) then
 open CPK2_PRICEDETAIL(:new.PDMETHOD);
 fetch CPK2_PRICEDETAIL into dummy;
 found := CPK2_PRICEDETAIL%FOUND;
 CLOSE CPK2_PRICEDETAIL;
 IF NOT FOUND THEN
 ERRNO := -20003;
 ERRMSG := 'PARENT DOES NOT EXIST IN "PRICEMETHOD". CANNOT UPDATE CHILD IN "PRICEDETAIL".';
 RAISE INTEGRITY_ERROR;
 END IF;
 END IF;

 -- PARENT "PRICEITEM" MUST EXIST WHEN UPDATING A CHILD IN "PRICEDETAIL"
 IF (:NEW.PDPIID IS NOT NULL) AND (SEQ = 0) THEN
 OPEN CPK3_PRICEDETAIL(:NEW.PDPIID);
 FETCH CPK3_PRICEDETAIL INTO DUMMY;
 FOUND := CPK3_PRICEDETAIL%FOUND;
 close CPK3_PRICEDETAIL;
 if not found then
 errno := -20003;
 errmsg := 'PARENT DOES NOT EXIST IN "PRICEITEM". CANNOT UPDATE CHILD IN "PRICEDETAIL".';
 raise integrity_error;
 end if;
 end if;

 -- Cannot modify parent code in "PRICEDETAIL" if children still exist in "PRICESTEP"
 if (updating('PDPFID') and :old.PDPFID != :new.PDPFID) or
 (updating('PDPIID') and :old.PDPIID != :new.PDPIID) or
 (updating('PDPSCID') and :old.PDPSCID != :new.PDPSCID) then
 open CFK1_PRICESTEP(:old.PDPFID,
 :old.PDPIID,
 :old.PDPSCID);
 fetch CFK1_PRICESTEP into dummy;
 found := CFK1_PRICESTEP%FOUND;
 CLOSE CFK1_PRICESTEP;
 IF FOUND THEN
 ERRNO := -20005;
 ERRMSG := 'CHILDREN STILL EXIST IN "PRICESTEP". CANNOT MODIFY PARENT CODE IN "PRICEDETAIL".';
 RAISE INTEGRITY_ERROR;
 END IF;
 END IF;

 -- CANNOT MODIFY PARENT CODE IN "PRICEDETAIL" IF CHILDREN STILL EXIST IN "RECDETAIL"
 IF (UPDATING('PDPFID') AND :OLD.PDPFID != :NEW.PDPFID) OR
 (UPDATING('PDPIID') AND :OLD.PDPIID != :NEW.PDPIID) OR
 (UPDATING('PDPSCID') AND :OLD.PDPSCID != :NEW.PDPSCID) THEN
 OPEN CFK2_RECDETAIL(:OLD.PDPFID,
 :OLD.PDPIID,
 :OLD.PDPSCID);
 FETCH CFK2_RECDETAIL INTO DUMMY;
 FOUND := CFK2_RECDETAIL%FOUND;
 CLOSE CFK2_RECDETAIL;
 IF FOUND THEN
 ERRNO := -20005;
 ERRMSG := 'CHILDREN STILL EXIST IN "RECDETAIL". CANNOT MODIFY PARENT CODE IN "PRICEDETAIL".';
 RAISE INTEGRITY_ERROR;
 END IF;
 END IF;


-- ERRORS HANDLING
EXCEPTION
 WHEN INTEGRITY_ERROR THEN
 RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

