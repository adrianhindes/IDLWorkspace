pro show_zfaps,power,powerscat,z,f,frange=frange,title=title,contour=contour,$
    fill=fill,surface=surface,isurface=isurface,shade_surf=shade_surf,surf_ax=ax,surf_az=az,nlev=nlev,$
	levels=levels,zrange=zrange,noerase=noerase,nolegend=nolegend,$
    pluslevels=pluslevels,noscale=noscale,plotrange=plotrange,ztype=ztype,$
    colorscheme=colorscheme,lcfs=lcfs,para_txt=para_txt,nopara=nopara,linethick=linethick,$
    axisthick=axisthick,charsize=charsize,ytitle=ytitle,zztfile=zztfile,errormess=errormess,silent=silent,$
    background_zztfile=backfile
;***********************************************************************************
; Plot z-f (space-frequency) distribution of autopower spectra read
; using load_zztcorr.pro or read directly from zzt file.
;
; INPUT:
;   power: The 3D crosspower array calculated by fluc_zztcorr.pro
;   powerscat: The error of the 3D crosspower array calculated by fluc_zztcorr.pro
;   z: Z scale (space coordinate)
;   f: Frequency scale
;   zztfile: Name of data file written by zztcorr.pro. If this given inputs z and f are omitted.
;   background_zztfile: The zzt file produced with the same parameter settings but with beam off.
;                        The power spectrum will be subtracted and the difference shown.
;   /silent: Do not print error message, just return in errormess
;   para_txt: The parameters of the calculation as returned by load_zztcorr
; PLOT parameters:
;   title: title of plot
;   /contour: plot contour plot
;   /fill: filled contour plot
;   /surface: plot surface plot
;   /shade_surf: plot shade_surf plot
;   surf_ax,surf_az: same as ax and az for the IDL surface command
;   nlev: number of levels for contour
;   levels: the list of levels for contour
;   zrange, frange: spatial and frequency range
;   ztype: 1: log scale
;   plotrange: vertical plot range
;   pluslevels: plot only positive contours
;   /noscale: do not plot scale bar
;   colorscheme: color scheme ('red-white-blue','blue-white-red','white-black','back-white')
;                (see setcolor.pro)
;   lcfs: if value is less than 300, this is the LCFS Z position, otherwise
;       consider this as shot number and get position of LCFS using get_lcfs()
;   /noerase: do not erase screen/page before plotting
;   /nolegend: Do not print legend in upper rh corner
;   /nopara: Do not print parameters on plot
;   linethick: The line thickness  (def:1)
;   axisthick: The axis thickness (def: 1)
;   charsize: Character size (def: 1)
;   ytitle: The title of the Y (spatial) scale
; OUTPUT:
;   errormess: Error message or ''
;**********************************************************************************


if (defined(zztfile)) then begin
  load_zztcorr,shot,k,kscat,z,t,f,power,powerscat,para_txt=para_txt,file=zztfile,errormess=errormess
  if (errormess ne '') then begin
    if (not keyword_set(silent)) then print,errormess
    return
  endif
endif

if (defined(backfile)) then begin
  load_zztcorr,shot_b,k_b,kscat_b,z_b,t_b,f_b,power_b,powerscat_b,para_txt=para_txt_b,file=backfile,errormess=errormess
  if (errormess ne '') then begin
    if (not keyword_set(silent)) then print,errormess
    return
  endif
endif

default,frange,[min(f),max(f)]
default,title,''
if (not keyword_set(surface) and not keyword_set(shade_surf) and not keyword_set(isurface)) then contour=1
default,ax,60
default,az,30
default,nlev,30
default,zrange,[min(z),max(z)]
default,fill,1
if ((!d.name eq 'WIN') or (!d.name eq 'X')) then  begin
  default,colorscheme,'black-white'
endif else begin
  default,colorscheme,'white-black'
endelse
default,para_txt,''
default,linethick,1
default,axisthick,1
default,charsize,1
default,ytitle,'Z [cm]'
default,plotpara,''


if (keyword_set(lcfs)) then begin
  if (lcfs gt 300) then lcfs=get_lcfs(lcfs)
endif

nch = (size(power))[1]
nf = (size(power))[3]
aps2 = fltarr(nf,nch)
for i=0,nch-1 do begin
  aps2[*,i] = reform(power[i,i,*])
endfor
ind=where((z ge zrange(0)) and (z le zrange(1)))
ind1=where((f ge frange(0)) and (f le frange(1)))
if ((ind[0] ge 0) and (ind1[0] ge 0)) then begin
  aps2_cut=aps2[*,ind]
  z = z[ind]
  aps2_cut=aps2_cut[ind1,*]
  f = f[ind1]
endif else begin
  aps2_cut=0
  errormess = 'No data in range'
  if (not keyword_set(silent)) then print,errormess
  return
endelse

if defined(backfile) then begin
  nch_b = (size(power))[1]
  nf_b = (size(power))[3]
  aps2_b = fltarr(nf_b,nch_b)
  for i=0,nch-1 do begin
    aps2_b[*,i] = reform(power_b[i,i,*])
  endfor
  ind=where((z_b ge zrange(0)) and (z_b le zrange(1)))
  ind1=where((f_b ge frange(0)) and (f_b le frange(1)))
  if ((ind[0] ge 0) and (ind1[0] ge 0)) then begin
    aps2_b_cut=aps2_b[*,ind]
    z_b = z_b[ind]
    aps2_b_cut=aps2_b_cut[ind1,*]
    f_b = f_b[ind1]
  endif else begin
    aps2_cut=0
    errormess = 'No background data in range'
    if (not keyword_set(silent)) then print,errormess
    return
  endelse
  if ((nch_b ne nch) or (nf_b ne nf)) then begin
    errormess = 'Background calculation parameters are different.'
    if (not keyword_set(silent)) then print,errormess
    return
  endif
  if ((total(z ne z_b) gt 0) or (total(f ne f_b) gt 0)) then begin
    errormess = 'Background calculation parameters are different.'
    if (not keyword_set(silent)) then print,errormess
    return
  endif
  aps2_cut = aps2_cut - aps2_b_cut
  para_txt = para_txt+'!C!CBackground corrected data!Cbackground zztfile:!C    '+backfile
endif

pos=!p.position
if (total(pos) eq 0) then pos=[0.07,0.15,0.7,0.7]

default,plotrange,[min(aps2_cut),max(aps2_cut)]
if (keyword_set(pluslevels)) then begin
  default,levels,(findgen(nlev))/(nlev)*abs(plotrange(1))
endif else begin
  default,levels,(findgen(nlev))/(nlev)*(plotrange(1)-plotrange(0))+plotrange(0)
endelse

setcolor,levels=levels,c_colors=c_colors,scheme=colorscheme
if (not keyword_set(noerase)) then erase
if (not keyword_set(nolegend)) then time_legend,'show_zfaps.pro'
if (not keyword_set(nopara)) then begin
  plots,[pos(2)+0.02,pos(2)+0.02],[0.1,0.9],thick=3,/normal
  xyouts,pos(2)+0.04,0.85,para_txt+'!C!C'+plotpara,/normal
endif

;if (!d.name eq 'PS') then begin
;  c_colors=fix((nlev-1-findgen(nlev))/(nlev)*(!d.n_colors-1))
;endif else begin
;  c_colors=fix((findgen(nlev)+1)/(nlev)*(!d.n_colors-1))
;endelse


if (keyword_set(contour)) then begin
		if (keyword_set(fill) and not keyword_set(noscale)) then begin
		  sc=fltarr(2,50)
			scale=findgen(50)/49*(max(aps2_cut)-min(aps2_cut))+min(aps2_cut)
			sc(0,*)=scale
			sc(1,*)=scale
			contour,sc,[0,1],scale,levels=levels,nlev=nlev,/fill,$
			position=[pos(2)-0.03,pos(1),pos(2),pos(3)],$
			xstyle=1,xrange=[0,0.9],ystyle=1,yrange=[plotrange(0),plotrange(1)],xticks=1,$
			xtickname=[' ',' '],/noerase,c_colors=c_colors,charsize=0.7*charsize,xthick=axisthick,$
      ythick=axisthick,thick=linethick,charthick=axisthick
		endif
  contour,aps2_cut,f,z,xrange=frange,xtitle='Frequency [Hz]',xstyle=1,$
	  yrange=zrange,ytitle=ytitle,ystyle=1,$
      title=title,/noerase,fill=fill,charsize=charsize,xthick=axisthick,ythick=axisthick,thick=linethick,$
      nlev=nlev,levels=levels,ticklen=-0.025,charthick=axisthick,$
      position=pos-[0,0,0.1,0],c_colors=c_colors
  if (keyword_set(lcfs)) then begin
    oplot,frange,[lcfs,lcfs],linestyle=2,thick=2*linethick
    xyouts,frange(0)+(frange(1)-frange(0))*0.02,lcfs+0.1,'LCFS',/data,charsize=charsize,charthick=axisthick
  endif
endif

if (keyword_set(surface)) then begin
  surface,(aps2_cut > plotrange[0])<plotrange[1],f,z,xrange=frange,xtitle='Frequency [Hz]',xstyle=1,$
	  yrange=zrange,ytitle=ytitle,ystyle=1,/noerase,ax=ax,az=az,xthick=axisthick,ythick=axisthick,thick=linethick,$
	  charsize=charsize,charthick=axisthick,position=pos-[0,0,0.1,0],zrange=plotrange,zlog=ztype
endif

if (keyword_set(isurface)) then begin
  isurface,(aps2_cut > plotrange[0])<plotrange[1],f,z,xrange=frange,xtitle='Frequency [Hz]',xstyle=1,$
	  yrange=zrange,ytitle=ytitle,ystyle=1,/noerase,ax=ax,az=az,xthick=axisthick,ythick=axisthick,thick=linethick,$
	  charsize=charsize,charthick=axisthick,zrange=plotrange,zlog=ztype
endif

if (keyword_set(shade_surf)) then begin
  shade_surf,(aps2_cut > plotrange[0])<plotrange[1],f,z,xrange=frange,xtitle='Frequency [Hz]',xstyle=1,$
	  yrange=[min(z),max(z)],ytitle=ytitle,ystyle=1,/noerase,ax=ax,az=az,xthick=axisthick,ythick=axisthick,thick=linethick,$
	  charsize=charsize,charthick=axisthick,position=pos-[0,0,0.1,0],zrange=plotrange,zlog=ztype
endif

end
