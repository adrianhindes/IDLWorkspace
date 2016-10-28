pro getflcstate,sh=sh,idx=idx,flc0=fflc0,flc1=fflc1
mdsclose
mdsopen,'mse',sh
flc0=cgetdata('.DAQ.DATA:FLC_0',/norest)
flc1=cgetdata('.DAQ.DATA:FLC_1',/norest)
if sh le 7829 then begin
    dtframe=(cgetdata('.SENSICAM.TIMING.FRAME_TIME')).v / 1000 ; ms to s
    nimg=(cgetdata('.SENSICAM.TIMING.NUM_IMAGES')).v
endif else begin
    dum=getimg(sh,pre='',index=0,sm=4,info=info,/getinfo,mdsplus=0)
    nimg=info.num_images
endelse

gettim,sh=sh,tstart=t0,ft=dtframe,iidx=iidx
if n_elements(iidx) eq 0 then iidx=findgen(nimg)

idx2=iidx(idx)


tmy=(idx2+0.5) * dtframe + t0

flc0.t-=flc0.t(0)
flc1.t-=flc1.t(0)
fflc0=interpolo(flc0.v,flc0.t,tmy-t0)
fflc1=interpolo(flc1.v,flc1.t,tmy-t0)

end

