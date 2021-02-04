create or replace force view hrbzls.view_inv_swap_ts as
select
padno  PPBATCH,
padrowno  行号,
padchkflag  选中标志,
padpdate  帐务日期,
padpdatetime  发生日期,
padpmonth  缴费月份,
padpposition  缴费地点,
padptrans  缴费事务,
padpcd  借贷方向,
padppayee  收款员,
padpper  销帐人员,
padppayway  付款方式,
padpbatch  缴费交易批次,
padplpid  交易流水号,
padplrlid  应收流水,
padplpfid  价格类别,
padplsl  销帐水量,
padplje  销帐金额,
padplznj  实收违约金,
padplscrplid  冲销原帐流水,
padrlmonth  应收帐月份,
padrldate  应收帐日期,
padmemo  备注,
- padcrsl  减退水量,
- padcrznj  减退滞纳金,
padmrsl  抄表水量,
padmrdate  抄表时间,
padshflag  审核标志,
- padcrje  减退金额,
- padcrje1  减退金额1,
- padcrje2  减退金额2,
- padcrje3  减退金额3,
- padcrje4  减退金额4,
- padcrje5  减退金额5,
- padcrje6  减退金额6,
- padcrje7  减退金额7,
- padnrlid  新应收账id,
padnpid  新实收账id,
padnbatch  新实收批次,
pahbh  单据编号,
pahlb  单据类别,
pahsource  单据来源,
pahsmfid  营业所,
pahdept  创建部门,
pahcredate  创建日期,
pahcreper  创建人员,
pahshdate  审核日期,
pahshper  审核人员,
pahmid  水表编号,
pahmcode  资料号,
pahcname  产权名,
pahmadr  用水地址,
pahmemo  冲正原因,
pahfromsmfid  申请冲正单位,
pahsaveflag  转预存标志,
pahsavetomcode  预存转入的代户代码,
rlmonth  应收月份
from PAIDADJUSTDT,PAIDADJUSTHD
where PADSHFLAG='Y'
AND pahno =padno;

