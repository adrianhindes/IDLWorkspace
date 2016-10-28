pro crat, p1,rat,od=od,ev=ev,meth=meth
;p1=180.*!dtor

nh=5
if keyword_set(od) then ih=1+findgen(nh)*2
if keyword_set(ev) then ih=findgen(nh)*2
mat=fltarr(nh)
for i=0,nh-1 do mat(i)=beselj(p1,ih(i))
;svdc,transpose(mat),w,u,v
;print,sqrt(total(u)^2 * 1/w^2 ),

e = 1/mat

num=1.d0
for i=0,nh-1 do num=num*abs(e(i))

denom=0.d0
for i=0,nh-1 do begin
    prod=1.d0
    for j=0,nh-1 do begin
        if j eq i then continue
        prod=prod*e(j)^2
    endfor
    denom=denom+prod
endfor

etot=num/sqrt(denom)


rat= 1/max(abs(mat))/ etot

if meth eq 1 then rat=1/max(abs(mat))
if meth eq 2 then rat=etot
end

p1=linspace(45*!dtor,360*!dtor,100)
cr1=fltarr(100)
cr2=fltarr(100)
cr1b=fltarr(100)
cr2b=fltarr(100)
for i=0,99 do begin
    crat,p1(i),dumrat,/od,meth=1
    cr1(i)=dumrat
    crat,p1(i),dumrat,/ev,meth=1
    cr2(i)=dumrat
    crat,p1(i),dumrat,/od,meth=2
    cr1b(i)=dumrat
    crat,p1(i),dumrat,/ev,meth=2
    cr2b(i)=dumrat
endfor
mkfig,'eranal.eps',xsize=12,ysize=10,font_size=7
plot,p1*!radeg, cr1,psym=-4,xtitle='Retardance [deg]',$
  ytitle='Error in stokes parameter / Noise in all harmonics'
oplot,p1*!radeg,cr1b,linesty=1
oplot,p1*!radeg,cr2,col=2,psym=-5
oplot,p1*!radeg,cr2b,linesty=1,col=2
legend,[$
         'Using only strongest harmonic [Sin type]',$
         'Using only strongest harmonic [Cos type]',$
         'Using all harmonics [Sin type]',$
         'Using all harmonics [Cos type]'],$
  linesty=[0,0,1,1],psym=[-4,-4,0,0],col=[1,2,1,2]
endfig,/jp,/gs
end
