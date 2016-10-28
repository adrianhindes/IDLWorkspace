pro apdcam_open,address=address,errormess=errormess
; Opens the camera
;
; INPUT:
;  address: the IP address of the camera (int array)
;           default is [10,123,13,101]


errormess = ''
default,address,[10,123,13,101]


; Calculating the ip address:
ipaddress = ishft(ulong(address[0]),24)+ishft(ulong(address[1]),16)+ishft(ulong(address[2]),8)+ulong(address[3])
; Open the socket
error = long(3)
R = CALL_EXTERNAL('CamControl.dll','idlOpen', ulong(ipaddress), long(error), /CDECL)

;print,error


end