pro analyse_core_turbulence, bigwin=bigwin, velocity=velocity

if keyword_set(bigwin)    then def=0
if keyword_set(velocity)  then def=1

if def eq 0 then begin  
  default,winsize,1
  
  cd, 'd:\KFKI\Measurements\KSTAR\Measurement'
  shot=[6056,6079]
  print, shot
  hardon, /color
  set_plot_style, 'foile_kg_eps'
  for i=0,n_elements(shot)-1 do begin
    show_rawsignal, shot[i],'BES-1-1', /noerase
    t2=5  
    t1=1
;    cursor,t1,y,/down
;    cursor,t2,y,/down
    nwin=fix(abs(t2-t1)/winsize)
    erase
    show_all_kstar_bes_power, shot[i], timerange=[2,3], /noerase
    erase
    xyouts, 0.8,0.95, strtrim(shot,2)+', [2,3]' , /normal
    ;for j=0,nwin-1 do begin
    ;  ;show_all_kstar_bes_power, shot[i], timerange=[t1+j*winsize,t1+(j+1)*winsize], /noerase
    ;  xyouts, 0.8,0.95, strtrim(shot,2)+' ['+strtrim(t1+j*winsize,2)+','+strtrim(t1+(j+1)*winsize,2)+']' , /normal
    ;  erase
    ;endfor
  endfor
  hardfile, 'plots/analyse_core_turbulence.ps'
endif
if def eq 1 then begin
    cd, 'd:\KFKI\Measurements\KSTAR\Measurement'
  pos=[[0.05,0.05,0.95,0.30],$
       [0.05,0.30,0.95,0.60],$
       [0.05,0.60,0.95,0.90]]
  ;time=[[1.5,2.5],$
  ;      [2.5,3.5],$
  ;      [3.5,4.5]]
  time=[[2,3]]
  hardon, /color
  shot=[6056,6079]
  set_plot_style, 'foile_kg_eps'
  for j=0,1 do begin
    for k=0,0 do begin
      for i=0,2 do begin
        if i eq 0 then begin
          xcharsize=1.5
          ycharsize=1.5
        endif else begin
          xcharsize=0.01
          ycharsize=1.5
        endelse
        fluc_correlation, shot[j], timerange=time[*,k],/plot_correlation, refchan='BES-1-2', plotchan='BES-'+strtrim(i+2,2)+'-2', $
                          outtime=outtime, outcorr=outcorr, position=pos[*,i], linethick=2, /noerase, /noerror, /nopara
        ;help, outtime, outcorr
        ;plot, outtime, outcorr,/noerase, xtitle='Time [s]', ytitle='Crosscorr', xcharsize=xcharsize,$
        ;      ycharsize=ycharsize, xstyle=1, ystyle=1, thick=2, position=pos[*,i] 
      endfor
      xyouts,0.7,0.95, 'Shot: '+strtrim(shot[j],2)+' Time: ['+strtrim(time[0,k],2)+','+strtrim(time[1,k],2)+']', /normal 
      erase
    endfor
  endfor
  hardfile, 'corr_turbulence.ps'
endif
end