
function bes_beta, density

; Data for density dependent beta = (dI/I)/(dne/ne), i.e. dne/ne = 1/beta * dI/I
; from I.H. Hutchinson, PPCF, 44 (2002), 71-82

  ne_val = 1e19 * [.1, .2, .4, .6, .8, 1., 2., 4., 6., 8., 10., 20., 40., 60., 80., 100.]
  beta_val = [.93, .91, .85, .8, .77, .74, .63, .57, .53, .51, .5, .46, .4, .35, .3, .27]

  beta = interpol(beta_val, alog10(ne_val), alog10(density))

  return, beta

end