@~/idl/get_kstar_mse_images_cached
@~/idl/demodcs
@~/idl/hats

pro mykstarb_go
setd_dat={$
           ;win:{type:'sg',sgmul:1.2,sgexp:4},$
win:{type:'sg',sgmul:1.5,sgexp:4},$
          filt:{type:'sg',sgmul:2,sgexp:2},$
;          filt:{type:'hat'},$
          aoffs:60,$
          c1offs:0,$
          c2offs:0,$
          c3offs:0,$
          fracbw:1.0,$
          pixfringe:10.,$
          typthres:'data',$
          thres:0.1}
setd_cal=setd_dat & setd_cal.fracbw=0.25
;set={shotno:5955,shotnoc:5955,calfr:10, nmediancal:1,$
;set={shotno:5988,shotnoc:5988,calfr:9, nmediancal:1,$

;set={shotno:5988,shotnoc:5991,calfr:0,shotnoc2:5990, nmediancal:5,$
set={shotno:5955,shotnoc:5991,calfr:0,shotnoc2:5990, nmediancal:3,$

;set={shotno:5988,shotnoc:563,calfr:0, nmediancal:3,$
     t0:2.0,nim:4,nsep:4,$
     dopl2:0,dopl1:1,$
     setd_dat:setd_dat,$
     setd_cal:setd_cal}
mykstarb,set
end

pro mykstarb, set ;shotno=shotno, t0=t0,dt=dt, cshotno=cshotno, noisemeth=noisemeth,$             dopl=dopl
noopl=1
tree='MSE'
uc = get_kstar_mse_images_cached(set.shotnoc, cal=set.shotnoc lt 1000 ? 1 : 0,camera=camera, time=timec, tree=tree)
nd=size(uc,/n_dim)
if  nd eq 3 then uc=uc(*,*,istag(set,'calfr') ? set.calfr : 0)
if istag(set,'shotnoc2') then begin
    uc2 = get_kstar_mse_images_cached(set.shotnoc2, cal=set.shotnoc2 lt 1000 ? 1 : 0,camera=camera, time=timec2, tree=tree)
    nd=size(uc,/n_dim)
    if  nd eq 3 then uc2=uc2(*,*,istag(set,'calfr') ? set.calfr : 0)
    uc=uc-uc2
endif

if set.nmediancal gt 1 then begin
    ucf=median(uc,set.nmediancal) 
    idx=where(ucf gt 5000)
    if idx(0) ne -1 then ucf(idx)=0.
endif else ucf=uc


demodcs,ucf,outsr,set.setd_cal,doplot=set.dopl1,zr=[-2,1],noopl=noopl


u = get_kstar_mse_images_cached(set.shotno, camera=camera, time=time, tree=tree)
time=time-time[0];;+0.8   ; trigger timing offset is 0.8s

iw0=value_locate(time,set.t0)
sz=size(u(*,*,0),/dim)
p1a=fltarr(sz(0),sz(1),set.nim)
p2a=p1a
for i=0,set.nim-1 do begin
    img=u(*,*,iw0+i*set.nsep)
    demodcs, img,outs,set.setd_dat,doplot=set.dopl2,zr=[-1,2],noopl=noopl
    p1=atan2(outs.c1/outsr.c1)
    p2=atan2(outs.c2/outsr.c2)
    pos=posarr(2,2,0)&erase
    imgplot,p1,/cb,zr=[-2,2],pal=-2,title='p1',pos=pos,/noer&pos=posarr(/next)
    imgplot,p2,/cb,zr=[-2,2],pal=-2,title='p2',pos=pos,/noer&pos=posarr(/next)
    imgplot,p1+p2,/cb,zr=[-2,2],pal=-2,title='p1+p2',pos=pos,/noer&pos=posarr(/next)
    imgplot,p1-p2,/cb,zr=[-2,2],pal=-2,title='p1-p2',pos=pos,/noer&pos=posarr(/next)
;    stop
    print,time(iw0+i*set.nsep)
    p1a(*,*,i)=p1
    p2a(*,*,i)=p2
endfor
pda=p1a-p2a
psa=p1a+p2a
plotm,reform(psa(*,512,*))-0.3,yr=[-.5,.5]

stop
end

mykstarb_go
end
