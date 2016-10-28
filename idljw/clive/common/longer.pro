function longer, p1,p2,fac
vec=p2-p1
dst=vabs(vec)
vec=vec/dst

p3 = p1 + vec * dst*fac
return,p3
end
