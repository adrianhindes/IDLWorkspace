pro show_event,shot,timefile,timerange=timerange,event_timefile=event_timefile,$
          event_timerange=event_timerange,event_trange=event_trange,$
          event_tres=event_tres,channels=channels,intlen=intlen,$
					confidence=confidence,uniform=uniform,tres=tres,avrsub=avrsub
					
default,shot,43990
if (not keyword_set(timerange)) then default,timefile,'43990test.time'
default,channels,defchannels(shot)
default,event_timefile,'43990on.time'
default,intlen,8e-5
default,event_trange,[5,300]
default,event_tres,5
default,tres,20e-6
					
nch=n_elements(channels) 

for i=0,nch-1 do begin
  print,i2str(i+1)+'/'+i2str(nch)
  e=event_func(shot,event_timefile,channel=channels(i),tres=event_tres,trange=event_trange)
  e1={e1, time: e.time, func: e.func, trange: e.trange}
	s=event_signal(shot,timefile,channel=channels(i),event=e,intlen=intlen,confidence=confidence,uniform=uniform,timerange=timerange)
	if (not keyword_set(time) and keyword_set(s)) then begin
	  sig=fltarr(n_elements(s.signal),nch)
		time=s.time
		event_arr=e1
		ind1_list=s.ind1_list
		ind2_list=s.ind2_list
		tres_sig=(time(n_elements(time)-1)-time(0))/(n_elements(time)-1)
	endif
	event_arr=[event_arr,e1]
	if (keyword_set(avrsub)) then begin
	  tot=0
		ntot=0
		for it=0,n_elements(ind1_list)-1 do begin
      tot=tot+total(s.signal(ind1_list(it):ind2_list(it)))
      ntot=ntot+(ind2_list(it)-ind1_list(it))+1
		endfor	
		for it=0,n_elements(ind1_list)-1 do begin
      s.signal(ind1_list(it):ind2_list(it))=s.signal(ind1_list(it):ind2_list(it))-tot/ntot
		endfor	
	endif	
  sig(*,i)=s.signal
endfor
  
mult=round(tres/tres_sig)
if ((mult mod 2) eq 0) then mult=mult+1
tres=tres_sig*mult
nt=long((size(sig))(1)/mult)
ind=lindgen(nt)*mult+fix(mult/2)
sig_sm=fltarr(nt,nch)
for i=0,nch-1 do begin
  sig1=sig(*,i)
	if (mult gt 1) then sig1=smooth(sig1,mult)
	sig_sm(*,i)=sig1(ind)
	if (i eq 0) then begin
    if (mult gt 1) then time_sm=smooth(time,mult) else time_sm=time
		time_sm=time_sm(ind)
	endif	
endfor
			 
loadxrr,xrr

pos1=[0.05,0.05,0.25,0.95]
pos=[0.35,0.1,0.9,0.65]											   

erase
if (not keyword_set(nolegend)) then time_legend,'show_event.pro'

ncol=2
if ((nch mod ncol) eq 0) then nrow=nch/ncol else nrow=fix(nch/ncol)+1
maxt=max(event_arr(0).time)
if (maxt lt 50) then ticksep=10
if ((maxt ge 50) and (maxt lt 100)) then ticksep=20
if ((maxt ge 100) and (maxt lt 500)) then ticksep=100
if ((maxt ge 500)) then ticksep=200
ticks=maxt/ticksep+1
tickv=findgen(ticks-1)*ticksep
for i=0,nch-1 do begin 
  col=fix(i/nrow)
	row=(i mod nrow)
  x1=pos1(0)+(pos1(2)-pos1(0))/ncol*col
  x2=x1+(pos1(2)-pos1(0))/ncol
  y1=pos1(3)-(pos1(3)-pos1(1))/nrow*(row+1)
	y2=y1+(pos1(3)-pos1(1))/nrow
	if ((row eq nrow-1) or (i eq nch-1)) then begin
	  plot,event_arr(i).time,event_arr(i).func,xrange=[0,event_arr(i).trange(1)],xstyle=1,$
		     ystyle=1,ytickname=replicate(' ',10),/noerase,$
				 position=[x1,y1,x2,y2],charsize=0.6,xticks=ticks,xtickv=tickv,xtitle='Time lag [!7l!Xs]'
	endif else begin			 
	  plot,event_arr(i).time,event_arr(i).func,xrange=[0,event_arr(i).trange(1)],xstyle=1,$
		     xtickname=replicate(' ',10),ystyle=1,ytickname=replicate(' ',10),/noerase,$
				 position=[x1,y1,x2,y2],xticks=ticks,xtickv=tickv
	endelse		 
	xyouts,event_arr(i).trange(1)-(event_arr(i).trange(1)-event_arr(i).trange(0))/5,0.7,i2str(channels(i)),/data,charsize=0.6
endfor
								  							  
z_vect=xrr(channels-1)
trange=[min(time_sm),max(time_sm)]
zrange=[z_vect(0)-(z_vect(1)-z_vect(0))/2,z_vect(nch-1)+(z_vect(nch-1)-z_vect(nch-2))/2]
plot,time_sm,z_vect,xstyle=1,xrange=trange,ystyle=1,yrange=zrange,xtitle='Time [s]',ytitle='Z [cm]',$
  /nodata,/noerase,position=pos,ticklen=-0.02
plots,replicate(trange(1),nch)+(trange(1)-trange(0))/20,xrr(channels-1),psym=1,/data
					 
ncol=!d.n_colors < 250	

if (keyword_set(avrsub)) then sig_sm=sig_sm-min(sig_sm)
if (!d.name eq 'PS') then begin
  sig_sm=(max(sig_sm)-sig_sm)/max(sig_sm)*ncol
	sig_sm = sig_sm > 0
	sig_sm = sig_sm < ncol
endif else begin
  sig_sm=sig_sm/max(sig_sm)*ncol>0
endelse		
otv,sig_sm	


txt='shot: '+i2str(shot)
if (not keyword_set(timerange)) then begin
  txt=txt+'!Ctimefile: '+timefile
endif else begin				 
  txt=txt+'!Ctimerange: ['+string(timerange(0),format='(F5.3)')+','+$
	       string(timerange(1),format='(F5.3)')+']'
endelse
if (not keyword_set(event_timerange)) then begin
  txt=txt+'!Cevent_timefile: '+event_timefile
endif else begin				 
  txt=txt+'!Cevent_timerange: ['+string(event_timerange(0),format='(F5.3)')+','+$
	       string(event_timerange(1),format='(F5.3)')+'] s'
endelse
txt=txt+'!Cevent_tres: '+i2str(event_tres)+' !7l!Xs'
  txt=txt+'!Cevent_trange: ['+i2str(event_trange(0))+','+$
	       i2str(event_trange(1))+'] !7l!Xs'
txt=txt+'!CChannels:'
nn=0
l=n_elements(channels)
for i=0,l-1 do begin
  txt=txt+i2str(channels(i))
  if (i ne (l-1)) then begin
    txt=txt+','
    nn=nn+1
    if (nn ge 8) then begin
      txt=txt+'!C         '
      nn=0
    endif
  endif
endfor
txt=txt+'!Cintlen: '+strtrim(string(intlen,format='(E7.1)'),2)+' s'
txt=txt+'!Ctres: '+strtrim(string(tres,format='(E7.1)'),2)+' s'
if (keyword_set(avrsub)) then txt=txt+'!C/avrsub'
if (confidence ne 0) then begin
  txt=txt+'!CConfidence: '+strtrim(string(confidence),2)
	if (keyword_set(uniform)) then txt=txt+'!C/uniform'
endif	
xyouts,0.35,0.95,txt,/normal

if keyword_set(stop) then stop
end


                                    
