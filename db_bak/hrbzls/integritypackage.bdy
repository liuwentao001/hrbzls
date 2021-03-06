CREATE OR REPLACE PACKAGE BODY HRBZLS."INTEGRITYPACKAGE" AS
 NESTLEVEL NUMBER;

-- PROCEDURE TO INITIALIZE THE TRIGGER NEST LEVEL
 PROCEDURE INITNESTLEVEL IS
 BEGIN
 NESTLEVEL := 0;
 END;


-- FUNCTION TO RETURN THE TRIGGER NEST LEVEL
 FUNCTION GETNESTLEVEL RETURN NUMBER IS
 BEGIN
 IF NESTLEVEL IS NULL THEN
     NESTLEVEL := 0;
 END IF;
 RETURN(NESTLEVEL);
 END;

-- PROCEDURE TO INCREASE THE TRIGGER NEST LEVEL
 PROCEDURE NEXTNESTLEVEL IS
 BEGIN
 IF NESTLEVEL IS NULL THEN
     NESTLEVEL := 0;
 END IF;
 NESTLEVEL := NESTLEVEL + 1;
 END;

-- PROCEDURE TO DECREASE THE TRIGGER NEST LEVEL
 PROCEDURE PREVIOUSNESTLEVEL IS
 BEGIN
 NESTLEVEL := NESTLEVEL - 1;
 END;

 END INTEGRITYPACKAGE;
/

