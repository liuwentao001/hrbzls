create or replace force view hrbzls.vie_应收冲正查询 as
select distinct
RCHNO 单据流水号,
RCHBH 单据编号,
RCHLB 单据类别,
RCHSOURCE  单据来源,
RCDRCODEFLAG 重置抄表起度,
RCDSCODE 上期抄见,
RCDECODE 本期抄见,
RCDREADSL 抄见水量,
RLSL 应收水量,
((select pddj from pricedetail where pdpfid=RCDPFID and pdpiid='01') +(select pddj from pricedetail where pdpfid=RCDPFID and pdpiid='02')) * RLSL   应收金额,
RCDPFID 用水性质,
(select pddj from pricedetail where pdpfid=RCDPFID and pdpiid='01') 水价,
(select pddj from pricedetail where pdpfid=RCDPFID and pdpiid='02') 污水价,
(select pddj from pricedetail where pdpfid=RCDPFID and pdpiid='03') 附加价,
RCHSMFID 营业所 ,
RCHDEPT 创建部门,
RCHCREDATE  创建日期,
RCHCREPER 创建人员,
RCHSHDATE 单据完成日期,
RCHSHPER  单据完成人员,
RCHSHFLAG 单据完成标志,
RLDATE 账务日期,
rcdflashdate 审核时间 ,
rcdflashflag 审核标志 ,
rcdflashper 审核人,
RCDCNAME 用户名称,
RCDMEMO 备注,
c.MICID 客户代号,
c.miid 水表编号,
c.mipriid 合收表主表号,
c.mibfid 表册,
c.miadr 表地址,
c.miprmon 上期抄表月份,
c.mirmon 本期抄表月份,
decode(c.mitype, '1', '坐收', '走收') 类型,
c.mircode 本期读数,
c.mirecsl 本期抄见水量,
c.mirecdate 本期抄见日期,
decode(c.miifcharge, 'Y', '已计费', '未计费') 计费标志,
decode(c.miifchk, 'Y', '考核表', '非考核表') 考核表标志,
decode(trim(c.miyl2), '0', '普通表', '1', '总表收免', '多级表') 总表收免标志,
c.misaving 预存款余额,
c.miusenum 户籍人数,
c.midbzjh 低保证件号,
decode(c.micolumn4,'GQ','公企','SM','收免','TK','特困', 'GD','定量','PT','普通') 用户性质,
c.mistatus  有效状态,substr(c.mibfid,1,5) 代号,
nvl((select count(*) from xt_ftp_file where substr(report_id,1,10) =RCHNO group by substr(report_id,1,10)),0) 件数,
(select max( kt_operator) from KPI_TASK where report_id=RCHNO ) 接收人
from recczdt a,RECCZHD b,meterinfo c,reclist d
where b.RCHNO=a.rcdno and a.rcdrlid=d.rlid
and RCDCID=c.micid  AND RCHLB='G';

