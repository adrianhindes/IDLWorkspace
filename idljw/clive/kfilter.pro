function filter_shift, lambda, angle

default, n, 2.05  ; refractive index

; angle is in degrees
return, lambda*(1-1/n*sin(angle*!dtor)^2)^0.5

end

pro kstar_mse_filter

device,decomp=0
tek_color

angle=range(-5.5,1.5,.01)        ; this accounts for the angle span produced by lens and CCD size + the filter tilt offset of 2 degrees
plot,angle,filter_shift(661.1,angle),/ynoz,yr=[658.5,662.5],/yst,/xst,/nodata,$
  xtitl='Angle (degrees)', ytitl='Wavelength (nm)',font=1,chars=2
oplot,angle,filter_shift(661.1,angle),col=2   ; FILTER CENTRE
oplot,angle,filter_shift(662.1,angle),col=7    ; THE FILTER EDGE
oplot,angle,filter_shift(660.1,angle),col=7
oplot,angle,(angle-min(angle))/(max(angle)-min(angle))+660  ; the wavelength span for KSTAR MSE

stop
end
