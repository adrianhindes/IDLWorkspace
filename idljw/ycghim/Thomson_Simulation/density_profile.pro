
function density_profile, dspsi, r, rmin, rmax, ne0, ntm, etb

  nr = n_elements(r)

; Density profile function parameters
  m = 4       ; Profile exponent #1
  n = .5        ; Profile exponent #2

; Local steepening due to ETB
  rhos = .85  ; Barrier location (r/a)
  ws = .02  ; Barrier width (r/a)
  if etb eq 0 then $
    cs = 1. $
  else $
    cs = 0.     ; Fraction outside barrier

; Local flattening due to island
  wi = .1     ; Islannd width (r/a)
  rhoi = .6     ; Island location (r/a)

; Density profile in major radius
  nel = ne0 * frm(dspsi, r, rmin, rmax, m, n, rhos, ws, cs, wi, rhoi, ntm)

; Inverse scale length of density profile
  ilne = abs(deriv(r, nel) / nel)

; Density profile structure
  dsne = {nr:nr, r:r, m:m, n:n, rhos:rhos, ws:ws, cs:cs, ne0:ne0, nel:nel, $
               ilne:ilne, wi:wi, rhoi:rhoi, ntm:ntm}

  return, dsne

end


