
PRO open_ps,$
	xsize=xsize,$
	ysize=ysize,$
	font=font,$
	filename=filename

	IF NOT KEYWORD_SET(xsize) THEN xsize=12
	IF NOT KEYWORD_SET(ysize) THEN ysize=12
	IF NOT KEYWORD_SET(font) THEN !p.font = 0
	IF NOT KEYWORD_SET(filename) THEN filename = 'temp.eps'


	SET_PLOT, 'PS'
	DEVICE, FILENAME=filename, xsize=xsize, ysize=ysize,/COLOR,SET_FONT='Helvetica',/tt_font

	print,'OPEN_PS: saving as '+filename


END
