
; $Id: draw_circle.pro,v 1.1 2005/12/13 16:14:52 afield Exp $

pro draw_circle, x0, y0, r, _extra=extra

  npts = 100
  theta = 2 * !PI * findgen(npts) / (npts-1)

  x = r * cos(theta) + x0
  y = r * sin(theta) + y0

  for i=1, npts-1 do $
    plots, [x[i], x[i-1]], [y[i], y[i-1]], _extra=extra
  
end
