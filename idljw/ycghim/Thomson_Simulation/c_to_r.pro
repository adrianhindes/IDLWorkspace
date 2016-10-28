
; $Id: c_to_r.pro,v 1.1 2005/12/13 16:14:52 afield Exp $

function c_to_r, pc

  pr = fltarr(3)

  if pc[1] le !PI then $
    phi = pc[1] $
  else $
    phi = 2 * !PI - pc[1]

  pr[0] = pc[0] * cos(phi)
  pr[1] = pc[0] * sin(phi)
  pr[2] = pc[2]

  return, pr

end
