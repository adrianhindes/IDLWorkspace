
function chebyshev, x, nc

  nx = n_elements(x)
  xmin = min(x)
  xmax = max(x)
  xn = 2 * (x - xmin) / (xmax - xmin) - 1

  f = fltarr(nx, nc)

  f[*, 0] = 1.0
  f[*, 1] = xn

  for i=2, nc-1 do $
    f[*, i] = 2*xn*f[*, i-1] - f[*, i-2]

  return, f

end

