function event_func,shot,timefile,channels=channels,trange=trange,tres=tres_in,$
               afs=afs,verbose=verbose,data_source=data_source,$
							 errormess=errormess,silent=silent,timerange=timerange
							 

; ******************************* event_stat.pro ****** S. Zoletnik 29.10.1998 ***
; Returns a structure containig the autocorrelation function and parameters.
; This is needed by the event_xxxx.pro routines.
; shot: shot No.
; timefile: timefile for calculation
; timerange: time range of calculation (alternative for timefile)
; channels: list of signals to add. See crosscorr_new.pro for signal names.
; trange: time lag range of autocorrelation function (microsec)
; tres: time resolution of correlation function (microsec)
; ---> for other arguments see crosscor_new.pro
; *************************************************************************** 

default,trange,[5,300]
default,tres_in,5

if (not keyword_set(channels)) then begin
  errormess='Channels should be set!'
  if (not keyword_set(silent)) then print,errormess
	return,0
endif	

errormess=''

tres=tres_in
corrlen=[-trange(1),trange(1)]
crosscor_new,shot,timefile,timerange=timerange,data_source=data_source,refchan=channels,$
             plotchan=channels,trange=corrlen,tres=tres,afs=afs,$
						 outtime=outtime,outcorr=outcorr,interval_n=1,cut_length=0,verbose=verbose,$
						 errormess=errormess,/silent,/noplot,/noerase
if (not keyword_set(outcorr)) then begin
  if (not keyword_set(silent)) then print,errormess
	return,0
endif
						  
ind=where((outtime ge trange(0)) and (outtime le trange(1)))
outtime=outtime(ind)
outcorr=outcorr(ind)
outcorr=outcorr/max(outcorr)
trange=[min(outtime),max(outtime)]
tres_in=tres

event={func: outcorr, time: outtime, tres: tres, trange:corrlen}
return,event
end	
							 

