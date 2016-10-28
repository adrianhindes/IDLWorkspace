function magpie_coils, I0, I1, scale=scale, ncoils=ncoils

if n_params() ne 2 then stop,'Please supply source and mirror currents in amps'
default, scale, replicate(1.,10)

windings_per_coil = 13.5
a = 0.183
coil_pos = [-0.72, -0.54, -0.36, -0.18, 0., 0.390, 0.443, 0.496, 0.549, 0.602]
current = [I0, I0, I0, I0, I0, I1, I1, I1, I1, I1] * scale
current = current*windings_per_coil

ncoils = n_elements(coil_pos)
coils = replicate({radius:0., current:0., position:0.}, ncoils)
for i=0, ncoils-1 do coils[i] = {radius:a, current:current[i], position:coil_pos[i]}

return, coils

end

