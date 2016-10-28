pro autocorr_vs_time,shot,trange=trange,autotime=autotime,tres=tres,channels=channels,$
    taures=taures,taurange=taurange,title=title,data_source=data_source,$
    verbose=verbose,errormess=errormess,$
    afs=afs,cdrom=cdrom,silent=silent,colorscheme=colorscheme,$
    nolegend=nolegend,nopara=nopara,crange=crange,$
    nocalculate=nocalculate,noscale=noscale,savefile=savefile,normalise=normalise,$
    cut_length=cut_length,extrapol_length=extrapol_length,chopper_level=chopper_level,$
    show_chopper=show_chopper,percent=percent  

; *********************** AUTOCORR_VS_TIME.PRO ******** S. Zoletnik 30.05.2002 *****

; Plots autocorrelation function vs. time.
; INPUT:
;   channel; channel(s) to use
;   data_source: as in get_rawsignal.pro
;   trange: time range to plot [s]
;   /autotime: automatically select time interval (trange) between min and max 
;   tres: time resolution
;   taurange: time lag range  [microsec]
;   taures: time lag resolution [microsec]
;   /nocalculate: Do not calculate, just repeat plot with last
;                 calculation result 
;   savefile: name of file in which calculation results will be
;               written 
;   /normalise: normalise correlation functions
;   cut_length, extrapol_length: see crosscor_new.pro
;   crange: correlation range
;   /noscale: do not plot color scale
;   title: title of plot
;   chopper_level: the relative amplitude between max and min below
;                    which the signal is considered to be background
; ----> see generally used parameters in "general_conventions.txt"
; ****************************************************************************
  
default,channel,18
default,trange,[0,1]
default,tres,float(trange(1)-trange(0))/20
default,savefile,'autocorr_vs_time.sav'
default,taures,5
default,taurange,[-300,300]
default,data_source,0
default,colorscheme,'blue-white-red'
default,chopper_level,0
default,inttime,2e-4   ; integration time for chopper determination

errormess=''

forward_function dispatch_error

if (keyword_set(autotime)) then begin
  get_rawsignal,shot,channels[0],t,d,data_source=data_source,errormess=errormess
  if (errormess ne '') then begin
    print,errormess
    return
  endif  
  trange=[min(t),max(t)]
endif  

trange=float(trange)
tres= float(tres)

if (not keyword_set(nocalculate)) then begin

  if (trange[0] ge trange[1]) then begin
    errormess = 'Bad time range.'
    if (dispatch_error(errormess,silent=silent)) then return
  endif  
  
  if (tres gt (trange[1]-trange[0])/2) then begin
    errormess = 'Bad time resolution.'
    if (dispatch_error(errormess,silent=silent)) then return
  endif  
    
  n_int = long((trange(1)-trange(0))/tres) > 1
  n_ch = n_elements(channels)

  n_points = 0
  for i=0,n_int-1 do begin
    if (keyword_set(verbose)) then print,i2str(i+1)+'/'+i2str(n_int)

    tr = trange[0]+[i,i+1]*tres
    if (chopper_level gt 0) then begin
      ss = 0
      for ich=0,n_ch-1 do begin 
        ds = data_source
        errormess=''
        get_rawsignal,shot,channels[ich],t,d,data_source=ds,errormess=erormess,trange=tr+[-inttime,inttime]
        if (dispatch_error(errormess)) then return
        ss = ss+d
      endfor
      intn = inttime/(t[1]-t[0])
      ss = smooth(ss,intn)
      t = t[intn:n_elements(ss)-intn]
      ss = ss[intn:n_elements(ss)-intn]
      if (keyword_Set(show_chopper)) then begin
        plot,t,ss
      endif
      level = (max(ss)-min(ss))*chopper_level+min(ss)
      timefile = '@auto_ontime@'
      mintime = 0.002        ; minimum on time length
      openw,unit,'time/'+timefile,/get_lun
      nt = 0
      pos = 0
      nd = n_elements(ss)
      while (pos lt nd) do begin
        ind = where(ss[pos:nd-1] gt level)
        if (ind[0] ge 0) then begin
          start = ind[0]+pos
          ind = where(ss[start:nd-1] lt level)
          if (ind[0] ge 0) then begin
            stop = ind[0]-1+start
            if (t[stop]-t[start] gt mintime) then begin
              start_time=t[start]+mintime/4
              stop_time=t[stop]-mintime/4
             printf,unit,string(start_time)+' '+string(stop_time)
              if (keyword_Set(show_chopper)) then begin
                print,nt,string(start_time)+' '+string(stop_time)
                oplot,[start_time,start_time],!y.crange
                oplot,[stop_time,stop_time],!y.crange
                if (not ask('Continue')) then stop
              endif
              nt = nt+1
              pos = stop+1
            endif
            pos = stop+1
          endif else begin
            pos = nd
          endelse
        endif else begin 
          pos = nd
        endelse
      endwhile
      tr = 0
      close,unit & free_lun,unit
    endif
    ds = data_source
   
    crosscor_new,shot,timefile,timerange=tr,ref=channels,plot=channels,data_source=ds,$
       errormess=errormess,norm=normalise,$
       outcorr=outcorr,outtime=outtime,tres=taures,trange=taurange,interval_n=1,$
       cut_length=cut_length,extrapol_length=extrapol_length,/noplot,/noverbose,percent=percent,/silent,/noerror
    if (not dispatch_error(errormess,silent=silent)) then begin
      if (not defined(c)) then begin
        n_c = n_elements(outcorr)
        c =fltarr(n_int,n_elements(outcorr))
        t_c = outtime
      endif else begin
        if ((n_elements(outcorr) ne n_c) or (total(outtime ne t_c) ne 0)) then begin
          errormess = 'Time vector of correlation functions are not identical.'
          if (dispatch_error(errormess,silent=silent)) then return
        endif
      endelse
      c[i,*] = outcorr
    endif else begin
      return
    endelse      
  endfor

  tscale = (findgen(n_int)+0.5)*tres+trange(0)
  save,file='tmp/'+savefile
endif else begin
  if (keyword_set(crange)) then crange_save=crange
  if (keyword_Set(colorscheme)) then colorscheme_save = colorscheme
  restore,'tmp/'+savefile
  if (keyword_Set(colorscheme_save)) then colorscheme=colorscheme_save
 if (keyword_set(crange_save)) then crange=crange_save
endelse  


pos = [0.1,0.2,0.6,0.7]

erase
if (not keyword_set(nolegend)) then time_legend,'autocorr_vs_time.pro'
default,crange,[min(c),max(c)],/nullarray
nlev=100
default,levels,(findgen(nlev))/(nlev)*(crange[1]-crange[0])+crange[0]
setcolor,levels=levels,c_colors=c_colors,scheme=colorscheme
  
if (not defined(title)) then begin
  title = '#'+i2str(shot)+'  channel='+string(channels[0])
  if (n_elements(channels) ne 1) then title=title+'...'+string(channels[n_elements(channels-1)])
endif
contour,c,tscale,t_c,xrange=trange,xstyle=1,xtitle='Time [s]',xticklen=-0.02,$
    yrange=taurange,ystyle=1,ytitle='Time lag[ microsec]',yticklen=-0.02,$
    /noerase,title=title,position=pos,c_colors=c_colors,levels=levels,/fill


if (not keyword_set(noscale)) then begin
  pos_scale=[pos(2)+0.1,pos(1),pos(2)+0.13,pos(3)]
  sc=fltarr(3,100)
  scale=findgen(100)/99*(max(c)-min(c))+min(c)
  sc(0,*)=scale
  sc(1,*)=scale
  sc(2,*)=scale
  if (keyword_set(percent)) then ytitle='%' else ytitle=''
  contour,sc,[0,1,2],scale,xrange=[0,2],xstyle=1,xticks=1,yrange=crange,xtickname=replicate(' ',3),$
    ystyle=1,yticklen=-0.02,/noerase,position=pos_scale,c_colors=c_colors,levels=levels,/fill,ytitle=ytitle
endif

if (not keyword_set(nopara)) then begin
  txt = 'Shot: '+i2str(shot,digits=5)
  txt = txt+'!Ctime res.: '+string(tres,format='(E10.2)')+' [s]'       
  txt = txt+'!Ctau. res.: '+string(taures,format='(F5.1)')+' [microsec]'
  if (keyword_set(cut_length)) then txt=txt+'!Ccut_length='+string(cut_length,format='(F4.1)')+'[microsec]'
  if (keyword_set(normalise)) then txt=txt+'!C/normalise'
  get_rawsignal,shot,data_names=data_names
  txt = txt+'!Cdata_source: '+i2str(data_source)+'!C     ('+data_names[data_source]+')'
  if (keyword_set(percent)) then txt = txt+'!C/percent'
  
  plots,[pos(2),pos(2)]+0.15,[pos(1),0.8],thick=1,/normal
  xyouts,pos(2)+0.16,0.8,/normal,txt
endif             

end
