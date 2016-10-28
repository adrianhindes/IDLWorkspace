pro show_all_kstar_bes,shot,timerange=timerange,yrange=yrange,position=pos,nointerpolate=nointerpol,$
    noerase=noerase,nolegend=nolegend,thick=thick,charsize=charsize,inttime=inttime,smoothlen=smoothlen,$
    filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,lowcut=lowcut,title=title,datapath=datapath,$
    nocalibrate=nocalibrate, color=color,marks=marks,click_marks=click_marks, vertical=vertical, horizontal=horizontal,$
    adc=adc
;*********************************************************************
;* SHOW_ALL_KSTAR_BES.PRO          S. Zoletnik  2.08.20011           *
;*********************************************************************
;* Plotting all BES signals in the KSTAR APDCAM measurement.         *
;* The location of subplots corresponds to location of pixels.       *
;* INPUT:                                                            *
;*   shot: Shot number                                               *
;*   timerange: Time range [start, stop] in sec                      *
;*   yrange: Plot range for all signals in Volts. They will          *
;*           have common range, default is full ADC                  *
;*           range [0,2] Volts.                                      *
;*   position: Position of full plot on page in normal               *
;*             coordinates.                                          *
;*   /nointerpolate: Do not interpolate signals to small number      *
;*                   of points.Default is to interpolate             *
;*                   above 5000 points otherwise plotting is slow.   *
;*   /noerase: Don not erae before plotting.                         *
;*   /nolegend: Do not put time and program name on plot UR corner.  *
;*   thick: Line thickness, default is 1.                            *
;*   charsize: Relative character thickness, default is 1.           *
;*   inttime: Integration time in microsec.                          *
;*   smoothlen: Smooth length in microsec                            *
;*   lowcut: Subtract signal integrated to this time constant        *
;*           (microsec)                                              *
;*   filter_low, filter_high, filter_order: filter parameters        *
;*   title: Title of plot, default is shot number.                   *
;*   marks: Put marks at these times.                                *
;*   /click_mark: Click on the last subplot to add marks.            *
;*                Will ad them to marks[]                            *
;*   datapath: directory with data                                   *
;*   /nocalibrate: Do not apply relative calibration.                *
;*   /adc: Plot according to ADCs and not BES pixels.                *
;*********************************************************************

default,pos,[0.05,0.05,0.9,1]
default,yrange,[0,0.5]
default,charsize,1
default,thick,1

deftitle ='Shot: '+i2str(shot)
if (defined(inttime)) then deftitle = deftitle+'!Cinttime: '+i2str(inttime)+' [!7l!Xs]'
if (defined(smoothlen)) then deftitle = deftitle+'!Csmoothlen: '+i2str(smoothlen)+' [!7l!Xs]'
if (defined(lowcut)) then deftitle = deftitle+'!Clowcut: '+i2str(lowcut)+' [!7l!Xs]'
if (keyword_set(filter_order)) then begin
  deftitle = deftitle+'!Cfilter_low: '+string(filter_low,format='(E8.2)')+' [Hz]'
  deftitle = deftitle+'!Cfilter_high: '+string(filter_high,format='(E8.2)')+' [Hz]'
  deftitle = deftitle+'!Cfilter_order: '+i2str(filter_order)
endif
default,title,deftitle

xstep=(pos[2]-pos[0])*0.9/8
ystep=(pos[3]-pos[1])*0.9/4
map=apdcam_channel_map(data_source=32)

loadct, 0
vert=0
load_config_parameter, shot, 'Optics', 'APDCAMPosition', output=outp,errormess=e
if (e eq '') then begin
   if double(outp.value) eq 30000 then vert=0
   if double(outp.value) eq 12150 then vert=1
endif else begin
   vert=0
endelse
if keyword_set(vertical) then vert=1
if keyword_set(horizontal) then vert=0


if (not keyword_set(noerase)) then erase
if (not keyword_set(nolegend)) then time_legend,'show_all_kstar_bes.pro'

if shot gt 10000 then begin
   if vert then begin
      nrow=16
      ncolumn=4
   endif else begin
      nrow=4
      ncolumn=16
   endelse
   pos=plot_position(nrow,ncolumn,xgap=0.01,ygap=0.03, corner=pos,/block)
endif else begin

   if vert then begin
      nrow=8
      ncolumn=4
   endif else begin
      nrow=4
      ncolumn=8
   endelse
   pos=plot_position(nrow,ncolumn,xgap=0.01,ygap=0.03, corner=pos,/block)
endelse

for row=0,nrow-1 do begin
  for column=0,ncolumn-1 do begin
    if shot gt 10000 then begin
      if (not keyword_set(adc)) then begin
        if vert then begin
           irow=column
           icolumn=row
           chname = 'BES-'+i2str(3-irow+1)+'-'+i2str(icolumn+1)
        endif else begin
           irow=row
           icolumn=column
           chname = 'BES-'+i2str(3-irow+1)+'-'+i2str(15-icolumn+1)
        endelse
      endif else begin
        chname = 'BES-ADC'+i2str(row*16+column+1)
      endelse
    endif else begin
      if (not keyword_set(adc)) then begin
        if vert then begin
           irow=column
           icolumn=row
           chname = 'BES-'+i2str(3-irow+1)+'-'+i2str(icolumn+1)
        endif else begin
          irow=row
          icolumn=column
          chname = 'BES-'+i2str(3-irow+1)+'-'+i2str(7-icolumn+1)
        endelse
      endif else begin
        chname = 'BES-ADC'+i2str(row*8+column+1)
      endelse
    endelse
    chname_full = chname
    get_rawsignal,shot,chname_full,t,d,data_s=32,errormess=e,trange=timerange,sampletime=sampletime,$
      datapath=datapath,nocalibrate=nocalibrate
    if (e eq '') then begin
      if (n_elements(timerange) lt 2) then begin
        timerange = [min(t),max(t)]
      endif
      if (row eq 0) then begin
        xtickname=''
        xtitle=' Time [s]'
      endif else begin
        xtickname=replicate('  ',20)
        xtitle = ''
      endelse
      if (column eq 0) then ytickname='' else ytickname=replicate('  ',20)
      if (keyword_set(inttime)) then d=integ(d,inttime/(sampletime/1e-6))
      if (keyword_set(smoothlen)) then d = smooth(d,smoothlen/(sampletime/1e-6))
      if (keyword_set(filter_order)) then begin
        d=bandpass_filter_data(d,sampletime=sampletime,filter_low=filter_low,filter_high=filter_high,$
        filter_order=filter_order,errormess=errormess,/silent)
      endif
      if (defined(lowcut)) then d = d-integ(d,lowcut/(sampletime/1e-6))
      if (not keyword_set(nointerpol)) then begin
        maxpoint=5000
        if (n_elements(t) gt maxpoint) then begin
          t=interpol(t,maxpoint)
          d=interpol(d,maxpoint)
        endif
      endif

      if (row eq 0) then begin
        xtickname=''
        xtitle=' Time [s]'
      endif else begin
        xtickname=replicate('  ',20)
        xtitle = ''
      endelse

      plot,t,d,xrange=timerange,xstyle=1,/noerase,$
          pos=pos[row,column,*],yrange=yrange,ystyle=1,xtickname=xtickname,xtitle=xtitle,ytickname=ytickname,$
          ytitle=ytitle,charsize=0.5*charsize,title=chname,thick=thick,xthick=thick,ythick=thick,$
          charthick=thick,xticks=2, color=color
      wait,0.01
      if (defined(marks)) then begin
         for i_mark=0,n_elements(marks)-1 do begin
           oplot,[marks[i_mark],marks[i_mark]],yrange,thick=thick
         endfor
      endif

    endif else begin
      if (not keyword_set(silent)) then print,e
      return
    endelse

  endfor
endfor

xyouts, 0.91, 0.95,  title, /norm,charsize=0.75*charsize,charthick=thick

if (keyword_set(click_marks)) then begin
  print,'Click with left button in upper right subplot to add marks. Click with right mouse to stop.'
  digxyadd,xx,yy,/data
  if (defined(xx)) then begin
    if (defined(marks)) then begin
      marks = [marks,xx]
    endif else begin
      marks = xx
    endelse
  endif
endif

end
