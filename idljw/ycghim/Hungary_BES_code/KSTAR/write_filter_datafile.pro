pro write_filter_datafile,angles=angles,filename=filename,clickfile=clickfile,wavelength_range=wavelength_range,$
   measurement_angle=measurement_angle, fwhm=fwhm_final,input_filter=input_filter

; Saves the calculated transmission of a filter at different angles
; into a multi-column data file. Takes the input data from either a "clickfile"
; which contains data digitized from a calibration sheet or from a filter data file
; writen with this program. The FWHM of the curve can be modified.
; INPUT:
;   filename: The name of the output file. Use '.dat' for extension
;   clickfile: The input digitized calibration curve. Transmission data ion the flanks will be
;              added from the Andover generic filter curve
;   input_filter: An already existing filter data file
;   angles: The list of angles (degrees) for which the transmission will be calculates
;   wavelength_range: The wavelength range for the calculation when the filter is extended using the
;                     generic transmission curve
;   measurement_angle: The measurement angle for the calibration curve
;   fwhm: The final FWHM of the filter


default,angles,float([0,2,4,6,8,10,12,14,16])
default,wavelength_range,[640.,683.]
default,measurement_angle,0.

if (defined(clickfile)) then begin
  restore,clickfile

  ; Scaling the curve to wawelength and transmission
  dx1 = float(xcal[2]-xcal[0])
  dx2 = float(xcal[3]-xcal[1])
  dy1 = float(ycal[1]-ycal[0])
  dy2 = float(ycal[3]-ycal[2])

  ; Bilinear coeff for w
  ;wcal = float([655,655,668,668])
  wcal = float([656.5,656.5,664.5,664.5])
  mat = fltarr(3,3)
  mat[*,0] = xcal[1:3]-xcal[0]
  mat[*,1] = ycal[1:3]-ycal[0]
  mat[*,2] = (xcal[1:3]-xcal[0])*(ycal[1:3]-ycal[0])
  coeff_w = invert(mat)#(wcal[1:3]-wcal[0])

  ; Bilinear coeff for p
  pcal  = float([0,100,0,100])
  coeff_p = invert(mat)#(pcal[1:3]-pcal[0])

  ; This is the real curve (w: wavelenth, p: transmission
  w = (coeff_w[0]*(xfilt-xcal[0])+coeff_w[1]*(yfilt-ycal[0])+coeff_w[2]*(xfilt-xcal[0])*(yfilt-ycal[0]))+wcal[0]
  p = (coeff_p[0]*(xfilt-xcal[0])+coeff_p[1]*(yfilt-ycal[0])+coeff_p[2]*(xfilt-xcal[0])*(yfilt-ycal[0]))+pcal[0]

  ; Transforming to perpendicular angle
  if (measurement_angle ne 0) then begin
    w = w/sqrt(1-(1/2.05)^2*sin(measurement_angle/180.*!pi)^2)
  endif
endif ; clickfile
if (defined(input_filter)) then begin
  d = loadncol(input_filter,header=2,errormess=e)
  if (e ne '') then return
  w = d[*,0]
  p = d[*,1]
endif

; calculating cwl
maxw = w[(where(p[*,0] eq max(p[*,0])))[0]]
ind = where((w ge maxw-4.) and (w le maxw+4.))
cwl = total(w[ind]*p[ind,0])/total(p[ind,0])

; interpolating to a finer resolution
w_int = findgen(1000)/999.*(max(w)-min(w))+min(w)
p_int = interpol(p,w,w_int)
; Determining FWHM
ind = where(p_int ge max(p_int)/2.)
fwhm = max(w_int[ind]) - min(w_int[ind])

;Rescaling to required fwhm
if (defined(fwhm_final)) then begin
  w1 = (w-cwl)*(fwhm/fwhm_final)+cwl
  p = interpol(p,w,w1)
  fwhm = fwhm_final
endif

if (defined(clickfile)) then begin
  ; Adding values on the flanks from a theoretical plot from the Andover website
  w1l = cwl+[-15*fwhm/2,-5.4*fwhm/2,-3.2*fwhm/2,-2.2*fwhm/2]
  p1l = 100*[1e-5,1e-4,1e-3,1e-2]
  w1r = cwl+[2.2*fwhm/2,3.2*fwhm/2,5.4*fwhm/2,15*fwhm/2]
  p1r = 100*[1e-2,1e-3,1e-4,1e-5]
  ; Using digitized values for >5% and theoretical below
  ind = where(p gt 5.0)
  px = [p1l,p[ind],p1r]
  wx = [w1l,w[ind],w1r]
  ;plot,wx,px,ytype=1,yrange=[5e-4,100],ystyle=1,xrange=cwl+[-30,30],xtype=0,xstyle=1
  w = findgen((wavelength_range[1]-wavelength_range[0])/0.1+1)*0.1+wavelength_range[0]
  ; Interpolating for 0.l nm scale on log vertical scale
  p = exp(interpol(alog(px),wx,w))
endif

d = fltarr(n_elements(w),n_elements(angles)+1)
d[*,0] = w
angle_list = 'wavelength '
for ia=0,n_elements(angles)-1 do begin
   w_scaled = w*sqrt(1-(1/2.05)^2*sin(angles[ia]/180.*!pi)^2)
   d[*,ia+1] = interpol(p,w_scaled,w)
   angle_list = angle_list+' '+string(angles[ia],format='(F4.1)')
endfor

savencol,d,filename,head=['Filter transmission',angle_list]
end
