pro show_bes_stft, shot,channel, timerange=timerange, fres=fres, tres=tres, nocalib=nocalib, wres=wres
;--------------------------------------------------------
;------------------   show_bes_stft   -------------------
;--------------------------------------------------------
;* The procedure plots the Short time Fourier-transform *
;* for a given shot and channel.                        *
;********************************************************
;* INPUTs:                                              *
;*                                                      *
;*      shot:      shotnumber                           *
;*      channel:   channel name, eg.: 'bes-1-1'         *
;*      timerange: timerange for the calculation        *
;*      fres:      frequency resolution for the STFT    *
;*                 calc in Hz                           *
;*      tres:      time resolution for stft in ms       *
;*      nocalib:   no calibration file is read for      *
;*                 get_rawsignal                        *
;********************************************************
  erase
    cd, 'D:\KFKI\Measurements\KSTAR\Measurement'
  default, nocalib, 0
  default, sample_freq, 2e6
  default, frange, [6e3,100e3]
  default, wres, 1000
  ;These lines calculate the input parameters for the stft calculation
  step=tres/1e3*sample_freq
  ws=wres/1e3*sample_freq
  freqres=sample_freq/fres
  get_rawsignal, shot,channel,t,d, timerange=timerange, nocalib=nocalib
  stft=pg_spectrogram_sim(d,t,plot=-1, freqax=freqax, windowsize=ws, step=step, freqres=freqres, windowname='Gauss')
  nx=n_elements(t)
  ny=n_elements(freqax)
  for fmin=0l,ny-1 do begin
     if (freqax[fmin] ge frange[0]) then break
  endfor
  for fmax=long(fmin),ny-1 do begin
     if (freqax[fmax] ge frange[1]) then break
  endfor
  freqax=freqax[fmin:fmax]
  stft_rescale=fltarr(nx,fmax-fmin)
  stft_rescale=stft[0:nx-1,fmin:fmax]
  n_level=100.
  nc=round(n_level*(2e33-2e23)/(max(abs(stft_rescale)^2)-min(abs(stft_rescale)^2)))
  levels1=(max(abs(stft_rescale)^2)-min(abs(stft_rescale)^2))/n_level*findgen(n_level+1)+min(abs(stft_rescale)^2)
  nx=n_elements(time)
  ny=n_elements(freqax)
  sig=abs(stft_rescale)^2
  loadct, 3
  DEVICE,DECOMPOSED=0
  contour,sig,t,freqax,xstyle=1,ystyle=1,nlevels=32,$
          /fill,xcharsize=1,ycharsize=1,ytitle='Frequency [kHz]',$
          xtitle='Time [s]',levels=levels1, $;position=pos[i-1,*],$
          xrange=range, xticks=10, /noerase, /ylog,$
          title='Shot: '+strtrim(shot,2)+' Channel: '+channel

end