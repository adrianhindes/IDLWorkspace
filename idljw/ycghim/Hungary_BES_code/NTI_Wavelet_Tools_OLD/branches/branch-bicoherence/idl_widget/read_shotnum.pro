function read_shotnum, errorshot=errorshot

;****************************************************** 17. 05. 2005.
;Reads the actual shotnumber from the http server
; Result a long integer
; for windows users: wget need to be installed!!!
;
;
;Shot server changed 18. 05. 2009.
;
;
;*****************************************************


spawn, 'wget http://shotnumber.ipp.kfa-juelich.de/textor/fbadata.txt  --output-document=- -q', shdata
;print, shdata

IF (n_elements(shdata) LT 2) THEN BEGIN

    errorshot='Could not reach the shot number server'
    newshotnum=-1

ENDIF ELSE BEGIN
    st=strpos(shdata[1],':')
    stcut=strmid(shdata[1], st+1)
    newshotnum=long(stcut)


ENDELSE

return, newshotnum
end
