
function fit_cheby, x, y, dy, nc

  ok = where(y gt 0.)

  xok = x[ok]
  yok = y[ok]
  dyok = dy[ok]

  ymax = max(yok, /nan)
  a = fltarr(nc)
  a[0] = ymax/2
  a[1] = 0.
  a[2] = -ymax/2
  a[3:nc-1] = 0.

  amask = intarr(nc)
  amask[*] = 1

  yfit = lmbevfit(xok, yok, dyok, a, sigma=sigma, chisq=chisq, iter=iter, $
                      function_name = 'f_cheby', tol=1e-3, itmax=100, amask=amask)

  ds = {nc:nc, x:x, y:y, dy:dy, a:a, xfit:xok, yfit:yfit}

  return, ds

end


