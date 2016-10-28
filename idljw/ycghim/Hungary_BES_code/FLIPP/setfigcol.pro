pro setfigcol
if (!d.name eq 'WIN') then device,decomposed=0
tvlct,r,g,b,/get
r(1:14)=[255,  0,  0,255,155,  0,100,  0,  0,100,100,  0,255,0]
g(1:14)=[  0,255,  0,  0,155,255,  0,100,  0,  0,100,100,255,0]
b(1:14)=[  0,  0,255,255,  0,255,  0,  0,100,100,  0,100,255,0]
n=n_elements(r)
r(n-1)=255
g(n-1)=255
b(n-1)=255
tvlct,r,g,b
end








