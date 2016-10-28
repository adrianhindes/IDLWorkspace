function rightmult,tensmat,vec
sz1=size(tensmat,/dim) 
sz2=size(vec,/dim) 
n1=sz1(2)
szout=sz1
tensmult=complexarr([4,sz1(2)])

for i=0,3 do for k1=0,n1-1 do $
    tensmult(i,k1)=total(tensmat(i,*,k1) * vec)
return,tensmult
end

