pro demod2state,on,off,phase,width,height,stops

nmedian=4
nstddev=2
hw=6
for i=0, stops-1 do begin
   idx = where(abs(on[*,*,i] - median(on[*,*,i],nmedian)) gt nstddev*stddev(on[*,*,i]) )
   if idx[0] ne -1 then begin
      for k=0, n_elements(idx)-1 do begin
         loc = ARRAY_INDICES(on[*,*,i], idx[k] )
         box = [(loc[0]-hw)>0,(loc[1]-hw)>0,(loc[0]+hw)<(width-1),(loc[1]+hw)<(height-1)]
         on[box[0],box[1],i] = median(on(box[0]:box[2], box[1]:box[3],i),nmedian)
      end
   end
   idx = where(abs(off[*,*,i] - median(off[*,*,i],nmedian)) gt nstddev*stddev(off[*,*,i]) )
   if idx[0] ne -1 then begin
      for k=0, n_elements(idx)-1 do begin
         loc = ARRAY_INDICES(off[*,*,i], idx[k] )
         box = [(loc[0]-hw)>0,(loc[1]-hw)>0,(loc[0]+hw)<(width-1),(loc[1]+hw)<(height-1)]
         off[box[0],box[1],i] = median(off(box[0]:box[2], box[1]:box[3],i),nmedian)
      end
   end
end

filton =complexarr(width,height,stops)
filtoff=complexarr(width,height,stops)
for j=0,stops-1 do begin
   for k = 0,width-1 do  filton[k,*,j]  = fft(fft(reform( on[k,*,j],height)*hanning(height))*pass_mask(height,80,60,0.5),/inverse)
   for k = 0,width-1 do filtoff[k,*,j]  = fft(fft(reform(off[k,*,j],height)*hanning(height))*pass_mask(height,80,60,0.5),/inverse)
endfor

factor=2
phase=(((6*!pi-atan(filton,/phase)+atan(filtoff,/phase)+factor) mod (2*!pi)) -factor)/4*180/!pi

end

function pass_mask,height,centre,pass,taper

filter=fltarr(height)
filter[centre-pass/2-pass*taper:centre-pass/2]=0.5*(1-cos(findgen(pass*taper+1)*!pi/(pass*taper)))
filter[centre-pass/2:centre+pass/2]=1
filter[centre+pass/2:centre+pass/2+pass*taper]=0.5*(1+cos(findgen(pass*taper+1)*!pi/(pass*taper)))

return,filter

end