function getrec,sht,path=path,prer=prer
;if sht ge 8044 then sh=8018 else sh=sht ; use efault
sh=sht ; use efault
default,path,'~/mse_data'
default,prer,''
fil=path+'/'+prer+string(sh,format='(I0)')+'.rec'
dum=file_search(fil,count=cnt)
if cnt eq 0 then begin
    fil=path+'/'+prer+string(8047,format='(I0)')+'.rec'
endif


dum=file_search(fil,count=cnt)
if cnt eq 0 then begin
    str={err:0}
    return,str
endif


openr,lun,fil,/get_lun
lin=''
readf,lun,lin
readf,lun,lin
readf,lun,lin
sdate=strmid(lin,12,10)
stime=strmid(lin,30,8)
readf,lun,lin
readf,lun,lin
readf,lun,lin

readf,lun,lin&cam=strmid(lin,26,100)
readf,lun,lin&siz=fix(strsplit(strmid(lin,26,100),'/',/extract))
readf,lun,lin&roi=fix(strsplit(strmid(lin,26,100),'-/',/extract))
readf,lun,lin&bin=fix(strsplit(strmid(lin,26,100),'/x',/extract))
readf,lun,lin&expdel=float(strsplit(strmid(lin,26,100),'/ms ',/extract))

readf,lun,lin&adc=fix(strmid(lin,26,100))
readf,lun,lin&offset=strtrim(strmid(lin,26,100),2)
readf,lun,lin&ir=strtrim(strmid(lin,26,100),2)
readf,lun,lin&pixrate=fix(strmid(lin,26,100))
readf,lun,lin&epercount=float(strmid(lin,26,5))
readf,lun,lin&serial=fix(strmid(lin,26,5))
close,lun
free_lun,lun
str={date:sdate,time:stime,cam:cam,siz:siz,roi:roi,bin:bin,expdel:expdel,adc:adc,offset:offset,ir:ir,pixrate:pixrate,epercount:epercount,serial:serial}
return,str
end
