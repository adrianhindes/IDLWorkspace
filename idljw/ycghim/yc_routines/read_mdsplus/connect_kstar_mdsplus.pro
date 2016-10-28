; This funcion connects to the KSTAR MDSPlus server
; It returns 1 if successfully connected, otherwise returns 0

FUNCTION connect_kstar_mdsplus

; Set the KSTAR MDSPlus address
  kstar_mdsplus_addr = '172.17.250.100:8005'

; Connect to KSTAR MDSPlus
  mdsconnect, kstar_mdsplus_addr, /QUIET, status=sta

  if bit_ffs(sta) EQ 1 then $ ;check the lowest bit of status is set to 1
    success = 1 $
  else $
    success = 0

  return, success  

END
