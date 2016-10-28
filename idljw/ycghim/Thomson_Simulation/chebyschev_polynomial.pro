
function chebyschev_polynomial, x, a, pder

  nc = n_elements(a)

  pder = chebyshev(x, nc)

  nx = n_elements(x)
  f = fltarr(nx)

  for i=0, nc-1 do $
    f = f + a[i] * pder[*, i]

  return, f

end

