pro show_aps,power,powerscat,z,f,zplot=zplot,channel=channel,frange=frange,title=title,$
	noerase=noerase,nolegend=nolegend,fscale=fscale,$
    para_txt=para_txt,nopara=nopara,linethick=linethick,$
    axisthick=axisthick,charsize=charsize,zztfile=zztfile,errormess=errormess,silent=silent,$
    background_zztfile=backfile,linestyle=linestyle,psym=psym,ytype=ytype,yrange=yrange,$
    noerror=noerror

;***********************************************************************************
; Plot autopwer spectrum read using load_zztcorr.pro or read directly from zzt file.
;
; INPUT:
;   power: The 3D crosspower array calculated by fluc_zztcorr.pro
;   powerscat: The error of the 3D crosspower array calculated by fluc_zztcorr.pro
;   z: Z scale (space coordinate)
;   f: Frequency scale
;   zztfile: Name of data file written by zztcorr.pro. If this given inputs z and f are omitted.
;   background_zztfile: The zzt file produced with the same parameter settings but with beam off.
;                        The power spectrum will be subtracted and the difference shown.
;   /silent: Do not print error message on error, just return in errormess
;   para_txt: The parameters of the calculation as returned by load_zztcorr
;   zplot: The Z coordinate where the autopower is plot. The program will interpolate
;          between individual spectra.
;   channel: The channel to plot. This is an alternative to zplot
;   fscale: 'Hz', 'kHz', or 'MHz' (default: Hz)
; PLOT parameters:
;   title: title of plot
;   /noerase: do not erase screen/page before plotting
;   /nolegend: Do not print legend in upper rh corner
;   /nopara: Do not print parameters on plot
;   linethick: The line thickness  (def:1)
;   axisthick: The axis thickness (def: 1)
;   charsize: Character size (def: 1)
;   /noerror: Do not plot error bars
; OUTPUT:
;   errormess: Error message or ''
;**********************************************************************************


default,title,'Autopower'
default,linethick,1
default,axisthick,1
default,charsize,1
default,ytitle,'Z [cm]'
default,ytype,0
default,fscale,'Hz'

if ((strupcase(fscale) ne 'HZ') and (strupcase(fscale) ne 'KHZ') and (strupcase(fscale) ne 'MHZ')) then begin
  errormess = 'fscale should be either Hz, kHz, or MHz'
  if (not keyword_set(silent)) then print,errormess
  return
endif

if (defined(channel) and defined(zplot)) then begin
  errormess = 'Set only on of channel and zplot.'
  if (not keyword_set(silent)) then print,errormess
  return
endif

if (defined(zztfile)) then begin
  load_zztcorr,shot,k,kscat,z,t,f,power,powerscat,para_txt=para_txt,channels=channels,file=zztfile,errormess=errormess
  if (errormess ne '') then begin
    if (not keyword_set(silent)) then print,errormess
    return
  endif
endif

if (defined(backfile)) then begin
  load_zztcorr,shot_b,k_b,kscat_b,z_b,t_b,f_b,power_b,powerscat_b,para_txt=para_txt_b,channels=channels_b,file=backfile,errormess=errormess
  if (errormess ne '') then begin
    if (not keyword_set(silent)) then print,errormess
    return
  endif
  if ((n_elements(z_b) ne n_elements(z)) or (n_elements(f) ne n_elements(f_b))) then begin
    errormess = 'Signal and background calculation parameters are different.'
    if (not keyword_set(silent)) then print,errormess
    return
  endif
  if ((total(abs(z_b-z)) gt mean(z)*0.01)  or (total(abs(f_b-f)) gt mean(f)*0.01) or (total(channels ne channels_b) ne 0)) then begin
    errormess = 'Signal and background calculation parameters are different.'
    if (not keyword_set(silent)) then print,errormess
    return
  endif
  power = power - power_b
  powerscat = sqrt(powerscat^2 + powerscat_b^2)
  para_txt = para_txt+'!C!CBackground corrected data!Cbackground zztfile:!C    '+backfile

endif

default,frange,[min(f),max(f)]
default,para_txt,''


if (not defined(channel) and not defined(zplot)) then begin
  channel = channels[0]
endif
if (not defined(channel)) then  default,zplot,min(z)

nch = (size(power))[1]
nf = (size(power))[3]

ind_f = where((f ge frange[0]) and (f le frange[1]))
if (ind_f[0] lt 0) then begin
  errormess = 'No data in frequency range.'
  if (not keyword_set(silent)) then print,errormess
  return
endif
f = f[ind_f]

if (defined(channel)) then begin
  if (size(channels,/type) eq 7) then begin
    ind = where(channels eq string(channel))
  endif else begin
    ind = where(channels eq fix(channel))
  endelse
  if (ind[0] lt 0) then begin
    errormess = 'Requested channel is not available in calculation.'
    if (not keyword_set(silent)) then print,errormess
    return
  endif
  power = reform(power[ind[0],ind[0],ind_f])
  powerscat = reform(powerscat[ind[0],ind[0],ind_f])
  plotpara = 'Channel: '+string(channel)
endif else begin
  ind = closeind(z,zplot)
  if (ind eq 0) then ind1 = ind+1
  if (ind eq n_elements(z)-1) then ind1= ind-1
  if ((ind gt 0) and (ind lt n_elements(z)-1)) then begin
    if (abs(z[ind+1]-zplot) lt abs(z[ind-1]-zplot)) then begin
      ind1 = ind+1
    endif else begin
      ind1 = ind-1
    endelse
  endif
  w1 = abs(zplot-z[ind])/abs(z[ind]-z[ind1])
  w2 = abs(zplot-z[ind1])/abs(z[ind]-z[ind1])
  power = w1*reform(power[ind,ind,ind_f]) + w2*reform(power[ind1,ind1,ind_f])
  powerscat = w1*reform(powerscat[ind,ind,ind_f]) + w2*reform(powerscat[ind1,ind1,ind_f])
  plotpara = 'Z= '+string(zplot,format='(F6.2)')
endelse


pos=!p.position
if (total(pos) eq 0) then pos=[0.07,0.15,0.7,0.7]
if (not keyword_set(noerase)) then erase
if (not keyword_set(nolegend)) then time_legend,'show_aps.pro'
if (not keyword_set(nopara)) then begin
  plots,[pos(2)+0.02,pos(2)+0.02],[0.1,0.9],thick=3,/normal
  xyouts,pos(2)+0.04,0.85,para_txt+'!C!C'+plotpara,/normal
endif

if (ytype eq 0) then begin
  default,yrange,[0,max(power)*1.05]
endif else begin
  default,yrange,[0.001,1]*max(power)*1.05
endelse

ftitle = 'Frequency [Hz]'
if (strupcase(fscale) eq 'KHZ') then begin
  f = f/1e3
  frange = frange/1e3
  ftitle = 'Frequency [kHz]'
endif
if (strupcase(fscale) eq 'MHZ') then begin
  f = f/1e6
  frange = frange/1e6
  ftitle = 'Frequency [MHz]'
endif
plot,f,power,xrange=frange,xstyle=1,xthick=axisthick,xtitle=ftitle,$
     yrange=yrange,ystyle=1,ytype=ytype,ytitle=ytitle,ythick=axisthick,$
     thick=linethick,charthick=axisthick,psym=psym,linestyle=linestyle,/noerase,position=pos,title=title,charsize=charsize
if (not keyword_set(noerror)) then begin
  errplot,f,power-powerscat,power+powerscat,thick=linethick
endif

end
