
function csq,da
common cb, a,x,wt
common cb2, coherror
if n_elements(coherror) eq 0 then coherror=0.
csq=total( wt^2 * abs(f(a+da,x)-f(a,x)+coherror)^2 )
;stop
return,csq
end


pro calches, ap, xp,hes,scal=scal,wt=wtp
common cb, a,x,wt
a=ap
x=xp
wt=wtp

n=n_elements(a)

mat=dblarr(n,n)

for i=0,n-1 do for j=0,n-1 do begin
vec=dblarr(n)
vec(i)=scal(i)
vec(j)=scal(j)

mat(i,j)=csq(vec); / scal(i)/scal(j) ; /scal(i)/scal(j) is new
endfor
hes=mat
sscal=scal
;sscal=1.+0.*scal
for i=0,n-1 do for j=0,n-1 do begin
    if i eq j then hes(i,j)=2*mat(i,j)/sscal(i)^2 else $
      hes(i,j)=(mat(i,j)-mat(i,i)-mat(j,j))/sscal(i)/sscal(j)
endfor

;print,csq(0.1,0.1)

;stop
;print,csq(0.,0.1)
end
