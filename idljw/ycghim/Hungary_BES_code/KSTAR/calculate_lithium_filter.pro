pro calculate_lithium_filter, ebeam=ebeam, radius=radius, visual=visual, doppler_shift=doppler_shift, filter_transmission = filter_transmission, $
                              trans_doppler=trans_doppler, trans_spectrum=trans_spectrum, w_doppler_i=w_doppler_i, w_doppler_geom=w_doppler, equation=equation, $
                              trans_fix=trans_fix, cwl=cwl_new, bw=bw
!p.font=2
cd, 'D:\KFKI\svn\KSTAR'
default, wavelength, 670.8
default, ebeam, 35
default, radius, 2300.
default, visual, 0
default,temperature,23.
default,angle,0.
default,fixed_wavelength,668.4 ;ArII
;default,fixed_wavelength,667.8 ;ArII
default,refr_index,2.08
default,equation,1
default,image_point,[0.,0.] ; [mm]
; The optics parameters: angular magnification, image distance, divergence
default,m_a, 46./80.  ; magnification at the object distance from the filter image/object
default,d_i,1500. ; The object distance from the first lens [mm]
default,ray_divergence,5.  ; The divergence on the filter
default,mirror_lens_d,150.  ; Distance between mirror centre and first lens
default,first_lens_r,75. ; radius of first lens
default, bw, '1.0'
default,filter,'Andover_'+bw+'nm.dat'
default,cwl_new,669.9

;Beam coordinates, angles measured from M-port center
a=xyztocyl([2100., -20.2, (4.632-45)/180.*!pi], /inv)
b=xyztocyl([2200., -1.0,  (4.267-45)/180.*!pi], /inv)
c=xyztocyl([2300., 19.1,  (3.916-45)/180.*!pi], /inv)
radius=double(radius)
; Calculating Doppler wavelength at the given r/a (image center)
; The observation line intersection with the beam plane

x0=c[0]
y0=c[1]
z0=c[2]

x1=a[0]
y1=a[1]
z1=a[2]
biga=(x1-x0)/(y1-y0)
const_a=1+biga^2
const_b=2*biga*y0-2*x0
const_c=x0^2+biga^2*y0^2-2*x0*biga*y0-biga^2*radius^2
opt_axis_x=(-const_b+sqrt(const_b^2-4*const_a*const_c))/(2*const_a)
opt_axis_y=sqrt(radius^2-opt_axis_x^2)
opt_axis_z=c[2]+(a[2]-c[2])*(opt_axis_x-c[0])/(a[0]-c[0])
opt_axis=[opt_axis_x, -opt_axis_y, opt_axis_z]

mirror_center = double([2732,66.4,-253.])
; unit vector from detector image center to first mirror
n_vect = (opt_axis-mirror_center)/sqrt(total((mirror_center-opt_axis)^2))
; Beam velocity
v_beam = sqrt(2*ebeam*1000.*1.602e-19/(7*1.6726e-27))
; Beam direction
n_beam = (a-c)/sqrt(total((a-c)^2))
; angle between optical axis and beam
angle_beam = acos(abs(total(n_vect*n_beam)))
; Doppler shifted beam emission wavelength for the optical axis
w_doppler = (1.-v_beam*cos(angle_beam)/2.997e8)*wavelength
;print, w_doppler
;print, angle_beam/!pi*180.
doppler_shift=w_doppler-wavelength

ray_divergence_max = float(ray_divergence)
angle = float(angle)
errormess = ''
image_point = float(image_point)
ray_divergence = float(ray_divergence)
angle = float(angle)

d = loadncol(filter,head=2,text=head,errormess=errormess,/silent)
if (errormess ne '') then begin
  print,errormess
  return
endif
txt = strsplit(strcompress(head[1]),' ',/extract)
angles = float(txt[1:n_elements(txt)-1])
w = d[*,0]
n_angle = (size(d))[2]-1
p = d[*,1:n_angle]
maxw = w[(where(p[*,0] eq max(p[*,0])))[0]]
ind = where((w ge maxw-4.) and (w le maxw+4.))
cwl = total(w[ind]*p[ind,0])/total(p[ind,0])
; Shifting to actual CWL

w = w+(cwl_new-cwl)
w = w+(temperature-23.)*0.018
;Interpolating the beam spectrum to the wavelength scale of the filter

; Filter angle for optical axis in radians
angle_filt = angle/180*!pi
trans_fix = 0. ; Transmission at given wavelength
trans = 0. ; Transmission at given wavelength
trans_doppler = 0.  ; Transmission at Doppler shift
trans_spectrum = 0.  ; Transmission of spectrum
filter_transmission = fltarr(n_elements(w))  ; This collects the effective filter transmission
rmax = 10 ; radial integration on filter
amax = 30 ; angular integration on filter
weight = 0 ; collecting the weight factors
  
;  plot,[0,1],[0,1],xrange=[0,rmax*amax],yrange=[-10,10],/nodata
 ; plot,[0,1],[0,1],xrange=[0,rmax*amax],yrange=[659,662],/nodata
 
  for i_int_r=0,rmax-1 do begin
    r = (float(i_int_r)+0.5)/rmax
    for i_int_a=0,amax-1 do begin
      ang = float(i_int_a)/amax*2*!pi
      ; filter is z=0 surface, defining a unit vector [x,y,z] along a light ray
      ray = [sin(r*ray_divergence/180*!pi)*cos(ang),sin(r*ray_divergence/180*!pi)*sin(ang),cos(r*ray_divergence/180*!pi)]
      ; Rotating around x axis by mean angle
      ray = [ray[0],ray[1]*cos(angle_filt)+ray[2]*sin(angle_filt),$
             -ray[1]*sin(angle_filt)+ray[2]*cos(angle_filt)]
      angle_act = abs(asin(sqrt(ray[0]^2+ray[1]^2)))/!pi*180.
      ; plots,i_int_r*amax+i_int_a,angle_act,psym=1,/data
      ; Calculating filter transmission at this angle
      if (keyword_set(equation)) then begin
        w1 = w*sqrt(1-(1/refr_index)^2*sin(angle_act/180.*!pi)^2)
        ind = where(angles eq 0)
        p_act = p[*,ind[0]]
        p_act = interpol(p_act,w1,w)
      endif else begin
        ; interpolating curves
        ind1 = where(angle_act ge angles)
        ind1 = ind1[n_elements(ind1)-1]
        if (ind1 eq n_elements(angles)-1) then begin
          print,'Warning: extrapolating filter angle data.'
          stop
          ind2 = ind1
          ind1 = ind1-1
        endif else begin
          ind2 = ind1+1
        endelse
        p_act = p[*,ind1]+(p[*,ind2]-p[*,ind1])*(angle_act-angles[ind1])/(angles[ind2]-angles[ind1])
      endelse
      ;if (ind1 ne 0) then stop
      ;oplot,w,p_act ; & wait,0.1
      weight = weight+r
      filter_transmission = filter_transmission + p_act*r
      trans_fix = trans_fix+(interpol(double(p_act),double(w),double(fixed_wavelength))*r)>1e-6
      ; Calculating Doppler wavelength for this ray
      ; angular deviation from the optical axis on the object side, radial direction
      ; positive is inward
      o_angle_x = atan(image_point[0]/m_a/d_i) - atan(r*first_lens_r/d_i)*sin(ang)
      ; angular deviation from the optical axis on the object side, vertical direction
      ; positive is up
      o_angle_y = atan(image_point[1]/m_a/d_i) + atan(r*first_lens_r/d_i)*cos(ang)
      ;plots,i_int_r*amax+i_int_a,o_angle_x/!pi*180,psym=1,/data
      ;plots,i_int_r*amax+i_int_a,o_angle_y/!pi*180,psym=2,/data
      ; Rotating the observiation direction for the given detector point
      n_vect_i = [n_vect[0]*cos(o_angle_x)+n_vect[1]*sin(o_angle_x),n_vect[1]*cos(o_angle_x)-n_vect[0]*sin(o_angle_x),n_vect[2]]
      n_vect_i = [n_vect_i[0],n_vect_i[1]*cos(o_angle_y)+n_vect_i[2]*sin(o_angle_y),n_vect_i[2]*cos(o_angle_y)-n_vect_i[1]*sin(o_angle_y)]
      ; angle between beam and observation fo this light ray
      angle_beam_i = acos(abs(total(n_vect_i*n_beam)))
    ;  plots,i_int_r*amax+i_int_a,(angle_beam_i-angle_beam)/!pi*180,psym=2,/data
      ; Doppler shifted beam emission wavelength for this light ray
      w_doppler_i = (1.-v_beam*cos(angle_beam_i)/2.997e8)*wavelength
 ;     plots,i_int_r*amax+i_int_a,w_doppler_i,psym=1,/data
      ; Transmission of Doppler shifted light weighted with light ray area (r)
      trans_doppler = trans_doppler+(interpol(p_act,w,w_doppler_i)*r) > 1e-6
      ;Shifting spectrum wavelength by Doppler differerence from optical axis
      w_spect_i = w+(w_doppler_i-w_doppler)
    endfor
  endfor
  trans = trans/weight
  trans_doppler = trans_doppler/weight
  trans_spectrum = trans_spectrum/weight
  filter_transmission = filter_transmission/weight
  trans_fix=trans_fix/weight

if keyword_set(visual) then begin
  
  
  ;trial tokamak for visualisation
  R1 = 1.3*1000
  R2 = 2.3*1000
  ;R2 = 1976.
  spat_xyz_4plot_double = dblarr(3,667)
  a1 = (double(findgen(100)))/99.*2*R1-R1
  a2 = (double(findgen(100)))/99.*2*R2-R2
  b1 = sqrt(R1^2 - a1^2)
  b2 = sqrt(R2^2 - a2^2)
  spat_xyz_4plot_double[0,67:166] = a1
  spat_xyz_4plot_double[1,67:166] = b1
  spat_xyz_4plot_double[0,167:266] = a2
  spat_xyz_4plot_double[1,167:266] = b2
  b1 = -sqrt(R1^2 - a1^2)
  b2 = -sqrt(R2^2 - a2^2)
  spat_xyz_4plot_double[0,267:366] = a1
  spat_xyz_4plot_double[1,267:366] = b1
  spat_xyz_4plot_double[0,467:566] = a2
  spat_xyz_4plot_double[1,467:566] = b2
  
      ;trial beam line for visualisation
  a_angle = -acos((1800.^2+mirror_center[0]^2-2317.^2)/(2.*mirror_center[0]*1800.))
  a_point_cyl = double([1800,3,a_angle])
  a_point_xyz = xyztocyl(a_point_cyl,/inv)
  
  b_angle = -acos((2250.^2+mirror_center[0]^2-1852.^2)/(2.*mirror_center[0]*2250.))
  b_point_cyl = double([2250,3,b_angle])
  b_point_xyz = xyztocyl(b_point_cyl,/inv)
  
  a3 = double(findgen(100)*8.176272+687.28500)
  x1 = a_point_xyz[0]
  x2 = b_point_xyz[0]
  y1 = a_point_xyz[1]
  y2 = b_point_xyz[1]
  b3 = (a3-x1)/(x2-x1)*(y2-y1)+y1
  spat_xyz_4plot_double[0,567:666] = a3
  spat_xyz_4plot_double[1,567:666] = b3
  device, decomposed=0
  loadct, 5
  erase
  plot,spat_xyz_4plot_double[0,67:666],spat_xyz_4plot_double[1,67:666], /isotrop,$
           /noerase, xrange=[-2400,2400],yrange=[-2400,2400], thick=3, charsize=2, xtitle='x [mm]', ytitle='y [mm]', title='Lithium beam geometry'
  oplot, [a[0], c[0]],[a[1], c[1]], color=240
  plots, opt_axis, psym=4, color=100
  plots, mirror_center, psym=4, color=200
endif
  end