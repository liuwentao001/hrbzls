CREATE OR REPLACE PACKAGE HRBZLS."PG_METERTRANS" IS

  -- Author  : 王勇
  -- Created : 2009-3-20 10:50:48
  -- Purpose : PG_CUSTCHANGE

  -- Public type declarations
  ERRCODE CONSTANT INTEGER := -20012;

  /*水表状态:总仓、分公司公用属性*/
  --1、库存水表状态
  M待立户   CONSTANT VARCHAR2(2) := '2'; --【分公司】水表出库后没有安装
  M暂拆     CONSTANT VARCHAR2(2) := '3'; --【分公司】欠费拆表后，则处于暂拆
  M新购     CONSTANT VARCHAR2(2) := '4'; --【总仓】、【分公司】新购买的水表
  M报废     CONSTANT VARCHAR2(2) := '5'; --【分公司】报废处理后，为报废
  M待检     CONSTANT VARCHAR2(2) := '6'; --【分公司】水表送检后处于待检状态
  M故障     CONSTANT VARCHAR2(2) := '8'; --【分公司】故障拆表后如果没有送检，水表状态为故障
  M周检到期 CONSTANT VARCHAR2(2) := '9'; --【分公司】周检拆表后如果没有送检，水表状态为周检到期
  M可用老表 CONSTANT VARCHAR2(2) := '10'; --【总仓】、【分公司】经检修后的老表，如果没有报废，入库后状态就为可用老表
  M换表     CONSTANT VARCHAR2(2) := '11'; --【分公司】换表拆表后如果没有送检，水表状态为换表
  M违章     CONSTANT VARCHAR2(2) := '12'; --【分公司】违章拆表后，水表状态为违章
  M报停     CONSTANT VARCHAR2(2) := '13'; --【分公司】报停拆表后，则处于报停
  M暂停     CONSTANT VARCHAR2(2) := '14'; --【分公司】暂停拆表后，则处于暂停
  M遗失     CONSTANT VARCHAR2(2) := '15'; --【分公司】遗失处理后，为遗失
  M总仓出库 CONSTANT VARCHAR2(2) := '17'; --【总仓】总仓配表到分公司后，总仓水表为总仓出库
  M拆迁     CONSTANT VARCHAR2(2) := '16'; --【分公司】拆迁拆表后如果没有送检，为拆迁
  M欠费停水 CONSTANT VARCHAR2(2) := '21'; --【总仓】欠费造成停水

  --2、在装水表状态
  M立户       CONSTANT VARCHAR2(2) := '1'; --【分公司】用户正在使用
  M销户       CONSTANT VARCHAR2(2) := '7'; --【分公司】销户拆表后如果没有送检，则处于销户
  M销户中     CONSTANT VARCHAR2(2) := '19'; --【分公司】销户拆表派工后后完工前
  M口径变更中 CONSTANT VARCHAR2(2) := '20'; --【分公司】口径变更派工后完工前
  M欠费停水中 CONSTANT VARCHAR2(2) := '21'; --【分公司】欠费停水派工后完工前
  M报停中     CONSTANT VARCHAR2(2) := '13';
  M复装中     CONSTANT VARCHAR2(2) := '22'; --【分公司】复装派工后完工前
  M校表中     CONSTANT VARCHAR2(2) := '23'; --【分公司】校表派工后完工前
  M故障换表中 CONSTANT VARCHAR2(2) := '24'; --【分公司】故障换表派工后完工前
  M周检换表中 CONSTANT VARCHAR2(2) := '25'; --【分公司】周检换表派工后完工前
  M复查中     CONSTANT VARCHAR2(2) := '26'; --【分公司】复查派工后完工前
  M升移中     CONSTANT VARCHAR2(2) := '27'; --【分公司】水表升移改造派工后完工前

  --应收事务
  计划抄表   CONSTANT CHAR(1) := '1';
  消防表底度 CONSTANT CHAR(1) := '5';

  营业外收入 CONSTANT CHAR(1) := 'T';
  追量       CONSTANT CHAR(1) := 'O';
  减欠       CONSTANT CHAR(1) := 'V';

  --单据类别,表务类别
  BT立户单 CONSTANT CHAR(1) := 'R';

  BT基础资料变更 CONSTANT CHAR(1) := 'B';
  BT银行信息变更 CONSTANT CHAR(1) := 'C';
  BT过户         CONSTANT CHAR(1) := 'D';
  BT水价变更     CONSTANT CHAR(1) := 'E';
  --
  BT水表升移       CONSTANT CHAR(1) := '3';
  BT水表整改       CONSTANT CHAR(1) := '4';
  BT改装总表       CONSTANT CHAR(2) := 'NA'; --报装类
  BT销户拆表       CONSTANT CHAR(1) := 'F';
  BT口径变更       CONSTANT CHAR(1) := 'G';
  BT欠费停水       CONSTANT CHAR(1) := 'H';
  BT恢复供水       CONSTANT CHAR(1) := '9';
  BT报停           CONSTANT CHAR(1) := '2';
  BT复装           CONSTANT CHAR(1) := 'I';
  BT换阀门         CONSTANT CHAR(1) := 'P';
  BT校表           CONSTANT CHAR(1) := 'A';
  BT故障换表       CONSTANT CHAR(1) := 'K';
  BT周期换表       CONSTANT CHAR(1) := 'L';
  BT复查工单       CONSTANT CHAR(2) := 'NM';
  BT安装分类计量表 CONSTANT CHAR(2) := 'NP'; --报装类
  BT补装户表       CONSTANT CHAR(2) := 'NQ'; --报装类

  --工单审核状态
  未派   CONSTANT CHAR(1) := 'N';
  已派工 CONSTANT CHAR(1) := 'W';
  待解决 CONSTANT CHAR(1) := 'D';
  已解决 CONSTANT CHAR(1) := 'Z';
  完工   CONSTANT CHAR(1) := 'Y';
  退单   CONSTANT CHAR(1) := 'Q';

  PROCEDURE APPROVE(P_BILLNO IN VARCHAR2,
                    P_PERSON IN VARCHAR2,
                    P_BILLID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2);


  --工单主程序
  PROCEDURE SP_METERTRANS(P_TYPE   IN VARCHAR2, --操作类型
                          P_MTHNO  IN VARCHAR2, --批次流水
                          P_PER    IN VARCHAR2, --操作员
                          P_COMMIT IN VARCHAR2 --提交标志
                          );
   --工单主程序-周期换表
  PROCEDURE SP_METERTRANS_ZQHB(P_TYPE   IN VARCHAR2, --操作类型
                          P_MTHNO  IN VARCHAR2, --批次流水
                          P_PER    IN VARCHAR2, --操作员
                          P_COMMIT IN VARCHAR2 --提交标志
                          );
                                                   
  --工单单个审核过程
  PROCEDURE SP_METERTRANSONE(P_TYPE   IN VARCHAR2, --类型
                             P_PERSON IN VARCHAR2, -- 操作员
                             P_MD     IN METERTRANSDT%ROWTYPE --单体行变更
                             );
  --工单派工
  PROCEDURE SP_METEROUT(P_BILLID IN VARCHAR2, --单据流水
                        P_DEPT   IN VARCHAR2, --派工部门
                        P_OPER   IN VARCHAR2, --操作员
                        P_MAN    IN VARCHAR2 --施工员
                        );
  --工单作废
  PROCEDURE SP_METERZF(P_BILLID IN VARCHAR2, --单据流水
                       P_OPER   IN VARCHAR2 --操作员
                       );
  PROCEDURE SP_METERWAITER(P_BILLID IN VARCHAR2, --单据流水
                           P_OPER   IN VARCHAR2 --操作员
                           );
  --工单已解决
  PROCEDURE SP_METEROK(P_BILLID IN VARCHAR2, --单据流水
                       P_OPER   IN VARCHAR2 --操作员
                       );
  --等针处理                      
   PROCEDURE SP_METERDZ(P_BILLID IN VARCHAR2, --单据流水
                     P_OPER   IN VARCHAR2, --操作员
                     P_COMMIT IN VARCHAR2 --提交标志
                     );                    
  --抄表计划批量生成故障换表工单
  PROCEDURE SP_MRMRIFSUBMIT(P_MRID   IN VARCHAR2,
                            P_TYPE   IN VARCHAR2,
                            P_SOURCE IN VARCHAR2,
                            P_SMFID  IN VARCHAR2,
                            P_DEPT   IN VARCHAR2,
                            P_OPER   IN VARCHAR2,
                            P_FLAG   IN VARCHAR2);
  --催收管理批量生成欠费工单
  PROCEDURE SP_CRERECBILL(P_MID    IN VARCHAR2,
                          P_TYPE   IN VARCHAR2,
                          P_SOURCE IN VARCHAR2,
                          P_SMFID  IN VARCHAR2,
                          P_DEPT   IN VARCHAR2,
                          P_OPER   IN VARCHAR2,
                          P_FLAG   IN VARCHAR2);
  --批量生成周检工单
  PROCEDURE SP_BUILDZJBILL(P_NUM    IN VARCHAR2,
                           P_TYPE   IN VARCHAR2,
                           P_SOURCE IN VARCHAR2,
                           P_SMFID  IN VARCHAR2,
                           P_DEPT   IN VARCHAR2,
                           P_OPER   IN VARCHAR2);
  --插入抄表库
  PROCEDURE SP_INSERTMR(P_PPER    IN VARCHAR2, --操作员
                        P_MONTH   IN VARCHAR2, --应收月份
                        P_MRTRANS IN VARCHAR2, --抄表事务
                        P_RLSL    IN NUMBER, --应收水量
                        P_SCODE   IN NUMBER, --起码
                        P_ECODE   IN NUMBER, --止码
                        P_CARRYSL    IN NUMBER, --调整水量
                        MI        IN METERINFO%ROWTYPE, --水表信息
                        OMRID     OUT METERREAD.MRID%TYPE --抄表流水
                        );
   --插入抄表历史库
  PROCEDURE SP_INSERTMRHIS(P_PPER    IN VARCHAR2, --操作员
                        P_MONTH   IN VARCHAR2, --应收月份
                        P_MRTRANS IN VARCHAR2, --抄表事务
                        P_RLSL    IN NUMBER, --应收水量
                        P_SCODE   IN NUMBER, --起码
                        P_ECODE   IN NUMBER, --止码
                        P_CARRYSL    IN NUMBER, --调整水量
                        MI        IN METERINFO%ROWTYPE, --水表信息
                        OMRID     OUT METERREADHIS.MRID%TYPE --抄表流水
                        );
  

END PG_METERTRANS;
/

