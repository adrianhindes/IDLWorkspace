pro wtdata, sd_id, nm, data

type = HDF_IDL2HDFTYPE(SIZE(data, /type))
sz=size(data,/dim)
rank=size(data,/n_dim)
if rank eq 0 then begin
    sz=[1] & rank=1
endif

sds_id=HDF_SD_CREATE(sd_id,nm,sz,hdf_type=type)
;hdf_sd_setcompress,sds_id,4,effort=5
HDF_SD_ADDDATA, sds_id, data
HDF_SD_ENDACCESS,sds_id
;print, nm,sz
end

pro hdfit, sd_id,pre,data
ntag=n_tags(data)
tn=repluscore(tag_names(data))

for i=0,ntag-1 do begin
    if (size(data.(i),/type) eq 8) then begin
;       tmp=create_struct('dumdum',0,data.(i))
 ;      stop
        hdfit, sd_id, pre+'_'+tn(i),data.(i);tmp
        goto,afterit
    endif

    if (size(data.(i),/type) eq 6) then begin
        wtdata,sd_id,pre+'_'+tn(i)+'*r',float(data.(i))
        wtdata,sd_id,pre+'_'+tn(i)+'*i',imaginary(data.(i))
    endif else begin
        dw=data.(i)
        if size(dw,/type) eq 7 then dw=byte(dw)
        wtdata,sd_id,pre+'_'+tn(i),dw
    endelse

    afterit:
endfor

end


pro hdfsaveext,filename,data,effort=effort
if n_elements(data) eq 0 then return
if n_elements(filename) eq 0 then return
;x=findfile(filename,count=cnt)
;if cnt ne 0 then spawn,'del '+filename
sd_id=HDF_SD_START(filename,/CREATE)

;hdf_sd_setcompress,sds_id,4,5

hdfit,sd_id,'',data


HDF_SD_END,sd_id

end




