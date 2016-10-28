pro auto_plot,shot,timefile,tres=tres,trange=trange,yrange=yr,noerror=noerror,$
channels=channels,nocalculate=nocalculate,nocalibrate=nocalibrate,$
cut_length=cut_length,file=file,rec=rec,nolegend=nolegend,errorproc=errorproc,$
afs=afs,norm=norm,errormess=errormess,nopara=nopara,title=title,nolock=nolock

;***************************************************************************
; auto_plot.pro                     S. Zoletnik 1998
;**************************************************************************
; Plots autocorrelation function of Li-beam signals or reconstructed density
; at many places.
; Can calculate the autocorrelations or load from a zzt file. (See zztcorr.pro)
;
; INPUT:
;   shot: shot number
;   timefile: Timefile
;   tres: time lag resolution in microsec
;   trange: time lag range in microsec
;   yrange: vertical plot range
;   /noerror: do not plot error bars
;   channels: list of channels to process
;   /nocalculate: repeat last plot without calculating
;   /nocalibrate: use uncalibrated data
;   cut_length: cut_length for photon_cut
;   file: name of zzt file to load
;   /rec: process reconstructed density fluctuation data
;   errorproc: name of error handling process (used if called from GUI)
;   /afs: take data from afs
;   /norm: plot normalised correlations
;   errormess: error message or ''
;   title: title of plot
;   /nopara: do not print parameters on plot
;   /nolegend: do not print legend (time and name of program)
;   /nolock: do not lock zzt directory while reading
;************************************************************************

default,title,''

if (not keyword_set(nocalculate)) then begin
  default,timefile,i2str(shot)+'on.time'
	default,channels,defchannels(shot)
	chn=(size(channels))(1)
	default,tres,11
	default,trange_in,[-150,150]
  default,cut_length,5

  if (keyword_set(rec)) then begin
    trange_f=trange_in
    load_zztcorr,shot,k,ks,z,t,timefile=timefile,tres=tres,trange=trange_f,$
        cut_length=cut_length,file=file,/rec,para_txt=para_txt,nolock=nolock
	  if ((size(k))(0) ne 3) then begin
      print,'auto_plot.pro : Cannot find density autocorrelation data.'
      return
    endif
    chn=(size(z))(1)
  endif else begin
    load_zztcorr,shot,k,ks,z,t,timefile=timefile,tres=tres,trange=trange_f,$
        cut_length=cut_length,channels=channels,file=file,para_txt=para_txt,nolock=nolock,$
        data_source=data_source
  endelse
  if (keyword_set(norm)) then begin
    norm_k,k,ks,z,t,errormess=errormess
    if (errormess ne '') then return
  endif


  nofile=0
	if ((size(k))(0) ne 3) then begin
    if (not keyword_set(nocalibrate)) then cal=getcal(shot)
    nofile=1
	endif

default,trange,trange_f
	for i=0,chn-1 do begin
	if ((size(k))(0) ne 3) then begin
		print,'Channel:'+i2str(channels(i))
			crosscor_new,shot,timefile,plotchan=channels(i),refchan=channels(i),$
			    tres=tres,trange=trange,/noverbose,/noplot,$
			    outtime=outtime,outcorr=outcorr,outscat=outscat,$
				  cut_length=cut_length,afs=afs,norm=norm
			if (not keyword_set(nocalibrate)) then begin
			  outcorr=outcorr*(cal(channels(i)-1)^2)
			  outscat=outscat*(cal(channels(i)-1)^2)
			endif
		endif else begin
      ind=where((t ge trange(0)) and (t le trange(1)))
      if (ind(0) lt 0) then begin
        txt='No data found in time range. Error in AUTO_PLOT.PRO.'
        if (keyword_set(errorproc)) then begin
          call_procedure,errorproc,txt
        endif else begin
          print,txt
        endelse
        return
      endif
		  outtime=t(ind)
			outcorr=outtime
			outcorr(*)=k(i,i,ind)
			outscat=outtime
			outscat(*)=ks(i,i,ind)
		endelse
	  if (i eq 0) then begin
		  tn=(size(outtime))(1)
			t_arr=fltarr(chn,tn)
			c_arr=fltarr(chn,tn)
			s_arr=fltarr(chn,tn)
		endif
		t_arr(i,*)=outtime
		c_arr(i,*)=outcorr
		if (not keyword_set(noerror)) then s_arr(i,*)=outscat
	endfor
	if (not lmgr(/demo)) then save,file='tmp/auto_plot.sav'
endif else begin
  if (not lmgr(/demo)) then restore,'tmp/auto_plot.sav'
endelse

if (chn gt 30) then begin
	coln=6
	rown=6
endif
if ((chn gt 24) and (chn le 30))  then begin
	coln=6
	rown=5
endif
if ((chn le 24) and (chn gt 20)) then begin
	coln=6
	rown=4
endif
if ((chn le 20) and (chn gt 16)) then begin
	coln=5
	rown=4
endif
if ((chn le 16) and (chn gt 12)) then begin
	coln=4
	rown=4
endif
if ((chn le 12) and (chn gt 9)) then begin
	coln=4
	rown=3
endif
if ((chn le 9) and (chn gt 6)) then begin
	coln=3
	rown=3
endif
if ((chn le 6) and (chn gt 4)) then begin
	coln=3
	rown=2
endif
if (chn le 4) then begin
	coln=2
	rown=2
endif

if (keyword_set(nopara)) then pos=[0.1,0.05,0.90,0.9] else pos=[0.1,0.05,0.7,0.9]
xstep=(pos(2)-pos(0))/coln
ystep=(pos(3)-pos(1))/rown
erase
if (not keyword_set(nolegend)) then time_legend,'auto_plot.pro'
if (keyword_set(title)) then xyouts,0.1,0.93,title,/normal

if (cut_length eq 0) then begin
  ind=where((outtime gt 5) or (outtime lt -5))
endif else begin
  ind=findgen((size(outtime))(1))
endelse

default,yr,[min(c_arr(*,ind)-s_arr(*,ind)),max(c_arr(*,ind)+s_arr(*,ind))]
if (yr(0) gt 0) then yr(0)=0

; beam_coordinates,shot,RR,ZZ,xrr,data_source=data_source
; loadxrr,xrr,data_source=data_source

if (not keyword_set(para_txt)) then begin
  para_txt='shot: '+i2str(shot)+'!C'
  if (keyword_set(rec)) then para_txt=para_txt+'Density' else para_txt=para_txt+'Light'
  para_txt=para_txt+' autocorrelations!Ctimefile:'+timefile+'!Ctau resolution: '+i2str(tres)
  if (keyword_set(nocalibrate)) then para_txt=para_txt+'!C/nocalibrate'
endif
if (not keyword_set(nopara)) then begin
  plots,[pos(2)+0.02,pos(2)+0.02],[0.1,0.9],thick=3,/normal
  xyouts,pos(2)+0.04,0.85,para_txt,/normal
endif

for i=0,chn-1 do begin
  rn=fix(i/coln)
  cn=(i mod coln)

  x=pos(0)+cn*xstep
  y=pos(1)+(rown-1-rn)*ystep
  pos1=[x,y,x+xstep*0.8,y+ystep*0.8]
	tickn=replicate(' ',20)
	if (cn eq 0) then ytickn='' else ytickn=replicate(' ',20)
	if (rn eq rown-1) then begin
    xtit='Time [microsec]'
		xtickn=''
	endif else begin
    xtit=''
		xtickn=replicate(' ',20)
	endelse
  if (keyword_set(rec)) then begin
    tit='Z='+string(z(i),format='(F4.1)')
  endif else begin
    tit='Ch:'+i2str(channels(i))+' Z='+string(z(i),format='(F4.1)')
  endelse
	plot,t_arr(i,*),c_arr(i,*),xrange=trange,xstyle=1,xtitle=xtit,$
	  yrange=yr,ystyle=1,title=tit,$
		/noerase,pos=pos1,charsize=0.7,xtickname=xtickn,ytickname=ytickn
	if (yr(0) lt 0)	then oplot,trange,[0,0],linestyle=2
	if (not keyword_set(noerrror)) then begin
	  s1=c_arr(i,*)-s_arr(i,*)
	  s2=c_arr(i,*)+s_arr(i,*)
		ind=where((s1 ge yr(0)) and (s2 le yr(1)))
		if ((size(ind))(0) ne 0) then begin
	    errplot,t_arr(i,ind),c_arr(i,ind)-s_arr(i,ind),c_arr(i,ind)+s_arr(i,ind)
		endif
	endif
endfor

end
