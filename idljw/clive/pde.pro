nr=101
r=findgen(nr) * 1.d0/(nr-1d0);linspace(0d0,1d0,nr)

r0=0.5
dr=0.1
a=0.5
pert=a*exp(-(r-r0)^2/dr^2)

psi0=-r^2 
psi=psi0

it=0L
istore=0L
maxstore=10000
vstore=fltarr(maxstore)
difstore=fltarr(nr,maxstore)
a:

del=r(1)-r(0)
d2psidr2 = [0,-2*psi(1:nr-2) +psi(0:nr-3) + psi(2:nr-1),0] / del^2
dpsidr = [0,psi(2:nr-1) - psi(0:nr-3),0] / del/2

dpsidt = -dpsidr / r^2 + d2psidr2 / r + pert

dpsidt(0)=0. ; bc at 0
if it eq 0 then vv=del * 2 * 0.995 ; * 0.019899981;vloop=0.

;dpsidt(nr-1) = vloop

if it mod 100 eq 0 then begin
cur=-deriv(r,psi)
jay=deriv(r,cur)*1/r
plot,r,cur,pos=posarr(1,3,0,/quiet),title='curr & pert'+string(it,format='(I0)')
plot,r,pert,col=2,/noer,pos=posarr(/curr,/quiet)
plot,r,jay,col=3,/noer,pos=posarr(/curr,/quiet)
oplot,r,2/r,col=4
plot,r,psi,/noer,pos=posarr(/next,/quiet),title='psi and dpsidt'
oplot,r,psi0,col=3
plot,r,dpsidt,col=2,/noer,pos=posarr(/curr,/quiet)
lv=dpsidt(nr-2)
plot,r,jay-2/r,pos=posarr(/next,/quiet),title='jay diff, loop v='+string(lv,format='(G0)'),/noer
vstore(istore)=lv
difstore(*,istore)=jay-2/r


istore=istore+1
print,max(abs(dpsidt))
endif 
step=0.3d-5/4
;stop
psi=psi+dpsidt*step
;;enforce edge bc
psi(nr-1) = psi(nr-2) - vv;del*2
;stop

it=it+1
goto,a

end
