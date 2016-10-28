pro ctfix
;tek_color
tvlct,va,vb,vc,/get
v2a=va
v2b=vb
v2c=vc
v2a[0]=va[1]
v2a[1]=va[0]
v2b[0]=vb[1]
v2b[1]=vb[0]
v2c[0]=vc[1]
v2c[1]=vc[0]
tvlct,v2a,v2b,v2c
end
