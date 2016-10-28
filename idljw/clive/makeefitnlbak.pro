pro makeefitnl, sh=sh,tw=tw,offs=offs,doout=doout,dossh=dossh,field=field,inperr=inperr,trueerr=trueerr,cmpimg=cmpimg
 make_p0_cdir,p0p,cdir,ix,iy,folder='~/nleonw/kmse_7345',bin=16,sz=sz,ix1=ix1,iy1=iy1

kbpars,mastbeam='k1',str=str
n=n_elements(ix)
rp=fltarr(n)
zp=fltarr(n)
default,offs,0


i0=round(tw/0.05)
;make even
i0=(i0/2)*2+offs
idxarr=i0+[0,1]


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
;    print,acos(total(vvec * str.chat))*!radeg
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



if keyword_set(doout) then begin
;    fspec='007485.001100'
    fspec=string(sh,tw*1000,format='(I6.6,".",I6.6)')

    if keyword_set(dossh) then begin
        cmd='scp -P 2201 ikstar.nfri.re.kr:~/erun/?'+fspec+' ~/idl'
        spawn,cmd
        cmd='scp -P 2201 ikstar.nfri.re.kr:~/erun/bdat.txt ~/idl'
        spawn,cmd
    endif
    dir='/home/users/cmichael/my2/EXP00'+string(sh,format='(I0)')+'_k'
    g=readg(dir+'/g'+fspec)
    m=readm(dir+'/m'+fspec)
    calculate_bfield,bp,br,bt,bz,g
    ix=interpol(findgen(n_elements(g.r)),g.r,rp*.01)
    iy=interpol(findgen(n_elements(g.z)),g.z,zp*.01)
    bt1=interpolate(bt,ix,iy)
    br1=interpolate(br,ix,iy)
    bz1=interpolate(bz,ix,iy)
;rys(0,*)=0.
    ey=rys(0,*) * br1 + rys(1,*) * bt1 + rys(2,*) * bz1
    ex=rxs(0,*) * br1 + rxs(1,*) * bt1 + rxs(2,*) * bz1
    tang2=ey/ex;atan(ex,ey)*!radeg
    tang2r=reform(tang2,sz(0),sz(1))

    ang2=atan(ex,ey)*!radeg
    ang2r=reform(ang2,sz(0),sz(1))
    
    br1r=reform(br1,sz(0),sz(1))
    bz1r=reform(bz1,sz(0),sz(1))
    bt1r=reform(bt1,sz(0),sz(1))

endif

rpr=reform(rp,sz(0),sz(1))
zpr=reform(zp,sz(0),sz(1))

prearr=replicate('c',2)
rarr=replicate(sh,2)
for i=0,1 do begin
demodcs, img,outs, doplot=doplot,zr=[-2,1],newfac=0.6 ,save={txt:prearr(i),shot:rarr(i),ix:idxarr(i)},override=0
if i eq 0 then outsr=outs
endfor
default,trueerr,0
ph1=atan2(outs.c1/outsr.c1)/4*!radeg - 16 + trueerr
;ph1*=2
ph1=rotate(ph1,7);flipit
sz2=size(ph1,/dim)
mult=round(1392./sz2(0))
ix2=indgen(sz2(0))*mult
iy2=indgen(sz2(1))*mult


tgam=tan(ph1*!dtor)
ix=[1200,550]
ix=fix(linspace(1300,500,16))
iy=440
ngam=n_elements(ix)
ix11=value_locate(ix1,ix)
ix12=value_locate(ix2,ix)
iy11=value_locate(iy1,iy)
iy12=value_locate(iy2,iy)


rix2=interpol(rpr(*,iy11),ix1,ix2)
plot,rix2,ph1(*,iy12),yr=[-15,5]
if keyword_set(doout) then begin
;    oplot,rpr(*,iy11),ang2r(*,iy11),col=2
    if istag(m,'rrgam') then begin
        oplot,m.rrgam*100,atan(m.tangam)*!radeg,psym=4
        oplot,m.rrgam*100,atan(m.cmgam)*!radeg,psym=4,col=2
    endif


endif

default,inperr,0.
tgamma=tgam(ix12,iy12) + inperr*!dtor
sgamma=replicate(1*!dtor,ngam)
fwtgam=replicate(1.,ngam)
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
stop
end
;l m=           1 bz=  2.502452452590846E-002 br= -1.974026719654984E-002 bt=
;   1.87041540271159     
; m=           2 bz=  0.166733343571532      br= -1.736781049003355E-002 bt=
;   1.67221517376686     
