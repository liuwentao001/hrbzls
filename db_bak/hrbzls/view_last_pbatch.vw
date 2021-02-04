CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_LAST_PBATCH AS
SELECT PMID, max(PBATCH) pbatch FROM PAYMENT
     WHERE     PREVERSEFLAG = 'N'
       AND PTRANS <> 'U'
        GROUP BY PMID;

