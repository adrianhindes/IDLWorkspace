pro getchisq, matr, tmatr,acoeff, rcoeff, chisq, pder
rpj = tmatr # acoeff
rpjdel=rpj - rcoeff
chisq = total( (rpjdel)^2 )
n=n_elements(matr(*,0))
pder=fltarr(n)
for i=0,n-1 do begin
    pder(i) = total(2*rpjdel*matr(i,*))
endfor
end
