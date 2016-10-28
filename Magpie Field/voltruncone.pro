function volTrunCone, r1, r2, h

vol = (1./3.) * !pi * h * (r1^2 + r2^2 + r1 * r2)

return,vol

end