pro add_profiles,file,backtimefile_in,message_proc=message_proc,errormess=errormess,$
  data_source=data_source,afs=afs,replace=replace,rec=rec

; Calculates and adds light profiles and background ligth profiles to correlation
; file.


default,message_proc,'print_message'
errormess=''
on_ioerror,err
restore,'zzt/'+file
default,calfac,0
default,profile,0
default,backgr_profile,0

if (((size(calfac))(0) eq 0) or keyword_set(replace)) then begin
  call_procedure,message_proc,'Getting calibration factors...'
  calfac=getcal(shot,data_source=data_source,/silent)
  if ((size(calfac))(0) eq 0) then begin
    errormess='Cannot find calibration data for shot '+i2str(shot)
    call_procedure,message_proc,errormess
    return
  endif  
  call_procedure,message_proc,'...done'
endif	

if (((size(profile))(0) eq 0) or keyword_set(replace)) then begin
  call_procedure,message_proc,'Calculating light profile...'
  profile=lightprof(shot,timefile,channels=channels,$
                    data_source=data_source,afs=afs,/silent,errormess=errormess,calfac=calfac)
  if ((size(profile))(0) eq 0) then begin
    call_procedure,message_proc,'Error calculating light profile:'
    call_procedure,message_proc,errormess
    return
  endif  
  call_procedure,message_proc,'...done'
endif
        
default,backtimefile_in,backtimefile
default,backtimefile_in,''
backtimefile=backtimefile_in
if ((((size(backgr_profile))(0) eq 0) or keyword_set(replace)) and (backtimefile ne '')) then begin
  call_procedure,message_proc,'Calculating background light profile...'
  backgr_profile=lightprof(shot,backtimefile,channels=channels,$
                    data_source=data_source,afs=afs,/silent,errormess=errormess,calfac=calfac)
  if ((size(profile))(0) eq 0) then begin
    call_procedure,message_proc,'Error calculating background light profile:'
    call_procedure,message_proc,errormess
    return
  endif  
  call_procedure,message_proc,'...done'
endif
   
if (not keyword_set(rec)) then begin
  save,k,kscat,z,t,channels,timefile,tres,trange,cut_length,shot,$
       data_source,f,p,ps,profile,backgr_profile,calfac,backtimefile,file='zzt/'+file
endif else begin       
  if (keyword_set(matrix)) then begin
    shot_w=shot
    restore,'matrix/'+matrix
    default,p0r,0
    shot=shot_w
  endif  
  save,zzt_ne,zzt_ne_scat,z_ne,t_ne,channels,tres,trange,data_source,$
    profile,calfac,backtimefile,backgr_profile,timefile,cut_length,autocorr_cut,$
    matrix,n0,z0,p0,p0r,te,shot,file='zzt/'+file
endelse    

return



err:
errormess='Cannot open correlation file '+file
if (keyword_set(message_proc)) then begin
  call_procedure,message_proc,errormess
endif else begin
  print,errormess
endelse    
on_ioerror,null


end
