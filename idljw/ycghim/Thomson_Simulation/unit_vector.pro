
; $Id: unit_vector.pro,v 1.1 2005/12/13 16:14:53 afield Exp $

function unit_vector, v
  u = v / sqrt(total(v^2))
  return, u
end
