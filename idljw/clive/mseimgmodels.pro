; make_p0_cdir,p0p,cdir,ix,iy,folder='~/nleonw/kmse',bin=16,sz=sz
 make_p0_cdir,p0p,cdir,ix,iy,folder='~/nleonw/kmse_7345',bin=16,sz=sz,ix1=ix1,iy1=iy1

kbpars,mastbeam='k1',str=str
n=n_elements(ix)
rp=fltarr(n)
zp=fltarr(n)

;g=myreadg(7427,3000)
;sh=7489&idxarr=[45,46]-1

sh=7486&idxarr=[80,81];[126,127]

;sh=7485&idxarr=[79,80]

;sh=7485&idxarr=[25,26];earlier on

g=cleanstruct(myreadg(sh,idxarr(0)*50))
calculate_bfield,bp,br,bt,bz,g
rxs=fltarr(3,n)
rys=fltarr(3,n)


vx=str.chat(0) & vy=str.chat(1) & vz=str.chat(2)



for i=0,n-1 do begin
    solint,str.ductpoint,str.chat,p0p(*,i),cdir(*,i),cl,cb,dl,db
    rp(i)=sqrt(cl(0)^2+cl(1)^2)
    zp(i)=cl(2)

    rint=rp
    pint=atan(cl(1),cl(0))


;    rp(i)=abs(rtangent(p0p(*,i),cdir(*,i),z=zt))
;    zp(i)=zt


    C_vec1 = cdir(*,i)
    zhats=C_vec1
    yhats=[0,0,1.]
    xhats=crossp(yhats,zhats)  & xhats/=norm(xhats)
    yhats=crossp(xhats,zhats) 




    rhat=[cos(pint),sin(pint),0]
    zhat=[0,0,1.]
    phat=[-sin(pint) , cos(pint), 0]

    trmat=transpose([[rhat],[phat],[zhat]]);transpose

    vvec=cl - str.centre
    vvec=vvec/norm(vvec)
    vx=vvec(0) & vy=vvec(1) & vz=vvec(2)
vmat=[$
[0, -vz, vy],$
[vz,  0,-vx],$
[-vy,vx,  0]]

    eresp=vmat ## trmat
;    eresp=transpose(eresp)
    rx=xhats ## eresp
    ry=yhats ## eresp
    rxs(*,i)=rx ; [rad, tor, z]
    rys(*,i)=ry



endfor
;rxs:: 'Br_pemx','Btor_pemx','Bz_pemx'
;rys::,'Br_pemy','Btor_pemy','Bz_pemy',
ix=interpol(findgen(n_elements(g.r)),g.r,rp*.01)
iy=interpol(findgen(n_elements(g.z)),g.z,zp*.01)
bt1=interpolate(bt,ix,iy)
br1=interpolate(br,ix,iy)
bz1=interpolate(bz,ix,iy)

;rys(0,*)=0.
ey=rys(0,*) * br1 + rys(1,*) * bt1 + rys(2,*) * bz1
ex=rxs(0,*) * br1 + rxs(1,*) * bt1 + rxs(2,*) * bz1
ang=atan(ex,ey)*!radeg

angr=reform(ang,sz(0),sz(1))

rpr=reform(rp,sz(0),sz(1))
zpr=reform(zp,sz(0),sz(1))

prearr=replicate('c',2)
rarr=replicate(sh,2)
for i=0,1 do begin
demodcs, img,outs, doplot=doplot,zr=[-2,1],newfac=0.6 ,save={txt:prearr(i),shot:rarr(i),ix:idxarr(i)},override=0
if i eq 0 then outsr=outs
endfor
ph1=atan2(outs.c1/outsr.c1)/4*!radeg - 16
;ph1*=2
ph1=rotate(ph1,7);flipit
sz2=size(ph1,/dim)
mult=round(1392./sz2(0))
ix2=indgen(sz2(0))*mult
iy2=indgen(sz2(1))*mult
plot,ix2,ph1(*,sz2(1)/2),yr=zr
oplot,ix1,angr(*,sz(1)/2),col=2
tgam=tan(angr*!radeg)
ix=[1200,800]
ngam=n_elements(ix)
ix11=value_locate(ix1,ix)

tgamma=tgam(ix11,sz(1)/2)
sgamma=replicate(1*!dtor,ngam)
fwtgam=replicate(1.,ngam)
rrrgam=rpr(ix11,sz(1)/2)/100.
zzzgam=zpr(ix11,sz(1)/2)/100.
a8=reform(rys(0,*),sz(0),sz(1))
a1=reform(rys(2,*),sz(0),sz(1))
a4=reform(rxs(2,*),sz(0),sz(1))
a2=reform(rxs(1,*),sz(0),sz(1))

aa1gam=a1(ix11,sz(1)/2)
aa2gam=a2(ix11,sz(1)/2)
aa3gam=a8(ix11,sz(1)/2);!!!!relabeled
aa4gam=a4(ix11,sz(1)/2)
aa5gam=replicate(0,ngam)
aa6gam=replicate(0,ngam)


print,'&INS'
fmt=string('(',ngam-1,'(G0,","),G0)',format='(A,I0,A)')
print,'TGAMMA ='+string(tgamma,format=fmt)
print,'SGAMMA ='+string(sgamma,format=fmt)
print,'FWTGAM =',string(fwtgam,format=fmt)
print,'RRRGAM =',string(rrrgam,format=fmt)
print,'ZZZGAM =',string(zzzgam,format=fmt)
print,'AA1GAM =',string(aa1gam,format=fmt)
print,'AA2GAM =',string(aa2gam,format=fmt)
print,'AA3GAM =',string(aa3gam,format=fmt)
print,'AA4GAM =',string(aa4gam,format=fmt)
print,'AA5GAM =',string(aa5gam,format=fmt)
print,'AA6GAM =',string(aa6gam,format=fmt)
print,' IPLOTS = 1'
print,' KDOMSE = 1'
print,' /'


cursor,dx,dy,/down
;retall
pos=posarr(2,1,0)
zr=[-20,20]*.5
imgplot,ph1,ix2,iy2,pal=-2,/cb,pos=pos,zr=zr
imgplot,angr,ix1,iy1,/cb,pal=-2,pos=posarr(/next),/noer,zr=zr,xr=!x.crange,yr=!y.crange


; &INS
; TGAMMA = 0.0341396,0.112518,
; SGAMMA = 1,1,
; FWTGAM = 0.1,0.1,
; RRRGAM = 1.87,2.15,
; ZZZGAM = 0.,0.,
; AA1GAM = 1.,1.,
; AA2GAM = 1.,1.,
; AA3GAM = 0.,0.,
; AA4GAM = 0.,0.,
; AA5GAM = 0.,0.,
; AA6GAM = 0.,0.,
; IPLOTS = 1,
; KDOMSE = 1
; /

end
