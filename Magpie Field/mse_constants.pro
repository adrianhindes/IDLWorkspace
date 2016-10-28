function mse_constants

c =     { c: 299792458.,$
          e: 1.60217646d-19, $
          me: 9.1093897d-31, $
          re: 2.8179403267d-15, $
          mp: 1.67262158d-27, $
          mu0: 4*!pi*1d-7, $
          h: 6.626068d-34, $
          eps0: 8.854187817d-12, $
          kB: 1.380658d-23, $
          alpha: 0.d,$
          uB: 0.d0, $
          a0: 5.2917721092d-11}

c.alpha = c.e^2 * c.c * c.mu0/(2*c.h)   ; fine structure
c.uB = c.e * c.h / (4d0*!dpi*c.me)      ; Bohr magneton
return, c
          
end