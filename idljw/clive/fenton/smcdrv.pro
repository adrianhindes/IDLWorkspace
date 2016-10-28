
pro smcdrv, name=name, action=action, val=val, state=state, help= help, status=status

;+
; 
;   Programmed by Adam Last January 1999
;   Additional mucking about by Fenton Glass, Jan. 2000
;
;   This is a device specific program for the SMC24B stepper motor 
;   controller.
;
;
;
; LEGAL 'Actions':
;
;        'ZERO'     = Rotates wheel to limit position.  Resets driver.
;        'MOVE'     = Accepts two's complement data and moves wheel by
;                     that many ticks 1.8 degrees / tick.
;        'READY'    = Returns all you wish to know.
;        'OVERRIDE' = Leave H1 and roll to Barbados.  
;        'STATUS'   = Returns results of status register. (See Page 6
; of SMC24B documentation.)
;        'LTEST'    = Specifically tests the limit conditions
;        'ATEST'    = Specifically tests to see if module is
; active. state=0 if module is not active and =1 for active.
;        'RESET'    = Stops motor, aborts cycle, resets unit. Has
; trouble with this command if stepper is under load. i.e. after
; issuing this command the SMC24B believes it is sending subsequent 
; commands but the motor doesn't turn and one of the transistors burns
; out. Use with caution!
;        'DECEL'    = Decelerates to stop, pause mode
;        'ACCEL'    = From pause mode, accelerate and resume previous command
;-

;progfile = 'smcdrv'


default, name, 'STEPPER_2'
default, action, 'MOVE'
default, val,   0
default, state,  0

iosb=110976

;
;  This line is here to allow debugging on the Alpha OSF UNIX system
;  It looks at the third variable in the !Version structure which
;  is 'vms' on the PRLAS0 system.

camv2
IF NOT(!version.(2) EQ 'vms') THEN BEGIN

print, 'Debugging mode :accessing module '+name+' to  '+action
print, 'Amount to be moved is '+string(val)

ENDIF ELSE BEGIN

case strupcase(action) of
'INIT': begin
  ; Not being implemented until positioning system prototyped
;  x=call_vms('CAMSHR','cam$piow',name, 0, 25)
 campiow,name, 0, 25
  
 end 

'MOVE': begin
  moveam=LONG(val)
;  x=call_vms('CAMSHR','cam$piow',name, 0, 16, moveam)
  campiow,name, 0, 16, moveam

 end 


'READY': begin

;    x = call_vms('CAMSHR','cam$piow',name, 1, 27, val, 24, iosb)  
    campiow,name, 1, 27, val, 24, iosb
    state=camq(iosb)
;    state = call_vms('CAMSHR','cam$q', iosb)
end

'STATUS': begin

    print, 'Doing Status report ...'
    stat_reg=0
    campiow, name, 1, 0, stat_reg, 24, iosb
;    x = call_vms('CAMSHR','cam$piow', name, 1, 0, stat_reg, 24, iosb)
    status=bytarr(8)
    for i=0,7 do begin
        status(i)=bittest(stat_reg, i+1, 1)
        if i eq 0 then status(i)=not float(status(i))
        if (i eq 0 and status(i) eq 0) then print, 'External Power Status Input is low.'
        if (i eq 0 and status(i) eq 1) then print, 'External Power Status Input is high.'
        if (i eq 1 and status(i) eq 1) then print, 'CW Limit Condition Input is high.'
        if (i eq 1 and status(i) eq 0) then print, 'CW Limit Condition Input is low.'
        if (i eq 2 and status(i) eq 1) then print, 'CCW Limit Condition Input is high.'
        if (i eq 2 and status(i) eq 0) then print, 'CCW Limit Condition Input is low.'
        if i eq 3 then status(i)=not float(status(i))
        if (i eq 3 and status(i) eq 0) then print, 'Module not active, can accept new command.'
        if (i eq 3 and status(i) eq 1) then print, 'Module active, cannot accept new command.'
        if (i eq 4 and status(i) eq 1) then print, 'No 24 volt power output.'
        if (i eq 4 and status(i) eq 0) then print, '24 volt power output present.'
        if (i eq 5 and status(i) eq 1) then print, 'Driver Power On.'
        if (i eq 5 and status(i) eq 0) then print, 'Driver Power Off.'
        if (i eq 6 and status(i) eq 1) then print, 'Module Active'
        if (i eq 6 and status(i) eq 0) then print, 'Module Not Active.'
        if (i eq 7 and status(i) eq 1) then print, 'Module in Pause Mode.'
        if (i eq 7 and status(i) eq 0) then print, 'Module Not in Pause Mode.'
    end
end

'LTEST': begin

    stat_reg=0
;    x = call_vms('CAMSHR','cam$piow', name, 1, 0, stat_reg, 24, iosb)
    campiow, name, 1, 0, stat_reg, 24, iosb
    r2=bittest(stat_reg, 2, 1)
    r3=bittest(stat_reg, 3, 1)
    if (r2 eq 1 and r3 eq 1) then state='CW_CCW'
    if (r2 eq 1 and r3 eq 0) then state='CW'
    if (r2 eq 0 and r3 eq 0) then state='NL'
    if (r2 eq 0 and r3 eq 1) then state='CCW'
end

'ATEST': begin

    stat_reg=0
;    x = call_vms('CAMSHR','cam$piow', name, 1, 0, stat_reg, 24, iosb)
    campiow, name, 1, 0, stat_reg, 24, iosb
    r4=bittest(stat_reg, 4, 1)
    if r4 eq 1 then state=0 else state=1

end

'DPTEST': begin

    stat_reg = 0
;    x = call_vms('CAMSHR', 'cam$piow', name, 1, 0, stat_reg, 24, iosb)
    campiow, name, 1, 0, stat_reg, 24, iosb
    r6 = bittest(stat_reg, 6, 1)
    if r6 then state='DP_ON' else state='DP_OFF'
end

'DECEL': begin

;    x = call_vms('CAMSHR', 'cam$piow', name, 0, 24)
    campiow, name, 0, 24
end

'ACCEL': begin

;    x = call_vms('CAMSHR', 'cam$piow', name, 0, 26)
    campiow, name, 0, 26
end

'RESET': begin
    
;    x = call_vms('CAMSHR', 'cam$piow', name, 0, 25)
   campiow, name, 0, 25
end

endcase

endelse

END













