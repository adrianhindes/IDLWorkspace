pro distort,px1,py1,view,sz,del
px = px1;>0<sz(0)
py=py1;>0<sz(1)
cx=view.distcx * sz(0)
cy=view.distcy * sz(1)
dx=px-cx
dy=py-cy
r2=(dx^2+dy^2)
dist=view.dist * ((del(0)/ view.flen)^2) ; convert from (1/rad^2) to 1/pix^2; note new put dist sqrt
pxo = px + dx * r2 * dist
pyo = py + dy * r2 * dist

px1=pxo
py1=pyo

end

