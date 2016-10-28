
function temperature_profile, dspsi, r, rmin, rmax, ws, ntm, itb, te0

  nr = n_elements(r)

; Temperature profile function parameters
  m = 2         ; Profile exponent #1
  n = 1          ; Profile exponent #2

; Local steepening due to ITB
  rhos = .6    ; Normalised radius (r/a) of barrier
;  ws = .02    ; Width of barrier (r/a)
  if itb eq 0 then $
    cs = 1.0 $
  else $
    cs = .3       ; Fraction outside barrier

; Local flattening due to NTM
  wi = .1       ; Island width (r/a)
  rhoi = .6     ; Island location (r/a)

; Temperature profile in major radius
  te = te0 * frm(dspsi, r, rmin, rmax, m, n, rhos, ws, cs, wi, rhoi, ntm)

; Inverse scale length of temperature profile
  ilte = abs(deriv(r, te) / te)

; Temperature profile structure
  dste = {nr:nr, r:r, m:m, n:n, rhos:rhos, ws:ws, cs:cs, te0:te0, te:te, ilte:ilte, $
              wi:wi, rhoi:rhoi, ntm:ntm}

  return, dste

end


