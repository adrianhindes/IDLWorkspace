
; $Id: modulus_vector.pro,v 1.1 2005/12/13 16:14:52 afield Exp $

function modulus_vector, a

  ma = sqrt(total(a^2))

  return, ma

end
