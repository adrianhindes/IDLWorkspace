pro demodcxrs,sh=sh,istart=istart,iend=iend,doplot=doplot,sm=sm,cal=cal



default,doplot,0
default,pixfringe,5.4;*105/50.

sets={win:{type:'sg',sgmul:1.2,sgexp:10},$
      filt:{type:'sg',sgexp:2,sgmul:1.},$
      aoffs:-75+22.5+1.,$   
      c1offs:-12,$
        c2offs:12,$
        c3offs: 0.,$
        fracbw:0.4,$
        pixfringe:pixfringe,$        
        typthres:'win',$
        thres:0.1}             


if keyword_set(cal) then begin
    prer=cal
    r=0
    nonum=1
    istart=0
    iend=0

endif else begin
    prer='c' & r=sh
    img=getimg(r,pre=prer,index=0,info=info,/getinfo,fil=fil)
    nimg=info.num_images
    default,istart,2
    default,iend,nimg-1
    nonum=0
endelse


nimg=iend-istart+1
prearr=[replicate(prer,nimg)]
rarr=[replicate(r,nimg)]
;;idxarr=[0,5,7,20,40,60,80,99]
idxarr=[intspace(istart,iend)]
nonumarr=[replicate(nonum,nimg)]
default,sm,1
smarr=[replicate(sm,nimg)]

for i=0,nimg-1 do begin


img=1.*getimg(rarr(i),pre=prearr(i),nonum=nonumarr(i),index=idxarr(i),sm=smarr(i));/16
if not keyword_set(cal) then begin
;if i gt 0 then begin
    imgz=1.*getimg(rarr(i),pre=prearr(i),nonum=nonumarr(i),index=1,sm=smarr(i)) ;/16
    img-=imgz
endif

demodcs, img,outs, sets,doplot=doplot,zr=[-2,1],newfac=0.6 ,save={txt:prearr(i),shot:rarr(i),ix:idxarr(i)},downsamp=sets.pixfringe,override=doplot eq 1,rfac=1.16,r5fac=0.6,/dofifth,plotwin=0;,linalong=1;,/noopl
;limg=total(img,2)
;    stop
print,i,nimg 
endfor


end

