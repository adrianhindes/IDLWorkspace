pro cmpmseefit_calc,rix2=rix2,ph1=ph1,iy12=iy12,rpr=rpr,iy11=iy11,ang2r=ang2r,$
  tgam=tgam,ix12=ix12,zpr=zpr,rxs=rxs,rys=rys,sz=sz,ix11=ix11,ngam=ngam,dir1=dir,idxarr=idxarr,$
                    g=g,m=m,iy0=iy,ix0=ix,$
                    ixa1=ix1,iya1=iy1,ixa2=ix2,iya2=iy2,$
                    intens=intens,fspec=fspec,$
 sh=sh,tw=tw,offs=offs,trueerr=trueerr,dirmod=dirmod,refsh=refsh,refi0=refi0,coff=coff,nocalc=nocalc

default,trueerr,-2.
default,offs,0

gettim,sh=sh,tstart=tstart,ft=ft,folder=folder,type=type,wid=wid

 make_p0_cdir,p0p,cdir,ix,iy,folder=folder,bin=16,sz=sz,ix1=ix1,iy1=iy1,wid=wid

kbpars,mastbeam='k1',str=str
n=n_elements(ix)
rp=fltarr(n)
zp=fltarr(n)
default,offs,0




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
;    vx=vvec(0) & vy=vvec(1) & vz=vvec(2)
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

twr=((round(tw*1000/100)*100)) / 1000.
print,'tround=',twr
fspec=string(sh,twr*1000,format='(I6.6,".",I6.6)')

if keyword_set(dossh) then begin
    cmd='scp -P 2201 ikstar.nfri.re.kr:~/erun/?'+fspec+' ~/idl'
    spawn,cmd
    cmd='scp -P 2201 ikstar.nfri.re.kr:~/erun/bdat.txt ~/idl'
    spawn,cmd
endif
default,dirmod,''

spawn,'hostname',host
if host eq 'ikstar.nfri.re.kr' then dir='/home/users/cmichael/my2/EXP00'+string(sh,format='(I0)')+'_k'+dirmod else dir='/home/cam112/idl'



;centre:
pc=[610,362]
pt=[639,138]
pd=pt-pc
ang=atan(pd(1),pd(0))*!radeg
;print,'ang=',ang
;stop


rpr=reform(rp,sz(0),sz(1))
zpr=reform(zp,sz(0),sz(1))

i0=round((tw-tstart)/ft)
;stop

if type eq 'flc' then begin
    getflcstate,sh=sh,idx=i0+[0,1],flc0=flc0,flc1=flc1
    prearr=replicate('',2)
    rarr=replicate(sh,2)
;make even
;    i0=(i0/2)*2+offs
;    idxarr=i0+[0,1]
    idxarr=i0+[0,1]
    srt=sort(-flc1)
    idxarr=idxarr(srt)

endif 
if type eq 'spath' then begin
    prearr=replicate('',2)
    rarr=[refsh,sh]
    idxarr=[refi0,i0]
endif

for i=0,1 do begin
demodcs, img,outs, doplot=doplot,zr=[-2,1],newfac=0.6 ,save={txt:prearr(i),shot:rarr(i),ix:idxarr(i)},override=0
;stop
if i eq 0 then outsr=outs
endfor



if type eq 'flc' then begin
    intens=abs(outsr.c4)
    default,trueerr,0
    ph1=atan2(outs.c1/outsr.c1)/4*!radeg - 16 + trueerr
;ph1*=2
    ph1=rotate(ph1,7)           ;flipit
    intens=rotate(intens,7)
    sz2=size(ph1,/dim)
    mult=round(wid/sz2(0))
    ix2=indgen(sz2(0))*mult
    iy2=indgen(sz2(1))*mult
    tgam=tan(ph1*!dtor)
;    ix=[1200,550]
    if wid eq 1392 then begin
        ix=fix(linspace(1300,500,16))
        iy=440
    endif
    if wid eq 1600 then begin
        ix=fix(linspace(1600,100,16))
        iy=700
    endif
    ngam=n_elements(ix)
    ix11=value_locate(ix1,ix)
    ix12=value_locate(ix2,ix)
    iy11=value_locate(iy1,iy)
    iy12=value_locate(iy2,iy)
    rix2=interpol(rpr(*,iy11),ix1,ix2)
endif
if type eq 'spath' then begin
    ph1=atan2(outs.c1/outsr.c1)
    ph2=atan2(outs.c2/outsr.c2)
    intens=abs(outs.c4)
    a1=abs(outs.c1)/abs(outs.c4)*2
    a2=abs(outs.c2)/abs(outs.c4)*2
    jumpimg,ph1
    jumpimg,ph2

    phs=(ph1+ph2)*0.5
    phd=(ph1-ph2)*0.5
    ang=(phs*!radeg+180*0)/2 + coff  ;;-25 +10. + 90.

    ph1=-ang ;; hack to relabel variable
    sz2=size(ph1,/dim)
    mult=round(1600./sz2(0))
    ix2=indgen(sz2(0))*mult
    iy2=indgen(sz2(1))*mult
    tgam=tan(ph1*!dtor)
    ix=[1200,550]
    ix=fix(linspace(1600,100,16))
    iy=700
    ngam=n_elements(ix)
    ix11=value_locate(ix1,ix)
    ix12=value_locate(ix2,ix)
    iy11=value_locate(iy1,iy)
    iy12=value_locate(iy2,iy)
    rix2=interpol(rpr(*,iy11),ix1,ix2)
    zix2=interpol(zpr(*,iy11),ix1,ix2)

endif




if keyword_set(nocalc) then return


g=readg(dir+'/g'+fspec)
m=readm(dir+'/m'+fspec)
;g=readg('/home/cam112/idl/g007485.002500')
;m=readm('/home/cam112/idl/m007485.002500')

calculate_bfield,bp,br,bt,bz,g
ix=interpol(findgen(n_elements(g.r)),g.r,rp*.01)
iy=interpol(findgen(n_elements(g.z)),g.z,zp*.01)
bt1=interpolate(bt,ix,iy)
br1=interpolate(br,ix,iy)
bz1=interpolate(bz,ix,iy)
;rys(0,*)=0.
ey=rys(0,*) * br1 + rys(1,*) * bt1 + rys(2,*) * bz1
ex=rxs(0,*) * br1 + rxs(1,*) * bt1 + rxs(2,*) * bz1
tang2=ey/ex                     ;atan(ex,ey)*!radeg
tang2r=reform(tang2,sz(0),sz(1))

ang2=atan(ex,ey)*!radeg
ang2r=reform(ang2,sz(0),sz(1))

br1r=reform(br1,sz(0),sz(1))
bz1r=reform(bz1,sz(0),sz(1))
bt1r=reform(bt1,sz(0),sz(1))

end
