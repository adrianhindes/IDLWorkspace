pro smbi_2d_plot, shot, refchannel=refchannel, vchan=vchan, crossphase=crossphase, crosspower=crosspower, norm=norm, crosscorr=crosscorr,$
                  tau=tau, t_smbi=t_smbi, stft=stft, ps=ps
                  
default, shot, 6352
default, refchannel, 1
default, vchan, 6
default, taurange, [-30,30]
default, tau, 100. ;timewindow in us
default, fres, 100
default, frange, [1e3, 100e3]
default, taurange,[-100,100]
if keyword_Set(crosscorr) then begin
  default, filter_low, 10e3
  default, filter_high, 100e3
endif
if keyword_set(ps) then hardon, /color
cd, 'D:\KFKI\Measurements\KSTAR\Measurement'
tau=tau*1e-6
case shot of
  6352: t_smbi=2.7
  6353: t_smbi=2.5
  ;6376: t_smbi=[2.2,2.7,3.2]
endcase
twin=[t_smbi-0.5,t_smbi+0.5]
n_win=double(round((twin[1]-twin[0])/tau))
t_vec_smbi=[[findgen(n_win)/n_win*(twin[1]-twin[0])+twin[0]],[findgen(n_win)/n_win*(twin[1]-twin[0])+twin[0]+tau]]
refchan='BES-'+strtrim(refchannel,2)+'-'+strtrim(vchan,2)
plotchan='BES-'+strtrim(refchannel+1,2)+'-'+strtrim(vchan,2)
fluc_correlation, shot, timerange=reform(t_vec_smbi[0,*]),/noplot, ftype=1, outphase=outphase, outpower=outpower,outcorr=outcorr, outtime=outtime, outfscale=outfreq,$
                      refchan=refchan, plotchan=plotchan, interval_n=1, fres=fres, frange=frange, norm=norm, taurange=taurange, filter_high=filter_high, filter_low=filter_low
                      
if keyword_set(crosscorr) then plotphase=dblarr(n_win,n_elements(outtime),3) else plotphase=dblarr(n_win,n_elements(outfreq),3)

for i=0,n_win-1 do begin
  for j=1,3 do begin
    plotchan='BES-'+strtrim(refchannel+j,2)+'-'+strtrim(vchan,2)
    fluc_correlation, shot, timerange=reform(t_vec_smbi[i,*]), /plot_power, /noplot, ftype=1, outphase=outphase, outpower=outpower,outcorr=outcorr, outtime=outtime, outfscale=outfreq,$
                      refchan=refchan, plotchan=plotchan, interval_n=1, fres=fres, frange=frange, norm=norm, taurange=taurange, filter_high=filter_high, filter_low=filter_low
    if keyword_set(crossphase) then plotphase[i,*,j-1]=outphase
    if keyword_set(crosspower) then plotphase[i,*,j-1]=outpower
    if keyword_set(crosscorr) then plotphase[i,*,j-1]=outcorr
  endfor
endfor
default,nlev, 51
;default,plotrange,[-!pi,!pi]
default,plotrange,[min(plotphase),max(plotphase)]
default,levels,(findgen(nlev))/(nlev)*(plotrange[1]-plotrange[0])+plotrange[0]
pos=plot_position(3,1)
device, decomposed=0
loadct, 3
erase
if keyword_set(crosscorr) then begin
  for i=0,2 do begin
    contour, plotphase[*,*,i], (t_vec_smbi[*,0]+t_vec_smbi[*,1])/2, outtime,  /noerase, fill=1, nlev=nlev, levels=levels, position=pos[i,*]
  endfor
endif else begin
  for i=0,2 do begin
    contour, plotphase[*,*,i], (t_vec_smbi[*,0]+t_vec_smbi[*,1])/2, outfreq,  /noerase, fill=1, nlev=nlev, levels=levels, position=pos[i,*], /ylog
  endfor
endelse
if keyword_set(crossphase) then str='_crossphase'
if keyword_set(crosspower) then str='_crosspower'
if keyword_set(crosscorr) then str='_crosscorr'
if keyword_set(norm) then str=str+'_norm'
if keyword_set(filter_low) then str=str+'_filtered'
filename='smbi_analysis_'+strtrim(shot,2)+str+'.ps'
if keyword_set(ps) then hardfile, dir_f_name(dir_f_name('plots','smbi_analysis'),filename)
stop
end