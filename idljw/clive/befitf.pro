@newmakeefitnl
@newcmpmseefit
pro befitf,sh,tref,twant,norun=norun,inperr=inperr,dogas=dogas,dobeam2=dobeam2,kpp=kpp,kff=kff,runtwice=runtwice,drcm=drcm,invang=invang,rrng=rrng,gfile=gfile,mfile=mfile,lut=lut,field=field,wt=wt,dzcm=dzcm,nz=nz,distback=distback,noplot=noplot,mixfactor=mixfactor,cmpang=cmpang,outgname=outgname,errmixfactor=errmixfactor
default, lut, sh gt 8000

tarr=tref
ifr=frameoftime(sh,tarr,db='k')&only2=1&demodtype=sh gt 8000 ? 'sm32013mse' : 'basicd'
newdemodflclt,sh, ifr,dopc=dopc1,angt=ang1,eps=eps1,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,cars=cars1,istata=istata1,demodtype=demodtype,/noid2,lut=lut;,/cacheread,/cachewrite
;ang1b=ang1



tarra=twant
na=n_elements(tarra)
;goto,ee
for i=0,na-1 do begin
   tarr=tarra(i)
;tarr=2.7
ifr=frameoftime(sh,tarr,db='k')&only1=1&only2=0
;
if tarr eq -1 then ang1b=ang1 else    newdemodflclt,sh, ifr,dopc=dopc1,angt=ang1b,eps=eps1b,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,only1=only1,cars=cars1b,istata=istata1b,demodtype=demodtype,/noid2,lut=lut;,/cacheread,/cachewrite
if tarr eq -1 then tarr=tref

if sh lt 8000 then ang1b-=16 else if not keyword_set(lut) then ang1b-=12.8 else ang1b-=1.5

default,field,2
ang1b-= 2 * (field - 3) ; for new cmapign ref is at 3T

if sh lt 8000 then ang1b*=-1



if keyword_set(invang) then ang1b*=-1
default,inperr,0


if keyword_set(cmpang) then begin
   idx=where(finite(ang1b) eq 0)

   newcmpmseefit,ix2=ix2,iy2=iy2,angexp=ang1b,str=p,tw=tarr,inperr=inperr,dogas=dogas,dobeam2=dobeam2,outinperr=dif2,drcm=drcm,invang=invang,rrng=rrng,pgfile=gfile,mfile=mfile,dzcm=dzcm,nz=nz,distback=distback,angsim=angsim_mix,/just,mixfactor=mixfactor
   angsim_mix(idx)=!values.f_nan
   newcmpmseefit,ix2=ix2,iy2=iy2,angexp=ang1b,str=p,tw=tarr,inperr=inperr,dogas=dogas,dobeam2=0,outinperr=dif2,drcm=drcm,invang=invang,rrng=rrng,pgfile=gfile,mfile=mfile,dzcm=dzcm,nz=nz,distback=distback,angsim=angsim1,/just
   angsim1(idx)=!values.f_nan
   newcmpmseefit,ix2=ix2,iy2=iy2,angexp=ang1b,str=p,tw=tarr,inperr=inperr,dogas=dogas,dobeam2=1,outinperr=dif2,drcm=drcm,invang=invang,rrng=rrng,pgfile=gfile,mfile=mfile,dzcm=dzcm,nz=nz,distback=distback,angsim=angsim2,/just
   angsim2(idx)=!values.f_nan

   angsim_mix2 = (1-mixfactor) * angsim1 + mixfactor * angsim2

   sz=size(angsim_mix,/dim)
;   mkfig,'~/mixbeam_ang.eps',xsize=13,ysize=11,font_size=8
   plot,angsim_mix(*,sz(1)/2),xtitle='pos in image',ytitle='pol angle (deg)'
   oplot,angsim1(*,sz(1)/2),col=2
   oplot,angsim2(*,sz(1)/2),col=3
   oplot,angsim_mix2(*,sz(1)/2),col=4,thick=2
   legend,['calculated from mixed A coeffs and R vals','beam 1','beam2','mixed angle from beam 1 angle and beam 2 angle'],col=[1,2,3,4],textcol=[1,2,3,4],linesty=0,/right,box=0
   endfig,/gs,/jp
   stop




endif else begin
   
;   newcmpmseefit,ix2=ix2,iy2=iy2,angexp=ang1b,str=p,tw=tarr,inperr=inperr,dogas=dogas,dobeam2=dobeam2,outinperr=dif2,drcm=drcm,invang=invang,rrng=rrng,pgfile=gfile,mfile=mfile,dzcm=dzcm,nz=nz,distback=distback,angsim=angsim,/just,mixfactor=mixfactor
   idx=where(finite(ang1b) eq 0)

   newcmpmseefit,ix2=ix2,iy2=iy2,angexp=ang1b,str=p,tw=tarr,inperr=inperr,dogas=dogas,dobeam2=0,outinperr=dif2,drcm=drcm,invang=invang,rrng=rrng,pgfile=gfile,mfile=mfile,dzcm=dzcm,nz=nz,distback=distback,angsim=angsim1,/just
   angsim1(idx)=!values.f_nan
   newcmpmseefit,ix2=ix2,iy2=iy2,angexp=ang1b,str=p,tw=tarr,inperr=inperr,dogas=dogas,dobeam2=1,outinperr=dif2,drcm=drcm,invang=invang,rrng=rrng,pgfile=gfile,mfile=mfile,dzcm=dzcm,nz=nz,distback=distback,angsim=angsim2,/just
   angsim2(idx)=!values.f_nan

   default,errmixfactor,0
   mixfactorb=mixfactor+errmixfactor
   angsim = (1-mixfactorb) * angsim1 + mixfactorb * angsim2

   
   ang1b=angsim ;;;!thug
   ang1b(idx)=!values.f_nan

endelse


;stop


if not keyword_set(norun) then begin
   default,drcm,6
   default,dzcm,0
   default,nz,1
   default,wt,3.
   newmakeefitnl,ix2=ix2,iy2=iy2,angexp=ang1b,str=p,tw=tarr,wt=wt,drcm=drcm,inperr=inperr ,dobeam2=dobeam2,invang=invang,rrng=rrng,dzcm=dzcm,nz=nz,distback=distback,mixfactor=mixfactor
default,kpp,2
default,kff,3
 runefit1,sh=sh,tw=tarr,kpp=kpp,kff=kff
if keyword_set(outgname) then begin
   twr=((round(tarr*1000/5)*5)) / 1000.
   print,'tround=',twr
   fspec=string(sh,twr*1000,format='(I6.6,".",I6.6)')
   default,dirmod,''
   default,dir,'/home/cam112/ikstar/my2/EXP00'+string(sh,format='(I0)')+'_k'+dirmod
   gfile1=dir+'/g'+fspec
   gfile2=dir+'/g_'+outgname+'_'+fspec
   spawn,'mv '+gfile1+' '+gfile2
endif


endif

!p.title=string(tarr)
if keyword_set(noplot) then return
newcmpmseefit,ix2=ix2,iy2=iy2,angexp=ang1b,str=p,tw=tarr,inperr=inperr,dogas=dogas,dobeam2=dobeam2,outinperr=dif2,drcm=drcm,invang=invang,rrng=rrng,mfile=mfile,dzcm=dzcm,nz=nz,distback=distback,mixfactor=mixfactor,pgfile=gfile2

if keyword_set(runtwice)  and not keyword_set(norun) then begin
   befit1,sh,tref,tarr,norun=norun,inperr=dif2,dogas=dogas,dobeam2=dobeam2,kpp=kpp,kff=kff,invang=invang,rrng=rrng,drcm=drcm,dzcm=dzcm,nz=nz,distback=distback,mixfactor=mixfactor
endif
!p.title=''
;stop
endfor



end



;; ee:
;; qarr=fltarr(na,65)
;; for i=0,na-1 do begin
;;    tarr=tarra(i)
;;    fspec=string(sh,tarr*1000,format='(I6.6,".",I6.6)')
;;    dir='/home/cam112/ikstar/my2/EXP00'+string(sh,format='(I0)')+'_k'+''
;;    gfile=dir+'/g'+fspec
;;    g=readg(gfile)
;;    qarr(i,*)=g.qpsi
;;    print,gfile
;; endfor


;; end
