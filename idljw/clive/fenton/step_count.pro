; Procedure to count the number of steps of a stepper motor between CW
; and CCW switches on the tomographic wheel

pro step_count, stepper, bklash=bklash

default, bklash, 0
speed=450

;Check at one limit (CW or CCW) already

smcdrv, name=stepper, action='LTEST', state=lstate0
if lstate0 eq 'CW' then begin 
    print, 'At CW limit.'
    smult=-1
    lstate_loop=1
    end

if lstate0 eq 'CCW' then begin
    print, 'At CCW limit.'
    smult=1
    lstate_loop=1
    end

if (lstate0 eq 'NL' or lstate0 eq 'CW_CCW') then begin
    print, 'Stepper not at either limit.(or both limits simultaneously)'
    print, 'Please take motor to one limit and restart this program.'
    return
    end

st_count=0.
print, 'Beginning stepping procedure...'
t0_c=systime(0) & t0=systime(1)
print, 'Stepping began at ',t0_c
if bklash eq 1 then begin
    wtime=abs(smult*10)/speed + .1
    print, 'Entering backlash mode...'
    while (lstate_loop ne 0) do begin
        smcdrv, name=stepper, val=smult*10
        st_count=st_count+smult*10
        wait, wtime
;        smcdrv, name=stepper, action='ATEST', state=astate
;        if astate eq 1 then wait, .5
        smcdrv, name=stepper, action='LTEST', state=lstate1
        if lstate1 eq 'NL' then lstate_loop=0
        end
    end

if bklash eq 0 then begin
    print, 'In normal mode ...'
    while (lstate_loop ne 0) do begin
        smcdrv, name=stepper, val=smult
        wait, .1
        st_count=st_count+1
        smcdrv, name=stepper, action='LTEST', state=lstate1
    if lstate0 eq 'CW' and (lstate1 eq 'CCW' or lstate1 eq 'CW_CCW') then lstate_loop=0
    if lstate0 eq 'CCW' and (lstate1 eq 'CW' or lstate1 eq 'CW_CCW') then lstate_loop=0
    end
    end
t1_c=systime(0) & t1=systime(1)
print, 'Stepping ceased at ',t1_c
print, 'Total time ',t1-t0 ,' seconds.'
print, 'Stepper motor took ', st_count, ' steps'

end

