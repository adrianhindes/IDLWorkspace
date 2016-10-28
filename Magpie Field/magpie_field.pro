function Magpie_field, I0, I1, r=r, z=z, scale=scale

forward_function magpie_coil_field

if n_elements(z) eq 0 then z=range(-0.8,0.7,.001) 
if n_elements(r) eq 0 then r=range(.001,.15,.001)

nz = n_elements(z)
nr = n_elements(r)

zz = z # replicate(1., nr)
rr = replicate(1., nz) # r

default, I0, 50.      ; source
default, I1, 500.     ; mirror

coils = magpie_coils( I0, I1, scale=scale, ncoils=ncoils )

Br = fltarr(nz,nr) & Bz = Br & Bz0 = fltarr(nz)

for k = 0, ncoils-1 do begin &$
  field = magpie_coil_field( rr, zz, coils[k] ) &$
  Br = Br + field.Br &$
  Bz = Bz + field.Bz &$
  Bz0 = Bz0 + field.Bz0 &$
  endfor
return, {Br: Br, Bz: Bz, Bz0: Bz0, rr:rr, zz:zz}
end


