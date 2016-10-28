
;tt=1.7&field=2.8;3;8
tt=1.3&field=2.8;3;8
;tt=1.1&field=3.3
ttms=string(tt*1000,format='(I0)')




befit1,9243,0.34, tt,field=field,kff=4,kpp=3,outgname='orig';+ttms
;stop

;,kpp=3,kff=4
;goto,a
befitf2,9243,0.34, tt,field=field,gfile='/home/cam112/ikstar/my2/EXP009243_k/g_orig_009243.00'+ttms,mixfactor=0.001,rval1=r1,profsim=profsim1,profexp=profexp1,proflin=proflin1,profinten=profinten1,profdop=profdop1

befitf2,9243,tt+0.04, -1,field=field,gfile='/home/cam112/ikstar/my2/EXP009243_k/g_orig_009243.00'+ttms,mixfactor=0.6,rval1=r2,profsim=profsim2,profexp=profexp2,proflin=proflin2,profinten=profinten2,profdop=profdop2,methavg='proper'
a:

mkfig,'~/bswcmp.eps',xsize=28,ysize=21,font_size=9
plot,profexp1,pos=posarr(4,2,0),yr=[-8,8],title='polarisation angle (deg)'
oplot,profexp2,col=2
oplot,profsim1,thick=3
legend,['b1 : meas','b1 and b2:meas','b1 only : EFIT','40% b1, 60% b2 : EFIT'],$
       col=[1,2,1,2],linesty=[0,0,0,0],thick=[1,1,3,3],/bottom,box=0,textcol=[1,2,1,2]

oplot,profsim2,col=2,thick=3


plot,proflin1,pos=posarr(/next),/noer,yr=[0,.25],title='contrast'
oplot,proflin2,col=2

legend,['b1 : meas','b1 and b2:meas'],$
       col=[1,2],linesty=[0,0],thick=[1,1],/bottom,box=0,textcol=[1,2]

profcmb1=proflin1*profinten1
profcmb2=proflin2*profinten2

plot,profinten1,pos=posarr(/next),/noer,yr=[0,4000],title='intensity'
oplot,profinten2,col=2
oplot,profinten2-profinten1,col=3

legend,['b1 : meas','b1 and b2:meas','b2 : inferred'],$
       col=[1,2,3],linesty=[0,0,0],thick=[1,1,1],/bottom,box=0,textcol=[1,2,3]


plot,profcmb1,pos=posarr(/next),/noer,yr=[0,600],title='intensity*contrast'
oplot,profcmb2,col=2
oplot,profcmb2-profcmb1,col=3

legend,['b1 : meas','b1 and b2:meas','b2 : inferred'],$
       col=[1,2,3],linesty=[0,0,0],thick=[1,1,1],/bottom,box=0,textcol=[1,2,3]


plot,(profinten2-profinten1)/profinten2,pos=posarr(/next),/noer,title='ratio I2/(I1+I2);I=intensity'

plot,(profcmb2-profcmb1)/profcmb2,pos=posarr(/next),/noer,title='ratio iz2/(iz1+iz2);iz=intensity*contrast'

dopdif=atan2((exp(complex(0,1)*profdop2*!dtor) / exp(complex(0,1)*profdop1*!dtor)))*!radeg
plot,dopdif,title='change in doppler phase',subtitle='beam1andbeam2 c.f. beam1 only',pos=posarr(/next),/noer,ytitle='deg'

endfig,/gs,/jp
end

