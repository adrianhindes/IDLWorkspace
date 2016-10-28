;pro loaddata,file=file
;
;common cngrid,rhogrid3,rcthgrid3,rsthgrid3,rout,zout,phiarr,r1,z1,rho1,theta1,file1
;
;
;default,file,'boozmn_wout_kh0.850-kv1.000fixed.nc'
;fn='/home/cmichael/idl/'+file+'.sav'
;restore,file=fn
;file1=file
;end





loaddata
common cngrid,rhogrid3,rcthgrid3,rsthgrid3,rout,zout,phiarr,r1,z1,rho1,theta1,file1

window, 1, xsize = 1800, ysize =900
contour,sqrt(rhogrid3(*,*,1)),rout*1e3,zout*1e3,/iso,xr=[1000,1400],yr=[-200,200],pos=posarr(2,1,0),lev=linspace(0,.98,5)

nrho=1
;rhosel1=[.56,.61,.66,.71,.76] ; for 240/250
rhosel1=[.7]-0.01 ; for 240/250

;nrho=6
;rhosel1=[.51,.56,.61,.66,.71,.76] ; for 240/250

;nrho=1
;rhosel1=[.51]

;nrho=3
;rhosel1=[.56,.66,.76] ; for 240/250
rhosel=rhosel1^2

;rhosel=[.46^2,.56^2,.66^2] ; for 240/250

;rhosel=.76^2 ; for 260
np=5000
span=90.
start=-50*!dtor
th0 = 7.2*!dtor * (7./5.) +start; approx for transform of 7/5.

mb_flux2cart,rhosel,0*rhosel,rb,zb,phi=0*!dtor
;plots,rb,zb,psym=4
;fppos3,250-10,0,rbpp,zbpp
xbpp=250
rbpp=1112+xbpp-45
zbpp = 0
plots, rbpp, zbpp, psym=4

stop

sh = [87842, 87846];, 87860, 87884]
;sh = [87842, 87846, 87860, 87884]+1
;sh=intspace(87837,87886)
sh=long(sh)

nsh=n_elements(sh)
coh=complexarr(nsh)
frng=[100e3,200e3]

rad=fltarr(nsh)
th=fltarr(nsh)

for i=0,nsh-1 do begin
   mdsopen,'h1data',sh(i)
   rad(i)=mdsvalue('\H1DATA::TOP.FLUCTUATIONS.FORK_PROBE:STEPPERXPOS')
   th(i)=mdsvalue('\H1DATA::TOP.FLUCTUATIONS.FORK_PROBE:STEPPERYPOS')
 
;   doit,sh(i),frng=frng,coh1=coh1dum,tr=tr,mode=mode;,/tunetime
;continue
;coh1dum= getpar( sh(i), 'isatfork', tw=[.03,.04],y=y,st=st)
;coh1dum= getpar( sh(i), 'vfloatfork', tw=[.03,.04],y=y,st=st)
;   coh(i)=coh1dum
endfor

r=fltarr(nsh)
z=fltarr(nsh)
for i=0,nsh-1 do begin
   fppos3,rad(i)-10,th(i),rdum,zdum
   r(i)=rdum & z(i)=zdum
endfor
radx=rad
thx=th

db=rb-(1112-44.)

contour,sqrt(rhogrid3(*,*,2)),rout*1e3,zout*1e3,/iso,xr=[1000,1400],yr=[-100,300],/noer,pos=posarr(/next),lev=linspace(0,.98,5)
plots,r,z,psym=4

window, /free, xsize = 900, ysize =900
contour,sqrt(rhogrid3(*,*,2)),rout*1e3,zout*1e3,/iso,xr=[1000,1400],yr=[-100,300],/noer,lev=linspace(0,.98,5)
plots,r,z,psym=4
stop

;;note that in martijns program I was using the subtraction for droop:
;th=float(th(idx)) -0.7
rhosel2=rhosel # replicate(1,np)
thsel1=linspace(th0,th0+span*!dtor,np)
thsel2=replicate(1,nrho) # thsel1

mb_flux2cart,rhosel2,thsel2,r,z,phi=7.2*!dtor
;oplot,r,z,psym=4
fppos3,d,theta,r,z,direction=-1
theta+=0.7 ; for droop

thetaw1=[-2,0,2,4,6,7]
;thetaw1=[8,9] 
 nthetaw1 = n_elements(thetaw1)
thetaw2=replicate(1,nrho) # thetaw1 
d2=fltarr(nrho,nthetaw1)
r2=d2
z2=d2
for i=0,nrho-1 do begin
   d2(i,*)=interpol(d(i,*),theta(i,*),thetaw1)
   r2(i,*)=interpol(r(i,*),theta(i,*),thetaw1)
   z2(i,*)=interpol(z(i,*),theta(i,*),thetaw1)
endfor
oplot,r2,z2,psym=4
stop
ntot=nthetaw1 * nrho
ctheta=fix(reform(thetaw2*10,ntot))/10.
cdee=fix(reform(d2,ntot))
cmd=strarr(ntot)
for i=0,ntot-1 do cmd(i)=string(cdee(i),ctheta(i),format='(I0,",",G0)')
cmd2=cmd
for i=0,ntot-1 do cmd2(i)="'"+cmd(i)+"'"
;print,cmd2,format='("[",'+string(ntot-1,format='(I0)')+'(A,", "),A,"]")

print, 'fork probe psoistion is',d2
print,'ball pen position should be',db
;print,'fork '
;print,'positions / angles'
;print,transpose([[d],[theta]])





end
