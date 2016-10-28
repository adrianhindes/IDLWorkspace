pro apdcam_close,errormess=errormess
; Closes the camera
;


errormess = ''

; VClose the socket
error = long(3)
R = CALL_EXTERNAL('CamControl.dll','idlClose', /CDECL)


end