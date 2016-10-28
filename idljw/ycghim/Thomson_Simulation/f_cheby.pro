
pro f_cheby, x, a, f, pder

  nc = n_elements(a)

  pder = chebyshev(x, nc)

  nx = n_elements(x)
  f = fltarr(nx)

  for i=0, nc-1 do $
    f = f + a[i] * pder[*, i]

  return

end

