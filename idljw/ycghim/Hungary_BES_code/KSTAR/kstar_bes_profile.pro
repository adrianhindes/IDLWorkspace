pro kstar_bes_profile,shot,timerange=timerange,background_timerange=background_timerange,$
   savefile=savefile,nocalculate=nocalculate, yrange=yrange,thick=thick,charsize=charsize,$
   plot_profile=plot_profile,plot_full=plot_full,plot_background=plot_background,photons=photons,$
   nocalibrate=nocalibrate, timefile=timefile


default,savefile,'kstar_bes_profile.sav'

if (not keyword_set(nocalculate)) then begin

  profile = fltarr(8,4)  ; light profile in the 8 rows
  profile_back = fltarr(8,4) ; Background light profile
  channels = fltarr(8)
  rows = fltarr(4)
  if (n_elements(background_timerange) ge 2) then begin
    full_trange = [min([timerange,background_timerange]),max([timerange,background_timerange])]
  endif else begin
    full_trange = timerange
  endelse

  for i=0,3 do begin ; rows
    for j=0,7 do begin  ; columns
      channel = 'BES-'+i2str(i+1)+'-'+i2str(j+1)
      print,channel & wait=0.1
      if keyword_set(timefile) then begin
        times=loadncol(dir_f_name('time',timefile),2,/silent,errormess=errormess)
        
        for k=0,n_elements(times[*,0])-1 do begin
          get_rawsignal,shot,channel,timerange=reform(times[k,*]),t,d,nocalibrate=nocalibrate
          if (ind[0] lt 0) then begin
            errormess = 'No data in time range.'
            if (not keyword_set(silent)) then print,errormess
            return
          endif
          profile[j,i] += mean(d)*(times[k,1]-times[k,0])/(total(times[*,1]-times[*,0]))
        endfor 
      endif else begin
        get_rawsignal,shot,channel,timerange=full_timerange,t,d,nocalibrate=nocalibrate
        ind = where((t ge timerange[0]) and (t le timerange[1]))
        if (ind[0] lt 0) then begin
          errormess = 'No data in time range.'
          if (not keyword_set(silent)) then print,errormess
          return
        endif
        profile[j,i] = mean(d[ind])
      endelse
      if (n_elements(background_timerange) ge 2) then begin
        ind = where((t ge background_timerange[0]) and (t le background_timerange[1]))
        if (ind[0] lt 0) then begin
          errormess = 'No data in background time range.'
          if (not keyword_set(silent)) then print,errormess
          return
        endif
        profile_back[j,i] = mean(d[ind])
      endif
    endfor ; columns
  endfor ; rows
  save,channels,rows,profile,profile_back,shot,timerange,background_timerange,file=dir_f_name('tmp',savefile)
endif else begin
  restore,dir_f_name('tmp',savefile)
endelse

if (keyword_set(plot_profile)) then begin
  if (keyword_set(photons)) then begin
    calfac = calc_abs_cal_fac(shot)
    ytitle = 'Photon flux [Ph/s]'
  endif else begin
    calfac = 1
    ytitle = 'Signal [V]
  endelse
  plot_prof = (profile-profile_back)*calfac
  default,yrange,[0,max(plot_prof)*1.05]
  default,title,i2str(shot)+' ['+string(timerange[0],format='(F5.3)')+','+string(timerange[1],format='(F5.3)')+']  BES light'
  plot,channels,plot_prof,/nodata,yrange=yrange,ystyle=1,ytitle=ytitle,xrange=[max(channels)+0.5,0.5],xstyle=1,xtitle='Channel',title=title,$
  thick=thick,xthick=thick,ythick=thick,charthick=thick,charsize=charsize
  for i=0,3 do begin
    plotsymbol,i
    oplot,channels,plot_prof[*,i],psym=-8,thick=thick,linest=i
  endfor
endif

if (keyword_set(plot_full)) then begin
  if (keyword_set(photons)) then begin
    calfac = calc_abs_cal_fac(shot)
    ytitle = 'Photon flux [Ph/s]'
  endif else begin
    calfac = 1
    ytitle = 'Signal [V]
  endelse
  plot_prof = profile*calfac
  default,yrange,[0,max(plot_prof)*1.05]
  default,title,i2str(shot)+' ['+string(timerange[0],format='(F5.3)')+','+string(timerange[1],format='(F5.3)')+']   Full light'
  plot,channels,plot_prof,/nodata,yrange=yrange,ystyle=1,ytitle=ytitle,xrange=[max(channels)+0.5,0.5],xstyle=1,xtitle='Channel',title=title,$
  thick=thick,xthick=thick,ythick=thick,charthick=thick,charsize=charsize
  for i=0,3 do begin
    plotsymbol,i
    oplot,channels,plot_prof[*,i],psym=-8,thick=thick,linest=i
  endfor
endif

if (keyword_set(plot_background)) then begin
  if (keyword_set(photons)) then begin
    calfac = calc_abs_cal_fac(shot)
    ytitle = 'Photon flux [Ph/s]'
  endif else begin
    calfac = 1
    ytitle = 'Signal [V]
  endelse
  plot_prof = profile_back*calfac
  default,yrange,[0,max(plot_prof)*1.05]
  default,title,i2str(shot)+' ['+string(timerange[0],format='(F5.3)')+','+string(timerange[1],format='(F5.3)')+']  Background'
  plot,channels,plot_prof,/nodata,yrange=yrange,ystyle=1,ytitle=ytitle,xrange=[max(channels)+0.5,0.5],xstyle=1,xtitle='Channel',title=title,$
  thick=thick,xthick=thick,ythick=thick,charthick=thick,charsize=charsize
  for i=0,3 do begin
    plotsymbol,i
    oplot,channels,plot_prof[*,i],psym=-8,thick=thick,linest=i
  endfor
endif


end