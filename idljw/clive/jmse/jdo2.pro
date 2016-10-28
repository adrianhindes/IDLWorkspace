function dee,var,fun
sz=size(fun,/dim)
nx=sz(0)
ny=sz(1)
rv=fun*0
if var eq 'x' then begin
for i=0,ny-1 do begin
   rv(*,i)=deriv(fun(*,i))
endfor
endif

if var eq 'y' then begin
for i=0,nx-1 do begin
   rv(i,*)=deriv(fun(i,*))
endfor
endif
return,rv
end

;goto,ff
e=read_kstar_intersect(9356)
d=read_interpolation_arrays(9356)

f=get_kstar_intersect(9356);shotno, bin=bin, beam=beam
g=calculate_mse_geometric_parameters(f,/ima);, geom, image_coords=image_coords


ee:
;readpatch,9323,p,db='k',nfr=100
;mgetptsnew,rarr=r,zarr=z,str=p,ix=ix2,iy=iy2,pts=pts,rxs=rxs,rys=rys,/calca,dobeam2=0,distback=distback,mixfactor=mixfactor ,/plane,bin=4

ff:
sz=size(f.r,/dim)

s2=sz(0)*sz(1)
rxsj=-[reform(g.n1,s2),reform(g.n3,s2),reform(g.n2,s2)]
rysj=[-reform(g.d1,s2),reform(g.d3,s2),reform(g.d2,s2)]
rxsj=reform(rxsj,sz(0),sz(1),3)
rysj=reform(rysj,sz(0),sz(1),3)

;rxsj=fltarr(sz(0),sz(1),3)
;rysj=rxsj
;rxsj(*,*,0)=-reform(g.n1,s2)
;rxsj(*,*,1)=-reform(g.n3,s2)
;rxsj(*,*,2)=-reform(g.n2,s2)
;rysj(*,*,0)=-reform(g.d1,s2)
;rysj(*,*,1)=reform(g.d3,s2)
;rysj(*,*,2)=reform(g.d2,s2)
goto,af
r2=congrid(r,sz(0),sz(1))/100
z2=congrid(z,sz(0),sz(1))/100

imgplot,(r2-f.r)*100. ,/cb,pal=-2
;stop

imgplot,(z2-f.z)*100. ,/cb,pal=-2
;stop

wset2,0
 plot,rxsj,pos=posarr(2,2,0),title='n'
plot,rxs,pos=posarr(/next),/noer,title='rxs'

 plot,rysj,pos=posarr(/next),title='d',/noer
plot,rys,pos=posarr(/next),/noer,title='rys'


wset2,1
erase
pos=posarr(3,2,0)
for k=0,1 do begin
if k eq 0 then begin
   a=rxs
   aj=rxsj
endif 
if k eq 1 then begin
   a=rys
   aj=rysj
endif 


for i=0,2 do begin

a0=a(*,*,i)
ajr=reform(aj,sz(0),sz(1),3)
aj0=ajr(*,*,i)
imgplot,aj0 - congrid(a0,sz(0),sz(1)),/cb,pal=-2,pos=pos,/noer,title=string(k,i)
pos=posarr(/next)

endfor
endfor
af:





;t=mdsvalue('DIM_OF(.DEMOD:THETA0,0)')
t=read_segmented_images_timebase('mse_2013',9323,'.DEMOD:THETA0')

;t=read_segmented_images_timebase('mse_2013',9323,'.DEMOD1:THETA0')
;stop

;t=t*1. / 1e6
i=value_locate3(t,2.15)
;i=3; ?guess
mdsopen,'mse_2013',9323
;d= ( get_image_seg('.DEMOD:THETA0',i)).images
d=( -( get_image_seg('.DEMOD:THETA',i)).images- 43.*!dtor)/4.
;d= ( get_image_seg('.DEMOD1:THETA0',i)).images
di= ( get_image_seg('.DEMOD:I0',i)).images 
idx=where(di lt max(di)*0.2)
d(idx)=!values.f_nan
;
mdsclose



;cdata,9323,1.925,2.1,angout=ang,inten=inten,/just,field=3.
;ang=rotate(ang,7);flip vert
;d=ang*!dtor

tgam=tan(d)


field=3.0

btcalc = 1.80/f.r * field

bzed =( tgam * rysj(*,*,1) - rxsj(*,*,1)) * btcalc / (rxsj(*,*,2) - 1*rysj(*,*,2)*tgam)

nxs=30*2 & nys=30*2;*2
kern=fltarr(nxs,nys)+1./(nxs*nys)
bzed=convol(bzed,kern,/edge_wrap)
r=f.r
z=f.z

;stop

triangulate,r,z,tri
nr2=129
nz2=129
r2=linspace(min(r),max(r),nr2)
z2=linspace(-1,1,nz2)*max(abs(z))

bzed2=trigrid(r,z,bzed, tri, xout=r2,yout=z2,missing=!values.f_nan)
nysm=11*2+1
nxsm=11;5;11;5


if keyword_set(dosym) then begin
   bzed2b=bzed2
   ix=reverse(indgen(nz2))
   for i=0,nz2-1 do begin
      bzed2b(*,i) = 0.5 * (bzed2(*,i) + bzed2(*,ix(i)))
   endfor
   bzed2=bzed2b
endif


;kern=fltarr(nxsm,nysm)+1./nysm/nxsm
bz2d2c=bzed2;convol(bzed2,kern,/edge_wrap)
imgplot,bz2d2c,/cb
;stop
dbzdz=dee('y',bz2d2c)
wset2,0
imgplot,dbzdz,r2,z2,/cb,pal=-2,zr=[-.02,.02]/2.
oplot,!x.crange,[0,0]
oplot,[1,1]*180,!y.crange


wset2,1
imgplot,-bzed2,r2,z2,/cb,xsty=1,ysty=1,pal=33,zr=[-.4,.4];pal=-2,
oplot,!x.crange,[0,0]

;oplot,[1,1]*180,!y.crange

;stop

wset2,3
imgplot,-bzed,/cb,xsty=1,ysty=1,pal=33,zr=[-.4,.4];pal=-2,,pal=-2
stop

wset2,2
iz0=nz2/2
plot,r2,bzed2(*,iz0)


dum=min(abs(bzed2(*,iz0)),imin,/nan)
oplot,r2(imin)*[1,1],!y.crange
oplot,!x.crange,[0,0]

stop
plot,r2,dbzdz(*,iz0),col=2,/noer
dum=min(abs(dbzdz(*,iz0)),imin,/nan)
oplot,r2(imin)*[1,1],!y.crange,col=2

oplot,!x.crange,[0,0],col=2
if keyword_set(calib) then begin
imgplot,ang1b,/cb,pal=-2
wset2,0
imgplot,rxs(*,*,1)/rys(*,*,1)*!radeg,/cb,pal=-2
wset2,1
imgplot,rxs(*,*,1)/rys(*,*,1)*!radeg - ang1b,/cb,pal=-2
endif
;dxz=dee('x',z)
;dyz=dee('y',z)
;dxp=dee('x',bzed)
;dyp=dee('y',bzed)

;dzx=1/dxz
;dzy=1/dyz
;dpdz = dzx * dxp + dzy * dyp


stop
;endfor




;end




;imgplot,rxs
   
end

