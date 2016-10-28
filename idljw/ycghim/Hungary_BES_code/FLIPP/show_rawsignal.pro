pro show_rawsignal,shot,channels_in,errorproc=errorproc,$
         nolegend=nolegend,data_source=data_source,afs=afs,cdrom=cdrom,$
         trange=trange,timerange=timerange,title=tit,over=over,nointerpol=nointerpol,symsize=symsize,$
         linestyle=linestyle,thick=thick,charsize=charsize,psym=psym,yrange=yrange,color=color,nocalibrate=nocal,inttime=inttime,$
         subchannel=subchannel,ystyle=ystyle,datapath=datapath,filename=filename,$
         chan_prefix=chan_prefix,chan_postfix=chan_postfix, offset_trange=offset_trange,ytitle=ytitle,store_data=store_data,$
         position=position, noerase=noerase, xcharsize=xcharsize, ycharsize=ycharsize, filter_radiaton_pulses=radpulse_limit,$
         mode=mode, scale=scale, no_offset=no_offset, errormess=errormess,offset_timerange=offset_timerange

;***********************************************************************
; show_rawsignal.pro                 S. Zoletnik    10.9.1997
;***********************************************************************
; Program to plot a signal (Li-beam channel # <channel> or signal name)
; Can also plot the sum of several channels if channels_in is an array.
; INPUT:
;   shot: shot number
;   channels_in: channel name or channel name array
;   trange: time range [t1,t2]
;   timerange: Same as trange
;   errorproc: name of error processing routine to call on error
;   /nolegend: do not plot time and name of program
;   data_source: the data source code, see get_rawsignal
;   /nocalibrate: do not attempt to calibrate signal
;   inttime: integration time (in microsecond) to apply prior to plotting
;   subchannel: select subchannel (see get_rawsignal)
;   offset_trange: Subtract the mean signal in this timerange
;   offset_timerange: this is different from offset_trange, since this si simply passed to get_rawsignal.pro 
;   /no_offset: Do no offset subtraction (passed to get_rawsignal)
;   scale: multiply the data with this number
;   linestyle, thick, psym, symsize, position, noerase,
;   xcharsize, ycharsize, charsize: like in plot
;   For other keywords see get_rawsignal.pro
;***********************************************************************

default,channel_in,18
default,linestyle,0
default,color,!p.color
default,nocal,1
default,inttime,0
default,ystyle,0
default,xcharsize,1
default,ycharsize,1
default,thick,1
default,symsize,1
default,ytitle,'Signal [V]'
default,position,[0.1,0.1,0.8,0.8]
default, scale, 1

if (not defined(shot) or not defined(channels_in)) then begin
      errormess = 'Shot or channel is not set.'
      print,errormess
      return
endif

;if ((data_source le 5) and (size(channel_in))(1) ne 7) then channel='Li-'+i2str(channel_in) else channel=string(channel_in)

if (defined(timerange)) then begin
  default,trange,timerange
endif
if (defined(trange)) then begin
  if (defined(offset_trange)) then begin
    trange_read = [min([offset_trange[0], trange[0]]), max([offset_trange[1], trange[1]])]
  endif else begin
    trange_read = trange
  endelse
endif
for i=0,n_elements(channels_in)-1 do begin
  channel=channels_in[i]

  if defined(data_source) then data_source_w = data_source
  get_rawsignal,shot,channel,time_w,data_w,errorproc=errorproc,data_source=data_source_w,$
        afs=afs,cdrom=cdrom,trange=trange_read,data_names=data_names,nocalibrate=nocal,$
        subchannel=subchannel,errormess=errormess,datapath=datapath,filename=filename,$
        chan_prefix=chan_prefix,chan_postfix=chan_postfix,store_data=store_data,filter_radiaton_pulses=radpulse_limit,$
    no_offset=no_offset,offset_timerange=offset_timerange
  if (errormess ne '') then begin
    print,errormess
    return
  endif
  if (i  eq 0) then begin
    channel_tit = channel
  endif
  if ( i eq 1) then begin
    channel_tit = channel_tit+'...'
  endif
  if (not defined(time)) then begin
    time = time_w
    data = data_w
  endif else begin
    if (n_elements(time) ne n_elements(time_w)) then begin
      errormess = 'Time vector of channels is different.'
      print,errormess
      return
    endif
    ind = where(time ne time_w)
    if (ind[0] ge 0) then begin
      errormess = 'Time vector of channels is different.'
      print,errormess
      return
    endif
    data = data+data_w
  endelse
endfor


if (keyword_set(offset_trange)) then begin
  ind = where((time ge offset_trange[0]) and (time le offset_trange[1]))
  if (ind[0] lt 0) then begin
    errormess = 'No data in offset timerange.'
    print,errormess
    return
  endif
  data = data-total(data[ind])/n_elements(ind)
endif

default,trange,[min(time),max(time)]
ind=where((time ge trange(0)) and (time le trange(1)))
if ((min(ind) gt 0) or (max(ind) lt n_elements(time)-1)) then begin
  time=time(ind)
  data=data(ind)
endif

if (inttime ne 0) then begin
  data = integ(data,time,inttime*1e-6)
endif

if (not keyword_set(nointerpol)) then begin
  maxpoint=5000
  if ((size(time))(1) gt maxpoint) then begin
    time=interpol(time,maxpoint)
    data=interpol(data,maxpoint)
  endif
endif

data=data*scale

;yrange_max = [min(data),max(data)]
;default,yrange,yrange_max+(yrange_max[1]-yrange_max[0])*0.05*[-1,1]
if (not keyword_set(over)) then begin
;  if (not keyword_set(noerase)) then erase
  if (not keyword_set(noerase) AND not keyword_set(mode)) then erase
  if (not keyword_set(nolegend)) then time_legend,'show_rawsignal.pro'
  if (not keyword_set(tit)) then begin
    tit=i2str(shot)
    tit=tit+'  Channel "'+channel_tit
      if (keyword_set(subchannel)) then tit=tit+' subch '+i2str(subchannel)
    tit=tit+'"'
  endif
  if (keyword_set(charsize)) then begin
    xcharsize=charsize
    ycharsize=charsize
  endif
  if keyword_set(mode) then begin
    plot,time,data,xtitle='Time [s]',xrange=trange,xstyle=1,xthick=thick,$
    title=tit,yrange=yrange,ystyle=ystyle,ythick=thick,ytitle=ytitle,$
    linestyle=linestyle,thick=thick,psym=psym,symsize=symsize,color=color,charthick=thick,$
    xcharsize=xcharsize, ycharsize=ycharsize
  endif else begin
    plot,time,data,xtitle='Time [s]',xrange=trange,xstyle=1,xthick=thick,$
    title=tit,yrange=yrange,ystyle=ystyle,ythick=thick,ytitle=ytitle,$
    linestyle=linestyle,thick=thick,psym=psym,symsize=symsize,color=color,charthick=thick,$
    xcharsize=xcharsize, ycharsize=ycharsize, /noerase, position=position
  endelse
endif else begin
  oplot,time,data,linestyle=linestyle,color=color,psym=psym,thick=thick,symsize=symsize
endelse
end
