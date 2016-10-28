function getimg, num,sm=sm,index=index,pre=pre,ndig=ndig,mdsplus=mdsplus,nonum=nonum,getinfo=getinfo,info=info,fil=fil,rememb=rememb,flc=flc,getflc=getflc,seg=seg,flipy=flipy,test=test,roi=roi,path=path
;on_error,2
forward_function get_kstar_mse_images, getflc

if keyword_set(mdsplus) and not keyword_set(seg) then begin
    common cbb, u
    if n_elements(u) ne 0 and keyword_set(rememb) then goto,aff

    shotno=num
    tree='MSE'
;if n_elements(u) eq 0 then
    u = get_kstar_mse_images(shotno, camera=camera, time=time, tree=tree)
    if keyword_set(getinfo) then begin
        mdsopen,'mse',shotno
        info={num_images:n_elements(u(0,0,*)),$
              hbin:fix(strmid((cgetdata('.SENSICAM.SETTINGS.H_BIN')).v,3,1)),$
              vbin:fix(strmid((cgetdata('.SENSICAM.SETTINGS.V_BIN')).v,3,1)),$
              x1:(cgetdata('.SENSICAM.SETTINGS.ROI_LEFT')).v,$
              x2:(cgetdata('.SENSICAM.SETTINGS.ROI_RIGHT')).v,$
              Y1:(cgetdata('.SENSICAM.SETTINGS.ROI_BOTTOM')).v,$
              Y2:(cgetdata('.SENSICAM.SETTINGS.ROI_TOP')).v    }

        if keyword_set(getflc) then begin
           flc=getflc()
;           flc={flc0:cgetdata('.DAQ.DATA:FLC_0'),flc1:cgetdata('.DAQ.DATA:FLC_1')}
        endif

        mdsclose
    endif
    aff:


    default,index,0
    slice=u(*,*,index)

endif else if keyword_set(mdsplus) and  keyword_set(seg) then begin
    mdsopen,'mse',num
    default,index,0
    dum=get_image_seg('.PCO_CAMERA:IMAGES',index)
    slice=dum.images
    info={num_images:mdsvalue('.PCO_CAMERA.SETTINGS.TIMING:NUM_IMAGES'),$
          frame_time:mdsvalue('.PCO_CAMERA.SETTINGS.TIMING:FRAME_TIME')}
        if keyword_set(getflc) then begin
           flc=getflc()
        endif


    mdsclose

endif else begin
;    path='~/kstartestimages'
    spawn,'hostname',res
;    if res eq 'h1svr' then path='~/prlpro/res_jh/mse_data'; ;'~/rsphy/kstartestimages'
;    if res eq 'ikstar.nfri.re.kr' and not keyword_set(test) then path='~/mse_data'
    default,path,getenv('mse_path')

    default,pre,''
    if keyword_set(ndig) then fmt='(I3.3)'  else fmt='(I0)'
    if not keyword_set(nonum) then fil=path+'/'+pre+string(num,format=fmt)+'.tif' else fil=path+'/'+pre+'.tif'
    print,findfile(fil)
    if keyword_set(getinfo) then begin
        dum=query_tiff(fil,info)
        info=create_struct(info,'tif',getrec(num,path=path,prer=pre))
    endif
    d=read_tiff(fil,/verb,image_index=index)
    slice=d
    if keyword_set(getflc) then begin
        mdsopen,'mse',num
        flc=getflc()
        mdsclose
    endif


endelse

if keyword_set(mdsplus) then begin
   if keyword_set(getflc) then begin
       if (num gt 7893 and num lt 7896) or num eq 7905 then numtmp=7893 else numtmp=num

       mdsopen,'mse',numtmp
           flc=getflc()
;       flc={flc0:cgetdata('.DAQ.DATA:FLC_0'),flc1:cgetdata('.DAQ.DATA:FLC_1')}
       mdsclose

       if keyword_set(getinfo) then begin
           freq=freqof(flc.flc1.t,flc.flc1.v,/plot,xr=[0,100],/ylog)
          
           mult=total(flc.flc1ms) ;
           fsamp=freq*mult
           fsamp=round(fsamp)   ;
           fsamp=float(fsamp)
           print,'sampling freq should be',fsamp
           frame_time=1/fsamp
           info=create_struct(info,'frame_time',frame_time)

       endif

   endif
endif


    
;stop




if keyword_set(roi) then begin
slice=slice(roi(0)-1:roi(1)-1,roi(2)-1:roi(3)-1)
endif

if keyword_set(sm) then begin
    sz=size(slice,/dim)
    sz2=sz / sm
;    d2=fltarr(sz2(0),sz2(1))
    slice=congrid(slice,sz2(0),sz2(1))
;    stop
endif
if keyword_set(flipy) then slice=rotate(slice,7)    
return,slice
end
