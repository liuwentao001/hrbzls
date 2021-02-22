CREATE OR REPLACE FUNCTION HRBZLS."FCHARGEINVSEARCHHP_NEW_OCX" (p_batch in varchar2,p_modelno in varchar2) return varchar2  is
  --v_invprintstr clob;
v_invprintstr varchar2(32767);
  begin
select  trim(to_char(lengthb( constructhd||constructdt ),'0000000000'))||
        trim(to_char(lengthb( contentstrorder||contentstr ),'0000000000'))||
        constructhd||
        constructdt||
        contentstrorder||
        contentstr into v_invprintstr
          from

   ( select
replace(
connstr(
  trim(c1  )||'^'
||trim(c2  )||'^'
||trim(c3  )||'^'
||trim(c4  )||'^'
||trim(c5  )||'^'
||trim(c6  )||'^'
||trim(c7  )||'^'
||trim(c8  )||'^'
||trim(c9  )||'^'
||trim(c10 )||'^'
||trim(c11 )||'^'
||trim(c12 )||'^'
||trim(c13 )||'^'
||trim(c14 )||'^'
||trim(c15 )||'^'
||trim(c16 )||'^'
||trim(c17 )||'^'
||trim(c18 )||'^'
||trim(c19 )||'^'
||trim(c20 )||'^'
||trim(c21 )||'^'
||trim(c22 )||'^'
||trim(c23 )||'^'
||trim(c24 )||'^'
||trim(c25 )||'^'
||trim(c26 )||'^'
||trim(c27 )||'^'
||trim(c28 )||'^'
||trim(c29 )||'^'
||trim(c30 )||'^'
||trim(c31 )||'^'
||trim(c32 )||'^'
||trim(c33 )||'^'
||trim(c34 )||'^'
||trim(c35 )||'^'
||trim(c36 )||'^'
||trim(c37 )||'^'
||trim(c38 )||'^'
||trim(c39 )||'^'
||trim(c40 )||'^'
||trim(c41 )||'^'
||trim(c42 )||'^'
||trim(c43 )||'^'
||trim(c44 )||'^'
||trim(c45 )||'^'
||trim(c46 )||'^'
||trim(c47 )||'^'
||trim(c48 )||'^'
||trim(c49 )||'^'
||trim(c50 )||'^'
||trim(c51 )||'^'
||trim(c52 )||'^'
||trim(c53 )||'^'
||trim(c54 )||'^'
||trim(c55 )||'^'
||trim(c56 )||'^'
||trim(c57 )||'^'
||trim(c58 )||'^'
||trim(c59 )||'^'
||trim(c60 )
||'|' )
,'|/','|') contentstr
from
(

            select
            max(rlmcode)                                                           C1              ,--���Ϻ�                  C1
            max(rlcname )                                                           C2              ,--����                    C2
            max(rlcadr )                                                            C3              ,--�û���ַ                C3
            min(rlscode )                                                           C4              ,--��������                C4
            max(rlecode )                                                           C5              ,--����ֹ��                C5
            sum(decode(pdpiid,'01',pdsl,0))                                                           C6              ,--Ӧ��ˮ��                C6
            to_char(SYSDATE,'yyyy-mm-dd'  )                                    C7              ,--��ӡ����                C7
            fGetOperName(MAX('c2'))                                                   C8              ,--��ӡԱ                  C8
            max(ppayee)                                          C9              ,--�շ�Ա                  C9
           '    '||tools.fuppernumber(sum(case when pdpiid <>'08' then  pdje else 0 end )  )              C10             ,--�ϼƽ���д            C10
            '��'||/*tools.fformatnum(sum(pdje)+sum(pdznj)+max(PLSAVINGBQ ) ,2)*/ tools.fformatnum(sum(case when pdpiid <>'08' then  pdje else 0 end ),2)                  C11             ,--�ϼƽ��                C11
            fGetPriceText_gtmx(plid)                C12             ,--ˮ����ϸ1               C12
          case when  pdpiid ='08' and pdje<>0 then '������:     ��'||to_char(round(sum(case when pdpiid ='08' then  pdje else 0 end ),2),'0.00')     else '' end            C13             ,--ˮ����ϸ2               C13
            to_char(sysdate ,'yyyy') ||'    '||to_char(sysdate ,'mm')||'    '|| to_char(sysdate ,'dd')||' '                                       C14             ,--ϵͳʱ����              C14
            to_char(max(rldate) ,'mm')                                             C15             ,--ϵͳʱ����              C15
            to_char(max(rldate) ,'dd')                                             C16             ,--ϵͳʱ����              C16
            max(pbatch )                                                            C17             ,----�ɷѽ�������,ϵͳʱ����           C17
            to_char(max(rldate) ,'yyyy')                                                                C18             ,----ʵ������ϸ��ˮ��      C18
            ''                                                             C19             ,--������ˮ��ˮ��          C19
            ''                 C20             ,--Ʊ������ /*Ʊ������*/   C20
            '��������'                                                         C21             ,--ˮ�����                C21
            '����Ա��'                                                         C22             ,--�û����                C22
            max(plrlmonth)                                                         C23             ,--Ӧ�����·�                  C23
            max(rlmadr )                                                         C24             ,--ˮ����װ��ַ            C24
            max(RLBFID)                                                         C25             ,--�����                  C25
            max(RLRPER)                                                         C26             ,--����Ա              C26
            to_char(max(RLDATE),'yyyy-mm-dd')                                                        C27             ,--�ƾ�����                C27
            fGetUnitPrice_mx(max(rlid),'01,02,03,04,05,06,07|',7)                                                   C28             ,--Ӧ�յ���                C28
            fGetUnitMoney_gtmx(plid)                                      C29             ,--ˮ�ѽ��                C29
            '��������'                                                         C30             ,--����                    C30
          TO_CHAR( sum(pdznj),'9990.00')                                                     C31             ,--���ɽ�                  C31
         '�ܼ�:'|| TO_CHAR( SUM(pdje)+sum(pdznj ),'9999999.00')                                                         C32             ,--������                  C32
            ''                                                        C33             ,--���ڳ�������    �����ν�Ǯ��        C33
      '�ϴ�����:'||   replace( tools.fformatnum(max(PLSAVINGQC), 2)   ,'-.','-0.')  /* '�ϴ�����:'||tools.fformatnum(max(PLSAVINGQC),2) */                                                     C34             ,--��������  (�ϴν���)             C34
        '��������:'||   replace( tools.fformatnum(max(PLSAVINGQM), 2)   ,'-.','-0.')   /*'��������:'||tools.fformatnum(max(PLSAVINGQM),2) */                                                      C35             ,--�������� (���ν���)               C35
            '��������'                                                         C36             ,--�����·�                C36
            'Ӧ���ֽ� '||fGetRecZnjMoney_gtmx(plid)                 C37                                                  ,--�ϼ�Ӧ��1                            C37
            '�ֽ�'                                                         C38             ,--�շѷ�ʽ                C38
            '��������'                                                         C39             ,--ˮ����ϸ3               C39
           ''                                                        C40             ,--Ԥ�淢����ϸ            C40
           ''                                  C41             ,--Ӧ�ս���д           C41
          case
             when sum(RLADDSL) > 0 then
              '������' || '������Ϊ' || tools.fformatnum(max(RLADDSL), 0) || '��'

              when max(RLTRANS)='O' then
              '׷���շ�'
             when sum(RLECODE - RLSCODE) <> sum(RLREADSL) then
              '����'
             else
              '��������'
           end                                                           C42             ,--��ע           C42
            'Ӧ�����ɽ�:'||tools.fformatnum(max(PLZNJ),2)                                                       C43             ,--Ӧ�����ɽ�3           C43
            'ʵ�����ɽ�:'||tools.fformatnum(max(PLZNJ),2)                                                        C44             ,--ʵ�����ɽ�4           C44
            'Ӧ��ˮ��:'||tools.fformatnum(max(plje)+max(PLZNJ)-max(PLSAVINGQC),2)                                                        C45             ,--Ӧ��ˮ��5           C45
            'ʵ��ˮ��:'||/*tools.fformatnum(max(PLJE),2)*/tools.fformatnum(sum(pdje)+sum(pdznj)+max(PLSAVINGBQ ) ,2)                                                        C46             ,--ʵ��ˮ��6           C46
            case when max(plcd)='DE' then '' else '���Ʊ' end                                                         C47             ,--�û�Ԥ���ֶ�7           C47
            ''                                                  C48             ,--�û�Ԥ���ֶ�8           C48
            ''                                                         C49             ,--�û�Ԥ���ֶ�9           C49
            ''                                                         C50             ,--�û�Ԥ���ֶ�10          C50
            ''                                                            C51             ,--Ӧ������ˮ��            C51
            ''                            C52             ,--������Ŀ                C52
            MAX('c2')                                                                 C53             ,--��ӡԱ���              C53
            ''                                                       C54             ,--�շ�Ա              C54
            '.'                                                                 C55             ,--���                    C55
            max(PCD )                                                               C56             ,--ϵͳԤ���ֶ�1           C56
            MAX('c3')                                                        C57             ,--ϵͳԤ���ֶ�2           C57
            ''                                                        C58             ,--ϵͳԤ���ֶ�3           C58
            ''                                                         C59             ,--ϵͳԤ���ֶ�4           C59
            ''                                                         C60              --ϵͳԤ���ֶ�5           C60
     from payment,paidlist,paiddetail,reclist/* ,  pbparmtemp*/
   where pid=plpid and
         plid=pdid and
         plrlid=rlid and
         --plpid = C1
         pid = p_batch

         group by plid,pid
UNION

select
            max(NVL(MIPRIID, pmcode))                                                           C1              ,--���Ϻ�                  C1
            max(ciname )                                                           C2              ,--����                    C2
            max(ciadr )                                                            C3              ,--�û���ַ                C3
            case when 0=0 then null else 0 end                                                           C4              ,--��������                C4
            case when 0=0 then null else 0 end                                                            C5              ,--����ֹ��                C5
            case when 0=0 then null else 0 end                                                            C6              ,--Ӧ��ˮ��                C6
            to_char(SYSDATE,'yyyy-mm-dd'  )                                    C7              ,--��ӡ����                C7
            fGetOperName(MAX('c2'))                                                   C8              ,--��ӡԱ                  C8
            max(ppayee)                                          C9              ,--�շ�Ա                  C9
           '��  '|| tools.fuppernumber(sum( decode(pcd,'DE',1,-1)*(ppayment -pchange)))                     C10             ,--�ϼƽ���д            C10
            '��'||tools.fformatnum(sum( decode(pcd,'DE',1,-1)*(ppayment -pchange)) ,2)                     C11             ,--�ϼƽ��                C11
            ''                C12             ,--ˮ����ϸ1               C12
            ''                 C13             ,--ˮ����ϸ2               C13
            to_char(sysdate ,'yyyy') ||'    '||to_char(sysdate ,'mm')||'    '|| to_char(sysdate ,'dd')||' '                                       C14             ,--ϵͳʱ����              C14
            to_char(max(pdatetime) ,'mm')                                             C15             ,--ϵͳʱ����              C15
            to_char(max(pdatetime) ,'dd')                                             C16             ,--ϵͳʱ����              C16
            max(pbatch )                                                            C17             ,----�ɷѽ�������          C17
             to_char(max(pdatetime) ,'yyyy')                                                                C18             ,----ʵ������ϸ��ˮ��      C18
            ''                                                             C19             ,--������ˮ��ˮ��          C19
            ''                 C20             ,--Ʊ������ /*Ʊ������*/   C20
            '��������'                                                         C21             ,--ˮ�����                C21
            '����Ա��'                                                         C22             ,--�û����                C22
            ''                                                         C23             ,--Ӧ�����·�                  C23
            ''                                                         C24             ,--ˮ����װ��ַ            C24
            max(MIBFID)                                                         C25             ,--�����                  C25
            ''                                                         C26             ,--���������              C26
            ''                                                         C27             ,--����ˮ��                C27
            ''                                                           C28             ,--Ӧ�յ���                C28
            ''                                      C29             ,--Ӧ�ս��                C29
            '��������'                                                         C30             ,--����                    C30
            ''                                                       C31             ,--���ɽ�                  C31
            ''                                                         C32             ,--������                  C32
            ''                                                        C33             ,--���ڳ�������    �����ν�Ǯ��        C33 '�ϴν��� '||tools.fformatnum(max(PSAVINGQC),2)
            '����Ԥ��'||tools.fuppernumber(sum( decode(pcd,'DE',1,-1)*(ppayment -pchange)))                                                        C34             ,--��������  (�ϴν���)  '���ν��� '||tools.fformatnum(max(PSAVINGQM),2)            C34
            ''                                                        C35             ,--�������� (���ν���)               C35
            '��������'                                                         C36             ,--�����·�                C36
            ''                 �ϼ�Ӧ��1                                                  ,--�ϼ�Ӧ��1                            C37
            '�ֽ�'                                                         C38             ,--�շѷ�ʽ                C38
            '��������'                                                         C39             ,--ˮ����ϸ3               C39
           ''                                                        C40             ,--Ԥ�淢����ϸ            C40
           ''                                  C41             ,--Ӧ�ս���д           C41
           ''                                                         C42             ,--�û�Ԥ���ֶ�2           C42
            ''                                                       C43             ,--�û�Ԥ���ֶ�3           C43
            ''                                                         C44             ,--�û�Ԥ���ֶ�4           C44
            ''                                                         C45             ,--�û�Ԥ���ֶ�5           C45
            ''                                                         C46             ,--�û�Ԥ���ֶ�6           C46
            ''                                                         C47             ,--�û�Ԥ���ֶ�7           C47
            ''                                                  C48             ,--�û�Ԥ���ֶ�8           C48
            ''                                                         C49             ,--�û�Ԥ���ֶ�9           C49
            ''                                                         C50             ,--�û�Ԥ���ֶ�10          C50
            ''                                                            C51             ,--Ӧ������ˮ��            C51
            ''                            C52             ,--������Ŀ                C52
            MAX('c2')                                                                 C53             ,--��ӡԱ���              C53
            ''                                                       C54             ,--�շ�Ա���              C54
            ''                                                                 C55             ,--���                    C55
            max(PCD )                                                               C56             ,--ϵͳԤ���ֶ�1           C56
            MAX('c3')                                                        C57             ,--ϵͳԤ���ֶ�2           C57
            ''                                                        C58             ,--ϵͳԤ���ֶ�3           C58
            ''                                                         C59             ,--ϵͳԤ���ֶ�4           C59
            MAX(PID)                                                         C60              --ϵͳԤ���ֶ�5           C60
     from payment , /* pbparmtemp,*/custinfo,METERINFO
   where  pmid=miid and
         pcid=ciid and
        -- pid = C1 and
        pid = p_batch and
         PTRANS ='S'
         group by PBATCH
         HAVING sum( decode(pcd,'DE',1,-1)*(ppayment -pchange))<>0

order by c55 ,c60 )
)  a,
(
select
replace(connstr(
trim(t.ptditemno)||'^'||trim(round(t.ptdx ) )||'^'||trim(round(t.ptdy  ))||'^'||trim(round(t.ptdheight ))||'^'||
trim(round(t.ptdwidth ))||'^'||trim(t.ptdfontname)||'^'||trim(t.ptdfontsize*-1)||'^'||trim(t.ptdfontalign)||'|'),'|/','|') constructdt,
 replace(connstr(trim(t.ptditemno)),'/','^')||'|'  contentstrorder
 from printtemplatedt_str t where ptdid= p_modelno
 --2
  ) b,
(
select pthpaperheight||'^'||pthpaperwidth||'^'||lastpage||'^'||1||'|' constructhd  from printtemplatehd t1 where  pthid =p_modelno --2
) c ;
    return v_invprintstr;

  end ;
/
