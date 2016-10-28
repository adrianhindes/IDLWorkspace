; Name: pg_initgraph
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2003.04.15.
;
; Purpose: Initialize graphics
;
; Calling sequence:
;	pg_initgraph [,/print] [,/portrait]
;
; Inputs:
;	/print (optional): Print to file instead of plotting
;	/portrait (optional): Portrait ps file
;
; Output: -

pro pg_initgraph, print=print, portrait=portrait

!P.MULTI=0

if keyword_set(print) then begin
	set_plot, 'PS'
	if keyword_set(portrait) then device,bits_per_pixel=8,font_size=8,/color,/portrait $
	else device,bits_per_pixel=8,font_size=8,/color,/landscape,/encapsulated,/bold,/cmyk,/preview,/times
endif else begin
	if (strupcase(!version.os) EQ 'WIN32') then begin
		set_plot, 'WIN'
		device,retain=2,decompose=0
	endif else begin
		set_plot, 'X'
		device,retain=2,decompose=0
	endelse
endelse

end
