; Procedure to reset STEPPER_1
pro rst1
smcdrv, name='STEPPER_1', action='decel'
smcdrv, name='STEPPER_1', action='reset'
end
