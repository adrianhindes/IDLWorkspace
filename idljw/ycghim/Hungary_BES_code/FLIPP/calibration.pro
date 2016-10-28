pro calibration,shot,calfac,chopper=chopper,new=new,plot=plot,save=save,$
		tcalanf=tcalanf,tcalend=tcalend,errormess=errormess,$
		backtrange=backtrange,caltrange=caltrange,auto_chopper=auto_chopper
		
; ******************** calibration.pro ****************** 17.01.2001 ******
; Calibration of Li-beam channels
; Modified using the original routine by S. Fiedler extracted from file
; signal_2.pro
; This routine either reads calibration factors from file
;  ~/libeam/cal/<shot>.cal
; or generates this file and returns values in variable calfac.
; The returned calibration factors are the averaged signals in the calibration
; time window.
; 
; History:
; 03.02.2006   SZ and EB: data read  -> get_rawsignal.pro
;                         This program does not read calibration data from cal/ directory
;                         it always does a calibration 
;                         /auto_chopper switch
; 17.01.2000   Creating routine from original signal_2.pro
;              Adding new keywords
;              Changing calibration without chopper to completely avoid the need
;                  for the chopper signal
;              Changing default calibration timerange
; Arguments
; shot: shot number
; calfac: the calibration factors
; /chopper: Use chopper intervals for determination of background signal,
;           otherwise use backtrange (default: 2.7-2.9s) as background time
; /auto_chopper: Determine chopper times from signal and not from chopper signal
; /new: calculate new calibration factors, don't use one in file
; /save: save calibration factors in file
; caltrange: calibration timerange [start,stop] s  
; tcalanf: start of calibration timerange | For compatibility with old routine
; tcalend: end of calibration timerange   |
; backtrange: background timerange if not using chopper
; errormess: error message if error occured
; /plot calibration factors
; **************************************************************************************


if (shot le 50400) then begin
  default,backtrange,[2.7,2.9]
  if (not defined(caltrange) and not (defined(tcalanf) and defined(tcalend))) then begin
    default,caltrange,[1.5,2.3]
  endif  
endif
if ((shot gt 50400) and (shot lt 50508))  then begin
  default,backtrange,[2,2.9]
  if (not defined(caltrange) and not (defined(tcalanf) and defined(tcalend))) then begin
    default,caltrange,[1.2,1.6]
  endif  
endif 
if (shot ge 50508) then begin
  default,backtrange,[2.5,2.9]
  if (not defined(caltrange) and not (defined(tcalanf) and defined(tcalend))) then begin
    default,caltrange,[1.3,2.3]
  endif  
endif

if (shot ge 54803) then begin
  default,auto_chopper,1
endif else begin
  default,auto_chopper,0
endelse
    
default,tcalanf,caltrange(0)
default,tcalend,caltrange(1)

errormess = ''

calfac=fltarr(28)
i=0
fname='cal/'+string(format='(i5)',shot)+'.cal'


  select_chopper_channel,shot,channr

  if not keyword_set(chopper) then begin		;****** no chopper
    text='offset substraction without chopper'
    print,'... ',text,' ...'
    if shot gt 33650 and shot lt 33900 then nshift=30 else nshift=5

    for i=0,27 do begin
     	chan=i+1
	get_rawsignal,shot,chan,data_s=2,time,sig,/nocalib
     	ind=where(time gt backtrange(0) and time lt backtrange(1), count)
     	offset=total(sig(ind))/count
     	ind=where(time gt caltrange(0) and time lt caltrange(1), count)
     	calfac(i) = total(sig(ind))/count - offset
    endfor
  endif

  if keyword_set(chopper) then begin			;****** chopper
  errormess = 'Calibration with chopper background subtraction does not work!'
  print,errormess
  return
  text='offset substraction with chopper'
  print,'... offset substraction with chopper ...'
  rawchannel,shot,'PELL','LIB3',channr,15000,chopperbuf,time

  for i=0,27 do begin
     chan=i+1
     rawchannel,shot,'PELL','LIB3',chan,15000,sig,time
     ind=where(time ge tcalanf and time le tcalend, count2)
     sig=sig(ind) & chopperbuf2=chopperbuf(ind) & time=time(ind)
     offset=fltarr(count2)
; Verbreiterung des Intervalls
     if shot lt 33900 then $
     chopperbuf2=(shift(chopperbuf2,-5)+shift(chopperbuf2,5))/2

     offsetchopper,sig,chopperbuf2,offset,timeoff,k,dauer,time,index_min
     ind=where(chopperbuf2 ge MAX(chopperbuf2)*0.95 and	$
               time ge time(timeoff(0)) and	$
               time le time(timeoff(k-1)), count3)
     calfac(i)=total(sig(ind)-offset(ind))/$
	    count3
  endfor

  endif

  ind = where(calfac eq 0,count)
  if (count gt 0) then calfac[ind] = 1
  calfac = 1./calfac
  if (count gt 0) then calfac[ind] = 0
  calfac=calfac/mean(calfac)
  
  if keyword_set(save) then begin	; saving calibration factors
    openw,u,fname,/get_lun
      printf,u,transpose(calfac)
      printf,u,text
      printf,u,'tcalanf,tcalend:',tcalanf,tcalend
    free_lun,u 
    print,'... saving ',fname,' ...'
  endif


if keyword_set(plot) then begin
   x=indgen(28)+1
   plot,x,calfac
endif

end
