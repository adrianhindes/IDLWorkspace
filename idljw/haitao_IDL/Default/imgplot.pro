function convrange,crange,wid,off
cwid=crange(1)-crange(0)

noff=crange(0) + off*cwid
nwid=cwid*wid

orange=[noff,noff+nwid]
return,orange
end

pro imgplot,z,x,y,xr=xr,yr=yr,zr=zr,xsty=xsty,ysty=ysty,position=position,noerase=noerase,pal=pal,cb=cb,title=title,iso=iso,cont=cont,reverse=reverse,nlevels=nlevels,dostop=dostop,xtitle=xtitle,ytitle=ytitle,offx=offx,ztitle=ztitle
default,pal,5
sz=size(z,/dim)
default,x,findgen(sz(0))
default,y,findgen(sz(1))
default,xsty,0
default,ysty,0
default,zr,pal eq -2 ? max(abs(z(where(finite(z)))))*[-1,1] : [min(z(where(finite(z)))),max(z(where(finite(z))))]


pmult=!p.multi
contour,z,x,y,xr=xr,yr=yr,/nodata,xsty=xsty or 4,ysty=ysty or 4,position=position,noerase=noerase,iso=iso,xtitle=xtitle,ytitle=ytitle

pmult1=!p.multi


xsiz=(!x.window(1)-!x.window(0))*!d.x_vsize
ysiz=(!y.window(1)-!y.window(0))*!d.y_vsize

xcr=!x.crange
ycr=!y.crange
ixa=interpol(findgen(sz(0)),x,xcr)
iya=interpol(findgen(sz(1)),y,ycr)

ix=linspace(ixa(0),ixa(1),fix(ixa(1)-ixa(0)+1))
iy=linspace(iya(0),iya(1),fix(iya(1)-iya(0)+1))
zmis=min(z(where(finite(z))))
;if keyword_set(reverse) then zmis=max(z(where(finite(z))))

if pal eq -2 then zmis=(zr(1)+zr(0))/2.
zz=z
iii=where(finite(z) eq 0)
if iii(0) ne -1 then zz(iii)=zmis
zbtmp=interpolate(zz,ix,iy,/grid,missing=zmis)
if keyword_set(reverse) then begin
    zra=zr
    zra(0)=zr(1)
    zra(1)=zr(0)
endif else zra=zr

zb=((float(zbtmp)-zra(0)*1.)/(zra(1)*1.-zra(0)) * (256-32.))
zb=zb>0<(255-32)
zb=zb + 32. 
;zb=zb>32 < 255


loadctb,pal

if !d.name ne 'PS' then begin
    z2=congrid(zb,xsiz,ysiz)
    tv,z2,!x.crange(0),!y.crange(0),/data
endif else begin
;    xsizcm=xsiz/!d.x_px_cm
;    ysizcm=xsiz/!d.y_px_cm
    ctfix
    xsiz=!x.crange(1)-!x.crange(0)
    ysiz=!y.crange(1)-!y.crange(0)
    tv,zb,!x.crange(0),!y.crange(0),/data,xsize=xsiz,ysize=ysiz


;,xsize=xsizcm,ysize=ysizcm
endelse
;endfig,/gs
if keyword_set(dostop) then stop

;if not keyword_set(position) then 
!p.multi=pmult
if not keyword_set(cont) then contour,z,x,y,xr=xr,yr=yr,/nodata,/noer,xsty=xsty,ysty=ysty,position=position,title=title,iso=iso,xtitle=xtitle,ytitle=ytitle $
  else $
  contour,z,x,y,xr=xr,yr=yr,/noer,xsty=xsty,ysty=ysty,position=position,title=title,iso=iso,nlevels=nlevels,zr=zr,xtitle=xtitle,ytitle=ytitle
!p.multi=pmult1



if keyword_set(cb) then begin
    default,widx,0.05
    default,offx,0.9
    default,widy,1.0
    default,offy,0.
    sx=!x & sy=!y & sp=!p
    px= convrange(!x.crange,widx,offx)
    cxm=!x.crange & if keyword_set(xlog) then cxm=10.^cxm
    cym=!y.crange & if keyword_set(ylog) then cym=10.^cym

    dummy=convert_coord(convrange(cxm,widx,offx),$
                        convrange(cym,widy,offy),$
                        /data,/to_normal)
    pos0=reform(dummy(0:1,0:1),4)
    
    nynew=256-32
    nxnew=2
    ynew1=linspace(zr(0),zr(1),nynew)
    xnew1=[0,1]
    znew=replicate(1,2) # ynew1 

    imgplot,znew,xnew1,ynew1,position=pos0,/noerase,xsty=5,ysty=5,pal=pal,reverse=reverse
    default,ztitle,''
    axis,1,0,yaxis=1,ytitle=ztitle,ysty=1
    !x=sx & !y=sy & !p=sp
endif
end


;imgplot,dist(10);,xr=[0,20],yr=[0,20]

;end
