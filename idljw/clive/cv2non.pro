pro cv2non, psi, epsilon, chi, delta,back=back

if not keyword_set(back) then begin
coschi = cos(psi) * cos(epsilon)
sinchi=sqrt(1-coschi^2) * sgn(  sin(psi))
tandelta=tan(epsilon) / sin(psi)

;cosdelta=cos(atan(delta))
;sinchi=

chi=atan(sinchi,coschi)
delta=atan(tandelta)

print,'hey2'

;chi=acos(cos(epsilon)*cos(psi))
;delta=acos(-((cos(epsilon)*sin(psi))/sqrt(1 - cos(epsilon)^2*cos(psi)^2)))

endif else begin

s3sq=$
-(((1 + tan(chi)^2)*tan(epsilon)^2)/(-tan(chi)^2 + tan(epsilon)^2))
tandelta= sqrt(s3sq) 
delta=atan(tandelta) * sgn(epsilon)

endelse


end

