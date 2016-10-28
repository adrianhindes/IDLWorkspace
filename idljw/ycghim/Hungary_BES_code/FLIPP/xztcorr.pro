pro xztcorr,sht,timefile,trange=trange,tres=tres,show=show,printer=printer,$
   simulate=simulate,pointn=pointn,old=old,help=help,interval_n=interval_n,$
   inttime=inttime,newcorr=newcorr,cut_length=cut_length,dens=dens,nocal=nocal,$
	 fft=fft,nofft=nofft,channels=channels,outfile=fn,errormess=errormess,$
   data_source=data_source,silent=silent,afs=afs,checkstop=checkstop,$
   messageproc=message_proc,backtimefile=backtimefile,nolock=nolock,$
   store_freq=store_freq
;*****************************************************************************   
; Calculates space--time correlation function of Li-beam signals with an extra
; (non-Li) signal and saves in file <sht>.xzt.sav.<x>, where <shot> is shotnumber and
; <x> is a serial number one above the last correlation file. 
; Removes photon noise correlation from curves.
; /old: write old style data file in ASCII format
; /newcorr: use crosscor_new.pro  instead of crosscor.pro
; /simulate: use simulated data (light or density)
; /dens: use simulated density data
; /nocal: do not calibrate zzt correlation function
; data_source: 0: nicolet (/nicolet in crosscor_new)
;              1: aurora (/aurora in crosscor_new)
;              2: li_standard (/li_standard in crosscor_new)
; checkstop: name of a function to check if stop of the calculation is 
;            desired by the user
; backtimefile: time file for the background light (name saved in data file)
; /nolock: do not lock resource zzt/lock
; /store_freq: store frequency spectrum data (power spectrum...)
; See other parameters at ztcorr.pro and crosscor_new.pro
;***************************************************************************

fn=''
default,store_freq,0
default,message_proc,'print_message'
default,data_source,0
case data_source of
  0: nicolet=1
  1: aurora=1
  2: li_standard=1
endcase

default,backtimefile,''
if (not (backtimefile eq '')) then begin
  openr,unit,'time/'+backtimefile,error=error,/get_lun
  if (error ne 0) then begin
    errormess='Cannot find background time file: '+backtimefile
    call_procedure,message_proc,errormess
    outk=0
    return
  endif
  close,unit
  free_lun,unit
endif    

call_procedure,message_proc,'Calculating light profile...'
profile=lightprof(sht,timefile,channels=channels,nocalibrate=nocal,$
                  data_source=data_source,afs=afs,/silent,errormess=errormess,calfac=calfac)
if ((size(profile))(0) eq 0) then begin
  call_procedure,message_proc,'Error calculating light profile:'
  call_procedure,message_proc,errormess
  outk=0
  return
endif  
call_procedure,message_proc,'...done'


if (not (backtimefile eq '')) then begin
  call_procedure,message_proc,'Calculating background light profile...'
  backgr_profile=lightprof(sht,backtimefile,channels=channels,nocalibrate=nocal,$
                    data_source=data_source,afs=afs,/silent,errormess=errormess,calfac=calfac)
  if ((size(profile))(0) eq 0) then begin
    call_procedure,message_proc,'Error calculating background light profile:'
    call_procedure,message_proc,errormess
    outk=0
    return
  endif  
  call_procedure,message_proc,'...done'
endif

fn=''
errormess=''
if (not keyword_set(nocal) and not keyword_set(simulate)) then begin
  c=getcal(sht,data_source=data_source,/silent)
  if ((size(c))(0) eq 0) then begin
    errormess='Cannot find calibration data for shot '+i2str(sht)
    if (not keyword_set(silent)) then print,errormess
    return
  endif  
endif	

if (keyword_set(help) or not keyword_set(sht)) then begin
  print,'Usage: zztcorr,shot,timefile[,trange=...] [,tres=...] [,/show] [,printer=...]'
	print,'               [,/simulate] [,/dens] [,pointn=...] [,/old] [,interval_n=...] [,/newcorr]'
	print,'               [,cut_length=...] [,/nocal]
	return
endif	

if (keyword_set(simulate)) then begin
  if (keyword_set(dens)) then begin
	  dd=0
		z_vect=0
	  restore,'tmp/sim1_dens.dat'
		chn=(size(z_vect))(1)
	endif else begin
	  chn=24
	endelse		
  channels=findgen(chn)+1
endif else begin	
	default,channels,defchannels(sht,data_source=data_source)
	chn=(size(channels))(1)
endelse
if (data_source le 1) then begin
  default,trange,[-400,400]
  default,tres,11
  default,cut_length,5
endif  
if (data_source eq 2) then begin
  default,trange,[-1000,1000]
  default,tres,200
  default,cut_length,0
endif  
default,pointn,1024
default,newcorr,1


if (not keyword_set(newcorr)) then begin
  print,'Using '+i2str(pointn)+' points/spectrum.'
endif

default,tf,timefile
default,tf,'(default)'
call_procedure,message_proc,'++++++ ZZTCORR.PRO  shot:'+i2str(sht)+'  time:'+tf+' +++++++'

for ii=0,chn-1 do begin
  if (keyword_set(checkstop)) then begin
    if (call_function(checkstop) ne 0) then return
  endif  
  i=channels(ii)-1
  call_procedure,message_proc,'Reference channel: '+i2str(i+1)
  ztcorr,sht,timefile,point=pointn,refch=i+1,$
     outtime=outtime,outz=outz,outk=outk,outscat=outscat,tres=tres,$
     trange=trange,cut_length=cut_length,norm=0,/noplot,show=show,printer=printer,$
     simulate=simulate,newcorr=newcorr,dens=dens,inttime=inttime,fft=fft,nofft=nofft,$
		 channels=channels,nicolet=nicolet,aurora=aurora,li_standard=li_standard,$
     errormess=errormess,silent=silent,afs=afs,checkstop=checkstop,messageproc=message_proc,$
     outfscale=outfscale,outpow=outpow,outpscat=outpscat,$
     proct1=proct1,proct2=proct2,procn=procn
     if ((size(outk))(0) eq 0) then return
	if (keyword_set(old)) then begin	 
    savencol,outk,i2str(sht)+'_'+i2str(i+1)+'.corr'
    savencol,outscat,i2str(sht)+'_'+i2str(i+1)+'_s.corr'
	endif else begin
	  if (ii eq 0) then begin
		  k=fltarr(chn,chn,(size(outtime))(1))
		  kscat=fltarr(chn,chn,(size(outtime))(1))
      p=complexarr(chn,(size(outpow))(1))
      ps=complexarr(chn,(size(outpscat))(1))
		endif
		k(ii,*,*)=transpose(outk)
		kscat(ii,*,*)=transpose(outscat)
    p(ii,*)=outpow
    ps(ii,*)=outpscat
	endelse	
endfor
if (keyword_set(old)) then begin
  savencol,outz,i2str(sht)+'_z.corr'
  savencol,outtime,i2str(sht)+'_time.corr'
	return
endif

z=outz
t=outtime
if (not keyword_set(nocal) and not keyword_set(simulate)) then begin
  cal_zztcorr,k,kscat,sht,p,ps,channels=channels,data_source=data_source,calfac=calfac
endif
	

if (not keyword_set(nolock)) then lock,'zzt/lock',60

i=0
found=1
f=i2str(sht)+'.zzt.sav'
while (found) do begin
  fn=f+'.'+i2str(i)
  openr,unit,'zzt/'+fn,error=error,/get_lun
  if (error ne 0) then begin
    found=0
  endif else begin
    close,unit
    free_lun,unit
  endelse
i=i+1    
endwhile
shot=sht
f=outfscale

default,calfac,0
default,backtimefile,''
default,backgr_profile,0
if (not store_freq) then begin
  f=0
  p=0
  s=0
endif  
save,k,kscat,z,t,channels,timefile,tres,trange,cut_length,shot,$
     data_source,f,p,ps,store_freq,profile,backgr_profile,calfac,backtimefile,$
     proct1,proct2,procn,file='zzt/'+fn
update_corr_list,shot,file=fn,channels=channels,trange=trange,tres=tres,$
   cut_length=cut_length,timefile=timefile,data_source=data_source     

if (not keyword_set(nolock)) then unlock,'zzt/lock'

end

