@~/idl/clive/vigfunc2
;setenv,'mse_path='+getenv('HOME')+'/prlpro/res_jh/mse_data'

d0=getimg(7869,index=50,info=info,/getinfo,path=getenv('HOME')+'/prlpro/res_jh/mse_data')&imgplot,d0,zr=[300,1000],/cb  

;d0=getimg(7891,index=25,info=info,/getinfo)&imgplot,d0,zr=[350,600],/cb  ;vessel structures
;retall
;imgplot,d0,zr=[0,3000]
;retall

; 135mm f/2 lens on sensicam? with 55mm lens pco edge 1x binning, i think..

d=float(d0-300.) / 1500.>0<1


sz=size(d,/dim)
x=findgen(sz(0))
mid0=[0.51,0.47]*[2560, 2160]

roi=info.tif.roi
mid1 = mid0 - [roi(0),roi(2)]
mid=mid1 / sz
;mid=[  0.415375,     0.459976]

theta = (x - sz(0)*mid(0)) * 6.5e-3 * 1 / 55. * !radeg

plot,theta,smooth(d(*,800),100)*1/0.9
oplot,theta,vigfunc2(theta),col=2
retall

;fitfun = 
y=findgen(sz(1))
thetay = (y - sz(1)*mid(1)) * 6.5e-3 * 1 / 55. * !radeg

plot,thetay,smooth(d(800,*),50)/0.9
oplot,thetay,vigfunc2(thetay),col=2
;retall
imgplot,d,theta,thetay,zr=[0,.1],/iso
thx2=theta # replicate(1,n_elements(thetay))
thy2=replicate(1,n_elements(theta)) # thetay
th2=sqrt(thx2^2+thy2^2)
contour,vigfunc2(th2),theta,thetay,c_col=replicate(2,10),/iso,/noer

end




