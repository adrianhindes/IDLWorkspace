function value_locate2, a, b

y=value_locate(a,b)
n=n_elements(a)
rv=(y>0)<(n-1)
return,rv
end


function convrange,crange,wid,off
cwid=crange(1)-crange(0)

noff=crange(0) + off*cwid
nwid=cwid*wid

orange=[noff,noff+nwid]
return,orange
end

function nspace, lst1,len1,nlevels,minor=mantn,extend=extend

lst=lst1
len=len1
rev=0
if len lt lst then begin
    lst=len1
    len=lst1
    rev=1
endif

default,extend,1
lev=linspace(lst,len,nlevels)

spacing=lev(1)-lev(0)
div=10.^(floor(alog10(spacing)))
mant=spacing/div
mantchoose=[1,2,5,10]
dummy=mantchoose-mant
ichoose=(where(dummy ge 0))(0)
mantn=mantchoose(ichoose)
spacingn=mantn*div
if extend eq 1 then begin
    levstart=floor(lev(0)/spacingn)*spacingn
    nlev=ceil((lev(nlevels-1)-levstart)/spacingn)+1
endif else begin
    levstart=ceil(lev(0)/spacingn)*spacingn
    nlev=floor((lev(nlevels-1)-levstart)/spacingn)+1
endelse

levn=levstart + spacingn*findgen(nlev)
lev=levn
nlevels=nlev
if rev eq 1 then lev=reverse(lev)
return, lev
end


pro contourn2,zp,xp,yp,zrange=zrange,nlevels=nlevels,$
              nonicelev=nonicelev,lev=lev,$
              xtitle=xtitle,xstyle=xstyle,xrange=xrange,xticks=xticks,$
              xtickv=xtickv,xticklen=xticklen,$
              ytitle=ytitle,ystyle=ystyle,yrange=yrange,yticks=yticks,$
              ytickv=ytickv,yticklen=yticklen,$
              title=title,subtitle=subtitle,charsize=charsize,position=position,$
              noerase=noerase,cb=cb,inhibitcb=inhibitcb, $
              widx=widx,widy=widy,offx=offx,offy=offy,ztitle=ztitle,$
              reverse=reverse,pal=pal,nicedefs=nicedefs,pause=pause,$
              irregular=irregular,iso=iso,n2levels=nlevels2,ctfix=ctfix,$
              xint=xint,yint=yint,exl=exl,dots=dots,xlog=xlog,ylog=ylog,$
              ssym=ssym,ygridstyle=ygridstyle,xgridstyle=xgridstyle,$
              xtickname=xtickname,ytickname=ytickname,plsym=plsym,special=special,darkness=darkness,box=box;,xticklabel=xticklabel,yticklabel=yticklabel
err=0
catch,err
if err ne 0 then goto,theend

common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

if keyword_set(nicedefs) then begin
    default, xstyle,1
    default, ystyle,1
    default, xticklen,1
    default, yticklen,1
    default,cb,1
endif


default,xtitle,!x.title
default,xstyle,!x.style
default,xticks,!x.ticks
default,xtickv,!x.tickv
default,xticklen,!x.ticklen

default,ytitle,!y.title
default,ystyle,!y.style

default,yticks,!y.ticks
default,ytickv,!y.tickv
default,yticklen,!y.ticklen

default,title,!p.title
default,subtitle,!p.subtitle
default,charsize,!p.charsize


z=reform(zp)
idx=where(finite(z) eq 0)
if idx(0) ne -1 then z(idx)=0;!values.f_nan ;0 ;min(zp(where(finite(zp eq 1))))
sz=size(z,/dim)
if n_elements(xp) eq 0 then xp=findgen(sz(0))
if n_elements(yp) eq 0 then yp=findgen(sz(1))

if keyword_set(box) then begin
    dx=xp(1)-xp(0)
    dy=yp(1)-yp(0)
    nx=n_elements(xp)
    ny=n_elements(yp)
    ix=fltarr(nx*2-2)
    iy=fltarr(ny*2-2)
    ix(0)=0 
    iy(0)=0 
    eps=0.05
    for i=1,nx-2 do begin
        ix(2*i-1)=(i)-eps
        ix(2*i)=i+eps
    endfor
    ix(2*nx-3)=nx-1
    for i=1,ny-2 do begin
        iy(2*i-1)=i-eps
        iy(2*i)=i+eps
    endfor
    iy(2*ny-3)=ny-1
    z2=fltarr(2*nx-2,2*ny-2)
    for i=0,2*nx-3 do for j=0,2*ny-3 do z2(i,j)=z(ix(i),iy(j))
    x=interpol(xp,findgen(nx),ix)
    y=interpol(yp,findgen(ny),iy)
    z=z2
endif else begin
    x=xp
    y=yp
endelse






default,xrange,[min(x),max(x)]
default,yrange,[min(y),max(y)]
default,pal,5

default,zrange,[min(z),max(z)]
z=z>zrange(0)<zrange(1)
default,nlevels,10
if pal eq -2 then zrange=[-1,1]*max(abs(zrange))
if not keyword_set(lev) then lev=linspace(zrange(0),zrange(1),nlevels) else $
  nlevels=n_elements(lev)


if not keyword_set(nonicelev) then begin
    lev=nspace(lev(0),lev(n_elements(lev)-1),n_elements(lev))
    nlevels=n_elements(lev)
    print,'nicelev'
endif

if keyword_set(xint) then begin
    default,exl,3
    zs=(z(value_locate2(x,xint(0)):value_locate2(x,xint(1)),$
                value_locate2(y,yint(0)):value_locate2(y,yint(1))))
    rg=dynrangem(zs,el=exl,eu=exl)
    lev=linspace(rg(0),rg(1),nlevels)
    print,'set lev to ',rg

endif
;print,lev



default,nlevels2,100
lev2=linspace(lev(0),lev(n_elements(lev)-1),nlevels2)
;on_error_goto, theend


if (xstyle mod 2) eq 1 then begin
    axticks=10
    xtickv=nspace(xrange(0),xrange(1),axticks,minor=minor,extend=-1)
    idx=where((xtickv ge xrange(0)) and (xtickv le xrange(1)))
    if idx(0) ne -1 then xtickv=xtickv(idx)
    xticks=n_elements(xtickv)-1
    !x.minor=minor
endif

if (ystyle mod 2) eq 1 then begin
    ayticks=10
    ytickv=nspace(min(y),max(y),ayticks,minor=minor,extend=-1)
    idx=where((ytickv ge yrange(0)) and (ytickv le yrange(1)))
    if idx(0) ne -1 then ytickv=ytickv(idx)
    yticks=n_elements(ytickv)-1
    !y.minor=minor
endif


if keyword_set(reverse) then $
  ccol=[linspace(!d.table_size-1,32,nlevels2+1)] $
else $
  ccol=[linspace(32,!d.table_size-1,nlevels2+1)]



if pal eq -3 then begin

    tek_color
    tvlct,v1,v2,v3,/get
    color_convert,v1,v2,v3,hue1,li1,sat1,/rgb_hls
    nt=256-32
    hue=fltarr(nt)
    sat=fltarr(nt)
    li=fltarr(nt)
    hue(*) = 0.
    default,darkness,1.0
    lightness=1-darkness
    if keyword_set(ctfix) or !d.name eq 'PS' then $
      li=linspace(lightness,1,nt) else lie=linspace(1,lightness,nt)
    sat(*) = 1.
    hue=[hue1(0:31),hue]
    li=[li1(0:31),li]
    sat=[sat1(0:31),sat]

    tvlct,hue,li,sat,/hls

    !p.background=0
    !p.color=1
endif

if pal eq -2 then begin

    tek_color
;    tvlct,hue1,li1,sat1,/get,/hls
    tvlct,v1,v2,v3,/get
    color_convert,v1,v2,v3,hue1,li1,sat1,/rgb_hls
;    zscl=max(abs(zrange(0:1)))
    nt=256-32
    hue=fltarr(nt)
    sat=fltarr(nt)
    li=fltarr(nt)
 ;   zp = (interpol([0,nt],[zrange(0),zrange(1)],0.))(0)
    hue(0:nt/2-1) = 240.
    hue(nt/2:*) = 0.
    default,darkness,1.0
    lightness=1-darkness
    if keyword_set(ctfix) or !d.name eq 'PS' then $
      li=[linspace(lightness,1,nt/2-2),linspace(1,lightness,nt/2+2)] $
      else $
      li=[linspace(1,lightness,nt/2),linspace(lightness,1,nt/2)]

;      li=[linspace(0,1,nt/2-2),linspace(1,0,nt/2+2)] $
;      else $
;      li=[linspace(1,0,nt/2),linspace(0,1,nt/2)]



;abs(linspace(zrange(0),zrange(1),nt))/zscl
    sat(*) = 1.
    hue=[hue1(0:31),hue]
    li=[li1(0:31),li]
    sat=[sat1(0:31),sat]

    tvlct,hue,li,sat,/hls

;    tek_color
;    !p.background=0
;    !p.color=255
    !p.background=0
    !p.color=1
;    contour,z,nl=100,/fill
;    return
;    stop
endif 

;goto,sk

if pal gt -1 then begin
    loadct,pal,/silent
    tvlct,ct1,ct2,ct3,/get
;endif else begin
    nt=256
    hue=fltarr(nt)
    sat=fltarr(nt)
    li=fltarr(nt)

    hue(0:nt/2-1) = 0.
    hue(nt/2:*) = 120.
    li=abs(linspace(-1,1,nt))
    sat(*) = 1.
    color_convert,hue,li,sat,ct1,ct2,ct3,/hls_rgb
    
;    tvlct,hue,li,sat,/hls
;    stop


    tek_color
    ct1b=[fltarr(32),interpol(float(ct1),findgen(256),linspace(0,255,256-32))]
    ct2b=[fltarr(32),interpol(float(ct2),findgen(256),linspace(0,255,256-32))]
    ct3b=[fltarr(32),interpol(float(ct3),findgen(256),linspace(0,255,256-32))]
    tvlct,ct1b,ct2b,ct3b
;print,n_elements(ct1b)
    tek_color
;endelse
endif


;if pal ne -1 and pal ne -2 and pal ne -3 then loadct,pal,/silent

if (!d.name eq 'PS') or keyword_set(ctfix) then ctfix

if pal ne -1 then begin
    !p.color=1
    !p.background=0
endif
sk:
tvlct,v1,v2,v3,/get
v4=sqrt(float(v1)^2/256.^2+float(v2)^2/256.^2+float(v3)^2/256.^2)/sqrt(3)
v4=v4*256.
if keyword_set(reverse) then $
  ccol2=[linspace(!d.table_size-1,32,n_elements(lev))] $
else $
  ccol2=[linspace(32,!d.table_size-1,n_elements(lev))]
lcol = v4(ccol2)
c_col2=lcol

idx=where(lcol gt 128)
if idx(0) ne -1 then if !d.name ne 'PS' then c_col2(idx) = 0  else c_col2(idx)=1
idx=where(lcol le 128)
if idx(0) ne -1 then if !d.name ne 'PS' then c_col2(idx) = 1  else c_col2(idx) = 0

if keyword_set(position) then begin
    contour,z,x,y,levels=lev2,/follow,$
            xtitle=xtitle,xstyle=xstyle,xrange=xrange,xticks=xticks,$
            xtickv=xtickv,xticklen=xticklen,$
            ytitle=ytitle,ystyle=ystyle,yrange=yrange,yticks=yticks,$
            ytickv=ytickv,yticklen=yticklen,$
            title=title,subtitle=subtitle,charsize=charsize,position=position,$
            noerase=noerase,/fill,c_colors=ccol,$
      irregular=irregular,iso=iso,xlog=xlog,ylog=ylog,ygridstyle=ygridstyle,xgridstyle=xgridstyle,xtickname=xtickname,ytickname=ytickname;,xticklabel=xticklabel,yticklabel=yticklabel


;;    contourfill,'tmpp',z,x,y,color_index=ccol

if not keyword_set(cb) then contour,z,x,y,levels=lev,/follow,/noerase,$
            xtitle=xtitle,xstyle=xstyle,xrange=xrange,xticks=xticks,$
            xtickv=xtickv,xticklen=xticklen,$
            ytitle=ytitle,ystyle=ystyle,yrange=yrange,yticks=yticks,$
            ytickv=ytickv,yticklen=yticklen,$
            title=title,subtitle=subtitle,charsize=charsize,position=position,$
            c_color=c_col2,      irregular=irregular,iso=iso,xlog=xlog,ylog=ylog,xtickname=xtickname,ytickname=ytickname;,xticklabel=xticklabel,yticklabel=yticklabel
endif else begin
    pmult=!p.multi
    contour,z,x,y,levels=lev2,/follow,$
            xtitle=xtitle,xstyle=xstyle,xrange=xrange,xticks=xticks,$
            xtickv=xtickv,xticklen=xticklen,$
            ytitle=ytitle,ystyle=ystyle,yrange=yrange,yticks=yticks,$
            ytickv=ytickv,yticklen=yticklen,$
            title=title,subtitle=subtitle,charsize=charsize,$
            noerase=noerase,/fill,c_colors=ccol,      irregular=irregular,iso=iso,xlog=xlog,ylog=ylog,ygridstyle=ygridstyle,xgridstyle=xgridstyle,xtickname=xtickname,ytickname=ytickname;,xticklabel=xticklabel,yticklabel=yticklabel
    !p.multi=pmult
;;    contourfill,'tmpp',z,x,y,color_index=ccol
if not keyword_set(cb) then contour,z,x,y,levels=lev,/follow,/noerase,$
            xtitle=xtitle,xstyle=xstyle,xrange=xrange,xticks=xticks,$
            xtickv=xtickv,xticklen=xticklen,$
            ytitle=ytitle,ystyle=ystyle,yrange=yrange,yticks=yticks,$
            ytickv=ytickv,yticklen=yticklen,$
            title=title,subtitle=subtitle,charsize=charsize,$
            c_color=c_col2,      irregular=irregular,iso=iso,xlog=xlog,ylog=ylog,xtickname=xtickname,ytickname=ytickname;,xticklabel=xticklabel,yticklabel=yticklabel
    if (!p.multi(1) ne 0) or (!p.multi(2) ne 0) then $
      !p.multi(0)=(!p.multi(0)-1 + !p.multi(1)*!p.multi(2)) mod $
                  (!p.multi(1)*!p.multi(2))
endelse
!x.minor=0
!y.minor=0

;stop
if keyword_set(cb) and not keyword_set(inhibitcb) then begin
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
    nynew=nlevels2
    nxnew=2
    ynew1=linspace(lev(0),lev(n_elements(lev)-1),nynew)
    print,minmax(ynew1)
    xnew1=[0,1]
    znew=replicate(1,2) # ynew1 

    contour, znew, xnew1, ynew1, position=pos0,/noerase,xsty=5,ysty=5,$
             levels=lev2,/fill,c_colors=ccol,zsty=1
;;    contourfill,'tmpp',znew,xnew1,ynew1,color_index=ccol
;    stop
    default,ztitle,''
    axis,1,0,yaxis=1,ytitle=ztitle,ysty=1
    !x=sx & !y=sy & !p=sp
endif



if keyword_set(dots) then begin
    default,ssym,1
    
    xsym = [-1, 0, 1, 0, -1]
    ysym = [0, 1, 0, -1, 0]
    ncirc=20
    xsym=fltarr(ncirc) & ysym=fltarr(ncirc)
    for i=0,ncirc-1 do begin
        xsym(i)=1*cos(2*!pi*float(i)/float(ncirc-1))
        ysym(i)=1*sin(2*!pi*float(i)/float(ncirc-1))
    endfor

    usersym, xsym, ysym;,/fill

    default,plsym,8
    if keyword_set(special) then idx=where(finite(zp)) else idx=findgen(n_elements(z))
    oplot, x(idx),y(idx),psym=plsym,symsize=ssym;,col=5
endif

;print,'nlevels=',nlevels
;print,lev2
if keyword_set(pause) then cursor,dx,dy,/down
theend:
catch,/cancel


end


