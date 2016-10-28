function rtangent, p, c,z=z
p0=p(0)
p1=p(1)
l0=c(0)
l1=c(1)
r=(l1*p0 - l0*p1)/sqrt(l0^2 + l1^2)

l=(-(l0*p0) - l1*p1)/(l0^2 + l1^2)
z=p(2) + l * c(2)
;tangent point
return,r
end

