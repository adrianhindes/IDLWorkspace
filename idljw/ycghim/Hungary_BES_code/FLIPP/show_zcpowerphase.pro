pro show_zcpowerphase,power,powerscat,phase,z,f,franges=franges,title=title,zrange=zrange,noerase=noerase,nolegend=nolegend,$
    lcfs=lcfs,para_txt=para_txt,nopara=nopara,linethick=linethick,refz=refz,refchannel=refchannel,$
    axisthick=axisthick,charsize=charsize,zztfile=zztfile,errormess=errormess,silent=silent,norm=norm,ztitle=ztitle
;***********************************************************************************
; Plots crosspower and cross-phase in a series of freqency ranges as a function of
; spatial coordiante for a series
; of channels processed using zztcorr.pro. Data can be read using load_zztcorr.pro
; prior to calling this program or this program can read them directly from zzt file.
;
; INPUT:
;   power: The 3D crosspower array calculated by fluc_zztcorr.pro
;   powerscat: The error of the 3D crosspower array calculated by fluc_zztcorr.pro
;   phase: The 3D crossphase array calculated by fluc_zztcorr.pro
;   z: Z scale (space coordinate)
;   f: Frequency scale
;   zztfile: Name of data file written by zztcorr.pro. If this given inputs z and f are omitted.
;   /silent: Do not print error message, just return in errormess
;   para_txt: The parameters of the calculation as returned by load_zztcorr
;   franges: The frequency ranges to process: [f1min,f1max,f2min,f2max,...]
;   refz: The Z coordinate of the reference location. The program will interpolate
;          between individual spectra.
;   refchannel: The reference channel. This is an alternative to zref.
;   /norm: Plot coherency instead of crosspower.
; PLOT parameters:
;   title: title of plot
;   zrange, frange: spatial and frequency range
;   lcfs: if value is less than 300, this is the LCFS Z position, otherwise
;       consider this as shot number and get position of LCFS using get_lcfs()
;   /noerase: do not erase screen/page before plotting
;   /nolegend: Do not print legend in upper rh corner
;   /nopara: Do not print parameters on plot
;   linethick: The line thickness  (def:1)
;   axisthick: The axis thickness (def: 1)
;   charsize: Character size (def: 1)
; OUTPUT:
;   errormess: Error message or ''
;**********************************************************************************


if (defined(channel) and defined(zplot)) then begin
  errormess = 'Set only on of channel and zplot.'
  if (not keyword_set(silent)) then print,errormess
  return
endif

if (defined(zztfile)) then begin
  load_zztcorr,shot,k,kscat,z,t,f,power,powerscat,phase,para_txt=para_txt,channels=channels,file=zztfile,errormess=errormess,ztitle=ztitle_file
  if (errormess ne '') then begin
    if (not keyword_set(silent)) then print,errormess
    return
  endif
  default,ztitle,ztitle_file
endif

; In some calculations the z scale has an additional element
z = z[0:(size(power))[1]-1]

default,franges,[min(f),max(f)]
default,title,''
default,zrange,[min(z),max(z)]
default,para_txt,''
default,linethick,1
default,axisthick,1
default,charsize,1
default,plotpara,''
if (not defined(refz) and not defined(refchannel)) then begin
  refchannel = channels[n_elements(channels)/2]
endif

if (keyword_set(lcfs)) then begin
  if (lcfs gt 300) then lcfs=get_lcfs(lcfs)
endif

channel_ind = where((z ge zrange[0]) and (z le zrange[1]))
if (channel_ind[0] lt 0) then begin
  errormess = 'No data in z range.'
  if (not keyword_set(silent)) then print,errormess
  return
endif

if (defined(refchannel)) then begin
  refchannel_ind = (where(refchannel eq channels))[0]
  if (refchannel_ind lt 0) then begin
    errormess = 'Rerefence channel not found.'
    if (not keyword_set(silent)) then print,errormess
    return
  endif
  refz = z[refchannel_ind]
endif

; The two indices to the channels form which we interpolate.
ind_1 = closeind(z,refz)
ind_2a = ind_1-1
ind_2b = ind_1+1
if (ind_2a lt 0) then begin
  ind_2 = ind_2b
endif else begin
  if (ind_2b gt n_elements(z)-1) then begin
    ind_2 = ind_2a
  endif else begin
    if (abs(z[ind_2a]-refz) lt abs(z[ind_2b]-refz)) then begin
      ind_2 = ind_2a
    endif else begin
      ind_2 = ind_2b
    endelse
  endelse
endelse
weight_2 = abs(refz-z[ind_1])/abs(z[ind_2]-z[ind_1])
weight_1 = abs(refz-z[ind_2])/abs(z[ind_2]-z[ind_1])

nch = n_elements(channel_ind)
nfreq = n_elements(franges)/2
power_list = fltarr(nfreq,nch)
phase_list = fltarr(nfreq,nch)
for ich=0,nch-1 do begin
  for ifreq=0, nfreq-1 do begin
    ind_f = where((f ge franges[ifreq*2]) and (f le franges[ifreq*2+1]))
    ;if (ind_1 eq channel_ind[ich]) then stop
    if (ind_f[0] lt 0) then begin
      errormess = 'No data in frequency range: ['+string(franges[ifreq*2],format='(E10)')+','+string(franges[ifreq*2+1],format='(E10)')+']'
      if (not keyword_set(silent)) then print,errormess
      return
    endif
    c = weight_1*reform(power[ind_1,channel_ind[ich],ind_f]) + weight_2*reform(power[ind_2,channel_ind[ich],ind_f])
    if (keyword_set(norm)) then begin
      ca1 = weight_1*reform(power[ind_1,ind_1,ind_f]) + weight_2*reform(power[ind_2,ind_2,ind_f])
      ca2 = reform(power[channel_ind[ich],channel_ind[ich],ind_f])
      c = c/sqrt(ca1*ca2)
    endif
    power_list[ich] = mean(c)
    phases = [reform(phase[ind_1,channel_ind[ich],ind_f]), reform(phase[ind_2,channel_ind[ich],ind_f])]
    p = weight_1*reform(power[ind_1,channel_ind[ich],ind_f]) + weight_2*reform(power[ind_2,channel_ind[ich],ind_f])
    weights = [(fltarr(n_elements(phases)/2)+weight_1)*p,(fltarr(n_elements(phases)/2)+weight_2)*p]
    phase_list[ich] = mean_phase(phases,weights)
  endfor
endfor




pos=!p.position
if (total(pos) eq 0) then pos=[0.1,0.15,0.7,0.7]
pos_power = [pos[0],pos[1]+(pos[3]-pos[1])*0.6,pos[2],pos[3]]
pos_phase = [pos[0],pos[1],pos[2],pos[1]+(pos[3]-pos[1])*0.4]

if (not keyword_set(noerase)) then erase
if (not keyword_set(nolegend)) then time_legend,'show_zcpowerphase.pro'
if (not keyword_set(nopara)) then begin
  plots,[pos(2)+0.02,pos(2)+0.02],[0.1,0.9],thick=3,/normal
  xyouts,pos(2)+0.04,0.85,para_txt+'!C!C'+plotpara,/normal
endif

if (keyword_set(norm)) then c_title = 'Coherency' else c_title = 'Crosspower'
if (defined(yrange)) then yrange_power = yrange[0:1]
default,yrange_power,[0,max(power_list)*1.1]
plotsymbol,0
plot,z[channel_ind],power_list,pos=pos_power,/noerase,psym=8,title=c_title,xtitle=ztitle,yrange=yrange_power,$
   ystyle=1,xrange=zrange,xstyle=1,thick=linethick,xthick=axisthick,ythick=axisthick,$
  charthick=axisthick,charsize=charsize
oplot,[refz,refz],yrange_power,linestyle=1,thick=linethick

if (defined(yrange)) then begin
  if (n_elements(yrange) ge 4) then yrange_phase = yrange[2:3]
endif
default,yrange_phase, [-1.05,1.05]
plotsymbol,0
plot,z[channel_ind],phase_list/!Pi,pos=pos_phase,/noerase,psym=8,title='Phase',xtitle=ztitle,$
  ystyle=1,xrange=zrange,xstyle=1,ytitle='Phase [!7p!X]',yrange=yrange_phase,thick=linethick,xthick=axisthick,ythick=axisthick,$
  charthick=axisthick,charsize=charsize
oplot,[refz,refz],yrange_phase,linestyle=1,thick=linethick
oplot,zrange,[0,0],linestyle=1,thick=linethick



end
