
function frho, rho, m, n, rhos, ws, cs, wi, rhoi, ntm

; Basis funciton
  fbasis = (1. - rho^m)^n

; tanh function
  ftanh = (tanh((rhos - rho) / ws) + 1) / 2

; Step function to simulate barrier
  fstep = ftanh * (1 - cs) + cs

; Profile with barrier
  fs = fstep * fbasis

; Profile flattening due to island

  if ntm then begin

    outside = where(rho ge rhoi+wi/2)
    inside = where(rho lt rhoi-wi/2)
    island = where(rho ge rhoi-wi/2 and rho lt rhoi+wi/2, count)

    if count gt 0 then begin
      fs[inside] = fs[inside] - max(fs[island]) + max (fs[outside])
      fs[island] = max(fs[outside])
    endif

  endif

  return, fs

end


