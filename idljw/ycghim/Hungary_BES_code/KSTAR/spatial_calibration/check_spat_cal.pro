pro check_spat_cal, plot=plot, time=time, shot=shot, lithium=lithium, ps=ps, zoom=zoom

default, shot, 9212
default, time, 5.25
default, isotropic, 1
default, nlevels, 100
if not keyword_set(zoom) then begin
  default, rrange, [1.2,2.4]
  default, zrange, [-1.1,1.1]
endif else begin
  ;default, rrange, [2.1525,2.325]
  ;default, zrange, [-0.272500,0.0725000]
  default, rrange, [2.1525,2.325]
  default, zrange, [-0.122500,0.2225000]
  
endelse
default, lithium, 0
default, ps, 0
!p.font=2
if keyword_set(ps) then hardon, /color

if keyword_set(lithium) then restore, '2013_calibration_a9110_Li.sav' else restore, '2013_calibration_a9110_Da.sav'
rpos=66000
zpos=10000

rad_ind=where(data.rad_pos eq rpos)
vert_ind=where(data.rad_pos eq zpos)
if rad_ind[0] eq -1 then begin
  print, 'The radial coordinate is not in the database!'
  return
endif
if vert_ind[0] eq -1 then begin
  print, 'The vertical coordinate is not in the database!'
  return
endif

det_pos=reform(data.spat_cord[vert_ind,rad_ind,*,*,*])

device, decomposed=0


flux = get_kstar_efit(shot,time,errormess=errormess,/silent)
if (errormess ne '') then begin
  if (not keyword_set(silent)) then print,errormess
  return
endif
if (not keyword_set(noerase) and not keyword_set(over)) then erase
if (not keyword_set(nolegend) and not keyword_set(over)) then time_legend,'show_ecei_bes_correlation_map.pro'
if (not keyword_set(over)) then begin
  contour,flux.psi,flux.r,flux.z,xrange=rrange,xstyle=1,xtitle='R [m]',nlevels=nlevels,$
          yrange=zrange,ystyle=1,ytitle='Z [m]',isotropic=isotropic,thick=thick,xthick=thick,$
          ythick=thick,charthick=thick,charsize=charsize,/noerase,title=i2str(shot)+'  '+string(time,format='(F5.2)')+'s',/nodata

endif


loadct, 5
contour,flux.psi,flux.r,flux.z,nlevels=nlevels,thick=thick,/noerase,/over
for i=0,3 do begin
  for j=0,7 do begin
    color=120
    plots, det_pos[i,j,0]/1e3,det_pos[i,j,1]/1e3, psym=4, color=color
  endfor
endfor
if keyword_set(ps) then begin
  if keyword_set(zoom) then str='_zoom' else str=''
  if keyword_set(lithium) then hardfile, '2d-3dtransform_Li'+str+'.ps' else hardfile, '2d-3dtransform_Da'+str+'.ps'
endif
end