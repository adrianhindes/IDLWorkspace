pro smbi_correlation_calc, shot, refchannel=refchannel, crossphase=crossphase, crosspower=crosspower, norm=norm, crosscorr=crosscorr, $
                           filter_low=filter_low, filter_high=filter_high
  
default, shot, 6352
default, refchannel, 'BES-1-6'
default, taurange, [-30,30]
default, crosspower, 0
default, crossphase, 0
default, crosscorr, 0
cd, 'D:\KFKI\Measurements\KSTAR\Measurement'
  case shot of
    6352: t_smbi=2.7
    6353: t_smbi=2.5
    ;6376: t_smbi=[2.2,2.7,3.2]
  endcase
  
  if n_elements(t_smbi) eq 1 then begin
    timerange_nosmbi=[t_smbi-0.1, t_smbi-0.05]
    timerange_smbi=[t_smbi+0.05, t_smbi+0.1]
  endif else begin
    print, 'Right now only one smbi injection is allowed (there would be no sense of before after!)'
    return
  endelse
  if (crossphase+crosspower+crosscorr gt 1) then begin
    print, 'Only one switch is allowed!'
    return
  endif
erase

hardon, /color
if not (keyword_set(filter_low) or keyword_set(filter_high)) then begin
  show_all_kstar_bes_power, shot, timerange=timerange_nosmbi, crossphase=crossphase,crosscorr=crosscorr, crosspower=crosspower, refchannel=refchannel, taurange=taurange, norm=norm, ytype=0
  xyouts, 0.7, 0.99, 'Before SMBI', /norm
  erase
  show_all_kstar_bes_power, shot, timerange=timerange_smbi, crossphase=crossphase,crosscorr=crosscorr, crosspower=crosspower, refchannel=refchannel, taurange=taurange, norm=norm, ytype=0
  xyouts, 0.7, 0.99, 'After SMBI', /norm
endif else begin
  show_all_kstar_bes_power, shot, timerange=timerange_nosmbi, crossphase=crossphase,crosscorr=crosscorr, crosspower=crosspower, $
                            refchannel=refchannel, taurange=taurange, filter_low=filter_low, filter_high=filter_high, norm=norm, ytype=0
  xyouts, 0.7, 0.99, 'Before SMBI', /norm
  erase
  show_all_kstar_bes_power, shot, timerange=timerange_smbi, crossphase=crossphase,crosscorr=crosscorr, crosspower=crosspower,$
                            refchannel=refchannel, taurange=taurange, filter_low=filter_low, filter_high=filter_high, norm=norm, ytype=0
  xyouts, 0.7, 0.99, 'After SMBI', /norm
endelse
if not keyword_set(norm) then begin
  if crosspower then str='crosspower'
  if crossphase then str='crossphase'
  if crosscorr then str='crosscorr'
endif else begin
  if crosspower then str='crosscoherence_norm'
  if crossphase then str='crossphase_norm'
  if crosscorr then str='crosscorr_norm'
endelse
hardfile, 'smbi_calc_correlation_'+str+'_'+strtrim(shot,2)+'.ps'
stop
end