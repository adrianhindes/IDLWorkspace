restore,file='~/geom.sav'
;save,cfront,cmiddle,rhoi,file='~/geom.sav'
;cfront(0:5)=cfront(6)
cmiddlep=deriv(rhoi,cmiddle)
cmiddlep(0)=cmiddlep(1)

a=max(rhoi)
r=rhoi
r0=0.2*a
dr=0.1*a
amp=0.
pert=amp*0.1/dr*exp(-2*(r-r0)^2/dr^2)

psi0=psiav;0*(-r^2)
psi=psi0

nr=n_elements(rhoi)

it=0L
istore=0L
maxstore=100000
vstore=fltarr(maxstore)
vstore2=fltarr(nr,maxstore)
curstore=vstore2
difstore=fltarr(nr,maxstore)
a:


del=rhoi(1)-rhoi(0)
d2psidr2 = [0,-2*psi(1:nr-2) +psi(0:nr-3) + psi(2:nr-1),0] / del^2
dpsidr = [0,psi(2:nr-1) - psi(0:nr-3),0] / del/2

;jay=-(dpsidr / r + d2psidr2)
;dpsidt = -jay  + pert
dpsidt0 = cfront * (cmiddlep * dpsidr + cmiddle * d2psidr2) 
dpsidt = dpsidt0 + pert
jay = rhoi/c3i/vprimei * deriv(rhoi,c2i * dpsidr)

if it eq 0 then jay0=jay


;dpsidt(0)=0. ; bc at 0

if it eq 0 then vv=-(psi(nr-1)-psi(nr-2)) 

;del * 2 * 0.995 ; * 0.019899981;vloop=0.

;dpsidt(nr-1) = vloop


step=0.3d-5/4*3;10e-6

if it mod 100 eq 0 then begin
cur=-deriv(r,psi) * r
;jay=deriv(r,cur)*1/r
plot,r,cur,pos=posarr(1,3,0,/quiet),title='curr & pert'+string(it,it*step,format='(I0,",",G0)')
plot,r,pert,col=2,/noer,pos=posarr(/curr,/quiet)
plot,r,jay,col=3,/noer,pos=posarr(/curr,/quiet)
;oplot,r,2/r,col=4
plot,r,psi,/noer,pos=posarr(/next,/quiet),title='psi and dpsidt'
oplot,r,psi0,col=3
plot,r,dpsidt,col=2,/noer,pos=posarr(/curr,/quiet)
lv=-dpsidt(nr-2)
plot,r,jay,pos=posarr(/next,/quiet),title='jay diff, loop v='+string(lv,format='(G0)'),/noer
vstore(istore)=lv
vstore2(*,istore)=-dpsidt
difstore(*,istore)=jay-2/r*0
curstore(*,istore)=cur

istore=istore+1
print,max(abs(dpsidt))

;if it mod 100000 eq 0 and it gt 0 then stop
endif 
;stop
psi=psi+dpsidt*step
;;enforce edge bc
psi(nr-1) = psi(nr-2) - vv;del*2
;enforce core bc
psi(0)=psi(1)

;stop

it=it+1
goto,a

end
