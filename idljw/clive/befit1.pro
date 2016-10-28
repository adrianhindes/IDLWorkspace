@newmakeefitnl
@newcmpmseefit
pro befit1,sh,tref,twant,norun=norun,inperr=inperr,dogas=dogas,dobeam2=dobeam2,kpp=kpp,kff=kff,runtwice=runtwice,drcm=drcm,invang=invang,rrng=rrng,gfile=gfile,mfile=mfile,lut=lut,field=field,wt=wt,dzcm=dzcm,nz=nz,distback=distback,noplot=noplot,shref=shref,mixfactor=mixfactor,outgname=outgname,fwtcur=fwtcur,readgg=readgg,db=db,nocmp=nocmp
;default, lut, sh gt 8000
default,db,'k'
tarr=tref
default,shref,sh
ifr=frameoftime(shref,tarr,db=db)&only2=1&demodtype=sh gt 8000 ? 'sm32013mse' : 'basicd'






newdemodflclt,shref, ifr,dopc=dopc1,angt=ang1,eps=eps1,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,cars=cars1,istata=istata1,demodtype=demodtype,/noid2,lut=lut,multiplier=multiplier,db=db,inten=inten,lin=lin;,/cacheread;,/cachewrite;,twant=twant
;ang1b=ang1


;stop

tarra=twant
na=n_elements(tarra)
;goto,ee
for i=0,na-1 do begin
   tarr=tarra(i)
;tarr=2.7
ifr=frameoftime(sh,tarr,db=db)&only1=1&only2=0
;
if tarr eq -1 then ang1b=ang1 else    newdemodflclt,sh, ifr,dopc=dopc1,angt=ang1b,eps=eps1b,ix=ix2,iy=iy2,pp=p,str=str,only2=only2,only1=only1,cars=cars1b,istata=istata1b,demodtype=demodtype,/noid2,lut=lut,db=db,inten=inten,lin=lin,/cacheread;,/cachewrite
if tarr eq -1 then tarr=tref

if sh lt 8000 then offset=16 

if sh ge 8001 and sh lt 9500*10 then begin
   if not keyword_set(lut) then offset=12.8 else offset=1.5
endif
print,'using offset of ',offset
ang1b-=offset
;if sh ge 9500 then begin
;   if not keyword_set(lut) then ang1b-=12.8+3 else ang1b-=12.8
;endif


default,field,2
ang1b-= 2 * (field - 3) ; for new cmapign ref is at 3T

if sh lt 8000 then ang1b*=-1



if keyword_set(invang) then ang1b*=-1
default,inperr,0
if not keyword_set(norun) then begin
   default,drcm,6
   default,dzcm,0
   default,nz,1
   default,wt,3.
   newmakeefitnl,ix2=ix2,iy2=iy2,angexp=ang1b,str=p,tw=tarr,wt=wt,drcm=drcm,inperr=inperr ,dobeam2=dobeam2,invang=invang,rrng=rrng,dzcm=dzcm,nz=nz,distback=distback,/doplot
default,kpp,2
default,kff,3

 runefit1,sh=sh,tw=tarr,kpp=kpp,kff=kff,fwtcur=fwtcur
endif

!p.title=string(tarr)
if keyword_set(noplot) then return

if keyword_set(outgname) then begin
   twr=((round(tarr*1000/5)*5)) / 1000.
   print,'tround=',twr
   fspec=string(sh,twr*1000,format='(I6.6,".",I6.6)')
   default,dirmod,''
   default,dir,'/home/cam112/ikstar/my2/EXP00'+string(sh,format='(I0)')+'_k'+dirmod
   gfile1=dir+'/g'+fspec
   gfile2=dir+'/g_'+outgname+'_'+fspec
   spawn,'rm '+gfile2
   spawn,'mv '+gfile1+' '+gfile2
endif

if keyword_set(nocmp) then return
newcmpmseefit,ix2=ix2,iy2=iy2,angexp=ang1b,str=p,tw=tarr,inperr=inperr,dogas=dogas,dobeam2=dobeam2,outinperr=dif2,drcm=drcm,invang=invang,rrng=rrng,pgfile=gfile2,mfile=mfile,dzcm=dzcm,nz=nz,distback=distback,mixfactor=mixfactor,readgg=readgg,inten=inten,lin=lin,/figwide

if keyword_set(runtwice)  and not keyword_set(norun) then begin
   befit1,sh,tref,tarr,norun=norun,inperr=dif2,dogas=dogas,dobeam2=dobeam2,kpp=kpp,kff=kff,invang=invang,rrng=rrng,drcm=drcm,dzcm=dzcm,nz=nz,distback=distback
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
