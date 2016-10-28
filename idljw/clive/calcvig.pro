
setenv,'mse_path='+getenv('HOME')+'/rsphy/kstartestimages'
d0=getimg(153,index=0,pre='run') ; 135mm lens on sensicam? with 105mm lens pco edge 2x binning, i think..

d=float(d0) / 55000.


sz=size(d,/dim)
x=findgen(sz(0))
theta = (x - sz(0)/2) * 6.5e-3 * 2 / 105. * !radeg

plot,theta,d(*,550)
oplot,theta,vigfunc(theta),col=2


;fitfun = 
y=findgen(sz(1))
thetay = (y - sz(1)/2) * 6.5e-3 * 2 / 105. * !radeg

plot,thetay,d(700,*)
oplot,thetay,vigfunc(thetay),col=2

setenv,'mse_path='+getenv('HOME')+'/prlpro/res_jh/mse_data'

d0=getimg(7865,index=120)&imgplot,d0,zr=[300,1000],/cb  
end




