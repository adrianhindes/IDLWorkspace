;-----------------------------------------------------------------
function thermal_zeta, delay=phi0, temperature=temperature, a=a
;
; calculate fringe visibility due to thermal spread of temperature Ti
; for fixed phase delay phi0
;
if n_elements(phi0) eq 0 then message,'Please supply delay in radians'
if n_elements(temperature) eq 0 then message,'Please supply temperature in eV'
if n_elements(a) eq 0 then message,'Please supply atomic weight'

exponent = -5.32e-10*phi0^2*Temperature/a
return, exp(exponent)
end
