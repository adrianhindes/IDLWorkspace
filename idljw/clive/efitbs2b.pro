window,0
befit1,9414,5.925, 5.975,/runtwice,/norun
window,1
befit1,9414,5.925,-1,/runtwice

window,2
befit1,9414,5.925,-1,/runtwice,/norun,gfile='/home/cam112/ikstar/my2/EXP009414_k/g009414.005975'

window,3
tarra=[5.975, 5.925]
na=n_elements(tarra)
qarr=fltarr(na,65)
sh=9414
for i=0,na-1 do begin
   tarr=tarra(i)
   fspec=string(sh,tarr*1000,format='(I6.6,".",I6.6)')
   dir='/home/cam112/ikstar/my2/EXP00'+string(sh,format='(I0)')+'_k'+''
   gfile=dir+'/g'+fspec
   g=readg(gfile)
   qarr(i,*)=g.qpsi
   print,gfile
endfor
plotm,transpose(qarr),yr=[0,5]



;befit1,7757,2.8,-1,inperr=[-1.25,-1.25,-1.25,-1.25,-0.94,-1.13,-1.27,-1.31,-1.29,-1.25,-1.25,-1.25,-1.25,-1.25,-1.25,-1.25]

end
