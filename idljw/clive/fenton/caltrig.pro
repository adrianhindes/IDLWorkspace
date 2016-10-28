; Procedure to trigger the digitisers waiting for a trigger
; under mantrig.tcl and turn the wheel 90 degrees anti-clockwise

pro caltrig

; trigger the digitisers here
 x=call_vms('CAMSHR','cam$piow', 'MOSS_4', 1, 25)
 x=call_vms('CAMSHR','cam$piow', 'MOSS_5', 1, 25)
 
; move the wheel

 smcdrv, name='STEPPER_1', val=666.*(-90)

end
