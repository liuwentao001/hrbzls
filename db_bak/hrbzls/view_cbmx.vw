create or replace force view hrbzls.view_cbmx as
select mrmcode,
       ciname,
       ciadr,
       mrmonth,
       mrsmfid,
       mrbfid,
       mrreadok,
       mrrdate,
       mrrper,
       mrscode,
       mrecode,
       mrsl,
       mrface,
       mrifrec,
       mrrecdate,
       mrrecsl,
       mraddsl,
       mrprimid,
       mrinputper,
       mrpfid,
       mrcaliber,
       mrlastsl,
       mrthreesl,
       mryearsl,
       mrcid,
       mrside,
       mrsafid,
       mrrorder,
       miuiid,
       michargetype,
       migps,
       mrid,
       misafid,
       mibfid,
       MRPRDATE
  from view_meterreadall, custinfo, meterinfo
 where mrcid = ciid
   and micode = MRMCODE;

