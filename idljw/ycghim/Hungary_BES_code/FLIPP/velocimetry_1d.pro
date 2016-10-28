pro velocimetry_1d,data_arr,time,resolution=resolution,delay=delay,tvec_delay_tvec=delay_tvec,$
           search_range=search_range,corr_limit=corr_limit,corr_int=corr_int,corr_value=corr_value,power_value=power_value,$
           nolimit=nolimit,errormess=errormess,norm=norm

;***************************************************************************
;* VELOCIMETRY_1D.PRO                       S. Zoletnik  28.06.2014        *
;***************************************************************************
;* From the 2D input data (time,space) calculates the time delay for each  *
;* timepoint by searching for the maximum place of the spatial correlation *
;* function between two consecutive time slices. The original spatial      *
;* resolution is interpolated to <resolution> points.                      *
;* Successive correlation functions are recursively integrated with        *
;* <corr_int> timepoit prior to maximum search.                            *
;* Only those points are kept where the correlation maximum value is above *
;* <corr_limit> and not at any of the search range edges, therefore the    *
;* output time delay signal is not necessarily equidistantly sampled       *
;***************************************************************************
;* INPUT:                                                                  *
;*   data_arr: The 2D data array (time,space)                              *
;*   column: The column to process                                         *
;*   time: The time  vector                                                *
;*   resolution: The number of points (subpixels) to use in the spatial    *
;*               direction                                                 *
;*   search_range: The search range for the correlation maximum in         *
;*                  subpixels                                              *
;*   resolution: The number of subsampixels in the whole spatial range.    *
;*   search_range: The range in which the velocity is searched [subpixel]  *
;*   corr_int: The intgegration time for the correlation change [timestep] *
;*   corr_limit: Time delay values will be thrown away below this          *
;*               correlation maximum                                       *
;*   /nolimit: Do not throw away points, return all timepoints.            *
;*   /norm: Calculate normalized correlation function.                     *
;* OUPUT:                                                                  *
;*   delay: The array of delay values in subpixels.                        *
;*   tvec_delay: The time vector for the delays.                           *
;*   corr_value: The array of corr. maximum values for each time point     *
;*   power_value: The power vs time                                        *
;*   errormess: Error message or ''                                        *
;***************************************************************************

errormess = ''

default,corr_limit,0.9
; data_arr: data[time,space]
; search_range: maximum search range in the subsampled resolution

corr_w = exp(-1./double(corr_int))
nt = (size(data_arr))[1]
ns = (size(data_arr))[2]
default,search_range,[-resolution/ns,resolution/ns]

if ((search_range[0]*(-1) gt (resolution-1)) or (search_range[1] gt (resolution-1)) $
     or ((search_range[1]-search_range[0]) gt (resolution-2))) then begin
  errormess = 'velocimetry_1d.pro: Bad wide search range.'
  return
endif

data_s = fltarr(nt,resolution)
x_int = findgen(resolution)/(resolution-1)*(ns-1)
x_orig = findgen(ns)
for i=0L,nt-2 do begin
 ; data_s[i,*] = spline(x_orig,reform(data_arr[i,*]),x_int)
  data_s[i,*] = interpol(reform(data_arr[i,*]),resolution)
endfor
lags = indgen(search_range[1]-search_range[0]+1)+search_range[0]
delay = fltarr(nt-1)
corr_value = fltarr(nt-1)
power_value = fltarr(nt-1)
startind = (-search_range[0]) > 0
endind = (resolution-search_range[1]-1)<(resolution-1)
;xx = findgen(resolution)
corr = fltarr(search_range[1]-search_range[0]+1)
for i=0L,nt-2 do begin
  act_corr = fltarr(search_range[1]-search_range[0]+1)
  s1 = reform(data_s[i,startind:endind])
  s1tot = total(s1^2)
  power_value[i] = s1tot
  ;s1 = s1-mean(s1)
  ;p = poly_fit(xx,s1,1)
  ;s1 = s1-p[0]-p[1]*xx
  for j=search_range[0],search_range[1] do begin
    s2 = reform(data_s[i+1,startind+j:endind+j])
    ;s2 = s2-mean(s2)
    ;p = poly_fit(xx,s2,1)
    ;s2 = s2-p[0]-p[1]*xx
    if (keyword_set(norm)) then begin
      s2tot = total(s2^2)
      if ((s1tot ne 0) and (s2tot ne 0)) then begin
        act_corr[j-search_range[0]] = total(s1*s2)/sqrt(s1tot*s2tot)
      endif else begin
        act_corr[j-search_range[0]] = 0
      endelse
    endif else begin
      act_corr[j-search_range[0]] = total(s1*s2)
    endelse
  endfor
;  corr =  c_correlate(reform(data_s[i,*]),reform(data_s[i+1,*]),lags)
  corr = corr*corr_w+act_corr*(1-corr_w)
  ret = parabola_extremum(x_array=lags,y_array=corr)
  delay[i] = ret[0]
  corr_value[i] = ret[1]
  if (0) then begin
    wset,0
    yrange = [min(data_s[i:i+1,*]),max(data_s[i:i+1,*])]
    plot,reform(data_s[i,*]),title=i2str(i)+'  shift='+string(ret[0],format='(F5.2)'),yrange=yrange
    oplot,reform(data_s[i+1,*]),line=2
    plots,[startind,startind],yrange,linest=2
    plots,[endind,endind],yrange,linest=2
    wset,1
    plot,lags,corr,yrange=[0,max(corr)],ystyle=1
    wait,0.1
    ;if (i gt 100) then stop
  endif
endfor

delay_tvec = (time[0:nt-2]+time[1:nt-1])/2
if (not keyword_set(nolimit)) then begin
  ind = where((corr_value gt corr_limit) and (delay ne search_range[0]) and (delay ne search_range[1]))
  if (ind[0] ge 0) then begin
    delay_tvec = delay_tvec[ind]
    delay = delay[ind]
    corr_value = corr_value[ind]
    power_value = power_value[ind]
  endif
endif
end