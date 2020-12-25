﻿create or replace package body pg_cb_cost is
  callogtxt clob;
  最低算费水量        number(10);
  总表截量            char(1);
  是否审批算费        char(1);
  分账操作            char(1);
  算费时预存自动销账  char(1);
  
  procedure wlog(p_txt in varchar2) is
  begin
    callogtxt := callogtxt || chr(10) || to_char(sysdate, 'mm-dd hh24:mi:ss >> ') || p_txt;
  end;
  
  --外部调用，自动算费
  procedure autosubmit is
    vlog clob;
  begin
    for i in (select mrbfid from bs_meterread
               where mrreadok = 'Y' and mrifrec = 'N'
               group by mrsmfid, mrbfid) loop
      submit(i.mrbfid , vlog);
    end loop;
  exception
    when others then raise;
  end;
  
  --计划内抄表提交算费
  procedure submit(p_mrbfid in varchar2, log out clob) is
    cursor c_mr(vbfid in varchar2) is
    select mrid
      from bs_meterread, bs_meterinfo
     where mrmid = miid
       and mrbfid = vbfid
       and bs_meterinfo.mistatus not in ('24', '35', '36', '19') --算费时，故障换表中、周期换表中、预存冲销中、销户中的不进行算费,需把故障换表中、周期换表中单据审核完才能算费 20140628
       and mrifrec = 'N' --抄见状态
     order by miclass desc,(case when mipriflag = 'Y' and miid <> mipid then 1 else 2 end) asc;
     vmrid bs_meterread.mrid%type;
  begin
    callogtxt := null;
    wlog('正在算费表册号：' || p_mrbfid || ' ...');
    open c_mr(p_mrbfid);
    loop
      fetch c_mr into vmrid;
      exit when c_mr%notfound or c_mr%notfound is null;
      --单条抄表记录处理
      begin
        calculate(vmrid);
        commit;
      exception
        when others then rollback; wlog('抄表记录' || vmrid || '算费失败，已被忽略');
      end;
    end loop;
    close c_mr;
    wlog('算费过程处理完毕');
    log := callogtxt;
  exception
    when others then
      rollback;
      log := callogtxt;
      if c_mr%isopen then close c_mr; end if;
      raise_application_error(errcode, sqlerrm);
  end;
  
  --计划抄表单笔算费
  procedure calculate(p_mrid in bs_meterread.mrid%type) is
   cursor c_mr is
      select * from bs_meterread
       where mrid = p_mrid
         and mrifrec = 'N'   --已计费(Y-是 N-否)
         and mrsl >= 0 
         for update nowait;
   cursor c_mr_child(p_mpid in varchar2, p_month in varchar2) is
      select mrsl, mrifrec, mrreadok, nvl(mrcarrysl, 0) mrcarrysl --校验水量
        from bs_meterinfo, bs_meterread
       where mrmid = miid
         and mipid = p_mpid
         and mrmonth = p_month
      union all
      select mrsl, mrifrec, mrreadok, nvl(mrcarrysl, 0) mrcarrysl
        from bs_meterinfo, bs_meterread_his, bs_reclist
       where mrmid = miid
         and mrid = rlmrid
         and mipid = p_mpid
         and mrmonth = p_month
         and (mrdatasource = 'M' or mrdatasource = 'L') --周期换表、故障换表
         and rlreverseflag = 'N';
    --一户多表用户信息zhb
    cursor c_mr_pr(p_mipriid in varchar2) is
      select miid
        from bs_meterinfo, bs_meterread
       where mrmid(+) = miid
         and mipid = p_mipriid
       order by miid;
    --合收子表抄表记录
    cursor c_mr_pri(p_primcode in varchar2) is
      select mrsl, mrifrec, mrmid
        from bs_meterinfo, bs_meterread
       where mrmid = miid
         and mipriflag = 'Y'
         and mipid = p_primcode
         and micode <> p_primcode;
    --取合收表信息
    cursor c_mi(p_mid in varchar2) is
      select * from bs_meterinfo where miid = p_mid;
    --总表有周期换表、故障换表的余量抓取 
    cursor c_mi_class(p_mrmid in varchar2, p_month in varchar2) is
      select nvl(decode(nvl(sum(mraddsl), 0), 0, sum(mrsl), sum(mraddsl)),0)
        from bs_meterinfo, bs_meterread_his, bs_reclist
       where mrmid = miid
         and mrid = rlmrid
         and mrmid = p_mrmid
         and mrmonth = p_month
         and (mrdatasource = 'M' or mrdatasource = 'L') --周期换表、故障换表
         and rlreverseflag = 'N' --未冲正
         and rlsl > 0;
    mr         bs_meterread%rowtype;
    mrchild    bs_meterread%rowtype;
    mi         bs_meterinfo%rowtype;
    mrl        bs_meterread%rowtype;
    mil        bs_meterinfo%rowtype;
    mid        bs_meterinfo.miid%type;
    v_tempsl   number;
    v_count    number;
    v_row      number;
    v_sumnum      number; --子表数
    v_readnum     number; --抄见子表数
    v_recnum      number; --算费子表数
    v_miclass     number;
    v_mipid       varchar2(10);
    v_mrmcode     varchar2(10);
    v_mdhis_addsl bs_meterread_his.mraddsl%type;
    v_pd_addsl    bs_meterread_his.mraddsl%type;
  begin
    
    open c_mr;
    fetch c_mr into mr;
    if c_mr%notfound or c_mr%notfound is null then
      raise_application_error(errcode, '无效的抄表计划流水号');
    end if;
    --抄表数据来源  1表示计划抄表   5表示远传抄表   9表示抄表机抄表
    if mr.mrsl < 最低算费水量 and mr.mrdatasource in ('1', '5', '9', '2') /*and (mr.mrrpid = '00' or mr.mrrpid is null) --计件类型*/ then
      raise_application_error(errcode, '抄表水量小于最低算费水量，不需要算费');
    end if;
    
   --水表记录
    open c_mi(mr.mrmid);
    fetch c_mi into mi;
    if c_mi%notfound or c_mi%notfound is null then
      wlog('无效的水表编号' || mr.mrmid);
      raise_application_error(errcode, '无效的水表编号' || mr.mrmid);
    end if;
    close c_mi;
  
    if mi.mistatus = '24' and mr.mrdatasource <> 'm' then
      --如果表状态为故障换表中且此抄表记录来源不是故障抄表余量，则提示不能算费，有故障换表
      wlog('此水表编号正在故障换表中,不能进行算费,如需算费请先审核故障换表或删除故障换表单据.' || mr.mrmid);
      raise_application_error(errcode, '此水表编号[' || mr.mrmid ||']正在故障换表中,不能进行算费,如需算费请先审核故障换表或删除故障换表单据.');
    end if;
    if mi.mistatus = '35' and mr.mrdatasource <> 'l' then
      --如果表状态为周期换表中且此抄表记录来源不是周期抄表余量，则提示不能算费，有周期换表
      wlog('此水表编号正在周期换表中,不能进行算费,如需算费请先审核周期换表或删除周期换表单据.' || mr.mrmid);
      raise_application_error(errcode,'此水表编号[' || mr.mrmid ||']正在周期换表中,不能进行算费,如需算费请先审核周期换表或删除周期换表单据.');
    end if;
    if mi.mistatus = '36' then
      --预存冲正中
      wlog('此水表编号正在预存冲正中,不能进行算费,如需算费请先审核预存冲正或删除预存冲正单据.' || mr.mrmid);
      raise_application_error(errcode, '此水表编号[' || mr.mrmid || ']正在预存冲正中,不能进行算费,如需算费请先审核预存冲正或删除预存冲正单据.');
    end if;
    if mi.mistatus = '39' then
      --预存冲正中
      wlog('此水表编号正在预存撤表退费中,不能进行算费,如需算费请先审核或删除预存冲正单据.' || mr.mrmid);
      raise_application_error(errcode, '此水表编号[' || mr.mrmid ||']正在预存冲正中,不能进行算费,如需算费请先审核或删除预存冲正单据.');
    end if;
    if mi.mircode <> mr.mrscode and mr.mrdatasource not in ('m','l') then
       --水表起码已经改变
       wlog('此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！' || mr.mrmid);
       raise_application_error(errcode,'此水表编号[' || mr.mrmid || ']此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！');
    end if;
    if mi.mistatus = '19' then
      --销户中
      wlog('此水表编号正在销户中,不能进行算费,如需算费请先审核销户单据或删除销户单据.' || mr.mrmid);
      raise_application_error(errcode, '此水表编号[' || mr.mrmid || ']正在销户中,不能进行算费,如需算费请先审核销户或删除销户单据.');
    end if;

    mr.mrrecsl := mr.mrsl; --本期水量
    -----------------------------------------------------------------------------
    --子表水量抵减计费总表抄见水量
    -----------------------------------------------------------------------------
    if 总表截量 = 'Y' then
      --######总分表算费   20140412 BY HK#######
      /*
      规则：
      1、同一表册，分表先算费，算费同普通表
      2、总表需要先判断分表是否都已算费，分表全算费了才允许总表算费
      3、总表按总表截量算费（总表抄见 - 分表抄见和），如果总表截量小于0，则总表不算费
      */
      --MICLASS：普通表=1，总表=2，分表=3
      --STEP1 检查是否总表
      select miclass, mipid into v_miclass, v_mipid from bs_meterinfo where micode = mr.mrmid;
      if v_miclass = 2 then
        --是总表
        v_mrmcode := mr.mrmid; --赋值为总表号
        --step2 判断总表下的分表中是否存在未抄子表 （子表未月初或未抄见）和未算费子表
        select count(*),
               sum(decode(nvl(mrreadok, 'N'), 'Y', 1, 0)),
               sum(decode(nvl(mrifrec, 'N'), 'Y', 1, 0))
          into v_sumnum, v_readnum, v_recnum
          from bs_meterinfo, bs_meterread
         where miid = mrmid(+)
           and mipid = v_mrmcode
           and miclass = '3';
        --如果子表数和大于子表已抄见数和，则存在未抄子表
        if v_sumnum > v_readnum then
          wlog('抄表记录' || mr.mrid || '总分表中包含未抄子表，暂停产生费用');
          raise_application_error(errcode,'总分表中包含未抄子表，暂停产生费用');
        end if;
        --总分表分表已抄见就让算费
        --如果子表数和大于子表已算费数和，则存在未算费子表
        if v_sumnum > v_recnum then
          wlog('抄表记录' || mr.mrid || '收费总表发现子表未计费，暂停产生费用');
          raise_application_error(errcode, '收费总表子表未计费，暂停产生费用');
        end if;
        --总表本月抄表产生账务明细时,抓取本月是否有做故障换表，有的话抓取故障换表余量
        open c_mi_class(v_mrmcode, mr.mrmonth);
        fetch c_mi_class
          into v_mdhis_addsl; --故障换表余量
        if c_mi_class%notfound or c_mi_class%notfound is null then
          v_mdhis_addsl := 0;
        end if;
        close c_mi_class;
      
        v_pd_addsl := v_mdhis_addsl; --判断水量=故障换表余量
      
        open c_mr_child(v_mrmcode, mr.mrmonth);
        loop
          fetch c_mr_child
            into mrchild.mrsl,
                 mrchild.mrifrec,
                 mrchild.mrreadok,
                 mrchild.mrcarrysl;
          exit when c_mr_child%notfound or c_mr_child%notfound is null;
          --判断的水量 v_pd_addsl 实际为故障换表水量
          v_pd_addsl := v_pd_addsl - mrchild.mrsl - mrchild.mrcarrysl;
          --总表故障换表水量 =总表故障换表水量 -子表抄表水量 - 子表校验水量
        end loop;
        close c_mr_child;
      
        if v_pd_addsl < 0 then
          --下述包含三种情况
          --1总表换表时 余量-分表总出账 小于0时不出账   不出账
          --2总表抄见时,如果有故障换表 则抄见水量=抄见水量+换表余量 -分表总出账   出账
          --3 总表故障换表 、分表出账后水量够减， 总表出账
          mr.mrrecsl := mr.mrrecsl + v_mdhis_addsl;
          --step3 判断总分表收费总表水量是否小于子表水量
          --取正常子表水量算截量
          open c_mr_child(v_mrmcode, mr.mrmonth);
          loop
            fetch c_mr_child
              into mrchild.mrsl,
                   mrchild.mrifrec,
                   mrchild.mrreadok,
                   mrchild.mrcarrysl;
            exit when c_mr_child%notfound or c_mr_child%notfound is null;
            --抵消水量
            mr.mrrecsl := mr.mrrecsl - mrchild.mrsl - mrchild.mrcarrysl;
            --总表应收水量 =总表抄表水量 -子表抄表水量 - 子表校验水量 
          end loop;
          close c_mr_child;
        else
          --4  总表本月有做故障换表，故障换表余量大于分表总量时，总表再次做抄表，出账水量就等于总表抄见水量
          mr.mrrecsl := mr.mrrecsl;
        end if;
        --如果收费总表水量小于子表水量，暂停产生费用
        if mr.mrrecsl < 0 then
          --如果总表截量小于0，则总表停算费用
          wlog('抄表记录' || mr.mrid || '收费总表水量小于子表水量，暂停产生费用');
          raise_application_error(errcode, '收费总表水量小于子表水量，暂停产生费用');
        end if;
      end if;
    end if;
    -----------------------------------------------------------------------------
    --判断一表多户 分表按比例分摊水量
    if /*mi.micolumn9 = 'Y'*/ 1>1 then
      open c_mr_pr(mr.mrmid);
      v_tempsl := mr.mrsl;
      v_row    := 1;
      select count(*)
        into v_count
        from bs_meterinfo
       where mipid = mr.mrmid
       --  and fchkmeterneedcharge(mistatus, miifchk, mitype) = 'Y'
       --order by micolumn6
       ;
      loop
        fetch c_mr_pr
          into mid;
        exit when c_mr_pr%notfound or c_mr_pr%notfound is null;
        mrl := mr;
        select * into mil from bs_meterinfo where miid = mid;
        mrl.mrsmfid := mil.mismfid;
        mrl.mrccode   := mil.micode;
        mrl.mrmid   := mil.miid;
        mrl.mrccode := mil.micode;
        mrl.mrbfid  := mil.mibfid;
        mrl.mrrecsl := trunc(v_tempsl);
        v_tempsl    := v_tempsl - mrl.mrrecsl;
        v_row       := v_row + 1;
        if mrl.mrifrec = 'Y' and --mrl.mrifsubmit = 'Y' and
           mrl.mrifhalt = 'Y' and mil.miifcharge = 'Y' and
           fchkmeterneedcharge(mil.mistatus, mil.miifchk, '1') = 'Y' then
           null;
          --正常算费
          calculate(mrl, '1', '0000.00');
        elsif mil.miifcharge = 'Y' or mrl.mrifhalt = 'Y' then
          --计量不计费,将数据记录到费用库
          --calculatenp(mrl, '1', '0000.00');
          null;
        end if;
      end loop;
      mr.mrifrec   := 'Y';
      mr.mrrecdate := trunc(sysdate);
      if c_mr_pr%isopen then
        close c_mr_pr;
      end if;
    else
      if mr.mrifrec = 'N' and --mr.mrifsubmit = 'Y' and
         mr.mrifhalt = 'N' and mi.miifcharge = 'Y' and
         fchkmeterneedcharge(mi.mistatus, mi.miifchk, '1') = 'Y' then
        --正常算费
        calculate(mr, '1', '0000.00');
      elsif mi.miifcharge = 'N' or mr.mrifhalt = 'Y' then
        --计量不计费,将数据记录到费用库
        calculatenp(mr, '1', '0000.00');
      end if;
    end if;
    -----------------------------------------------------------------------------
    --更新当前抄表记录
    if 是否审批算费 = 'N' then
      update bs_meterread
         set mrifrec   = mr.mrifrec,
             mrrecdate = mr.mrrecdate,
             mrrecsl   = mr.mrrecsl,
             mrrecje01 = mr.mrrecje01,
             mrrecje02 = mr.mrrecje02,
             mrrecje03 = mr.mrrecje03,
             mrrecje04 = mr.mrrecje04
       where current of c_mr;
    else
      update bs_meterread
         set mrrecdate = mr.mrrecdate,
             mrrecsl   = mr.mrrecsl,
             mrrecje01 = mr.mrrecje01,
             mrrecje02 = mr.mrrecje02,
             mrrecje03 = mr.mrrecje03,
             mrrecje04 = mr.mrrecje04
       where current of c_mr;
    end if;
    close c_mr;
  exception
    when others then
      if c_mr_pr%isopen then close c_mr_pr; end if;
      if c_mr_pri%isopen then close c_mr_pri; end if;
      if c_mr_child%isopen then close c_mr_child; end if;
      if c_mr%isopen then close c_mr; end if;
      if c_mi%isopen then close c_mi; end if;
      if c_mi_class%isopen then close c_mi_class; end if;
      raise_application_error(errcode, sqlerrm);
  end;
  
  procedure calculate(mr in out bs_meterread%rowtype,p_trans in char, p_ny    in varchar2) is
    cursor c_mi(vmiid in bs_meterinfo.miid%type) is select * from bs_meterinfo where miid = vmiid for update;
    cursor c_ci(vciid in bs_custinfo.ciid%type) is select * from bs_custinfo where ciid = vciid for update;
    cursor c_md(vmiid in bs_meterdoc.mdid%type) is select * from bs_meterdoc where mdid = vmiid for update;
    cursor c_pd(vpfid in bs_pricedetail.pdpfid%type) is
      select *
        from bs_pricedetail t
       where pdpfid = vpfid
       order by pdpscid desc;
    cursor c_misaving(vmicode varchar2) is
      select *
        from bs_meterinfo
       where micode in
             (select mipid from bs_meterinfo where micode = vmicode)
         and micode <> vmicode;
    mi    bs_meterinfo%rowtype;
    ci    bs_custinfo%rowtype;
    rl    bs_reclist%rowtype;
    md    bs_meterdoc%rowtype;
    pd    bs_pricedetail%rowtype;
    v_pmisaving bs_custinfo.misaving%type;    
    rdtab rd_table;
    i     number;
    vrd   bs_recdetail%rowtype;
    cursor c_hs_meter(c_miid varchar2) is select miid from bs_meterinfo where mipid = c_miid;
    v_hs_meter bs_meterinfo%rowtype;
    v_psumrlje bs_reclist.rlje%type;
    v_hs_rlids varchar2(1280); --应收流水
    v_hs_rlje  number(12, 2); --应收金额
    v_hs_znj   number(12, 2); --滞纳金
    v_hs_outje number(12, 2);
    --预存自动抵扣
    v_rlidlist varchar2(4000);
    v_rlid     bs_reclist.rlid%type;
    v_rlje     number(12, 3);
    v_znj      number(12, 3);
    v_rljes    number(12, 3);
    v_znjs     number(12, 3);
    v_countall number;
    cursor c_ycdk is
      select rlid,sum(rlje) rlje
        from bs_reclist, bs_meterinfo t
       where rlmid = t.miid
         and rlpaidflag = 'N'
         and rlreverseflag = 'N'
         and rlbadflag = 'N' -- 添加呆坏帐过滤条件
         and rlje <> 0
         and rltrans not in ('13', '14', 'U')
         and ((t.mipid = mi.mipid and mi.mipriflag = 'Y') or
             (t.miid = mi.miid and
             (mi.mipriflag = 'N' or mi.mipid is null)))
       group by rlmid, t.miid, t.mipid, rlmonth, rlid, rlsmfid
       order by  rlmonth, rlid, mipid, miid;
  begin
    --锁定水表记录
    open c_mi(mr.mrmid);
    fetch c_mi into mi;
    if c_mi%notfound or c_mi%notfound is null then
      wlog('无效的水表编号' || mr.mrmid);
      raise_application_error(errcode, '无效的水表编号' || mr.mrmid);
    end if;
    --锁定水表档案
    open c_md(mr.mrmid);
    fetch c_md into md;
    if c_md%notfound or c_md%notfound is null then
      wlog('无效的水表档案' || mr.mrmid);
      raise_application_error(errcode, '无效的水表编号' || mr.mrmid);
    end if;
    --锁定用户记录
    open c_ci(mi.micode);
    fetch c_ci into ci;
    if c_ci%notfound or c_ci%notfound is null then
      wlog('无效的用户编号' || mi.micode);
      raise_application_error(errcode, '无效的用户编号' || mi.micode);
    end if;
    --判断起码是否改变
    if mi.mircode <> mr.mrscode and mr.mrdatasource not in ('m','l') then
       --水表起码已经改变
       wlog('此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！' || mr.mrmid);
       raise_application_error(errcode, '此水表编号[' || mr.mrmid ||']此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！');
    end if;
    
    delete bs_reclist_temp where rlmrid = mr.mrid;
    --非计费表执行空过程，不抛异常
    --合收子表
    if md.ifdzsb = 'Y' then
      --如果是倒表 要判断一下指针的问题
      if mr.mrecode > mr.mrscode then
        raise_application_error(errcode, '该用户' || mi.micode || '是倒表用户,起码应大于止码');
      end if;
    elsif mi.miyl1 <> 'Y' and mi.miyl9 is null then
        if mr.mrecode < mr.mrscode then
           raise_application_error(errcode,'该用户' || mi.micode || '不是倒表、等针、超量程用户,起码应小于止码');
        end if;
    end if;
    if true then
      rl.rlid          := trim(to_char(seq_reclist.nextval,'0000000000'));
      rl.rlsmfid       := mr.mrsmfid;
      rl.rlmonth       := to_char(sysdate,'yyyy.mm');
      rl.rldate        := sysdate;
      rl.rlcid         := mr.mrccode;
      rl.rlmid         := mr.mrmid;
      rl.rlsmfid      := mi.mismfid;
      rl.rlchargeper   := mi.micper;
      rl.rlmflag       := ci.ciflag;
      rl.rlcname       := ci.ciname;
      rl.rlcadr        := ci.ciadr;
      rl.rlmadr        := mi.miadr;
      rl.rlcstatus     := ci.cistatus;
      rl.rlmtel        := ci.cimtel;
      rl.rltel         := ci.citel1;
      rl.rlifinv       := 'N'; --ci.ciifinv; --开票标志
      rl.rlmid       := mi.micode;
      rl.rlmpid        := mi.mipid;
      rl.rlmclass      := mi.miclass;
      rl.rlmflag       := mi.miflag;
      rl.rlmsfid       := mi.mistid;
      rl.rlday         := mr.mrday;
      rl.rlbfid        := mr.mrbfid;
      rl.rlscode   := mr.mrscode;
      rl.rlecode   := mr.mrecode;
      rl.rlreadsl  := mr.mrrecsl; --reclist抄见水量 = mr.抄见水量+mr 校验水量
      if p_trans = 'OY' then
        rl.rltrans := 'O';
        rl.rljtmk  := 'Y';
      elsif p_trans = 'ON' then
        rl.rltrans := 'O';
        rl.rljtmk  := 'N';
      else
        rl.rltrans := p_trans;
      end if;
      rl.rlsl           := 0; --应收水费水量，【rlsl = rlreadsl + rladjsl】
      rl.rlje           := 0; --生成帐体后计算,先初始化
      rl.rlscrrlid      := null;
      rl.rlscrrltrans   := null;
      rl.rlscrrlmonth   := null;
      rl.rlpaidje       := 0;
      rl.rlpaidflag     := 'N';
      rl.rlpaidper      := null;
      rl.rlpaiddate     := null;
      rl.rlmrid         := mr.mrid;
      rl.rlmemo         := mr.mrmemo || '   [' || p_ny || '历史单价' || ']';
      rl.rlpfid         := mi.mipfid;
      rl.rldatetime     := sysdate;
      if mi.mipriflag = 'Y' then
        rl.rlmpid := mi.mipid; --记录合收子表串
      else
        rl.rlmpid := rl.rlmid;
      end if;
      rl.rlpriflag := mi.mipriflag;
      if mr.mrrper is null then
        raise_application_error(errcode, '该用户' || mi.micode || '的抄表员不能为空!');
      end if;
      rl.rlrper      := mr.mrrper;
      rl.rlscode        := mr.mrscode;
      rl.rlecode        := mr.mrecode;
      rl.rlpid          := null; --实收流水（与payment.pid对应）
      rl.rlpbatch       := null; --缴费交易批次（与payment.pbatch对应）
      rl.rlsavingqc     := 0; --期初预存（销帐时产生）
      rl.rlsavingbq     := 0; --本期预存发生（销帐时产生）
      rl.rlsavingqm     := 0; --期末预存（销帐时产生）
      rl.rlreverseflag  := 'N'; --  冲正标志（n为正常，y为冲正）
      rl.rlbadflag      := 'N'; --呆帐标志（y :呆坏帐，o:呆坏帐审批中，n:正常帐）
      rl.rlscrrlid      := rl.rlid; --原应收帐流水
      rl.rlscrrltrans   := rl.rltrans; --原应收帐事务
      rl.rlscrrlmonth   := rl.rlmonth; --原应收帐月份
      rl.rlscrrldate    := rl.rldate; --原应收帐日期
      begin
        select nvl(sum(nvl(rlje, 0) - nvl(rlpaidje, 0)), 0)
          into rl.rlpriorje
          from bs_reclist t
         where t.rlreverseflag = 'Y'
           and t.rlpaidflag = 'N'
           and rlje > 0
           and rlmid = mi.miid;
      exception
        when others then
          rl.rlpriorje := 0; --算费之前欠费
      end;
      if rl.rlpriorje > 0 then
        rl.rlmisaving := 0;
      else
        rl.rlmisaving := ci.misaving; --算费时预存
      end if;
      rl.rlcolumn9       := rl.rlid; --上次应收帐流水
    end if;
    
    -------------调用算费过程-------------
    open c_pd(mi.mipfid);
    loop
      fetch c_pd into pd;
      exit when c_pd%notfound;
      calpiid(rl, rl.rlreadsl, pd, rdtab);
    end loop;
    close c_pd;
    --------------------------------------
    
    if mi.miclass = '2' then
      --总分表
      rl.rlreadsl := mr.mrsl + nvl(mr.mrcarrysl, 0); --如果为合收表，则rl的抄见水量为mr抄表水量+mr校验水量
    else
      rl.rlreadsl := mr.mrrecsl + nvl(mr.mrcarrysl, 0); --reclist抄见水量 = mr.抄见水量+mr 校验水量
    end if;
    
    rl.rlje := 0;
    for i in rdtab.first .. rdtab.last loop
      rl.rlje := rl.rlje + rdtab(i).rdje;
    end loop;
    
    if 是否审批算费 = 'N' then
      insert into bs_reclist values rl;
    else
      insert into bs_reclist_temp values rl;
    end if;
    insrd(rdtab);

    --预存自动扣款
    if 算费时预存自动销账 = 'Y' and 是否审批算费 = 'N' then
      if mi.mipid is not null and mi.mipriflag = 'Y' then
        --总预存
        v_pmisaving := 0;
        select count(*)
          into v_countall
          from bs_meterread
         where mrmid <> mr.mrmid
           and mrifrec <> 'Y'
           and mrmid in
               (select miid from bs_meterinfo where mipid = mi.mipid);
        if v_countall < 1 then
          begin
            select sum(misaving) into v_pmisaving from bs_custinfo where ciid =  mi.micode;
          exception
            when others then v_pmisaving := 0;
          end;
          --总欠费
          v_psumrlje := 0;
          begin
            select sum(rlje)
              into v_psumrlje
              from bs_reclist
             where rlmpid = mi.mipid
               and rlbadflag = 'N'
               and rlreverseflag = 'N'
               and rlpaidflag = 'N';
          exception
            when others then v_psumrlje := 0;
          end;
          if v_pmisaving >= v_psumrlje then
            --合收表
            v_rlidlist := '';
            v_rljes    := 0;
            v_znj      := 0;
            open c_ycdk;
            loop
              fetch c_ycdk
                into v_rlid, v_rlje;
              exit when c_ycdk%notfound or c_ycdk%notfound is null;
              --预存够扣
              if v_pmisaving >= v_rlje + v_znj then
                v_rlidlist  := v_rlidlist || v_rlid || ',';
                v_pmisaving := v_pmisaving - (v_rlje + v_znj);
                v_rljes     := v_rljes + v_rlje;
                v_znjs      := v_znjs + v_znj;
              else
                exit;
              end if;
            end loop;
            close c_ycdk;
            if length(v_rlidlist) > 0 then
              --插入pay_para_tmp 表做合收表销账准备
              delete pay_para_tmp;
              open c_hs_meter(mi.mipid);
              loop
                fetch c_hs_meter
                  into v_hs_meter.miid;
                exit when c_hs_meter%notfound or c_hs_meter%notfound is null;
                v_hs_outje := 0;
                v_hs_rlids := '';
                v_hs_rlje  := 0;
                v_hs_znj   := 0;
                select replace(connstr(rlid), '/', ',') || '|',
                       sum(rlje)
                  into v_hs_rlids, v_hs_rlje
                  from bs_reclist rl
                 where rl.rlmid = v_hs_meter.miid
                   and rl.rlje > 0
                   and rl.rlpaidflag = 'N'
                   and rl.rlreverseflag = 'N'
                   and rl.rlbadflag = 'N';
                if v_hs_rlje > 0 then
                  insert into pay_para_tmp
                  values
                    (v_hs_meter.miid,
                     v_hs_rlids,
                     v_hs_rlje,
                     0,
                     v_hs_znj);
                end if;
              end loop;
              close c_hs_meter;
              v_rlidlist := substr(v_rlidlist,
                                   1,
                                   length(v_rlidlist) - 1);
              /*v_retstr   := pg_ewide_pay_01.pos('02', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                                mi.mismfid, --缴费机构
                                                'system', --收款员
                                                v_rlidlist || '|', --应收流水串
                                                nvl(v_rljes, 0), --应收总金额
                                                nvl(v_znjs, 0), --销帐违约金
                                                0, --手续费
                                                0, --实际收款
                                                pg_ewide_pay_01.paytrans_预存抵扣, --缴费事务
                                                mi.mipriid, --水表资料号
                                                'XJ', --付款方式
                                                mi.mismfid, --缴费地点
                                                fgetsequence('entrustlog'), --销帐批次
                                                'N', --是否打票  y 打票，n不打票， r 应收票
                                                null, --发票号
                                                'N' --控制是否提交（y/n）
                                                );*/
            end if;
          end if;
        end if;
      else
        v_rlidlist  := '';
        v_rljes     := 0;
        v_znj       := 0;
        v_pmisaving := ci.misaving;
        open c_ycdk;
        loop
          fetch c_ycdk
            into v_rlid, v_rlje;
          exit when c_ycdk%notfound or c_ycdk%notfound is null;
          --预存够扣
          if v_pmisaving >= v_rlje + v_znj then
            v_rlidlist  := v_rlidlist || v_rlid || ',';
            v_pmisaving := v_pmisaving - (v_rlje + v_znj);
            v_rljes     := v_rljes + v_rlje;
            v_znjs      := v_znjs + v_znj;
          else
            exit;
          end if;
        end loop;
        close c_ycdk;
        --单表
        if length(v_rlidlist) > 0 then
          v_rlidlist := substr(v_rlidlist, 1, length(v_rlidlist) - 1);
          /*v_retstr   := pg_ewide_pay_01.pos('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                            mi.mismfid, --缴费机构
                                            'system', --收款员
                                            v_rlidlist || '|', --应收流水串
                                            nvl(v_rljes, 0), --应收总金额
                                            nvl(v_znjs, 0), --销帐违约金
                                            0, --手续费
                                            0, --实际收款
                                            pg_ewide_pay_01.paytrans_预存抵扣, --缴费事务
                                            mi.miid, --水表资料号
                                            'XJ', --付款方式
                                            mi.mismfid, --缴费地点
                                            fgetsequence('entrustlog'), --销帐批次
                                            'N', --是否打票  y 打票，n不打票， r 应收票
                                            null, --发票号
                                            'N' --控制是否提交（y/n）
                                            );*/
        end if;
      end if;
    end if;
    update bs_meterinfo
       set mircode     = mr.mrecode,
           mirecdate   = mr.mrrdate,
           mirecsl     = mr.mrsl, --取本期水量（抄量）
           miface      = mr.mrface,
           miyl11      = to_date(rl.rljtsrq, 'yyyy.mm')
     where current of c_mi;
    close c_mi;
    close c_md;
    close c_ci;
    --反馈应收水量水费到原始抄表记录
    mr.mrrecsl   := nvl(rl.rlsl, 0);
    mr.mrifrec   := 'Y';
    mr.mrrecdate := rl.rldate;
    if rdtab is not null then
      for i in rdtab.first .. rdtab.last loop
        vrd := rdtab(i);
        case vrd.rdpiid
          when '01' then mr.mrrecje01 := nvl(mr.mrrecje01, 0) + vrd.rdje;
          when '02' then mr.mrrecje02 := nvl(mr.mrrecje02, 0) + vrd.rdje;
          when '03' then mr.mrrecje03 := nvl(mr.mrrecje03, 0) + vrd.rdje;
          when '04' then mr.mrrecje04 := nvl(mr.mrrecje04, 0) + vrd.rdje;
          else null;
        end case;
      end loop;
    end if;
  exception
    when others then
      if c_mi%isopen then close c_mi; end if;
      if c_misaving%isopen then close c_misaving; end if;
      if c_md%isopen then close c_md; end if;
      if c_ci%isopen then close c_ci; end if;
      if c_pd%isopen then close c_pd; end if;
      wlog('其他异常：' || sqlerrm);
      raise_application_error(errcode, sqlerrm);
  end;
  
    --自来水单笔算费，只用于记账不计费（哈尔滨）
  procedure calculatenp(mr      in out bs_meterread%rowtype,
                        p_trans in char,
                        p_ny    in varchar2) is
    cursor c_mi(vmiid in bs_meterinfo.miid%type) is select * from bs_meterinfo where miid = vmiid for update;
    cursor c_ci(vciid in bs_custinfo.ciid%type) is select * from bs_custinfo where ciid = vciid for update;
    cursor c_md(vmiid in bs_meterdoc.mdid%type) is select * from bs_meterdoc where mdid = vmiid for update;
    cursor c_pd(vpfid in bs_pricedetail.pdpfid%type) is
      select *
        from bs_pricedetail t
       where pdpfid = vpfid
       order by pdpscid desc;
    cursor c_misaving(vmicode varchar2) is
      select *
        from bs_meterinfo
       where micode in
             (select mipid from bs_meterinfo where micode = vmicode)
         and micode <> vmicode;
    mi    bs_meterinfo%rowtype;
    ci    bs_custinfo%rowtype;
    rl    bs_reclist%rowtype;
    md          bs_meterdoc%rowtype;
    rdtab       rd_table;
    i             number;
    vrd           bs_recdetail%rowtype;
  begin  
    --锁定水表记录
    open c_mi(mr.mrmid);
    fetch c_mi
      into mi;
    if c_mi%notfound or c_mi%notfound is null then
      wlog('无效的水表编号' || mr.mrmid);
      raise_application_error(errcode, '无效的水表编号' || mr.mrmid);
    end if;
    --锁定水表档案
    open c_md(mr.mrmid);
    fetch c_md
      into md;
    if c_md%notfound or c_md%notfound is null then
      wlog('无效的水表档案' || mr.mrmid);
      raise_application_error(errcode, '无效的水表编号' || mr.mrmid);
    end if;
    --锁定用户记录
    open c_ci(mi.micode);
    fetch c_ci into ci;
    if c_ci%notfound or c_ci%notfound is null then
      wlog('无效的用户编号' || mi.micode);
      raise_application_error(errcode, '无效的用户编号' || mi.micode);
    end if;
    delete bs_reclist_temp where rlmrid = mr.mrid;
    --非计费表执行空过程，不抛异常
    --合收子表
    if true then
     rl.rlid          := to_char(seq_reclist.nextval, '0000000000');
      rl.rlsmfid       := mr.mrsmfid;
      rl.rlmonth       := to_char(sysdate,'yyyy.mm');
      rl.rldate        := sysdate;
      rl.rlcid         := mr.mrccode;
      rl.rlmid         := mr.mrmid;
      rl.rlsmfid      := mi.mismfid;
      rl.rlchargeper   := mi.micper;
      rl.rlmflag       := ci.ciflag;
      rl.rlcname       := ci.ciname;
      rl.rlcadr        := ci.ciadr;
      rl.rlmadr        := mi.miadr;
      rl.rlcstatus     := ci.cistatus;
      rl.rlmtel        := ci.cimtel;
      rl.rltel         := ci.citel1;
      rl.rlifinv       := 'N'; --ci.ciifinv; --开票标志
      rl.rlmid       := mi.micode;
      rl.rlmpid        := mi.mipid;
      rl.rlmclass      := mi.miclass;
      rl.rlmflag       := mi.miflag;
      rl.rlmsfid       := mi.mistid;
      rl.rlday         := mr.mrday;
      rl.rlbfid        := mr.mrbfid;
      rl.rlscode   := mr.mrscode;
      rl.rlecode   := mr.mrecode;
      rl.rlreadsl  := mr.mrrecsl; --reclist抄见水量 = mr.抄见水量+mr 校验水量
      if p_trans = 'OY' then
        rl.rltrans := 'O';
        rl.rljtmk  := 'Y';
      elsif p_trans = 'ON' then
        rl.rltrans := 'O';
        rl.rljtmk  := 'N';
      else
        rl.rltrans := p_trans;
      end if;
      rl.rlsl           := 0; --应收水费水量，【rlsl = rlreadsl + rladjsl】
      rl.rlje           := 0; --生成帐体后计算,先初始化
      rl.rlscrrlid      := null;
      rl.rlscrrltrans   := null;
      rl.rlscrrlmonth   := null;
      rl.rlpaidje       := 0;
      rl.rlpaidflag     := 'N';
      rl.rlpaidper      := null;
      rl.rlpaiddate     := null;
      rl.rlmrid         := mr.mrid;
      rl.rlmemo         := mr.mrmemo || '   [' || p_ny || '历史单价' || ']';
      rl.rlpfid         := mi.mipfid;
      rl.rldatetime     := sysdate;
      if mi.mipriflag = 'Y' then
        rl.rlmpid := mi.mipid; --记录合收子表串
      else
        rl.rlmpid := rl.rlmid;
      end if;
      rl.rlpriflag := mi.mipriflag;
      if mr.mrrper is null then
        raise_application_error(errcode, '该用户' || mi.micode || '的抄表员不能为空!');
      end if;
      rl.rlrper      := mr.mrrper;
      rl.rlscode        := mr.mrscode;
      rl.rlecode        := mr.mrecode;
      rl.rlpid          := null; --实收流水（与payment.pid对应）
      rl.rlpbatch       := null; --缴费交易批次（与payment.pbatch对应）
      rl.rlsavingqc     := 0; --期初预存（销帐时产生）
      rl.rlsavingbq     := 0; --本期预存发生（销帐时产生）
      rl.rlsavingqm     := 0; --期末预存（销帐时产生）
      rl.rlreverseflag  := 'N'; --  冲正标志（n为正常，y为冲正）
      rl.rlbadflag      := 'N'; --呆帐标志（y :呆坏帐，o:呆坏帐审批中，n:正常帐）
      rl.rlscrrlid      := rl.rlid; --原应收帐流水
      rl.rlscrrltrans   := rl.rltrans; --原应收帐事务
      rl.rlscrrlmonth   := rl.rlmonth; --原应收帐月份
      rl.rlscrrldate    := rl.rldate; --原应收帐日期
      begin
        select nvl(sum(nvl(rlje, 0) - nvl(rlpaidje, 0)), 0)
          into rl.rlpriorje
          from bs_reclist t
         where t.rlreverseflag = 'Y'
           and t.rlpaidflag = 'N'
           and rlje > 0
           and rlmid = mi.miid;
      exception
        when others then
          rl.rlpriorje := 0; --算费之前欠费
      end;
      if rl.rlpriorje > 0 then
        rl.rlmisaving := 0;
      else
        rl.rlmisaving := ci.misaving; --算费时预存
      end if;
      rl.rlcolumn9       := rl.rlid; --上次应收帐流水
    end if;
      
    if mi.miclass = '2' then
      --合收表
      rl.rlreadsl := mr.mrsl + nvl(mr.mrcarrysl, 0); --如果为合收表，则rl的抄见水量为mr抄表水量+mr校验水量
    else
      rl.rlreadsl := mr.mrrecsl + nvl(mr.mrcarrysl, 0); --reclist抄见水量 = mr.抄见水量+mr 校验水量
    end if;
  
    update bs_meterinfo
       set mircode     = mr.mrecode,
           mirecdate   = mr.mrrdate,
           mirecsl     = mr.mrsl, --取本期水量（抄量）
           miface      = mr.mrface,
           miyl11      = to_date(rl.rljtsrq, 'yyyy.mm')
     where current of c_mi;
    close c_mi;
    close c_md;
    close c_ci;
    --反馈应收水量水费到原始抄表记录
    mr.mrrecsl   := nvl(rl.rlsl, 0);
    mr.mrifrec   := 'Y';
    mr.mrrecdate := rl.rldate;
    if rdtab is not null then
      for i in rdtab.first .. rdtab.last loop
        vrd := rdtab(i);
        case vrd.rdpiid
          when '01' then mr.mrrecje01 := nvl(mr.mrrecje01, 0) + vrd.rdje;
          when '02' then mr.mrrecje02 := nvl(mr.mrrecje02, 0) + vrd.rdje;
          when '03' then mr.mrrecje03 := nvl(mr.mrrecje03, 0) + vrd.rdje;
          when '04' then mr.mrrecje04 := nvl(mr.mrrecje04, 0) + vrd.rdje;
          else null;
        end case;
      end loop;
    end if;
  
  exception
    when others then
      if c_mi%isopen then close c_mi; end if;
      if c_misaving%isopen then close c_misaving; end if;
      if c_md%isopen then close c_md; end if;
      if c_ci%isopen then close c_ci; end if;
      if c_pd%isopen then close c_pd; end if;
      wlog('其他异常：' || sqlerrm);
      raise_application_error(errcode, sqlerrm);
  end;
  
  procedure calpiid(p_rl             in out bs_reclist%rowtype,
                  p_sl             in number,
                  pd               in bs_pricedetail%rowtype,
                  rdtab            in out rd_table) is
    rd       bs_recdetail%rowtype;
  begin
    rd.rdid       := p_rl.rlid; --流水号 
    rd.rdpiid     := pd.pdpiid; --费用项目  
    rd.rdpfid     := pd.pdpfid; --费率  
    rd.rdpscid    := pd.pdpscid; --费率明细方案  
    rd.rddj     := 0; --单价 
    rd.rdsl     := 0; --水量 
    rd.rdje     := 0; --金额 
    rd.rdmethod   := pd.pdmethod; --计费方法 
    case pd.pdmethod
      when '01' then 
        --固定单价  默认方式，与抄量有关  哈尔滨都是dj1
        begin
          rd.rdclass := 0; --阶梯级别 
          rd.rddj  := pd.pddj; --单价 
          rd.rdsl  := p_sl; --水量 
          rd.rdje := 0; --调整金额 
          --计算调整
          rd.rdje   := round(rd.rddj * rd.rdsl, 2); --实收金额 
          --插入明细包
          if rdtab is null then
            rdtab := rd_table(rd);
          else
            rdtab.extend;
            rdtab(rdtab.last) := rd;
          end if;
          --汇总
          p_rl.rlje := p_rl.rlje + rd.rdje;
          p_rl.rlsl := p_rl.rlsl + (case when rd.rdpiid = '01' then rd.rdsl else 0 end);
        end;
      when '02' then 
        --阶梯计费  简单模式阶梯水价
        rd.rdsl    := p_sl;
        begin
          --阶梯计费
          calstep(p_rl,
                  rd.rdsl,
                  pd,
                  rdtab);
		    end;
      else raise_application_error(errcode, '不支持的计费方法' || pd.pdmethod);
    end case;
  exception
    when others then
      wlog(p_rl.rlid || '计算费用项目费用异常：' || sqlerrm);
      raise_application_error(errcode, sqlerrm);
  end;

  procedure calstep(p_rl       in out bs_reclist%rowtype,
                    p_sl       in number,
                    pd         in bs_pricedetail%rowtype,
                    rdtab      in out rd_table) is
    cursor c_ps is
      select *
        from bs_pricestep
       where pspscid = pd.pdpscid
         and pspfid = pd.pdpfid
         and pspiid = pd.pdpiid
       order by psclass;
    tmpyssl        number;
    tmpsl          number;
    rd             bs_recdetail%rowtype;
    ps             bs_pricestep%rowtype;
    年累计水量     number;
    minfo          bs_meterinfo%rowtype;
    usenum         number; --计费人口数
    v_date         date;
    v_dateold      date;
    v_monbet       number;
    v_yyyymm       varchar2(10);
    v_rljtmk       varchar2(1);
    bk             bs_bookframe%rowtype;
    v_rlscrrlmonth bs_reclist.rlmonth%type;
    v_rlmonth      bs_reclist.rlmonth%type;
    v_rljtsrq      bs_reclist.rljtsrq%type;
    v_rljtsrqold   bs_reclist.rljtsrq%type;
    v_jgyf         number;
    v_jtny         number;
    v_newmk        char(1);
    v_jtqzny       bs_reclist.rljtsrq%type;
    v_betweenny    number;
  begin
    rd.rdid       := p_rl.rlid;
    rd.rdpiid     := pd.pdpiid;
    rd.rdpfid     := pd.pdpfid;
    rd.rdpscid    := pd.pdpscid;
    rd.rdmethod   := pd.pdmethod;
    tmpyssl := p_sl; --阶梯累减应收水量余额
    tmpsl   := p_sl; --阶梯累减实收水量余额
    v_newmk := 'N';
    --取上次算费月份，以及阶梯开始月份
   select nvl(max(rlscrrlmonth), 'a'), nvl(max(rljtsrq), 'a'),nvl(max(rlmonth),'2015.12')
      into v_rlscrrlmonth, v_rljtsrqold,v_rlmonth
      from bs_reclist
     where rlmid = p_rl.rlmid
       and rlreverseflag = 'N';
    --第一次算费比进入阶梯
  
    select * into bk from bs_bookframe where bfid = p_rl.rlbfid;
    --判断数据是否满足收取阶梯的条件
    select mi.* into minfo from bs_meterinfo mi where mi.miid = p_rl.rlmid;
    --取合收表人口最大表的用户数
    select nvl(max(miusenum),0)
      into usenum
      from bs_meterinfo
     where mipid = minfo.mipid;
    if usenum <= 5 then
      usenum := 5;
    end if;
    bk.bfjtsny := nvl(bk.bfjtsny, '01');
    bk.bfjtsny := to_char(to_number(bk.bfjtsny), 'fm00');
    if substr(p_rl.rlmonth, 6, 2) >= bk.bfjtsny then
      v_rljtsrq := substr(p_rl.rlmonth, 1, 4) || '.' || bk.bfjtsny;
    else
      v_rljtsrq := substr(p_rl.rlmonth, 1, 4) - 1 || '.' || bk.bfjtsny;
    end if;
    --新阶梯起止
    v_date := add_months(to_date(v_rljtsrq, 'yyyy.mm'), 12);
    if v_rljtsrqold <> 'a' then
      --旧阶梯起止
      v_dateold := add_months(to_date(v_rljtsrqold, 'yyyy.mm'), 12);
    else
      v_dateold := v_date;
    end if;
    --旧阶梯起止不等于新阶梯起止
    if v_dateold <> v_date then
    
      v_betweenny := months_between(v_date, v_dateold);
      if substr(v_rljtsrq, 1, 4) <> to_char(v_dateold, 'yyyy') then
        if v_rljtsrq < to_char(v_dateold, 'yyyy.mm') then
          if v_rljtsrq = p_rl.rlmonth then
            p_rl.rljtmk  := 'Y';
            p_rl.rljtsrq := v_rljtsrq;
          else
            p_rl.rljtsrq := v_rljtsrqold;
            v_jtqzny     := v_rljtsrqold;
          end if;
        else
          p_rl.rljtmk  := 'Y';
          p_rl.rljtsrq := v_rljtsrq;
        end if;
      else
        if mod(v_betweenny, 12) = 0 then
          --跨年的情况
          if v_betweenny / 12 > 1 then
            p_rl.rljtmk  := 'Y';
            p_rl.rljtsrq := v_rljtsrq;
          else
            p_rl.rljtsrq := v_rljtsrq;
            v_jtqzny     := v_rljtsrqold;
          end if;
        elsif v_betweenny < 12 then
          if p_rl.rlmonth = v_rljtsrq then
            p_rl.rljtsrq := v_rljtsrq;
            v_jtqzny     := v_rljtsrqold;
          elsif p_rl.rlmonth < v_rljtsrq then
            p_rl.rljtsrq := v_rljtsrqold;
            v_jtqzny     := v_rljtsrqold;
          else
            p_rl.rljtsrq := v_rljtsrq;
            v_jtqzny     := v_rljtsrqold;
          end if;
        elsif v_betweenny > 12 then
          if p_rl.rlmonth = v_rljtsrq then
            if substr(p_rl.rlmonth, 1, 4) = substr(v_rlscrrlmonth, 1, 4) then
              p_rl.rljtsrq := v_rljtsrq;
              p_rl.rljtmk  := 'Y';
            else
              p_rl.rljtsrq := v_rljtsrq;
              v_newmk      := 'Y';
              v_jtqzny     := v_rljtsrqold;
            end if;
          else
            if p_rl.rlmonth = v_rljtsrqold then
              p_rl.rljtsrq := to_char(v_dateold, 'yyyy.mm');
              v_jtqzny     := v_rljtsrqold;
            else
              p_rl.rljtsrq := v_rljtsrqold;
              v_jtqzny     := v_rljtsrqold;
            end if;
          end if;
        end if;
      end if;
    else
      if p_rl.rlmonth = v_rljtsrq then
        v_jtqzny := substr(p_rl.rlmonth, 1, 4) - 1 || '.' || bk.bfjtsny;
      else
        v_jtqzny := v_rljtsrq;
      end if;
      p_rl.rljtsrq := v_rljtsrq;
    
    end if;

    --取日期
    select nvl(months_between(v_date, trunc(max(cchshdate), 'mm')), 99) + 1,
           to_char(trunc(max(cchshdate), 'mm'), 'yyyy.mm')
      into v_monbet, v_yyyymm
      from gd_custchangehd, gd_custchangedt
     where gd_custchangehd.cchno = gd_custchangedt.ccdno
       and gd_custchangehd.cchlb in ('D')
       and gd_custchangedt.pmdmid = p_rl.rlmid;
    if v_monbet = 100 or v_yyyymm <= v_jtqzny then
    
      v_yyyymm := v_jtqzny;
    else
      v_yyyymm := v_yyyymm;
    end if;
    -- 第一次算费不进入阶梯 
    -- 2016年1月起（含一月）首次抄表不计入阶梯
    if p_rl.rljtmk = 'Y' or v_rlscrrlmonth = 'a' or p_rl.rltrans in('14', '21') or v_rlmonth <='2015.12' then
      v_rljtmk := 'Y';
    else
      v_rljtmk := 'N';
    end if;
    --没有跨阶梯年月程序处理
    if v_dateold >= to_date(p_rl.rlmonth, 'yyyy.mm') or v_rljtmk = 'Y' then
       select nvl(sum(rdsl), 0)
        into p_rl.rlcolumn12
        from bs_reclist, bs_recdetail,bs_meterinfo
       where rlid = rdid
         and rlmid = miid
         and nvl(rljtmk, 'N') = 'N'
         and rlscrrltrans not in ('14', '21')
         and rdpmdcolumn3 = substr(v_jtqzny, 1, 4)
         and rdpiid = '01'
         and rdmethod = 'sl3'
         and rlscrrlmonth <= p_rl.rlmonth
         and rlscrrlmonth > v_yyyymm
         and mipid = minfo.mipid;
      rd.rdpmdcolumn3 := substr(v_jtqzny, 1, 4);
      年累计水量      := case when p_rl.rlcolumn12<0 then 0 else to_number(nvl(p_rl.rlcolumn12, 0)) end + p_sl;
      
      open c_ps;
      fetch c_ps
        into ps;
      if c_ps%notfound or c_ps%notfound is null then
        raise_application_error(errcode, '无效的阶梯计费设置');
      end if;
      while c_ps%found and (tmpyssl >= 0 or tmpsl >= 0) loop
        --居民水费阶梯数量跟户籍人数有关
        if ps.psscode = 0 then
          ps.psscode := 0;
        else
          ps.psscode := round((ps.psscode + 30 * (usenum - 5)) );
        end if;
        ps.psecode := round((ps.psecode + 30 * (usenum - 5)) );
        rd.rdclass := ps.psclass;
        rd.rddj  := ps.psprice;
        rd.rdsl := case
                       when v_rljtmk = 'Y' then tmpyssl
                       else
                        case
                          when 年累计水量 >= ps.psscode and 年累计水量 <= ps.psecode then
                            年累计水量 - tools.getmax(to_number(nvl(p_rl.rlcolumn12, 0)),ps.psscode)
                          when 年累计水量 >= ps.psecode then
                            tools.getmax(0, tools.getmin(ps.psecode - to_number(nvl(p_rl.rlcolumn12, 0)),ps.psecode - ps.psscode))
                          else
                            0
                        end
                     end;
        rd.rdje  := rd.rddj * rd.rdsl;
        rd.rddj    := ps.psprice;
        rd.rdsl := case
                     when v_rljtmk = 'Y' then
                      tmpsl
                     else
                      case
                        when 年累计水量 >= ps.psscode and 年累计水量 <= ps.psecode then
                         年累计水量 -
                         tools.getmax(to_number(nvl(p_rl.rlcolumn12, 0)), ps.psscode)
                        when 年累计水量 > ps.psecode then
                         tools.getmax(0,
                                      tools.getmin(ps.psecode -
                                                   to_number(nvl(p_rl.rlcolumn12, 0)),
                                                   ps.psecode - ps.psscode))
                        else
                         0
                      end
                   end;
        rd.rdje    := rd.rddj * rd.rdsl;
        if v_rljtmk <> 'Y' then
          rd.rdpmdcolumn1 := ps.psecode - ps.psscode;
          if 年累计水量 >= ps.psscode and 年累计水量 <= ps.psecode then
            rd.rdpmdcolumn2 := 年累计水量 - ps.psscode;
          elsif 年累计水量 > ps.psecode then
            rd.rdpmdcolumn2 := ps.psecode - ps.psscode;
          else
            rd.rdpmdcolumn2 := 0;
          end if;
          --end if;
        end if;
        
        if rd.rdsl > 0 then
          if rdtab is null then
            rdtab := rd_table(rd);
          else
            rdtab.extend;
            rdtab(rdtab.last) := rd;
          end if;
        end if;
        --汇总
        p_rl.rlje := p_rl.rlje + rd.rdje;
        p_rl.rlsl := p_rl.rlsl + (case
                       when rd.rdpiid = '01' then
                        rd.rdsl
                       else
                        0
                     end);
        tmpsl   := tools.getmax(tmpsl - rd.rdsl, 0);
        exit when tmpyssl <= 0 and tmpsl <= 0;
        fetch c_ps into ps;
      end loop;
      close c_ps;
    else
      --跨年，需要按用水月份比例拆分
      v_jgyf := months_between(to_date(p_rl.rlmonth, 'yyyy.mm'), v_dateold);
      v_jtny := months_between(to_date(p_rl.rlmonth, 'yyyy.mm'),
                               to_date(v_rlscrrlmonth, 'yyyy.mm'));
      if v_jgyf / v_jtny  > 1 then
        v_jtny := v_jgyf;
      end if;                
      if v_jgyf > 12 then
        tmpyssl  := p_sl;
        tmpsl    := p_sl;
        v_rljtmk := 'Y';
      else
        tmpyssl := p_sl - round(p_sl * v_jgyf / v_jtny); --阶梯累减应收水量余额
        tmpsl   := p_sl - round(p_sl * v_jgyf / v_jtny); --阶梯累减实收水量余额 
      end if;
      rd.rdpscid := -1;
      if v_rljtmk = 'Y' then
        p_rl.rlcolumn12 := 0;
      else
        select nvl(sum(rdsl), 0)
          into p_rl.rlcolumn12
          from bs_reclist, bs_recdetail
         where rlid = rdid
           and nvl(rljtmk, 'N') = 'N'
           and rlscrrltrans not in ('14', '21')
           and rdpmdcolumn3 = substr(v_rljtsrqold, 1, 4)
           and rdpiid = '01'
           and rdmethod = 'sl3'
           and rlscrrlmonth <= p_rl.rlmonth
           and rlscrrlmonth > v_yyyymm
           and rlmid in (select miid from bs_meterinfo where mipid = minfo.mipid);
      end if;
      rd.rdpmdcolumn3 := substr(v_rljtsrqold, 1, 4);
      年累计水量      := tools.getmax(to_number(nvl(p_rl.rlcolumn12, 0)), 0) + (p_sl - round(p_sl * v_jgyf / v_jtny));
      --计算去年的阶梯
      open c_ps;
      fetch c_ps
        into ps;
      if c_ps%notfound or c_ps%notfound is null then
        raise_application_error(errcode, '无效的阶梯计费设置');
      end if;
      while c_ps%found and (tmpyssl >= 0 or tmpsl >= 0) loop
        --居民水费阶梯数量跟户籍人数有关
        if ps.psscode = 0 then
          ps.psscode := 0;
        else
          ps.psscode := round((ps.psscode + 30 * (usenum - 5)) );
        end if;
        ps.psecode := round((ps.psecode + 30 * (usenum - 5)) );

        rd.rdclass := ps.psclass;
        rd.rddj  := ps.psprice;
        rd.rdsl := case
                       when v_rljtmk = 'Y' then
                        tmpyssl
                       else
                        case
                          when 年累计水量 >= ps.psscode and 年累计水量 <= ps.psecode then
                            年累计水量 - tools.getmax(to_number(nvl(p_rl.rlcolumn12, 0)), ps.psscode)
                          when 年累计水量 > ps.psecode then
                            tools.getmax(0, tools.getmin(ps.psecode - to_number(nvl(p_rl.rlcolumn12, 0)), ps.psecode - ps.psscode))
                          else
                            0
                        end
                     end;
        rd.rdje  := rd.rddj * rd.rdsl;
        rd.rddj    := ps.psprice;
        rd.rdsl := case
                     when v_rljtmk = 'Y' then
                      tmpsl
                     else
                      case
                        when 年累计水量 >= ps.psscode and 年累计水量 <= ps.psecode then 
                          年累计水量 - tools.getmax(to_number(nvl(p_rl.rlcolumn12, 0)), ps.psscode)
                        when 年累计水量 > ps.psecode then
                          tools.getmax(0,tools.getmin(ps.psecode - to_number(nvl(p_rl.rlcolumn12, 0)), ps.psecode - ps.psscode))
                        else
                          0
                      end
                   end;
        rd.rdje    := rd.rddj * rd.rdsl;
        if v_rljtmk <> 'Y' then
          rd.rdpmdcolumn1 := ps.psecode - ps.psscode;
          if 年累计水量 >= ps.psscode and 年累计水量 <= ps.psecode then
            rd.rdpmdcolumn2 := 年累计水量 - ps.psscode;
          elsif 年累计水量 > ps.psecode then
            rd.rdpmdcolumn2 := ps.psecode - ps.psscode;
          else
            rd.rdpmdcolumn2 := 0;
          end if;
        end if;
        
        if rd.rdsl > 0 then
          if rdtab is null then
            rdtab := rd_table(rd);
          else
            rdtab.extend;
            rdtab(rdtab.last) := rd;
          end if;
        end if;
        --汇总
        p_rl.rlje := p_rl.rlje + rd.rdje;
        p_rl.rlsl := p_rl.rlsl + (case when rd.rdpiid = '01'then rd.rdsl else 0 end);
        tmpsl   := tools.getmax(tmpsl - rd.rdsl, 0);
        exit when tmpyssl <= 0 and tmpsl <= 0;
        fetch c_ps into ps;
      end loop;
      close c_ps;

      if v_jgyf <= 12 then
        if v_newmk = 'Y' then
          v_rljtmk := 'Y';
        end if;
        rd.rdpscid := pd.pdpscid;
        tmpyssl    := round(p_sl * (v_jgyf / v_jtny)); --阶梯累减应收水量余额
        tmpsl      := round(p_sl * (v_jgyf / v_jtny)); --阶梯累减实收水量余额 
        select nvl(sum(rdsl), 0)
          into p_rl.rlcolumn12
          from bs_reclist, bs_recdetail
         where rlid = rdid
           and nvl(rljtmk, 'N') = 'N'
           and rlscrrltrans not in ('14', '21')
           and rdpmdcolumn3 = substr(p_rl.rlmonth, 1, 4)
           and rdpiid = '01'
           and rdmethod = 'sl3'
           and rlscrrlmonth <= p_rl.rlmonth
           and rlscrrlmonth > v_yyyymm
           and rlmid in (select miid from bs_meterinfo where mipid = minfo.mipid);
        rd.rdpmdcolumn3 := substr(p_rl.rlmonth, 1, 4);
        年累计水量      := tools.getmax(to_number(nvl(p_rl.rlcolumn12, 0)), 0) + (round(p_sl * v_jgyf / v_jtny));
        
        --计算去年的阶梯
          open c_ps;
          fetch c_ps
            into ps;
          if c_ps%notfound or c_ps%notfound is null then
            raise_application_error(errcode, '无效的阶梯计费设置');
          end if;
          while c_ps%found and (tmpyssl >= 0 or tmpsl >= 0) loop
            --居民水费阶梯数量跟户籍人数有关
            if ps.psscode = 0 then
              ps.psscode := 0;
            else
              ps.psscode := round((ps.psscode + 30 * (usenum - 5)));
            end if;
            ps.psecode := round((ps.psecode + 30 * (usenum - 5)));
            rd.rdclass := ps.psclass;
            rd.rddj    := ps.psprice;
            rd.rdsl := case
                         when v_rljtmk = 'Y' then
                          tmpsl
                         else
                          case
                            when 年累计水量 >= ps.psscode and 年累计水量 <= ps.psecode then
                              年累计水量 - tools.getmax(to_number(nvl(p_rl.rlcolumn12, 0)), ps.psscode)
                            when 年累计水量 > ps.psecode then
                              tools.getmax(0,tools.getmin(ps.psecode -  to_number(nvl(p_rl.rlcolumn12, 0)), ps.psecode - ps.psscode))
                            else
                              0
                          end
                       end;
            rd.rdje    := rd.rddj * rd.rdsl;
            if v_rljtmk <> 'Y' then
              rd.rdpmdcolumn1 := ps.psecode - ps.psscode;
              if 年累计水量 >= ps.psscode and 年累计水量 <= ps.psecode then
                rd.rdpmdcolumn2 := 年累计水量 - ps.psscode;
              elsif 年累计水量 > ps.psecode then
                rd.rdpmdcolumn2 := ps.psecode - ps.psscode;
              else
                rd.rdpmdcolumn2 := 0;
              end if;
            end if;
          
            if rd.rdsl > 0 then
              if rdtab is null then
                rdtab := rd_table(rd);
              else
                rdtab.extend;
                rdtab(rdtab.last) := rd;
              end if;
            end if;
            --汇总
            p_rl.rlje := p_rl.rlje + rd.rdje;
            p_rl.rlsl := p_rl.rlsl + (case
                           when rd.rdpiid = '01' then
                            rd.rdsl
                           else
                            0
                         end);
            --累减后带入下一行游标
            tmpsl   := tools.getmax(tmpsl - rd.rdsl, 0);
            exit when tmpyssl <= 0 and tmpsl <= 0;
            fetch c_ps into ps;
          end loop;
          close c_ps;
      end if;
    end if;
    if v_rljtmk = 'N' then
      p_rl.rlcolumn12 := 年累计水量;
    else
      p_rl.rljtmk := 'Y';
    end if;
  exception
    when others then
      if c_ps%isopen then close c_ps; end if;
      wlog(p_rl.rlmid || '计算阶梯水量费用异常：' || sqlerrm);
      raise_application_error(errcode, sqlerrm);
  end;
  
  procedure insrd(rd in rd_table) is
    vrd      bs_recdetail%rowtype;
    i        number;
    v_rdpiid varchar2(10);
  begin
    for i in rd.first .. rd.last loop
      vrd      := rd(i);
      v_rdpiid := vrd.rdpiid;
      if 是否审批算费 = 'N' then
        insert into bs_recdetail values vrd;
      else
        insert into bs_recdetail_temp values vrd;
      end if;
    end loop;
  exception
    when others then
      raise_application_error(errcode, sqlerrm);
  end;
  
begin
  select to_number(spvalue) into 最低算费水量 from sys_para where spid='1092';
  select spvalue into 总表截量 from sys_para where spid='1069';
  select spvalue into 是否审批算费 from sys_para where spid='ifrl';
  select spvalue into 分账操作 from sys_para where spid='1104';
  select spvalue into 算费时预存自动销账 from sys_para where spid='0006';
end;
/

