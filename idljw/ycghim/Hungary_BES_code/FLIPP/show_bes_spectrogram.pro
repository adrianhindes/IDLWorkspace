pro show_bes_spectrogram, shot, channel, timerange=timerange, nocalib=nocalib,$ 
                          fres=fres, tres=tres, filter_low=filter_low

;*****************************************************
;**** SHOW_BES_SPECTROGRAM  M. Lampert 2015.01.09 ****
;*****************************************************
;* The routine calculates the Short Time Fourier     *
;* transform for a given shot, channel, timerange.   *
;*                                                   *
;* INPUTs:                                           *
;*                                                   *
;* shot: shotnumber                                  *
;* channel: channel for calculation of the STFT      *
;* timerange: the timerange of the calculation [s]   *
;* nocalib: no relative calibration                  *
;* fres: frequency resolution of the calculation     *
;* tres: time resolution of the calculation          *
;* filter_low: low frequency filtering               *
;*                                                   *
;* OUTPUTs:                                          *
;* NON (the software plots the STFT)                 *
;*****************************************************

default, channel, 'BES-2-8'
default, timerange, [2,5]
default, nocalib, 1
default, fres, 5e2
default, tres, 0.05 ;time resolution in seconds
default, filter_low, 1e3

n_time=(timerange[1]-timerange[0])/tres
tres=(timerange[1]-timerange[0])/double(round(n_time))

split_timerange=timerange[0]+[[findgen(round(n_time))*tres],[(findgen(round(n_time))+1)*tres]]
n_time=n_elements(split_timerange[*,0])

; loop over all work packages
for i=0,n_time-1 do begin
  filter_low1=filter_low
  fluc_correlation, shot, refchan=channel, nocalib=nocalib,$
                    timerange=split_timerange[i,*],fres=fres,$
                    outfscale=outfscale, outpower=outpower, $
                    /plot_power,interval_n=1, /noplot, filter_low=filter_low1
                    
  if not defined(outpower_arr) then begin              
    outpower_arr=dblarr(n_elements(outpower),n_time)
  endif
  outpower_arr[*,i]=outpower          
endfor
loadct, 5
!p.font=-1
contour, transpose(outpower_arr), timerange[0]+findgen(round(n_time)+0.5)*tres, $
         outfscale/1e3, nlevel=21, /ylog, /fill,  yrange=[1,1e3],$
         title='Spectrogram for '+strtrim(shot,2)+' @ '+strtrim(timerange[0],2)+'s - '+strtrim(timerange[1],2)+'s, '+channel,$
         ytitle='Frequency [kHz]', xtitle='Time [s]', $
         zrange=[min(outpower_arr[where(outfscale gt filter_low),*]),max(outpower_arr[where(outfscale gt filter_low),*])],$
         thick=2, charsize=2
end