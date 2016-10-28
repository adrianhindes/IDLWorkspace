pro choppertimes,shot,channel,trange,on_name=on_name,off_name=off_name,data_source=data_source,$
    afs=afs,inttime=inttime,errorproc=errorproc

default,data_source,0
default,channel,15
default,inttime,30  ; microsec

if (data_source eq 0) then begin
  pointn=2000000L
  wftread,flukfile(shot,channel,afs=afs),data,rc,time=time,$
          tstart=tstart,/nodata,ext_fsample=wftsamp(shot)		 
  wftread,flukfile(shot,channel,afs=afs),data,rc,time=time,trange=[tstart,tstart+0.2],$
          pointn=pointn,ext_fsample=wftsamp(shot)
  ;data=integ(data,inttime)
  data=smooth(data,inttime)
endif
if (data_source eq 2) then begin
  if (strmid(getenv('HOST'),0,3) ne 'das') then begin
    txt='Libeam standard data are available only on das machines!'
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,txt,/forward
    endif else begin
      print,txt
    endelse
    return
  endif   
  pointn=7500
  rawchannel,shot,'PELLET','LIB3',channel,pointn,data,time
endif  

