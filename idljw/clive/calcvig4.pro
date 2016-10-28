@~/idl/clive/vigfunc2
;setenv,'mse_path='+getenv('HOME')+'/prlpro/res_jh/mse_data'

;d0=getimg(7350,index=6,/mdsplus,info=info,/getinfo,/flipy)& imgbin=4
d0=getimg(7430,index=71,/mdsplus,info=info,/getinfo,/flipy)& imgbin=2

;imgplot,d0,/cb  
;imgplot,d0,zr=[0,3000]
;retall

; 135mm f/2 lens on sensicam? with 55mm lens pco edge 1x binning, i think..

d=d0/3000.;float(d0-300.) / 1500.>0<1

sz=size(d,/dim)
mid0=[0.51,0.47]*[2560, 2160]
a0=(mid0-[2560/2.,2160/2.]) * 6.5e-3 / 55. 

mid = [0.5,0.5] + (a0 * 50 / (6.5e-3*imgbin)) / sz


;retall




x=findgen(sz(0))


theta = (x - sz(0)*mid(0)) * 6.5e-3 * imgbin / 50. * !radeg

plot,theta,smooth(d(*,sz(1)/2),30)*1/0.9*1/0.7
oplot,theta,vigfunc2(theta),col=2
;retall

;fitfun = 
y=findgen(sz(1))
thetay = (y - sz(1)*mid(1)) * 6.5e-3 * imgbin / 50. * !radeg

plot,thetay,smooth(d(sz(0)/2,*),10)/0.9 * 1/0.7
oplot,thetay,vigfunc2(thetay),col=2
;retall
imgplot,d,theta,thetay,zr=[0,1],/iso
thx2=theta # replicate(1,n_elements(thetay))
thy2=replicate(1,n_elements(theta)) # thetay
th2=sqrt(thx2^2+thy2^2)
contour,vigfunc2(th2),theta,thetay,c_col=replicate(2,10),/iso,/noer

end




