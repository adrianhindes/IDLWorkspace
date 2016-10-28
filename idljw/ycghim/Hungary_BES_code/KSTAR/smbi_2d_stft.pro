pro smbi_2d_stft, shot

default, shot, 6352
default, refchannel, 1
default, vchan,6
default, ws, 1000
default, fres, 10
default, frange, [1e3, 1e5]
cd, 'D:\KFKI\Measurements\KSTAR\Measurement'
case shot of
  6352: t_smbi=2.7
  6353: t_smbi=2.5
  ;6376: t_smbi=[2.2,2.7,3.2]
endcase
twin=[t_smbi-0.01,t_smbi+0.01]

pos=plot_position(3,1)

for i=1,3 do begin
  refchan='BES-'+strtrim(refchannel,2)+'-'+strtrim(vchan,2)
  plotchan='BES-'+strtrim(refchannel+i,2)+'-'+strtrim(vchan,2)
  get_rawsignal, shot, refchan, timerange=twin, time, data1
  get_rawsignal, shot, plotchan, timerange=twin, time, data2
  stft=pg_cspectrogram_sim(data1,data2,time,plot=-1, freqax=freqax, windowsize=ws, freqres=fres)
  
    nx=n_elements(time)
  ny=n_elements(freqax)
  for fmin=0,ny-1 do begin
     if (freqax[fmin] ge frange[0]) then break
  endfor
  for fmax=fmin,ny-1 do begin
     if (freqax[fmax] ge frange[1]) then break
  endfor
  freqax=freqax[fmin:fmax]
  stft_rescale=fltarr(nx,fmax-fmin)
  stft_rescale=stft[0:nx-1,fmin:fmax]
  nc=round(50*(2e33-2e23)/(max(abs(stft_rescale)^2)-min(abs(stft_rescale)^2)))
  levels1=(max(abs(stft_rescale)^2)-min(abs(stft_rescale)^2))/50.*findgen(51)+min(abs(stft_rescale)^2)
  nx=n_elements(time)
  ny=n_elements(freqax)
  sig=abs(stft_rescale)^2
  
      DEVICE,DECOMPOSED=0
    show_rawsignal, shot2, channel, trange=time_range, position=[0.1,0.33,0.85,0.66], int=int, charsize=1, /noerase
    show_rawsignal, shot2, '\TOR_HA09', trange=time_range, position=[0.1,0.66,0.85,0.95], /noerase, ystyle=1
  ;    plot, time,data, position=[0.1,0.50,0.85,0.9], xcharsize=0.01, ycharsize=cs, xrange=range,$
  ;          xstyle=1, xticks=10, ytitle='Amplitude', yticks=4
      contour,sig,time,freqax,xstyle=1,ystyle=1,nlevels=32,$
              /fill,xcharsize=0.01,ycharsize=cs,ytitle='Frequency [kHz]',$
              xtitle='Time [s]',levels=levels1, position=pos[i-1,*],$
              xrange=range, xticks=10, /noerase
endfor

end