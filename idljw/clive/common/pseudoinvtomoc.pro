
function pseudoinvtomoc, mat,w=w,u=u,v=v

;mat=u * w * v^transposeconj
la_svd, (mat), w,u, v,double=double
nw = n_elements(w)
w1mat = complexarr(nw,nw)
for i=0,nw-1 do w1mat(i,i)=w(i)

mr=	v ## w1mat ## conj(transpose(u))


return, mr

end
