opt='iport';2'
ccam= [2541,1121,30.]/1000.
jcam=ccam
;endif

print,'numbers are',sqrt(ccam(0)^2+ccam(1)^2),'for radius'
print,'and',atan(ccam(1),ccam(0))*!radeg,'in deg for angle'
jcam/=norm(jcam)
ccam/=norm(ccam)
rot=acos(total(ccam*jcam))
print,'rot=',rot*!radeg
mat=[[cos(rot),sin(-rot),0],$
     [sin(rot),cos(rot),0],$
     [0,0,1]]
print,'jcam is',jcam
print,'mat # jcam is', mat # jcam 
print,'ccam is ',ccam


nseg=36*2*0

lns=fltarr(3,2,9+nseg)

cnt=0

pp=[-976,2545,-253.] &lns(*,0,cnt) = pp & lns(*,1,cnt++) = pp*0.97
dia=160.
lns(*,0,cnt) = pp+[0,0,-dia/2] & lns(*,1,cnt++) = pp*0.97+[0,0,-dia/2]
lns(*,0,cnt) = pp+[0,0,+dia/2] & lns(*,1,cnt++) = pp*0.97+[0,0,+dia/2]
; bot win

pp=[-966,2570,0.] &lns(*,0,cnt) = pp & lns(*,1,cnt++) = pp*0.97
dia=106.
lns(*,0,cnt) = pp+[0,0,-dia/2] & lns(*,1,cnt++) = pp*0.97+[0,0,-dia/2]
lns(*,0,cnt) = pp+[0,0,+dia/2] & lns(*,1,cnt++) = pp*0.97+[0,0,+dia/2]
; mid win

pp=[-966,2570,285.] &lns(*,0,cnt) = pp & lns(*,1,cnt++) = pp*0.97
dia=74.
lns(*,0,cnt) = pp+[0,0,-dia/2] & lns(*,1,cnt++) = pp*0.97+[0,0,-dia/2]
lns(*,0,cnt) = pp+[0,0,+dia/2] & lns(*,1,cnt++) = pp*0.97+[0,0,+dia/2]
; top win


;lns/=1000.


;
;;cnt=6
;rad=2300.
;div=360. / nseg*!dtor
;for i=0,nseg-1 do begin
;   lns(*,0,cnt+i)=rad*[cos(i*div),sin(i*div),0]
;   lns(*,1,cnt+i)=rad*[cos((i+1)*div),sin((i+1)*div),0]
;endfor






fn='~/idl/clive/nleonw/kmse_9240/objhidden_'+'ex_'+opt+'.sav'
print,'fn=',fn
save,lns,file=fn,/verb
end


