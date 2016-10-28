pro model_lambda_broadening


n_e = findgen(100,start = 1)*1E18
temp = findgen(100,start = 1)/100.

starkBroadened = fltarr(7)

dopplerBroadened = doppler_broadening_lambda(temp)
starkBroadened = stark_broadening_lambda(n_e)

title= 'Doppler Broadening of Linewidth'
p = plot(temp,dopplerBroadened,xtitle='Temperature (eV)',ytitle='FWHM $\Delta \lambda$ (nm)' $
  ,title = title)

title= 'Stark Broadening of Linewidth'
p = plot(n_e,starkBroadened,xtitle='Electron density $(m^{-3})$',ytitle='FWHM $\Delta \lambda$ (nm)' $
    ,title = title)

stop

  end