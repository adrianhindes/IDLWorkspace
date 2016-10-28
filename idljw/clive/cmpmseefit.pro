pro cmpmseefit, sh=sh,tw=tw,offs=offs,trueerr=trueerr,dirmod=dirmod,equi=equi,ffp=ffp,cmpimg=cmpimg,doshowq=showq,refi0=refi0,refsh=refsh,coff=coff

cmpmseefit_calc,rix2=rix2,ph1=ph1,iy12=iy12,rpr=rpr,iy11=iy11,ang2r=ang2r,$
  g=g,m=m,iy0=iy,ix0=ix,ix12=ix12,$
  ixa1=ix1,iya1=iy1,ixa2=ix2,iya2=iy2,$
  intens=intens,$
  zpr=zpr,fspec=fspec,$
 sh=sh,tw=tw,offs=offs,trueerr=trueerr,dirmod=dirmod,refi0=refi0,refsh=refsh,coff=coff

mkfig,'~/pf'+fspec+'.eps',xsize=10,ysize=10,font_size=9
!p.thick=3
    sshot=string(sh,tw,format='(" ",I0," @ t=",G0,"s")')
;yr=[-12,0]
yr=[-12,12]
plot,rix2,ph1(*,iy12),yr=yr,$
  xtitle='R (cm)',ytitle='Pol. Angle (deg)',title=sshot

oplot,rpr(*,iy11),ang2r(*,iy11),col=4
legend,['MSE measurement','EFIT calculation'],col=[1,4],/right,box=0,textcol=[1,4]
if istag(m,'rrgam') then begin
    oplot,m.rrgam*100,atan(m.tangam)*!radeg-1,psym=4
;    oplot,m.rrgam*100,atan(m.cmgam)*!radeg,psym=4,col=2
endif
!p.thick=1
endfig,/gs,/jp

if keyword_set(showq) then begin
    mkfig,'~/q'+fspec+'.eps',xsize=10,ysize=5,font_size=9
    !p.thick=3

    plot,g.rhovn,g.qpsi,xtitle='r/a',ytitle='q',yr=[0.5,4],ysty=1
    oplot,!x.crange,[1,1],linesty=2
    endfig,/gs,/jp
endif



dpsi=g.ssibry-g.ssimag
p2=(g.psirz-g.ssimag)/dpsi
p3=sqrt(p2)

if keyword_set(equi) then begin
;    stop
    mkfig,'~/equi'+fspec+'.eps',xsize=7,ysize=9,font_size=7
    !p.thick=3

    contourn2,p3,g.r,g.z,/iso,lev=linspace(0,1,11),xr=[1.2,2.3],yr=[-1,1],xsty=1,ysty=1
    oplot,g.lim(0,*),g.lim(1,*),col=4
    endfig,/gs,/jp
endif

if keyword_set(ffp) then begin
    mkfig,'~/p'+fspec+'.eps',xsize=10,ysize=5,font_size=9
    !p.thick=3
    plot,g.rhovn,g.pres,xtitle='r/a',ytitle='pressure'
    endfig,/gs,/jp
endif

if keyword_set(cmpimg) then begin
mkfig,'~/nicefig.eps',xsize=13,ysize=10,font_size=8
;zr=[-8,2]
    iix=interpol(findgen(n_elements(g.r)),g.r*100,rpr)
    iiy=interpol(findgen(n_elements(g.z)),g.z*100,zpr)
    psiimg=interpolate(p3,iix,iiy)

    zr=[-7,2]
    zr=[-12,12]
    sshot=string(sh,tw,format='(" ",I0," @ t=",G0,"s")')
    rev=1
;    stop
    sz=size(rpr,/dim)
    rix1=-rpr(*,sz(1)/2)
    riy1=zpr(sz(0)/2,*)
    rix2=interpol(rix1,ix1,ix2)
    riy2=interpol(riy1,iy1,iy2)

    riy=interpol(riy1,iy1,iy)
    ph1tmp=ph1
    idx=where(finite(ph1tmp) eq 0)
    if idx(0) ne -1 then ph1tmp(idx)=zr(0)
    contourn2,ph1tmp,rix2,riy2,zr=zr,nl=60,pos=posarr(2,2,0,fx=0.5),ysty=1,xsty=1,title='measured angle'+sshot,/iso,rev=rev
    oplot,!x.crange,iy*[1,1],thick=2
    contourn2,ang2r,rix1,riy1,zr=zr,nl=60,xr=!x.crange,yr=!y.crange,pos=posarr(/next),/noer,ysty=1,xsty=1,title='computed angle',/iso,rev=rev
    oplot,!x.crange,riy*[1,1],thick=2

    contourn2,intens,rix2,riy2,pos=posarr(/next),xsty=1,ysty=1,title='intensity',/iso,rev=rev,/noer,/cb,/inhibit
    contourn2,psiimg,rix1,riy1,pos=posarr(/next),xsty=1,ysty=1,title='flux surf',/iso,rev=1-rev,/noer,lev=linspace(0.,1,11)

;    plot,ix2,ph1(*,iy12),yr=zr,pos=posarr(/next),/noer,title='measured and computed, line profile'
;    oplot,ix2(ix12),ph1(ix12,iy12),psym=4
;    oplot,!x.crange,[0,0]
;    oplot,ix1,ang2r(*,iy11),col=2
endfig,/jp,/gs
stop
endif


end


cmpmseefit,sh=7485,tw=2.5,offs=1,true=-2,dirmod='2'
end
