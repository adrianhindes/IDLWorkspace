function getrecnew,fil
;if sht ge 8044 then sh=8018 else sh=sht ; use efault

dum=file_search(fil,count=cnt)
if cnt eq 0 then begin
    str={err:0}
    return,str
endif

;Picture Size horz./vert.:  688/520

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

readf,lun,lin
if strmid(lin,0,11) eq 'Camera Mode' then begin
    cam2='sensicam'
    cam=strmid(lin,26,100)
    readf,lun,lin&gain=strmid(lin,26,100)
    readf,lun,lin&siz=fix(strsplit(strmid(lin,26,100),'/',/extract))
    readf,lun,lin&roi=fix(strsplit(strmid(lin,26,100),'-/',/extract))+1;;; fudge for sensicam!!!
    readf,lun,lin&bin=fix(strsplit(strmid(lin,26,100),' /x',/extract))
    readf,lun,lin&triggermode=strmid(lin,26,100)

    readf,lun,lin&del=float(strsplit(strmid(lin,26,100),'ms ',/extract))
    readf,lun,lin&exp=float(strsplit(strmid(lin,26,100),'ms ',/extract))
    expdel=[exp,del]

    close,lun
    free_lun,lun

    str={cam2:cam2,date:sdate,time:stime,cam:cam,siz:siz,roi:roi,bin:bin,expdel:expdel}


endif else begin
    cam2='edge'
    cam=strmid(lin,26,100)
    readf,lun,lin&siz=fix(strsplit(strmid(lin,26,100),'/',/extract))
    readf,lun,lin&roi=fix(strsplit(strmid(lin,26,100),'-/',/extract))
    readf,lun,lin&bin=fix(strsplit(strmid(lin,26,100),'/x',/extract))
    if cam eq 'pco.edge rolling shutter' then bin=1 ;override bin info

    readf,lun,lin&expdel=float(strsplit(strmid(lin,26,100),'/ms ',/extract))
    
    readf,lun,lin&adc=fix(strmid(lin,26,100))
    readf,lun,lin&offset=strtrim(strmid(lin,26,100),2)
    readf,lun,lin&ir=strtrim(strmid(lin,26,100),2)
    readf,lun,lin&pixrate=fix(strmid(lin,26,100))
    readf,lun,lin&epercount=float(strmid(lin,26,5))
    readf,lun,lin&serial=fix(strmid(lin,26,5))

    close,lun
    free_lun,lun

    str={cam2:cam2,date:sdate,time:stime,cam:cam,siz:siz,roi:roi,bin:bin,expdel:expdel,adc:adc,offset:offset,ir:ir,pixrate:pixrate,epercount:epercount,serial:serial}
    
endelse

return,str
end
