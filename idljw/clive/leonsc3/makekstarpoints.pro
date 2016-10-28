opt='new2';2'
if opt eq 'old' then begin
    jcam=[-1.19830,      2.65770,     0.322000] ; comented on 14/mar/2013
    ccam=2.754*[cos(-1.7*!dtor),sin(-1.7*!dtor),0] ;commented on 14/mar
endif

if opt eq 'new' then begin
    jcam= [-927., 2557., 275.]/1000.
    ccam=jcam;[2717., -122, 275]/1000.
endif

if opt eq 'new2' then begin
    jcam= [-982.,2576,275]/1000.
    ccam=jcam
endif

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

;centre of window
wcoord = [2525.5, 1123.9, 0.];/1000.

wcoord=mat # wcoord

;print,'Click on inside right corner of large port box flange'
fcoord = [2042.1, 1634.8, -278];/1000.

fcoord=mat # fcoord

nseg=36*2*0

lns=fltarr(3,2,8+10+nseg)

cnt=0
lns(*,0,cnt) = wcoord
lns(*,1,cnt++) = wcoord*0.9

lns(*,0,cnt) = fcoord
lns(*,1,cnt++) = fcoord*0.9


lns(*,0,cnt) = fcoord
lns(*,1,cnt++) = fcoord + [0,0,400.]

if opt eq 'new2' then begin
    ang=-24.3*!dtor
    mat=[[cos(ang),sin(-ang),0],$
         [sin(ang),cos(ang),0],$
         [0,0,1]]

;   ductpoint1=[1485,3399,0.] ; point through which both beams cross {mm->cm)
;   ductpoint2=ductpoint1 + [0,-3399,0,0.]
;   ductpoint3=ductpoint1 + [0,-3399+1400,0.]

    ductpoint0=[1485,3399,0.]
    ductpoint1=[1485,3399,0.]+[0,-3399+1500,0] ; point through which both beams cross {mm->cm)
    ductpoint2=ductpoint0 + [0,-3399+1200,0.]
    ductpoint3=ductpoint0 + [0,-3399+1400,0.]
    
    ductpoint1m=mat # ductpoint1
    ductpoint2m=mat # ductpoint2
    ductpoint3m=mat # ductpoint3
    stop
    lns(*,0,cnt) = ductpoint1m
    lns(*,1,cnt++) = ductpoint2m

    lns(*,0,cnt) = ductpoint3m + [0,0,200]*0.1
    lns(*,1,cnt++) = ductpoint3m + [0,0,-200]*0.1
    
endif else begin
    ductpoint=[3399,-1485,0.] ; point through which both beams cross {mm->cm)
    lns(*,0,cnt) = ductpoint +[-3399+1800,0,0]
    lns(*,1,cnt++) = ductpoint + [-3399+1200,0,0.] 

    lns(*,0,cnt) = ductpoint + [-3399+1400,0,0.] + [0,0,200]
    lns(*,1,cnt++) = ductpoint + [-3399+1400,0,0.] + [0,0,-200]
endelse


lns(*,0,cnt) = [2525.5, 1123.9, 220.];/10
lns(*,1,cnt++) = [2525.5, 1123.9, 220.]*0.95 ; mid upper win

lns(*,0,cnt) = [2525.5, 1123.9, 411.5];/10
lns(*,1,cnt++) = [2525.5, 1123.9, 411.5]*0.97;upper win

lns(*,0,cnt) = [2073.,1833.,0.]
lns(*,1,cnt++) = [2073.,1833.,0.]*0.97;box cent

pp=[1411.06,2042.7,190.5] &lns(*,0,cnt) = pp & lns(*,1,cnt++) = pp*0.97
; uper left

pp=[1411.06,2042.7,-190.5] &lns(*,0,cnt) = pp & lns(*,1,cnt++) = pp*0.97
; bot left

pp=[2338.31,834.3,190.5] &lns(*,0,cnt) = pp & lns(*,1,cnt++) = pp*0.97
; upper rightbox

pp=[2338.31,834.3,-190.5] &lns(*,0,cnt) = pp & lns(*,1,cnt++) = pp*0.97
; lower rightbox

pp=[2078.9,1598.1,340] &lns(*,0,cnt) = pp & lns(*,1,cnt++) = pp*0.97
; leftbox upperright



;cnt=6
rad=2300.
div=360. / nseg*!dtor
for i=0,nseg-1 do begin
   lns(*,0,cnt+i)=rad*[cos(i*div),sin(i*div),0]
   lns(*,1,cnt+i)=rad*[cos((i+1)*div),sin((i+1)*div),0]
endfor




;fn='~/idl/clive/nleonw/kmse_7891n2/objhidden_'+'ex_'+opt+'.sav'
fn='~/idl/clive/nleonw/kmse_7345n2/objhidden_'+'ex_'+opt+'.sav'
print,'fn=',fn
save,lns,file=fn,/verb
end


