function cylint, v
a=v(0)
b=v(1)
c=v(2)
restore,'mode number.save'
m=mv
n=nv
restore, 'zone and sample parameter.save'
nmult=samn
znn=zonen
vec=[a/sqrt(a^2+b^2+c^2),b/sqrt(a^2+b^2+c^2),c/sqrt(a^2+b^2+c^2)]
if (abs(vec(1)^2/(vec(0)^2+vec(1)^2))lt (1-0.2^2)) then begin
indi=0.0
intdata={int:0.0, integral:0.0}
endif else begin
center=[0,1.0,0]
;vector=[a/sqrt(a^2+b^2+c^2),b/sqrt(a^2+b^2+c^2),c/sqrt(a^2+b^2+c^2)]
;lefts=max([-abs(0.2/vector(0)),-0.8/vector(1)]);,-abs(10.0/vector(2))])
;rights=min([abs(0.2/vector(0)),-1.2/vector(1)]);,abs(10.0/vector(2))])
lefts = 0.7
rights = 1.4
t=findgen(500*nmult)*(abs(rights-lefts)/(nmult*500.0))+lefts
dt=(vec(0)*t)^2+(vec(1)*t+1.0)^2
index=where(dt le 0.21^2)
t=t(index)
deltat=t(1)-t(0)
x=vec(0)*t
y=vec(1)*t+1.0
z=vec(2)*t

pvector=-[[x/sqrt(x^2+y^2)],[y/sqrt(x^2+y^2)],[0*x]]
rsq=sqrt(x^2+y^2)


intensity=replicate(1.0,n_elements(t)) ; uniform intensity model
dif=0.0

;intensity1=1.0-(x^2+y^2)/0.2^2          ;gaussian intensity distribution
;dif=1-2*rsq/0.2^2                         ;differentition of background intensisy

;gaussian amplitude distribution
;dis=replicate(dcomplex(1.0,0.0),n_elements(rsq))
dis=dcomplex(exp(-(rsq-0.1)^2/0.05^2)*cos(m*atan(y,x)-n/1.0*z+sita),exp(-(rsq-0.1)^2/0.05^2)*sin(m*atan(y,x)-n/1.0*z+sita))
;disp=dcomplex(exp(-(rsq-0.1)^2/0.02^2)*cos(m*atan(y,x)-n/1.0*z),exp(-(rsq-0.1)^2/0.02^2)*sin(m*atan(y,x)-n/1.0*z))

;zonal methods, 0 order spline function equally
;zk=findgen(znn+1)*0.2/znn ;znn zone number
;dr=replicate(0.0,n_elements(rsq))
;restore,'zone number.save'
;ind=where(( rsq ge zk(zn-1.0)) and ( rsq le zk(zn)))
;dr(ind)=1.0


;first order spline funciton ingegration
;rad=findgen(1000)*0.2/999.0
;restore, 'First order spline function with 11 knots.save'
;restore, 'the number of first spline basic function.save'
;dr=interpol(da(*,bn),rad,rsq)

;dis=dcomplex(dr*cos(m*atan(y,x)-n/1.0*z+sita),dr*sin(m*atan(y,x)-n/1.0*z+sita))


;test phase as a function of rdius
;n1=n_elements(dis)
;dis1=make_array(n1,/dcomplex)
;index=where(rsq lt 0.2^2/2.0)
;index1=where(rsq ge 0.2^2/2.0)
;dis1(index)=dis(index)
;dis1(index1)=disp(index1)
;dis=dis1


common ratio,gama
gama=0.0
dif1=-2*(rsq-0.05)/(0.02^2)*dis  ;diffretiation of displacerment

intensity=intensity;+(1-gama)*dif*dis1+gama*real_part(dif1)*intensity ; ;different intensity distribution
intenst=total(intensity)*deltat

;sum=total(intensity*dis*(-reform(pvector(*,0))*vector(0)-reform(pvector(*,1))*vector(1)-reform(pvector(*,2))*vector(2)))*deltat/real_part(intenst)
sum=total(dis);(intensity*dis)*deltat;/real_part(intenst)
;amp=total(abs(intensity*abs(dis)*(-pvector(0)*vector(0)-pvector(1)*vector(1)-pvector(2)*vector(2))))/total(intensity)
;img=total(intensity*imaginary(dis)*(-pvector(0)*vector(0)-pvector(1)*vector(1)-pvector(2)*vector(2)))/total(intensity)
;pha=total(abs(intensity*atan(dis,/phase)/intensity*(-pvector(0)*vector(0)-pvector(1)*vector(1)-pvector(2)*vector(2))))/total(intensity)

intdata={int:double(intenst),integral:dcomplex(sum)}

if finite(sum) eq 0 then stop
endelse
return,intdata
stop
end


    

