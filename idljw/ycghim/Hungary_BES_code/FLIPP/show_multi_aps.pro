pro show_multi_aps,power,powerscat,z,f,channels=channels_in,frange=frange,title=title,$
	noerase=noerase,nolegend=nolegend,equal_scale=equal_scale,$
    para_txt=para_txt,nopara=nopara,linethick=linethick,$
    axisthick=axisthick,charsize=charsize,zztfile=zztfile,errormess=errormess,silent=silent,$
    background_zztfile=backfile,linestyle=linestyle,psym=psym,ytype=ytype,yrange=yrange,noerror=noerror,$
    columns=columns,rows=rows,xtype=xtype


;***********************************************************************************
; Plot multiple autopwer spectra read using load_zztcorr.pro or read directly from zzt file.
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
;   channels: The list of channels to plot.
;   /equal_scale: Set equal y scale for all plots
; PLOT parameters:
;   title: title of plot
;   /noerase: do not erase screen/page before plotting
;   /nolegend: Do not print legend in upper rh corner
;   /nopara: Do not print parameters on plot
;   linethick: The line thickness  (def:1)
;   axisthick: The axis thickness (def: 1)
;   charsize: Character size (def: 1)
;   /noerror: Do not plot error bars
;   columns: number of columns to plot
;   rows: number of rows to plot
; OUTPUT:
;   errormess: Error message or ''
;**********************************************************************************


default,title,'Autopower'
default,linethick,1
default,axisthick,1
default,charsize,1
default,ytitle,'Z [cm]'
default,ytype,0
default,xtype,0


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
    ind = where(f eq f_b)
    if (ind[0] lt 0) then return
    f = f[ind]
    f_b = f_b[ind]
    power = power[*,*,ind]
    power_b = power_b[*,*,ind]
    powerscat = powerscat[*,*,ind]
    powerscat_b = powerscat_b[*,*,ind]
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


if (not defined(channels_in)) then begin
  channels_in = channels
endif


ind_f = where((f ge frange[0]) and (f le frange[1]))
if (ind_f[0] lt 0) then begin
  errormess = 'No data in frequency range.'
  if (not keyword_set(silent)) then print,errormess
  return
endif
f = f[ind_f]

nch_in = n_elements(channels_in)
for i=0,nch_in-1 do begin
  if (size(channels,/type) eq 7) then begin
    ind1 = where(channels_in[i] eq string(channels))
  endif else begin
    ind1 = where(channels_in[i] eq fix(channels))
  endelse
  if (ind1[0] ge 0) then begin
    if (not defined(ind)) then begin
      ind = ind1[0]
    endif else begin
      ind = [ind,ind1[0]]
    endelse
  endif
endfor
if (not defined(i)) then begin
  erromess = 'Requested channels not found.'
  if (not keyword_set(silent)) then print,errormess
  return
endif
power = power[ind,ind,*]
power = power[*,*,ind_f]
powerscat = powerscat[ind,ind,*]
powerscat = powerscat[*,*,ind_f]
channels = channels_in

pos=!p.position
if (total(pos) eq 0) then pos=[0.07,0.15,0.7,0.85]
if (not keyword_set(noerase)) then erase
if (not keyword_set(nolegend)) then time_legend,'show_multi_aps.pro'
if (not keyword_set(nopara)) then begin
  plots,[pos(2)+0.02,pos(2)+0.02],[0.1,0.9],thick=3,/normal
  xyouts,pos(2)+0.04,0.85,para_txt,/normal,charthick=axisthick
endif

if (keyword_set(noerror)) then begin
  if (ytype eq 0) then begin
    default,yrange,[0,max(power)*1.05]
  endif else begin
    default,yrange,[0.001,1]*max(power)*1.05
  endelse
endif else begin
  if (ytype eq 0) then begin
    default,yrange,[0,max(power+powerscat)*1.05]
  endif else begin
    default,yrange,[0.001,1]*max(power+powerscat)*1.05
  endelse
endelse

nch = n_elements(channels)
default,columns,fix(sqrt(nch))
default,rows,fix(nch/columns)
while(columns*rows lt nch) do columns=columns+1

xstep = (pos[2]-pos[0])/(columns-0.35)
ystep = (pos[3]-pos[1])/(rows-0.2)

flog = fix(alog10(max(f)))
f = f/10.^flog
frange = frange/10.^flog
for i=0, nch-1 do begin
  ir = fix(i/columns)
  ic = i-ir*columns
  p = reform(power[i,i,*])
  ps = reform(powerscat[i,i,*])
  if (ir eq rows-1) then begin
  xtitle = 'Frequency [10!U'+i2str(flog)+'!NHz]'
    xtickname = ''
  endif else begin
    xtitle = ' '
    xtickname = replicate(' ',20)
  endelse
  if (ic eq 0) then begin
    ytitle = 'Power [a.u.]'
  endif else begin
    ytitle = ' '
  endelse
  if (keyword_set(equal_scale)) then begin
    yrange_1 = yrange
  endif else begin
    if (keyword_set(noerror)) then begin
      if (ytype eq 0) then begin
        yrange_1 = [0,max(p)*1.05]
      endif else begin
        yrange_1 = [0.001,1]*max(p)*1.05
      endelse
    endif else begin
      if (ytype eq 0) then begin
        yrange_1 = [0,max(p+ps)*1.05]
      endif else begin
        yrange_1 = [0.001,1]*max(p+ps)*1.05
      endelse
    endelse
  endelse

  pos1 = [pos[0]+xstep*ic,pos[3]-ystep*(ir+0.8),pos[0]+xstep*(ic+0.65),pos[3]-ystep*ir]
  if (size(channels,/type) eq 7) then begin
    title = channels[i]
  endif else begin
    title = i2str(channels[i])
  endelse
  plot,f,p,xrange=frange,xstyle=1,xthick=axisthick,xtitle=xtitle,xtype=xtype,$
    xtickname=xtickname,yrange=yrange_1,ystyle=1,ytype=ytype,ytitle=ytitle,ythick=axisthick,$
    thick=linethick,charthick=axisthick,psym=psym,linestyle=linestyle,/noerase,position=pos1,title=title,charsize=charsize*0.7
  if (not keyword_set(noerror)) then begin
    errplot,f,p-ps,p+ps,thick=linethick
  endif
endfor

end
