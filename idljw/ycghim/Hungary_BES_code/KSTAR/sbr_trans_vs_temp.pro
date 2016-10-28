pro sbr_trans_vs_temp,ebeam=ebeam,radius=radius,rho=rho,ray_divergence=ray_divergence,$
   filter_angle=angle,temp_range=temp_range,temp_res=temp_res,$
   cwl=cwl,filter_name=filter,$
   ref_index=refr_index,thick=thick,charsize=charsize


; Plot SBR and transmission of BES spectrum as a function of filter temperature

default,temp_range,[23,60]
default,temp_res,2.
default,angle,0.
default,ebeam,90.
default,filter,'Andover_2.0nm.dat'
default,refr_index,2.05
; The optics parameters: angular magnification, image distance, divergence
default,ray_divergence,5.  ; The divergence on the filter
default,rho,0.9
default,CWL,660.84

n_temp = (temp_range[1]-temp_range[0])/temp_res
trans_spectrum = fltarr(n_temp)
trans_fixed_658 = fltarr(n_temp)
trans_fixed_656 = fltarr(n_temp)
temperature = fltarr(n_temp)
for i=0,n_temp-1 do begin
  act_temp = temp_range[0]+i*temp_res
  delete,radius
  fixed_wavelength = 658.3
  object_point_transmission,ebeam=ebeam,radius=radius,rho=rho,ray_divergence=ray_divergence,$
  filter_angle=angle,temperature=act_temp,$
  fixed_wavelength=fixed_wavelength,cwl=cwl,filter_name=filter,$
  trans_fixed=trans_fixed_1,trans_doppler=trans_doppler_1,trans_spectrum=trans_spectrum_1,errormess=errormess,$
  ref_index=refr_index,rel_point=[0.,0.]
  if (errormess ne '') then begin
    print,errormess
    return
  endif
  trans_spectrum[i] = trans_spectrum_1
  trans_fixed_658[i] = trans_fixed_1
  temperature[i] = act_temp
  fixed_wavelength = 656.3
  delete,radius
  object_point_transmission,ebeam=ebeam,radius=radius,rho=rho,ray_divergence=ray_divergence,$
  filter_angle=angle,temperature=act_temp,$
  fixed_wavelength=fixed_wavelength,cwl=cwl,filter_name=filter,$
  trans_fixed=trans_fixed_1,trans_doppler=trans_doppler_1,trans_spectrum=trans_spectrum_1,errormess=errormess,$
  ref_index=refr_index,rel_point=[0.,0.]
  if (errormess ne '') then begin
    print,errormess
    return
  endif
  trans_fixed_656[i] = trans_fixed_1
end

erase
time_legend,'sbr_trans_vs_temp.pro'
plot,temperature,trans_spectrum/trans_fixed_658,xtitle='Filter temperature',xstyle=1,$
  ytitle = 'SBR',yrange=[0,max(trans_spectrum/trans_fixed_658)*1.05],ystyle=1,$
  title='Spectrum to '+string(658.3,format='(F5.1)')+'nm',/noerase,$
  thick=thick,xthick=thick,ythick=thick,charthick=thick,charsize=charsize,pos=[0.15,0.6,0.45,0.9]

plot,temperature,trans_spectrum/trans_fixed_656,xtitle='Filter temperature',xstyle=1,$
  ytitle = 'SBR',yrange=[0,max(trans_spectrum/trans_fixed_656)*1.05],ystyle=1,$
  title='Spectrum to '+string(656.3,format='(F5.1)')+'nm',/noerase,$
  thick=thick,xthick=thick,ythick=thick,charthick=thick,charsize=charsize,pos=[0.6,0.6,0.9,0.9]

plot,temperature,trans_spectrum,xtitle='Filter temperature',xstyle=1,$
  ytitle = 'Transmission [%]',yrange=[0,105],ystyle=1,$
  title='Transmission of BES spectrum',/noerase,$
  thick=thick,xthick=thick,ythick=thick,charthick=thick,charsize=charsize,pos=[0.15,0.1,0.45,0.4]


  title = 'R = '+i2str(radius*1000)+'[mm] (r/a='+string(rho,format='(F4.2)')+')
  title = title+'!CFilter: '+filter
  title = title+'!CCWL: '+string(cwl,format='(F6.2)')+' [nm]'
  title = title+'!CDivergence: '+i2str(ray_divergence)
  title = title+'!CFilter angle: '+string(angle,format='(F3.1)')+'[deg]'
  title = title+'!CE!Dbeam!N='+i2str(ebeam)+' [keV]'
  xyouts,0.65,0.35,title,charthick=thick,charsize=charsize ,/normal

end
