pro demodmsea,sh=sh,istart=istart,iend=iend,doplot=doplot,sm=sm,pixfringe=pixfringe,cal=cal,prer=prer
default,cal,0

default,doplot,0


r=0
default,prer,'' 
 r=sh

if sh lt 7829 then begin
    mdsplus=1
    default,sm,1
endif else begin
    mdsplus=0
    default,sm,4
endelse

img=getimg(r,pre=prer,index=0,info=info,/getinfo,fil=fil,mdsplus=mdsplus,sm=sm,flipy=mdsplus eq 0)
nimg=info.num_images


if mdsplus eq 1 then default,pixfringe,6.0 * 4/info.vbin
if mdsplus eq 0 then default,pixfringe,6.0*5.3/5 * 4/sm
;print,'vertical binning is',info.vbin,'so pixfringe is ',pixfringe
;stop
;5.4;*105/50.

sets={win:{type:'sg',sgmul:1.2,sgexp:10},$
      filt:{type:'sg',sgexp:2,sgmul:1.},$
      aoffs:-75-11.,$   
      c1offs:45,$
        c2offs:-45,$
        c3offs: 0.,$
        fracbw:0.4,$
        pixfringe:pixfringe,$        
;        typthres:'win',$
        typthres:'data',$
;        thres:0.05}             
        thres:0.1}             



default,istart,0
default,iend,nimg-1
nimg=iend-istart+1



prearr=[replicate(prer,nimg)]
rarr=[replicate(r,nimg)]
idxarr=[intspace(istart,iend)]
nonumarr=[replicate(0,nimg)]
default,sm,1
smarr=[replicate(sm,nimg)]


for i=0,nimg-1 do begin


img=1.*getimg(rarr(i),pre=prearr(i),nonum=nonumarr(i),index=idxarr(i),sm=smarr(i),mdsplus=mdsplus,rememb=1,flipy=mdsplus eq 0);/16


   if cal eq 0 then begin
;       imgz=1.*getimg(rarr(i),pre=prearr(i),nonum=nonumarr(i),index=1,sm=smarr(i),mdsplus=mdsplus,/rememb) ;/16
;       img-=imgz
   endif

demodcs, img,outs, sets,doplot=doplot,zr=[-2,1],newfac=0.6 ,save={txt:prearr(i),shot:rarr(i),ix:idxarr(i)},downsamp=sets.pixfringe,override=doplot eq 1,plotwin=0;,linalong=1;,/noopl
;limg=total(img,2)
;    stop
print,i,nimg 
endfor


end




