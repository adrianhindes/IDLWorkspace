pro getp12, h1,h2,h3,h4,p31,p42,pcmb,noplot=noplot,np=np,maxang=maxang

s31a=float((h3)/(h1))
s42a=float((h4)/(h2))
s31=total(s31a * abs(h1)) / total(abs(h1))
s42=total(s42a * abs(h2)) / total(abs(h2))

default,np,1000
default,maxang,360*1.05
p1=linspace(0,maxang*!dtor,np)
j1=beselj(p1,1)
j2=beselj(p1,2)
j3=beselj(p1,3)
j4=beselj(p1,4)


r42=j4/j2
r31=j3/j1

idx=where(abs(j2) lt 0.01)
idx2=where(abs(j1) lt 0.01)
idx3w=where(abs(j1) gt 0.01)
idx4w=where(abs(j2) gt 0.01)
r42(idx) = !values.f_nan
r31(idx2) = !values.f_nan


;'i31=value_locate(r31,s31)
;i42=value_locate(r42,s42)
dummy=min(abs(r31(idx3w)-s31),i31)
dummy=min(abs(r42(idx4w)-s42),i42)
i31=idx3w(i31)
i42=idx4w(i42)
p31=p1(i31)
p42=p1(i42)

if total(abs(h1)) gt total(abs(h2)) then begin
    print, 'using fundamental for pcmb',total(abs(h1)),total(abs(h2))
    pcmb=p31
endif else begin
   print,'using second harm for pcmb',total(abs(h1)),total(abs(h2))
    pcmb=p42
endelse
print,'p31=',p31*!radeg,'deg',p31
print,'p42=',p42*!radeg,'deg',p42
print,'pcmb=',pcmb*!radeg,'deg'
if keyword_set(noplot) then return
!p.multi=[0,1,2]
!p.charsize=1
plot,p1*!radeg,r31,xtitle='phi1 (deg)',ytitle='r31',yr=s31+[-1,1];*5
oplot,p1(i31)*[1,1]*!radeg,[-10,10],col=2
oplot,!x.crange,s31*[1,1],col=2
plot,p1*!radeg,r42,xtitle='phi1 (deg)',ytitle='r42',yr=s42+[-1,1]
oplot,p1(i42)*[1,1]*!radeg,[-10,10],col=2
oplot,!x.crange,s42*[1,1],col=2


!p.multi=0 & !p.charsize=0

end
