pro calculate_vpol_mir,shot,column=column,filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,$
  delta_t=delta_t,timerange=timerange,nosignal=nosignal,taurange=taurange



default,shot,9009
default,timerange,[0.5,6]
default,column,'L'
default,taurange,[0,10]*1e-6
default,delta_t,1e-5
default,filter_low,2e4
default,filter_high,2e5
default,filter_order,100
default,signal_type,'A'

channels_1 = [7,8,9,10,11,12,13]
channels_2 = [8,9,10,11,12,13,14]
nsig = n_elements(channels_1)
signals_1 = strarr(nsig)
signals_2 = strarr(nsig)
for i=0,nsig-1 do begin
  signals_1[i] = 'ECEI/MIR_'+column+i2str(channels_1[i],digits=2)+'_'+signal_type
  signals_2[i] = 'ECEI/MIR_'+column+i2str(channels_2[i],digits=2)+'_'+signal_type
endfor

if (not keyword_set(nosignal)) then begin
  for ich=1,nsig do begin
    get_rawsignal,shot,'KSTAR/'+signals_1[ich-1],cache=i2str(shot)+'_'+signals_1[ich-1],trange=timerange,errormess=errormess,/nocalibrate,/search_cache
    if (errormess ne '') then begin
      print,errormess
      return
    endif
    get_rawsignal,shot,'KSTAR/'+signals_2[ich-1],cache=i2str(shot)+'_'+signals_2[ich-1],trange=timerange,errormess=errormess,/nocalibrate,/search_cache
    if (errormess ne '') then begin
      print,errormess
      return
    endif
  endfor
endif

for i=1,nsig do begin
  print,i2str(i)+'/'+i2str(nsig)
  wait,0.1
  sigproc_tde,i2str(shot)+'_'+signals_1[i-1],i2str(shot)+'_'+signals_2[i-1],td_signal=i2str(shot)+'_'+signals_1[i-1]+'_TD',tres_out=delta_t,$
    filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,/cs,$
    taurange=taurange,errormess=errormess

  if (errormess ne '') then begin
    print,errormess
    return
  endif
endfor

for i=1,nsig do begin
  signal_cache_get,name=i2str(shot)+'_'+signals_1[i-1]+'_TD',data=d,time=t,errormess=errormess
  if (errormess ne '') then begin
    print,errormess
    return
  endif
  if (not defined(sum_td)) then begin
    sum_td = d
  endif else begin
    sum_td = sum_td+d
  endelse
endfor
signal_cache_add,name=i2str(shot)+'_MIR-'+i2str(column)+'-S_TD',data=d,time=t,errormess=errormess
if (errormess ne '') then begin
  print,errormess
  return
endif

end