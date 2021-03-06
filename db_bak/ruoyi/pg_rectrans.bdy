﻿create or replace package body pg_rectrans is

  --工单
  --p_gdtype: ZLSF  追量收费,  BJSF  补缴收费
  --追量收费：request_zlsf
  --
  procedure rectrans_gd(p_reno varchar2, p_gdtype varchar2, o_log out varchar2) is
    v_gdtype_name varchar(10);
    v_miid varchar(20);
    v_mrscode number;
    v_mrecode number;
    v_mrsl number;
    v_mrdatasource varchar2(1);
    v_mrid varchar2(20);
    o_mrrecje01 bs_meterread.mrrecje01%type;
    o_mrrecje02 bs_meterread.mrrecje02%type;
    o_mrrecje03 bs_meterread.mrrecje03%type;
    o_mrrecje04 bs_meterread.mrrecje04%type;
    o_mrsumje   number;
    v_insmr_log varchar2(2000);
    v_cal_log varchar2(2000);
    v_reshbz varchar2(1);
    v_rewcbz varchar(1);
    v_reifreset varchar(1);
    v_reifstep varchar(1);
  begin
    select decode(p_gdtype, 'ZLSF', '追量收费', 'BJSF', '补缴收费') into v_gdtype_name from dual;

    if p_gdtype = 'ZLSF' then
      select miid, mircode, rercode, abs(rercode - mircode), 'Z', reshbz, rewcbz, reifreset, reifstep
             into v_miid , v_mrscode , v_mrecode , v_mrsl , v_mrdatasource ,v_reshbz, v_rewcbz, v_reifreset, v_reifstep
      from request_zlsf where reno = p_reno;
    elsif p_gdtype = 'BJSF' then
      select miid, mircode, rercode, abs(rercode - mircode), 'Z', reshbz, rewcbz, reifreset, reifstep
             into v_miid , v_mrscode , v_mrecode , v_mrsl , v_mrdatasource ,v_reshbz, v_rewcbz, v_reifreset, v_reifstep
      from request_bjsf where reno = p_reno;
    else
      o_log := '请正确输入工单类型。';
      return;
    end if;

    if v_reshbz <> 'Y' or v_reshbz is null then o_log := '工单未审核，无法' || v_gdtype_name || '。工单编号：'|| p_reno || chr(10); return; end if;
    if v_rewcbz = 'Y' then  o_log := '工单已完成，无法' || v_gdtype_name || '。工单编号：'|| p_reno || chr(10); return; end if;

    o_log := '开始执行' || v_gdtype_name || '工单。工单编号：'|| p_reno || chr(10);
    --生成抄表信息
    ins_mr(v_miid , v_mrscode , v_mrecode , v_mrsl , v_mrdatasource, p_reno, v_reifreset, v_reifstep, v_mrid, v_insmr_log);
    o_log := o_log || '开始执行工单。生成抄表记录：'|| v_insmr_log || v_mrid || chr(10);
    --算费
    pg_cb_cost.calculatebf(v_mrid, '02', o_mrrecje01, o_mrrecje02, o_mrrecje03, o_mrrecje04, o_mrsumje, v_cal_log);
    o_log := o_log || '开始执行' || v_gdtype_name || '工单。算费：'|| v_cal_log || chr(10);

    if p_gdtype = 'ZLSF' then
      update request_zlsf set rewcbz = 'Y' where reno = p_reno;
    elsif p_gdtype = 'BJSF' then
      update request_bjsf set rewcbz = 'Y' where reno = p_reno;
    end if;

    commit;
    o_log := o_log || v_gdtype_name || '工单完成。工单编号：'|| p_reno;

  exception
      when no_data_found then o_log := '无效的工单号：' || p_reno;
      return;
  end;

  --生成抄表记录
  procedure ins_mr(p_miid varchar2, p_mrscode number, p_mrecode number, p_mrsl number,
            p_mrdatasource varchar2, p_mrgdid varchar2, p_mrifreset varchar2, p_mrifstep varchar2,
            o_mrid out varchar2, o_log out varchar2) is
    v_rowcount number;
  begin
    o_mrid := fgetsequence('METERREAD');

    insert into bs_meterread (mrid, mrmonth, mrsmfid, mrbfid, mrccode, mrmid, mrstid, mrcreadate, mrreadok, mrday, mrrdate, mrprdate, mrrper,
       mrscode, mrecode, mrsl, mrifsubmit, mrifhalt, mrdatasource, mrifrec, mrrecsl, mrpfid, mrgdid, mrifreset, mrifstep)
    select o_mrid, to_char(sysdate, 'yyyy.mm'), mismfid, mibfid, micode, miid, mistid, sysdate, 'N', sysdate, sysdate, sysdate, '1',
           p_mrscode, p_mrecode, p_mrsl, 'Y', 'N', p_mrdatasource, 'N', 0, mipfid, p_mrgdid, p_mrifreset, p_mrifstep
    from bs_meterinfo
    where miid = p_miid;
    v_rowcount := sql%rowcount;

    commit;
    if v_rowcount = 1 then
      o_log := '生成抄表记录成功';
    else
      o_log := '生成抄表记录失败';
    end if;

  end;

end pg_rectrans;
/

