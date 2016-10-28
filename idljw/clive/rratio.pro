function yof, ra, v
tmp=ra # v
return,tmp(1)
end

function rot, a
return, [[cos(a),sin(a)],[-sin(a),cos(a)]]
end

;a=-14.04*!dtor & s=1. ; 4.8,4.8,.24
a=-18.5*!dtor & s=4./3. ; .63,.63,.31
;a=-18*!dtor
;s=4./3.

ra=rot(a)
p0=yof(ra,[-1,1.*s])
p1=yof(ra,[1,1.*s])
p2=yof(ra,[-1,0])
p3=0

print,p0,p1,p2,p3
print,p0-p1,p1-p2,p2-p3
plot,[p0,p1,p2,p3],psym=-4

end




