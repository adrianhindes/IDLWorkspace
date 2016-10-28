; Procedure to reset STEPPER_2
pro rst2
smcdrv, name='STEPPER_2', action='decel'
smcdrv, name='STEPPER_2', action='reset'
end
