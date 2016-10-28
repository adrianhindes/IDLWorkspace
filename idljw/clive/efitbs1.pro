;goto,b
;window,0
befit1,7757,3.05,-1,/dobeam2,/runtwice,rrng=[1.86695,2.16695+0.01]*100,/norun,gfile='/home/cam112/ikstar/my2/EXP007757_k/g007757.002900'
retall


window,1

;befit1,7757,2.9,-1,/runtwice,/norun
;retall
b:
window,2
tarra=[2.9,3.05]
na=n_elements(tarra)
qarr=fltarr(na,65)
sh=7757
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

end
