PRO SHOW_TIMES,shot,channel_in,TIMEFILES=flist,TRANGE=trange,TIMERANGE=timerange,      $
    NOLEGEND=nolegend,COLOR=color,NOCALIBRATE=nocalibrate, $
    DATA_SOURCE=data_source,AFS=afs,ERRORPROC=errorproc,      $
    PROCTIMES=proctimes,MASK=mask,INTTIME=inttime,thick=thick,charsize=charsize


;***********************************************************************
; show_times.pro                 S. Zoletnik    1997
;***********************************************************************
; Program to plot a signal (Li-beam channel # <channel>) and show time
; intervals for the shot.
; proctimes and timefiles is not set then plots all
; timefiles for the given shot, otherwise plots only the timefiles listed
; inttime:      integration time in microsec for plotting signal
; and the proc. time of the correlation files listed in proctimes
; proctimes:    array of correlation file name for which the time windows
;     processed during the correlation calculation are to be plotted
; mask:     mask string for timefiles (Unix wildcars..)
;***********************************************************************

default,channel_in,'Li-18'
default,color,0
default,mask,'*'
default,nsum,10
default,inttime,100
if (defined(timerange)) then default,trange,timerange

setcolor,scheme='white-black'

; Convert channel to full signal name
signal_in = channel_in
get_rawsignal,shot,signal_in,/nodata,data_source=data_source
channel = channel_in

;if ((size(channel_in))(1) ne 7) then channel = 'Li-'+i2str(channel_in)     $
;          else channel = channel_in

if (not keyword_set(flist) and not keyword_set(proctimes)) then begin
  if (!version.os ne 'Win32') then begin
    if (data_source ne 5) then spawn,'cd time ; ls -1 '+i2str(shot)+mask,flist   $
         else spawn,'cd time; ls -1 AUG_'+i2str(shot)+mask,flist
  endif else begin
    ;n = (size(flist))(1)
    ;for i=0,n-1 do flist(i) = (str_sep(flist(i),'/'))(1)
    if (data_source ne 5) then spawn,'cd time & dir /b '+i2str(shot)+mask,flist     $
         else spawn,'cd time & dir /b AUG_'+i2str(shot)+mask,flist
  endelse
  if (flist(0) eq '') then begin
    txt = 'No timefiles found for shot '+i2str(shot)+' !'
    if (keyword_set(errorproc)) then call_procedure,errorproc,txt,/forward  $
          else print,txt
    return
  endif
endif else n = 0

if (keyword_set(flist)) then begin
  if ((size(flist))(0) eq 0) then flist = [flist]
  n = (size(flist))(1)
endif else n = 0

if (keyword_set(proctimes)) then begin
  if ((size(proctimes))(0) eq 0) then proctimes = [proctimes]
  nproc = (size(proctimes))(1)
  maxtn = 200
  proct1 = fltarr(maxtn,nproc)
  proct2 = fltarr(maxtn,nproc)
  procnlist = fltarr(nproc)
  for i=0,nproc-1 do begin
    load_zztcorr,shot,k,ks,z,t,file=proctimes(i),proct1=wt1,proct2=wt2,procn=procn
    if ((size(k))(0) eq 0) then begin
      txt = 'Cannot find file zzt/'+proctimes(i)
      if (keyword_set(errorproc)) then call_procedure,errorproc,txt,/forward    $
              else print,txt
      return
    endif
    default,wt1,0
    if ((size(wt1))(0) eq 0) then begin
      txt = 'No proc time data found in zzt/'+proctimes(i)
      if (keyword_set(errorproc)) then call_procedure,errorproc,txt,/forward    $
              else print,txt
      return
    endif
    if (procn gt maxtn-1) then begin
      txt = 'Too many time intervals!'
      if (keyword_set(errorproc)) then call_procedure,errorproc,txt,/forward    $
              else print,txt
      return
    endif
    proct1(0:procn-1,i) = wt1
    proct1(procn:maxtn-1,i) = wt1(0)
    proct2(0:procn-1,i) = wt2
    proct1(procn:maxtn-1,i) = wt2(0)
    procnlist(i) = procn
  endfor
endif else nproc = 0

if (not keyword_set(trange)) then begin
  trange = [1000,0.0]
  if (keyword_set(flist)) then begin
    for i=0,n-1 do begin
      d = loadncol('time/'+flist(i),2,/silent,errormess=e)
      if (e ne '') then begin
        print,e
        return
      endif
      mi = min([trange(0),min(d)])
      ma = max([trange(1),max(d)])
      trange(0) = mi
      trange(1) = ma
    endfor
  endif
  if (keyword_set(proctimes)) then begin
    trange(0) = min([trange(0),min(proct1)])
    trange(1) = max([trange(1),max(proct2)])
  endif
  d = (trange(1)-trange(0))/50
  trange = trange+[-d,d]
endif else begin
  trange = float(trange)
  if (keyword_set(proctimes)) then begin
    procmask = intarr(nproc)
    for i=0,nproc-1 do begin
      mi = min(proct1(0:procnlist(i)-1))
      ma = max(proct2(0:procnlist(i)-1))
      if (not ((ma le trange(0)) or (mi ge trange(1)))) then procmask(i) = 1
    endfor
    masktot = total(procmask)
    if (masktot ne 0) then begin
      proct1 = proct1(*,where(procmask ne 0))
      proct2 = proct2(*,where(procmask ne 0))
      procnlist = procnlist(*,where(procmask ne 0))
    endif else nproc = (size(procnlist))(1)
  endif else nproc = 0
  if (keyword_set(flist)) then begin
    flist_orig = flist
    n_orig = n
    n = 0
    for i=0,n_orig-1 do begin
      d = loadncol('time/'+flist_orig(i),2,/silent)
      mi = min(d)
      ma = max(d)
      if (not ((ma le trange(0)) or (mi ge trange(1)))) then begin
        if (n eq 0) then flist = [flist_orig(i)]          $
         else flist = [flist,flist_orig(i)]
        n = n+1
      endif
    endfor
  endif else n = 0
  if ((n eq 0) and (nproc eq 0)) then begin
    txt = 'No timefiles found for shot '+i2str(shot)+' in time range ['+    $
       string(trange(0),format='(F5.3)')+'-'+          $
       string(trange(1),format='(F5.3)')+'] !'
    if (keyword_set(errorproc)) then call_procedure,errorproc,txt,/forward  $
          else print,txt
    return
  endif
endelse

if (string(channel) eq 'W00') then READ_W00,shot,time,data          $
    else GET_RAWSIGNAL,shot,signal_in,time,rawdata,          $
       DATA_SOURCE=data_source,AFS=afs,ERRORMESS=errormess,   $
       TRANGE=trange,NOCALIBRATE=nocalibrate,DATA_NAMES=data_names,sampletime=sampletime
if (errormess ne '') then return
ind = where((time ge trange(0)) and (time le trange(1)))
time = time(ind)                   ; s
rawdata = rawdata(ind)
nsum = ROUND(inttime/(sampletime/1e-6))
if ((nsum mod 2) ne 1) then nsum = nsum+1
if (nsum gt 1) then begin
  data = SMOOTH(rawdata,nsum)
  ind = lindgen(long(n_elements(data)/nsum)-1)*nsum+fix(nsum/2)
  data = data[ind]
  time = time[ind]
endif else begin
  data = rawdata
endelse
data_min = MIN(data,MAX=data_max)
default,yrange,[data_min,data_max]


maxpoint = 5000
if ((size(time))(1) gt maxpoint) then begin
  time = interpol(time,maxpoint)
  data = interpol(data,maxpoint)
endif

if (n+nproc le 2) then nnn = 0.3
if ((n+nproc gt 2) and (n+nproc le 5)) then nnn = 0.5
if ((n+nproc gt 5) and (n+nproc le 10)) then nnn = 1.
if ((n+nproc gt 10)) then nnn = 3.
sep = (max(data)-min(data))/20
yrange = [min(data),max(data)+(max(data)-min(data))*nnn+sep]
erase
if (not keyword_set(nolegend)) then time_legend,'show_times.pro'
tit = i2str(shot)+'  '+signal_in
PLOT,time,data,/NOERASE,XTITLE='Time [s]',XRANGE=trange,/XSTYLE,    $
    YRANGE=yrange,/YSTYLE,POSITION=[0.1,0.1,0.8,0.8],TITLE=tit,thick=thick,charsize=charsize,$
    xthick=thick,ythick=thick,charthick=thick

if (keyword_set(color)) then setfigcol
dy = (max(data)-min(data))*nnn/(n+nproc)
for i=0,n+nproc-1 do begin
  if (keyword_set(color)) then col = (i mod 10)+1 else col = !p.color
  if (i lt n) then begin
    d = loadncol('time/'+flist(i),2,/silent)
    nn = (size(d))(1)
  endif else begin
    d = fltarr(procnlist(i-n),2)
    d(*,0) = proct1(0:procnlist(i-n)-1,i-n)
    d(*,1) = proct2(0:procnlist(i-n)-1,i-n)
    nn = procnlist(i-n)
  endelse
  y1 = max(data)+sep+i*dy
  y2 = max(data)+sep+i*dy+dy*0.6
  yy = [y1,y1,y2,y2]
  for ii=0,nn-1 do begin
    cutleft = 0
    cutright = 0
    if (not ((d(ii,1) lt trange(0)) or (d(ii,0) gt trange(1)))) then begin
      if (d(ii,0) lt trange(0)) then begin
        xx1 = [trange(0),trange(0),trange(0)-(trange(1)-trange(0))/20/(n+nproc)]
        yy1 = [y1,y2,(y2+y1)/2]
        polyfill,xx1,yy1,/data,color=col
        d(ii,0) = trange(0)
        cutleft = 1
      endif
      if (d(ii,1) gt trange(1)) then begin
        xx1 = [trange(1),trange(1),trange(1)+(trange(1)-trange(0))/20/(n+nproc)]
        yy1 = [y1,y2,(y2+y1)/2]
        polyfill,xx1,yy1,/data,color=col
        d(ii,1) = trange(1)
        cutright = 1
      endif
      xx = [d(ii,0),d(ii,1),d(ii,1),d(ii,0)]
      polyfill,xx,yy,/data,color=col
      if (not cutleft) then plots,[xx(0),xx(0)],[yrange[0],y1],/data,color=col,/LINE,thick=thick
      if (not cutright) then plots,[xx(1),xx(1)],[yrange[0],y1],/data,color=col,/LINE,thick=thick
    endif
  endfor
  if (i lt n) then begin
    xyouts,trange(1)+(trange(1)-trange(0))/30,y1,flist(i),color=col,/data,charsize=charsize,charthick=thick
  endif else begin
    xyouts,trange(1)+(trange(1)-trange(0))/30,y1,proctimes(i-n),color=col,/data,charsize=charsize,charthick=charthick
  endelse
  plots,[trange(0),trange(1)+(trange(1)-trange(0))/40],[y1,y1],color=col
  plots,[trange(0),trange(1)+(trange(1)-trange(0))/40],[y2,y2],color=col
endfor

end
