pro deflection_overview,shot,shot_nodeflection=shot_nodeflection,trange_nodeflection=trange_nodefl,trange_deflection=trange_defl,$
  nosignal=nosignal,channels=channels,nocalculate=nocalculate,taurange_auto=taurange_auto,taurange_cross=taurange_cross

;************************************************************************************
;* DEFLECTION_OVERVIEW.PRO                                                          *
;*                                                                                  *
;* Plot overview of fast deflection measurement.                                    *
;*                                                                                  *
;* INPUT:                                                                           *
;*   shot: Shot nunber                                                              *
;*   shot_nodeflection: The shot number without deflection (def: shot)              *
;*   trange_deflection: Time range when beam is deflected.                          *
;*   trange_nodeflection: Time range when ben is not deflected.                     *
;*   channels: Channel list. (default is defchannels())                             *
;*   /nosignal: Do not process deflected signals, they are already in signal cache. *
;*   /nocalculate: Do not calculate, use results of last calculation                *
;************************************************************************************

default,shot,107253
default,shot_nodeflection,shot
default,trange_nodefl,[1.4,1.5]
default,trange_defl,[1.55,1.65]
default,lowcut,30
default,cut_len,2
default,taurange_auto,[-100,100]
default,taurange_cross,[-30,30]

default,channels,defchannels(shot)

nchan = n_elements(channels)

erase
time_legend,'deflection_overview.pro'
xyouts,0.15,0.95,/norm,i2str(shot),charsize=2,charthick=3

pos_lightprof = [0.07,0.8 ,0.35, 0.9]
pos_noiseprof = [0.07,0.6,0.35, 0.7]
pos_flucprof = [0.07,0.4,0.35, 0.5]
pos_relnoise = [0.07,0.2,0.35, 0.3]
pos_totfluc = [0.4, 0.8, 0.63, 0.9]
pos_delayprof = [0.4, 0.6, 0.63, 0.7]
pos_autocorrs = [0.7,0.1,0.8,0.9]
pos_crosscorrs = [0.85,0.1,0.95,0.9]

lightprof_nodefl = fltarr(nchan)
lightprof_defl_1 = fltarr(nchan)
lightprof_defl_2 = fltarr(nchan)
noiseprof = fltarr(nchan)
totfluc_prof = fltarr(nchan)
totfluc_prof_1 = fltarr(nchan)
totfluc_prof_2 = fltarr(nchan)
flucprof = fltarr(nchan)
delayprof = fltarr(nchan)


if (not keyword_set(nocalculate)) then begin

if (not keyword_set(nosignal)) then begin
  signal_cache_delete,/all
  print,'Processing deflected signals...'
  wait,0.1
  fastdefl_signal,shot,channels,timerange=trange_defl
  print,'...done'
endif

for i=0,nchan-1 do begin
  print,'Processing '+channels[i]
  get_rawsignal,shot_nodeflection,channels[i],t,d,trange=trange_nodefl,errormess=e
  if (e ne '') then return
  lightprof_nodefl[i] = mean(d)

  fluc_correlation,shot_nodeflection,refchan=channels[i],plotchan=channels[i],timerange=trange_nodefl,cut_len=0,lowcut=lowcut,$
      outcorr=outcorr,outtime=outtime,errormess=e,/silent,/noplot
  if (e ne '') then begin & print,e & return & endif
  ind = where(outtime eq 0)
  totfluc_prof[i] = sqrt(outcorr[ind[0]])/lightprof_nodefl[i]

  fluc_correlation,shot_nodeflection,refchan=channels[i],plotchan=channels[i],timerange=trange_nodefl,cut_len=cut_len,lowcut=lowcut,$
      outcorr=outcorr,outtime=outtime,errormess=e,/silent,/noplot,taurange=taurange_auto
  if (e ne '') then begin & print,e & return & endif
  ind = where(outtime eq 0)
  flucprof[i] = sqrt(outcorr[ind[0]])/lightprof_nodefl[i]
  noiseprof = sqrt(totfluc_prof^2-flucprof^2)
  if (i eq 0) then begin
    autocorrs = fltarr(nchan,n_elements(outtime))
  endif
  autocorrs[i,*] = outcorr
  autocorr_time = outtime

  print,'Processing cache/'+i2str(shot)+'_'+channels[i]+'_1'
  get_rawsignal,shot,'cache/'+i2str(shot)+'_'+channels[i]+'_1',t,d,trange=trange_defl,errormess=e
  if (e ne '') then begin & print,e & return & endif
  lightprof_defl_1[i] = mean(d)

  fluc_correlation,shot,refchan='cache/'+i2str(shot)+'_'+channels[i]+'_1',plotchan='cache/'+i2str(shot)+'_'+channels[i]+'_1',$
      timerange=trange_defl,cut_len=0,lowcut=lowcut,$
      outcorr=outcorr,outtime=outtime,errormess=e,/silent,/noplot
  if (e ne '') then begin & print,e & return & endif
  ind = where(outtime eq 0)
  totfluc_prof_1[i] = sqrt(outcorr[ind[0]])/lightprof_defl_1[i]


  print,'Processing cache/'+i2str(shot)+'_'+channels[i]+'_2'
  get_rawsignal,shot,'cache/'+i2str(shot)+'_'+channels[i]+'_2',t,d,trange=trange_defl,errormess=e
  if (e ne '') then begin & print,e & return & endif
  lightprof_defl_2[i] = mean(d)

  fluc_correlation,shot,refchan='cache/'+i2str(shot)+'_'+channels[i]+'_2',plotchan='cache/'+i2str(shot)+'_'+channels[i]+'_2',$
      timerange=trange_defl,cut_len=0,lowcut=lowcut,$
      outcorr=outcorr,outtime=outtime,errormess=e,/silent,/noplot
  if (e ne '') then begin & print,e & return & endif
  ind = where(outtime eq 0)
  totfluc_prof_2[i] = sqrt(outcorr[ind[0]])/lightprof_defl_2[i]

  fluc_correlation,shot,refchan='cache/'+i2str(shot)+'_'+channels[i]+'_1',plotchan='cache/'+i2str(shot)+'_'+channels[i]+'_2',$
      timerange=trange_defl,cut_len=0,lowcut=lowcut,taurange=taurange_cross,$
      outcorr=outcorr,outtime=outtime,errormess=e,/silent,/noplot
  ind = where(outcorr eq max(outcorr))
  x = outtime[[ind[0]-1,ind[0],ind[0]+1]]
  y = outcorr[[ind[0]-1,ind[0],ind[0]+1]]
  p = poly_fit(x,y,2,/double,status=s)
  delayprof[i] = -p[1]/(2*p[2])
  if (i eq 0) then begin
    crosscorrs = fltarr(nchan,n_elements(outtime))
  endif
  crosscorrs[i,*] = outcorr
  crosscorr_time = outtime
endfor

  save,file=dir_f_name('tmp','deflection_overview.sav');
endif else begin
  restore,file=dir_f_name('tmp','deflection_overview.sav');
endelse

chlist = strmid(channels,4)
plot,chlist,lightprof_nodefl,/noerase,xrange=[0,17],xstyle=1,$
     yrange=[0,max([lightprof_nodefl,lightprof_defl_1,lightprof_defl_2])*1.05],ystyle=1,title='Light profiles',$
     pos=pos_lightprof
oplot,chlist,lightprof_defl_1,linestyle=1
oplot,chlist,lightprof_defl_1,linestyle=2,thick=3

ind = where((flucprof ne 0) and finite(flucprof))
flucprof = flucprof[ind]
noiseprof = noiseprof[ind]
totfluc_prof = totfluc_prof[ind]
totfluc_prof_1 = totfluc_prof_1[ind]
totfluc_prof_2 = totfluc_prof_2[ind]

plot,chlist[ind],noiseprof,/noerase,xrange=[0,17],xstyle=1,$
     yrange=[0,max(noiseprof)*1.05],ystyle=1,title='Relative noise',$
     pos=pos_noiseprof

plot,chlist[ind],flucprof,/noerase,xrange=[0,17],xstyle=1,$
     yrange=[0,0.2],ystyle=1,title='Relative fluctuation',$
     pos=pos_flucprof

plot,chlist[ind],noiseprof/flucprof,/noerase,xrange=[0,17],xstyle=1,xtitle='Channels',$
     yrange=[0,max(noiseprof/flucprof)*1.05],ystyle=1,title='Relative noise/relative fluctuation',$
     pos=pos_relnoise

plot,chlist[ind],totfluc_prof,/noerase,xrange=[0,17],xstyle=1,$
     yrange=[0,max([totfluc_prof,totfluc_prof_1,totfluc_prof_2])*1.05],ystyle=1,title='Relative total fluctuations',$
     pos=pos_totfluc
oplot,chlist[ind],totfluc_prof_1,linestyle=1
oplot,chlist[ind],totfluc_prof_2,linestyle=2

plot,chlist[ind],delayprof,/noerase,xrange=[0,17],xstyle=1,$
     yrange=[min(delayprof),max(delayprof)]+[-1,1]*(max(delayprof)-min(delayprof))*0.05,ystyle=1,title='Time delay [!7l!Xs]',$
     pos=pos_delayprof

dpos = (pos_autocorrs[3]-pos_autocorrs[1])/nchan
for i=0,nchan-1 do begin
   yrange = [min(reform(autocorrs[i,*])),max(reform(autocorrs[i,*]))]
   yrange = yrange+[-1,1]*0.05*(yrange[1]-yrange[0])
   if (i eq nchan-1) then xtickname = '' else xtickname=replicate(' ',20)
   plot,autocorr_time,reform(autocorrs[i,*]),/noerase,pos=[pos_autocorrs[0],pos_autocorrs[3]-(i+1)*dpos,pos_autocorrs[2],pos_autocorrs[3]-i*dpos],$
     xrange=taurange,yrange=yrange,ystyle=1,ytickname=replicate(' ',20),xtickname=xtickname
endfor

for i=0,nchan-1 do begin
   yrange = [min(reform(crosscorrs[i,*])),max(reform(crosscorrs[i,*]))]
   yrange = yrange+[-1,1]*0.05*(yrange[1]-yrange[0])
   if (i eq nchan-1) then xtickname = '' else xtickname=replicate(' ',20)
   plot,crosscorr_time,reform(crosscorrs[i,*]),/noerase,pos=[pos_crosscorrs[0],pos_crosscorrs[3]-(i+1)*dpos,pos_crosscorrs[2],pos_crosscorrs[3]-i*dpos],$
     xrange=taurange,yrange=yrange,ystyle=1,ytickname=replicate(' ',20),xtickname=xtickname
   oplot,[0,0],yrange,linestyle=1
endfor
end
