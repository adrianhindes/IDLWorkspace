@calccurr

nt=40
tarr=findgen(nt) * 50e-3 + 2.0
nt=2 & tarr=[3.45,3.7]
;nt=2 & tarr=[5.135,5.345];-30e-3
;nt=2 & tarr=[4.565, 4.745];-30e-3
;sh=11433
sh=11003
dirmod=''
dirbase='/home/cam112/ikstarcp/my2'
dir=dirbase+'/EXP'+string(sh,format='(I6.6)')+'_k'+dirmod

;goto,af

rax=fltarr(nt)
cur=fltarr(nt,101)
jay=cur
dcur=cur
for i=0,nt-1 do begin
   tw=tarr(i)
   twr=((round(tw*1000/5)*5)) / 1000.
print,'tround=',twr
   fspec=string(sh,twr*1000,format='(I6.6,".",I6.6)')
   gfile=dir+'/g'+fspec
   g=readg(gfile)

   rax(i)=g.rmaxis

   cur(i,*)=calccurr(g,jay=d1,dcur=d2) ;,rho=rho) & ii=ii/max(ii) * (-g.cpasma)
   jay(i,*)=d1
   dcur(i,*)=d2

endfor
af:
ec=cgetdata('\EC1_RFFWD1',sh=sh,db='kstar')
plot,ec.t,ec.v,xr=minmax(tarr),xsty=1,pos=posarr(1,3,0)
plot,tarr,rax,pos=posarr(/next),/noer,/yno
plotm,tarr,jay(*,0:50),pos=posarr(/next),/noer

plotm,transpose(cur)

;; psi=(g.psirz-g.ssimag)/(g.ssibry-g.ssimag) ;& psi=sqrt(psi)
;; ;contour,psi,g.r,g.z,lev=[.01,.1,.2,.4,.7,1]
;; iz0=value_locate(g.z,0)
;; plot,g.r,psi(*,iz0),xr=[1.3,2.4],xsty=1

;; g2=readg('/home/cam112/ikstarcp/my2/EXP011003_k/g011003.003700')
;; psi2=(g2.psirz-g2.ssimag)/(g2.ssibry-g2.ssimag); & psi2=sqrt(psi2)
;; ;contour,psi,g.r,g.z,lev=[.01,.1,.2,.4,.7,1],/overplot,c_col=[2,2,2,2]
;; oplot,g2.r,psi2(*,iz0),col=2

;; plot,g.r,psi2(*,iz0)-psi(*,iz0)

;; r2=g.r # replicate(1,n_elements(g.z)) * 1 ; cm to m
;; z2=replicate(1,n_elements(g.r)) # g.z * 1 ; cm to m

;; npsi=n_elements(g.pprime)
;; pprime2 = interpol(g.pprime,findgen(npsi)/npsi,psi)
;; ffprime2 = interpol(g.ffprim,findgen(npsi)/npsi,psi)
;; idx=where(psi gt 1)


;; pprime2(idx)=!values.f_nan
;; ffprime2(idx)=!values.f_nan
;; j1 =- r2 * pprime2
;; j2 = -ffprime2 / r2 / (4*!pi*1e-7)
;; j=j1+j2
;; plot,g.r,j1(*,iz0),yr=[0,5e6]
;; oplot,g.r,j2(*,iz0),col=2
;; oplot,g.r,j(*,iz0),col=3

;; pprime22 = interpol(g2.pprime,findgen(npsi)/npsi,psi2)
;; ffprime22 = interpol(g2.ffprim,findgen(npsi)/npsi,psi2)
;; idx=where(psi2 gt 1)
;; pprime22(idx)=!values.f_nan
;; ffprime22(idx)=!values.f_nan
;; j1_2 =- r2 * pprime22
;; j2_2 = -ffprime22 / r2 / (4*!pi*1e-7)
;; j_2=j1_2+j2_2
;; oplot,g.r,j1_2(*,iz0),linesty=2
;; oplot,g.r,j2_2(*,iz0),col=2,linesty=2
;; oplot,g.r,j_2(*,iz0),col=3,linesty=2

;; calculate_bfield,bp,br,bt,bz,g

;; calculate_bfield,bp2,br2,bt2,bz2,g2

;; ;plot,-g.r*100,bz2(*,iz0)-bz(*,iz0),xr=[-220,-165],xsty=1
;; ;oplot,!x.crange,[0,0]
;; ;oplot,-g.r,bz2(*,iz0),col=2
;; stop
;; ii=calccurr(g,rho=rho) & ii=ii/max(ii) * (-g.cpasma)
;; plot,ii
;; ii2=calccurr(g2,rho=rho2) &ii2=ii2/max(ii2) * (-g2.cpasma)
;; ii2i=interpol(ii2,rho2,rho)

;; oplot,ii2,linesty=2
;; ;stop
;; plot,ii2i-ii
;; ;plot,g.pres
;; ;oplot,g2.pres,col=2

;; end
end
