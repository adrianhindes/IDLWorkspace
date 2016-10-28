pro show_event_corr,shot,timefile,timerange=timerange,event_timefile=event_timefile,$
          event_timerange=event_timerange,event_trange=event_trange,$
          event_tres=event_tres,channels=channels,refch=refch,intlen=intlen,$
					confidence=confidence,uniform=uniform,normalize=normalize,tres=tres,trange=trange,$
					avrsub=avrsub,stop=stop,test=test,nocalculate=nocalculate,plotrange=plotrange,$
          lcfs=lcfs,nopara=nopara,nolegend=nolegend
					
default,shot,43990
default,timefile,'43990test.time'
default,channels,defchannels(shot)
default,event_timefile,'43990on.time'
default,refch,18															  
default,intlen,8e-5
default,event_trange,[5,300]
default,event_tres,5
default,trange,[-600,600]
default,tres,20
default,avrsub,1
default,normalize,1
					
if (not keyword_set(nocalculate)) then begin
  nch=n_elements(channels) 
  
  refi=(where(channels eq refch))(0)
  for i=0,nch-1 do begin
    print,i2str(i+1)+'/'+i2str(nch)
    e=event_func(shot,event_timefile,channel=channels(i),tres=event_tres,trange=event_trange)
    e1={e1, time: e.time, func: e.func, trange: e.trange}
    if ((i eq 0) or (not keyword_set(test)) or (i eq refi)) then begin
  	  s=event_signal(shot,timefile,channel=channels(i),event=e,intlen=intlen,confidence=confidence,uniform=uniform)
  	endif	
  	if (not keyword_set(time) and keyword_set(s)) then begin
  	  sig=fltarr(n_elements(s.signal),nch)
  		time=s.time
  		event_arr=e1
  		ind1_list=s.ind1_list
  		ind2_list=s.ind2_list
  		tres_sig=(time(n_elements(time)-1)-time(0))/(n_elements(time)-1)/1e-6
  	endif
  	event_arr=[event_arr,e1]
  	if (keyword_set(avrsub)) then begin
  	  tot=0
  		ntot=0
  		for it=0,n_elements(ind1_list)-1 do begin
        tot=tot+total(s.signal(ind1_list(it):ind2_list(it)))
        ntot=ntot+(ind2_list(it)-ind1_list(it))+1
  		endfor	
  		s.signal=s.signal-tot/ntot
  	endif	
    sig(*,i)=s.signal
  endfor
    
  if (keyword_set(test)) then begin
    nnn=(size(sig))(1)
    for i=0,nch-1 do begin
  	  ind=lindgen(nnn)+(i-refi)*20
  		ind=ind > 0
  		ind=ind < nnn-1
  	  sig(*,i) = sig(ind,refi)
  	endfor
  endif		
    		
  					 
  if (trange(0) gt 0) then trange(0)=0		 
  if (trange(1) lt 0) then trange(1)=0		 
  print,'Calculating correlations...'
  tres=round(tres/tres_sig)*tres_sig							 						 
  trange(0)=-round(-trange(0)/tres)*tres
  trange(1)=round(trange(1)/tres)*tres
  nt=(trange(1)-trange(0))/tres+1
  shift_list=findgen(nt)*tres+trange(0)
  shift_list=shift_list/tres_sig
  minshift=min(shift_list)
  maxshift=max(shift_list)
  corr=fltarr(nt,nch)
  stot1=fltarr(nt,nch)
  stot2=float(0)
  refi=(where(channels eq refch))(0)
  nsig=(size(sig))(1)
  for it=0, n_elements(ind1_list)-1 do begin
  	sig2=sig(ind1_list(it)+(-minshift > 0) : ind2_list(it)-(maxshift > 0),refi)
  	stot2=stot2+total(sig2*sig2)
  	for i=0,nch-1 do begin
  	  for j=0,nt-1 do begin
  	    sig1=sig(ind1_list(it)+(-minshift > 0)+shift_list(j) : ind2_list(it)-(maxshift > 0)+shift_list(j),i)
  	    stot1(j,i)=stot1(j,i)+total(sig1*sig1)
  		  corr(j,i)=corr(j,i)+total(sig1*sig2)
  		endfor
  	endfor
  endfor 
  if (keyword_set(normalize)) then begin	
    if (stot2 eq 0) then begin
      ind=-1
  	endif else begin
  		ind=where(stot1 ne 0)
  	endelse 
  	w=corr
    corr=fltarr(nt,nch)
  	if (ind(0) ge 0) then corr(ind)=w(ind)/sqrt(stot2*stot1(ind))
  endif		
  corrt=shift_list*tres_sig
  loadxrr,xrr
  corrz=xrr(channels-1)
  save,file='tmp/show_event_corr.sav'
endif else begin
  restore,'tmp/show_event_corr.sav'
endelse 

pos1=[0.05,0.1,0.28,0.65]
pos=[0.35,0.1,0.9,0.65]

erase
if (not keyword_set(nolegend)) then time_legend,'show_event_corr.pro'

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
	xyouts,event_arr(i).trange(1)-(event_arr(i).trange(1)-event_arr(i).trange(0))/3,0.7,$
      '#'+i2str(channels(i))+' Z='+string(corrz(i),format='(F4.1)'),/data,charsize=0.6
endfor

trange=[min(corrt),max(corrt)]
zrange=[min(corrz),max(corrz)]
default,plotrange,[0,max(corr)]
default,nlev,20
default,levels,(findgen(nlev))/(nlev)*(plotrange(1)-plotrange(0))+plotrange(0)
if (!d.name eq 'PS') then default,colorscheme,'white-black' else default,colorscheme,'black-white'
setcolor,levels=levels,c_colors=c_colors,scheme=colorscheme																				  
sc=fltarr(2,50)
scale=findgen(50)/49*(max(corr)-min(corr))+min(corr)
sc(0,*)=scale
sc(1,*)=scale
charsize=1
contour,sc,[0,1],scale,levels=levels,nlev=nlev,/fill,$
  position=[pos(2)-0.03,pos(1),pos(2),pos(3)],$
  xstyle=1,xrange=[0,0.9],ystyle=1,yrange=[plotrange(0),plotrange(1)],xticks=1,$
  xtickname=[' ',' '],/noerase,c_colors=c_colors,charsize=0.7*charsize,xthick=axisthick,$
  ythick=axisthick,thick=linethick,charthick=axisthick
contour,corr,corrt,corrz,xrange=trange,xtitle='Time delay [microsec]',xstyle=1,$
  yrange=zrange,ytitle='Z [cm]',ystyle=1,$
  /noerase,/fill,charsize=charsize,xthick=axisthick,ythick=axisthick,thick=linethick,$
  nlev=nlev,levels=levels,ticklen=-0.025,charthick=axisthick,$
	position=pos-[0,0,0.1,0],c_colors=c_colors,$
  title='Ref ch: '+i2str(refch)+' (Z='+string(xrr(refch-1),format='(F4.1)')+'cm)'
if (keyword_set(lcfs)) then begin
  lcfs=get_lcfs(shot)
  plots,trange,[lcfs,lcfs],/data,linestyle=2
endif                          
  
plots,replicate(trange(1),nch)+(trange(1)-trange(0))/20,xrr(channels-1),psym=1

if (not keyword_set(nopara)) then begin
  txt='Shot: '+i2str(shot)
  if (not keyword_set(timerange)) then begin
    txt=txt+'!CTimefile: '+timefile
  endif else begin				 
    txt=txt+'!CTimerange: ['+string(timerange(0),format='(F5.3)')+','+$
  	       string(timerange(1),format='(F5.3)')+']'
  endelse
  if (not keyword_set(event_timerange)) then begin
    txt=txt+'!CEvent timefile: '+event_timefile
  endif else begin				 
    txt=txt+'!CEvent timerange: ['+string(event_timerange(0),format='(F5.3)')+','+$
  	       string(event_timerange(1),format='(F5.3)')+']'
  endelse
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
  txt=txt+'!CRef. channel: '+i2str(refch)
  txt=txt+'!Cintlen: '+strtrim(string(intlen,format='(E7.1)'),2)
  txt=txt+'!Ctres: '+i2str(tres)+' !7l!Xs'
  txt=txt+'!Ctrange: ['+i2str(trange(0))+','+i2str(trange(1))+'] !7l!Xs'
  if (keyword_set(avrsub)) then txt=txt+'!C/avrsub'
  if (confidence ne 0) then begin
    txt=txt+'!CConfidence: '+strtrim(string(confidence),2)
  	if (keyword_set(uniform)) then txt=txt+'!C/uniform'
  endif	
  if (keyword_set(normalize)) then txt=txt+'!C/normalize'
  xyouts,0.35,0.95,txt,/normal
endif

if keyword_set(stop) then stop
end


                                    
