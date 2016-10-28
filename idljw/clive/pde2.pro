;goto,af
nr=101
r=0.5*findgen(nr) * 1.d0/(nr-1d0);linspace(0d0,1d0,nr)

r0=0.1
dr=0.03
a=0;-0.3
pert=a*0.1/dr*exp(-(r-r0)^2/dr^2)

;dtpert=1*0.1/dr*exp(-(r-r0)^2/dr^2)
;tpert=total(dtpert,/cum)
tpert=exp(-r^2 / 0.2^2) + 2.
eta=1/tpert^1.5
;plot,eta
etaprof=eta/max(eta)
;etaprof(*)=1.
;stop
psi0=1*r^2/4; - r^3/9.;1*(-r^2)
psi=psi0

it=0L
istore=0L
maxstore=100000
vstore=fltarr(maxstore)
vstore2=fltarr(nr,maxstore)
curstore=vstore2
difstore=fltarr(nr,maxstore)
psistore=difstore
a:


if it lt 10000L then begin
   pert=r*0
   etaprof=r*0+1.
endif else begin
   pert=a*0.1/dr*exp(-(r-r0)^2/dr^2)
   etaprof=eta/max(eta);*0.9
endelse

del=r(1)-r(0)
d2psidr2 = [0,-2*psi(1:nr-2) +psi(0:nr-3) + psi(2:nr-1),0] / del^2
dpsidr = [0,psi(2:nr-1) - psi(0:nr-3),0] / del/2

jay=-(dpsidr / r + d2psidr2)
dpsidt = -etaprof* (jay  + pert)

dpsidt(0)=dpsidt(1);0. ; bc at 0
if it eq 0 then vv=-(psi(nr-1)-psi(nr-2)) 

;del * 2 * 0.995 ; * 0.019899981;vloop=0.

;dpsidt(nr-1) = vloop

if it mod 100 eq 0 then begin
cur=-deriv(r,psi) * r
;jay=deriv(r,cur)*1/r
plot,r,cur,pos=posarr(1,3,0,/quiet),title='curr & pert'+string(it,format='(I0)')
plot,r,pert,col=2,/noer,pos=posarr(/curr,/quiet)
plot,r,jay,col=3,/noer,pos=posarr(/curr,/quiet)
;oplot,r,2/r,col=4
plot,r,psi,/noer,pos=posarr(/next,/quiet),title='psi and dpsidt'
oplot,r,psi0,col=3
plot,r,dpsidt,col=2,/noer,pos=posarr(/curr,/quiet)
lv=-dpsidt(nr-2)
plot,r,jay-2/r*0,pos=posarr(/next,/quiet),title='jay diff, loop v='+string(lv,format='(G0)'),/noer
vstore(istore)=lv
vstore2(*,istore)=-dpsidt
difstore(*,istore)=jay-2/r*0
curstore(*,istore)=cur
psistore(*,istore)=psi


istore=istore+1
print,max(abs(dpsidt))
;if it mod 100000 eq 0 and it gt 0 then stop
endif 
step=0.3d-5/4
;stop
psi=psi+dpsidt*step

;;enforce edge bc
psi(nr-1) = psi(nr-2) - vv;del*2


it=it+1
;stop
;if it ge 10000L then goto,af
if it ge 100000L then goto,af

goto,a
af:
;mkfig,'~/profs.eps',xsize=9,ysize=8,font_size=9
!p.thick=3
plot,r,pert,ysty=4,xsty=8
oplot,r,etaprof,col=4
oplot,r,etaprof*0+1,col=4,linesty=3
endfig,/gs,/jp
;stop

setaovermu0=0.0078777672
mkfig,'~/simul.eps',xsize=25,ysize=9,font_size=11

t=findgen(istore)*step/setaovermu0
imgplot,-transpose(difstore(*,0:istore-1)),t,r,ytitle='minor radius (m)',xtitle='time (s)',title='difference in perturbed current density',/cb,yr=[0.02,0.5],offx=1,xsty=1,$
pos=posarr(2,1,0,cnx=0.1,cny=0.1)
imgplot,-transpose(vstore2(*,0:istore-1)),t,r,ytitle='minor radius (m)',xtitle='time (s)',title='loop voltage or flux time derivative',/cb,yr=[0.02,0.5],offx=1,xsty=1,pos=posarr(/next),/noer;,zr=[-10,10]
endfig,/gs,/jp


end
