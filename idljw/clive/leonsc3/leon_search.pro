function mypowellfunc, x1
common cbmypowell1, pmask,imask,func,pfull
;x=x1(imask)
x=pfull
x(imask)=x1
r=call_function(func,x)
return,r
end


pro mypowell, P1, Xi1, Ftol, Fmin, Func1, DOUBLE=double , ITER=iter , ITMAX=itmax,pmask=pmask1
;xi1 is 1d array of scale for each dim
common cbmypowell1, pmask,imask,func,pfull
pfull=p1
pmask=pmask1
imask=where(pmask)
func=Func1

P=P1(imask)
Xi=diag_matrix(Xi1(imask))

powell, P, Xi, Ftol, Fmin, 'mypowellfunc', DOUBLE=double , ITER=iter , ITMAX=itmax
p1(imask)=P

end



function srchfunc,p


view={flen:p(0),$
      rad:p(1),$
      tor:p(2),$
      hei:p(3),$
      yaw:p(4),$
      pit:p(5),$
      rol:p(6),$
      dist:p(7),$
      distcx:p(8),$
      distcy:p(9)}

common cbsrch,smask,swt,nmask
common cbleon, sim,sobj;img,imset
common cbleon3, spts

ln=sobj.lns(*,*,spts.ifnd2(smask))
transc, ln,view
ix=indgen(nmask)

common cbbtan, dotan

if dotan eq 0 then begin
    px1=(reform(ln(0,*,*))*view.flen/sim.del(0)+ sim.sz(0)*view.distcx ) 
    py1=(reform(ln(1,*,*))*view.flen/sim.del(1) + sim.sz(1)*view.distcy) 
endif

if dotan eq 1 then begin
         thxc=0;(view.distcx-0.5)*sim.dim(0)/view.flen
         thyc=0;(view.distcy-0.5)*sim.dim(1)/view.flen
         px1=(tan(reform(ln(0,*,*))-thxc)+tan(thxc))*view.flen/sim.del(0)+ sim.sz(0)*view.distcx
         py1=(tan(reform(ln(1,*,*))-thyc)+tan(thyc))*view.flen/sim.del(1) + sim.sz(1)*view.distcy
     
;    px1=tan(reform(ln(0,*,*)))*view.flen/sim.del(0)+ sim.sz(0)/2
;    py1=tan(reform(ln(1,*,*)))*view.flen/sim.del(1) + sim.sz(1)/2
    print,'dotan=1'
endif


distort,px1,py1,view,sim.sz,sim.del

px=fltarr(nmask)
py=px
for i=0,nmask-1 do px(i)=px1(spts.ifnd1(smask(i)),i)
for i=0,nmask-1 do py(i)=py1(spts.ifnd1(smask(i)),i)
px=px/ sim.sz(0) 
py=py/ sim.sz(1)

dx=px - spts.xim(smask)
dy=py - spts.yim(smask)

csq1=dx^2+dy^2
csq2=swt * csq1
csq=total(csq2)

;print,dx,dy,csq
;help,/str,view
;stop
return,csq
end




      
pro leon_search, view

common cbsrch,smask,swt,nmask
common cbleon3, spts

idx=where(view.smask le spts.npts-1)
smask=view.smask(idx)
nmask=n_elements(smask)
;;;
if n_elements(view.swt) lt nmask then message,'not enough weight points'
swt=view.swt(0:nmask-1)

print,'smask=',smask
pmask=view.pmask
print,'pmask',pmask

par=[view.flen,view.rad,view.tor,view.hei,view.yaw,view.pit,view.rol,view.dist,view.distcx,view.distcy]

scal=[1.,0.1,1.,0.01,1.,1.,1., 1e-6,.01,.01]
print,'initial par=',par
c0=srchfunc(par)
mypowell,par,scal,1e-8,fmin,'srchfunc',iter=iter,pmask=pmask
c1=srchfunc(par)
print,'iter=',iter
print,'final par=',par
print,'c0,c1=',c0,c1
print,'fmin=',fmin
print,'______________'
if c1 gt c0 then return
view.flen=par(0)
view.rad=par(1)
view.tor=par(2)
view.hei=par(3)
view.yaw=par(4)
view.pit=par(5)
view.rol=par(6)
view.dist=par(7)
view.distcx=par(8)
view.distcy=par(9)

end
