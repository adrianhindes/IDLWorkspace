pro newcmpmseefit,ix2=ix2,iy2=iy2,angexp=angexp,str=p,tw=tw,pgfile=gfile,dir=dir,moddir=dirmod,inperr=inperr,dogas=dogas,dobeam2=dobeam2,outinperr=dif2,drcm=drcm,rrng=rrng,invang=invang,mfile=mfile,dzcm=dzcm,nz=nz,distback=distback,angsim=ang2,just=just,mixfactor=mixfactor,rval=r,zval=z,readgg=readgg,bz1=bz1,bt1=bt1,lin=lin,inten=inten,figwide=figwide



;,rix2=rix2,ph1=ph1,iy12=iy12,rpr=rpr,iy11=iy11,ang2r=ang2r,$
;  tgam=tgam,ix12=ix12,zpr=zpr,rxs=rxs,rys=rys,sz=sz,ix11=ix11,ngam=ngam,dir1=di;r,idxarr=idxarr,$
;                    g=g,m=m,iy0=iy,ix0=ix,$
;                    ixa1=ix1,iya1=iy1,ixa2=ix2,iya2=iy2,$
;                    intens=intens,fspec=fspec,$
; sh=sh,tw=tw,trueerr=trueerr,dirmod=dirmod,refsh=refsh,refi0=refi0,coff=coff,no;calc=nocalc,res=res

;default,trueerr,-2.


;gettim,sh=sh,tstart=tstart,ft=ft,folder=folder,type=type,wid=wid

;spawn,'hostname',host
;if host eq 'ikstar.nfri.re.kr' then dir='/home/users/cmichael/my2/EXP00'+string;(sh,format='(I0)')+'_k'+dirmod else dir='/home/cam112/idl'

;g=readg(dir+'/g'+fspec)
;m=readm(dir+'/m'+fspec)
;g=readg('/home/cam112/idl/g007485.002500')
;m=readm('/home/cam112/idl/m007485.002500')



sh=p.sh

mgetptsnew,rarr=r,zarr=z,str=p,ix=ix2,iy=iy2,pts=pts,rxs=rxs,rys=rys,/calca,dobeam2=dobeam2,distback=distback,mixfactor=mixfactor;,/plane

default,dirmod,''

default,dir,'/home/cam112/ikstar/my2/EXP'+string(sh,format='(I6.6)')+'_k'+dirmod

twr=((round(tw*1000/5)*5)) / 1000.
print,'tround=',twr
fspec=string(sh,twr*1000,format='(I6.6,".",I6.6)')

default,gfile,dir+'/g'+fspec
default,mfile,dir+'/m'+fspec
g=readg(gfile)
if keyword_set(readgg) then begin
   restore,file='~/gg.sav',/verb
endif

calculate_bfield,bp,br,bt,bz,g
;br*=-1
;bz*=-1;flip as though bt were flipped
if keyword_set(dogas) then begin
   sz=size(g.psirz)
   for j=0,sz(1)-1 do bt(*,j)=g.bcentr*g.rzero/g.r
   bz=bz*0
   br=br*0
endif

bt*=-1
  
ix=interpol(findgen(n_elements(g.r)),g.r,r*.01)
iy=interpol(findgen(n_elements(g.z)),g.z,z*.01)
bt1=interpolate(bt,ix,iy)
br1=interpolate(br,ix,iy)
bz1=interpolate(bz,ix,iy)
;stop
psi=interpolate((g.psirz-g.ssimag)/(g.ssibry-g.ssimag),ix,iy)
psiun=interpolate((g.psirz),ix,iy)
;rys(0,*)=0.
sgn=keyword_set(invang) ? -1 : 1
ey=rys(*,*,0) * br1 + rys(*,*,1) * bt1 + rys(*,*,2) * bz1
ex=rxs(*,*,0) * br1 + rxs(*,*,1) * bt1 + rxs(*,*,2) * bz1
ex*=sgn
tang2=ex/ey                     ;atan(ex,ey)*!radeg

ang2=atan(ex,ey)*!radeg

if keyword_set(just) then return
m=readm(mfile)



sz=size(r,/dim)
iz0=value_locate(z(sz(0)/2,*),0)
r1=r(*,iz0)
z1=z(sz(0)/2,*)



iz=where(finite(angexp) eq 0)
ang2(iz)=!values.f_nan
default,nz,1
nz1=nz
if keyword_set(figwide) then nz1=nz1+2
if sh lt 8800 then fac=2 else fac=1
if sh eq 9129 then fac=2
contourn2,ang2,r1,z1,pos=posarr(2,(3+nz1)/2,0),zr=[-7,7]*fac,pal=-2,nl=15,/nonice,ysty=1,xsty=1
contour,angexp,r1,z1,pos=posarr(/curr),/noer,lev=linspace(-7,7,15)*fac,ysty=1,xsty=1
contourn2,angexp-ang2,r1,z1,pos=posarr(/next),/noer,zr=[-7,7]*fac/10.,pal=-2,nl=15,/nonice,ysty=1,xsty=1

contourn2,inten,r1,z1,pos=posarr(/next),/noer,nl=15,/nonice,ysty=1,xsty=1,title='intenisty'

contourn2,lin,r1,z1,pos=posarr(/next),/noer,nl=15,/nonice,ysty=1,xsty=1,title='polar frac'





;stop

;; default,drcm,6.
;; igood=where(finite(angexp(*,iz0)) eq 1)
;; default,rrng,[min(r1(igood)),max(r1(igood))]
;; ngam=floor((rrng(1)-rrng(0))/(drcm))+1
;; rwant=rrng(0)+drcm * findgen(ngam) 

;; ;ngam=floor((max(r1)-min(r1))/(drcm))
;; ;rwant=min(r1)+drcm * findgen(ngam) 

;; rwant+= (max(r1) - max(rwant))/2. ; centre

;; angexpwant=interpol(angexp(*,iz0),r1,rwant)
;; angcalcwant=interpol(ang2(*,iz0),r1,rwant)

default,drcm,3.
default,dzcm,0
default,nz,1

igood=where(finite(angexp(*,iz0)) eq 1)
default,rrng,[min(r1(igood)),max(r1(igood))]
ngam1=floor((rrng(1)-rrng(0))/(drcm))+1;!!!!
rwant1=rrng(0)+drcm * findgen(ngam1) 
;rwant1+= (rrng(1) - max(rwant1))/2. ; centre

default,zrng,(nz-1.)/2.*[-1,1]*dzcm
zwant1=nz gt 1 ? linspace(zrng(0),zrng(1),nz) : zrng(0)
ngam=ngam1*nz
rwant=fltarr(ngam)
zwant=rwant
for i=0,nz-1 do begin
   rwant(ngam1*i:ngam1*(i+1)-1)=rwant1
   zwant(ngam1*i:ngam1*(i+1)-1)=zwant1(i)
endfor
if nz gt 1 then begin
triangulate,r,z,tri
angexpwant=trigrid(r,z,angexp, tri, xout=rwant1,yout=zwant1)
angcalcwant=trigrid(r,z,ang2, tri, xout=rwant1,yout=zwant1)
angexpwant=reform(angexpwant,ngam)
angcalcwant=reform(angcalcwant,ngam)
endif else begin
   ix=interpol(findgen(n_elements(r1)),r1,rwant)
   iy=interpol(findgen(n_elements(z1)),z1,zwant)
   angexpwant=interpolate(angexp,ix,iy)
   angcalcwant=interpolate(ang2,ix,iy)
endelse

ix2=interpol(findgen(n_elements(g.r)),g.r,rwant*.01)
iy2=interpol(findgen(n_elements(g.z)),g.z,zwant*.01)

bbr1=interpolate(br,ix2,iy2)
bps1=interpolate(g.psirz,ix2,iy2)
bbz1=interpolate(bz,ix2,iy2)
bbt1=interpolate(bt,ix2,iy2)



;plot,rwant,angexpwant,psym=4
for ii=0,nz-1 do begin
;yr=[-7,7];[-12,12]
yr=[-12,12]
postmp=posarr(/next)
;postmp=posarr(2,1,0,cnx=0.1,cny=0.1)

;erase
;mkfig,'~/fig1q.eps',xsize=10,ysize=7.5,font_size=9
plot,r1,interpolate(angexp,indgen(n_elements(r1)),(iy(ii*ngam1))*replicate(1,n_elements(r1))),yr=yr,$
  xtitle='R (cm)',ytitle='Pol. Angle (deg)',title=string(p.sh,tw,m.plasma/1e3 ,m.cpasma/1e3,format='("#",I0," @t=",G0,"s,Im=",I0,",Ic=",I0)'),pos=postmp,/noer,ysty=1,nodata=zwant1(ii) ne 0

if zwant1(ii) eq 0 then oplot,r1,interpolate(ang2,indgen(n_elements(r1)),iy(ii*ngam1)*replicate(1,n_elements(r1))),col=4
legend,['MSE measurement','EFIT calculation'],col=[1,4],/right,box=0,textcol=[1,4],/bottom
if istag(m,'rrgam') then begin

   default,inperr,0.
   idx=indgen(ngam1) + ii*ngam1
   inperrtmp=inperr
   if n_elements(inperr) ne 1 then inperrtmp=inperr(idx)
   oplot,m.rrgam(idx)*100,atan(m.tangam(idx))*!radeg-inperrtmp,psym=4
;   oplot,m.rrgam(idx)*100,atan(m.cmgam(idx))*!radeg,psym=4,col=2
   blueinterpol=angcalcwant(idx)
;   oplot,m.rrgam*100,blueinterpol,psym=4,col=4
   oplot,rwant1,blueinterpol,psym=4,col=4
;   stop
   dif=(atan(m.cmgam(idx))*!radeg-blueinterpol)
;   oplot,m.rrgam(idx)*100,dif*10,col=5
   realdif=atan(m.tangam(idx))*!radeg-inperr - blueinterpol
;   oplot,m.rrgam(idx)*100,realdif*10,col=6
endif
endfor

if istag(m,'rrgam') then begin
   idx=indgen(ngam) 
   blueinterpol=angcalcwant(idx)
   dif=(atan(m.cmgam(idx))*!radeg-blueinterpol)
   nn=n_elements(m.rrgam(idx))
   fmts='("inperr=[",'+string(nn-1,format='(I0)')+'(F5.2,","),F5.2,"]")'
   idx=where(finite(dif) eq 0)
   dif2=dif
   if idx(0) ne -1 then begin
      i1=where(finite(dif) eq 1)
      mm=median(dif(i1))
      dif2(idx)=mm
   endif
   print,dif2,format=fmts
   
endif
;endfig,/gs,/jp
;stop
!p.thick=1

plot,g.qpsi,pos=posarr(/next),/noer,ysty=8
plot,g.pres,pos=posarr(/curr),/noer,col=2,xsty=4,ysty=4
axis,!x.crange(1),!y.crange(0),yaxis=1,col=2

checkgreen=1
if checkgreen eq 1 then begin
   
   bbr2=fltarr(128) & bbz2 = bbr2 & bbt2=bbr2 & cm22=bbr2
   openr,lun,'~/ikstar/my2/EXP0'+string(sh,format='(I0)')+'_k/bdat.txt',/get_lun
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
      cm22(cnt)=spl(2)
      cnt=cnt+1
      if cnt eq 128 then break
   endwhile
   close,lun & free_lun,lun
   bbz2=bbz2(0:ngam-1)
   bbr2=bbr2(0:ngam-1)
   bbt2=bbt2(0:ngam-1)
   cm22=cm22(0:ngam-1)
   bbt1*=-1

   idx=indgen(ngam) 
   cm1= m.a1gam(idx) * bbz1 / $  
       (m.a2gam(idx) * bbt1 + m.a3gam(idx) * bbr1 + m.a4gam(idx) * bbz1)
       
   cm2= m.a1gam(idx) * bbz2 / $  
       (m.a2gam(idx) * bbt2 + m.a3gam(idx) * bbr2 + m.a4gam(idx) * bbz2)
       

endif
scdump,fil='~/eimg_'+fspec+'.png',/png,/norev

print,'rax=',g.rmaxis
end

