pro norm_k,k,ks,z,t,errormess=errormess,silent=silent

; ******************************************************************
; Normalises correlation functions by dividing with the square root
; of the autopowers.
; INPUT:
;   k: Correlation function calculated by zztcorr
;   ks: Error or correlation function
;   z: spatial coordinates  (cm)
;   t: time-lag coordinates (microsec)
; ******************************************************************

errormess=''
chn=(size(k))(1)
limit = min([1,(t(1)-t(0))*0.5])
i0=where(abs(t) lt limit)
if (i0(0) lt 0) then begin
  errormess='No 0 delay time available in autocorrelation. Cannot normalize.'
  if (not keyword_set(silent)) then print,errormess
    return
endif
i0=i0(0)
kn=k
if (keyword_set(ks)) then ksn=ks
for i=0,chn-1 do begin
  for j=0,chn-1 do begin
    if (keyword_set(ks)) then begin
      if ((k(i,i,i0) lt ks(i,i,i0)) or (k(j,j,i0) lt ks(j,j,i0))) then begin
        kn(i,j,*) = 0
        ksn(i,j,*)=1
      endif else begin
        kn(i,j,*)=k(i,j,*)/sqrt(abs(k(i,i,i0)*k(j,j,i0))>1e-20)
        ksn(i,j,*)=ks(i,j,*)/sqrt(abs(k(i,i,i0)*k(j,j,i0))>1e-20)
      endelse
    endif else begin
      kn(i,j,*)=k(i,j,*)/sqrt(abs(k(i,i,i0)*k(j,j,i0))>1e-20)
    endelse
  endfor
endfor
k=kn
if (keyword_set(ks)) then ks=ksn
end

