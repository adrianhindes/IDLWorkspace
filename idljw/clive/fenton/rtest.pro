; Procedure to control 2D scanning via two translation stages, powered by stepper motors
; controlled by two SMC24B CAMAC stepper motor controllers. Uses smcdrv.pro as the driver
; SMC24B. Reads in 2dscan.ini as a [2,*] array of alternating x and y co-ords to move to,
; beginning with x as the first co-ord read. Can also provide an alternate input array
; from the command line. All x, y co-ords must be positive and are in millimetres.
; Assumes x-stage is at STEPPER_1 (defined VMS system logical) and y-stage at STEPPER_2
;
; Written by Fenton Glass, Oct. 1999

pro rtest
@rtest.ini
print, rt
print, 'It is assumed that the translation stages have been already placed at (0,0)'
print, 'This means that they both start with stage at the motor end of the rail.'
; Stage distance calibration: 100mm=20000 steps (Stepper motor=1.8 degrees per step)
xy=200.*xy
x=0 & y=0
print, xy
stop
for i=0, n_elements(xy(0,*))-1 do begin
	x_prev=x & y_prev=y
	x=xy(0,i) & y=xy(1,i)
	x_step=x-x_prev & y_step=y-y_prev
	smcdrv, name='STEPPER_1', action='ready', state=chk_state_x
	smcdrv, name='STEPPER_2', action='ready', state=chk_state_y
;	if (chk_state_y and chk_state_x) eq 1 then smcdrv, name='STEPPER_1', val=x_step
        smcdrv, name='STEPPER_1', val=x_step
        print, 'Stepped Stepper 1 ' + string(x_step)
        smcdrv, name='STEPPER_1', action='ready', state=chk_state_x
        while (chk_state_x eq 0) do begin
            smcdrv, name='STEPPER_1', action='ready', state=chk_state_x
            end
	smcdrv, name='STEPPER_1', action='ready', state=chk_state_x
        smcdrv, name='STEPPER_2', action='ready', state=chk_state_y
;	if (chk_state_y and chk_state_x) eq 1 then smcdrv, name='STEPPER_2', val=y_step
        smcdrv, name='STEPPER_2', val=-y_step
; Note: Use -y_step since the CW direction of the y-stage is toward
; the motor end
        print, 'Stepped Stepper 2 ' + string(y_step)
        smcdrv, name='STEPPER_2', action='ready', state=chk_state_y
        while (chk_state_y eq 0) do begin
            smcdrv, name='STEPPER_2', action='ready', state=chk_state_y
            end
	end

end


