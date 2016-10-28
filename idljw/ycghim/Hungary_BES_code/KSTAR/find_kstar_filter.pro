pro find_kstar_filter,filter=filter,double_filter=double_filter,fixed1=fixed1,limit1=limit1,$
  fixed2=fixed2,limit2=limit2,trans_limit=trans_limit,angle=angle,divergence_max=divergence_max,$
  thick=thick,charsize=charsize,rhos=rhos,ebeam=ebeam

; This program calucalates the area in the filter CWL-divergence plane where the SBR limits
; for two wavelengths (CII line and unshifted D alpha) and the transmission limit is fulfilled.

default,filter,'Materion_3nm_1.95.dat'
ebeam = 100 ; keV
default,angle,0
default,divergence_max,5.
;radii = [1.85,2.0,2.1,2.2,2.3]
;radii = [1.8,1.9]
default,rhos,[0.2,0.4,0.6,0.8,0.9]
default,fixed1,658.3
default,limit1,500
default,fixed2,656.3
default,limit2,5000
default,trans_limit,80

radii = fltarr(n_elements(rhos))

for i=0,n_elements(rhos)-1 do begin
   optimize_kstar_filter,n_divergence=n_divergence,divergence_max=divergence_max,cwl_range=cwl_range,$
     ebeam=ebeam,radius=radius,angle=angle,temperature=temperature,$
     fixed_wavelength=fixed1,filter=filter,$
     trans_doppler=trans_doppler,trans_spectrum=trans_spectrum,trans_fixed=trans_fixed,cwls=cwls,divergences=divergences,$
     rho=rhos[i],ratio_range=[0,limit1],errormess=errormess
   if (errormess ne '') then return
   if (i eq 0) then begin
     result = trans_doppler
     result[*,*] = 1
     result_spectrum = trans_spectrum
     result_spectrum[*,*] = 1
   endif
   radii[i] = radius
   mask = where((trans_doppler lt trans_limit) or (trans_doppler/trans_fixed lt limit1))
   if (mask[0] ge 0) then result[mask] = 0
   mask = where((trans_spectrum lt trans_limit) or (trans_spectrum/trans_fixed lt limit1))
   if (mask[0] ge 0) then result_spectrum[mask] = 0

   optimize_kstar_filter,n_divergence=n_divergence,divergence_max=divergence_max,cwl_range=cwl_range,$
     ebeam=ebeam,angle=angle,temperature=temperature,$
     fixed_wavelength=fixed2,filter=filter,$
     trans_doppler=trans_doppler,trans_spectrum=trans_spectrum,trans_fixed=trans_fixed,cwls=cwls,divergences=divergences,$
     rho=rhos[i],ratio_range=[0,limit2],errormess=errormess
   if (errormess ne '') then return
   mask = where((trans_doppler lt trans_limit) or (trans_doppler/trans_fixed lt limit2))
   if (mask[0] ge 0) then result[mask] = 0
   mask = where((trans_spectrum lt trans_limit) or (trans_spectrum/trans_fixed lt limit2))
   if (mask[0] ge 0) then result_spectrum[mask] = 0
endfor

erase
time_legend,'find_kstar_filter.pro'
contour,result,cwls,divergences,levels=[0.99],xstyle=1,ystyle=1,xtitle='CWL [nm]',$
  ytitle='Divergence [deg]',pos=[0.1,0.5,0.4,0.8],xthick=thick,ythick=thick,charthick=thick,thick=thick,$
  charsize=charsize,/noerase,title='Filter parameter range (Doppler)'

contour,result_spectrum,cwls,divergences,levels=[0.99],xstyle=1,ystyle=1,xtitle='CWL [nm]',$
  ytitle='Divergence [deg]',pos=[0.6,0.5,0.9,0.8],xthick=thick,ythick=thick,charthick=thick,thick=thick,$
  charsize=charsize,/noerase,title='Filter parameter range (Spectrum)'


title = 'R = '+i2str(min(radii)*1000)+'-'+i2str(max(radii)*1000)+'[mm]'+$
        '!Cr/a='+string(min(rhos),format='(F4.2)')+'-'+string(max(rhos),format='(F4.2)')
title = title+'!CFilter: '+filter
title = title+'!CT: '+string(temperature,format='(F4.1)')+'[C]'
title = title+'!CFilter angle: '+string(angle,format='(F3.1)')+'[deg]'
title = title+'!CE!Dbeam!N='+i2str(ebeam)+' [keV]'
title = title+'!C!C SBR limit ('+string(fixed1,format='(F5.1)')+'nm):'+i2str(limit1)
title = title+'!C SBR limit ('+string(fixed2,format='(F5.1)')+'nm):'+i2str(limit2)
title = title+'!C BES Transmission limit: '+i2str(trans_limit)+'%'

xyouts,0.65,0.25,title,charthick=thick ,/normal



end