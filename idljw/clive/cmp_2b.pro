goto,af
sh=7479;26 ; 4 state
tr=[1,4.5]

newdemodflcshot,sh,tr,res=res

af:




common cbshot, shotc,dbc,isconnected
shotc=sh
dbc='kstar'
nbi1=cgetdata('\NB11_VG1')      ;\NB11_I0')
nbi2=cgetdata('\NB12_VG1')
sz=size(res.ang,/dim)
ix=sz(0)/2
iy=sz(1)/2

mkfig,'~/rsphy/cmp2b_ref.eps',xsize=12,ysize=12,font_size=10
contourn2,res.ang(*,*,30),zr=zr,/cb
plots,ix,iy,psym=4
endfig,/jp,/gs
retall

nsm=round( (res.t(1)-res.t(0)) / (nbi1.t(1)-nbi1.t(0)))

mkfig,'~/rsphy/cmp_2b.eps',xsize=24,ysize=18,font_size=12
pos=posarr(1,4,0)
;dif=res.dopc(ix,iy,0)-resb.dopc(ix,iy,0)

plot,res.t,res.dopc(ix,iy,*),psym=-4,xsty=1,/yno,pos=pos,title=string(sh,format='(I0)')
;oplot,resb.t,resb.dopc(ix,iy,*)+dif,col=3
pos=posarr(/next)

plot,nbi1.t,smooth(nbi1.v,nsm),xr=!x.crange,/noer,col=2,xsty=1,/yno,pos=pos
oplot,nbi2.t,smooth(nbi2.v,nsm),col=3
pos=posarr(/next)

;dif=res.ang(ix,iy,0)-resb.ang(ix,iy,0)

plot,res.t,res.ang(ix,iy,*),psym=-4,xsty=1,/yno,pos=pos,/noer

pos=posarr(/next)

plot,res.t,res.eps(ix,iy,*),psym=-4,xsty=1,/yno,pos=pos,/noer
;oplot,resb.t,resb.ang(ix,iy,*)+dif,col=3
;legend,['assuming qwp/hwp perfect','with true pars'],textcol=[1,3],/right,/bottom

endfig,/jp

; plot,t,dop2,/yno,pos=posarr(1,2,0),yr=[-180,180]
; oplot,t,dop2-180,col=3
; oplot,t,dop3,col=4
; vs=smooth(nbi1.v,200)
; plot,nbi1.t,vs,xr=!x.crange,xsty=1,/noer,/yno,col=2,pos=posarr(/next)

end
