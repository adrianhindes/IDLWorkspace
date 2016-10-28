PRO close_ps,$
	jpeg=jpeg,$
	no_open=no_open,$
	filename=filename

	IF NOT KEYWORD_SET(filename) THEN filename = 'temp.eps'
	IF FILENAME eq 'temp.eps' THEN filename_jpeg = 'temp.jpeg' $
	ELSE filename_jpeg = (strsplit(filename,'.',/extract))(0)+'.jpeg' 

	IF FILE_TEST(filename) EQ 0 THEN BEGIN
		print,'CLOSE_PS: '+filename+' does not exist'
		RETURN
	ENDIF

	SET_DEVICE,'ps',/close

	IF KEYWORD_SET(jpeg) THEN BEGIN
		spawn,' convert '+filename+' '+filename_jpeg
		print,'CLOSE_PS: Your file has now been created as: '+filename_jpeg
		IF NOT KEYWORD_SET(no_open) THEN spawn,' xv '+filename_jpeg+ ' & '
	ENDIF
	
END
