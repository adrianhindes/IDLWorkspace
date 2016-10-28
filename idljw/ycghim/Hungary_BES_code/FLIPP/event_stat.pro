pro event_stat,shot,timefile,channels=channels,intlen=intlen,$
               cdrom=cdrom,afs=afs,verbose=verbose,event=event,$
							 testplot=testplot,test_n_event=test_n_event,test_event=test_event,$
               test_npoints=test_n_point,test_signal_amp=test_event_amp,test_noise_amp=test_noise_amp,$
							 PDF_xrange=PDF_xrange,PDF_yrange=PDF_yrange,simulation=simulation,$
							 PDF_xtype=PDF_xtype,confidence=confidence,maxpdf=maxpdf,test_amp_distr=test_amp_distr,$
               nopdf=nopdf,nocorr=nocorr,nolegend=nolegend,nopara=nopara,nosignal=nosignal,$
               stop=stop,out_signal=signal,out_event=corcor

; ******************************* event_stat.pro ****** S. Zoletnik 29.10.1998 ***
; Calculates statistics of event in Li-beam signals
; channels: list of channels to add signals
; intlen: integration length for corcor (sec)
; event: an event structure event_func
; *************************************************************************** 

default,fitorder,2
default,test_amp_distr,'fixed'

if (not keyword_set(testplot)) then begin
  if (shot ge 50000) then simulation=1
endif
					   
if (not keyword_set(event)) then begin
  print,'Create an event first using event_func.pro.'
	return    
endif
  
default,intlen,max(event.trange)*1e-6	

if (not keyword_set(testplot)) then begin
  if (not keyword_set(channels)) then begin
	  print,'Channels are not set!'
		return
	endif	
  default,timefile,i2str(shot,digits=5)+'on.time'
	; ************** Loading the timefile **************
	times=loadncol('time/'+timefile,2,/silent)
	ind=where((times(*,0) ne 0) or (times(*,1) ne 0))
	times=times(ind,*)
	nt=(size(times))(1)
	trange=[min(times),max(times)]
	nch=n_elements(channels)
endif else begin
  if (test_event.tres ne 1) then begin
    print,'test_event should have 1 microsec time resolution'
    return
  endif
  sampletime=1e-6
  times=fltarr(1,2)
  default,test_n_point,long(1e5)
	default,test_n_event,long(10)
  default,test_event_amp,1
  default,test_noise_amp,1
	signal=fltarr(test_n_point)
	time=findgen(test_n_point)*sampletime
  nd=n_elements(time)
	times(0,0)=0
	times(0,1)=max(time)
	nt=1
	trange=[min(times),max(times)]
	for i=0,test_n_event-1 do begin
	  x = randomu(seed)*test_n_point-1
		ind1 = long(x)
		ind2 = (ind1+n_elements(test_event.func)-1) < test_n_point-1
    if (test_amp_distr eq 'fixed') then aaa=test_event_amp
    if (test_amp_distr eq 'uniform') then aaa=randomu(seed)*2*test_event_amp
    if (test_amp_distr eq 'normal') then aaa=randomn(seed)*test_event_amp
		signal(ind1:ind2) = signal(ind1:ind2)+test_event.func*aaa
	endfor
  flucamp1=sqrt(total((signal-total(signal)/test_n_point)^2)/test_n_point)
  noise=randomn(seed,test_n_point)
  signal=signal+noise*test_noise_amp
  flucamp2=sqrt(total((signal-total(signal)/test_n_point)^2)/test_n_point)
endelse  
erase
if (not keyword_set(nolegend)) then time_legend,'event_stat.pro'	 

c=event.func
corrlen=event.trange(1)
       
if (not keyword_set(nocorr)) then begin
  if (not keyword_set(testplot)) then begin
  	plot,event.time,event.func,xtit='time lag [!7l!Xs]',title='Autocorrelation function',/noerase,$
  	   pos=[0.05,0.1,0.3,0.4]
  endif else begin
  	plot,event.time,event.func,xtit='time lag [!7l!Xs]',title='Correlation function of event',/noerase,$
  	   pos=[0.1,0.28,0.3,0.45],charsize=0.5
  	plot,test_event.time,test_event.func,xtit='time lag [!7l!Xs]',title='Event for signal generation',/noerase,$
  	   pos=[0.1,0.05,0.3,0.22],charsize=0.5
  endelse		 
endif 

if (not keyword_set(testplot)) then begin
  s=event_signal(shot,timefile,channels=channels,intlen=intlen,cdrom=cdrom,afs=afs,$
    event=event,confidence=confidence)
endif else begin
  s=event_signal(shot,timefile,channels=channels,intlen=intlen,cdrom=cdrom,afs=afs,$
    event=event,confidence=confidence,signal=signal,sig_time=time,$
    timerange=[min(time)+sampletime,max(time)-sampletime])
endelse


corcor=s.signal
corcor_time=s.time
ind1_list=s.ind1_list
ind2_list=s.ind2_list
sampletime=s.sampletime

if (not keyword_set(nosignal)) then begin
  plot,corcor_time,corcor,pos=[0.1,0.55,0.95,0.9],/noerase,title='Event signal',$
  ystyle=1,xstyle=1,xtitle='Time [s]'
endif
                
if (not keyword_set(nopdf)) then begin
  if (not keyword_set(maxpdf)) then begin	 							 
    bin=max(corcor)/100
    max=max(corcor)
    min=min(corcor)
    for it=0,nt-1 do begin
      cc=corcor(ind1_list(it):ind2_list(it)) 
    	if (it eq 0) then begin
        h=histogram(cc,bin=bin,max=max,min=min,omax=hmax,omin=hmin)
    	endif else begin	
        h=histogram(cc,bin=bin,max=max,min=min,omax=hmax,omin=hmin,input=h)
    	endelse	
    endfor	
    hx=findgen(n_elements(h))*bin+hmin
    hxe=0
    while (max(hx) ge 10) do begin
      hx=hx/10
    	hxe=hxe+1
    endwhile
    while (max(hx) lt 1) do begin
      hx=hx*10
    	hxe=hxe-1
    endwhile
    default,PDF_xtype,0
    default,PDF_xrange,[min(hx),max(hx)*1.05]
    default,PDF_yrange,[0.9,max(h)]	
    plot,hx,float(h),xstyle=1,xtype=PDF_xtype,xtit='Amplitude !9X!X10!U'+i2str(hxe)+'!N',ytit='Signal [a.u.]',/noerase,$
        xrange=PDF_xrange,title='PDF of event signal',pos=[0.45,0.1,0.7,0.4],ytype=1,yrange=PDF_yrange,ystyle=1,$
        xtickformat='(F3.1)'
    if ((PDF_xrange(0) lt 0) and (PDF_xrange(1) gt 0)) then plots,[0,0],PDF_yrange,linestyle=1		
  endif else begin
    bin=max(corcor)/100
    max=max(corcor)
    min=min(corcor)
    for it=0,nt-1 do begin
      cc=corcor(ind1_list(it)+intlen/event.tres*1e-6:ind2_list(it)-intlen/event.tres*1e-6) 
      ncc=n_elements(cc)
      ind=where((cc(1:ncc-2) gt cc(0:ncc-3)) and ((cc(1:ncc-2) ge cc(2:ncc-1))))
      if (ind(0) ge 0) then begin
        s_pdf=cc(ind+1)
    	  if (it eq 0) then begin
          h=histogram(s_pdf,bin=bin,max=max,min=min,omax=hmax,omin=hmin)
    	  endif else begin	
          h=histogram(cc,bin=bin,max=max,min=min,omax=hmax,omin=hmin,input=h)
    	  endelse
      endif  	
    endfor
    hx=findgen(n_elements(h))*bin+hmin
    hxe=0
    while (max(hx) ge 10) do begin
      hx=hx/10
    	hxe=hxe+1
    endwhile
    default,PDF_xtype,0
    default,PDF_xrange,[min(hx),max(hx)*1.05]
    default,PDF_yrange,[0.9,max(h)]	
    plot,hx,float(h),xstyle=1,xtype=PDF_xtype,xtit='Event max. amplitude !9X!X10!U'+i2str(hxe)+'!N',ytit='number of events',/noerase,$
        xrange=PDF_xrange,title='PDF of maximums of event signal',pos=[0.45,0.1,0.7,0.4],ytype=1,yrange=PDF_yrange,ystyle=1,$
        xtickformat='(F3.1)'
    if ((PDF_xrange(0) lt 0) and (PDF_xrange(1) gt 0)) then plots,[0,0],PDF_yrange,linestyle=1		
  endelse  	
endif    
   
if (not keyword_set(nopara)) then begin
  if (not keyword_set(testplot)) then begin
  	txt='shot: '+i2str(shot)								  
  	txt=txt+'!Ctimefile: '+timefile
  	if (n_elements(channels) eq 1) then begin
  	  txt=txt+'!CChannel: '+strtrim(string(channels(0)),2)
  	endif else begin
  	  txt=txt+'!CChannels:
  		for i=0,n_elements(channels)-1 do txt=txt+'!C  '+strtrim(string(channels(i)))
  	endelse
  	txt=txt+'!Ctres of signal: '+string(sampletime,format='(E8.2)')+' [s]'		
  	txt=txt+'!Ctres of corr.: '+string(corcor_time(1)-corcor_time(0),format='(E8.2)')+' [s]'		
  	txt=txt+'!Cintlen='+string(intlen,format='(E7.1)')+' [s]'
  	if (keyword_set(simulation)) then begin
  	  openr,unit,'data/'+i2str(shot,digits=5)+'_para.txt',/get_lun
  		txt1=''
  		readf,unit,txt1
  		close,unit & free_lun,unit
  		txt=txt+'!C'+txt1
  	endif	
  endif else begin
  	txt='test plot'
  	txt=txt+'!Cn_event: '+strtrim(string(test_n_event),2)								  
  	txt=txt+'!Cn_point: '+strtrim(string(test_n_point),2)
  	txt=txt+'!Cevent_amp: '+strtrim(string(test_event_amp),2)
    txt=txt+'!Cevent amplitude distribution: '+test_amp_distr
  	txt=txt+'!Cnoise_amp: '+strtrim(string(test_noise_amp),2)								  
  	txt=txt+'!CRMS fluct wo. noise: '+strtrim(string(flucamp1),2)								  
  	txt=txt+'!CRMS fluct w. noise: '+strtrim(string(flucamp2),2)								  
  	txt=txt+'!Ctres of signal: '+string(sampletime,format='(E8.2)')+' [!7l!Xs]'		
  	txt=txt+'!Ctres of event signal.: '+string(event.tres,format='(E8.2)')+' [!7l!Xs]'		
  	txt=txt+'!Cintlen='+string(intlen,format='(E7.1)')+' [s]'	  	
  	if (confidence ne 0) then begin
  	  txt=txt+'!CConfidence: '+strtrim(string(confidence),2)
  		if (keyword_set(uniform)) then txt=txt+'!C/uniform'
  	endif	
  endelse
  xyouts,0.72,0.4,txt,/normal	  	
endif

if (keyword_set(stop)) then stop
end
