pro show_all_kstar_ecei_power,shot,timerange=timerange,yrange=yrange,position=pos,$
                              frange=frange,fres=fres,ftype=ftype,ytype=ytype,xtype=xtype,refchannel=refchannel,$
                              autopower=autopower,crosspower=crosspower,crossphase=crossphase,autocorr=autocorr, crosscorr=crosscorr,norm=norm,$
                              noerase=noerase,nolegend=nolegend,thick=thick,charsize=charsize,title=title,datapath=datapath,$
                              nocalculate=nocalculate,savefile=savefile,errormess=errormess,taurange=taurange,taures=taures,$
                              filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,lowcut=lowcut,$
                              cut_length=cut_length,extrapol_length=extrapol_length,nocalibrate=nocalibrate,block=block,interval_n=interval_n,$
                              plot_2d=plot_2d, c_matrix=c_matrix, postscript=postscript, out=out, only_lfs=only_lfs

;*********************************************************************
;* SHOW_ALL_KSTAR_ECE_POWER.PRO    S. Zoletnik  2.02.2012            *
;*********************************************************************
;* Plotting all ECEi signal power (cross-or auto)                    *
;* The location of subplots corresponds to location of channels.     *
;* INPUT:                                                            *
;*   shot: Shot number                                               *
;*   block: The blocks to plot ('H' 'L' or both) (string array)      *
;*   timerange: Time range [start, stop] in sec                      *
;*   fres: Frequency resolution in Hz.                               *
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
;*   interval_n: Number of subintervals for processing               *
;*********************************************************************

default,block,['H','L']
default,crosspower,0
default,crossphase,0
default,autocorr,0
default,crosscorr,0
default,autopower,0
default,postscript, 0
default, out, 0
default, only_lfs, 0

if keyword_set(only_lfs) then begin
   block=['L']
endif
if (not keyword_set(crosspower) and not keyword_set(crossphase) and not keyword_set(autocorr) and not keyword_set(crosscorr)) then autopower=1

if (keyword_set(crosspower) or keyword_set(crosscorr) or keyword_set(crossphase)) then begin
  if (not defined(refchannel))then begin
    errormess = 'No reference channel is set.'
    if (not keyword_set(silent)) then print,errormess
    return
  endif
endif

if (autopower+crosspower+crossphase+autocorr+crosscorr eq 0) then begin
  errormess = 'One of /autopower, /crosspower, /crossphase, /autocorr or /crosscorr should be set.'
  if (not keyword_set(silent)) then print,errormess
  return
endif

if (keyword_set(autopower)+keyword_set(crosspower)+keyword_set(crossphase)+keyword_set(autocorr)+keyword_set(crosscorr) gt 1) then begin
  errormess = 'Only one of /autopower, /crosspower, /crossphase, /autocorr or /crosscorr should be set.'
  if (not keyword_set(silent)) then print,errormess
  return
endif

if keyword_set(postscript) then begin
   hardon, /color
endif

default,charsize,1
default,thick,1
default,fres,30
default,frange,[1e3,1e6]
default,taures,1
default,taurange,[-100,100]
if (keyword_set(autocorr) or keyword_set(crosscorr)) then default,xtype,0 else default,xtype,1
default,ftype,1
if (keyword_set(autocorr) or keyword_set(crosscorr) or keyword_set(crossphase)) then default,ytype,0 else default,ytype,1
default,norm,0

errormess = ''
if keyword_set(refchannel) then begin
  default,savefile,'show_all_kstar_ecei_power_'+strmid(refchannel,5,10)+'_'+strtrim(shot,2)+'_'+strtrim(timerange[0],2)+'_.sav'
  endif else begin
  default,savefile,'show_all_kstar_ecei_power_'+strtrim(shot,2)+'_'+strtrim(timerange[0],2)+'_.sav'
endelse
default,norm,0


if (not keyword_set(nocalculate)) then begin
  if (keyword_set(crosspower) or keyword_set(crosscorr) or keyword_set(crossphase)) then begin
    refchannel_full = refchannel
    get_rawsignal,shot,refchannel_full,trange=timerange,cache=refchannel,nocalibrate=nocalibrate
  endif
  nblock = n_elements(block)

  chname_arr = ecei_channel_map(block=block[0])
  chname_arr = strarr(nblock,(size(chname_arr))[1],(size(chname_arr))[2])
  for ib=0,nblock-1 do begin
    chname_arr[ib,*,*]=ecei_channel_map(block=block[ib])
    nrow = (size(chname_arr))[3]
    ncol = (size(chname_arr))[2]
    for row=0,nrow-1 do begin
      for column=0,ncol-1 do begin
        chname = chname_arr[ib,column,row]
        print,chname & wait,0.1
        chname_full = chname
        if (keyword_set(autopower) or keyword_set(autocorr)) then begin
          delete,taures_in & delete,taurange_in & delete,fres_in & delete,frange_in
          if (defined(fres)) then fres_in = fres
          if (defined(frange)) then frange_in = frange
          if (defined(taures)) then taures_in = taures
          if (defined(taurange)) then taurange_in = taurange
          fluc_correlation,shot,timer=timerange,ref=chname_full,/plot_power,/noplot,fres=fres_in,frange=frange_in,$
            xtype=xtype,ftype=ftype,outfscale=fscale,outpower=p,outpwscat=ps,outcorr=corr,outscat=corrs,outtime=tauscale,$
            datapath=datapath,errormess=errormess,/silent,taurange=taurange_in,taures=taures_in,norm=norm,$
            /no_errorcatch,filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,lowcut=lowcut,inttime=inttime,$
            cut_length=cut_length,extrapol_length=extrapol_length,nocalibrate=nocalibrate,interval_n=interval_n
          if (errormess ne '') then begin
            ;print,errormess
            ;return
          endif
          if (not defined(p_matrix)) then begin
            fscale_common = fscale
            tauscale_common = tauscale
            p_matrix = fltarr(nblock,ncol,nrow,n_elements(fscale))
            ps_matrix = p_matrix
            c_matrix = fltarr(nblock,ncol,nrow,n_elements(tauscale))
            cs_matrix = c_matrix
          endif
          if (errormess eq '') then begin
            if (n_elements(fscale) ne n_elements(fscale_common)) then begin
              errormess = 'Frequency scale is different for channels'
              if (not keyword_set(silent)) then print,errormess
              return
            endif
            if ((where(fscale ne fscale_common)) ge 0) then begin
              errormess = 'Frequency scale is different for channels'
              if (not keyword_set(silent)) then print,errormess
              return
            endif
            if (n_elements(tauscale) ne n_elements(tauscale_common)) then begin
              errormess = 'Time lag scale is different for channels'
              if (not keyword_set(silent)) then print,errormess
              return
            endif
            if ((where(tauscale ne tauscale_common))[0] ge 0) then begin
              errormess = 'Time lag scale is different for channels'
              if (not keyword_set(silent)) then print,errormess
              return
            endif
            p_matrix[ib,column,row,*] = p
            ps_matrix[ib,column,row,*] = ps
            c_matrix[ib,column,row,*] = corr
            cs_matrix[ib,column,row,*] = corrs
          endif
        endif ; autopower
        if (keyword_set(crosspower) or keyword_set(crosscorr) or keyword_set(crossphase)) then begin
          delete,taures_in & delete,taurange_in & delete,fres_in & delete,frange_in
          if (defined(fres)) then fres_in = fres
          if (defined(frange)) then frange_in = frange
          if (defined(taures)) then taures_in = taures
          if (defined(taurange)) then taurange_in = taurange
          fluc_correlation,shot,timer=timerange,ref='cache/'+refchannel,plotch=chname_full,/plot_power,/noplot,fres=fres_in,frange=frange_in,$
            xtype=xtype,ftype=ftype,outfscale=fscale,outpower=p,outpwscat=ps,datapath=datapath,errormess=errormess,$
            norm=norm,outcorr=corr,outscat=corrs,outtime=tauscale,outphase=phase,$
            /silent,taurange=taurange_in,taures=taures_in,coherency_noiselevel=cn,$
            /no_errorcatch,filter_low=filter_low,filter_high=filter_high,filter_order=filter_order,lowcut=lowcut,inttime=inttime,$
            cut_length=cut_length,extrapol_length=extrapol_length,nocalibrate=nocalibrate,interval_n=interval_n
          if (errormess ne '') then begin
            print,errormess
            ;return
          endif
          if (not defined(p_matrix)) then begin
            fscale_common = fscale
            tauscale_common = tauscale
            p_matrix = fltarr(nblock,ncol,nrow,n_elements(fscale))
            ps_matrix = p_matrix
            ph_matrix = p_matrix
            c_matrix = fltarr(nblock,ncol,nrow,n_elements(tauscale))
            cs_matrix = c_matrix
            if (n_elements(cn) eq 1) then begin
              noiselevel_matrix = fltarr(nblock,ncol,nrow)
            endif else begin
              noiselevel_matrix = p_matrix
            endelse
          endif
          if (errormess eq '') then begin
            if (n_elements(fscale) ne n_elements(fscale_common)) then begin
              errormess = 'Frequency scale is different for channels'
              if (not keyword_set(silent)) then print,errormess
              return
            endif
            if ((where(fscale ne fscale_common))[0] ge 0) then begin
              errormess = 'Frequency scale is different for channels'
              if (not keyword_set(silent)) then print,errormess
              return
            endif
            if (n_elements(tauscale) ne n_elements(tauscale_common)) then begin
              errormess = 'Frequency scale is different for channels'
              if (not keyword_set(silent)) then print,errormess
              return
            endif
            if ((where(tauscale ne tauscale_common))[0] ge 0) then begin
              errormess = 'Frequency scale is different for channels'
              if (not keyword_set(silent)) then print,errormess
              return
            endif
            p_matrix[ib,column,row,*] = p
            ps_matrix[ib,column,row,*] = ps
            ph_matrix[ib,column,row,*] = phase
            c_matrix[ib,column,row,*] = corr
            cs_matrix[ib,column,row,*] = corrs
            if (n_elements(cn) eq 1) then begin
              noiselevel_matrix[ib,column,row] = cn
            endif else begin
              noiselevel_matrix[ib,column,row,*] = cn
            endelse
          endif
        endif
      endfor
    endfor
    default,refchannel,-1
    autocorr_calc = autocorr
    crosscorr_calc = crosscorr
    autopower_calc = autopower
    crosspower_calc = crosspower
    crossphase_calc = crossphase
  endfor ; ib
  save,chname_arr,fscale,p_matrix,ps_matrix,fres,shot,timerange,norm,refchannel,autopower_calc,$
     crosspower_calc,crossphase_calc,autocorr_calc,crosscorr_calc,tauscale,c_matrix,cs_matrix,inttime,filter_low,filter_high,filter_order,lowcut,$
     ph_matrix,noiselevel_matrix,cut_length,extrapol_length,block,file=dir_f_name('tmp',savefile)
  block_saved = block
  if (keyword_set(crosspower) or keyword_set(crosscorr) or keyword_set(spectra)) then begin
    signal_cache_delete,name=refchannel
  endif
endif else begin
  if (defined(block)) then block_plot = block
  restore,dir_f_name('tmp',savefile)
  block_saved = block
  if (defined(block_plot)) then block = block_plot
  nblock = n_elements(block)
  ;if (not defined(chname_arr)) then begin
    chname_arr = ecei_channel_map(block=block[0])
    chname_arr = strarr(nblock,(size(chname_arr))[1],(size(chname_arr))[2])
    for ib=0,nblock-1 do chname_arr[ib,*,*]=ecei_channel_map(block=block[ib])
  ;endif
endelse

deftitle = 'Shot: '+i2str(shot)+'  Timerange=['+string(timerange[0],format='(F6.4)')+$
   ','+string(timerange[1],format='(F6.4)')+']'
if (keyword_set(autopower)) then deftitle=deftitle+'  autopower'
if (keyword_set(crosspower)) then deftitle=deftitle+'  crosspower'
if (keyword_set(crossphase)) then deftitle=deftitle+'  crossphase'
if (keyword_set(autocorr)) then deftitle=deftitle+'  autocorr.'
if (keyword_set(crosscorr)) then deftitle=deftitle+'  crosscorr.'
if (keyword_set(crosspower) or keyword_set(crosscorr) or keyword_set(spectra)) then begin
  deftitle = deftitle+' Ref:'+refchannel
endif
if keyword_set(norm) then deftitle = deftitle+' /norm'
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

default,pos,[0.0,0.05,1,0.95]
nblock = n_elements(block)
nrow = (size(chname_arr))[3]
ncol = (size(chname_arr))[2]*nblock
xstep=(pos[2]-pos[0])*0.95/ncol
ystep=(pos[3]-pos[1])*0.95/nrow

if (not keyword_set(noerase)) then erase
if (not keyword_set(nolegend)) then time_legend,'show_all_kstar_ecei_power.pro'
for irow=0,nrow-1 do begin
  for icolumn=0,ncol-1 do begin
    if (nblock eq 1) then begin
      iblock = where(strupcase(block_saved) eq strupcase(block[0]))
    endif  else begin
      iblock = icolumn/(ncol/2)
      iblock = where(strupcase(block_saved) eq strupcase(block[iblock]))
    endelse
    row = irow
    if (nblock ne 1) then column = icolumn mod (ncol/2) else column = icolumn
    if (irow eq 10) and (strupcase(block[iblock]) eq 'H') then continue
    pos1 = [xstep*0.5+(icolumn+0.2)*xstep+iblock*0.01,ystep*0.2+(row+0.2)*ystep,xstep*0.5+(icolumn+0.95)*xstep+iblock*0.01,ystep*0.2+(row+1)*ystep]
    if (keyword_set(autopower) or keyword_set(crosspower)) then begin
      if (row eq 0) then begin
        xtickname=''
        xtitle=' Frequency [kHz]'
      endif else begin
        xtickname=replicate('  ',20)
        xtitle = ''
      endelse
      if (icolumn eq 0) then ytickname='' else ytickname=replicate('  ',20)

       plot,fscale/1000.,reform(p_matrix[iblock,column,row,*]),xrange=frange/1000,xstyle=1,xtype=xtype,/noerase,$
          pos=pos1,$
          yrange=yrange,ystyle=1,ytype=ytype,xtickname=xtickname,xtitle=xtitle,ytickname=ytickname,ytitle=ytitle,$
          thick=thick,xthick=thick,ythick=thick,charthick=thick ;,charsize=0.3*charsize,title=chname_arr[iblock,column,row]
       if (keyword_set(crosspower)) then begin
         if ((size(noiselevel_matrix))[0] eq 2) then begin
           oplot,frange,[noiselevel_matrix[iblock,column,row],noiselevel_matrix[iblock,column,row]]
         endif else begin
           oplot,fscale,reform(noiselevel_matrix[iblock,column,row,*])
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
       plot,fscale/1000.,reform(ph_matrix[iblock,column,row,*])/!pi,xrange=frange/1000,xstyle=1,xtype=xtype,/noerase,$
          pos=pos1,$
          yrange=yrange,ystyle=1,ytype=ytype,xtickname=xtickname,xtitle=xtitle,ytickname=ytickname,ytitle=ytitle,$
          thick=thick,xthick=thick,ythick=thick,charthick=thick ;,charsize=0.3*charsize,title=chname_arr[iblock,column,row]
    endif
    if (keyword_set(autocorr) or keyword_set(crosscorr)) then begin
      if (row eq 0) then begin
        xtickname=''
        xtitle=' Time lag [!7l!Xs]'
      endif else begin
        xtickname=replicate('  ',20)
        xtitle = ''
      endelse
      
        numdat=n_elements(c_matrix[0,0,0,*])
        c_matrix2=dblarr(nblock,ncol/2,nrow,2*numdat)
        c_matrix2[*,*,*,0:numdat-1]=c_matrix
        c_matrix2[*,*,*,numdat:2*numdat-1]=c_matrix

        in2=50
        for idata=0,numdat+in2 do begin
          c_matrix2[iblock,column,irow,idata]-=mean(c_matrix2[iblock,column,irow,idata:idata+in2])
        endfor
        
        c_matrix=c_matrix2[*,*,*,0:numdat-1]
        c_matrix[iblock,column,irow,*]-=mean(c_matrix[iblock,column,irow,*])
        
      if (column eq 0) then ytickname='' else ytickname=replicate('  ',20)
       plot,tauscale,reform(c_matrix[iblock,column,row,*]),xrange=taurange,xstyle=1,xtype=xtype,/noerase,$
          pos=pos1,$
          yrange=yrange,ystyle=1,ytype=ytype,xtickname=xtickname,xtitle=xtitle,ytickname=ytickname,ytitle=ytitle,$
          thick=thick,xthick=thick,ythick=thick,charthick=thick ;,title=chname_arr[iblock,column,row],charsize=0.3*charsize
    endif

  endfor
endfor
;xyouts,pos[0]+xstep*0.3,pos[3]-ystep*0.3,/norm,title,charsize=1.2,charthick=thick

if keyword_set(plot_2d) then begin
  
  erase
  loadct,3
  default, nlev,51
  device, decomposed=0
  numdat=n_elements(c_matrix[0,0,0,*])
  maxcorr=dblarr(nblock,ncol/2,nrow)
  help, maxcorr
  twin=100
  
  for iblock=0,nblock-1 do begin
    for irow=0,nrow-1 do begin
      for icolumn=0,ncol-1 do begin            
        if (nblock ne 1) then column = icolumn mod (ncol/2) else column = icolumn                  
        maxcorr[iblock,column,irow]=max(reform(c_matrix[iblock,column,irow,where(tauscale gt -twin and tauscale lt twin)]))
      endfor
    endfor
    position=[[0.05,0.05,0.5,1],$
              [0.5,0.05,0.95,1]]
    num=iblock[0]
    default,plotrange,[min(maxcorr),max(maxcorr)]
    default,levels,(findgen(nlev))/(nlev)*(plotrange[1]-plotrange[0])+plotrange[0]
    contour,maxcorr[num,*,*],position=position[*,num], /noerase, fill=1, nlev=nlev,$
    levels=levels, /isotrop
  endfor

endif

if keyword_set(postscript) then begin
   hardfile, 'plots/ecei_spectra_'+strtrim(shot,2)+'_'+strtrim(timerange[0],2)+'_'+strtrim(timerange[1],2)+'.ps'
endif
end
