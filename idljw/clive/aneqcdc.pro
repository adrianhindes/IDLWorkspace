@calccurr
g=readg('/home/cam112/ikstarcp/my2/EXP011003_k/g011003.003450')
g2=readg('/home/cam112/ikstarcp/my2/EXP011003_k/g011003.003700')

;g=readg('/home/cam112/ikstarcp/my2/EXP011433_k/g011433.004565')
;g2=readg('/home/cam112/ikstarcp/my2/EXP011433_k/g011433.004745')

psi=(g.psirz-g.ssimag)/(g.ssibry-g.ssimag) ;& psi=sqrt(psi)
;contour,psi,g.r,g.z,lev=[.01,.1,.2,.4,.7,1]
iz0=value_locate(g.z,0)
plot,g.r,psi(*,iz0),xr=[1.3,2.4],xsty=1


psi2=(g2.psirz-g2.ssimag)/(g2.ssibry-g2.ssimag); & psi2=sqrt(psi2)
;contour,psi,g.r,g.z,lev=[.01,.1,.2,.4,.7,1],/overplot,c_col=[2,2,2,2]
oplot,g2.r,psi2(*,iz0),col=2

plot,g.r,psi2(*,iz0)-psi(*,iz0)

r2=g.r # replicate(1,n_elements(g.z)) * 1 ; cm to m
z2=replicate(1,n_elements(g.r)) # g.z * 1 ; cm to m

npsi=n_elements(g.pprime)
pprime2 = interpol(g.pprime,findgen(npsi)/npsi,psi)
ffprime2 = interpol(g.ffprim,findgen(npsi)/npsi,psi)
idx=where(psi gt 1)


pprime2(idx)=!values.f_nan
ffprime2(idx)=!values.f_nan
j1 =- r2 * pprime2
j2 = -ffprime2 / r2 / (4*!pi*1e-7)
j=j1+j2

pprime22 = interpol(g2.pprime,findgen(npsi)/npsi,psi2)
ffprime22 = interpol(g2.ffprim,findgen(npsi)/npsi,psi2)
idx=where(psi2 gt 1)
pprime22(idx)=!values.f_nan
ffprime22(idx)=!values.f_nan
j1_2 =- r2 * pprime22
j2_2 = -ffprime22 / r2 / (4*!pi*1e-7)
j_2=j1_2+j2_2

mkfig,'~/efit_jmid11003.eps',xsize=14.5,ysize=18,font_size=11 & !p.thick=3
plot,g.r,j1(*,iz0),yr=[-1e6,4e6],ysty=1,xtitle='R (m)',ytitle='j (A/m^2)',/nodata,pos=posarr(1,3,0,cnx=0.1,fx=0.8),title='net current',xr=xr,xsty=1
;,$
;    title='comparison of #11003 at t=3.45s (noeccd, solid lines) and 3.70s (w/eccd, dashed lines)

oplot,!x.crange,[0,0]
xr=[1.3,2.2]
oplot,g.r,j(*,iz0),col=1
oplot,g.r,j_2(*,iz0),col=1,linesty=2
oplot,g.rmaxis*[1,1],!y.crange
oplot,g2.rmaxis*[1,1],!y.crange,linesty=2



plot,g.r,j1(*,iz0),yr=[-1e6,4e6],ysty=1,xtitle='R (m)',ytitle='j (A/m^2)',/nodata,pos=posarr(/next),/noer,title="p' component",xr=xr,xsty=1
oplot,!x.crange,[0,0]
oplot,g.r,j1(*,iz0),col=2
oplot,g.r,j1_2(*,iz0),col=2,linesty=2

plot,g.r,j1(*,iz0),yr=[-1e6,4e6],ysty=1,xtitle='R (m)',ytitle='j (A/m^2)',/nodata,pos=posarr(/next),/noer,title="ff' component",xr=xr,xsty=1
oplot,!x.crange,[0,0]

oplot,g.r,j2(*,iz0),col=3
oplot,g.r,j2_2(*,iz0),col=3,linesty=2

;legend,['pprime component','ffprime component','total current'],$
;       textcol=[2,3,4],linesty=[0,0,0],col=[2,3,4],box=0,charsize=1.5

endfig,/gs,/jp
stop
calculate_bfield,bp,br,bt,bz,g

calculate_bfield,bp2,br2,bt2,bz2,g2

;plot,-g.r*100,bz2(*,iz0)-bz(*,iz0),xr=[-220,-165],xsty=1
;oplot,!x.crange,[0,0]
;oplot,-g.r,bz2(*,iz0),col=2
;stop
ii=calccurr(g,rho=rho) & ii=ii/max(ii) * (-g.cpasma)
ii2=calccurr(g2,rho=rho2) &ii2=ii2/max(ii2) * (-g2.cpasma)
ii2i=interpol(ii2,rho2,rho)
ii/=1e3
ii2i/=1e3
mkfig,'~/efit_enccurr2.eps',xsize=8,ysize=5.5,font_size=9
rho/=max(rho)
plot,rho,ii,xtitle=textoidl('\rho'),ytitle='enclosed current (kA)',pos=posarr(1,1,0,cnx=0.15,cny=0.1,fy=0.5),xsty=8,ysty=8
oplot,rho,ii2i,linesty=1

legend,['t=3.45s (ECCD off)','t=3.70s (ECCD on)'],linesty=[0,1],box=0,/bottom,/right
;stop
plot,rho,ii2i-ii,pos=posarr(/curr),xsty=4,ysty=4,col=2,/noer
oplot,!x.crange,[0,0],col=2,linesty=1
axis,!x.crange(1),!y.crange(0),yaxis=1,ytitle='Difference (kA)',col=2

endfig,/gs,/jp
;plot,g.pres
;oplot,g2.pres,col=2

end
