pro analyse_velocity, shot=shot, timerange=timerange, all=all, two_chan=two_chan, rad_chan=rad_chan, $
    tres_out=tres_out, taurange=taurange, filter_low=filter_low, filter_high=filter_high, $
    cache_erase=cache_erase, ps=ps, average=average, velocity=velocity
  
  !p.font=0
  default, shot, 6352
  default, timerange, [2.3,3]
  default, all, 0
  default, two_chan, [1,2]
  default, rad_chan, 6
  default, filter_low, 10e3
  default, filter_high, 100e3
  default, taurange, [-10e-6,15e-6]
  default, tres_out, 0.001
  
  cd, 'D:\KFKI\Measurements\KSTAR\Measurement'
  case shot of
    6352: t_smbi=2.7
    6353: t_smbi=2.5
    6376: t_smbi=[2.2,2.7,3.2]
  endcase
  erase
  loadct, 5
  device, decomposed=0
  det_pos=getcal_kstar_spat(shot)
  if (keyword_set(ps)) then hardon, /color
if not (keyword_set(all)) then begin
  if keyword_set(average) then begin
    
    for i=1,4 do begin
      get_rawsignal, shot, 'BES-'+strtrim(i,2)+'-'+strtrim(rad_chan,2), timerange=timerange, cache='signal'+strtrim(i,2)
      print, 'BES-'+strtrim(i,2)+'-'+strtrim(rad_chan,2)
    endfor 
    for i=0,2 do begin
      print, 'signal'+strtrim(i+1,2), 'signal'+strtrim(i+2,2)
      sigproc_tde, 'signal'+strtrim(i+1,2), 'signal'+strtrim(i+2,2), td_signal_out='td_signal_out'+strtrim(i+1,2), tres_out=tres_out, $
                   taurange=taurange, filter_low=filter_low, filter_high=filter_high, /cs
      get_rawsignal, 0, 'cache/td_signal_out'+strtrim(i+1,2), t, d
      if (i eq 0) then begin
        a=d/3.
      endif
      a=a+d/3.
    endfor
    plot, t, a
  endif else begin
    print, 'BES-'+strtrim(two_chan[0],2)+'-'+strtrim(rad_chan,2)
    print, 'BES-'+strtrim(two_chan[1],2)+'-'+strtrim(rad_chan,2)
    get_rawsignal, shot, 'BES-'+strtrim(two_chan[0],2)+'-'+strtrim(rad_chan,2), timerange=timerange, cache='signal1'
    get_rawsignal, shot, 'BES-'+strtrim(two_chan[1],2)+'-'+strtrim(rad_chan,2), timerange=timerange, cache='signal2'
    sigproc_tde, 'signal1', 'signal2', td_signal_out='td_signal_out', tres_out=tres_out, $
                 taurange=taurange, filter_low=filter_low, filter_high=filter_high, /cs
    show_rawsignal, 0, 'cache/td_signal_out'
  endelse
  if keyword_set(cache_erase) then signal_cache_delete, /all
endif else begin
  pos=plot_position(4,8, /block, xgap=0.03, ygap=0.05)
  for i=1,8 do begin
    for j=1,3 do begin
      get_rawsignal, shot, 'BES-'+strtrim(j,2)+'-'+strtrim(i,2), timerange=timerange, cache='signal1'
      get_rawsignal, shot, 'BES-'+strtrim(j+1,2)+'-'+strtrim(i,2), timerange=timerange, cache='signal2'
      sigproc_tde, 'signal1', 'signal2', td_signal_out='td_signal_out', tres_out=tres_out, $
                   taurange=taurange, filter_low=filter_low, filter_high=filter_high, /cs
      
      
      get_rawsignal, 0, 'cache/td_signal_out',t,d
    if keyword_set(velocity) then begin
      ytitle='Velocity [km/s]'
      dist=mean(abs(det_pos[0:2,i-1,1]-det_pos[1:3,i-1,1]))
      d=dist/d
    endif else begin
      ytitle='Time lag [us]'
    endelse
      if j eq 1 then xch=1 else xch=0.01
      if i eq 1 then ych=1 else ych=0.01
      ch=0.5
      
      plot, t, d, position=pos[j-1,i-1,*], /noerase, title='BES-'+strtrim(j,2)+'-'+strtrim(i,2)+'<->'+'BES-'+strtrim(j+1,2)+'-'+strtrim(i,2),$
            xcharsize=xch, ycharsize=ych, charsize=ch, xtitle='Time [s]', ytitle=ytitle, yrange=taurange*1e6, xticks=3, yticks=3,$
            xstyle=1, ystyle=1
            
      for is=0,n_elements(t_smbi)-1 do oplot, [t_smbi[is],t_smbi[is]],[-100,100], color=64, linestyle=2
    endfor
    
    for j=1,4 do begin
      get_rawsignal, shot, 'BES-'+strtrim(j,2)+'-'+strtrim(i,2), timerange=timerange, cache='signal'+strtrim(j,2)
      print, 'BES-'+strtrim(j,2)+'-'+strtrim(rad_chan,2)
    endfor 
    for j=0,2 do begin
      if j eq 1 then xch=1 else xch=0.01
      if i eq 1 then ych=1 else ych=0.01
      ch=0.5
      print, 'signal'+strtrim(j+1,2), 'signal'+strtrim(j+2,2)
      sigproc_tde, 'signal'+strtrim(j+1,2), 'signal'+strtrim(j+2,2), td_signal_out='td_signal_out'+strtrim(j+1,2), tres_out=tres_out, $
                   taurange=taurange, filter_low=filter_low, filter_high=filter_high, /cs
      get_rawsignal, 0, 'cache/td_signal_out'+strtrim(j+1,2), t, d
      if (j eq 0) then begin
        a=d/3.
      endif
      a=a+d/3.
    endfor
    if keyword_set(velocity) then begin
      ytitle='Velocity [km/s]'
      dist=mean(abs(det_pos[0:2,i-1,1]-det_pos[1:3,i-1,1]))
      a=dist/a
    endif else begin
      ytitle='Time lag [us]'
    endelse
    plot, t, a, position=pos[3,i-1,*], /noerase, title='Average: Row='+strtrim(i,2), xcharsize=xch, ycharsize=ych, $
          charsize=ch, xtitle='Time [s]', ytitle=ytitle, yrange=taurange*1e6, xstyle=1, xticks=3, yticks=3
    for is=0,n_elements(t_smbi)-1 do oplot, [t_smbi[is],t_smbi[is]],[-100,100], color=64, linestyle=2
  endfor
  xyouts, 0.05, 0.97, 'Shot: '+strtrim(shot,2)+' Filter_low: '+strtrim(round(filter_low/1e3),2)+'kHz Filter_high: '+strtrim(round(filter_high/1e3),2)+'kHz Time resolution: '+$
        strtrim(round(tres_out*1e3),2)+'ms Taurange: ['+strtrim(round(taurange[0]*1e6),2)+'us,'+strtrim(round(taurange[1]*1e6),2)+'us]', /normal, charsize=0.5
  if (keyword_set(ps)) then hardfile, 'velocity_analysis_'+strtrim(shot,2)+'_'+strtrim((timerange[0]+timerange[1])/2,2)+'_all.ps'
endelse

end