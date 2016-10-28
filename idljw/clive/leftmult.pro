function leftmult,tensmat,regmat
sz1=size(tensmat,/dim) 
sz2=size(regmat,/dim) 
nd2=n_elements(sz1)
n1=sz1(2)
szout=sz1
tensmult=tensmat*0

for i=0,3 do for j=0,3 do for k1=0,n1-1 do $
    tensmult(i,j,k1)=total(regmat(*,i) * tensmat(j,*,k1))

return,tensmult
end
