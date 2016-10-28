function lightprof,shot_arr,timefile_arr,channels=chlist,nocalibrate=nocalibrate,data_source=data_source,afs=afs,$
           silent=silent,errormess=errormess,calfac=calfac,timerange=timerange,$
           subchannel=subchannel,datapath=datapath,filename=filename,chan_prefix=chan_prefix,chan_postfix=chan_postfix


;*****************lightprof.pro     S. Zoletnik 7.11.1997 *****************
; Calculates light profiles in given shot and for given timefile or
; for a series of shots (in case shot and timefile is an array)
;  experiment: experiment file name (see load_experiment.pro)
;  calfac: calibration factors (optional)
;  subchannel: subchannel for deflected Li-beam measurements
;  filename: Name of the datafile (only for 6 and 13 and for MAST test shots)
;  datapath: Path for the datafile
; For other parameters see zztcorr.pro
;**************************************************************************

default,data_source,fix(local_default('data_source',/silent))
default,chlist,defchannels(shot_arr[0],data_source=data_source)
errormess = ''

n_shot=n_elements(shot_arr)

for i_shot=0,n_shot-1 do begin
	shot = shot_arr[i_shot]
	if (keyword_set(timefile_arr)) then timefile = timefile_arr[i_shot]
	if (keyword_set(timefile)) then begin
	  times=loadncol(dir_f_name('time',timefile),2,/silent,errormess=errormess)
	  if (errormess ne '') then begin
	     if (not keyword_set(silent)) then print,errormess
	     return,0
	  endif
	  ind=where((times(*,0) ne 0) or (times(*,1) ne 0))
	  times=times(ind,*)
	endif else begin
	  if (not keyword_set(timerange)) then begin
	    errormess='One of timefile or timerange should be set'
	    return,0
	  endif
	  times=fltarr(1,2)
	  times(0,*) = timerange
	endelse

	nt=(size(times))(1)
	chn=(size(chlist))(1)

	tstart=double(min(times))
	tend=double(max(times))

	default,profile,dblarr(chn)
	default,totalpoint,fltarr(chn)

	for chi=0,chn-1 do begin

	  get_rawsignal,shot,chlist(chi),time,data,data_source=data_source,$
	        afs=afs,errormess=errormess,trange=[tstart,tend],$
	        nocalibrate=nocalibrate,calfac=calfac,data_names=data_names,subchannel=subchannel,$
		datapath=datapath,filename=filename,chan_prefix=chan_prefix,chan_postfix=chan_postfix

	  if (not keyword_set(time)) then begin
	    if (not keyword_set(errormess)) then  begin
	      errormess='Cannot read channel '+chlist(chi)+' from '+data_names(data_source)
	    endif
	    return,0
	  endif
	  for it=0,nt-1 do begin
	    ind=where((time ge times(it,0)) and (time le times(it,1)))
	    if (ind(0) ge 0) then begin
	      totalpoint(chi)=totalpoint(chi)+n_elements(ind)
	      profile(chi)=profile(chi)+total(data(ind))
	    endif
	  endfor

	endfor
	on_ioerror,NULL
endfor

profile = profile/totalpoint
profile=float(profile)
return,profile


end


