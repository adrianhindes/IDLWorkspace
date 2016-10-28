pro trasmission_vs_angle,fixed_wavelength=fixed_wavelength,thick=thick,charsize=charsize,over=over

default,fixed_wavelength,656.1
cwl = 660.8
filter = 'Andover_2.0nm.dat'
angle_range = [0,12.] ; deg
angle_n = 20
thick=2
charsize=2
!p.font=1

angles = fltarr(angle_n)
background = fltarr(angle_n)


for i=0,angle_n-1 do begin
  angles[i] = (angle_range[1]-angle_range[0])/(angle_n-1)*i+angle_range[0]
  object_point_transmission,ebeam=ebeam,rho=0.9,filter_angle=angles[i],fixed_wavelength=fixed_wavelength,cwl=cwl,filter_name=filter,$
  trans_fixed=trans_fixed_1,trans_doppler=trans_doppler_1,trans_spectrum=trans_spectrum_1,errormess=errormess,$
  ref_index=refr_index,rel_point=[0.,0.]

  background[i] = trans_fixed_1
endfor


if (not keyword_set(over)) then begin
  plot,angles,background,xtitle='Filter angle [deg]',ytitle='Transmission at '+strtrim(fixed_wavelength,2)+' nm',$
    thick=thick,charsize=charsize,xthick=thick,ythick=thick,charthick=thick, /ylog, yrange=[0.001, 100]
endif else begin
  oplot,angles,background,thick=thick
endelse
end