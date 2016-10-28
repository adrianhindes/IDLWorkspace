pro object_point_transmission,ebeam=ebeam,radius=radius,rho=rho,ray_divergence=ray_divergence,$
   filter_angle=angle,temperature=temperature,$
   fixed_wavelength=fixed_wavelength,cwl=cwl_new,filter_name=filter,$
   trans_fixed=trans,trans_doppler=trans_doppler,trans_spectrum=trans_spectrum,errormess=errormess,$
   transmission_filter=filter_transmission,wavelength=w,full_beam=full_beam,spectrum_data=spectrum_data,$
   spectrum_w=spectrum_w,doppler_wavelength=w_doppler,$
   equation=equation,ref_index=refr_index,rel_point=rel_point, lithium=lithium

;******************************************************************************
;* OBJECT_POINT_TRANSMISSION.PRO               S. Zoletnik  28.07.2012        *
;******************************************************************************
;* Calculate the transmission of the filter in the final KSTAR BES system     *
;* for a given point in the plasma. The optical axis is assumed to look at    *
;* rho (r/a) minor radius and the point is given relative to this in          *
;* rel_point.                                                                 *
;* Transmission at a given wavelength, at the Doppler shifted D_alpha and     *
;* using a calculated BES spectrum are calculated.                            *
;* Takes into account the change of the Doppler shift for rays passing at     *
;* different points through the first lens and that each ray passes the filter*
;* at different angle                                                         *
;* Can use various filter data specified by <filter>                          *
;* INPUT:                                                                     *
;*   ebeam: Beam energy [keV]                                                 *
;*   radius: Major radius in tokamak [m]                                      *
;*   rho: r/a. (This is alternative to radius, this is the preferred one)     *
;*   ray_divergence: The max divergence of light rays on the filter           *
;*                   relative to the central ray [deg]                        *
;*   filter_angle: The mean angle of incidence on the filter                  *
;*   temperature: Filter temperature in C.                                    *
;*                (The filter transmission in the data file is assumed ot be  *
;*                  at 23 C)                                                  *
;*   fixed_wavelength: Calculate transmission at this wavelength instead of   *
;*         the Doppler shifted D_alpha                                        *
;*   cwl: Central wavelength of filter. The transmission from the file will   *
;*                         be shifted to this CWL                             *
;*   filter: A file name containing filter transmission as a function of      *
;*           wavelength and angle. First line is description, second line is  *
;*           'wavelength a1 a2 a3 a4', where a1, a2... are the angles in deg  *
;*   /full_beam: use full beam BES emission for calculation                   *
;*                (otherwise use full energy component only)                  *
;*   rel_point: The [x,y] coordinates of the modeled point in the object      *
;*                plane. x is along the beam (increasing inside) and y is     *
;*                accross. [mm]                                               *
;*   /equation: Use equation from Andover website for angle shift             *
;*    refr_index: Refrective index for angle sensitivity                      *
;*    /lithium: Ese the calculation for Lithium beam
;*  OUTPUT:                                                                   *
;*   trans_fixed: Transmission at fixed wavelength vs. divergences            *
;*   trans_doppler: Transmission at Doppler shift vs divergence               *
;*   trans_spectrum: Transmission of spectrum vs. divergence                  *
;*   transmission_filter: The transmision of the filter with divergence       *
;*   wavelength: The wavelength scale for the filter transmission             *
;*   rho: The calculated r/a value at this radius                             *
;*   radius: The major R for the rho                                          *
;*   spectrum_data: The intensity data for the calculated BES spectrum        *
;*   spectrum_w: The wavelength data for the spectrum                         *
;*   doppler_wavelength: The calculated Doppler shifted full energy wavelength*
;******************************************************************************

default,temperature,23.
default,angle,0.
default,ebeam,100.
default,filter,'KSTAR_filter_2.0nm.dat'
default,fixed_wavelength,658.3
default,refr_index,2.05
default,equation,1
default,rel_point,[0.,0.] ; [mm]
; The optics parameters: angular magnification, image distance, divergence
default,d_i,1500. ; The object distance from the first lens [mm]
default,ray_divergence,5.  ; The divergence on the filter
default,mirror_lens_d,150.  ; Distance between mirror centre and first lens
default,first_lens_r,75. ; radius of first lens


errormess = ''
rel_point = float(rel_point)
ray_divergence = float(ray_divergence)
angle = float(angle)

if (defined(rho) and defined(radius)) then begin
  errormess = 'Set only one of rho and radius.'
  print,errormess
  return
endif
if (not defined(rho) and not defined(radius)) then begin
  errormess = 'Set either rho or radius.'
  print,errormess
  return
endif

ray_divergence_max = float(ray_divergence)
angle = float(angle)

rho_list = loadncol('Spectra\KSTAR_rho.dat',1,/silent,errormess=errormess)
if (errormess ne '') then begin
  print,errormess
  return
endif
R_list = loadncol('Spectra\KSTAR_R.dat',1,/silent,errormess=errormess)
if (errormess ne '') then begin
  print,errormess
  return
endif
if (defined(radius)) then begin
  rho = interpol(rho_list,R_list,radius*1000)
endif else begin
  radius = interpol(R_list,rho_list,rho)/1000.
endelse
spectrum_file = 'Spectra\D-Spectra\MSE_output_KStar_D_'+i2str(ebeam)+'keV_rho'+string(float(round(rho*10))/10,format='(F3.1)')+'.m'
;print,'Reading '+spectrum_file
d=loadncol(spectrum_file,8,head=2,errormess=errormess,/silent)
if (errormess ne '') then begin
  print,errormess
  return
endif
if (keyword_set(full_beam)) then begin
  spectrum_data = d[*,1]
endif else begin
  spectrum_data = d[*,3]
endelse
spectrum_e2 = d[*,4]
spectrum_e3 = d[*,5]
spectrum_w = d[*,0]/10.

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
default,cwl_new,cwl
w = w+(cwl_new-cwl)
w = w+(temperature-23.)*0.018  ; From Andover website

;Interpolating the beam spectrum to the wavelength scale of the filter
beam_spectrum = interpol(spectrum_data,spectrum_w,w)
;
; Calculating Doppler wavelength at the given r/a (image center)
; The toroidal angle for the given R
phi = asin(1.486/radius)
; The observation line intersection with the beam plane
;opt_axis = [radius*1000,0,phi]
opt_axis = double([cos(phi)*radius*1000,-1486.,0])
;opt_axis = xyztocyl(opt_axis,/inv)
;mirror_center = double([2833,-250,0])
mirror_center = double([2732,66.4,-253.])
;mirror_center = xyztocyl(mirror_center,/inv)
; Distance between observation point and first lens
d_obj_lens = sqrt(total((opt_axis-mirror_center)^2))+mirror_lens_d
; unit vector from detector image center to first mirror
n_vect = (mirror_center-opt_axis)/sqrt(total((mirror_center-opt_axis)^2))
; first lens position mirrored in first mirror
first_lens = mirror_center + n_vect*mirror_lens_d
; Beam velocity
v_beam = sqrt(2*ebeam*1000.*1.602e-19/(2*1.6726e-27))
; Beam direction
n_beam = [-1.,0.,0.]
; angle between optical axis and beam
angle_beam = acos(abs(total(n_vect*n_beam)))
; Doppler shifted beam emission wavelength for the optical axis
w_doppler = (1.+v_beam*cos(angle_beam)/2.997e8)*656.3

; Filter angle in radians
angle_filt = angle/180*!pi
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
      trans = trans+(interpol(double(p_act),double(w),double(fixed_wavelength))*r)>1e-6
      ; Calculating Doppler wavelength for this ray
      ; angular deviation from the optical axis on the object side, radial direction
      ; positive is inward
      o_angle_x = atan(rel_point[0]/d_i) - atan(r*first_lens_r/d_i)*sin(ang)
      ; angular deviation from the optical axis on the object side, vertical direction
      ; positive is up
      o_angle_y = atan(rel_point[1]/d_i) + atan(r*first_lens_r/d_i)*cos(ang)
      ;plots,i_int_r*amax+i_int_a,o_angle_x/!pi*180,psym=1,/data
      ;plots,i_int_r*amax+i_int_a,o_angle_y/!pi*180,psym=2,/data
      ; Rotating the observiation direction for the given detector point
      n_vect_i = [n_vect[0]*cos(o_angle_x)+n_vect[1]*sin(o_angle_x),n_vect[1]*cos(o_angle_x)-n_vect[0]*sin(o_angle_x),n_vect[2]]
      n_vect_i = [n_vect_i[0],n_vect_i[1]*cos(o_angle_y)+n_vect_i[2]*sin(o_angle_y),n_vect_i[2]*cos(o_angle_y)-n_vect_i[1]*sin(o_angle_y)]
      ; angle between beam and observation for this light ray
      angle_beam_i = acos(abs(total(n_vect_i*n_beam)))
    ;  plots,i_int_r*amax+i_int_a,(angle_beam_i-angle_beam)/!pi*180,psym=2,/data
      ; Doppler shifted beam emission wavelength for this light ray
      w_doppler_i = (1.+v_beam*cos(angle_beam_i)/2.997e8)*656.3
 ;     plots,i_int_r*amax+i_int_a,w_doppler_i,psym=1,/data
      ; Transmission of Doppler shifted light weighted with light ray area (r)
      trans_doppler = trans_doppler+(interpol(p_act,w,w_doppler_i)*r) > 1e-6
      ;Shifting spectrum wavelength by Doppler differerence from optical axis
      w_spect_i = w+(w_doppler_i-w_doppler)
      beam_spectrum_i = interpol(beam_spectrum,w_spect_i,w)
   ;   plots,i_int_r*amax+i_int_a,total(w*beam_spectrum_i)/total(beam_spectrum_i),psym=1,/data
   ;plot,w,beam_spectrum_i*p_act,xrange=[658,665] & wait,0.1
      trans_spectrum = trans_spectrum+(total(beam_spectrum_i*p_act)/total(beam_spectrum_i)*r) > 1e-6
    endfor
  endfor
  trans = trans/weight
  trans_doppler = trans_doppler/weight
  trans_spectrum = trans_spectrum/weight
  filter_transmission = filter_transmission/weight


end