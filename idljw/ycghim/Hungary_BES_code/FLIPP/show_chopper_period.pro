pro show_chopper_period,shot,channels=channels,data_source=data_source,timerange=timerange,$
          errormess=errormess,thick=thick,charsize=charsize,symsize=symsize,norm=norm,$
          nolegend=nolegend,nopara=nopara,datapath=datapath,check_channel=check_channel,$
          subch_mask_1=subch_mask_1,subch_mask_2=subch_mask_2


;*****************************************************************************************
;* SHOW_CHOPPER_PERIOD                                                                   *
;* S. Zoletnik    01.07.2008                                                             *
;*****************************************************************************************
;* Program to average and plot signals over chopper periods in a fast deflection         *
;*  measurement.                                                                         *
;* INPUT:                                                                                *
;*   shot: Shot number                                                                   *
;*   channels: List of channel names (string array)                                      *
;*   data_source: Data source as used in get_rawsignal.pro                               *
;*   datapath: See get_rawsignal.pro                                                     *
;*   timerange: Time range to process [start,stop] in seconds. If not specified will     *
;*              use all available data.                                                  *
;*   /norm: Normalise average signals to [0,1] range before plotting.                    *
;*          Otherwise only minimum is subtracted. Default is to normalise, use norm=0 to *
;*          switch it off.                                                               *
;*   thick: Line axis and character line thickness (default: 1)                          *
;*   charsize: Character size (default: 1)                                               *
;*   symsize: symbol size (default: 1)                                                   *
;*   /nolegend: Do not print name and date on page.                                      *
;*   /nopara: Do not print input parameters on page.                                     *
;*   check_channel: The channel for which the subchannel read is checked by reading      *
;*                  signal with get_rawsignal with subch_sample changing from 0 to the   *
;*                  number of samples in one period.                                     *
;* OUTPUT:                                                                               *
;*   errormess: '' if no error occured, otherwise error message.                         *
;*****************************************************************************************

default,channels,['BES-2','BES-3','BES-4','BES-5','BES-6','BES-7','BES-8','BES-9','BES-10',$
                  'BES-11','BES-12','BES-13','BES-14','BES-15']

default,data_source,fix(local_default('data_source'))
default,datapath,local_default('datapath')
default,norm,1

if (not keyword_set(shot)) then begin
  errormess = 'No shot number is given.'
  return
endif

channel_n = n_elements(channels)

deflection_config,shot,data_source=data_source,start_sample=start_sample,period_n=period_n,$
                  period_cycle_n=period_cycle_n,datapath=datapath,starttime=starttime,period_time=period_time,$
                  errormess=errormess,mask_up=mask_up,mask_down=mask_down
if (errormess ne '') then begin
  print,errormess
  return
endif

if (defined(subch_mask_1)) then begin
  mask_up = subch_mask_1
endif
if (defined(subch_mask_2)) then begin
  mask_down = subch_mask_2
endif

if (not defined(timerange)) then begin
  start_period = 0L
  end_period = long(period_cycle_n)-1
  timerange = [start_time,start_time+(end_period+1)*period_time]
endif else begin
  start_period = long((timerange[0]-starttime)/period_time > 0)
  if (start_period ge period_cycle_n) then begin
    errormess = 'Start time is after deflection end time.'
    return
  endif
  end_period = long((timerange[1]-starttime)/period_time < long(period_cycle_n)-1)
endelse

sig = fltarr(period_n,channel_n)

for i=0,channel_n-1 do begin
  get_rawsignal,shot,channels[i],t,d,subchannel=0,data_source=data_source,errormess=errormess
  if (errormess ne '') then begin
    return
  endif
  for ip=start_period,end_period do begin
    sig[*,i] = sig[*,i] + d[ip*period_n+start_sample:ip*period_n+start_sample+period_n-1]
  endfor
  if keyword_set(norm) then begin
    if max(sig[*,i]) ne min(sig[*,i]) then begin
      sig[*,i] = (sig[*,i]-min(sig[*,i])) / (max(sig[*,i])-min(sig[*,i]))
    endif else begin
      sig[*,i] = sig[*,i]-min(sig[*,i])
    endelse
  endif else begin
    sig[*,i] = sig[*,i]/(end_period-start_period+1)
  endelse
endfor
step = max(sig)*1.15
yrange = [min(sig[*,0]),step*(channel_n-1)+max(sig[*,channel_n-1])]
erase
if (not keyword_set(nolegend)) then begin
  time_legend,'show_chopper_period.pro'
endif
samples = findgen(period_n)
plotsymbol,0
plot,samples,sig[*,0],/nodata,yrange=yrange,ystyle=1,xrange=[-0.5,period_n+0.5],xstyle=1,/noerase,$
  thick=thick,xthick=thick,ythick=thick,charthick=thick,charsize=charsize,pos=[0.1,0.15,0.65,0.9],xtitle='Sample'
for i=0,channel_n-1 do begin
  oplot,samples,sig[*,channel_n-i-1]+step*i,psym=-8,symsize=symsize,thick=thick
endfor
if (not keyword_set(nopara)) then begin
  txt = 'Shot: '+i2str(shot)+$
        '!Cdata_source: '+i2str(data_source)+$
        '!CChannels:!C'
  for i=0,channel_n-1 do txt = txt + '  '+channels[i]+'!C'
  txt = txt+ 'Timerange: ['+string(timerange[0],format='(F7.4)')+','+string(timerange[1],format='(F7.4)')+'] s!C'
  if (keyword_set(norm)) then txt = txt + '/norm!C'
  xyouts,0.67,0.9,/norm,txt,charsize=charsize,charthick=thick
endif

if (defined(check_channel)) then begin
  s_check = fltarr(period_n)
  for i=0,period_n-1 do begin
    get_rawsignal,shot,check_channel,t,d,subchannel=1,subch_mask=[i],data_source=data_source,$
                  errormess=errormess,trange=timerange
    if (errormess ne '') then begin
      return
    endif
    s_check[i] = mean(d)
  endfor
  plot,samples,s_check,xrange=[-0.5,period_n+0.5],xstyle=1,/noerase,pos=[0.7,0.1,0.95,0.4],$
      thick=thick,xthick=thick,ythick=thick,charthick=thick,charsize=charsize,psym=-1,symsize=symsize,$
      title=check_channel,xtitle='Sample'
  plotsymbol,0
  oplot,samples[mask_up],s_check[mask_up],psym=8,thick=thick,symsize=symsize
  plotsymbol,2
  oplot,samples[mask_down],s_check[mask_down],psym=8,thick=thick,symsize=symsize
endif
end


