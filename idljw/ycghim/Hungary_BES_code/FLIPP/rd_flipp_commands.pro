pro rd_flipp_commands,shotnr=shotnr,mode=mode,trange=trange,chnum=chnum, hardplot=hardplot, search_cache=search_cache, cache=cache,$
 auto_chopper=auto_chopper,	experiment=experiment,nsum=nsum,yrange=yrange,min_on_time=min_on_time, min_off_time=min_off_time,refchannel=refchannel,$
 nocalc=nocalc,timefile=timefile
	if local_default('online') EQ 1 then default, experiment, 'JET'
	if local_default('online') EQ 0 then default, experiment, 'JET_APDCAM'

if defined(trange) then timerange=trange

if experiment EQ 'JET_APDCAM' then begin
  default,prof_ch_num,24
  ;default,path,'D:\dokumentumok\BES\JET\JET-measure'
  default,path,local_default('path')
  default, shotnr,82129
  default, savepath,dir_f_name(path,'results')
  numchannel=32
endif
if experiment EQ 'JET' then begin
	;default, path,'D:\dokumentumok\BES\JET\JET-measure\'
	default,path,local_default('path')
	default, shotnr,81233
	default, savepath,dir_f_name(path,'results')
	numchannel=4
endif
if experiment EQ 'CXRS' then begin
	default, path,'d:\textor\data_processing\'
	default, shotnr,116354
	default, savepath,path+'results\'
	numchannel=32
endif
default, mode, 30
default, hardplot,0
cd, path
;stop
print, 'current working dirctory is: '+path
;fluc_correlation, 81095, refch='JET-JPF/DH/Y6-FAST:003', '81095on.time', /plot_pow, ytype=1, xtype=1, frange=[1e3,5e5], fres=1e3, yrange=[1e-11,1e-9]
;fluc_correlation, 81095, refch='JET-JPF/DH/Y6-FAST:003', '81095on.time', taurange=[-50,50], cut_length=2, filter_low=1e3
;fluc_correlation, 81095, refch='JET-JPF/DH/Y6-FAST:003', '81095on.time', taurange=[-50,50], filter_low=1e3
;fluc_correlation, 81095, refch='JET-JPF/DH/Y6-FAST:003', timerange=[47,47.5], /plot_pow, ytype=1, xtype=1, frange=[1e3,5e5], fres=1e3, yrange=[1e-11,1e-9], /overplot
!p.MULTI=[0,1,1]
case mode of

1: begin
!p.BACKGROUND=!d.n_colors-1
!p.COLOR=0
if hardplot EQ 0 then window,0,xsize=1024,ysize=800,title=i2str(shotnr)
if hardplot EQ 1 then hardon
if experiment EQ 'JET' then begin
  !p.MULTI=[0,2,2]
  ;!p.MULTI=[0,1,1]
  for i=1,4 do begin
    ;get_rawsignal, shotnr, 'JET-JPF/DH/Y6-FAST:00'+i2str(i), data_s=26,trange=trange,t,d
    ;mean=mean(integ(d,100))
    ;dev=stddev(integ(d,100))
    show_rawsignal, shotnr, 'JET-JPF/DH/Y6-FAST:00'+i2str(i), data_s=26, int=10, mode=mode, trange=trange;, yrange=[mean-dev,mean+dev]
    ;show_rawsignal, shotnr, 'JET-JPF/DH/Y6-FAST:00'+i2str(i), data_s=26, int=1000, trange=trange;, yrange=[mean-dev,mean+dev]
  endfor
endif
if experiment EQ 'JET_APDCAM' then begin
  show_all_jet_bes,shotnr,int=1000, path=path,timerange=trange, nsum=nsum,yrange=yrange
endif
if hardplot EQ 1 then hardfile, savepath+i2str(shotnr)+'raw_data_all_channels_'+experiment+'.ps'
end

2: begin
if experiment EQ 'JET' then begin
default,chnum,3
SELECT_TIME,shotnr,'JET-JPF/DH/Y6-FAST:00'+i2str(chnum), trange=trange, inttime=1000, auto_chopper=auto_chopper
endif
if experiment EQ 'JET_APDCAM' then begin
SELECT_TIME,shotnr,'BES-4-4', trange=trange, inttime=2000, auto_chopper=auto_chopper,/nocalibrate,min_on_time=min_on_time, min_off_time=min_off_time
endif
end

3: begin ;overview of 4 channel measurement power spectra
default,hardplot,0
;if hardplot EQ 0 then window,0,xsize=1024,ysize=800,title=i2str(shotnr)
if hardplot EQ 1 then hardon
!p.MULTI=[0,2,2]
!p.BACKGROUND=!d.n_colors-1
!p.COLOR=0
yrange=[1e-10,1e-8]
frange=[1e2,3e3]
fres=1e1
for i=1,4 do begin
 if hardplot EQ 0 then window,i,title=i2str(shotnr)+'_ch'+i2str(i)+'off'
 print, 'processing '+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_beam_off.ps'
 fluc_correlation, shotnr, refch='JET-JPF/DH/Y6-FAST:00'+i2str(i), i2str(shotnr)+'off.time', /plot_pow, xtype=1,ytype=1, frange=frange, fres=fres, yrange=yrange
 if hardplot EQ 1 then begin
   hardfile, savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_beam_off.ps'
   print, 'plot saved to '+savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_beam_off.ps'
 endif
endfor

for i=1,4 do begin 
 if hardplot EQ 0 then window,i+4,title=i2str(shotnr)+'_ch'+i2str(i)+'on'
 print, 'processing '+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_beam_on.ps'
 fluc_correlation, shotnr, refch='JET-JPF/DH/Y6-FAST:00'+i2str(i), i2str(shotnr)+'on.time', /plot_pow, xtype=1,ytype=1, frange=frange, fres=fres, yrange=yrange
 if hardplot EQ 1 then begin
   hardfile, savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_beam_on.ps'
   print, 'plot saved to '+savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_beam_on.ps'
 endif
endfor

end


4: begin ; JET BES signal power spectrum
for i=1,4 do begin

 ;window,i*2
 hardon
 trange1=[55,57]
 ;stop
 print, 'processing '+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_L-mode.ps'
 fluc_correlation, shotnr, refch='JET-JPF/DH/Y6-FAST:00'+i2str(i), i2str(shotnr)+'Lon.time', $
   /plot_pow,xtype=1,ytype=1, frange=[1e2,2e3], fres=1e1, yrange=[1e-11,1e-7], linethick=2, linestyle=0
 fluc_correlation, shotnr, refch='JET-JPF/DH/Y6-FAST:00'+i2str(i), i2str(shotnr)+'Loff.time',$
   /plot_pow, xtype=1,ytype=1, frange=[1e2,2e3], fres=1e1,/overplot, yrange=[1e-11,1e-7], linethick=1, linestyle=2
 hardfile, savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_L-mode.ps'
 print, 'plot saved to '+savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_L-mode.ps'

 hardon
 print, 'processing '+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_L-mode_lin_on.ps'
 fluc_correlation, shotnr, refch='JET-JPF/DH/Y6-FAST:00'+i2str(i), i2str(shotnr)+'Lon.time', $
   /plot_pow,xtype=1, frange=[1e2,3e3], fres=1e1, linethick=2, linestyle=0;, yrange=[1e-9,1e-7]
 hardfile, savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_L-mode_lin_on.ps'
 print, 'plot saved to '+savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_L-mode_lin_on.ps'

 ;window,i*2+1
 hardon
 trange2=[59,61]
 print, 'processing '+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_H-mode.ps'
 fluc_correlation, shotnr, refch='JET-JPF/DH/Y6-FAST:00'+i2str(i), i2str(shotnr)+'Hon.time', $
   /plot_pow, xtype=1,ytype=1, frange=[1e2,2e3], fres=1e1, yrange=[1e-11,1e-7], linethick=2, linestyle=0
 fluc_correlation, shotnr, refch='JET-JPF/DH/Y6-FAST:00'+i2str(i), i2str(shotnr)+'Hoff.time',$
    /plot_pow, xtype=1,ytype=1, frange=[1e2,2e3], fres=1e1,/overplot, yrange=[1e-11,1e-7], linethick=1, linestyle=2
 hardfile, savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_H-mode.ps'
 print, 'plot saved to '+savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_H-mode.ps'
 

 hardon
 print, 'processing '+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_H-mode_lin_on.ps'
 fluc_correlation, shotnr, refch='JET-JPF/DH/Y6-FAST:00'+i2str(i), i2str(shotnr)+'Hon.time', $
   /plot_pow,xtype=1, frange=[1e2,3e3], fres=1e1, linethick=2, linestyle=0;, yrange=[1e-9,1e-7]
 hardfile, savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_H-mode_lin_on.ps'
 print, 'plot saved to '+savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_H-mode_lin_on.ps'

endfor
end

5: begin ; overplots power spectra for H and L mode.
for i=1,4 do begin
!p.BACKGROUND=!d.n_colors-1
!p.COLOR=0
 hardon
 ;window,i,xsize=1024,ysize=800,title=i2str(shotnr)+'ch'+i2str(i)
 if shotnr EQ 81236 then begin
   if i EQ 1 then yrange=[1e-10,5e-9]
   if i EQ 2 then yrange=[1e-10,4e-8]
   if i EQ 3 then yrange=[1e-10,1e-8]
   if i EQ 4 then yrange=[1e-10,3e-8]
 endif
 if shotnr EQ 81237 then begin
   if i EQ 1 then yrange=[1e-10,1e-8]
   if i EQ 2 then yrange=[1e-10,1e-7]
   if i EQ 3 then yrange=[1e-10,1e-8]
   if i EQ 4 then yrange=[1e-10,2e-8]
 endif
 if shotnr EQ 81238 then begin
   yrange=[1e-10,1e-8]
 endif
 if shotnr EQ 81239 then begin
   yrange=[1e-9 ,4e-8]
 endif
 if shotnr EQ 81240 then begin
   yrange=[1e-10,1e-8]
 endif
 frange=[1e2,2e3]
  fluc_correlation, shotnr, refch='JET-JPF/DH/Y6-FAST:00'+i2str(i), i2str(shotnr)+'Hon.time', $
   /plot_pow, frange=frange, fres=1e1, yrange=yrange, linethick=2, linestyle=0;, ytype=1
  fluc_correlation, shotnr, refch='JET-JPF/DH/Y6-FAST:00'+i2str(i), i2str(shotnr)+'Lon.time', $
   /plot_pow, frange=frange, fres=1e1,/overplot, yrange=yrange, linethick=1, linestyle=2;, ytype=1
 hardfile, savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_L&H.ps'
endfor
end

6: begin ; overview for power spectra for each channel
yrange=[1e-10,3e-9]
frange=[1e3,2e4]
fres=200
for i=1,4 do begin
!p.BACKGROUND=!d.n_colors-1
!p.COLOR=0
 ;hardon
  if hardplot EQ 1 then hardon
  if hardplot EQ 0 then window,i,xsize=640,ysize=480,title=i2str(shotnr)+'ch'+i2str(i) 

  fluc_correlation, shotnr, refch='JET-JPF/DH/Y6-FAST:00'+i2str(i), i2str(shotnr)+'on.time', $
   /plot_power, frange=frange, fres=fres,yrange=yrange,xtype=0,ytype=0
   if hardplot EQ 1 then hardfile, savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_beam_on.ps'
endfor
end

61: begin ; overview for power spectra for each channel
yrange=[1e-10,3e-9]
frange=[1e3,2e4]
fres=200
for i=1,4 do begin
!p.BACKGROUND=!d.n_colors-1
!p.COLOR=0
 ;hardon
  if hardplot EQ 1 then hardon
  if hardplot EQ 0 then window,i,xsize=640,ysize=480,title=i2str(shotnr)+'ch'+i2str(i) 

  fluc_correlation, shotnr, refch='JET-JPF/DH/Y6-FAST:00'+i2str(i), i2str(shotnr)+'off.time', $
   /plot_power, frange=frange, fres=fres,yrange=yrange,xtype=0,ytype=0
   if hardplot EQ 1 then hardfile, savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_beam_off.ps'
endfor
end

62: begin ; overview for power spectra for each channel
;yrange=[1e-10,3e-9]
frange=[1e3,1e4]
fres=100
timerange=[45.5,45.6]
;timerange=[46,46.5]
for i=1,4 do begin
!p.BACKGROUND=!d.n_colors-1
!p.COLOR=0
 ;hardon
  if hardplot EQ 1 then hardon
  if hardplot EQ 0 then window,i,xsize=640,ysize=480,title=i2str(shotnr)+'ch'+i2str(i) 

  fluc_correlation, shotnr, refch='JET-JPF/DH/Y6-FAST:00'+i2str(i), timerange=timerange, $
   /plot_power, frange=frange, fres=fres,yrange=yrange,xtype=0,ytype=0
   if hardplot EQ 1 then hardfile, savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect.ps'
endfor
end

7: begin ; crosscorrelation with mirnov signal
yrange=[1e-10,2e-8]
frange=[1e2,3e3]
fres=1e1
for i=1,4 do begin
!p.BACKGROUND=!d.n_colors-1
!p.COLOR=0
 if hardplot EQ 1 then hardon
 if hardplot EQ 0 then window,i,xsize=640,ysize=480,title=i2str(shotnr)+'ch'+i2str(i)

 frange=[1e2,2e3]
  fluc_correlation, shotnr, refch='JET-JPF/DA/C1M-I801', plotchan='JET-JPF/DH/Y6-FAST:00'+i2str(i), i2str(shotnr)+'off.time', $
   /plot_power,frange=frange, yrange=yrange, fres=fres,ytype=1

 if hardplot EQ 1 then hardfile, savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_Hon_corr_mirnov.ps'
endfor
end

8: begin ; crosscorrelation with mirnov signal
yrange=[1e-10,1e-7]
frange=[5e2,5e3]
fres=16
for i=1,4 do begin
 if shotnr EQ 81237 then begin
   if i EQ 1 then yrange=[1e-10,2e-7]
   if i EQ 2 then yrange=[1e-10,2e-7]
   if i EQ 3 then yrange=[1e-10,2e-7]
   if i EQ 4 then yrange=[1e-10,2e-7]
 endif
 if shotnr EQ 81236 then begin
   if i EQ 1 then yrange=[1e-10,5e-9]
   if i EQ 2 then yrange=[1e-10,4e-8]
   if i EQ 3 then yrange=[1e-10,1e-8]
   if i EQ 4 then yrange=[1e-10,3e-8]
 endif
 if shotnr EQ 81238 then begin
   if i EQ 1 then yrange=[1e-10,1.3e-7]
   if i EQ 2 then yrange=[1e-10,1.3e-7]
   if i EQ 3 then yrange=[1e-10,1.3e-7]
   if i EQ 4 then yrange=[1e-10,1.3e-7]
 endif
 if shotnr EQ 81239 then begin
   yrange=[1e-9 ,4e-8]
 endif
 if shotnr EQ 81240 then begin
   yrange=[1e-10,1e-8]
 endif
 

!p.BACKGROUND=!d.n_colors-1
!p.COLOR=0
 if hardplot EQ 1 then hardon
 if hardplot EQ 0 then window,i,xsize=640,ysize=480,title=i2str(shotnr)+'ch'+i2str(i)

 fluc_correlation, shotnr, refch='JET-JPF/DA/C1M-I801', plotchan='JET-JPF/DH/Y6-FAST:00'+i2str(i), i2str(shotnr)+'on.time', $
  /plot_power,frange=frange, yrange=yrange, linethick=2, fres=fres,linestyle=0,xtype=1,ytype=1
 fluc_correlation, shotnr, refch='JET-JPF/DA/C1M-I801', plotchan='JET-JPF/DH/Y6-FAST:00'+i2str(i), i2str(shotnr)+'off.time', $
   /plot_power,frange=frange, yrange=yrange, linethick=2, fres=fres,linestyle=2,/overplot,xtype=1,ytype=1


 if hardplot EQ 1 then hardfile, savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_on_off_corr_mirnov.ps'

endfor
end

9: begin ; crosscorrelation with mirnov signal
loadct,13,file='COLORS.TBL'
t_res=0.1 ;timeresulution in seconds
trange_all=[53,57]
n_times=(trange_all[1]-trange_all[0])/t_res
t_arr=findgen(n_times)/(n_times-1)*(trange_all[1]-trange_all[0]-t_res)+trange_all[0]
  for i=1,1 do begin
    for j=0,n_times-1 do begin
      frange=[1e2,3e3]
      fres=1e1
      fluc_correlation, shotnr, refch='JET-JPF/DA/C1M-I801', plotchan='JET-JPF/DA/C1M-I801', timerange=[t_arr[j],t_arr[j]+t_res], $
        ;outfscale=outfreq,outpower=outpower, /plot_power, fres=fres, frange=frange
        outfscale=outfreq,outpower=outpower, /noplot, fres=fres, frange=frange
      if j EQ 0 then outpower_array=fltarr(4,n_times,n_elements(outpower))
      outpower_array[i-1,j,*]=outpower
      ;plot, outfreq,outpower_array[i-1,j,*]
      ;wait,0.01
      ;stop
    endfor

  if hardplot EQ 1 then hardon
  if hardplot EQ 0 then window,i,xsize=640,ysize=480,title=i2str(shotnr)+'ch'+i2str(i)
  loadct,5
  ;contour, outpower_array[i-1,*,*], t_arr, outfreq, yrange=frange, nlevels=500, /fill, MIN_VALUE=1e-9, MAX_VALUE=max(outpower_array[i-1,*,*])
  contour, outpower_array[i-1,*,*], t_arr, outfreq, yrange=frange, nlevels=1000, /fill, MIN_VALUE=0, MAX_VALUE=max(outpower_array[i-1,*,*])
    ;COLORBAR, BOTTOM=bottom, CHARSIZE=2., COLOR=color, DIVISIONS=divisions, $
    ;FORMAT=format, POSITION=[0.01,0.01,0.1,0.99], MAX=1., MIN=0., NCOLORS=ncolors, $
    ;PSCOLOR=pscolor, VERTICAL=1, TOP=top, RIGHT=1
  if hardplot EQ 1 then hardfile, savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_spectrogram.ps'
  ;stop
endfor
save, filename=savepath+i2str(shotnr)+'_spectrogram.sav'
end

10: begin ; crosscorrelation with other BES channel

timerange=[52.5,52.6]
taurange=[-1000,1000]

for i=1,4 do begin
  if i LT 4 then begin
    for j=i+1,4 do begin
      refch='JET-JPF/DH/Y6-FAST:00'+i2str(j)
      plotchan='JET-JPF/DH/Y6-FAST:00'+i2str(i)
      !p.BACKGROUND=!d.n_colors-1
      !p.COLOR=0
       if hardplot EQ 1 then hardon
       if hardplot EQ 0 then window,i+j,xsize=640,ysize=480,title=i2str(shotnr)+'_cross_channel: '+plotchan+'_refch: '+refch
      
       frange=[1e2,1e3]
        ;fluc_correlation, shotnr, refch='JET-JPF/DA/C1M-I801', plotchan='JET-JPF/DH/Y6-FAST:003', i2str(shotnr)+'Hon.time', $
        ; taurange=[-100,100], cut_length=3, filter_low=1e3,/plot_spectra
       fres=1e1
       fluc_correlation, shotnr, refch=refch, plotchan=plotchan, timerange=timerange, filter_low=1e2,$
         outfscale=outfreq,outpower=outpower, /plot_correlation, fres=fres, frange=frange, taurange=taurange, interval_n=1, taures=100, /norm
       if hardplot EQ 1 then hardfile, savepath+i2str(shotnr)+'_cross_channel_'+i2str(i)+'_refch_'+i2str(j)+'.ps'
     endfor
   endif
endfor
end

11: begin ; crosscoherence power spectra with mirnov signal, shifted time window
loadct,13,file='COLORS.TBL'
t_res=0.1 ;timeresulution in seconds
t_shift=0.01
trange_all=[57,58]
frange=[1e2,2e3]
fres=1e0
n_times=(trange_all[1]-trange_all[0])/t_shift
t_arr=findgen(n_times)/(n_times-1)*(trange_all[1]-trange_all[0]-t_res)+trange_all[0]
  for i=1,4 do begin
    for j=0,n_times-1 do begin
      fluc_correlation, shotnr, refch='JET-JPF/DA/C1M-I801', plotchan='JET-JPF/DH/Y6-FAST:00'+i2str(i), timerange=[t_arr[j],t_arr[j]+t_res], $
        outfscale=outfreq,outpower=outpower, /plot_power, fres=fres, frange=frange,/noplot
      if j EQ 0 then outpower_array=fltarr(4,n_times,n_elements(outpower))
      outpower_array[i-1,j,*]=outpower
      ;plot, outfreq,outpower_array[i,j,*]
      ;wait,0.01
      ;stop
    endfor

  if hardplot EQ 1 then hardon
  if hardplot EQ 0 then window,i,xsize=640,ysize=480,title=i2str(shotnr)+'ch'+i2str(i)
  loadct,5
  ;contour, outpower_array[i-1,*,*], t_arr, outfreq, yrange=frange, nlevels=500, /fill, MIN_VALUE=1e-9, MAX_VALUE=max(outpower_array[i-1,*,*])
  contour, outpower_array[i-1,*,*], t_arr, outfreq, yrange=frange, nlevels=1000, /fill, MIN_VALUE=0, MAX_VALUE=max(outpower_array[i-1,*,*])
    ;COLORBAR, BOTTOM=bottom, CHARSIZE=2., COLOR=color, DIVISIONS=divisions, $
    ;FORMAT=format, POSITION=[0.01,0.01,0.1,0.99], MAX=1., MIN=0., NCOLORS=ncolors, $
    ;PSCOLOR=pscolor, VERTICAL=1, TOP=top, RIGHT=1
  if hardplot EQ 1 then hardfile, savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_spectrogram_shift2.ps'
  ;stop
endfor
save, filename=savepath+i2str(shotnr)+'_spectrogram_shift2.sav'
end

12: begin ; autocorrelation of the BES channels
for i=1,4 do begin
  refchannel='JET-JPF/DH/Y6-FAST:00'+i2str(i)
  !p.BACKGROUND=!d.n_colors-1
  !p.COLOR=0
  if hardplot EQ 1 then hardon
  if hardplot EQ 0 then window,i,xsize=640,ysize=480,title=i2str(shotnr)+'_autocorr_channel_'+i2str(i)
  frange=[1e2,1e3]
  fres=1e1
  fluc_correlation, shotnr, refchannel=refchannel, timerange=[58.73,58.877], filter_low=1e2,$
    outfscale=outfreq,outpower=outpower, /plot_correlation, fres=fres, frange=frange, taurange=[-20000,20000], interval_n=1, taures=100, /norm
  if hardplot EQ 1 then hardfile, savepath+i2str(shotnr)+'_autocorr_channel_'+i2str(i)+'.ps'
endfor
end

13: begin

if hardplot EQ 0 then window,0,xsize=1024,ysize=800,title=i2str(shotnr)
if hardplot EQ 1 then hardon
!p.MULTI=[0,2,4]
!p.BACKGROUND=!d.n_colors-1
!p.COLOR=0
letterarray=['A','B','C','D','E','F','G','H']
for i=0,7 do begin
  show_rawsignal, 116354, 'BES-'+letterarray[i]+'3', int=1000, mode=mode, yrange=[300,400]
endfor
if hardplot EQ 1 then hardfile, savepath+i2str(shotnr)+'raw_data_all_channels.ps'
end

14: begin ;CXRS time files
  SELECT_TIME,shotnr,'BES-F3', trange=trange, inttime=1000, auto_chopper=auto_chopper
end

15: begin ; overview for power spectra for each channel
letterarray=['A','B','C','D','E','F','G','H']
for i=5,5 do begin
refch='BES-'+letterarray[i]+'3'
;!p.MULTI=[0,2,4]
!p.BACKGROUND=!d.n_colors-1
!p.COLOR=0
 ;hardon
 window,i,xsize=1200,ysize=800,title=i2str(shotnr)+'ch'+refch

 frange=[1e3,5e5]
  fluc_correlation, shotnr, refch=refch, i2str(shotnr)+'on.time', filter_low=1e3,$
   /plot_pow, frange=frange, fres=1e3, xtype=1, ytype=1, yrange=[1e-5,1e-4]

endfor
end

16: begin ;CXRS autocrrelation
for i=1,4 do begin
letterarray=['A','B','C','D','E','F','G','H']

  refchannel='BES-'+letterarray[i]+'3'
  !p.BACKGROUND=!d.n_colors-1
  !p.COLOR=0
  if hardplot EQ 1 then hardon
  if hardplot EQ 0 then window,i,xsize=640,ysize=480,title=i2str(shotnr)+'_autocorr_channel_'+i2str(i)
  frange=[1e2,1e3]
  fres=1e1
  fluc_correlation, shotnr, refchannel=refchannel, i2str(shotnr)+'on.time' , filter_low=1e2,$
    outfscale=outfreq,outpower=outpower, /plot_correlation, fres=fres, frange=frange, taurange=[-20000,20000], interval_n=1, taures=100, /norm
  if hardplot EQ 1 then hardfile, savepath+i2str(shotnr)+'_autocorr_channel_'+i2str(i)+'.ps'
endfor
end

17: begin ;JET crosscorrelation BES with Mirnov
for i=1,4 do begin
refch='JET-JPF/DA/C1M-I801'
plotchan='JET-JPF/DH/Y6-FAST:00'+i2str(i)
!p.BACKGROUND=!d.n_colors-1
!p.COLOR=0
 if hardplot EQ 1 then hardon
 if hardplot EQ 0 then window,i,xsize=640,ysize=480,title=i2str(shotnr)+' CH'+i2str(i)

 frange=[1e2,1e3]
 fres=1e1
 fluc_correlation, shotnr, refch=refch, plotchan=plotchan, timerange=[58.73,58.877], filter_low=1e2,$
         outfscale=outfreq,outpower=outpower, /plot_correlation, fres=fres, frange=frange, taurange=[-20000,20000], interval_n=1, taures=100, /norm
 if hardplot EQ 1 then hardfile, savepath+i2str(shotnr)+'_cross_BESch'+i2str(i)+'_mirnov.ps'
endfor
end

18: begin
for i=1,4 do begin

 ;window,i*2
 hardon
 trange1=[55,57]
 yrange=[5e-10,1e-8]
 ;stop
 print, 'processing '+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_'+i2str(trange1[0])+'_'+i2str(trange1[1])+'.ps'
 fluc_correlation, shotnr, refch='JET-JPF/DH/Y6-FAST:00'+i2str(i), i2str(shotnr)+'_55_57on.time', /plot_pow, xtype=1,ytype=1, frange=[1e2,2e3], fres=1e1, yrange=yrange
 ;fluc_correlation, shotnr, refch='JET-JPF/DH/Y6-FAST:00'+i2str(i), i2str(shotnr)+'_55_57off.time', /plot_pow, xtype=1,ytype=1, frange=[2e2,2e3], fres=1e1,/overplot, yrange=yrange
 hardfile, savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_'+i2str(trange1[0])+'_'+i2str(trange1[1])+'.ps'
 print, 'plot saved to '+savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_'+i2str(trange1[0])+'_'+i2str(trange1[1])+'.ps'

 ;window,i*2+1
 hardon
 trange2=[59,61]
 print, 'processing '+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_'+i2str(trange2[0])+'_'+i2str(trange2[1])+'.ps'
 fluc_correlation, shotnr, refch='JET-JPF/DH/Y6-FAST:00'+i2str(i), i2str(shotnr)+'_59_61on.time', /plot_pow, xtype=1,ytype=1, frange=[1e2,2e3], fres=1e1, yrange=yrange
 ;fluc_correlation, shotnr, refch='JET-JPF/DH/Y6-FAST:00'+i2str(i), i2str(shotnr)+'_59_61off.time', /plot_pow, xtype=1,ytype=1, frange=[2e2,2e3], fres=1e1,/overplot, yrange=yrange
 hardfile, savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_'+i2str(trange2[0])+'_'+i2str(trange2[1])+'.ps'
 print, 'plot saved to '+savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_power_spect_'+i2str(trange2[0])+'_'+i2str(trange2[1])+'.ps'

endfor
end


19: begin ;crosscorrelation between  BES and Mirnov channels
fluc_correlation, shotnr, plotchan='BES-4-1', refch='JET-JPF/DA/C1M-I801',timerange=[52.3,52.55], /plot_correlation,/nocalibrate,taurange=[-30000,30000], taures=200,/normalize
end

20: begin ;crosscoherence power spectra with mirnov signal
fluc_correlation, shotnr, plotchan='BES-1-4', refch='JET-JPF/DA/C1M-I801',timerange=[52.2,52.55], /plot_power, xtype=1,ytype=1, frange=[1e3,1e4], fres=1e2,/nocalibrate, yrange=[1e-13,1e-10]
end

21: begin ;crosscoherence power spectra with mirnov signal of the APDCAM
!p.BACKGROUND=!d.n_colors-1
!p.COLOR=0
 
 frange=[5e2,5e3]
 fres=16
if experiment EQ 'JET' then begin
 yrange=[1e-10,2e-8]
 for i=4,4 do begin
 title='4channel_'+i2str(i)
 if hardplot EQ 0 then window,i,xsize=640,ysize=480,title=title
 if hardplot EQ 1 then hardon
 fluc_correlation, shotnr, refch='JET-JPF/DA/C1M-I801', plotchan='JET-JPF/DH/Y6-FAST:00'+i2str(i), i2str(shotnr)+'on.time', $
 ;fluc_correlation, shotnr, refch='JET-JPF/DH/Y6-FAST:00'+i2str(i), i2str(shotnr)+'on.time', $
  /plot_power,frange=frange, linethick=2, linestyle=0, ytype=1, xtype=1, fres=fres, yrange=yrange
 endfor
endif

if experiment EQ 'JET_APDCAM' then begin
;yrange=[1e-13,1e-10]
yrange=[1e-12,1e-8]
!p.MULTI=[0,2,4]
if shotnr LT 82270 then restore, 'jet_apd_map_13_02_2012.sav'
if shotnr GT 82270 then restore, 'jet_apd_map.sav'
for i=0,prof_ch_num-1 do begin
if where(apd_map[*,*,4] EQ i2str(i+1)) NE -1 then begin
  print, 'Loading data for Track '+i2str(i+1)+'.'
  ind=array_indices(apd_map[*,*,4],where(apd_map[*,*,4] EQ i2str(i+1)))
  ;ind_prev=array_indices(apd_map[*,*,4],where(apd_map[*,*,4] EQ i2str(i)))
  chname_full=apd_map(ind[0],ind[1],0)
  ;chname_full_prev=apd_map(ind_prev[0],ind_prev[1],0)
  
  if hardplot EQ 1 then hardon
  if hardplot EQ 0 then window,1, title=chname_full
    ;fluc_correlation, shotnr, plotchan='BES-'+i2str(i)+'-'+i2str(j), refch='JET-JPF/DA/C1M-I801', i2str(shotnr)+'on.time', /plot_power, xtype=1,ytype=1, frange=[1e2,1e4], fres=1e2,/nocalibrate, yrange=[1e-12,1e-9]
    fluc_correlation, shotnr, plotchan=chname_full, refch='JET-JPF/DA/C1M-I801', i2str(shotnr)+'on.time', /plot_power, xtype=1,ytype=1, $
    ;fluc_correlation, shotnr, plotchan=chname_full, refch='JET-JPF/DA/C1M-I801', timerange=trange, /plot_power, xtype=0,ytype=0, $
    ;fluc_correlation, shotnr, plotchan=chname_full, refch=chname_full_prev, i2str(shotnr)+'on.time', /plot_power, xtype=1,ytype=1, $
    frange=frange, /nocalibrate, yrange=yrange, linethick=2, linestyle=0, fres=fres
    ;fluc_correlation, shotnr, refch=chname_full, i2str(shotnr)+'on.time', /plot_power, xtype=1,ytype=1, $
    ;fluc_correlation, shotnr, refch=chname_full, timerange=trange, /plot_power, xtype=1,ytype=1, $
    ;frange=frange, /nocalibrate, yrange=yrange, linethick=2, linestyle=0, fres=fres
    if hardplot EQ 1 then hardfile, savepath+i2str(shotnr)+'_'+chname_full+'_'+experiment+'_power_spect.ps'
    wait,3
  endif
endfor

endif else begin
  print, 'Track '+i2str(i+1)+' not available in this shot.'
endelse
;if hardplot EQ 1 then hardfile, savepath+i2str(shotnr)+'_'+title+'_'+experiment+'_power_spect_corr_mirnov.ps'

end

22: begin
show_all_kstar_bes_power, shotnr,timerange=[52.4,52.6],yrange=[1e-12,1e-10],fres=1e2,frange=[1e3,1e4],/nocalibrate;,/autopower
end

23: begin ; power spectra of APDCAM, shifted time window
loadct,13,file='COLORS.TBL'
t_res=0.05 ;timeresulution in seconds
t_shift=0.01
trange_all=[52.3,52.6]
n_times=(trange_all[1]-trange_all[0])/t_shift
t_arr=findgen(n_times)/(n_times-1)*(trange_all[1]-trange_all[0]-t_res)+trange_all[0]
yrange=[1e-12,1e-10]
frange=[1e3,1e4]
fres=16
if shotnr LT 82270 then restore, 'jet_apd_map_13_02_2012.sav'
if shotnr GT 82270 then restore, 'jet_apd_map.sav'
refch='JET-JPF/DA/C1M-I801'
for i=0,prof_ch_num-1 do begin
;for i=14,14 do begin
if where(apd_map[*,*,4] EQ i2str(i+1)) NE -1 then begin
  print, 'Loading data for Track '+i2str(i+1)+'.'
  ind=array_indices(apd_map[*,*,4],where(apd_map[*,*,4] EQ i2str(i+1)))
  chname_full=apd_map(ind[0],ind[1],0)
    for k=0,n_times-1 do begin
      ;refch='BES-'+i2str(i)+'-'+i2str(j)
      fluc_correlation, shotnr,plotchan=chname_full, refch=refch,timerange=[t_arr[k],t_arr[k]+t_res], /plot_power, xtype=1,ytype=1, /noplot,$
      frange=frange, /nocalibrate, yrange=yrange, linethick=2, linestyle=0, fres=fres,outfscale=outfreq,outpower=outpower
      if k EQ 0 then outpower_array=fltarr(prof_ch_num,n_times,n_elements(outpower))
      outpower_array[i,k,*]=outpower
      ;window,1
      ;plot, outfreq,outpower_array[i-1,j-1,k,*]
      ;wait,0.01
      ;stop
    endfor

  if hardplot EQ 1 then hardon
  if hardplot EQ 0 then window,i,xsize=640,ysize=480,title=i2str(shotnr)+chname_full
  loadct,5

  contour, outpower_array[i,*,*], t_arr, outfreq, yrange=frange, nlevels=1000, /fill, MIN_VALUE=0, MAX_VALUE=max(outpower_array[i,*,*])
    ;COLORBAR, BOTTOM=bottom, CHARSIZE=2., COLOR=color, DIVISIONS=divisions, $
    ;FORMAT=format, POSITION=[0.01,0.01,0.1,0.99], MAX=1., MIN=0., NCOLORS=ncolors, $
    ;PSCOLOR=pscolor, VERTICAL=1, TOP=top, RIGHT=1
  if hardplot EQ 1 then hardfile, savepath+i2str(shotnr)+'Track'+i2str(i+1)+'_'+chname_full+'_spectrogram_tres'+i2str(t_res*1000)+'ms_t_shift'+i2str(t_shift*1000)+'ms_fres'+i2str(fres)+'Hz.ps'
  
endif else begin
  print, 'Track '+i2str(i+1)+' not available in this shot.'
endelse
endfor
save, filename=savepath+i2str(shotnr)+'_spectrogram_shift2.sav'
end

24: begin ;power spectra of the APDCAM, overplot of beam on/off times
!p.BACKGROUND=!d.n_colors-1
!p.COLOR=0
 
frange=[8e2,2e3]
fres=10
yrange=[1e-11,1e-9]
xtype=0
ytype=0
 refch='JET-JPF/DA/C1M-I801'
 ;refch='BES-1-6'
if experiment EQ 'JET_APDCAM' then begin
;default,off_timefile,i2str(shotnr)+'off.time'
;default,on_timefile,i2str(shotnr)+'on.time'
default,off_timefile,i2str(shotnr)+'off_m-mode.time'
default,on_timefile,i2str(shotnr)+'on_m-mode.time'
default,noerror,0

;!p.MULTI=[0,8,4]
;if shotnr LT 82270 then restore, 'jet_apd_map_13_02_2012.sav'
;if shotnr GT 82270 then restore, 'jet_apd_map.sav'
if not defined(apd_map) then begin
  make_apd_map,shotnumber=shotnr
  restore, dir_f_name(path,dir_f_name('data',dir_f_name(i2str(shotnr),i2str(shotnr)+'_jet_apd_map.sav')))
endif
for i=0,prof_ch_num-1 do begin
if where(apd_map[*,*,4] EQ i2str(i+1)) NE -1 then begin
  print, 'Loading data for Track '+i2str(i+1)+'.'
  ind=array_indices(apd_map[*,*,4],where(apd_map[*,*,4] EQ i2str(i+1)))
  chname_full=apd_map(ind[0],ind[1],0)
  
  if hardplot EQ 1 then hardon
  if hardplot EQ 0 then window,1, title=chname_full
    fluc_correlation, shotnr, refch=refch,plotchan=chname_full, on_timefile, /plot_power, xtype=xtype,ytype=ytype, $
    frange=frange, /nocalibrate, yrange=yrange, linethick=2, linestyle=0, fres=fres, noerror=noerror
    fluc_correlation, shotnr, refch=refch,plotchan=chname_full, off_timefile, /plot_power, xtype=xtype,ytype=ytype, $
    frange=frange, /nocalibrate, yrange=yrange, linethick=2, linestyle=2, fres=fres,/overplot, noerror=noerror
    ;if hardplot EQ 1 then hardfile, savepath+i2str(shotnr)+'_'+chname_full+'_'+experiment+'_power_on_off_spect.ps'
    wait,1
endif else begin
  print, 'Track '+i2str(i+1)+' not available in this shot.'
endelse
endfor
if hardplot EQ 1 then hardfile, savepath+i2str(shotnr)+'_all_power_on_off_spect.ps'
endif
end

25: begin ;power spectra for all channels with show_all_ky6d_power.pro
;default,refchannel,'BES-2-8'
default,refchannel,'JET-JPF/DA/C1M-I801'
default,frange,[8e2,2e3]
;default,yrange,[1e-13,1e-11]
default,fres,10
default,mirror,1500
default,nocalc,0
default,timefile,i2str(shotnr)+'on.time'
default,xtype,1
default,ytype,0
default,crosspower,1
default,crossphase,0
default,interval_n,1
default,noerror,1
if defined(timefile) then begin
 tfile=dir_f_name('time',timefile)
    times=loadncol(tfile,2,/silent,errormess=errormess)
    if (errormess ne '') then begin
      if (not keyword_set(silent)) then print,errormess
      outcorr=0
      return
    endif
    ind=where((times(*,0) ne 0) or (times(*,1) ne 0))
    times=times(ind,*)
endif

for i=0,n_elements(times[*,0])-1 do begin

timerange=[times[i,*]]
print, timerange
show_all_ky6d_power,shotnr,timerange=timerange,crosspower=crosspower,crossphase=crossphase,ref=refchannel,frange=frange,mirror=mirror, $
fres=fres,yrange=yrange,nocalc=nocalc,ytype=ytype,xtype=xtype, savefile=i2str(shotnr)+'_JET-JPF_DA_C1M-I801_show_all_ky6D_power'+i2str(i)+'.sav',$
interval_n=interval_n,noerror=noerror
;show_all_ky6d_power,shotnr,timefile=timefile,timerange=timerange,crosspower=crosspower,crossphase=crossphase,ref=refchannel,frange=frange,mirror=mirror,fres=fres,yrange=yrange,nocalc=nocalc,ytype=ytype,xtype=xtype
;show_all_ky6d_power,82637,timefile='82637on.time',/crosspower,ref='BES-1-2',frange=[8e2,1.2e3],mirror=1500,fres=1e0,yrange=[1e-13,2e-11],/nocalc,ytype=0,xtype=0
;show_all_ky6d_power,82637,timefile='82637on.time',/crossphase,ref='BES-1-2',frange=[8e2,1.2e3],mirror=1500,fres=1e0,/nocalc,xtype=0
;restore, './tmp/82637_JET-JPF_DA_C1M-I801_show_all_ky6D_power'+i2str(i)+'.sav'
;window,0
;plot,fscale/1000.,reform(p_matrix[5,*])
;window,1
;plot,fscale/1000.,reform(ph_matrix[5,*])
endfor
end

26: begin ;power spectra for all channels from cross coherence themselves
!p.BACKGROUND=!d.n_colors-1
!p.COLOR=0
 
frange=[2e2,3e3]
fres=5e1
yrange=[1e-11,3e-9]
ftype=0
xtype=0
ytype=0
timerange=[59,60]
interval_n=10
;interval_n=500
if hardplot EQ 1 then hardon
for i=1,4 do begin
  for j=1,8 do begin
  refch='BES-'+i2str(i)+'-'+i2str(j)
  plotchan=refch
    if hardplot EQ 0 then window,1, title=refch
    
      fluc_correlation, shotnr, refch=refch,plotchan=plotchan, timerange=timerange, /plot_power, xtype=xtype,ytype=ytype,frange=frange, /nocalibrate, fres=fres, noerror=noerror, $
      interval_n=interval_n
      ;fluc_correlation, shotnr, i2str(shotnr)+'on.time',yrange=yrange,refch=refch,plotchan=plotchan, /plot_power, xtype=xtype,ytype=ytype,$
      ;frange=frange, /nocalibrate, fres=fres, noerror=noerror,ftype=ftype,interval_n=interval_n
    if hardplot EQ 0 then wait,1
    
  endfor
endfor
if hardplot EQ 1 then hardfile, dir_f_name(dir_f_name(path,'results'),i2str(shotnr)+'_all_spect.ps')
end

27: begin ;autocorreltaion functions
!p.BACKGROUND=!d.n_colors-1
!p.COLOR=0
 
taurange=[-2e2,2e2]
taures=1
cut_length=2
timerange=[55,55.5]
percent=0
;interval_n=500
;background_level=0.57
if hardplot EQ 1 then hardon
for i=1,4 do begin
  for j=1,8 do begin
  refch='BES-'+i2str(i)+'-'+i2str(j)
  plotchan=refch
    if hardplot EQ 0 then window,1, title=refch
    
      ;fluc_correlation, shotnr,timerange=timerange,refchan=refch, /plot_correlation,/nocalibrate,taurange=taurange, cut_length=cut_length,$
      ;taures=taures,percent=percent,interval_n=interval_n
      fluc_correlation, shotnr, i2str(shotnr)+'on.time',refchan=refch, /plot_correlation,/nocalibrate,taurange=taurange, cut_length=cut_length, $
      interval_n=interval_n,taures=taures,percent=percent,background_level=background_level
    if hardplot EQ 0 then wait,1
    
  endfor
endfor
if hardplot EQ 1 then hardfile, dir_f_name(dir_f_name(path,'results'),i2str(shotnr)+'_all_autocorr.ps')
end

28: begin ;crosscorreltaion functions
!p.BACKGROUND=!d.n_colors-1
!p.COLOR=0
 
taurange=[-2e2,2e2]
taures=5
cut_length=0
timerange=[55,55.5]
percent=0
refch='BES-1-4'
interval_n=200
if hardplot EQ 1 then hardon
for i=1,4 do begin
  for j=1,8 do begin
  plotchannel='BES-'+i2str(i)+'-'+i2str(j)
    if hardplot EQ 0 then window,1, title=refch
    
    fluc_correlation, shotnr, i2str(shotnr)+'on.time', refch=refch,plotchan=plotchannel, /plot_correlation,/nocalibrate,taurange=taurange, $
    cut_length=cut_length,taures=taures,percent=percent,interval_n=interval_n
    ;fluc_correlation, shotnr, timerange=timerange, refch=refch,plotchan=plotchannel, /plot_correlation,/nocalibrate,taurange=taurange, cut_length=cut_length,taures=taures,percent=percent
    
    if hardplot EQ 0 then wait,1
    
  endfor
endfor
if hardplot EQ 1 then hardfile, dir_f_name(dir_f_name(path,'results'),i2str(shotnr)+'_all_crosscorr.ps')
end


29: begin
!p.BACKGROUND=!d.n_colors-1
!p.COLOR=0
 
frange=[1e4,1e5]
fres=1e3
yrange=[1e-9,3e-8]
xtype=1
ytype=1
taurange=[-2e3,2e3]
taures=50
refch='BES-1-2'
if experiment EQ 'JET_APDCAM' then begin

default,on_timefile,i2str(shotnr)+'on.time'
;default,off_timefile,i2str(shotnr)+'off_m-mode.time'
;default,on_timefile,i2str(shotnr)+'on_m-mode.time'
default,noerror,0


if not defined(apd_map) then begin
  make_apd_map,shotnumber=shotnr
  restore, dir_f_name(path,dir_f_name('data',dir_f_name(i2str(shotnr),i2str(shotnr)+'_jet_apd_map.sav')))
endif
if hardplot EQ 1 then hardon
if hardplot EQ 0 then window,1
for i=1,4 do begin
  for j=1,8 do begin
    plotchannel='BES-'+i2str(i)+'-'+i2str(j)
    

      fluc_correlation, shotnr, refch=refch,plotchan=plotchannel, on_timefile, /plot_correlation, xtype=xtype,ytype=ytype, $
      frange=frange, /nocalibrate, yrange=yrange, linethick=2, linestyle=0, fres=fres, noerror=noerror,/plot_noiselevel,$
      taurange=taurange,taures=taures, title=chname_full
      wait,1

  endfor
endfor
if hardplot EQ 1 then hardfile, dir_f_name(savepath,i2str(shotnr)+'ref:'+refch+'_all_correltaion.ps')
print, dir_f_name(savepath,i2str(shotnr)+'_ref:'+refch+'_all_correltaion.ps')
endif
end

30: begin ;ECE signal processing, auto correlation
;default,n_channels,12
default,shotnr,80913
default,ch_start,28
default,ch_end,38
default,trange,[60.,61.]
;default,refchannel,'JET-JPF/DA/C1M-I801'
default,frange,[8e2,1.2e3]
default,yrange,[1e-4,1e-1]
default,fres,5
default,timefile,i2str(shotnr)+'on.time'
default,xtype,1
default,ytype,1
default,crosspower,1
default,crossphase,0
default,interval_n,1
default,noerror,1
default,plot_raw_data,0
default,hardplot,1
n_channels=ch_end-ch_start+1
if hardplot EQ 1 then hardon
for i=ch_start, ch_end do begin
  if plot_raw_data EQ 1 then begin
    if not(defined(data_arr)) then begin
      get_rawsignal,i2str(shotnr), timerange=trange,'KK3TE01',data_source=27,time,data
      data_arr=fltarr(n_elements(data),n_channels)
      data_arr[*,i-ch_start]=data 
    endif else begin
      get_rawsignal,i2str(shotnr), 'KK3TE'+string(i,format='(I2.2)'),data_source=27,time,data
      data_arr[*,i-ch_start]=data    
    endelse
    d_t=fltarr(n_elements(where((time GE trange[0]) AND (time LE trange[1]))))
    for k=min(where(time GE trange[0])), min(where(time GE trange[0]))+n_elements(where((time GE trange[0]) AND (time LE trange[1])))-1 do begin
      d_t[k-min(where(time GE trange[0]))]=(time[k]-time[k-1])
    endfor
    ;print,max(d_t),min(d_t)
    ;plot,time(where((time GE trange[0]) AND (time LE trange[1]))),d_t
    restore,'D:\dokumentumok\BES\JET\JET-measure\data\'+i2str(shotnr)+'\JET-PPF_'+i2str(shotnr)+'_KK3TE'+string(i,format='(I2.2)')+'.sav
    sampletime=mean(d_t)
    save,sampletime,time,data,filename='D:\dokumentumok\BES\JET\JET-measure\data\'+i2str(shotnr)+'\JET-PPF_'+i2str(shotnr)+'_KK3TE'+string(i,format='(I2.2)')+'.sav'
  endif


 fluc_correlation, shotnr, data_source=27,timerange=trange,yrange=yrange,refchannel='KK3TE'+string(i,format='(I2.2)'),plotchan=plotchan, $
 /noplot, xtype=xtype,ytype=ytype,frange=frange, /nocalibrate, fres=fres, noerror=noerror,ftype=ftype,interval_n=interval_n,/auto,$
 /stop_on_error,outpower=outpower,outfscale=outfscale,outphase=outphase
 
 plot, outfscale/1000,outpower,yrange=yrange,title='auto spectra, ECE channel '+string(i,format='(I2.2)'), xtitle='frequency [kHz]'
 wait,0
endfor
if hardplot EQ 1 then hardfile,  dir_f_name(dir_f_name(path,'results'),i2str(shotnr)+'_ECE_autospectra.ps')
if plot_raw_data EQ 1 then begin
  loadct,13
  contour, data_arr(where((time GE trange[0]) AND (time LE trange[1])),*),time(where((time GE trange[0]) AND (time LE trange[1]))),indgen(n_channels)+1,/fill,nlevels=20,$
  /xstyle,/ystyle, max_value=max(data_arr(where((time GE trange[0]) AND (time LE trange[1])),*))
endif  
end

31: begin ;ECE signal processing, crosscorrelation
;default,n_channels,12
;default,shotnr,80913
default,shotnr,85960
default,ch_start,30
default,ch_end,40
default,trange,[59.,60.]
default,refchannel,'KK3TE37'
default,frange,[8e2,1.2e3]
default,yrange,[1e-4,1e-1]
default,fres,5
default,timefile,i2str(shotnr)+'on.time'
default,xtype,1
default,ytype,1
default,crosspower,1
default,crossphase,0
default,interval_n,1
default,noerror,0
default,plot_raw_data,1
default,hardplot,0
default,fmin,970
default,fmax,1030
n_channels=ch_end-ch_start+1
if hardplot EQ 1 then hardon
for i=ch_start, ch_end do begin
  if plot_raw_data EQ 1 then begin
    if not(defined(data_arr)) or  not(defined(coord_arr)) then begin
      get_rawsignal,i2str(shotnr), 'KK3TE01',data_source=27,time,data
      data_arr=fltarr(n_elements(data),n_channels)
      data_arr[*,i-ch_start]=data 
      get_rawsignal,i2str(shotnr), 'KK3RA'+string(i,format='(I2.2)'),data_source=27,t,r
      coord_arr=fltarr(n_elements(r),n_channels)
      coord_arr[*,i-ch_start]=r 
      int_arr=fltarr(n_channels)
      int_arr[i-ch_start]=mean(data_arr(where((time GE trange[0]) AND (time LE trange[1])),i-ch_start))
    endif else begin
      get_rawsignal,i2str(shotnr), 'KK3TE'+string(i,format='(I2.2)'),data_source=27,time,data
      data_arr[*,i-ch_start]=data    
      get_rawsignal,i2str(shotnr), 'KK3RA'+string(i,format='(I2.2)'),data_source=27,t,r
      coord_arr[*,i-ch_start]=r
      int_arr[i-ch_start]=mean(data_arr(where((time GE trange[0]) AND (time LE trange[1])),i-ch_start))
    endelse
    d_t=fltarr(n_elements(where((time GE trange[0]) AND (time LE trange[1]))))
    for k=min(where(time GE trange[0])), min(where(time GE trange[0]))+n_elements(where((time GE trange[0]) AND (time LE trange[1])))-1 do begin
      d_t[k-min(where(time GE trange[0]))]=(time[k]-time[k-1]) ;time vector gradient ~ sampling rate
    endfor
    ;print,max(d_t),min(d_t)
    ;plot,time(where((time GE trange[0]) AND (time LE trange[1]))),d_t
    ;
    ;this is necessarry because the sampling rate is changing, it is read at the beginning of the shot (0.1ms), and it is different at the ROI (0.04ms)
    restore,'D:\dokumentumok\BES\JET\JET-measure\data\'+i2str(shotnr)+'\JET-PPF_'+i2str(shotnr)+'_KK3TE'+string(i,format='(I2.2)')+'.sav
    sampletime=mean(d_t)
    save,sampletime,time,data,filename='D:\dokumentumok\BES\JET\JET-measure\data\'+i2str(shotnr)+'\JET-PPF_'+i2str(shotnr)+'_KK3TE'+string(i,format='(I2.2)')+'.sav'
  endif


 fluc_correlation, shotnr, data_source=27,timerange=trange,yrange=yrange,refchannel=refchannel,plotchan='KK3TE'+string(i,format='(I2.2)'), $
 /noplot, xtype=xtype,ytype=ytype,frange=frange, /nocalibrate, fres=fres, noerror=noerror,ftype=ftype,interval_n=interval_n,$
 /stop_on_error,outpower=outpower,outfscale=outfscale,outphase=outphase
 

 plot, outfscale/1000,outpower,yrange=yrange,title='cross correlation spectra, plotchannel '+string(i,format='(I2.2)')+' ref: '+refchannel, xtitle='frequency [kHz]'
 plot, outfscale/1000,outphase/!Pi,title='cross correlation phase, plotchannel '+string(i,format='(I2.2)')+' ref: '+refchannel, xtitle='frequency [kHz]'
 wait,0
 if not(defined(meanphase)) then meanphase=fltarr(n_channels,3)
  meanphase[i-ch_start,0]=mean(outphase(where((outfscale GE fmin) AND (outfscale LE fmax)))/!Pi)
  meanphase[i-ch_start,1]=stddev(outphase(where((outfscale GE fmin) AND (outfscale LE fmax)))/!Pi)
  meanphase[i-ch_start,2]=mean(reform(coord_arr(where((t GE trange[0]) AND (t LE trange[1])),i-ch_start)))
if not(defined(meancorr)) then meancorr=fltarr(n_channels,2)
  meancorr[i-ch_start,0]=total(outpower(where((outfscale GE fmin) AND (outfscale LE fmax))))/(fmax-fmin)
  ;meancorr[i-ch_start,1]=
  
endfor

if hardplot EQ 1 then begin
    hardon
    xthick=5
    ythick=5
    charthick=4
    thick=2.5
    charsize=1.1
    ticklen=0.02
    symsize=2
  endif


plot, meanphase[*,2],meanphase[*,0],yrange=[-1,1],xtitle='midplane coordinate [m]',ytitle='Phase[Pi]',$
charsize=charsize,charthick=charthick, xthick=xthick, ythick=ythick, ticklen=ticklen,thick=thick,symsize=symsize,$
title=i2str(shotnr)+' Channel:'+refchannel+', phase distribution, frequency: '+i2str(fmin)+'Hz-'+i2str(fmax)+'Hz, time: '+string(trange[0],format='(f5.2)')+'-'+string(trange[1],format='(f5.2)')+'s'
ERRPLOT,meanphase[*,2],meanphase[*,0]-meanphase[*,1],meanphase[*,0]+meanphase[*,1]

if plot_raw_data EQ 1 then begin
  loadct,13
  contour, data_arr(where((time GE trange[0]) AND (time LE trange[1])),*),time(where((time GE trange[0]) AND (time LE trange[1]))),meanphase[*,2],$
  /fill,nlevels=20,xtitle='time [s]',ytitle='midplane coordinate [m]',$
  /xstyle,/ystyle, max_value=max(data_arr(where((time GE trange[0]) AND (time LE trange[1])),*))
  
  plot,  meanphase[*,2], meancorr[*,0]  ,xtitle='midplane coordinate [m]',ytitle='cross power[arb]',$
  charsize=charsize,charthick=charthick, xthick=xthick, ythick=ythick, ticklen=ticklen,thick=thick,symsize=symsize,$
  title=i2str(shotnr)+' Channel:'+refchannel+', crosspower distribution, frequency: '+i2str(fmin)+'Hz-'+i2str(fmax)+'Hz, time: '+string(trange[0],format='(f5.2)')+'-'+string(trange[1],format='(f5.2)')+'s'
  
  plot,  meanphase[*,2], int_arr/1000,xtitle='midplane coordinate [m]',ytitle='T_e[keV]',$
  charsize=charsize,charthick=charthick, xthick=xthick, ythick=ythick, ticklen=ticklen,thick=thick,symsize=symsize,$
  title=i2str(shotnr)+' KK3 electron temperature distribution, time: '+string(trange[0],format='(f5.2)')+'-'+string(trange[1],format='(f5.2)')+'s'
endif  

if hardplot EQ 1 then hardfile,  dir_f_name(dir_f_name(path,'results'),i2str(shotnr)+'_ECE_crossspectra.ps')
end

32: begin ;power autospectra 
!p.BACKGROUND=!d.n_colors-1
!p.COLOR=0

mirror_m=1050
frange=[8e2,1.2e3]
fres=1
yrange=[1e-12,1e-10]
ftype=1
xtype=1
ytype=1
interval_n=1
noerror=1
timefile=i2str(shotnr)+'on_m-mode.time'

if not defined(apd_map) then begin
  make_apd_map,shotnumber=shotnr
  restore, dir_f_name(path,dir_f_name('data',dir_f_name(i2str(shotnr),i2str(shotnr)+'_jet_apd_map.sav')))
endif

if defined(timefile) then begin
 tfile=dir_f_name('time',timefile)
    times=loadncol(tfile,2,/silent,errormess=errormess)
    if (errormess ne '') then begin
      if (not keyword_set(silent)) then print,errormess
      outcorr=0
      return
    endif
    ind=where((times(*,0) ne 0) or (times(*,1) ne 0))
    times=times(ind,*)
endif


zr_pos = fltarr(2,prof_ch_num)
fibre = intarr(prof_ch_num)

if hardplot EQ 1 then hardon
for i=0,prof_ch_num-1 do begin
  if where(apd_map[*,*,4] EQ i2str(i+1)) NE -1 then begin
    print, 'Loading data for Track '+i2str(i+1)+'.'
    ind=array_indices(apd_map[*,*,4],where(apd_map[*,*,4] EQ i2str(i+1)))
    refchannel=apd_map(ind[0],ind[1],0)
    fibre[i] = ky6d_fibre_number(shotnr,refchannel)
    zr_pos[*,i] = ky6_fibre_pos(shotnr,fibre[i],mirror=mirror_m,time=timerange,relative=relative,z_error=z_error)
      if hardplot EQ 0 then window,1, title=refchannel
      
        fluc_correlation, shotnr, timefile,yrange=yrange,refchannel=refchannel,/auto, xtype=xtype,ytype=ytype,/noplot,$
        frange=frange, /nocalibrate, fres=fres, noerror=noerror,ftype=ftype,interval_n=interval_n,outpower=outpower,outfscale=outfscale,outphase=outphase
        
        rd_gauss_fit, data_x=outfscale, data_y=outpower,cog=cog, dev=dev,ampl=ampl,/plotting
        if not defined(fit_prof) then fit_prof=fltarr(prof_ch_num,3)
        fit_prof[i,0]=ampl
        fit_prof[i,1]=cog
        fit_prof[i,2]=dev
        
      if hardplot EQ 0 then wait,1
  endif
endfor

ind_sort=sort(zr_pos[0,*])
ind_sort=ind_sort[where(zr_pos[1,ind_sort] EQ 0)]
ind_sort=ind_sort[where(zr_pos[0,ind_sort] NE 0)]

if hardplot EQ 1 then begin
    hardon
    xthick=5
    ythick=5
    charthick=4
    thick=2.5
    charsize=1.1
    ticklen=0.02
    symsize=2
  endif

plot,  zr_pos[0,ind_sort]/1000, fit_prof[*,0]  ,xtitle='midplane coordinate [m]',ytitle='autopower[arb]',$
charsize=charsize,charthick=charthick, xthick=xthick, ythick=ythick, ticklen=ticklen,thick=thick,symsize=symsize,$
title=i2str(shotnr)+' autopower amplitude distribution, time: '+string(min(times),format='(f5.2)')+'-'+string(max(times),format='(f5.2)')+'s'
  
plot,  zr_pos[0,ind_sort]/1000, fit_prof[*,1]/1000  ,xtitle='midplane coordinate [m]',ytitle='mode frequency [kHz]',yrange=[0.8,1.050],$
charsize=charsize,charthick=charthick, xthick=xthick, ythick=ythick, ticklen=ticklen,thick=thick,symsize=symsize,$
title=i2str(shotnr)+' autopower frequency distribution, time: '+string(min(times),format='(f5.2)')+'-'+string(max(times),format='(f5.2)')+'s'
  

if hardplot EQ 1 then hardfile, dir_f_name(dir_f_name(path,'results'),i2str(shotnr)+'_radial_distribution.ps')
end

33: begin ;power spectra for all channels with show_all_ky6d_power.pro
default,refchannel,'BES-2-8'
;default,refchannel,'JET-JPF/DA/C1M-I801'
default,frange,[8e2,2e3]
;default,yrange,[1e-13,1e-11]
default,fres,10
default,mirror,1500
default,nocalc,0
if not defined(timerange) then default,timefile,i2str(shotnr)+'on_m-mode.time'
default,xtype,1
default,ytype,0
default,crosspower,1
default,crossphase,0
default,interval_n,1
default,noerror,1

show_all_ky6d_power,shotnr,timefile=timefile,timerange=timerange,crosspower=crosspower,crossphase=crossphase,ref=refchannel,frange=frange,mirror=mirror,fres=fres,yrange=yrange,nocalc=nocalc,ytype=ytype,xtype=xtype
;show_all_ky6d_power,82637,timefile='82637on.time',/crosspower,ref='BES-1-2',frange=[8e2,1.2e3],mirror=1500,fres=1e0,yrange=[1e-13,2e-11],/nocalc,ytype=0,xtype=0
;show_all_ky6d_power,82637,timefile='82637on.time',/crossphase,ref='BES-1-2',frange=[8e2,1.2e3],mirror=1500,fres=1e0,/nocalc,xtype=0
;restore, './tmp/82637_JET-JPF_DA_C1M-I801_show_all_ky6D_power'+i2str(i)+'.sav'
;window,0
;plot,fscale/1000.,reform(p_matrix[5,*])
;window,1
;plot,fscale/1000.,reform(ph_matrix[5,*])

end

34: begin ;power spectra for all channels with show_all_ky6d_power.pro
;default,refchannel,'BES-4-1'
;default,refchannel,'JET-JPF/DA/C1M-I803'
default,refchannel,'JET-PPF/KK3TE37'
default,frange,[2e2,1e3]
;default,yrange,[1e-11,2e-9]
default,fres,5
default,mirror,1050
default,nocalc,0
;default,timefile,i2str(shotnr)+'on.time'
default,timerange,[59,60]
default,xtype,0
default,ytype,0
default,autopower,0
default,crosspower,1
default,crossphase,0
default,crosscorr,0
default,interval_n,1
default,noerror,1
default,hardplot,1
default,taurange,[-1e2,1e2]
default,taures,2
default,cut_length,3

if autopower EQ 1 then default, plotfile,dir_f_name(savepath,i2str(shotnr)+'_auto_power_all_channels.ps')
if crosspower EQ 1 then default, plotfile,dir_f_name(savepath,i2str(shotnr)+'_cross_power_all_channels.ps')
if crossphase EQ 1 then default, plotfile,dir_f_name(savepath,i2str(shotnr)+'_cross_phase_all_channels.ps')
if crosscorr EQ 1 then default, plotfile,dir_f_name(savepath,i2str(shotnr)+'_crosscorrelation_all_channels.ps')

if hardplot EQ 1 then hardon
show_all_ky6d_power,shotnr,timefile=timefile,timerange=timerange,crosspower=crosspower,crossphase=crossphase,ref=refchannel,frange=frange, $
mirror=mirror,fres=fres,yrange=yrange,nocalc=nocalc,ytype=ytype,xtype=xtype,autopower=autopower, crosscorr=crosscorr, taurange=taurange, taures=taures,$
cut_length=cut_length, interval_n=interval_n, noerror=noerror
;show_all_ky6d_power,82637,timefile='82637on.time',/crosspower,ref='BES-1-2',frange=[8e2,1.2e3],mirror=1500,fres=1e0,yrange=[1e-13,2e-11],/nocalc,ytype=0,xtype=0
;show_all_ky6d_power,82637,timefile='82637on.time',/crossphase,ref='BES-1-2',frange=[8e2,1.2e3],mirror=1500,fres=1e0,/nocalc,xtype=0
;restore, './tmp/82637_JET-JPF_DA_C1M-I801_show_all_ky6D_power'+i2str(i)+'.sav'
;window,0
;plot,fscale/1000.,reform(p_matrix[5,*])
;window,1
;plot,fscale/1000.,reform(ph_matrix[5,*])
if hardplot EQ 1 then hardfile, plotfile
end

35: begin ; auto power spectrogram of the JET BES signals (all channels)
loadct,13,file='COLORS.TBL'
t_res=0.01 ;timeresulution in seconds
t_shift=0.005
interval_n=1
if not defined(trange) then begin
  get_rawsignal, shotnr, 'BES-1-1',t,d
  trange_all=[min(t),max(t)]
endif else begin
  trange_all=trange
endelse
frange=[1e3,2e3]
fres=30
yrange=[1e-8,1e-7]
;filter_low=1e2
n_times=floor((trange_all[1]-trange_all[0])/t_shift)-1
t_arr=findgen(n_times)/(n_times-1)*(trange_all[1]-trange_all[0]-t_res)+trange_all[0]
  if hardplot EQ 1 then hardon
  for i=3,3 do begin
  for j=1,1 do begin
  refchannel='BES-'+i2str(i)+'-'+i2str(j)
    for k=0,n_times-1 do begin
      fluc_correlation, shotnr, refchannel=refchannel, timerange=[t_arr[k],t_arr[k]+t_res], $
        outfscale=outfreq,outpower=outpower, /plot_power, fres=fres, frange=frange,/kHz,interval_n=interval_n, yrange=yrange, filter_low=filter_low, /noplot
        ;wait,0.1
      if k EQ 0 then outpower_array=fltarr(4,8,n_times,n_elements(outpower))
      outpower_array[i-1,j-1,k,*]=outpower
      ;plot, outfreq,outpower_array[i-1,j-1,k,*], charsize=2,yrange=yrange
      ;wait,0.01
      ;stop
    endfor

  if hardplot EQ 0 then window,i,xsize=640,ysize=480,title=i2str(shotnr)+refchannel
  loadct,5
  ;contour, outpower_array[i-1,*,*], t_arr, outfreq, yrange=frange, nlevels=500, /fill, MIN_VALUE=1e-9, MAX_VALUE=max(outpower_array[i-1,*,*])
  contour, outpower_array[i-1,j-1,*,*], t_arr, outfreq, yrange=frange, nlevels=50, /fill, MIN_VALUE=min(outpower_array[i-1,j-1,*,*]), MAX_VALUE=max(outpower_array[i-1,j-1,*,*]),$
  title='Spectrogram of '+i2str(shotnr)+' '+refchannel, xtitle='Time [s]', ytitle='Frequency [kHz]'
    ;COLORBAR, BOTTOM=bottom, CHARSIZE=2., COLOR=color, DIVISIONS=divisions, $
    ;FORMAT=format, POSITION=[0.01,0.01,0.1,0.99], MAX=1., MIN=0., NCOLORS=ncolors, $
    ;PSCOLOR=pscolor, VERTICAL=1, TOP=top, RIGHT=1

  ;stop
endfor
endfor
if hardplot EQ 1 then hardfile, dir_f_name(savepath,i2str(shotnr)+'_spectrogram.ps')
save, filename=savepath+i2str(shotnr)+'_spectrogram.sav'
end

36: begin ; auto power spectrogram 4 channel
loadct,13,file='COLORS.TBL'
t_res=0.1 ;timeresulution in seconds
t_shift=0.05
trange_all=[43,45]
frange=[1e3,1e4]
fres=100
n_times=(trange_all[1]-trange_all[0])/t_shift
t_arr=findgen(n_times)/(n_times-1)*(trange_all[1]-trange_all[0]-t_res)+trange_all[0]
  for i=1,4 do begin
    for j=0,n_times-1 do begin
      fluc_correlation, shotnr, refch='JET-JPF/DH/Y6-FAST:00'+i2str(i), plotchan='JET-JPF/DH/Y6-FAST:00'+i2str(i), timerange=[t_arr[j],t_arr[j]+t_res], $
        outfscale=outfreq,outpower=outpower, /plot_power, fres=fres, frange=frange,/noplot, interval_n=1
      if j EQ 0 then outpower_array=fltarr(4,n_times,n_elements(outpower))
      outpower_array[i-1,j,*]=outpower
      ;plot, outfreq,outpower_array[i-1,j,*]
      ;wait,0.01
      ;stop
    endfor

  if hardplot EQ 1 then hardon
  if hardplot EQ 0 then window,i,xsize=640,ysize=480,title=i2str(shotnr)+'ch'+i2str(i)
  loadct,5
  ;contour, outpower_array[i-1,*,*], t_arr, outfreq, yrange=frange, nlevels=500, /fill, MIN_VALUE=1e-9, MAX_VALUE=max(outpower_array[i-1,*,*])
  contour, outpower_array[i-1,*,*], t_arr, outfreq, yrange=frange, nlevels=1000, /fill, MIN_VALUE=0, MAX_VALUE=max(outpower_array[i-1,*,*]),/xstyle,/ystyle
    ;COLORBAR, BOTTOM=bottom, CHARSIZE=2., COLOR=color, DIVISIONS=divisions, $
    ;FORMAT=format, POSITION=[0.01,0.01,0.1,0.99], MAX=1., MIN=0., NCOLORS=ncolors, $
    ;PSCOLOR=pscolor, VERTICAL=1, TOP=top, RIGHT=1
  if hardplot EQ 1 then hardfile, savepath+i2str(shotnr)+'_chnr'+i2str(i)+'_spectrogram_shift5.ps'
  ;stop
endfor
save, filename=savepath+i2str(shotnr)+'_spectrogram_shift5.sav'
end

362: begin
default,serie,5
;loadct,13,file='COLORS.TBL'

restore, filename=savepath+i2str(shotnr)+'_spectrogram_shift'+i2str(serie)+'.sav'
get_rawsignal, 79012, 'EFITZPRO', data_source=27,t,d
dummy=min(abs((min(t_arr)-t)), ind_efit1)
dummy=min(abs((max(t_arr)-t)), ind_efit2)
;stop

  if hardplot EQ 1 then begin
    hardon
    xthick=5
    ythick=5
    charthick=2.5
    thick=2
    charsize=0.9
    ticklen=0.02
  endif
  if hardplot EQ 0 then begin
    window,0,xsize=1000,ysize=800
    xthick=1.5
    ythick=1.5
    charthick=2
    thick=2
    charsize=1.2
    ticklen=0.02
  endif

loadct,13
for i=1,4 do begin
  contour, outpower_array[i-1,*,*], t_arr, outfreq, yrange=frange, nlevels=1000, $
  /fill, MIN_VALUE=0, MAX_VALUE=max(outpower_array[i-1,*,*]),/xstyle,/ystyle,position=[0.1,0.27,0.9,0.95],$
  charsize=charsize,charthick=charthick, xthick=xthick, ythick=ythick, yTITLE='Frequency [Hz]',$
  ticklen=ticklen
  plot,t[ind_efit1:ind_efit2],d[ind_efit1:ind_efit2], position=[0.1,0.07,0.9,0.2], /noerase,/xstyle,/ystyle,$
  charthick=charthick, xthick=xthick, ythick=ythick,thick=thick,ytitle='Height above midplane[m]',$
    ticklen=ticklen,title='EFIT ZPRO', yrange=[min(d[ind_efit1:ind_efit2])*0.999,max(d[ind_efit1:ind_efit2])*1.001],$
    xtitle='Time[s]'
  ;stop
endfor
if hardplot EQ 1 then hardfile, savepath+i2str(shotnr)+'_spectrogram_shift_efit_'+i2str(serie)+'.ps'

end

37: begin ; find crosscorrelation maximum
default,refchannel,'BES-1-2'
restore, './tmp/'+i2str(shotnr)+'_'+refchannel+'_show_all_ky6D_power.sav
;plot, tauscale,cs_matrix[5,*]
;help
zr_pos = fltarr(2,32)
fibre = intarr(32)
tau_max=fltarr(32)
mirror_m=1050
for i=0,31 do begin
  fibre[i] = ky6d_fibre_number(shotnr,chname_arr[i])
  zr_pos[*,i] = ky6_fibre_pos(shotnr,fibre[i],mirror=mirror_m,time=timerange,relative=relative,z_error=z_error)
endfor

smooth_fact=30

for i=0,31 do begin

tau_max[i]=tauscale(where(smooth(c_matrix[i,*],smooth_fact) EQ max(smooth(c_matrix[i,*],smooth_fact))))
;tau_max[i]=total(tauscale*c_matrix[i,*]/total(c_matrix[i,*]))
;rd_gauss_fit, data_x=tauscale, data_y=c_matrix[i,*],cog=cog, dev=dev,ampl=ampl,/plotting
;if not defined(fit_prof) then fit_prof=fltarr(32,3)
;fit_prof[i,0]=ampl
;fit_prof[i,1]=cog
;fit_prof[i,2]=dev
result = POLY_FIT(tauscale, c_matrix[i,*], 4, MEASURE_ERRORS=measure_errors, SIGMA=sigma)  
;stop

plot,tauscale,smooth(c_matrix[i,*], smooth_fact)


plots,tau_max[i], c_matrix(i,where(smooth(c_matrix[i,*],smooth_fact) EQ max(smooth(c_matrix[i,*],smooth_fact)))), psym=7
;oplot, tauscale, result[0]+result[1]*tauscale+result[2]*tauscale^2+result[3]*tauscale^3+result[4]*tauscale^4
;Result2 = DERIV(tauscale, result[0]+result[1]*tauscale+result[2]*tauscale^2+result[3]*tauscale^3+result[4]*tauscale^4) 
;tau_max[i]=tauscale(where(abs(result2) EQ min(abs(result2))))
;stop
;wait,1
endfor
print, tau_max[sort(zr_pos[0,*])]
plot,zr_pos[0,sort(zr_pos[0,*])],tau_max[sort(zr_pos[0,*])], psym=7;, yrange=[-200,200]
stop
end


endcase
end
