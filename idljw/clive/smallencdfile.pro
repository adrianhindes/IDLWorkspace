basepath='/home/cam112/rsphycp/fres/KSTAR/26887/'
basepath2='/tmp/'
cmno=32;25

famp=1.
hamp=10.
tamp=20.

;tamp=0.
fil='cd_26887.00230_A02_1_CM'+string(cmno,format='(I0)')+'.dat'
restore,file=basepath+fil,/verb  

;nx=cd.coords.nx
;ny=cd.coords.ny
;nz=cd.coords.nz

;xt=reform(cd.coords.x);,nx,ny,nz)
;hamp=fltarr(20475,600,1,3)
;for i=0,599 do for j=0,2 do hamp(*,i,0,j) = xt ge 150
;famp=1-hamp
;stop
;if dores eq 1 and docmb eq 1 then combinebeams,cd,wt=[0,1]

;createvig,size(uc,/dim),vig,imgbin=imgbin
;vig=uc*0+1
cd2={inputs:cd.inputs,coords:cd.coords,$
     neutrals:{srspectra0:famp*cd.neutrals.frspectra0+cd.neutrals.hrspectra0*hamp+cd.neutrals.trspectra0*tamp,$
               srspectra1:famp*cd.neutrals.frspectra1+cd.neutrals.hrspectra1*hamp+cd.neutrals.trspectra1*tamp,$
               srspectra2:famp*cd.neutrals.frspectra2+cd.neutrals.hrspectra2*hamp+cd.neutrals.trspectra2*tamp},$
    spectra:{lambda:cd.spectra.lambda}}


;stop
cd=cd2 
save,cd,file=basepath2+'sm'+fil+'';renamed to 231 for halfhalf, 2031 is half en, 1031 is full en, 531/533 is 10xhalf 20xthird
end
