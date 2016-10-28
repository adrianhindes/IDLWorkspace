function modb, x,y
z = x mod y
ix=where(z lt 0)
if ix(0) ne -1 then z(ix)=z(ix)+y
return,z
end
