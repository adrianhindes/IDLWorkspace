pro show_kstar_mean_row_correlations,shot,timerange=timerange,savefile=savefile,columns=columns,taurange=taurange,taures=taures,$
    filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,nocalculate=nocalculate,rows=rows,$
    nolegend=nolegend,thick=thick,charsize=charsize,maxrange=maxrange,timefile=timefile,r_scale=r_scale,v_pol=vpol,vrange=vrange

; Calculate and plot the mean correlation function between consecutive channels in a column
; and plot the time delay as a function of column or radius. Also plots the correlation functions.
; The correlation is calculated between rows 1-2, 2-3, ...
;
; INPUT:
; shot:  Shot number
; timerange: Time range
; timefile: Alternative to timereange
; /r_scale: Plot on R scale rather then versus column
; /v_pol: Plot poloidal velocity instead of time delay
; rot_image: Rotate BES image by this degree
; columns: List of columns to process (1...)
; rows: The rows to process (1...)
; taurange: Time lag range for correlation functions in microsec
; maxrange: Plot range of the time delay [microsec]
; vrange: Plot range of the velocity [km/s]
; taures: Time lag resolution in microsec
; filter_low, filter_high, filter_order: Bandpass filter parameters
; /nocalculate: do not caluclate just plot last results load from savefile.
; savefile: The file into which calculation results are saved or loaded from.
;           (default is tmp/<shot>_mean_row_correlations.sav)
;


default,columns,[1,2,3,4,5,6,7,8]
default,rows,[1,2,3,4]
default,savefile,dir_f_name('tmp',i2str(shot)+'_mean_row_correlations.sav')
default,charsize,1
default,thick,1
default,taurange,[-30,30]
default,maxrange,taurange
default,interval_n,1
default,rot_deg,18.

if (not keyword_set(nocalculate)) then begin
  ncol = n_elements(columns)
  nrow = n_elements(rows)
  if (keyword_set(timefile)) then begin
    d=loadncol(dir_f_name('time',timefile),2)
    timerange_read = [min(d),max(d)]
  endif else begin
    timerange_read = timerange
  endelse
  for icol=0,ncol-1 do begin
    for irow=0,nrow-2 do begin
      if (irow eq 0) then begin
        signal_name_1 = 'BES-'+i2str(rows[irow])+'-'+i2str(columns[icol])
        cs1 = i2str(shot)+'_'+signal_name_1
        s1 = signal_name_1
        print,'Reading '+s1
        wait,0.1

        get_rawsignal,shot,s1,timerange=timerange_read,cache=cs1,errormess=errormess,/nocalib
        if (errormess ne '') then begin
          print,errormess
          return
        endif
      endif else begin
        signal_cache_delete,name=cs1
        signal_name_1 = signal_name_2
        cs1 = cs2
      endelse

      signal_name_2 = 'BES-'+i2str(rows[irow+1])+'-'+i2str(columns[icol])
      cs2 = i2str(shot)+'_'+signal_name_2
      s2 = signal_name_2
      print,'Reading '+s2
      wait,0.1
      get_rawsignal,shot,s2,timerange=timerange_read,cache=cs2,errormess=errormess,/nocalib
      if (errormess ne '') then begin
        print,errormess
        return
      endif
      fluc_correlation,shot,timefile,shot,ref='cache/'+cs1,plotcha='cache/'+cs2,timerange=timerange,$
           taurange=taurange,taures=taures,filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,$
           /noplot,outt=tauscale,outcorr=outcorr,outscat=outcorr_scat,errormess=errormess,/norm,/nocalib,/silent,interval_n=interval_n
      if (errormess ne '') then begin
        print,errormess
        return
      endif
      if (not defined(outcorr_sum)) then begin
        outcorr_sum = fltarr(ncol,n_elements(outcorr))
      endif
      outcorr_sum[icol,*] = outcorr_sum[icol,*]+outcorr
    endfor ; row
  endfor ; column
  save,shot,timefile,timerange,columns,rows,taures,filter_low,filter_high, filter_order, tauscale,outcorr_sum,file=savefile
endif else begin ; if nocalculate
  restore,savefile
endelse

default,ncol,n_elements(columns)
default,nrow,n_elements(rows)

detpos=getcal_kstar_spat(shot,/trans)
if (defined(rot_deg)) then begin
  detpos_0 = total(total(detpos,1),1)/32
  rot = float(rot_deg)/180*!pi
  for i=0,(size(detpos))[1]-1 do begin
    for j=0,(size(detpos))[2]-1 do begin
      detpos[i,j,0] = (detpos[i,j,0]-detpos_0[0])*cos(rot) + (detpos[i,j,1]-detpos_0[1])*sin(rot)+detpos_0[0]
      detpos[i,j,1] = -(detpos[i,j,0]-detpos_0[0])*sin(rot) + (detpos[i,j,1]-detpos_0[1])*cos(rot)+detpos_0[1]
    endfor
  endfor
endif


if (keyword_set(r_scale)) then begin
  R = reform(detpos[columns-1,0,0])/10
  default,rrange,[min(R)-1,max(R)+1]
  xtitle = 'R [cm]'
endif else begin
  R = findgen(ncol)+1
  default,rrange,[0,10]
  xtitle = 'Column'
endelse

erase
if (not keyword_set(nolegend)) then time_legend,'show_kstar_mean_row_correlations.pro'
ncol = n_elements(columns)
nrow = n_elements(rows)
pos = [0.05,0.1,1,0.3]
default,yrange,[min(outcorr_sum)<0,max(outcorr_sum)*1.05]/nrow
default,taurange,[min(tauscale),max(tauscale)]
actpos=plot_position(1,ncol,xgap=0.05,ygap=0.0, corner=pos,/block)
maxpos = fltarr(ncol)
for i=0,ncol-1 do begin
  corr = reform(outcorr_sum[i,*])/nrow
  plot,tauscale,corr,/noerase,xrange=taurange,xtitle='Time lag [!7l!Xs]',xstyle=1,$
    yrange=yrange,ystyle=1,pos=reform(actpos[0,i,*]),title='Column '+i2str(columns[i])+' R='+string(R[i],format='(F5.1)'),$
    charsize=charsize*0.7,thick=thick,$
    charthick=thick,xthick=thick,ythick=thick,xticks=2
  oplot,taurange,[0,0],linest=1,thick=thick
  oplot,[0,0],yrange,linest=1,thick=thick
  ;maxpos[i] = abs(tauscale[where(corr eq max(corr))])
  ind = where((tauscale ge taurange[0]) and (tauscale le taurange[1]))
  p = parabola_extremum(x_array=tauscale[ind],y_array=corr[ind])
  maxpos[i] = p[0]
endfor

if (keyword_set(vpol)) then begin
  mean_distance = total(detpos[*,rows[1:n_elements(rows)-1]-1,1]-detpos[*,rows[0:n_elements(rows)-2]-1,1],2)/(n_elements(rows)-1)
  v = mean_distance/maxpos
  default,vrange,[-1,1]*max(abs(v[where(finite(v))]))
  plotsymbol,0
  plot,R,v,xtitle=xtitle,xrange=rrange,xstyle=1,yrange=vrange,ystyle=1,ytitle='v!Dpol!N [km/s]',$
  thick=thick,xthick=thick,ythick=thick,charthick=thick,charsize=charsize,pos=[0.1,0.5,0.55,0.9],$
  title=i2str(shot)+'Poloidal flow velocity',psym=8,/noerase
  oplot,rrange,[0,0],linest=1,thick=thick
  xyouts,rrange[1]-(rrange[1]-rrange[0])*0.18,vrange[1]*0.9,/data,'e-diam!C(LFS up)',charsize=0.75*charsize,charthick=thick
  xyouts,rrange[1]-(rrange[1]-rrange[0])*0.18,vrange[0]*0.7,/data,'i-diam!C(LFS udown)',charsize=0.75*charsize,charthick=thick
endif else begin
  ; Setting the
  if (detpos[0,1,1] lt detpos[0,0,1]) then begin
    ; if BES-1-1 is on top then reverting time delay
    ; positive time delay means propagation up, e-diam direction
    maxpos = -maxpos
  endif
  plotsymbol,0
  plot,R,maxpos,xtitle=xtitle,xrange=rrange,xstyle=1,yrange=maxrange,ystyle=1,ytitle='Time delay [!7l!Xs]',$
    thick=thick,xthick=thick,ythick=thick,charthick=thick,charsize=charsize,pos=[0.1,0.5,0.55,0.9],$
    title=i2str(shot)+' Time delay',psym=-8,/noerase
  oplot,rrange,[0,0],linest=1,thick=thick
  xyouts,rrange[1]-(rrange[1]-rrange[0])*0.18,maxrange[1]*0.2,/data,'e-diam!C(LFS up)',charsize=0.75*charsize,charthick=thick
  xyouts,rrange[1]-(rrange[1]-rrange[0])*0.18,maxrange[0]*0.13,/data,'i-diam!C(LFS down)',charsize=0.75*charsize,charthick=thick
endelse

para_txt = 'Shot: '+i2str(shot)
if (defined(timerange)) then para_txt = para_txt+'!CTimerange: ['+$
                        string(timerange[0],format='(F6.3)')+','+string(timerange[1],format='(F6.3)')+']s'
if (defined(timefile)) then para_txt = para_txt+'!CTimefile: '+timefile
if (defined(filter_order)) then begin
  para_txt = para_txt+'!CBandpass filter:!C  Low f: '+string(filter_low,format='(E10.2)')+$
                                         '!C  High f:'+string(filter_high,format='(E10.2)')+$
                                         '!C  Order: '+i2str(filter_order)
endif
para_txt = para_txt+'!CTaures: '+string(taures,format='(F4.1)')+'[!7l!Xs]'
xyouts,0.62,0.9,/norm,para_txt,charthick=thick,charsize=charsize

end