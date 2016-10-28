pro quickdelof,wpid,lam=lam,del=del,kay=kay,doprint=doprint,flencam=flencam,cambin=cambin,th=th
default,lam,529e-9
default,flencam,50e-3
default,cambin,1

readwp,wpid,tmp
par={crystal:tmp.material,thickness:tmp.thicknessmm*1e-3,facetilt:tmp.facetilt*!dtor,lambda:lam,delta0:0.}
default,th,0
  opd=opd(th,0,par=par,delta0=0,k0=k,kappa=kappat)/2/!pi & k/=!radeg ;convert k from fringes per radian to fringes per degree


         kmult= $; fringes/deg
            1/!dtor* $; /rad
            1/(flencam*1e3)* $; per mm on detector
            6.5e-3*cambin ; per binned pixel

if keyword_set(doprint) then begin
    print,'delay is',opd,'waves'
    print,'k is',k,' fringes/degree
    print,'which for on camera with flen=',flencam,' and bin=',cambin
    print,' is k=',k*kmult,'fringes/pix' 
endif
del=opd
kay=k*kmult
end

