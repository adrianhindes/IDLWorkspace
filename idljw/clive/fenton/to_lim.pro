; Procedure to take the wheel to one of the limits (CW or CCW)

pro to_lim, stepper, limit, fast=fast

default, fast, 0
default, stepper, 'STEPPER_2'

smcdrv, name=stepper, action='dptest', state=dpstate
if dpstate eq 'DP_OFF' then begin
    print, 'Driver Power currently off for ', stepper
    return
    end

smcdrv, name=stepper, action='ltest', state=lstate0

if limit eq 'CW' then smult=1
if limit eq 'CCW' then smult=-1

if lstate0 eq 'CW' and limit eq 'CW' then print, 'Already at that limit schmuck!'
if lstate0 eq 'CCW' and limit eq 'CCW' then print, 'Already at that limit schmuck!

print, 'Going to ', limit, ' limit'

; stepper motor speed in steps per second
st_speed=450.

while lstate0 ne limit do begin
    if fast eq 1 then value=smult*666 else value=smult*10
    smcdrv, name=stepper, val=value
    wait, abs(value)/st_speed
    smcdrv, name=stepper, action='ltest', state=lstate0
    end
smcdrv, name=stepper, action='reset'

print, 'At limit ', lstate0

end

