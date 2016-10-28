

pro wbsp4, l0,sh,shcorr=shcorr,doresid=doresid,dohe=dohe,fout=fout
;l0=488.
;9=660nm ar line
;10=black
;11=ar lamp
;12=black
;for the above, 2 5mm plates with 50mm lens

;then shots13-14,15-16 are with fw savart [ahwp in it]


;1718 white light no filt
;1920 spectral lamp filt ;[nb adjusted then...]
;2122 white light filt
;2324 spectral lamp no filt
;2526 white lamp no filt...
;; all above were for pols at 45 not 22.5 deg, redo

;2728 laser
;2930 spec lamp w/filt (re-adjusted)
;3132 laser (not readjusted)
;3334 spec lamp no filtt=0;0
;3536 white light no filt
;3738 whisxrt elight filt
;39 helium lamp?

; new setup, fiddling around
;45/46, 47/48 -- before stabilization of temperature
;49 - 514.53 [think, could be 514.17]
;51 - 487.78
;53 - 458.98 (bluest)
;55 - 1 up [465.79]
;57 - 2 up [476.48]
;59 - between 488 and 514 [496.5]
;61 - ar lamp
;63 - he lamp
;65 - white light
;shcorr=51;29;31;27;9
default,shcorr,95;sh;95;85
;sh=49&l0=514. ? 2 l
;sh=51 &l0=488.
;sh=53 & l0=459
;sh=55 & l0=465
;sh=57 & l0=476.48
;sh=59 & l0=496
;
;sh=63 & l0=500
;sh=65 & l0=700

; again, Wedneseay 9th April
;67 ; 459
;69
;71 ; 476 clipped
;73;488
;75;496
;77;501.4
;79 514
;81 514 repeat
;removed 2mm from back side
;83/ 1st
;85 wait little
;87 little more (all 514
;sh=87 & l0=514.

;ok lamnda scan
;87  ?
;89  .. 459 1
;91  .. 465 1
;93  .. 475 1
;95  .. 488 1
;97  .. 496 mostly 1 poss 2
;99  .. 501 1
;101 .. 514 ? 2l

;63;51;49;47;23;39;39;39;31;27;31;29;9;35;39;35;39;29;35;29;29

; wednesday 7th may
; initially just repeat measurement, but nb-> haven't switched
; on thermal stabilisation

;105 459
;107 465
;109 475
;111 488
;113 496
;115 501
;117 514


;119 465
;121 459-->nb reversed
;123 475
;125 488
;127 496
;129 501
;131 514

savenfact=0;1
restnfact=0;0
saveaval=1
restaval=0
avmax=1
doskip=0
wintype='hanning';hanning'
;wrng=(580+[-30,30])*1e-9
;wrng=(670+[-30,30])*1e-9
;wrng=(660+[-10,10])*1e-9
;wrng=(474+[-10,10])*1e-9
;l0=514
;l0=705.
;l0=728.
;wrng=(l0+[-10,10])*1e-9
;!x.range=wrng
wrng=[0,1e9]

;lrng=[650e-9,670e-9]
;lrng=[500e-9,560e-9]
;lrng=[520e-9,540e-9]
;lrng=727e-9 + 10e-9 * [-1,1]


;lrng=[660,740]*1e-9
;nlam=120*1+1
;nlcalc=13

;lrng=[580,740]*1e-9
;nlam=160*5+1
;nlcalc=17;13


if keyword_set(dohe) then begin
lrng=[450,550]*1e-9 ;+ 200e-9
nlam=401;201
nlcalc=11
endif else begin

lrng=(l0+[-10,10])*1e-9
nlcalc=6
nlam=20*10+1

;lrng=(l0+[-10,10]/4.)*1e-9
;nlcalc=6
;nlam=20*10/4+1 ;; this one

endelse

;lrng=659.8e-9*[1,1]
;lrng=650e-9*[1,1]
;nlcalc=11;6
;nlam=201
;nlam=41;201

;lrng=[560e-9,700e-9]&nlcalc=11&nlam=261
;lrng=wrng&nlcalc=11& nlam=61;181
;lrng=[560e-9,620e-9]&nlcalc=3&nlam=61

;lrng=[400e-9,700e-9]&nlcalc=16&nlam=151
;

shz=sh+1
db='wb'

d=getimgnew(sh,0,db=db,str=p);&s=fft(d,/center)  
d0=getimgnew(shz,0,db=db)
;stop
d=d*1.-d0*1.
d=d>0

;stop



readcell,p.cellno,str
readancal,shcorr,xcorr
;stop
;xcorr*=0.;0001
str2=str
;xcorr(4:5)=[-0.02,-0.2+12e-3]
xcorr2=xcorr

sd=1
dif=0.02*[1,0];(randomu(sd,2)-0.5) *2
;xcorr2(4:5)+=dif

applycal_wb1,str,xcorr,/dodel;,/test1
applycal_wb1,str2,xcorr2,/dodel;,/test1
default,doresid,0
if doresid eq 1 then $
   hdfrestoreext,'/home/cam112/idl/clive/settings/res'+string(sh,format='(I0)')+'.hdf',resid
;stop

svec0=[1,.5,.5,0.]
;l00=659.8e-9
nlsim=0
goto,nosim
nlsim=1
;lsimrng=[640e-9,660e-9] ;650e-9*[1,1];
;lsimarr=linspace(lsimrng(0),lsimrng(1),nlsim)
lsimarr=[l0*1e-9]
for i=0,nlsim-1 do begin
   l00=lsimarr(i)               ;650e-9;670e-9
   simimgnew,dtmp,sh=sh,db=db,lam=l00,svec=svec0,str=str2,p=p,/noload ;,/angdeptilt
   if i eq 0 then d=dtmp else d=d+dtmp
   print,i,nlsim,'____'
endfor
nosim:

;imgplot,d,/cb

;newdemod,d,sh=sh,db=db,/doplot,ordermag=6

;stop
imsz=[(p.roir-p.roil+1),(p.roit-p.roib+1)]/[p.binx,p.biny]
i0=(getcamdims(p)/[p.binx,p.biny]) / 2.
ixo=(findgen(imsz(0))+p.roil-1 - i0(0))
iyo=(findgen(imsz(1))+p.roib-1 - i0(1))
iw=[value_locate(ixo,0),value_locate(iyo,0)]
x1=ixo*p.binx * p.pixsizemm;6.5e-3
y1=iyo*p.biny * p.pixsizemm;6.5e-3
x2 = x1 # replicate(1,imsz(1))
y2 = replicate(1,imsz(0)) # y1
thx2=x2/p.flencam
thy2=y2/p.flencam
nx=imsz(0) & ny=imsz(1)

;pix=6.5e-6*2
;flen=50e-3
;nx=2560/2
;ny=2160/2
;thx=linspace(-nx/2*pix/flen,nx/2*pix/flen,nx)
;thy=linspace(-ny/2*pix/flen,ny/2*pix/flen,ny)
;thx2=thx # replicate(1,ny)
;;thy2=replicate(1,nx) # thy

thv=fltarr(nx,ny,2) & thv(*,*,0)=thx2 & thv(*,*,1)=thy2


larr=linspace(lrng(0),lrng(1),nlam)
karr=1/larr
;kcalcarr=linspace(1/lrng(0),1/lrng(1),nlcalc)
;lcalcarr=1/kcalcarr
lcalcarr=linspace(lrng(0),lrng(1),nlcalc)
kcalcarr=1/lcalcarr
if doskip eq 1 then goto,af2
;if n_elements(kzvcalcarr) ne 0 then goto,aff
kzvcalcarr=fltarr(nx,ny,5,nlcalc)
scar=fltarr(5)
for il=0,nlcalc-1 do begin
   gencarriers2,th=[0,0],kx=kx1,ky=ky1,kz=kz1,sh=sh,db=db,vth=thv,vkzv=kzv,lam=lcalcarr(il),dmat=a2,/noload,str=str,p=p
;   stop
   if il eq 0 then begin
      scar=a2 ## svec0
   endif
   kzvcalcarr(*,*,*,il)=kzv

goto,x
   ns=11
   ck=fltarr(ns,ns)+1./ns^2
   ds=convol(d,ck)
   dd=d-ds
   idd=where(ds eq 0) & dd(idd)=0.
   ind=[300,400,0,100]
   ind=[0,nx-1,0,ny-1]
   imgplot,dd(ind(0):ind(1),ind(2):ind(3));,pos=posarr(2,1,0)
   contour,kzv(ind(0):ind(1),ind(2):ind(3),4),lev=[0],/noer,thick=2;,pos=posarr(/curr)
   contour,kzv(ind(0):ind(1),ind(2):ind(3),3),lev=[0],/noer,thick=2;,pos=posarr(/curr)

;   imgplot,cos(2*!pi*kzv(ind(0):ind(1),ind(2):ind(3),4)),pos=posarr(/next),/cb,/noer,title=lcalcarr(il)*1e9
;   contour,kzv(300:400,0:100,4),lev=[0],/noer,pos=posarr(/curr),thick=5
;   contour,kzv(*,*,3),lev=[0],/noer
   eikonal=exp(2*!pi*complex(0,1)*kzv(*,*,4))

   pp=total(d*eikonal*win)
   print,atan2(pp)*!radeg,abs(pp),lcalcarr(il)*1e9
   stop

x:
endfor
aff:
;stop

ncar=4
prod=complexarr(ncar,nlam)
prodref=prod
nwavref=float(prod)
win=hanning(nx,ny);^2
if wintype eq 'square' then win=win*0+1

s1=fltarr(nx,ny) & s2=s1 & s3=s1
for i=0,nx-1 do s1(i,*,*)=i
for i=0,ny-1 do s2(*,i,*)=i

;indgen(nx),indgen(ny),ixl
for il=0,nlam-1 do begin
   ixl=interpol(findgen(nlcalc),kcalcarr,karr(il))

      ixl0=floor(ixl)
      ixl1=ixl0+1
      aixl=ixl-ixl0
      bixl=ixl1-ixl
      if lrng(1) eq lrng(0) then begin
         ixl=0
         ixl0=0
         ixl1=0
         aixl=0
         bixl=1.
      endif
;      print,ixl,ixl0,ixl1,aixl,bixl

      for icar=0,3 do begin
      
      
      car=icar+1
;stop
;      kzv=interpolate(kzvcalcarr(*,*,car,*),s1,s2,s3+ixl)
      kzv=kzvcalcarr(*,*,car,ixl0) * bixl 
      if aixl ne 0 then kzv+= kzvcalcarr(*,*,car,ixl1)*aixl

;      kzv=fltarr(nx,ny)
;      for i=0,nx-1 do for j=0,ny-1 do
;      kzv(i,j)=interpol(kzvcalcarr(i,j,car,*),lcalcarr,larr(il))
;      kzv=kzvcalcarr(*,*,car,ixl)
;      print,'hey',il,icar
      
;      stop
      
      if doresid eq 1 then $
         if nlsim eq 0 then kzv = kzv - resid.(icar)*(1)
      eikonal=exp(2*!pi*complex(0,1)*kzv)
      eikonalref=exp(2*!pi*complex(0,1)*kzv(nx/2,ny/2))
      if doresid eq 1 then begin
         idx=where(finite(resid.(icar) eq 0))
         magamp = resid.zeta(*,*,icar)/resid.amp(icar) * resid.inten/max(resid.inten(where(finite(resid.inten) eq 1)))
         idx=where(finite(1/magamp) eq 0 or finite(resid.(icar)) eq 0)

         if nlsim eq 0 then eikonal = eikonal / magamp
         eikonal(idx)=0.        ; no contrib
      endif
      prod(icar,il)=total(eikonal*d*win)
      prodref(icar,il)=eikonalref
      nwavref(icar,il)=kzv(nx/2,ny/2)
;      stop
   endfor
 ;  print,nwavref(0,il)+nwavref(2,il), nwavref(3,il)
  ; print,nwavref(2,il)-nwavref(0,il), nwavref(1,il)
;   stop
print,il,nlam
endfor

af2:
prod2=prod
nfact=complexarr(ncar)
lmax=fltarr(ncar)
nwavmax=lmax

nfact0= scar(1:4)/abs(scar(1:4)) ;* (-1.)

restore,file='~/c_analysed.sav',/verb;parsave
corr_model=fltarr(ncar,nlam)
for i=0,ncar-1 do begin
   corr_model(i,*) = parsave(0,i) + parsave(1,i) * nwavref(i,*)
endfor
nwav_model=nwavref - corr_model
for i=0,3 do begin
   ord=round(corr_model(i,nlam/2))
   corr_model(i,*)-=ord
endfor

proda_model=exp(complex(0,1)*2*!pi*(-corr_model))

dprod=prod/prodref

prodb_model=proda_model * prod


for i=0,ncar-1 do begin
   idx=where(larr ge wrng(0) and larr le wrng(1))
   dum=max(abs(prod(i,idx)),imax) 
   nfact(i)=prod(i,idx(imax))/nfact0(i)
   lmax(i)=larr(idx(imax))
   nwavmax(i)=nwavref(i,idx(imax))
endfor
lmaxorig=lmax


if not keyword_set(dohe) then lmax(*)=l0*1e-9 ; this one

if avmax eq 1 then begin
   lmaxmn=lmax(0) ; mean(lmax)
   iw=value_locate3(larr,lmaxmn)
   lmax2=lmax*0+larr(iw)
   
   nwavmax_model=nwav_model(*,iw)
   for i=0,ncar-1 do begin
      nfact(i)=prod(i,iw)/nfact0(i)
      nwavmax(i)=nwavref(i,iw)
   endfor
endif else lmax2=lmax


aval=abs(prodb_model(*,iw)) * fsign(float(prodb_model(*,iw))) * (1.)



nfactwav=atan2(nfact)/(2*!pi)

if savenfact eq 1 then begin
   save,nfact,file='~/nfact.sav',/verb
endif

if restnfact eq 1 then begin
   nfacto=nfact
   restore,file='~/nfact.sav',/verb
   nfact = nfact/max(abs(nfact)) * max(abs(nfacto))
endif


if saveaval eq 1 then begin
   save,aval,file='~/aval.sav',/verb
endif

if restaval eq 1 then begin
   nfacto=nfact
   restore,file='~/aval.sav',/verb
endif


prodc_model = prodb_model*0
for i=0,3 do prodc_model(i,*)=prodb_model(i,*) / aval(i)

prodc_modelsum=total(prodc_model,1)/4.


for i=0,ncar-1 do begin
   prod2(i,*)=prod(i,*)/(nfact(i)*nfact0(i))
endfor




prod3=total(prod2,1)/4.
;xr=lmax+([-2,2])*1e-9
;xr=475e-9+([-2,2])*2e-9
if n_elements(xr) gt 0 then dum=temporary(xr)
;delvar,xr
if  keyword_set(dohe) then pos=posarr(3,2,0)
plotm,larr,transpose(abs(prod2)),pos=pos,xr=xr
oplot,larr,abs(prod3),thick=3
oplot,l0*1e-9*[1,1],!y.crange,linesty=2,col=2

if not keyword_set(dohe) then goto,eg
plotm,larr,transpose(abs(prod2)),pos=posarr(/next),/noer,xr=xr
oplot,larr,abs(prodc_modelsum),thick=3,col=5

; retall
 plotm,larr,transpose(atan2(prod2)),pos=posarr(/next),/noer,xr=xr
 plotm,larr,transpose(atan2(prodc_model)),pos=posarr(/next),/noer,xr=xr
 plotm,larr,transpose(corr_model)*2*!pi,pos=posarr(/next),/noer,xr=xr
eg:
;nwavref2=nwavref
;for i=0,3 do nwavref2(i,*)-=nwavref(i,0)
;plotm,larr,abs(transpose(nwavref2)),pos=posarr(/next),/noer

;; plotm,larr,transpose(abs(prodc_model)),pos=posarr(/next),/noer
;; oplot,larr,abs(prodc_modelsum),thick=3

;plotm,larr, transpose(atan2(prod_model)),pos=posarr(/next),/noer

;print,atan2(prod2(*,20))*!radeg
;print,atan2(prod2(*,40))*!radeg

dnwavmax=nwavmax-round(nwavmax)

dd=nfactwav-dnwavmax
rdd=dd-round(dd)
;print,lmax

openw,lun,'~/tmp.txt',/get_lun

printf,lun,lmax2
printf,lun,nwavmax
printf,lun,dnwavmax;floor(nwavmax)
printf,lun,nfactwav
;print,dd
printf,lun,rdd
close,lun & free_lun,lun
spawn,'cat ~/tmp.txt'
if not keyword_set(dohe) then spawn,'cat ~/tmp.txt >> '+fout;~/p2.txt' ;; this one
print,'___'
stop
if not keyword_set(dohe) then return ;; this one

print,'ref       ',(atan2(prod(*,iw))/2/!pi) 
print,'corr model',(corr_model(*,iw))

;print,atan2(dprod(*,iw))/2/!pi ,'ref'
;print,nwav_model(*,iw)-round(nwav_model(*,iw)),'nwavmodel'
print,'proda     ',(atan2(proda_model(*,iw))/2/!pi)
print,'prodc     ',(atan2(prodc_model(*,iw))/2/!pi)
print,'prodc abs ',(abs(prodc_model(*,iw)))



;print,'--'
;print,nfactwav
;print,nwavmax_model-round(nwavmax_model)


stop




;plotm,larr,transpose(abs(prod))
;stop

;plot,larr,atan2(prod(3,*))*!radeg
;print,(atan2(prod(3,nlam-1))-atan2(prod(3,0)))*!radeg
;stop
;plot,larr,abs(prod3),/noer,thick=3



stop
stop
if sh eq 33 then begin
   dat=(read_ascii('/data/kstar/misc/wbtest1/Ar_lamp_spec.txt',data_start=12)).(0)
   dlam=reform(dat(0,*))*1e-9
   ddat=reform(dat(2,*))
oplot,dlam,ddat/max(ddat) * max(abs(prod3)),col=6,thick=3
endif

if sh eq 39 then begin
   el='He'
   read_spe,'~/spectrum/'+el+' lamp.spe',l,t,daa,str=str
   ds=total(daa(*,512-50:512+50),2)
   dlam=l*1e-9
   ddat=ds
   read_nist,lam,inten,nam=el+'_I'
   lam*=1e-9
   linten=alog10(inten)
   linten-=min(linten(where(finite(linten))))
   oplot,dlam,ddat/max(ddat) * max(abs(prod3)),col=6,thick=3
   oplot,lam,linten/max(linten)*max(abs(prod3)),col=7,psym=5,thick=3
   stop
endif

   

;newdemod,d,sh=sh,db=db,/doplot

end

;wbsp4, 500., 193,shcorr=185

wbsp4, 500., 211,shcorr=203,/dohe

end

