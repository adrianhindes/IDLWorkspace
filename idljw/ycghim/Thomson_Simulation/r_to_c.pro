
; $Id: r_to_c.pro,v 1.1 2005/12/13 16:14:53 afield Exp $

function r_to_c, pr

  pc = fltarr(3)

  pc[0] = sqrt(pr[0]^2 + pr[1]^2)
  pc[1] = atan(pr[1], pr[0])
  pc[2] = pr[2]

  return, pc

end
