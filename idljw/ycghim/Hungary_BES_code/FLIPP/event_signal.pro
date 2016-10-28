function event_signal,shot,timefile,channels=channels,intlen=intlen,$
               cdrom=cdrom,afs=afs,verbose=verbose,event=event,timerange=timerange,$
               confidence=confidence,uniform=uniform,signal=signal,sig_time=signal_t

; ******************************* event_signal.pro ****** S. Zoletnik 04.11.1998 ***
; Calculates the amplitude of an event 
; channels: list of channels to add signals
; intlen: integration length for corcor (sec)
; event: an event structure from event_func.pro
; confidence: return only those events where the amplitude is above noise with 
;             the given confidence (confidence=0 or unset --> return everything)
; /uniform: give 1 for all events (only if confidence is set)
; *************************************************************************** 

default,fitorder,2
default,confidence,0
						   
if (not keyword_set(event)) then begin
  print,'Create an event first using event_func.pro.'
	return,0
endif
	

if (not keyword_set(signal)) then begin
  if (not keyword_set(channels)) then begin
    print,'Channels are not set!'
  	return,0
  endif	
endif
  
if (not keyword_set(timerange)) then begin
  if (keyword_set(shot)) then begin
    default,timefile,i2str(shot,digits=5)+'on.time'
  endif else begin
    if (not keyword_set(timefile)) then begin
      print,'No timefile or timerange is set!'
      return,0
    endif
  endelse  
	; ************** Loading the timefile **************
	times=loadncol('time/'+timefile,2,/silent)
	ind=where((times(*,0) ne 0) or (times(*,1) ne 0))
	times=times(ind,*)
endif else begin
  times=fltarr(1,2)
	times(0,0)=timerange(0)	
	times(0,1)=timerange(1)
endelse	
nt=(size(times))(1)
trange=[min(times),max(times)]

if (not keyword_set(signal)) then begin
  nch=n_elements(channels)
  for i=0,nch-1 do begin
    get_rawsignal,shot,channels(i),t,d,afs=afs,cdrom=cdrom,trange=trange,$
                  sampletime=sampletime,errormess=errormess
  	if (errormess ne '') then return,0
  	if (i eq 0) then begin
  	  nd=n_elements(d)
  		time=t
  		signal=d
  	endif else begin
  	  signal=signal+d
  	endelse									
  endfor
endif else begin
  time = signal_t
  d = signal  
  nd=n_elements(d)
  sampletime=time(1)-time(0)
endelse  
							   
c=event.func
corrlen=event.trange(1)

mult=round(event.tres/(sampletime/1e-6))
shift_list=event.time/event.tres
maxshift=max(shift_list)
if (not keyword_set(intlen)) then intlen_shift=maxshift else intlen_shift=intlen/(event.tres*sampletime)
if ((mult mod 2) ne 1) then begin
  print,'Incompatible time resolution of signals.'
	stop
endif
			 
corcor=fltarr(nd/mult+1)
if (mult gt 2) then corcor_time=smooth(time,mult) else corcor_time=time
corcor_time=corcor_time(findgen(nd/mult)*mult+mult/2)
ind1_list=lonarr(nt)
ind2_list=lonarr(nt)
for it=0,nt-1 do begin 
  if (keyword_set(verbose)) then print,i2str(it+1)+'/'+i2str(nt)
	ind=where((time ge times(it,0)) and (time le times(it,1)))
	ind1=ind(0)
	ind2=ind(n_elements(ind)-1)
	sig=signal(ind1:ind2)
	n=ind2-ind1+1
	t=findgen(n)
	p=poly_fit(t,sig,fitorder)
	sig0=p(0)
	for i=1,fitorder do sig0=sig0+p(i)*t^i
	sig=sig-sig0
	if (mult gt 2) then sig=smooth(sig,mult)
	sig=sig(lindgen(long(n/mult))*mult+mult/2)
	i_base=ind1/mult
  c1=fltarr(n_elements(event.func))
  for j=0,n_elements(shift_list)-1 do begin
    c1(j)=total(sig(maxshift:maxshift+intlen_shift-1)$
                *sig(maxshift+shift_list(j):maxshift+intlen_shift-1+shift_list(j)))
  endfor
	corcor(i_base+maxshift+intlen_shift/2)=total(c1*c)
	shift1=shift_list(0)
	shift2=shift_list(n_elements(shift_list)-1)						  
  ind1_list(it)=i_base+maxshift+intlen_shift/2
	ind2_list(it)=i_base+n_elements(sig)-shift2-intlen_shift-1+intlen_shift/2
  for i=long(maxshift+1),n_elements(sig)-shift2-intlen_shift-1 do begin
    c1=c1-sig(i-1)*sig(i-1+shift1:i-1+shift2)  
    c1=c1+sig(i+intlen_shift-1)*sig(i+intlen_shift-1+shift1:i+intlen_shift-1+shift2)  
	  corcor(i_base+i+intlen_shift/2)=total(c1*c)
  endfor	 
endfor	 

if (confidence ne 0) then begin
	bin=max(corcor)/100
	max=max(corcor)
	max=(long(max/bin)+1)*bin
	min=min(corcor)
	if (min ge 0) then begin
	  print,'Minimum of corocor signal is above 0! Cannot determine confidency.'
		print,'Using confidency=0'
	endif	else begin
	  min = -(long(-min/bin)+1)*bin
		for it=0,nt-1 do begin
		  cc=corcor(ind1_list(it):ind2_list(it)) 
			if (it eq 0) then begin
		    h=histogram(cc,bin=bin,max=max,min=min,omax=hmax,omin=hmin)
			endif else begin	
		    h=histogram(cc,bin=bin,max=max,min=min,omax=hmax,omin=hmin,input=h)
			endelse	
		endfor	
		hx=findgen(n_elements(h))*bin+hmin
	  ind_plus=where(hx gt 0)
		hx_plus=hx(ind_plus)
		h_plus=h(ind_plus)
		ind_minus=reverse(where(hx lt 0))
		hx_minus=-hx(ind_minus)
		h_minus=h(ind_minus)
;		plot,hx(ind_plus),h(ind_plus),ytype=1,yrange=[0.9,max(h)],ystyle=1
;		oplot,-hx(ind_minus),h(ind_minus)
    n=min([n_elements(ind_minus),n_elements(ind_plus)])
		ind=where(h_plus lt h_minus/(1-confidence))
		if (max(ind) ge 0) then begin
		  level = max(hx_plus(ind))+bin
		  corcor(where(corcor lt level)) = 0
		endif else begin
		  print,'Warning: signal always above event confidence limit'
		endelse
		if (keyword_set(uniform)) then begin
		  ind=where(corcor ge level)
			if (ind(0) ge 0) then corcor(ind)=1
		endif		
	endelse
endif
	 
return,{signal: corcor, time: corcor_time, ind1_list: ind1_list, ind2_list: ind2_list, sampletime:sampletime}
end
