FUNCTION DATAFROMFILE,file,$
	OLD=old,$
	SEPARATOR=separator,$
	ERROR=error

;-----------------------------------------------------------------
; Eric Arends
; 16/03/2000 - 01/08/2001
;
; This function returns data stored in the data file given as
; input.
;-----------------------------------------------------------------

	separator = '	'

;loading data file

	GET_LUN,lun
	OPENR,lun,file,ERROR=err


;reading data file

	IF (err EQ 0) THEN BEGIN

		firstline=''
		REPEAT READF,lun,firstline UNTIL STRMID(firstline,0,1) NE ';'
		header = STRSPLIT(firstline,/EXTRACT)
		Nd = N_ELEMENTS(header)
		firstlineisheader = 1
		ON_IOERROR,converr
		err = FLOAT(header)
		firstlineisheader = 0 ; skipped if conversion error

		converr: IF NOT firstlineisheader THEN BEGIN
			header = 'item'+STRTRIM((INDGEN(Nd)),2)
			POINT_LUN,lun,0
		ENDIF

		Nl = 0L
		line = ''
		data = 0*INTARR(Nd)-1

		WHILE NOT EOF(lun) DO BEGIN

			REPEAT READF,lun,line UNTIL (STRMID(line,0,1) NE ';') OR (EOF(lun))

			IF NOT EOF(lun) THEN BEGIN

				splitline = FLOAT(STRSPLIT(line,/EXTRACT))
				Nn = N_ELEMENTS(splitline)
				newdata = FLTARR(Nd)
				newdata(0:Nn-1) = splitline
				data = [[data],[newdata]]
				Nl=Nl+1L

			ENDIF ELSE BEGIN

				IF (STRMID(line,0,1) NE ';') THEN BEGIN

					splitline = FLOAT(STRSPLIT(line,/EXTRACT))
					Nn = N_ELEMENTS(splitline)
					newdata = FLTARR(Nd)
					newdata(0:Nn-1) = splitline
					data = [[data],[newdata]]
					Nl=Nl+1

				ENDIF

			ENDELSE

		ENDWHILE
		data=data(*,1:Nl)

		CLOSE,lun
		FREE_LUN,lun
		error = 0

	ENDIF ELSE BEGIN

		header = ['nope']
		data = [0.0,1.0]
		PRINT,'  Data not found. for file ..... '+file
		
		CLOSE,lun
		FREE_LUN,lun
		error = 1

	ENDELSE


;return result

	raw = CREATE_STRUCT('header',header,'data',data)
	IF KEYWORD_SET(OLD) THEN BEGIN

		result = raw
		FOR i=0,N_ELEMENTS(header)-1 DO result=CREATE_STRUCT(result,raw.header(i),REFORM([raw.data(i,*)]))

	ENDIF ELSE BEGIN

		result = CREATE_STRUCT(raw.header(0),REFORM([raw.data(0,*)]))
		FOR i=1,N_ELEMENTS(header)-1 DO result=CREATE_STRUCT(result,raw.header(i),REFORM([raw.data(i,*)]))

	ENDELSE

	RETURN,result

END
