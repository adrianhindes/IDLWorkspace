@filt_common
nl=101
lam=linspace(520,540,nl)

scalld,la,fa,l0=529.48,fwhm=2.85,opt='a3';10pc=4.21,1pc=6.31nm
nen=1000
en=linspace(0,530./530.,nen)
ft=complexarr(nen)
for i=0,nen-1 do ft(i)=total(fa * exp(2*!pi*complex(0,1)*en(i)*la))
plot,en,abs(ft)

stop


; gencarriers2,th=[0,0],sh='cxrstest4y',mat=a2,dmat=da2,kx=kx,ky=ky,kz=kz,vth=

; tkz=kzlist,nkz=nkz,dkx=dkx,dky=dky,quiet=quiet,p=p,str=str,noload=noload,toutlist=toutlist,vth=thv,indexlist=indexlist,vkzv=kzv,lam=lam,frac=frac,fudgethick=fudgethick,useindex=useindex,slist=slist,stat=stat,nstates=nstates,kappa=kappa


; filtstr={nref:2.05,cwl:529.48}
; thetatilt=0*!dtor
; nlam=n_elements(lam)
; f2=fltarr(nlam,nxim,nyim)
; tshiftarr=fltarr(nxim,nyim)
; dshift2=tshiftarr



; nwav=opd(1e-6,0.,par=par3,delta=!pi/4)/2/!pi
; eikonal = exp(complex(0,1)*2*!pi*nwav)
; spvrw=complexarr(nxim,nyim,4)
; for i=0,nxim-1 do for j=0,nyim-1 do begin
;     thetax = detx(i)/55e-3 - thetatilt
;     thetay = dety(j)/55e-3 
;     thetao=sqrt(thetax^2+thetay^2)
;     dlol=1-sqrt(filtstr.nref^2-sin(thetao)^2)/filtstr.nref
;     tshifted=filtstr.cwl*dlol ;lam0c=lam0*(1-dlol)
;     tshiftarr(i,j)=tshifted
;     f2(*,i,j)=interpolo(fa,la,lam+tshifted)  

;     for k=0,3 do for h=0,2 do begin
;         exp=1.
;         if h eq 0 then premu=1.
;         if h eq 0 then denom=1 else denom=mom(i,j,0,k)
;         if h eq 1 then premu=lam
;         if h eq 2 then premu=(lam-mom(i,j,1,k))^2
;         if h eq 2 then exp=0.5
;         mom(i,j,h,k)=( total(spvr(i,j,*,k)*f2(*,i,j) * premu) / denom )^exp
; ;        mom(i,j,h,k)=( total(spvr(i,j,*,k) * premu) / denom )^exp

;     endfor

;     for k=0,3 do begin
;         spvrw(i,j,k) = total(spvr(i,j,*,k)*f2(*,i,j)*eikonal)
;     endfor

; endfor

; c1=complex(float(spvrw(*,*,1)) - imaginary(spvrw(*,*,2)) , $
;            -float(spvrw(*,*,2)) - imaginary(spvrw(*,*,1)) )

; c2=complex(-float(spvrw(*,*,1)) - imaginary(spvrw(*,*,2)) , $
;            -float(spvrw(*,*,2)) + imaginary(spvrw(*,*,1)) )

; p1=atan2(c1)
; p2=atan2(c2)

; jumpimg,p1
; jumpimg,p2

; psi=(p1-p2)/4

; ;top=imaginary(spvrw(*,*,2))
; ;bottom=float(spvrw(*,*,1))
; ;p1=atan(-top,bottom)
; ;p2=atan(-top,-bottom)
; ;imgplot,topl,lam,indgen(50),pos=posarr(3,1,0)
; ;imgplot,f2,lam,indgen(50),pos=posarr(/next),/noer
; ;imgplot,topl*f2,lam,indgen(50),pos=posarr(/next),/noer



; ;for i=0,nxim-1 do begin



end
