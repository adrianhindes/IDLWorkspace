@~/ems2/common/loadte


pro cuf,pre,ext,dat
shot=23476
path='/fuslwv/scratch/cmichael/mc3_tmp/23476b/'
path2='/fuslwv/scratch/cmichael/mc3_tmp/23476c4/'

r=readuf(pre,ext,shot,dir=path)
;writeuf,pre,ext,shot,r.machine,r.pcode,r.sdate,xlab=r.xlab,ylab='sqrt(psipoloidaln)',xval=dat.t,yval=dat.x,fval=transpose(dat.z),flab=r.flab,comments=r.comments,dir=path2
print,'flab=',r.flab
print,'fvalt=0.2',r.f(value_locate(r.x,0.2),0), dat.z(0,value_locate(dat.t,0.2))
;if ext eq 'TIRA' then stop
;  PRE             STRING    'F'
;   EXT             STRING    'TERA'
;   SHOT            LONG             23476
;   FILE            STRING    'F23476.TERA'
;   MACHINE         STRING    ' MAS'
;   DIM             BYTE         2
;   FLAG1           FLOAT           0.00000
;   FLAG2           FLOAT           6.00000
;   PCODE           BYTE         0
;   SDATE           STRING    '26-Oct-09 '
;   NSC             INT              0
;   SCVAL           FLOAT     Array[1]
;   SCLAB           STRING    Array[1]
;   XLAB            STRING    'TIME                 SECS     '
;   NX              LONG                78
;   X               FLOAT     Array[78]
;   YLAB            STRING    'r/a                           '
;   NY              LONG              1000
;   Y               FLOAT     Array[1000]
;   ZLAB            STRING    ''
;   NZ              INT              0
;   Z               FLOAT     Array[1]
;   FLAB            STRING    'ELECTRON TEMPERATURE eV       '
;   NF              LONG             78000
;   F               FLOAT     Array[78, 1000]
;   COMMENTS        STRING    'NONE'
;   ERROR           INT              0

end

pro mcontour, z, r, t, xrange=xrange,map=map,_extra=_extra
;contourn2,z,r,t,_extra=_extra

nt=n_elements(t)
npsin=40
psin=linspace(0,1,npsin)
z2=fltarr(npsin,nt)

nrj=n_elements(map.r)
psinmp2=fltarr(nrj,nt)

for i=0,nrj-1 do psinmp2(i,*)=interpol(map.psin(i,*),map.t,t)

nr=n_elements(r)
for i=0,nt-1 do begin
    dum=min(psinmp2(*,i),iax) & rax=map.r(iax)
    idx = where(map.r ge rax)
    if idx(0) ne -1 then if n_elements(idx) gt 1 then begin
        rw=interpol(map.r(idx),psinmp2(idx,i),psin)
        z2(*,i)=interpol(z(*,i),r,rw)
    endif
endfor
contour,z2,sqrt(psin),t,_extra=_extra

;stop
end


pro mcontourn2, z, r, t, xrange=xrange,map=map,xtitle=xtitle,_extra=_extra,omap=mapo,dostop=dostop,nopl=nopl
;contourn2,z,r,t,_extra=_extra

nt=n_elements(t)
npsin=40
psin=linspace(0,1,npsin)
z2=fltarr(npsin,nt)

nrj=n_elements(map.r)
psinmp2=fltarr(nrj,nt)

for i=0,nrj-1 do psinmp2(i,*)=interpol(map.psin(i,*),map.t,t)

nr=n_elements(r)
for i=0,nt-1 do begin
    dum=min(psinmp2(*,i),iax) & rax=map.r(iax)
    idx = where(map.r ge rax)
    if idx(0) ne -1 then if n_elements(idx) gt 1 then begin
        rw=interpolo(map.r(idx),psinmp2(idx,i),psin)
        z2(*,i)=interpol(z(*,i),r,rw)
    endif
endfor
;stop
xt=textoidl('\psi_n^{1/2}')
if not keyword_set(nopl) then contourn2,z2,sqrt(psin),t,xtitle=xt,_extra=_extra
mapo={z:z2,x:sqrt(psin),t:t}

if keyword_set(dostop) then stop    

;    psi1=fltarr(nr)
;    psi1(idx)=interpol(psinmp(iout:*),rj(iout:*),r(idx))
    
    
    


end

pro corrnan, z
nt=n_elements(z(0,*))
nch=n_elements(z(*,0))
z2=z & z2(*)=0.
zt=total(z,1)
idx=where(finite(zt))
nidxnew=idx(n_elements(idx)-1) - idx(0)
idxnew=idx(0) + lindgen(nidxnew)
for i=0,nch-1 do begin
    z2(i,idxnew)=interpol(z(i,idx),idx,idxnew)
endfor
z=z2
end



pro getcx,sh,qty,z,r,t,zg,nsm=nsm,tsm=tsm

;qty='velocity'
;qty='temperature' 

;fname=string('/home/mast_cx/rerun/act',sh/100,sh mod 100,format='(A,I4.4,".",I2.2)')


if qty eq 'cdens' then nd='acd_ss_tresrw_c6dns' else nd='act_ss_'+qty
d=read_data(sh,nd,filename=fname)


t=d.taxis.vector
r=d.xaxis.vector
z=reform(d.data)
corrnan,z


if sh eq 23476 then begin
    nt=n_elements(t)
    iw=indgen(nt)
    iiw=where(iw lt 69 or iw gt 72)
    iw=iw(iiw)
    t=t(iw)
    z=(reform(d.data))(*,iw)
endif
nt=n_elements(t)

if keyword_set(nsm) then begin
    z=smooth(z,[nsm,1])
    print, 'smoothd cx by ',nsm
endif

if keyword_set(tsm) then begin
    dt=t(1)-t(0)
    nt2=fix((max(t)-min(t))/dt) + 1
    t2=linspace(min(t),max(t),nt2)
    nr=n_elements(r)
    z2=fltarr(nr,nt2)
    for i=0,nr-1 do z2(i,*)=interpolo(z(i,*),t,t2)
    nsmt=fix(tsm/dt)
    print,'smoothing cx in time by',nsmt
    for i=0,nr-1 do z2(i,*)=smooth(z2(i,*),nsmt)
    t=t2
    z=z2
endif

zg=z
for i=0,nt-1 do zg(*,i)=deriv(r,z(*,i))
end


pro analqtff,sh,suff,old=old,nsmcx=nsmcx,nsmthom=nsmthom,tsmcx=tsmcx,tsmthom=tsmthom,nocalib=nocalib,tw=tw,n1=n1,n2=n2;fil,,,

;print,nsmcx,nsmthom
;retall
fil=string(sh,suff,format='(I0,A,"/efitOut.hdf5")')
if keyword_set(old) then char='' else char='2'
fil='/home/cmichael/ems'+char+'/res/'+fil
d=h5_parse(fil,/read)
i=d.equilibrium.input.constraints
o=d.equilibrium.output.fitdetails
mso_csq=o.mse.chisquaredvalues._data

q=d.equilibrium.output.fluxfunctionprofiles.q._data
nq=n_elements(q(*,0))
psin=linspace(0,1,nq)
t=d.equilibrium.header.times._data & nt=n_elements(t)
qrad=sqrt(psin)

psi=(d.equilibrium.output.profiles2D.poloidalflux._data)
rj=d.equilibrium.output.profiles2D.rVector._data
zj=d.equilibrium.output.profiles2D.zVector._data

pax=d.equilibrium.output.globalParameters.psiAxis._data
ped=d.equilibrium.output.globalParameters.psiBoundary._data

q2=fltarr(n_elements(rj),nt)
psinmp=fltarr(n_elements(rj),nt)
qg=q2
qrad=rj
iz=value_locate(zj,0)
for i=0,nt-1 do begin
    psin2=(transpose(psi(*,*,i))-pax(i))/(ped(i)-pax(i))
    qful=interpol(q(*,i),psin,psin2)
    qgful=interpol(deriv(psin,q(*,i)),psin,psin2)
    qgful = qgful / qful * psin2 * 2 ; 2 to make to sqrt(psin)
    
    isub=where(psin2 gt 1)
    if isub(0) ne -1 then qgful(isub) = 0.
    q2(*,i)=qful(*,iz)
    psinmp(*,i)=psin2(*,iz)
    qg(*,i)=qgful(*,iz)
endfor
q=q2
if sh eq 23476 and suff eq 'd' then begin
    dummy=min(abs(t-0.242),imin)
    iw=indgen(n_elements(t))
    isel=where(setcompl(iw,imin))
    iw=iw(isel)
    t=t(iw)
    psinmp=psinmp(*,iw)
    q=q(*,iw)
    qg=qg(*,iw)
    print, 'got rid of point ',imin
endif



;mkfig,'~/qdat/dggcmp'+string(sh,suff,format='(I0,A)')+'.eps',xsize=28,ysize=19/2,font_size=8
pos=posarr(4,1,0,cny=0.1,msratx=3);,/rev)
erase
levrat=[1,1.33,1.5,1.66,2,2.5,3,4]
map={t:t,r:rj,psin:psinmp}
mcontourn2,q,qrad,t,xtitle=textoidl('R'),ytitle='t (s)',title='q',xr=[.8,1.4],zr=[0,4],/noer,pos=pos,ysty=1,xsty=1,offx=1.,pal=5,/cb,map=map,omap=sq,/nopl

;,lev=levrat
;mcontour,q,qrad,t,lev=levrat,/overplot,c_lab=replicate(1,8),c_col=replicate(3,8),map=map,c_thick=replicate(5,8),c_charsize=1.5
;xp=!x.crange(0)+[0,(!x.crange(1)-!x.crange(0))/20.]
;for i=0,n_elements(t)-1 do $
;  oplot,xp,t(i)*[1,1],col=3,thick=3
;pos=posarr(/next)
yr0=minmax(t)
;mcontourn2,qg,qrad,t,xtitle=textoidl('R'),ytitle='t (s)',/cb,xr=!x.crange,xsty=1,yr=yr0,ysty=1,/noer,pos=pos,zr=[-1,1]*1,pal=-2,title='q/r dq/dr',offx=1.,map=map
;mcontour,qg,qrad,t,lev=[0],/overplot,col=5,thick=2,map=map
;xp=!x.crange(0)+[0,(!x.crange(1)-!x.crange(0))/20.]
;for i=0,n_elements(t)-1 do $
;  oplot,xp,t(i)*[1,1],col=3,thick=3
;pos=posarr(/next)


levrat=[1,1.33,1.5,1.66,2,2.5,3,4,5,6,7,8]
nlev=n_elements(levrat)
getcx,sh,'temperature',xti,xr,xt,xtig,nsm=nsmcx,tsm=tsmcx
tmax=2e3
;if sh ge 22368 and sh le 22877 then tmax=1e3
;if sh eq 22619 then tmax=2e3

;mcontourn2,xti,xr,xt,zr=[0,tmax],yr=!y.crange,ysty=1,pos=pos,/noer,nl=10,xr=!x.crange,xtitle=textoidl('R'),ytitle='t (s)',title='Ti(keV)',map=map,omap=sti
;mcontour,q,qrad,t,lev=levrat,/overplot,c_lab=replicate(1,nlev),c_col=replicate(3,nlev),c_thick=replicate(3,nlev),map=map
;pos=posarr(/next)
faf1=2.;1
rhogyro=1.67e-27*2 * sqrt(2*1.6e-19*xti/1.67e-27/2)/1.6e-19/0.5

titt=textoidl('\rho_s/L_{Ti}')
titv=textoidl('\rho_s/L_{\omega i}')
tittq=textoidl('d \omega / dt')
rhostar=-xtig/xti * rhogyro
;mcontourn2,rhostar,xr,xt,zr=[0,.2],yr=!y.crange,ysty=1,pos=pos,/noer,nl=10,xr=!x.crange,/nonice,/cb,xtitle=textoidl('R'),ytitle='t (s)',title=titt,map=map,pal=-2,offx=1.
;mcontourn2,-xtig/xti,xr,xt,zr=[0,3./.2]*faf1,yr=!y.crange,ysty=1,pos=pos,/noer,nl=10,xr=!x.crange,/nonice,/cb,xtitle=textoidl('R'),ytitle='t (s)',title='1/LTi',/inhibit,map=map

;mcontour,q,qrad,t,lev=levrat,/overplot,c_lab=replicate(1,nlev),c_col=replicate(3,nlev),c_thick=replicate(3,nlev),map=map
;mcontour,qg,qrad,t,lev=[0],/overplot,col=5,thick=2,map=map


;pos=posarr(/next)
getcx,sh,'cdens',xti,xr,xt,xtig,nsm=nsmcx,tsm=tsmcx
ctmax=min([max(xti/1e18),2])
;if sh ge 22368 and sh le 22877 then tmax=1e3
;if sh eq 22619 then tmax=2e3

;mcontourn2,xti/1e18,xr,xt,zr=[0,ctmax],yr=!y.crange,ysty=1,pos=pos,/noer,nl=10,xr=!x.crange,xtitle=textoidl('R'),ytitle='t (s)',title='n_c 1e18m-3',map=map,omap=sti
;mcontour,q,qrad,t,lev=levrat,/overplot,c_lab=replicate(1,nlev),c_col=replicate(3,nlev),c_thick=replicate(3,nlev),map=map
;pos=posarr(/next)
;faf1=2.;1
;mcontourn2,-xtig/xti,xr,xt,zr=[0,3./.2]*faf1,yr=!y.crange,ysty=1,pos=pos,/noer,nl=10,xr=!x.crange,/nonice,/cb,xtitle=textoidl('R'),ytitle='t (s)',title='1/L_nc',/inhibit,map=map,pal=-2
;mcontour,q,qrad,t,lev=levrat,/overplot,c_lab=replicate(1,nlev),c_col=replicate(3,nlev),c_thick=replicate(3,nlev),map=map
;mcontour,qg,qrad,t,lev=[0],/overplot,col=5,thick=2,map=map


;pos=posarr(/next)
getcx,sh,'velocity',xvi,xr,xt,xvig ,nsm=nsmcx,tsm=tsmcx
nvt=n_elements(xt)
for i=0,nvt-1 do xvi(*,i)=xvi(*,i)/xr/2/!pi
; convert to angular vel
mcontourn2,xvi,xr,xt,zr=[0,50e3],yr=!y.crange,ysty=1,pos=pos,/noer,nl=10,xr=!x.crange,xtitle=textoidl('\psi_n^{1/2}'),ytitle='t (s)',title='omi (rad/s)',map=map,omap=somi,/nopl ;,/dostop
somi.z*=2*!pi
;mcontour,q,qrad,t,lev=levrat,/overplot,c_lab=replicate(1,nlev),c_col=replicate(3,nlev),c_thick=replicate(3,nlev),map=map
pos=posarr(/next)

;pos=posarr(/next)
;rhostarv=-xvig/xvi * rhogyro

;mcontourn2,rhostarv,xr,xt,zr=[0,.2],yr=!y.crange,ysty=1,pos=pos,/noer,nl=10,xr=!x.crange,/nonice,/cb,xtitle=textoidl('R'),ytitle='t (s)',title=titv,map=map,pal=-2,offx=1.
;mcontour,q,qrad,t,lev=levrat,/overplot,c_lab=replicate(1,nlev),c_col=replicate(3,nlev),c_thick=replicate(3,nlev),map=map
;mcontour,qg,qrad,t,lev=[0],/overplot,col=5,thick=2,map=map


;pathadd,'~rscann/idl/useful_programs'
;;pathadd,'~rscann/masttm/lib'
;pathadd,'~rscann/edgets'
;pathadd,'~rscann/widget'
;pos=posarr(/next)

;if sh eq 23474 then shte = 23476 else shte=sh
;loadte,shte,mr,mt,mte,nsm=nsmthom,tsm=tsmthom,nocalib=nocalib

;mteg=mte
;for i=0,n_elements(mt)-1 do mteg(*,i)=deriv(mr,mte(*,i))
;mcontourn2,mte,mr,mt,zr=[0,tmax],yr=!y.crange,ysty=1,pos=pos,/noer,nl=10,xr=!x.crange,xtitle=textoidl('R'),ytitle='t (s)',title='Te(keV)',map=map,omap=ste
;mcontour,q,qrad,t,lev=levrat,/overplot,c_lab=replicate(1,nlev),c_col=replicate(3,nlev),c_thick=replicate(3,nlev),map=map;


;pos=posarr(/next)
;mcontourn2,-mteg/mte,mr,mt,zr=[0,3/.2],yr=!y.crange,ysty=1,pos=pos,/noer,nl=10,xr=!x.crange,/nonice,/cb,xtitle=textoidl('R'),ytitle='t (s)',title='1/LTe',/inhibit,map=map
;mcontour,q,qrad,t,lev=levrat,/overplot,c_lab=replicate(1,nlev),c_col=replicate(3,nlev),c_thick=replicate(3,nlev),map=map
;mcontour,qg,qrad,t,lev=[0],/overplot,col=5,thick=2,map=map


;pos=posarr(/next)
shte=sh
loadte,shte,mr,mt,mne,qty='ne',nsm=nsmthom,tsm=tsmthom,nocalib=nocalib & mne/=1e19
;mneg=mne
;for i=0,n_elements(mt)-1 do mneg(*,i)=deriv(mr,mne(*,i))
mcontourn2,mne,mr,mt,zr=[0,10],yr=!y.crange,ysty=1,pos=pos,/noer,nl=10,xr=!x.crange,xtitle=textoidl('R'),ytitle='t (s)',title='ne(1e19)',/cb,offx=1.,map=map,omap=sne,/nopl;,/dostop
;mcontour,q,qrad,t,lev=levrat,/overplot,c_lab=replicate(1,nlev),c_col=replicate(3,nlev),c_thick=replicate(3,nlev),map=map

sne2={z:interpolate(sne.z,indgen(40),interpol(findgen(n_elements(sne.t)),sne.t,somi.t),/grid),t:somi.t,x:sne.x}

dvdt=somi.z
smom={z:somi.z*sne2.z,x:somi.x,t:somi.t}
for i=0,n_elements(somi.x)-1 do dvdt(i,*)=deriv(somi.t,smom.z(i,*))
;endfig,/gs,/jp



;contourn2,dvdt/1e5,somi.x,somi.t,zr=[-1e0,1e0]*200,yr=yr0,ysty=1,pos=pos,/noer,nl=10,xr=[0,1],/nonice,/cb,xtitle=textoidl('\psi_n^{1/2}'),ytitle='t (s)',title=tittq,pal=-2,/box,offx=1.

;mcontour,q,qrad,t,lev=levrat,/overplot,c_lab=replicate(1,nlev),c_col=replicate(3,nlev),c_thick=replicate(3,nlev),map=map,xsty=1,ysty=1,xr=!x.crange,yr=!y.crange
;mcontour,qg,qrad,t,lev=[0],/overplot,col=5,thick=2,map=map

pos=posarr(/next)

radint=dvdt
for i=0,n_elements(somi.t)-1 do radint(*,i)=total(dvdt(*,i)*somi.x,/cum)

;contourn2,radint/1e5,somi.x,somi.t,zr=[-1e0,1e0]*200,yr=yr0,ysty=1,pos=pos,/noer,nl=10,xr=[0,1],/nonice,/cb,xtitle=textoidl('\psi_n^{1/2}'),ytitle='t (s)',title=tittq,pal=-2,/box,offx=1.

pos=posarr(/next)
;mcontourn2,-mneg/mne,mr,mt,zr=[0,3/.2],yr=!y.crange,ysty=1,pos=pos,/noer,nl=10,xr=!x.crange,/nonice,/cb,xtitle=textoidl('R'),ytitle='t (s)',title='1/LNe',/inhibit,map=map
;mcontour,q,qrad,t,lev=levrat,/overplot,c_lab=replicate(1,nlev),c_col=replicate(3,nlev),c_thick=replicate(3,nlev),map=map
;mcontour,qg,qrad,t,lev=[0],/overplot,col=5,thick=2,map=map


;pos=posarr(/next)


dom=read_data(sh,'XMC_OMV/210') ;'XMO_OMAHA/L2C');

tom=dom.taxis.vector
domd=dom.data
fdig=1./(tom(1)-tom(0))
dt=1e-3
df=1e3

fmax=100e3&mult=1
if sh eq 22543 then begin&fmax=200e3&mult=2&end

df=df*mult

spectdata2,domd,psm,tm,f,t0=tom(0),fdig=fdig,dt=dt,df=df

;contourn2,transpose(alog10(psm)),f/1e3,tm,xr=[0,fmax]/1e3,yr=!y.crange,ysty=1,pos=pos,/noer,nl=10,/nonice,/cb,xtitle=textoidl('F(kHz)'),ytitle='t (s)',title='spetrogram',/inhibit,zr=[-7,-2]-2,/rev


mkfig,'~/mlock_'+string(sh,tw,format='(I0,"_",G0)')+'.eps',xsize=20,ysize=8,font_size=8
default,tw,0.21
iw=value_locate(somi.t,tw)
pos=posarr(3,1,0,cnx=0.1,cny=0.1,msratx=4)
default,n1,2
default,n2,1
plot,somi.z(*,iw)/2/!pi * n1/1e3,somi.x,pos=pos,xtitle='Freq (kHz)',ytitle=textoidl('\psi_n^{1/2}'),title='Mode+rotation frequency',ysty=8
xyouts,0.5,0.97,string(sh,tw,format='("#",I0,"@t=",G0,"s")'),ali=0.5,/norm

oplot,somi.z(*,iw)/2/!pi * n2/1e3, somi.x,linesty=1
iw=value_locate(tm,tw)
yr1=minmax(psm(iw,value_locate(f,3e3):value_locate(f,40e3)))
psm(iw,value_locate(f,40e3):*)=!values.f_nan
psm(iw,0:value_locate(f,3e3))=!values.f_nan
plot,f/1e3,psm(iw,*)/yr1(1),xr=!x.crange,xsty=5,ysty=4,col=2,/noer,pos=pos
axis,!x.crange(1),!y.crange(0),ytitle='S(f)(a.u.)',col=2,yaxis=1,yr=[0,1]
legend,textoidl(['n*f_{rot}, n='+string(n1,format='(I0)'),'n*f_{rot}, n='+string(n2,format='(I0)'),'Mirnov spectrum']),col=[1,1,2],textcol=[1,1,2],linesty=[0,1,0],/right,box=0

iw=value_locate(somi.t,tw)
plot,dvdt(*,iw)/1e5,somi.x,/noer,pos=posarr(/next),ytitle=textoidl('\psi_n^{1/2}'),xtitle=textoidl('d \omega / dt (10^5 rad/s)'),title='Location of MHD torque'
oplot,0*[1,1],!y.crange,linesty=2


iw=value_locate(sq.t,tw)
plot,sq.z(*,iw),sq.x,xr=[1,2.5],/noer,pos=posarr(/next),xtitle='q',ytitle=textoidl('\psi_n^{1/2}'),title='Rational & qmin location'
oplot,1.5*[1,1],!y.crange,linesty=2
oplot,1.66*[1,1],!y.crange,linesty=2
oplot,2*[1,1],!y.crange,linesty=2

endfig,/gs,/jp

stop
;,/cb,pos=pos,/noer,$
;  ytitle='F (kHz)',xtitle='t(s)',title='Mirnov spectrogram',/rev
;oplot,t(imin1)*[1,1],!y.crange,linesty=1
;oplot,t(imin2)*[1,1],!y.crange,linesty=1




;fil='~/qdat/'+string(sh,suff,format='(I0,A)')+'.csv'
;tit=['t(s)/sqrt(psinorm)',string(sqrt(psin),format='(G0)')]
;writecsv,t,transpose(q),file=fil,titles=tit

;endfig,/jp;,/gs;,/del

;cuf,'F','QPS',sq
;cuf,'F','TIRA',sti
;cuf,'F','WTRA',somi
;cuf,'F','TERA',ste
;sne.z=sne.z*1e13;tocm-3
;cuf,'F','NERA',sne

;stop
end






;analqtff,23457,'a'

;end

;analqtff,22807,'hi3'
;analqtff,22254,'hi3'
;analqtff,23459,'f';,nsmcx=3,nsmthom=3,tsmcx=0.025,tsmthom=0.025
;analqtff,23476,'f';,nsmcx=3,nsmthom=3,tsmcx=0.025,tsmthom=0.025
;analqtff,23476,'j';,nsmcx=3,nsmthom=3,tsmcx=0.025,tsmthom=0.025
;;;;analqtff,21771,'b';,nsmcx=3,nsmthom=3,tsmcx=0.025,tsmthom=0.025
;analqtff,23474,'f';,nsmcx=3,nsmthom=3,tsmcx=0.025,tsmthom=0.025
;analqtff,22134,'a';,nsmcx=3,nsmthom=3,tsmcx=0.025,tsmthom=0.025
;analqtff,22547,'hi3',/old;,nsmcx=3,nsmthom=3,tsmcx=0.025,tsmthom=0.025
;end

;analqtff,23459,'f',tw=0.255,n1=3,n2=2;0.21
;analqtff,23459,'f',tw=0.22,n1=2,n2=1;0.21
;analqtff,23459,'f',tw=0.24,n1=2,n2=3;0.21
;analqtff,24501,'a',tw=.115,n1=1,n2=1;0.19



end

