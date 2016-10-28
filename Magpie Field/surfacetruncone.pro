function surfacetruncone, r1, r2, length


slant = sqrt( (r1 - r2)^2 + length^2 )
area = !pi*(r1+r2)*slant

return, area

end