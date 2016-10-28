
; $Id: vector_cross_product.pro,v 1.1 2005/12/13 16:14:53 afield Exp $

function vector_cross_product, a, b

  c = fltarr(3)

  c[0] = a[1] * b[2] - a[2] * b[1]
  c[1] = - (a[0] * b[2] - a[2] * b[0])
  c[2] = a[0] * b[1] - a[1] * b[0]

  return, c

end
