@~/idl/clive/vigfunc2
setenv,'mse_path='+getenv('HOME')+'/prlpro/res_jh/mse_data'

d0=getimg(7865,index=120)&imgplot,d0,zr=[300,1000],/cb  
; 135mm f/2 lens on sensicam? with 55mm lens pco edge 1x binning, i think..

d=float(d0-300.) / 2000.>0<1

sz=size(d,/dim)
x=findgen(sz(0))
mid=[0.51,0.47]
theta = (x - sz(0)*mid(0)) * 6.5e-3 * 1 / 55. * !radeg

plot,theta,smooth(d(*,1000),100)*1/0.9
oplot,theta,vigfunc2(theta),col=2
;retall

;fitfun = 
y=findgen(sz(1))
thetay = (y - sz(1)*mid(1)) * 6.5e-3 * 1 / 55. * !radeg

plot,thetay,smooth(d(1400,*),50)/0.9
oplot,thetay,vigfunc2(thetay),col=2
retall
imgplot,d,theta,thetay,zr=[0,.1],/iso
thx2=theta # replicate(1,n_elements(thetay))
thy2=replicate(1,n_elements(theta)) # thetay
th2=sqrt(thx2^2+thy2^2)
contour,vigfunc2(th2),theta,thetay,c_col=replicate(2,10),/iso,/noer

end




