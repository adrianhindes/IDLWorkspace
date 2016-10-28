function replarr, a, n
sz=size(a,/dim)
tp=size(a,/type)
szn=[sz,n]
a2=reform(a,product(sz))
b=a2
for i=1,n-1 do b=[b,a2]
bb=reform(b,szn)
return,bb
end

;b=make_array([sz,n],type=tp)
