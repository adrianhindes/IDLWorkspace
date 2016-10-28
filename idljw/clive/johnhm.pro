goto,ee
tr=[4.5,7.5]
;sh=9324 & freqshot=2. & tr2=[2,7]

;sh=9326 & freqshot=10. & tr2=[2,7]
sh=9034 & freqshot=10. & tr2=tr
demodtype='hsm2013mse'
newdemodflcshot,sh,tr,/lut,/only2,res=res1,demodtype=demodtype,/cachewrite,/cacheread
tr=tr2
newdemodflcshot,sh,tr,/lut,/only2,rresref=res1,res=res,demodtype=demodtype,nsm=1,nskip=1,/cachewrite,/cacheread

ee:
sz=size(res.z1)
iz0=value_locate(res.z1,0)

tmp=transpose(reform(res.ang(*,iz0,*)))-12
ix=where(res.r1 gt -230 and res.r1 lt -180)
nsub=3


imgplot,tmp(*,ix),res.t,res.r1(ix),nl=21,zr=[-10,15],$
        title='MSE polarisation angle #'+string(sh,format='(I0)'),ytitle='-R (cm)',/cb
imgplot,res1.ang(*,*,value_locate(res1.t,5.48))-12,/cb,zr=[-10,15]


end

