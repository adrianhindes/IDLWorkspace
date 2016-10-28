function hdfrestit, sd_id, i,NumSDS,pre=prep
;print,'here,; pre=',prep

a:
sds_id=HDF_SD_SELECT(sd_id,i)
hdf_sd_getinfo,sds_id,name=name
;print,'name=',name
pos=strpos(name,'_',/reverse_search)
pre=strmid(name,0,pos)


post=strmid(name,pos+1,1000)
nuprep=total( ( byte(prep) eq (byte('_'))(0) ) )
nupre=total( ( byte(pre) eq (byte('_'))(0) ) )

pos=strpos(pre,'_',/reverse_search)
prepre=strmid(name,0,pos)

;if nuprep ge 1 then begin
;   spl=strsplit(name,'_',/extr)
;   prepre2=strjoin( spl(0:nuprep-1),'_')
;   if prepre2 ne prepre then stop
;endif





sameroot=prepre eq prep;strpos(pre,prep) eq 0

if (prep ne pre) and sameroot eq 1 then begin
    HDF_SD_ENDACCESS,sds_id
    pos=strpos(pre,'_',/reverse_search)
    nm=strmid(pre,pos+1,1000)
    nm=repluscore(nm,/back)
;    print,'pre=',pre
    dat=hdfrestit(sd_id, i,NumSDS,pre=pre)
;    if i eq 0
    if n_elements(data) eq 0  then data=create_struct(nm,dat) else $
      data=create_struct(data,nm,dat)
endif else if (prep ne pre) and sameroot eq 0 then begin
    HDF_SD_ENDACCESS,sds_id
;    stop
    return,data
endif else begin
    pos=strpos(post,'*r')
    if pos ne -1 then begin
        post=strmid(post,0,pos)
        HDF_SD_GETDATA,sds_id,datr ;,start=start,count=count
        HDF_SD_ENDACCESS,sds_id
        i=i+1
        sds_id=HDF_SD_SELECT(sd_id,i)
        HDF_SD_GETDATA,sds_id,dati ;,start=start,count=count
        dat=complex(datr,dati)
    endif else begin
        HDF_SD_GETDATA,sds_id,dat ;,start=start,count=count
        if size(dat,/type) eq 1 then dat=string(dat)
    endelse

	if n_elements(dat) eq 1 then dat=dat(0)
    if n_elements(data) eq 0  then data=create_struct(post,dat) else begin
        tn=total(tag_names(data) eq post)
        if tn eq 0 then data=create_struct(data,post,dat)
    endelse
    HDF_SD_ENDACCESS,sds_id
    i=i+1
;    print,name,i,NumSDS
endelse
b:
if i eq NumSDS then return,data
goto,a
end






PRO hdfrestoreext,filename, data;,start=start,count=count
sd_id=HDF_SD_START(filename)
HDF_SD_FILEINFO,sd_id,NumSDS,attributes
i=0
pre=''
data=hdfrestit(sd_id, i,NumSDS,pre=pre)
HDF_SD_END,sd_id
end

