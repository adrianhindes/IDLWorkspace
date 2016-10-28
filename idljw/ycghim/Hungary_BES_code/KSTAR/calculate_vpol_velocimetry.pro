pro calculate_vpol_velocimetry,shot,column=column,filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,$
  timerange=timerange,lowcut=lowcut,inttime=inttime,fitorder=fitorder,$
  errormess=errormess,signal_out=signal_out,correlation_out=corr_name_out,tres=tres,search_range=search_range,resolution=resolution,corr_int=corr_int,$
  plot_histogram=plot_histogram,corr_limit=corr_limit,norm=norm,power_out=power_name_out,nolimit=nolimit

;*************************************************************************
;* CALCULATE_VPOL_VELOCIMETRY.PRO           S. Zoletnik  28.06.2014      *
;*************************************************************************
;* Calculates the poloidal velocity as a function of time from the       *
;* poloidal movement of structures in the KSTAR BES measurement.         *
;* At present this program works only with horizontal BES array.         *
;*************************************************************************
;* INPUT:                                                                *
;*   shot: Shot number                                                   *
;*   column: The column to process                                       *
;*   filter_low, filter_high, filter_order: Signal filtering parameters  *
;*   lowcut: Integration time for highpass filter in microsec            *
;*   fitorder: Fit order for polynomial trend removal as signal filtering*
;*   inttime: Integration time on the signal in microsec                 *
;*   rows: The rows to process in the BES data. (1...)                   *
;*         Must be contiuous in increasing order.                        *
;*   resolution: The number of poloidal subsamples in the whole poloidal *
;*               range                                                   *
;*   tres: Time resolution of the velocity calculation (sec)             *
;*   search_range: The range in which the velocity is searched [km/s]    *
;*   corr_int: The intgegration time for the correlation change  [s]     *
;*   signal_out: Output signal name in signal cache                      *
;*   correlation_out: Output corr. value array name in signal cache      *
;*   power_out: The name of the power vs time in the signal cache        *
;*   corr_limit: Time delay values will be thrown away below this        *
;*               correlation maximum                                     *
;*   /nolimit: Do not throw away points, return all timepoints.          *
;*   /norm: Calculate normalized correlation function.                   *
;*   /plot_histogram: Plot a histogram of velocity                       *
;* OUPUT:                                                                *
;*   errormess: Error message                                            *
;*************************************************************************

default,column,4
default,rows, [1,2,3,4]
default,resolution,40
default,signal_out,i2str(shot)+'_'+i2str(column)+'_v'
default,column,3
default,tres,5e-6
default,search_range,[-10,10]
default,corr_int,1e-5
default,corr_limit,0
default,nolimit,1

nrow = n_elements(rows)
signals = strarr(nrow)
for i=0,nrow-1 do begin
  signals[i] = 'BES-'+i2str(rows[i])+'-'+i2str(column)
endfor
for i=0,nrow-1 do begin
  get_rawsignal,shot,'KSTAR/'+signals[i],time,d,timerange=timerange,errormess=errormess,/nocalibrate,sampletime=sampletime
  if (errormess ne '') then begin
    print,errormess
    return
  endif
  nt = n_elements(d)

  ; Low frequency filtering
  if (keyword_set(lowcut)) then begin
    d = d - integ(d,lowcut*1e-6/sampletime)
  endif

  ; Polynomial fit as baseline subtracttion
  if (defined(fitorder)) then begin
    x = dindgen(nt)*sampletime
    p = poly_fit(x,double(d),fitorder)
    b = p[0]
    for ifit=1,fitorder do begin
      b = b + p[ifit]*x^ifit
    endfor
    d = d - b
  endif

  ; High frequency filtering (integration)
  if (keyword_set(inttime)) then begin
    d = integ(d,inttime*1e-6/sampletime)
  endif

  ; Bandpass filter
  d = bandpass_filter_data(d,sampletime=sampletime,$
             filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,$
             filter_symmetric=filter_symmetric,errormess=errormess)
  if (errormess ne '') then begin
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,errormess,/forward
    endif
    return
  endif

  tres_sample = round(tres/sampletime)
  nt_new = nt/tres_sample
  ind = lindgen(nt_new)*tres_sample
  d_samp = d[ind]
  t_samp = time[ind]

  if (i eq 0) then begin
    data = fltarr(n_elements(d_samp),nrow)
  endif
  data[*,i] = d_samp
endfor

detpos=getcal_kstar_spat(shot,/trans)
; The full poloidal range in m
full_range = abs((detpos[column-1,rows[nrow-1]-1,1]-detpos[column-1,rows[0]-1,1])/1000.)
; Converting the velocity range to shift range in subpixel resolution units
search_range_subpixel = fix(search_range*1e3*tres / (full_range/resolution))

velocimetry_1d,data,t_samp,resolution=resolution,delay=velocity,tvec_delay=time_velocity,$
   search_range=search_range_subpixel,corr_int=corr_int/tres,corr_limit=corr_limit,nolimit=nolimit,corr_value=corr_value,$
   power_value=power_value,errormess=errormess,norm=norm
if (errormess ne '') then begin
  print,errormess
  return
endif

velocity = velocity*full_range/resolution/tres/1e3

if (keyword_set(plot_histogram)) then begin
  bin = float((search_range[1]-search_range[0]))/100
  h=histogram(velocity,bin=bin,min=search_range[0],max=search_range[1])
  plot,findgen(n_elements(h))*bin+search_range[0],h,title='Histogram of velocity, Total='+i2str(n_elements(velocity))+' valid points.',$
     xtitle='Velocity [km/s]',ytitle='Number or points'
  oplot,[0,0],!y.crange,line=1
endif

signal_cache_add,data=velocity,time=time_velocity+tres/2,name=signal_out,$
   errormess=errormess
if (errormess ne '') then print,errormess

if (defined(corr_name_out)) then begin
  signal_cache_add,data=corr_value,time=time_velocity+tres/2,name=corr_name_out,$
     errormess=errormess
  if (errormess ne '') then print,errormess
endif

if (defined(power_name_out)) then begin
  signal_cache_add,data=power_value,time=time_velocity+tres/2,name=power_name_out,$
     errormess=errormess
  if (errormess ne '') then print,errormess
endif

end