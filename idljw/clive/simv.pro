function bbo, l

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
d=d1
l=reform(d(0,*))
a=reform(d(1,*))
nc=n_elements(a)

nl=100
len=linspace(0,15e-3,nl)
f=complexarr(nl)
f2=complexarr(nl,nc)
lcwl=total(l*a)/total(a)
for i=0,nc-1 do begin
tmp=len*bbo(l(i)*1e-3)/(l(i)*1e-9)
tmpref=len*bbo(lcwl*1e-3)/(lcwl*1e-9)
f=f+a(i)*exp(2*!pi*complex(0,1)*(tmp-tmpref))
f2(*,i)=a(i)*exp(2*!pi*complex(0,1)*(tmp-tmpref))
endfor
plot,len/1e-3,abs(f),yr=[-1,1]
for i=0,nc-1 do begin
oplot,len/1e-3,float(f2(*,i)),linesty=1,col=i+2
oplot,len/1e-3,imaginary(f2(*,i)),linesty=2,col=i+2
endfor
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
