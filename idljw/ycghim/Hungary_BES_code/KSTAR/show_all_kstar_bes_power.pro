pro show_all_kstar_bes_power,shot,timerange=timerange,timefile=timefile,yrange=yrange,position=pos,$
                             frange=frange,fres=fres,ftype=ftype,ytype=ytype,xtype=xtype,refchannel=refchannel,$
                             autopower=autopower,crosspower=crosspower,crossphase=crossphase,autocorr=autocorr, crosscorr=crosscorr,norm=norm,$
                             noerase=noerase,nolegend=nolegend,thick=thick,charsize=charsize,title=title,datapath=datapath,$
                             nocalculate=nocalculate,savefile=savefile,errormess=errormess,taurange=taurange,taures=taures,$
                             filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,lowcut=lowcut,$
                             cut_length=cut_length,extrapol_length=extrapol_length,nocalibrate=nocalibrate, font0=font0, color=color,$
                             vertical=vertical, horizontal=horizontal,interval_n=interval_n,nopara=nopara,plot_marks=plot_marks

;*********************************************************************
;* SHOW_ALL_KSTAR_BES.PRO          S. Zoletnik  3.08.2011           *
;*********************************************************************
;* Plotting all BES power (cross-or auto) in the KSTAR APDCAM        *
;* measurement.                                                      *
;* The location of subplots corresponds to location of pixels.       *
;* INPUT:                                                            *
;*   shot: Shot number                                               *
;*   timerange: Time range [start, stop] in sec                      *
;*   timefile: time file from select_time
;*   fres: freuquency resolution in Hz.                              *
;*   frange: Frequency range [Hz]                                    *
;*   xtype: 1: log axis                                              *
;*   ftype: 1: Log frequency resolution.                             *
;*   ytype: 1: log y range                                           *
;*   yrange: Plot range for all powers.Default is min to max.        *
;*           range [0,2] Volts.                                      *
;*   position: Position of full plot on page in normal               *
;*             coordinates.                                          *
;*   /noerase: Don not erae before plotting.                         *
;*   /nolegend: Do not put time and program name on plot UR corner.  *
;*   /nopara: Do not put caoculation parameters on the plot.         *
;*   thick: Line thickness, default is 1.                            *
;*   charsize: Relative character thickness, default is 1.           *
;*   title: Title of plot, default is shot number and time interval  *
;*   datapath: directory with data                                   *
;*   /autopower: Plot autopowers                                     *
;*   /crosspower: Plot crosspowers, use refchannel as reference      *
;*   /crossphase: Plot crossphase                                    *
;*   /autocorr: Plot autocorrelations                                *
;*   /crosscorr: Plot crosscorrelations                              *
;*   /norm: noramlize the plots                                      *
;*   refchannel: reference channel for cross... plots                *
;*   taurange: Time lag range for correlations in microsec           *
;*   taures: Time lag range for correaltions in microsec             *
;*   filter_low, filter_high, filter_order: FIR filter parameters    *
;*   lowcut: Low frequency cutoff time constant in microsec          *
;*   inttime: Integration time before signal processing in microsec  *
;*   savefile: The IDL sve file name in tmp/ to save data after      *
;*              calculation                                          *
;*   plot_marks: X coordinate where vertical marks are plot          *
;*********************************************************************

default,crosspower,0
default,crossphase,0
default,autocorr,0
default,crosscorr,0
default,autopower,0

if keyword_set(font0) then !p.font=2
if (not keyword_set(crosspower) and not keyword_set(crossphase) and not keyword_set(autocorr) and not keyword_set(crosscorr)) then autopower=1

if (keyword_set(crosspower) or keyword_set(crosscorr) or keyword_set(crossphase)) then begin
  if (not defined(refchannel))then begin
    errormess = 'No reference channel is set.'
    if (not keyword_set(silent)) then print,errormess
    return
  endif
endif
if (autopower+crosspower+crossphase+autocorr+crosscorr eq 0) then begin
  errormess = 'One of /autopower, /crosspower, /crosphase, /autocorr or /crosscorr should be set.'
  if (not keyword_set(silent)) then print,errormess
  return
endif

if (keyword_set(autopower)+keyword_set(crosspower)+keyword_set(crossphase)+keyword_set(autocorr)+keyword_set(crosscorr) gt 1) then begin
  errormess = 'Only one of /autopower, /crosspower, /crosphase, /autocorr or /crosscorr should be set.'
  if (not keyword_set(silent)) then print,errormess
  return
endif

default,pos,[0.05,0.05,0.9,1]
default,charsize,1
default,thick,1
default,fres,30
default,frange,[1e3,1e6]
if (keyword_set(autocorr) or keyword_set(crosscorr)) then default,xtype,0 else default,xtype,1
default,ftype,1
if (keyword_set(autocorr) or keyword_set(crosscorr) or keyword_set(crossphase)) then default,ytype,0 else default,ytype,1
default,norm,0

errormess = ''

default,savefile,'show_all_kstar_bes_power.sav'
default,norm,0
vert=0
load_config_parameter, shot, 'Optics', 'APDCAMPosition', output=outp,errormess=e
if shot lt 10000 then begin
   if (e eq '') then begin
      if double(outp.value) eq 30000 then vert=0
      if double(outp.value) eq 12150 then vert=1
   endif else begin
      vert=0
   endelse
   if keyword_set(vertical) then vert=1
   if keyword_set(horizontal) then vert=0
   if vert then begin
      nrow=8
      ncol=4
   endif else begin
      nrow=4
      ncol=8
   endelse
endif else begin
   if (e eq '') then begin
      if double(outp.value) gt 15000 then vert=0
      if double(outp.value) lt 3000 then vert=1
   endif else begin
      vert=0
   endelse
   if keyword_set(vertical) then vert=1
   if keyword_set(horizontal) then vert=0
   if vert then begin
      nrow=16
      ncol=4
   endif else begin
      nrow=4
      ncol=16
   endelse
endelse

if (not keyword_set(nocalculate)) then begin
  if (keyword_set(crosspower) or keyword_set(crosscorr) or keyword_set(crossphase)) then begin
    refchannel_full = refchannel
    if defined(timerange) then timerange_tmp=timerange
    ; Reading in the reference channel into the signal cache
    get_rawsignal,shot,refchannel_full,trange=timerange_tmp,cache=refchannel,nocalibrate=nocalibrate
  endif
  chname_arr = strarr(nrow,ncol)
  for row=0,nrow-1 do begin
    for column=0,ncol-1 do begin
       if shot lt 10000 then begin
          chname = kstar_bes_matrix(row+1,column+1,vert=vert)
       endif else begin
          chname = 'BES-'+i2str(row+1)+'-'+i2str(column+1)
       endelse

       print,chname & wait,0.1
       chname_arr[row,column] = chname
       chname_full = chname


       if (keyword_set(autopower) or keyword_set(autocorr)) then begin
        fluc_correlation,shot,timefile,timer=timerange,ref=chname_full,/plot_power,/noplot,fres=fres,frange=frange,$
                         xtype=xtype,ftype=ftype,outfscale=fscale,outpower=p,outpwscat=ps,outcorr=corr,outscat=corrs,outtime=tauscale,$
                         datapath=datapath,errormess=errormess,/silent,taurange=taurange,taures=taures,norm=norm,$
                         /no_errorcatch,filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,lowcut=lowcut,inttime=inttime,$
                         cut_length=cut_length,extrapol_length=extrapol_length,nocalibrate=nocalibrate,interval_n=interval_n
        if (errormess ne '') then begin
           print,errormess
           return
        endif
        if (not defined(p_matrix)) then begin
           fscale_common = fscale
           tauscale_common = tauscale
           p_matrix = fltarr(nrow,ncol,n_elements(fscale))
           ps_matrix = p_matrix
           c_matrix = fltarr(nrow,ncol,n_elements(tauscale))
           cs_matrix = c_matrix
        endif
        if (n_elements(fscale) ne n_elements(fscale_common)) then begin
           errormess = 'Frequency scale is different for channels'
           if (not keyword_set(silent)) then print,errormess
           return
        endif
        if ((where(fscale ne fscale_common)) ge 0) then begin
           errormess = 'Frequency scale is differenct for channels'
           if (not keyword_set(silent)) then print,errormess
           return
        endif
        if (n_elements(tauscale) ne n_elements(tauscale_common)) then begin
           errormess = 'Time lag scale is differenct for channels'
           if (not keyword_set(silent)) then print,errormess
           return
        endif
        if ((where(tauscale ne tauscale_common))[0] ge 0) then begin
           errormess = 'Time lag scale is differenct for channels'
           if (not keyword_set(silent)) then print,errormess
           return
        endif
        p_matrix[row,column,*] = p
        ps_matrix[row,column,*] = ps
        c_matrix[row,column,*] = corr
        cs_matrix[row,column,*] = corrs
     endif                      ; autopower
       if (keyword_set(crosspower) or keyword_set(crosscorr) or keyword_set(crossphase)) then begin
                                ; If this is autopower or autocorrelation omitting the reference channel so as the calculation does not think the two signals are different
                                ;  (As the ref channel is in the cache.)
          if (refchannel eq chname) then delete,chname_full
          fluc_correlation,shot,timefile,timer=timerange,ref='cache/'+refchannel,plotch=chname_full,/plot_power,/noplot,fres=fres,frange=frange,$
                           xtype=xtype,ftype=ftype,outfscale=fscale,outpower=p,outpwscat=ps,datapath=datapath,errormess=errormess,$
                           norm=norm,outcorr=corr,outscat=corrs,outtime=tauscale,outphase=phase,$
                           /silent,taurange=taurange,taures=taures,coherency_noiselevel=cn,$
                           /no_errorcatch,filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,lowcut=lowcut,inttime=inttime,$
                           cut_length=cut_length,extrapol_length=extrapol_length,nocalibrate=nocalibrate,interval_n=interval_n
          if (errormess ne '') then begin
             print,errormess
             return
          endif
          if (not defined(p_matrix)) then begin
             fscale_common = fscale
             tauscale_common = tauscale
             p_matrix = fltarr(nrow,ncol,n_elements(fscale))
             ps_matrix = p_matrix
             ph_matrix = p_matrix
             c_matrix = fltarr(nrow,ncol,n_elements(tauscale))
             cs_matrix = c_matrix
             if (n_elements(cn) eq 1) then begin
                noiselevel_matrix = fltarr(nrow,ncol)
             endif else begin
                noiselevel_matrix = p_matrix
             endelse
          endif
          if (n_elements(fscale) ne n_elements(fscale_common)) then begin
             errormess = 'Frequency scale is differenct for channels'
             if (not keyword_set(silent)) then print,errormess
             return
          endif
          if ((where(fscale ne fscale_common))[0] ge 0) then begin
             errormess = 'Frequency scale is differenct for channels'
             if (not keyword_set(silent)) then print,errormess
             return
          endif
          if (n_elements(tauscale) ne n_elements(tauscale_common)) then begin
             errormess = 'Frequency scale is differenct for channels'
             if (not keyword_set(silent)) then print,errormess
             return
          endif
          if ((where(tauscale ne tauscale_common))[0] ge 0) then begin
             errormess = 'Frequency scale is differenct for channels'
             if (not keyword_set(silent)) then print,errormess
             return
          endif
          p_matrix[row,column,*] = p
          ps_matrix[row,column,*] = ps
          ph_matrix[row,column,*] = phase
          c_matrix[row,column,*] = corr
          cs_matrix[row,column,*] = corrs
          if (n_elements(cn) eq 1) then begin
             noiselevel_matrix[row,column] = cn
          endif else begin
             noiselevel_matrix[row,column,*] = cn
          endelse
       endif

    endfor
 endfor
  default,refchannel,-1
  autocorr_calc = autocorr
  crosscorr_calc = crosscorr
  autopower_calc = autopower
  crosspower_calc = crosspower
  crossphase_calc = crossphase
  save,chname_arr,fscale,p_matrix,ps_matrix,fres,shot,timerange,norm,refchannel,autopower_calc,$
       crosspower_calc,crossphase_calc,autocorr_calc,crosscorr_calc,tauscale,c_matrix,cs_matrix,inttime,filter_low,filter_high,filter_order,lowcut,$
       ph_matrix,noiselevel_matrix,cut_length,extrapol_length,file=dir_f_name('tmp',savefile)
  if (keyword_set(crosspower) or keyword_set(crosscorr) or keyword_set(spectra)) then begin
     signal_cache_delete,name=refchannel
  endif
endif else begin
   restore,dir_f_name('tmp',savefile)
endelse

deftitle = 'Shot: '+i2str(shot)
if (defined(timerange)) then deftitle=deftitle+'!CTimerange=['+string(timerange[0],format='(F6.4)')+$
                                      ','+string(timerange[1],format='(F6.4)')+']'
if (defined(timefile)) then begin
   deftitle=deftitle+'!CTimefile: '+timefile
   d=loadncol(dir_f_name('time',timefile),2,/silent,errormess=e)
   if (e eq '') then begin
      deftitle = deftitle+'!C  ['+string(min(d),format='(F6.3)')+','+string(max(d),format='(F6.3)')+']'
   endif else begin
      deftitle = deftitle+'!C  [???,???]'
   endelse
endif
if (keyword_set(autopower)) then deftitle=deftitle+'!C/autopower'
if (keyword_set(crosspowerpower)) then deftitle=deftitle+'!C/crosspower'
if (keyword_set(crossphase)) then deftitle=deftitle+'!C/crossphase'
if (keyword_set(autocorr)) then deftitle=deftitle+'!C/autocorr.'
if (keyword_set(crosscorr)) then deftitle=deftitle+'!C/crosscorr.'
if (keyword_set(crosspower) or keyword_set(crosscorr) or keyword_set(spectra)) then begin
   deftitle = deftitle+'!CRef:'+refchannel
endif
if keyword_set(norm) then deftitle = deftitle+'!C/norm'
default,title,deftitle

default,frange,[min(fscale),max(fscale)]
if (keyword_set(ytype)) then begin
 if (keyword_set(autopower) or keyword_set(crosspower)) then default,yrange,[max(p_matrix)*0.001,max(p_matrix)*1.5]
 if (keyword_set(autocorr) or keyword_set(crosscorr)) then default,yrange,[max(c_matrix)*0.001,max(c_matrix)*1.5]
endif else begin
   if (keyword_set(autopower) or keyword_set(crosspower)) then default,yrange,[0,max(p_matrix)*1.05]
   if (keyword_set(autocorr) or keyword_set(crosscorr)) then default,yrange,[min(c_matrix)<0,max(c_matrix)*1.05]
endelse
if (keyword_set(crossphase)) then default,yrange,[-1.05,1.05]

if (not keyword_set(noerase)) then erase
if (not keyword_set(nolegend)) then time_legend,'show_all_kstar_bes_power.pro'
if shot lt 10000 then begin
   if vert then begin
      nrow=8
      ncolumn=4
   endif else begin
      nrow=4
      ncolumn=8
   endelse
endif else begin
   if vert then begin
      nrow=16
      ncolumn=4
   endif else begin
      nrow=4
      ncolumn=16
   endelse
endelse

pos=plot_position(nrow,ncolumn,xgap=0.01,ygap=0.03,corner=pos, /block)
for row=0,nrow-1 do begin
   for column=0,ncolumn-1 do begin
      if (keyword_set(autopower) or keyword_set(crosspower)) then begin
         if (row eq 0) then begin
        xtickname=''
        xtitle=' Frequency [kHz]'
     endif else begin
        xtickname=replicate('  ',20)
        xtitle = ''
     endelse
      if (column eq 0) then ytickname='' else ytickname=replicate('  ',20)
      plot,fscale/1000.,reform(p_matrix[row,column,*]),xrange=frange/1000,xstyle=1,xtype=xtype,/noerase,$
           pos=pos[row,column,*], yrange=yrange,ystyle=1,ytype=ytype,xtickname=xtickname,xtitle=xtitle,$
           ytickname=ytickname,ytitle=ytitle,charsize=0.5*charsize,title=chname_arr[row,column],thick=thick,$
           xthick=thick,ythick=thick,charthick=thick, color=color

       if (keyword_set(crosspower)) then begin
          if ((size(noiselevel_matrix))[0] eq 2) then begin
             oplot,frange/1000,[noiselevel_matrix[row,column],noiselevel_matrix[row,column]]
          endif else begin
             oplot,fscale/1000,reform(noiselevel_matrix[row,column,*])
          endelse
       endif
    endif
    if (keyword_set(crossphase)) then begin
       if (row eq 0) then begin
          xtickname=''
          xtitle=' Frequency [kHz]'
       endif else begin
          xtickname=replicate('  ',20)
          xtitle = ''
       endelse
       if (column eq 0) then begin
          ytickname=''
          ytitle = 'Phase [Pi]'
       endif else begin
          ytickname=replicate('  ',20)
        ytitle = ' '
     endelse
       plot,fscale/1000.,reform(ph_matrix[row,column,*])/!pi,xrange=frange/1000,xstyle=1,xtype=xtype,/noerase,$
            pos=pos[row,column,*],$
          yrange=yrange,ystyle=1,ytype=ytype,xtickname=xtickname,xtitle=xtitle,ytickname=ytickname,ytitle=ytitle,charsize=0.5*charsize,$
            title=chname_arr[row,column],thick=thick,xthick=thick,ythick=thick,charthick=thick,color=color
    endif
    if (keyword_set(autocorr) or keyword_set(crosscorr)) then begin
       if (row eq 0) then begin
          xtickname=''
          xtitle=' Time lag [!7l!Xs]'
      endif else begin
         xtickname=replicate('  ',20)
        xtitle = ''
     endelse
      if (column eq 0) then ytickname='' else ytickname=replicate('  ',20)
      plot,tauscale,reform(c_matrix[row,column,*]),xrange=taurange,xstyle=1,xtype=xtype,/noerase,$
           pos=pos[row,column,*],$
          yrange=yrange,ystyle=1,ytype=ytype,xtickname=xtickname,xtitle=xtitle,ytickname=ytickname,ytitle=ytitle,charsize=0.5*charsize,$
           title=chname_arr[row,column],thick=thick,xthick=thick,ythick=thick,charthick=thick, color=color
      if (defined(plot_marks)) then begin
        for i=0,n_elements(plot_marks)-1 do begin
          oplot,[plot_marks[i],plot_marks[i]],yrange,thick=thick
        endfor
      endif

   endif

 endfor
endfor


if (not keyword_set(nopara)) then begin
   xyouts, 0.89, 0.95,  title, /norm,charsize=0.75*charsize,charthick=thick
endif

end
