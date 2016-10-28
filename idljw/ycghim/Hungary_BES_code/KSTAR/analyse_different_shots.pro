pro analyse_different_shots, stft=stft
  cd, 'D:\KFKI\Measurements\KSTAR\Measurement'
  if not (keyword_set(stft)) then begin
    shot=[7717, 7886, 7909]
    timerange=transpose([[3.5,4.5],[2.5,3.5],[2.4,3.4]])
    win=0.1
    n=n_elements(timerange)/2
    
    for i=0,n-1 do begin
      hardon, /color
      nvec=(timerange[i,1]-timerange[i,0])/win
      win_vec=dindgen(nvec)*win+timerange[i,0]
      for j=0, nvec-1 do begin
        show_all_kstar_bes_power, shot[i],/nocalib, timerange=[win_vec[j],win_vec[j]+win]
      endfor
      hardfile, 'analyse_'+strtrim(shot[i],2)+'.ps'
    endfor
  endif else begin
    default, fres, 1000
    default, frange, [1e3, 1e5]
    default, step, 2000
    default, channel, 'bes-4-6'
    shot=[7717, 7886, 7909]
    timerange=transpose([[3.4,6.1],[2.3,4.1],[2.2,4.4]])
    n=n_elements(timerange)/2
    hardon, /color
    for i=0,n-1 do begin
      show_bes_stft, shot[i], channel, timerange=timerange[i,*], fres=fres, tres=10, /nocalib
    endfor
    hardfile, 'analyse_stft.ps'
  endelse
  
end