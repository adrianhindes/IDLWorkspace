@~/idl/clive/cmpmseefit_calc
pro makeefitnl, sh=sh,tw=tw,offs=offs,inperr=inperr,trueerr=trueerr,run=run,nostop=nostop,kff=kff,kpp=kpp,wt=wt,refi0=refi0,refsh=refsh,coff=coff,nocalc=nocalc,lookimg=lookimg,_extra=_extra
default,inperr,1.
default,wt,1.
cmpmseefit_calc,rix2=rix2,ph1=ph1,iy12=iy12,rpr=rpr,iy11=iy11,ang2r=ang2r,$
  tgam=tgam,ix12=ix12,zpr=zpr,rxs=rxs,rys=rys,sz=sz,ix11=ix11,ngam=ngam,dir1=dir,idxarr=idxarr,$
  ixa1=ix1,iya1=iy1,ixa2=ix2,iya2=iy2,$
 sh=sh,tw=tw,offs=offs,trueerr=trueerr,refi0=refi0,refsh=refsh,coff=coff,nocalc=nocalc


plot,rix2,ph1(*,iy12),yr=[-15,5]

default,inperr,0.

oplot,rpr(ix11,iy11),ph1(ix12,iy12) + inperr,psym=4

if keyword_set(lookimg) then begin

    sz=size(rpr,/dim)
    rix1=-rpr(*,sz(1)/2)
    riy1=zpr(sz(0)/2,*)
    rix2=interpol(rix1,ix1,ix2)
    riy2=interpol(riy1,iy1,iy2)

    ph1tmp=ph1
    idx=where(finite(ph1tmp) eq 0)
    zr=[-15,15]
    if idx(0) ne -1 then ph1tmp(idx)=zr(0)
    contourn2,ph1tmp,rix2,riy2,zr=zr,ysty=1,xsty=1,/iso,pal=-2,/cb,offx=1.0
    stop
endif




tgamma=tgam(ix12,iy12) + inperr*!dtor
sgamma=replicate(1*!dtor,ngam)
fwtgam=replicate(wt,ngam)
rrrgam=rpr(ix11,iy11)/100.
zzzgam=zpr(ix11,iy11)/100.
a3=reform(rys(0,*),sz(0),sz(1))
a4=reform(rys(2,*),sz(0),sz(1))
a2=reform(rys(1,*),sz(0),sz(1))

a1=reform(rxs(2,*),sz(0),sz(1))

aa1gam=a1(ix11,iy11)
aa2gam=a2(ix11,iy11)
aa3gam=a3(ix11,iy11)
aa4gam=a4(ix11,iy11)
aa5gam=replicate(0,ngam)
aa6gam=replicate(0,ngam)

    fspec=string(sh,tw*1000,format='(I6.6,".",I6.6)')

ino=where(finite(tgamma) eq 0)
if ino(0) ne -1 then begin
    tgamma(ino)=0.
    fwtgam(ino)=0.
endif

fil=dir+'/msenl_'+fspec
openw,lun,fil,/get_lun
printf,lun,'&INS'
fmt=string('(',ngam-1,'(G0,","),G0)',format='(A,I0,A)')
printf,lun,'TGAMMA ='+string(tgamma,format=fmt)
printf,lun,'SGAMMA ='+string(sgamma,format=fmt)
printf,lun,'FWTGAM =',string(fwtgam,format=fmt)
printf,lun,'RRRGAM =',string(rrrgam,format=fmt)
printf,lun,'ZZZGAM =',string(zzzgam,format=fmt)
printf,lun,'AA1GAM =',string(aa1gam,format=fmt)
printf,lun,'AA2GAM =',string(aa2gam,format=fmt)
printf,lun,'AA3GAM =',string(aa3gam,format=fmt)
printf,lun,'AA4GAM =',string(aa4gam,format=fmt)
printf,lun,'AA5GAM =',string(aa5gam,format=fmt)
printf,lun,'AA6GAM =',string(aa6gam,format=fmt)
printf,lun,' IPLOTS = 1'
printf,lun,' KDOMSE = 1'
printf,lun,' /'
printf,lun,'shot ',sh,'time ',tw,'idxarr',idxarr
close,lun
free_lun,lun
print,'wrote namelist to',fil

if keyword_set(doout) then begin
    bbz=bz1r(ix11,iy11)
    bbr=br1r(ix11,iy11)
    bbt=bt1r(ix11,iy11)
;    itmpx=interpol(findgen(n_elements(g.r)),g.r,rrrgam)
;    itmpy=interpol(findgen(n_elements(g.z)),g.z,replicate(1.0,16))

;    bbz=interpolate(bz,itmpx,itmpy)
;    bbr=interpolate(br,itmpx,itmpy)
;    bbt=interpolate(bt,itmpx,itmpy)
    bbz2=bz1r(ix11,iy11)*0
    bbr2=br1r(ix11,iy11)*0
    bbt2=bt1r(ix11,iy11)*0

openr,lun,'~/my2/EXP007485_k/bdat.txt',/get_lun
txt=''
while 1 do begin
    readf,lun,txt

    if strmid(txt,2,4) eq '----' then break
endwhile
cnt=0
done=0
while 1 do begin
    txt=''
    readf,lun,txt
    print,txt
    if strmid(txt,1,1) ne 'm' and done eq 0 then continue
    done=1
    spl=strsplit(txt,/extr)
    bbz2(cnt)=spl(3)
    bbr2(cnt)=spl(5)
    readf,lun,txt
    spl=strsplit(txt,/extr)
    bbt2(cnt)=spl(0)
    cnt=cnt+1
    if cnt eq 16 then break
endwhile


;bbz=[ 2.558467925292810E-002,0.167533435325605 ]
;bbr=[-1.981119625516455E-002,-1.739111093628551E-002]
;bbt=[ 1.87065912996788 , 1.67222696796808  ]

    
    bcg=(aa1gam * bbz )/ (aa3gam * bbr + aa4gam * bbz + aa2gam * bbt)
    oplot,rrrgam*100,atan(bcg)*!radeg,col=4,psym=4
    print,'blue is cal from gfile'

    bcg2=(aa1gam * bbz2 )/ (aa3gam * bbr2 + aa4gam * bbz2 + aa2gam * bbt2)
;    oplot,rrrgam*100,atan(bcg2)*!radeg,col=5,psym=4
    print,'cyan is calc from efit bfield'
    print,'and red is clc direcly by efit'

    err=median(m.cmgam-bcg)*!radeg
    print, 'the error is',err

    oplot,rrrgam*100,atan(bcg)*!radeg+err,col=5,psym=4
    print,'cyan is with blue plus error'


endif

if keyword_set(cmpimg) then begin
mkfig,'~/nicefig.eps',xsize=8,ysize=20,font_size=8
;zr=[-8,2]
zr=[-12,2]
sshot=string(sh,tw,format='(" ",I0," @ t=",G0,"s")')
rev=1
 contourn2,ph1,ix2,iy2,zr=zr,nl=60,pos=posarr(1,3,0,fx=0.5),ysty=1,xsty=1,title='measured'+sshot,/iso,rev=rev
oplot,!x.crange,iy*[1,1],thick=2
 contourn2,ang2r,ix1,iy1,zr=zr,nl=60,xr=!x.crange,yr=!y.crange,pos=posarr(/next),/noer,ysty=1,xsty=1,title='computed',/iso,rev=rev
oplot,!x.crange,iy*[1,1],thick=2
plot,ix2,ph1(*,iy12),yr=zr,pos=posarr(/next),/noer,title='measured and computed, line profile'
oplot,ix2(ix12),ph1(ix12,iy12),psym=4
oplot,!x.crange,[0,0]
oplot,ix1,ang2r(*,iy11),col=2
endfig,/jp,/gs


endif


if keyword_set(field) then begin
plot,rrrgam,bbz,pos=posarr(2,1,0),title='z'
oplot,rrrgam,bbz2,col=2

plot,rrrgam,bbr,pos=posarr(/next),title='r',/noer,yr=minmax([bbr,bbr2])
oplot,rrrgam,bbr2,col=2

print,'red is calc in efit bz'
endif

if not keyword_set(nostop) then stop

if keyword_set(run) then runefit1,sh=sh,tw=tw,dirmod=dirmod,trueerr=trueerr,kff=kff,kpp=kpp,offs=offs,_extra=_extra
end

;makeefitnl,sh=7485,tw=2.5,offs=1,true=-2.,inperr=1.
;end
