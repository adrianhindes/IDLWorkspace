; This function disconnects the connection to the KSTAR MDSPlus server
; It returns 1 if successfully disconnected, otherwise returns 0.

FUNCTION disconnect_kstar_mdsplus

  mdsdisconnect, status = status

;  if bit_ffs(status) eq 1 then $ ;check the lowest big of status is set to 1
;    success = 1 $
;  else $
;    success = 0
; Note that status is always set to 0. This is not consistent with the manual.
; For now, I will just set the success to 1 always.
  success = 1

  return, success
 

 
END
