function bbo,l

clinbo3, n_e=n_e,n_o=n_o,lambda=l * 1e-6,kappa=kappa,dnedl=dnedl,dnodl=dnodl

;stop
return,n_e-n_o
end


function bbo2, l

;goto,b
no2= 2.7359+0.01878/(l^2 - 0.01822)-0.01354 *l^2
ne2 = 2.3753+0.01224/(l^2-0.01667)-0.01516 *l^2


;abbo
;no2=2.7471+0.01878/(l^2-0.01822)-0.01354*l^2
;ne2=2.3174+0.01224/(l^2-0.01667)-0.01516*l^2




return,-(sqrt(ne2)-sqrt(no2))

end




d1=[$

;C III
;Lambda (nm)            Rel. Int
 [     464.742, 0.555366],$
 [     465.025, 0.333592],$
 [     465.147, 0.111044]]

d1b=[$
 [     464.742, 830],$
 [     465.025, 520],$
 [     465.147, 375]]

;C II
;Lambda (nm)                    Rel. Int
d2=[$
[      513.294, 0.1417],$
      [513.328 ,0.1417],$
      [513.726 ,0.0493],$
      [513.917 ,0.0495],$
      [514.349 ,0.1359],$
      [514.516 ,0.3275],$
      [515.109 ,0.1544]]

;  0.0129353     0.649874     0.337191

d3=[$
[656.1,  0.0129353 ],$
[657.805,0.649874 ],$
[658.288,0.337191] ]


d=d3
l=reform(d(0,*))
a=reform(d(1,*))
nc=n_elements(a)

nl=100
;len=linspace(0,50e-3,nl)
len=replicate(len0*1e-3,nl)
frac=linspace(0,100,nl)
f=complexarr(nl)
f2=complexarr(nl,nc)
atmp=a & atmp(0)=0.
lcwl=total(l*atmp)/total(atmp)

atmp=fltarr(nl,nc)
for i=0,nl-1 do atmp(i,*)=a * [frac(i),1,1]
for i=0,nl-1 do atmp(i,*)=atmp(i,*)/total(atmp(i,*))

for i=0,nc-1 do begin
tmp=len*bbo(l(i)*1e-3)/(l(i)*1e-9)
tmpref=len*bbo(lcwl*1e-3)/(lcwl*1e-9)
f=f+atmp(*,i)*exp(2*!pi*complex(0,1)*(tmp-tmpref))
f2(*,i)=atmp(*,i)*exp(2*!pi*complex(0,1)*(tmp-tmpref))
endfor
plot,frac,abs(f),yr=[0.,1],pos=posarr(1,2,0)

;for i=0,nc-1 do begin
;oplot,frac,float(f2(*,i)),linesty=1,col=i+2
;oplot,frac,imaginary(f2(*,i)),linesty=2,col=i+2
;endfor

;oplot,45*[1,1],!y.crange

plot,frac,atan2(f/f(0)),yr=[-1,1]*0.3,pos=posarr(/next),/noer

;for i=0,nc-1 do begin
;oplot,frac,atan2(f2(*,i)),linesty=1,col=i+2
;endfor

;oplot,45*[1,1],!y.crange


retall
lcor=465.7
acor=.11 / 6. * 0.5

tmp=len*bbo(lcor*1e-3)/(lcor*1e-9)
fcor=acor*exp(2*!pi*complex(0,1)*(tmp-tmpref))

plot,len,abs(f)
oplot,len,abs(f+fcor),linesty=1
plot,len,atan2(f)*!radeg,/noer,col=4
oplot,len,atan2(f+fcor)*!radeg,linesty=1,col=4
a=tmp*10e3/3e8 * 360
b=atan2( (f+fcor)/f )*!radeg
c=atan2( ((f+0*fcor)*exp(2*!pi*complex(0,1)*tmpref*10e3/3e8)+1*fcor)/f )*!radeg
plot,len,a
oplot,len,a+b,col=2;,yr=[-30,30]
oplot,len,c,col=3
end


;len*bbo(lcwl*1e-3)/(lcwl*1e-9)
