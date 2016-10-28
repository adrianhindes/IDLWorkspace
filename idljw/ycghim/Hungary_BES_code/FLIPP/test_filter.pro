pro test_filter,filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,$
     normalize=normalize,filter_symmetric=filter_symmetric,response=response
;******************************************************************
;* TEST_FILTER                    S. Zoletnik  4.16.2010          *
;*                                                                *
;* Test the bandpass_filter_data function. Plot power spectrum    *
;* of filtered white noise or plot response for a pulse.          *
;* The unfiltered power level is 1.                               *
;*                                                                *
;* INPUT:                                                         *
;*   filter_low: Lower frequnency band limit                      *
;*   filter high: Upper frequency band limit                      *
;*   filter_order: The order of the FIR filter                    *
;*                 (default from bandpas_filter_data)             *
;*   filter_symmetric:                                            *
;*           1: use temporally symmetric filter.                  *
;*           0: to use asymmetric (deteministic) filter. In this  *
;*              case filtering is less optimal if frequency space.*
;*   /normalize: Use /normalize switch in convol function         *
;*   /response: Plot pulse response                               *
;******************************************************************
default,filter_high,1e5


sampletime = 1e-6

if (not keyword_set(response)) then begin
  s = randomn(seed,1000000)

  signal_cache_add,data=s/1e-3,name='s',sampletime=sampletime, starttime=0,errormess=e
  if (e ne '') then begin
    print,e
    return
  endif

  sf = bandpass_filter_data(s,sampletime=sampletime,filter_high=filter_high,filter_order=filter_order,$
             filter_low=filter_low,errormess = e,/silent,/verbose,normalize=normalize,filter_symmetric=filter_symmetric)
  print,'Filter_order:'+i2str(filter_order)
  if (e ne '') then begin
    print,e
    return
  endif
  signal_cache_add,data=sf/1e-3,name='sf',sampletime=sampletime, starttime=0,errormess=e
  if (e ne '') then begin
    print,e
    return
  endif

  fluc_correlation,0,ref='cache/sf',/plot_power,fres=1e2,ytype=1,xtype=1,frange=[1e2,5e5],timerange=[0,1],yrange=[1e-4,1e1]
; Uncomment this to test through fluc_correlation
;  fluc_correlation,0,ref='cache/s',/plot_power,fres=1e3,ytype=1,xtype=1,frange=[1e3,5e5],timerange=[0,1],yrange=[1e-4,1e1],$
;      filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,filter_symmetric=filter_symmetric

endif else begin
  s = fltarr(100000)
  s[50000] = 1
  sf = bandpass_filter_data(s,sampletime=sampletime,filter_high=filter_high,filter_order=filter_order,$
             filter_low=filter_low,errormess = e,/silent,/verbose,normalize=normalize,filter_symmetric=filter_symmetric)
  if (e ne '') then begin
    print,e
    return
  endif
  erase
  plot, s[50000-filter_order-2:50000+filter_order+2],pos=[0.1,0.6,0.9,0.9],/noerase,xstyle=1
  plot, sf[50000-filter_order-2:50000+filter_order+2],pos=[0.1,0.1,0.9,0.4],/noerase,xstyle=1
endelse


end