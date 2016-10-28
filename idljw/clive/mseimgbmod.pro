; make_p0_cdir,p0p,cdir,ix,iy,folder='~/nleonw/kmse',bin=16,sz=sz
 make_p0_cdir,p0p,cdir,ix,iy,folder='~/nleonw/kmse_7345',bin=16,sz=sz,ix1=ix1,iy1=iy1
nebula_kmodel,p0p,cdir,simg,mastbeam='k1',sz=sz

kbpars,mastbeam='k1',str=str
n=n_elements(ix)
rp=fltarr(n)
zp=fltarr(n)
for i=0,n-1 do begin
    solint,str.ductpoint,str.chat,p0p(*,i),cdir(*,i),cl,cb,dl,db
    rp(i)=sqrt(cl(0)^2+cl(1)^2)
    zp(i)=cl(2)

;    rp(i)=abs(rtangent(p0p(*,i),cdir(*,i),z=zt))
;    zp(i)=zt
endfor
rpr=reform(rp,sz(0),sz(1))
zpr=reform(zp,sz(0),sz(1))
;pro solint, B0,Bv, C0, Cv,coord,coordb,a,b

img=getimg(7427,index=60,sm=1,info=info,/getinfo,/mdsplus)
img=rotate(img,7)
sz=size(img,/dim)
ix2=indgen(sz(0))*info.hbin
iy2=indgen(sz(1))*info.vbin


imgplot,img,ix2,iy2,xsty=1,ysty=1,/cb,pos=posarr(1,2,0)
contour,rpr,ix1,iy1,c_lab=replicate(1,100),/noer,xsty=1,ysty=1,pos=posarr(/curr),lev=reverse([230,220,210,200,190,180]),xr=!x.crange,yr=!y.crange
imgplot,simg,ix1,iy1,xsty=1,ysty=1,/cb,/noer,pos=posarr(/next)
contour,rpr,ix1,iy1,c_lab=replicate(1,100),/noer,xsty=1,ysty=1,pos=posarr(/curr),lev=reverse([230,220,210,200,190,180])




end
