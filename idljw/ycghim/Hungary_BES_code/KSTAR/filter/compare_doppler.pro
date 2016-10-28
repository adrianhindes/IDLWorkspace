pro compare_doppler,ebeam=ebeam,thick=thick,charsize=charsize,yrange=yrange

default,ebeam,100.

rho_list = [0,0.2,0.4,0.6,0.8,1.]

doppler_list = fltarr(n_elements(rho_list))
spectrum_mean = fltarr(n_elements(rho_list))

for i=0,n_elements(rho_list)-1 do begin
   filter_divergence_transmission,ebeam=ebeam,rho=rho_list[i],ray_divergence=0.,n_divergence=1,$
   /noplot,errormess=errormess,spectrum_data=spectrum_data,spectrum_w=spectrum_w,doppler_wavelength=w_doppler
   if (errormess ne '') then return
   doppler_list[i] = w_doppler
   spectrum_mean[i] = total(spectrum_w*spectrum_data)/total(spectrum_data)
 endfor

stop
 plotsymbol,0
 if (not defined(yrange)) then begin
   yrange = [min([doppler_list,spectrum_mean]),max([doppler_list,spectrum_mean])]
   yrange = yrange+[-0.05,0.05]*(yrange[1]-yrange[0])
 endif
 plot,rho_list,doppler_list,yrange=yrange,ystyle=1,$
   psym=8,xtitle='r/a',ytitle='BES wavelength [nm]',xrange=[-0.05,1.15],xstyle=1,$
   title='Doppler shifts (circe: calculated, square: spectrum)  E!Dbeam!N='+i2str(ebeam)+'[keV]',$
   thick=thick,xthick=thick,ythick=thick,charthick=thick,charsize=charsize
 plotsymbol,1
 oplot,  rho_list,spectrum_mean,psym=8,thick=thick

for i=0,n_elements(rho_list)-1 do begin
   filter_divergence_transmission,ebeam=ebeam,rho=rho_list[i],ray_divergence=0.,n_divergence=1,$
   /noplot,errormess=errormess,spectrum_data=spectrum_data,spectrum_w=spectrum_w,doppler_wavelength=w_doppler
   if (errormess ne '') then return
   oplot,spectrum_data/max(spectrum_data)*0.1+rho_list[i],spectrum_w,thick=thick
   oplot,[rho_list[i],rho_list[i]],yrange,linest=1,thick=thick
 endfor

end