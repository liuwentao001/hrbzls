create or replace force view hrbzls.vie_变更管理_合收表维护 as
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'合收表维护：证件类型'  变更对象,decode(t3.ciidentitylb,'NULL','无','1','身份证','2','驾驶证') 变更前,decode(t2.ciidentitylb,'NULL','无','1','身份证','2','驾驶证') 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.ciidentitylb IS NOT NULL AND t3.ciidentitylb IS NOT NULL AND t2.ciidentitylb <> t3.ciidentitylb) OR (t2.ciidentitylb IS NULL AND t3.ciidentitylb IS NOT NULL) OR (t2.ciidentitylb IS NOT NULL AND t3.ciidentitylb IS NULL))
and t1.cchlb='Y'
---证件类型
---证件号码
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'合收表维护：证件号码'  变更对象,t3.ciidentityno 变更前,t2.ciidentityno 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.ciidentityno IS NOT NULL AND t3.ciidentityno IS NOT NULL AND t2.ciidentityno <> t3.ciidentityno) OR (t2.ciidentityno IS NULL AND t3.ciidentityno IS NOT NULL) OR (t2.ciidentityno IS NOT NULL AND t3.ciidentityno IS NULL))
and t1.cchlb='Y'
---合收表标志
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'合收表维护：合收表标志'  变更对象,decode(t3.mipriflag,'Y','是','N','否') 变更前,decode(t2.mipriflag,'Y','是','N','否') 变更后,'Y' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.mipriflag IS NOT NULL AND t3.mipriflag IS NOT NULL AND t2.mipriflag <> t3.mipriflag) OR (t2.mipriflag IS NULL AND t3.mipriflag IS NOT NULL) OR (t2.mipriflag IS NOT NULL AND t3.mipriflag IS NULL))
and t1.cchlb='Y'
---合收主表号
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'合收表维护：合收主表号'  变更对象,t3.mipriid 变更前,t2.mipriid 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.mipriid IS NOT NULL AND t3.mipriid IS NOT NULL AND t2.mipriid <> t3.mipriid) OR (t2.mipriid IS NULL AND t3.mipriid IS NOT NULL) OR (t2.mipriid IS NOT NULL AND t3.mipriid IS NULL))
and t1.cchlb='Y'

---备注信息
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'合收表维护：备注信息'  变更对象,t3.mimemo 变更前, t2.mimemo 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.mimemo IS NOT NULL AND t3.mimemo IS NOT NULL AND t2.mimemo <> t3.mimemo) OR (t2.mimemo IS NULL AND t3.mimemo IS NOT NULL) OR (t2.mimemo IS NOT NULL AND t3.mimemo IS NULL))
and t1.cchlb='Y'
;

