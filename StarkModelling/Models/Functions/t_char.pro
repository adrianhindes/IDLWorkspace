function T_char, phi

;generate characteristic temperature for a given phase delay

a = !const.mp ;mass of hydrogen atom
Tc = double(((2.*a*(!const.c)^2.)/((!const.k)*phi^2.))/11604)

return,Tc

end