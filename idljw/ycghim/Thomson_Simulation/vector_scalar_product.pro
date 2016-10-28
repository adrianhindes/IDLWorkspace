
; $Id: vector_scalar_product.pro,v 1.1 2005/12/13 16:14:53 afield Exp $

function vector_scalar_product, a, b

  return, total(a * b)

end
