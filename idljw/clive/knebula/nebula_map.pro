Pro nebula_map, rpsi,zpsi,timepsi,psi,rvec,zvec,tvec,npsi
	 
;-------------------------------------------------------------------------------
; Interpolate onto a 3 dimensional array
;-------------------------------------------------------------------------------
Ridx    = (Rvec-min(Rpsi))/(max(Rpsi)-min(Rpsi)) * (n_elements(Rpsi)-1)
Zidx    = (zvec-min(Zpsi))/(max(Zpsi)-min(Zpsi)) * (n_elements(Zpsi)-1)
timeidx = (tvec-min(timepsi))/(max(timepsi)-min(timepsi)) * (n_elements(timepsi)-1)
npsi    = reform(interpolate(psi,Ridx,Zidx,timeidx,/grid))	

End
