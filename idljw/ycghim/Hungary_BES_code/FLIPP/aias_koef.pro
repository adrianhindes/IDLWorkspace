function aias_koef
  w_aia_koef = replicate(1.,25)			; UPRAVENO 19.3.2004 ;;;;;;;;;;;;;;;;;;;

  w_aia_koef(1) = w_aia_koef(1) * 10.      ; channel 1				|	Uloop	|
  w_aia_koef(2) = w_aia_koef(2) *  4.      ;	   2				|	n_e 	|
  w_aia_koef(3) = w_aia_koef(3) *  4.      ;  	   3            	|	Ipl 	|
  w_aia_koef(4) = w_aia_koef(4) * (-1)     ;  	   4            	|	Bz_aver	|
  w_aia_koef(6) = w_aia_koef(6) * (-1)     ;  	   6            	|	Urad	|
  w_aia_koef(7) = w_aia_koef(7) *  198.5   ;  	   7            	|	Ivert	|
  w_aia_koef(8) = w_aia_koef(8) * (-1)     ;  	   8            	|	Uvert	|
  w_aia_koef(9) = w_aia_koef(9) * (-215)   ;  	   9            	|	Ihor	|
  w_aia_koef(11) = w_aia_koef(11) * (-1)   ;  	  11            	|	HalphaLim	|
  w_aia_koef(12) = w_aia_koef(12) * (-1)   ;  	  12            	|	HalphaCham	|
  w_aia_koef(13) = w_aia_koef(13) * (-1)   ;  	  13            	|	CIII	|
  w_aia_koef(14) = w_aia_koef(14) * (-1)   ;  	  14            	|	HXR 	|
  w_aia_koef(18) = w_aia_koef(18) * 100    ;  	  18            	|	Ubias	|
  w_aia_koef(19) = w_aia_koef(19) / 2e-3   ;  	  19            	|	Ibias	|
  w_aia_koef(23) = w_aia_koef(23) / 2e-1   ;  	  23            	|	Idyn	|

  return, w_aia_koef

end