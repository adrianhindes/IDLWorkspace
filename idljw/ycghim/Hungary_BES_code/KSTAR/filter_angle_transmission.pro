pro filter_angle_transmission,shot,click=click,ebeam = ebeam,ray_divergence=ray_divergence,$
    transmission=trans,temperature=temperature,noplo=noplot,thick=thick,charsize=charsize,symsyze=symsize,$
    offset=offset,fixed_wavelength=fixed_wavelength,yrange=yrange,title=title
   
;******************************************************************************
;* KSTAR_FILTER_TRANSMISSION.PRO          S. Zoletnik  29.02.2012             *
;******************************************************************************
; Calculate the transmission of the filter in the KSTAR BES system for all    *
;* channels.                                                                  *
;* INPUT:                                                                     *
;*   shot: Shot number                                                        *
;*   ebeam: Beam energy [keV]                                                 *
;*   ray_divergence: The maximum divergence of light rays from one channel    *
;*                   relative to the central ray [deg]                        *
;*   temperature: Filter temperature in C.                                    *
;*   offset: Offset of the measurement locations in R and Z in mm.            *
;*   fixed_wavelength: Calculate transmission at this wavelength instead of   *
;*         the Doppler shiftes D_alpha                                        *
;* OUTPUT:                                                                    *
;*   transmission: A 4x8 matrix with the precentage transmission of channels  *
;******************************************************************************

default,ray_divergence,2.
default,temperature,23.
default,offset,[0,0]

ray_divergence = float(ray_divergence)

if (keyword_set(click)) then begin
  ; Digitizing the tranmission curve of the filter by clikcing on the plot.
  read_jpeg,'..\BES\Trial_BES\Installation\calibration_data\Photos\P7310280.JPG',im
  im = float(total(im,1))
  xs = (size(im))[0]
  ys = (size(im))[1]
  plot,[0,xs-1],[0,ys-1],/nodata,xstyle=1,ystyle=1
  otv,(im-min(im))/(max(im)-min(im))*255
  print,'Click on (655,0), (655,100), (668,0) and (668,100) points.'
  digxyadd,xcal,ycal,/data
  if (n_elements(xcal) lt 4) then return
  print, 'Click on a series of points on the curve. Click with right button to stop.'
  digxyadd,xfilt,yfilt,/data
  if (n_elements(xfilt) lt 5) then return
  save,xcal,ycal,xfilt,yfilt,file='KSTAR_filter.sav'
endif else begin
  restore,'KSTAR_filter.sav'
endelse

; Scaling the curve to wawelength and transmission
dx1 = float(xcal[2]-xcal[0])
dx2 = float(xcal[3]-xcal[1])
dy1 = float(ycal[1]-ycal[0])
dy2 = float(ycal[3]-ycal[2])

; Bilinear coeff for w
wcal = float([655,655,668,668])
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

; Adding values on the flanks from a theoretical plot from the Andover website
cwl = 661.99
fwhm = 2.86
w1l = cwl+[-15*fwhm/2,-5.4*fwhm/2,-3.2*fwhm/2,-2.2*fwhm/2]
p1l = 100*[1e-5,1e-4,1e-3,1e-2]
w1r = cwl+[2.2*fwhm/2,3.2*fwhm/2,5.4*fwhm/2,15*fwhm/2]
p1r = 100*[1e-2,1e-3,1e-4,1e-5]
; Using digitized values for >5% and theretical below
ind = where(p gt 5.0)
px = [p1l,p[ind],p1r]
wx = [w1l,w[ind],w1r]
;plot,wx,px,ytype=1,yrange=[5e-4,100],ystyle=1,xrange=cwl+[-30,30],xtype=0,xstyle=1
w = findgen(430)*0.1+640.
; Interpolating for 0.l nm scale on log vertical scale
p = exp(interpol(alog(px),wx,w))
;oplot,w,p,psym=1


w = w+(temperature-23.)*0.018
cal = getcal_kstar_spat(shot,/detcorn)
cal[*,*,*,0] = cal[*,*,*,0]+offset[0]
cal[*,*,*,1] = cal[*,*,*,1]+offset[1]

cal = total(cal,3)/4
; optical axis position in the detector array
opt_axis = (reform(cal[1,3,*])+reform(cal[2,3,*])+reform(cal[2,4,*])+reform(cal[1,4,*]))/4
opt_axis = xyztocyl(opt_axis,/inv)
mirror_center = double([2833,-250,0])
mirror_center = xyztocyl(mirror_center,/inv)
; Distance between detector center and first lens
d = sqrt(total((opt_axis-mirror_center)^2))+275
; unit vector from detector center to first mirror
n_vect = (mirror_center-opt_axis)/sqrt(total((mirror_center-opt_axis)^2))
; first lens position mirrored in first mirror
first_lens = mirror_center + n_vect*275
v_beam = sqrt(2*ebeam*1000.*1.6e-19/(2*1.6e-27))
trans = fltarr(4,8)
for i=0,3 do begin
  for j=0,7 do begin
    detpos = xyztocyl(reform(cal[i,j,*]),/inv)
    ;angle between this detector and optical axis
    angle = acos(abs(total((detpos-first_lens)*n_vect)/sqrt(total((detpos-first_lens)^2))))
    ; angle of this detector's light on filter
    angle_filt = angle*5.09
    ; normal vector along beam
    n_beam = [-1.,0.,0.]
    ; angle between observation and beam
    angle_beam = acos(abs(total((detpos-first_lens)*n_beam)/sqrt(total((detpos-first_lens)^2))))
    ; Doppler shifted beam emission wavelength for this channel
    w_doppler = (1.+v_beam*cos(angle_beam)/3e8)*656.1
    ; Integrating through the light cone
    ; radial cycle
    rmax = 10
    amax = 30
    weight = 0
    ;print,angle_filt
    ;plot,[0,1],[0,1],/nodata,xrange=[0,rmax*amax],xstyle=1,yrange=[0,angle_filt+ray_divergence/180*!Pi]/!pi*180,ystyle=1
    for i_int_r=0,rmax-1 do begin
      ; angular cycle
      r = (float(i_int_r)+0.5)/rmax
      for i_int_a=0,amax-1 do begin
        ang = float(i_int_a)/amax*2*!pi
        ; filter is z=0 surface, defining a unit vector [x,y,z] along a light ray
        ray = [sin(r*ray_divergence/180*!pi)*cos(ang),sin(r*ray_divergence/180*!pi)*sin(ang),cos(r*ray_divergence/180*!pi)]
        ; Rotating around x axis by angle_beam
        ray = [ray[0],ray[1]*cos(angle_filt)+ray[2]*sin(angle_filt),-ray[1]*sin(angle_filt)+ray[2]*cos(angle_filt)]
        angle_act = abs(asin(sqrt(ray[0]^2+ray[1]^2)))
        ;plots,i_int_r*amax+i_int_a,angle_act/!pi*180,psym=1
        ;wait,0.01
        w_scaled = w*sqrt(1-(1/2.05)^2*sin(angle_act)^2)
        weight = weight+r
        if (keyword_set(fixed_wavelength)) then begin
          trans[i,j] = trans[i,j]+interpol(p,w_scaled,fixed_wavelength)*r
        endif else begin
          trans[i,j] = trans[i,j]+interpol(p,w_scaled,w_doppler)*r
        endelse
      endfor
    endfor
    trans[i,j] = trans[i,j]/weight
  endfor
endfor

if (not keyword_set(noplot)) then begin
  default,title,'Divergence: '+string(ray_divergence,format='(F3.1)')+'[deg],  T='+string(temperature,format='(F4.1)')+'[C]'
  default,yrange,[0,90]
  plot,[0,1],[0,1],xrange=[0,9],xstyle=1,xtitle='Channel in row',yrange=yrange,ystyle=1,ytitle='Transmission [%]',$
    thick=thick,xthick=thick,ythick=thick,charthick=thick,charsize=charsize,title=title,/nodata
  for i=0,3 do begin
    plotsymbol,i
    oplot,findgen(8)+1,trans[i,*],thick=thick,symsize=symsize,psym=-8
  endfor
endif

end