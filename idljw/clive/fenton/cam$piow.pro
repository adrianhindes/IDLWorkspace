pro CAM$PIOW,MODULE,A,F,DATA,MEM,IOSB
;+
;CAM$PIOW does single programmed input/output.
;-
	if (n_elements(DATA) ne 1L) then DATA = 0L
	if (n_elements(MEM) ne 1L) then MEM = !CAM$MEM
	if (MEM ne 24) then if (MEM ne 16) then MEM = !CAM$MEM
;	if (MEM eq 16) then DATA = fix(DATA) else DATA = long(DATA)
	IOSB = !CAM$IOSB
	CAM$$CHECK,call_vms('CAMSHR','CAM$PIOW',MODULE,A,F,DATA,MEM,IOSB)
	!CAM$IOSB = IOSB
	if (!CAM$XSTATE le 0L) then if (!CAM$XSTATE ne call_vms('CAMSHR','CAM$X',IOSB)) then $
		message,string('module,A,F,bad_X: ',MODULE,A,F,call_vms('CAMSHR','CAM$X',IOSB))
	if (!CAM$QSTATE le 0L) then if (!CAM$QSTATE ne call_vms('CAMSHR','CAM$Q',IOSB)) then $
		message,string('module,A,F,bad_Q: ',MODULE,A,F,call_vms('CAMSHR','CAM$Q',IOSB))
end
