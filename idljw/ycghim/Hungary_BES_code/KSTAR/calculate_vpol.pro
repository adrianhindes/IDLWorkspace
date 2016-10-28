pro calculate_vpol,shot,column=column,filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,$
  delta_t=delta_t,timerange=timerange,nosignal=nosignal,taurange=taurange,multi=multi,lowcut=lowcut

;*************************************************************************
;* CALCULATE_VPOL.PRO                             S. Zoletnik  2013-2014 *
;*************************************************************************
;* Calculates the mean time delay signal between pairs of poloidally     *
;* adjacent signals in one column of the 2D BES array.                   *
;*************************************************************************
;* INPUT:                                                                *
;*   shot: Shot number                                                   *
;*   column: The column to process                                       *
;*   filte_low, filter_high, filter_order: Signal filtering parameters   *
;*   delta_t: The time interval length of the correlation calculation    *
;*   timerange: The full time range to process. THis will be cut into    *
;*              della_t long signal pieces for processing.               *
;*   /nosignal: Do not load signals, they are already in the cache.      *
;*   taurange: The time lag range in which to search for the maximum of  *
;*             the correlation.                                          *
;*   /multi: If this is set the correlations will be averaged before     *
;*           maximum search, otherwise the maximum location will be      *
;*           averaged.                                                   *
;*************************************************************************


default,shot,9212
default,timerange,[3,3.1]
default,column,4
default,taurange,[0,10]*1e-6
default,delta_t,1e-5
;default,filter_low,2e4
;default,filter_high,1e5
;default,filter_order,100


signals = strarr(4)
for row=1,4 do begin
  signals[row-1] = 'BES-'+i2str(row)+'-'+i2str(column)
endfor
if (not keyword_set(nosignal)) then begin
  for row=1,4 do begin
    get_rawsignal,shot,'KSTAR/'+signals[row-1],cache=i2str(shot)+'_'+signals[row-1],trange=timerange,errormess=errormess,/nocalibrate
    if (errormess ne '') then begin
      print,errormess
      return
    endif
  endfor
endif

if (not keyword_set(multi)) then begin
  for i=1,3 do begin
    sigproc_tde,i2str(shot)+'_'+signals[i-1],i2str(shot)+'_'+signals[i],td_signal=i2str(shot)+'_'+signals[i-1]+'_TD',tres_out=delta_t,$
      filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,lowcut=lowcut,/cs,$
      taurange=taurange,errormess=errormess

    if (errormess ne '') then begin
      print,errormess
      return
    endif
  endfor

  for i=1,3 do begin
    signal_cache_get,name=i2str(shot)+'_'+signals[i-1]+'_TD',data=d,time=t,errormess=errormess
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
  signal_cache_add,name=i2str(shot)+'_BES-'+i2str(column)+'-S_TD',data=d,time=t,errormess=errormess
  if (errormess ne '') then begin
    print,errormess
    return
  endif
endif else begin; not /multi
  nsig = n_elements(signals)
  signal1 = i2str(shot)+'_'+signals[0:nsig-2]
  signal2 = i2str(shot)+'_'+signals[1:nsig-1]
  sigproc_tde_multi,signal1,signal2,td_signal=i2str(shot)+'_BES-'+i2str(column)+'-SM_TD',tres_out=delta_t,$
      filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,lowcut=lowcut,/cs,$
      taurange=taurange,errormess=errormess
endelse
end