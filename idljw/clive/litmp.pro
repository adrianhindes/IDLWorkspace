wpid='disp755'
wpid2='del20bbo'
default,lam,667e-9+linspace(0,2e-9,1000)
default,flencam,85e-3
default,cambin,1

readwp,wpid,tmp
par={crystal:tmp.material,thickness:tmp.thicknessmm*1e-3,facetilt:tmp.facetilt*!dtor,lambda:lam,delta0:0.}
default,th,0
  opd1=opd(th,0,par=par,delta0=0,k0=k,kappa=kappat)/2/!pi & k/=!radeg ;convert k from fringes per radian to fringes per degree


readwp,wpid2,tmp
par={crystal:tmp.material,thickness:tmp.thicknessmm*1e-3,facetilt:tmp.facetilt*!dtor,lambda:lam,delta0:0.}
default,th,0
opd2=opd(th,0,par=par,delta0=0,k0=k2,kappa=kappat2)/2/!pi & k2/=!radeg ;convert k 

opd=opd1-opd2

;         kmult= $; fringes/deg
;            1/!dtor* $; /rad
;            1/(flencam*1e3)* $; per mm on detector
;            6.5e-3*cambin ; per binned pixel;;
;
;if keyword_set(doprint) then begin
;    print,'delay is',opd,'waves'
;    print,'k is',k,' fringes/degree
;    print,'which for on camera with flen=',flencam,' and bin=',cambin
;    print,' is k=',k*kmult,'fringes/pix' 
;endif
;del=opd
;kay=k*kmult
plot,lam,cos(opd*2*!pi)

l0=668e-9
l1=l0+0.2e-9
wid=0.02e-9
spec=exp(-(lam-l0)^2/wid^2) + exp(-(lam-l1)^2/wid^2) 
oplot,lam,spec,col=2

end

