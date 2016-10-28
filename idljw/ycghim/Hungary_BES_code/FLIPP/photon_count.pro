pro photon_count,shot,channel,data_source=data_source,step=step,tmax=tmax,$
   trange=trange,in_data=d,in_time=t,title=title,baseline_trange=baseline_trange,$
   baseline_value=baseline_value,nocalibrate=nocalibrate,nolegend=nolegend,$
   axisthick=axisthick,linethick=linethick,font=font,charsize=charsize,$
   filename=filename,datapath=datapath,negative=negative
; *************************************************************************
; PHOTON_COUNT.PRO                            S. Zoletnik 2003
; Determine photon and other statistics of a signal.
; Plots the RMS noise vs. averaging length.
;
; INPUT:
;  shot: shot number
;  channel: Channel name (See get_rawsignal.pro)
;  data_source: The data source (see get_rawsignal.pro)
;  in_data,in_time: two arrays with dat and timevector of the input signal. If these
;             parameters are set, the data will not be read using shot,channel
;             and datra_source
;  step: Thes step length in consequtive averaging (average this many points)
;  tmax: Maximum averaging length in sec
;  trange: Time range for data read.
;  baseline_trange: a time range where the signal is 0. Average signal from here 
;                   will be subtacted
; baseline_value: subtract this as a baseline value
; /nocalibrate: do not calibrate signal
; /negative: SIgnal is negative, multiply by -1
; *************************************************************************

default,axisthick,1
default,linethick,1
default,charsize,1
default,font,-1   
default,step,3
step = long(step/2)*2+1 

if (defined(d) and defined(t)) then data_set=1
if (not keyword_set(data_set)) then begin
  get_rawsignal,shot,channel,t,d,data_source=data_source,trange=trange,errormess=errormess,nocalib=nocalibrate,$
    filename=filename,datapath=datapath
  if (errormess ne '') then begin
    print,errormess
    return
  endif  
  if (n_elements(t) le 1) then begin
    print,'No data in timewindow.'
    return
  endif
endif 

if (keyword_set(negative)) then d = -1*d

if (keyword_set(baseline_trange)) then begin
  if (defined(baseline_value)) then begin
    errormess = 'Set only baseline_trange OR baseline_value.'
    print,errormess
    return
  endif  
  get_rawsignal,shot,channel,tb,db,data_source=data_source,trange=baseline_trange
  if (errormess ne '') then begin
    print,'Error getting baseline data,'
    print,errormess
    return
  endif  
  bl = total(db)/n_elements(db)
  d = d-bl
endif else begin
  if (defined(baseline_value)) then begin
    d = d-baseline_value
  endif
endelse    
  

d = abs(float(d))


default,tmax,(max(t)-min(t))/20
sampletime=t[1]-t[0]
multmax = tmax/sampletime
n = n_elements(t)


mult = 1
while ((mult lt multmax) and (n gt 10)) do begin
  avr = total(d)/n
  rms = sqrt(total((d-avr)^2)/n)
  if (not keyword_set(tscale)) then begin
    tscale = float(sampletime*mult)
    scatter = rms
    avrscale = avr
  endif else begin
    tscale = [tscale,sampletime*mult]
    scatter = [scatter,rms]
    avrscale = [avrscale,avr]
  endelse
  mult = mult*step
  d = smooth(d,step)
  n = long(n/step)
  if (n ge 10) then begin
    ind = lindgen(n)*step+fix(step/2)
    d = d[ind]
  endif  
endwhile

erase
if (not keyword_set(nolegend)) then time_legend,'photon_count.pro'
plotsymbol,0
yrange = [min(scatter/avrscale)*0.8,max(scatter/avrscale)*1.5]
get_rawsignal,data_names=data_names
if (not keyword_set(data_set)) then begin
  default,title,'Shot: '+i2str(shot)+' channel: '+channel+' trange=['+$
  string(trange[0],format='(F6.3)')+','+string(trange[1],format='(F6.3)')+']s'
endif else begin
  default,title,' '
endelse    
plot,tscale,scatter/avrscale,xrange=[sampletime/2,max(tscale)*3],xstyle=1,xtype=1,$
    yrange=yrange,ystyle=1,ytype=1,xtitle='Timescale [s]',$
    ytitle='RMS rel. scatter',/noerase,psym=8,symsize=1,$
    title=title,position=[0.15,0.15,0.85,0.85],xthick=axisthick,ythick=axisthick,$
    thick=linethick,font=font,charsize=charsize,charthick=axisthick

ratemax = fix(alog(1/(scatter[0]/avr[0])^2/sampletime)/alog(10))+1
rate = float(ratemax)
stop_while = 0 
while (not stop_while) do begin
  yy = 1/sqrt(tscale*10^rate)
  if (min(yy) gt yrange[1]/4) then begin
    stop_while = 1
  endif else begin  
    oplot,tscale,yy,linestyle=2,thick=linethick
    xpos = tscale[n_elements(tscale)-1]*1.2
    ypos = yy[n_elements(yy)-1]
    if (ypos lt yrange[0]) then begin
      ind = where(yy ge yrange[0]*1.2)
      if (ind[0] ge 0) then begin
        ypos = yy[ind[n_elements(ind)-1]]
        xpos = tscale[ind[n_elements(ind)-1]]*1.2
      endif
    endif    
    xyouts,xpos,ypos,'10!U'+i2str(rate)+'!D',font=font,charsize=charsize,charthick=axisthick
    rate = rate-1
  endelse  
endwhile

end
