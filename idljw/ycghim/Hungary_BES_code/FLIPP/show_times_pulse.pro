pro show_times_pulse,shot,channel_in,errorproc=errorproc,$
         nolegend=nolegend,data_source=data_source,afs=afs,$
         trange=trange,timefile=timefile,yrange=yrange,wait=wait,single=single
;***********************************************************************
; show_times_pulse.pro                 S. Zoletnik    15.03.2001
;***********************************************************************
; Program to overplot signal in each time window of a timefile.
; It is assumed that all time windows are of equal length.
; This program was written to analyse timefiles for Blow-off fluctuation measurement
; INPUT:
;   channel_in: channel name (Default: Blo-1)
;   errorproc: error processing procedure
;   data_source: data_source as defined in get_rawsignal.pro (def: 8)
;   trange: Time offsets relative to the time interval starts and ends
;               (Def: 20% of timewindow length on both ends)
;   timefile: name fo timefile
;   
;***********************************************************************

default,data_source,8
default,channel_in,'Blo-1'

setcolor,scheme='white-black'

if (data_source eq 8) then begin
  if ((size(channel_in))[1] ne 7) then channel='Blo-'+i2str(channel_in) else channel=channel_in
endif else begin
  if ((size(channel_in))[1] ne 7) then channel='Li-'+i2str(channel_in) else channel=channel_in
endelse

time=loadncol(dir_f_name('time',timefile),2,/silent)
if (n_elements(time) eq 1) then begin
  txt='Cannot open timefile '+timefile
  if (keyword_set(errorproc)) then begin
    call_procedure,errorproc,txt,/forward
  endif else begin
    print,txt
  endelse
  return
endif

nt=(size(time))[1]

d0 = time[0,1]-time[0,0]
for i=1,nt-1 do begin
  di = time[i,1]-time[i,0]
  
  if (abs(di-d0) gt abs(d0)/100) then begin
    txt='Time intervals are of different length in timefile '+timefile
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,txt,/forward
    endif else begin
      print,txt
    endelse
    return
  endif
endfor
     
tr = [time[0,0], time[0,1]]
len = tr[1]-tr[0]
default,trange,[-len*0.2,len*0.2]
tr = tr + trange


get_rawsignal,shot,channel,t,d,errorproc=errorproc,data_source=data_source,$
        afs=afs,trange=[min(time)+trange[0],max(time)+trange[1]]
if (n_elements(t) le 1) then return        

if (not keyword_set(yrange)) then begin
  yrange=[max(d),min(d)]

  for i=0,nt-1 do begin
    offs = time[i,0]-time[0,0]
    ind = where((t ge time[0,0]+trange[0]+offs) and (t le time[0,1]+trange[1]+offs))
    if (ind[0] lt 0) then begin
      txt='No data in time interval '+i2str(i+1)
      if (keyword_set(errorproc)) then begin
        call_procedure,errorproc,txt,/forward
      endif else begin
        print,txt
      endelse
      return
    endif
    yrange[0] = min([yrange[0],min(d[ind])])
    yrange[1] = max([yrange[1],max(d[ind])])
  endfor
endif

pos = [0.15,0.15,0.8,0.8]

if (not keyword_set(single)) then begin
  erase
  if (not keyword_set(nolegend)) then time_legend,'show_times_pulse.pro'
  plot,tr*1000.,[0,0],/nodata,/noerase,pos=pos,yrange=yrange,ystyle=1,xstyle=1,$
     xtitle='Time in first interval [ms]',title='Channel: '+channel
  plots,[time[0,0],time[0,0]]*1000.,yrange
  plots,[time[0,1],time[0,1]]*1000.,yrange
endif


for i=0,nt-1 do begin
  offs = time[i,0]-time[0,0]
  ind = where((t ge time[0,0]+trange[0]+offs) and (t le time[0,1]+trange[1]+offs))
  if (ind[0] lt 0) then begin
    txt='No data in time interval '+i2str(i+1)
    if (keyword_set(errorproc)) then begin
      call_procedure,errorproc,txt,/forward
    endif else begin
      print,txt
    endelse
    return
  endif
  
  if (keyword_set(single)) then begin
    plot,tr*1000.,[0,0],/nodata,pos=pos,yrange=yrange,ystyle=1,xstyle=1,$
      xtitle='Time in first interval [ms]',title='Channel: '+channel+' pulse:'+i2str(i+1)
    plots,[time[0,0],time[0,0]]*1000.,yrange
    plots,[time[0,1],time[0,1]]*1000.,yrange
  endif
  oplot,(t[ind]-offs)*1000.,d[ind]
  if (keyword_set(wait)) then if (not ask('Continue ?')) then stop 
  
endfor


if (not keyword_set(nopara)) then begin
  plots,[pos[2]+0.03,pos[2]+0.03],[0.1,0.9],thick=3,/normal
  para_txt = 'Shot: '+i2str(shot)
  para_txt = para_txt+ '!CTimefile: '+timefile
  para_txt = para_txt+ '!CNumber of intervals:!C   '+i2str(nt)
  xyouts,pos[2]+0.04,0.85,para_txt,/normal
endif





end
