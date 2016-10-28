fn='~/idl/clive/nleonw/tang_port/objhidden_mirr_5.sav'
restore,fn,/verb


fn='~/idl/clive/nleonw/tang_port/irset3.sav'
 restore,fn,/verb


str.rad=1.7
str.tor+=1.5
str.hei-=0.03


cosa=cos(str.tor*!dtor)
sina=sin(str.tor*!dtor)

vec=[cosa,sina,0]
rmat=[ [cosa,sina,0],$
       [-sina,cosa,0],$
       [0,0,1]]




p1=lns(*,0,0)
p2=lns(*,0,1)
p3=lns(*,0,3)

pn=lns(*,0,2)

;pc=p1;(p1+p2)/2.
pc=(p1+pn)/2
vec1=p2-p1
vec2=p3-p1

kay=crossp(vec1,vec2) & kay/=norm(kay)
kay=-kay
print,kay

plot,lns(0,*,*),lns(1,*,*),/iso,xr=[-2000,2000],yr=[-2000,2000]

plots,pc(0),pc(1),psym=4

oplot,[0,kay(0)]*300+pc(0),[0,kay(1)*300]+pc(1),linesty=2
kay2=rmat ## kay

lns2=lns
for i=0,1 do for j=0,3 do begin
   tmp=reform(lns(*,i,j))
   tmp2=rmat ## tmp
   lns2(*,i,j)=tmp2

;   stop
endfor
pc2=rmat ## pc
oplot,lns2(0,*,*),lns2(1,*,*),col=2
plots,pc2(0),pc2(1),psym=4,col=2

oplot,[0,kay2(0)]*300+pc2(0),[0,kay2(1)*300]+pc2(1),linesty=2,col=2


oplot,str.rad*1000*[1,1],[-37,37],col=2

theta=atan(kay2(1),kay2(0))*!radeg & print,theta
phi=atan(kay2(2),sqrt(kay2(0)^2+kay2(1)^2))*!radeg & print,phi
end
