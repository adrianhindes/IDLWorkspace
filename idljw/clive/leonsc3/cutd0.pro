function cutd0, ip,ix,iy
sz=size(ip,/dim)
o=uintarr(sz(0)/2,sz(1)/2)
for i=0,sz(0)/2-1 do for j=0,sz(1)/2-1 do o(i,j)=ip(2*i+ix,2*j+iy)
return,o
end
