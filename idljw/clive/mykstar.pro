@demodc

set={shotno:5988,cshotno:5991,cshotno2:5990, t0=2.0,dt=0.,noisemeth:0,$
     dopl:1}
pro mykstar, set ;shotno=shotno, t0=t0,dt=dt, cshotno=cshotno, noisemeth=noisemeth,$             dopl=dopl

shotno=set.shotno
tree='MSE'
if n_elements(u) eq 0 then u = get_kstar_mse_images(shotno, camera=camera, time=time, tree=tree)
time=time-time[0]+0.8   ; trigger timing offset is 0.8s

img=u(*,*,10)

aoffs=60.
sgmul=1.2
dopl=1
fracbw=0.5
demodc, img,c1,c2a,c2b,s3,idxng=idxng,thres=0.1,pixfringe=10,aoffs=aoffs,wintype='sg',sgmul=sgmul,sgexp=sgexp,dopl=dopl,typthres='data',fracbw=fracbw,zr=[-2,1],/no
;stop
a=2 ;with gain
;a=3 ;no gain
shotnoc=5990+1  ; 7 is 90kv
shotnoc2=5990
tree='MSE'
if n_elements(uc) ne 0 then dum=temporary(uc)
if n_elements(uc) eq 0 then uc = get_kstar_mse_images(shotnoc, camera=camera, time=timec, tree=tree)

if n_elements(uc2) ne 0 then dum=temporary(uc2)
if n_elements(uc2) eq 0 then uc2 = get_kstar_mse_images(shotnoc2, camera=camera, time=timec2, tree=tree)

goto,sk

imgc=uc

;idx=where(imgc ge 4090)
;if idx(0) ne -1 then imgc(idx)=0.
;time=time-time[0]+0.8   ; trigger timing offset is 0.8s
;help,uc
;imgplot,,/cb
nbins=100
imgc=uc2
myhist,imgc,h,hx,nbins=500
plot,hx,h,psym=-4,/ylog
thres=100
;wait,2
idx=where(imgc ge thres)
if idx(0) ne -1 then imgc(idx)=0.
imgplot,imgc,/cb
;wait,2
myhist,imgc,h,hx,nbins=thres/2
;plot,hx,h,psym=-4
;wait,2

lam=33.
fac=4
plot,hx,h,/ylog
f=poissd(hx/fac,lam=lam/fac)
ii=where(finite(f) eq 0)
if ii(0) ne -1 then f(ii)=0.
f=f/max(f)
f=f*h(value_locate(hx,lam))
oplot,hx,f,col=2

ucf=uc
ucf(idx)=1e9

ucf=median(ucf,3)
idx=where(ucf gt 5000)
if idx(0) ne -1 then ucf(idx)=0.
imgplot,ucf,zr=[0,10000]
;retall

sk:
ucf=median(uc-uc2,3)
dopl=1
zr=[-1,2]
fracbw=0.2
demodc, ucf,c1r,c2ar,c2br,s3r,idxng=idxng2,thres=0.1,pixfringe=10,aoffs=aoffs,wintype='sg',sgmul=sgmul,sgexp=sgexp,dopl=dopl,zr=zr,/noopl,typthres='data',fracbw=fracbw


c2ac=c2a/c2ar
c2bc=c2b/c2br
p2a=atan2(c2ac)
p2b=atan2(c2bc)


imgplot,p2a*!radeg,zr=[-50,50],/cb
end
