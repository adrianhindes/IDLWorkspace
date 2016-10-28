function pass_mask,height,centre,pass,taper

filter=fltarr(height)
filter[centre-pass/2-pass*taper:centre-pass/2]=0.5*(1-cos(findgen(pass*taper+1)*!pi/(pass*taper)))
filter[centre-pass/2:centre+pass/2]=1
filter[centre+pass/2:centre+pass/2+pass*taper]=0.5*(1+cos(findgen(pass*taper+1)*!pi/(pass*taper)))

return,filter

end

function adaptive_median, vector, nmedian=nmedian, nstddev=nstddev,stops=stops
;+
; A Filter to median clean only the noisy regions of an image or vector
; nmedian is the median filter width
; nstddev removes only those pixels which deviate more than nstddev from ave stddev
;  vector can be 1D or 2D
;-
  default, nstddev, 4
  default, nmedian, 13
  v_vec = vector
  sz=size(vector)
  h=sz[2]
  for i=0, stops-1 do begin
     for j=0, h-1 do begin
        v_new=v_vec[*,j,i]
        v_med = median(v_new, nmedian)
        d = v_new-v_med
        replace = where(abs(d) gt nstddev*stddev(d))
        if replace[0] ne -1 then v_new[replace] = v_med[replace]
        v_vec[*,j,i]=v_new
     end
  end
  return, v_vec
end

pro demod2state,on,off,phase,width,height,stops

on=adaptive_median(on,stops=stops)
off=adaptive_median(off,stops=stops)
on=adaptive_median(on,stops=stops)
off=adaptive_median(off,stops=stops)

filton =complexarr(width,height,stops)
filtoff=complexarr(width,height,stops)
for j=0,stops-1 do begin
   for k = 0,width-1 do  filton[k,*,j]  = fft(fft(reform( on[k,*,j],height)*hanning(height))*pass_mask(height,80,60,0.5),/inverse)
   for k = 0,width-1 do filtoff[k,*,j]  = fft(fft(reform(off[k,*,j],height)*hanning(height))*pass_mask(height,80,60,0.5),/inverse)
endfor

factor=2
phase=(((6*!pi-atan(filton,/phase)+atan(filtoff,/phase)+factor) mod (2*!pi)) -factor)/4*180/!pi

end
