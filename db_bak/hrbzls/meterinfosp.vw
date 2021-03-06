CREATE OR REPLACE FORCE VIEW HRBZLS.METERINFOSP AS
SELECT MI.MIID,
       MI.MINAME,
       MI.MIADR,
       MI.MIIFTAX,
       NVL(TI.TINAME, NVL(TV.TINAME, MI.MINAME)) TINAME,
       NVL(TI.TITAXCODE, NVL(TV.TITAXCODE, MI.MITAXNO)) TITAXCODE,
       NVL(TI.TIADDR, NVL(TV.TIADDR, CI.Ciadr)) TIADDR,
       NVL(TI.TITEL, NVL(TV.TITEL, CI.CITEL1)) TITEL,
       NVL(TI.TIMTEL, NVL(TV.TIMTEL, CI.CIMTEL)) TIMTEL,
       NVL(TI.TIBANK, NVL(TV.TIBANK, MI.MIBANKNAME)) TIBANK,
       NVL(TI.TIBANKACC, NVL(TV.TIBANKACC, MI.MIBANKNO)) TIBANKACC,
       NVL(NVL(TI.TITYPE, TV.TITYPE), '04') TITYPE,
       NVL(TI.TIEMAIL, NVL(TV.TIEMAIL, MI.MIEMAIL)) TIEMAIL,
       NVL(TI.TIFPTNO, TV.TIFPTNO) TIFPTNO,
       NVL(TI.TIMEMO, TV.TIMEMO) TIMEMO
  FROM CUSTINFO CI, METERINFO MI
  LEFT JOIN TAXCODEINFO_MIID TM
    ON MI.MIID = TM.MIID
  LEFT JOIN TAXCODEINFO TI
    ON TM.TIID = TI.TIID
  LEFT JOIN TAXMETERINV TV
    ON MI.MIID = TV.TIMID
 WHERE CI.CIID = MI.MICID;

