pro filter_divergence_transmission,ebeam=ebeam,radius=radius,rho=rho,ray_divergence=ray_divergence_max,n_divergence=n_divergence,$
   angle=angle,temperature=temperature,noplot=noplot,thick=thick,charsize=charsize,symsyze=symsize,$
   fixed_wavelength=fixed_wavelength,yrange=yrange,title=title,cwl=cwl_new,filter=filter,$
   trans_fixed=trans,trans_doppler=trans_doppler,trans_spectrum=trans_spectrum,div_list=divergences,errormess=errormess,$
   transmission_filter=filter_transmission,wavelength=w,full_beam=full_beam,spectrum_data=spectrum_data,spectrum_w=spectrum_w,doppler_wavelength=w_doppler,$
   equation=equation,ref_index=refr_index,image_point=image_point

;******************************************************************************
;* FILTER_DIVERGENCE_TRANSMISSION.PRO          S. Zoletnik  12.03.2012        *
;******************************************************************************
;* Calculate the transmission of the filter as a function of ray divergence   *
;* either at a given wavelength  or using a calculated BES spectrum.          *
;* Can use various filter data specified by <filter>                          *
;* INPUT:                                                                     *
;*   ebeam: Beam energy [keV]                                                 *
;*   radius: Major radius in tokamak [m]                                      *
;*   rho: r/a. (This is alternative to radius)                                *
;*   ray_divergence: The maximum divergence of light rays from one channel    *
;*                   relative to the central ray [deg]                        *
;*   angle: The mean angle of incidence on the filter                         *
;*   temperature: Filter temperature in C.                                    *
;*   fixed_wavelength: Calculate transmission at this wavelength instead of   *
;*         the Doppler shiftes D_alpha                                        *
;*   cwl: Central wavelength of filter (def:661.99)                           *
;*   filter: A file name containing filter transmission as a function of      *
;*           wavelength and angle. First line is description, second line is  *
;*           'wavelength a1 a2 a3 a4', where a1, a2... are the angles in deg  *
;*   /full_beam: use full beam BES emission for calculation                   *
;*                (otherwise use full energy component only)                  *
;*   image_point: The [x,y] coordinates of the modeled point on the image     *
;*                plane. x is along the beam (incresing inside) and y is      *
;*                accross.                                                    *
;*   /equation: Use equation from Andover website for angle shift             *
;*    refr_index: Refrective index for angle sensitivity                      *
;*  OUTPUT:                                                                   *
;*   trans_fixed: Transmission at fixed wavelength vs. divergences            *
;*   trans_doppler: Transmission at Doppler shift vs divergence               *
;*   trans_spectrum: Transmission of spectrum vs. divergence                  *
;*   transmission_filter: The transmision of the filter with divergence       *
;*   wavelength: The wavelength scale for the filter transmission             *
;*   div_list: The list of divergence values                                  *
;*   rho: The calculated r/a value at this radius                             *
;*   radius: The major R for the rho                                          *
;*   spectrum_data: The intensity data for the calculated BES spectrum        *
;*   spectrum_w: The wavelength data for the spectrum                         *
;*   doppler_wavelength: The calculated Doppler shifted full energy wavelength*
;******************************************************************************

default,ray_divergence_max,5.
default,temperature,23.
default,angle,0.
default,ebeam,100.
default,filter,'BES_2011.dat'
default,fixed_wavelength,658.3
default,refr_index,2.08
default,n_divergence,10
default,equation,1

errormess = ''

if (defined(rho) and defined(radius)) then begin
  errormess = 'Set only one of rho and radius.'
  print,errormess
  return
endif
if (not defined(rho) and not defined(radius)) then begin
  errormess = 'Set wither rho or radius.'
  print,errormess
  return
endif

ray_divergence_max = float(ray_divergence_max)
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

;Interpolating the beam spectrum to the wavelength scale of the filter
beam_spectrum = interpol(spectrum_data,spectrum_w,w)

; Calculating Doppler wavelength
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
d = sqrt(total((opt_axis-mirror_center)^2))+275
; unit vector from detector center to first mirror
n_vect = (mirror_center-opt_axis)/sqrt(total((mirror_center-opt_axis)^2))
; first lens position mirrored in first mirror
first_lens = mirror_center + n_vect*275
v_beam = sqrt(2*ebeam*1000.*1.602e-19/(2*1.6726e-27))
n_beam = [-1.,0.,0.]
; angle between observation and beam
angle_beam = acos(abs(total(n_vect*n_beam)))
; Doppler shifted beam emission wavelength
w_doppler = (1.+v_beam*cos(angle_beam)/2.997e8)*656.3

;plot,spectrum_w/10,spectrum_data
;oplot,spectrum_w/10,spectrum_e2
;oplot,spectrum_w/10,spectrum_e3
;oplot,[w_doppler,w_doppler],[0,max(spectrum_data)]

w = w+(temperature-23.)*0.018
angle_filt = angle/180*!pi
trans = dblarr(n_divergence)
trans_doppler = trans
trans_spectrum = trans
filter_transmission = fltarr(n_divergence,n_elements(w))
if (n_divergence eq 1) then begin
  divergences = ray_divergence_max
endif else begin
  divergences = findgen(n_divergence)/(n_divergence-1)*ray_divergence_max
endelse
;plot,[min(w),max(w)],[0,120],/nodata
for i_div=0,n_divergence-1 do begin
  ray_divergence = divergences[i_div]
  rmax = 10
  amax = 30
  weight = 0
  ; plot,[0,1],[0,1],xrange=[0,rmax*amax],yrange=[-10,10],/nodata
  for i_int_r=0,rmax-1 do begin
    ; angular cycle
    r = (float(i_int_r)+0.5)/rmax
    for i_int_a=0,amax-1 do begin
      ang = float(i_int_a)/amax*2*!pi
      ; filter is z=0 surface, defining a unit vector [x,y,z] along a light ray
      ray = [sin(r*ray_divergence/180*!pi)*cos(ang),sin(r*ray_divergence/180*!pi)*sin(ang),cos(r*ray_divergence/180*!pi)]
      ; Rotating around x axis by mean angle
      ray = [ray[0],ray[1]*cos(angle_filt)+ray[2]*sin(angle_filt),-ray[1]*sin(angle_filt)+ray[2]*cos(angle_filt)]
      angle_act = abs(asin(sqrt(ray[0]^2+ray[1]^2)))/!pi*180.
      ; plots,i_int_r*amax+i_int_a,angle_act,psym=1,/data
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
      filter_transmission[i_div,*] = filter_transmission[i_div,*] + p_act*r
      trans[i_div] = trans[i_div]+(interpol(double(p_act),double(w),double(fixed_wavelength))*r)>1e-6
      trans_doppler[i_div] = trans_doppler[i_div]+(interpol(p_act,w,w_doppler)*r) > 1e-6
      trans_spectrum[i_div] = trans_spectrum[i_div]+(total(beam_spectrum*p_act)/total(beam_spectrum)*r) > 1e-6
    endfor
  endfor
  trans[i_div] = trans[i_div]/weight
  trans_doppler[i_div] = trans_doppler[i_div]/weight
  trans_spectrum[i_div] = trans_spectrum[i_div]/weight
  filter_transmission[i_div,*] = filter_transmission[i_div,*]/weight
endfor ; divergence

if (not keyword_set(noplot)) then begin
  erase
  title = 'R = '+i2str(radius*1000)+'[mm] (r/a='+string(rho,format='(F4.2)')+')
  title = title+'!CSpectrum: !C'+spectrum_file
  title = title+'!CFilter: '+filter
  title = title+'!CCWL: '+string(cwl_new,format='(F6.2)')+'nm'
  title = title+'!CT: '+string(temperature,format='(F4.1)')+'[C]'
  title = title+'!CFilter angle: '+string(angle,format='(F3.1)')+'[deg]'
  xyouts,0.65,0.47,title,charthick=thick ,/normal

  plotsymbol,0

  plot,divergences,trans_doppler,yrange=[0,105],xstyle=1,xtitle='Divergence [degree]',$
    ystyle=1,ytitle='Transmission [%]',$
    thick=thick,xthick=thick,ythick=thick,charthick=thick,charsize=charsize,psym=-8,symsize=symsize,$
    title='Transmission at Doppler D!D!7a!X!N',pos=[0.1,0.57,0.3,0.9],/noerase
  plot,divergences,trans_spectrum,yrange=[0,105],xstyle=1,xtitle='Divergence [degree]',$
    ystyle=1,ytitle='Transmission [%]',$
    thick=thick,xthick=thick,ythick=thick,charthick=thick,charsize=charsize,psym=-8,symsize=symsize,$
    title='Transmission of BES spectrum',pos=[0.4,0.57,0.6,0.9],/noerase
  plot,divergences,trans,xstyle=1,yrange=[0,max(trans)*1.05],xtitle='Divergence [degree]',ytitle='Transmission [%]',$
    thick=thick,xthick=thick,ythick=thick,charthick=thick,charsize=charsize,psym=-8,symsize=symsize,$
    title='Transmission at '+string(fixed_wavelength,format='(F5.1)')+'nm',pos=[0.7,0.57,0.9,0.9],/noerase
  plot,divergences,trans_doppler/trans,xstyle=1,xtitle='Divergence [degree]',ystyle=1,yrange=[0,max(trans_doppler/trans)*1.05],$
    thick=thick,xthick=thick,ythick=thick,charthick=thick,charsize=charsize,psym=-8,symsize=symsize,$
    title='Doppler D!D!7a!X!N to '+string(fixed_wavelength,format='(F5.1)')+'nm',pos=[0.1,0.1,0.3,0.42],/noerase
  plot,divergences,trans_spectrum/trans,xstyle=1,xtitle='Divergence [degree]',ystyle=1,yrange=[0,max(trans_spectrum/trans)*1.05],$
    thick=thick,xthick=thick,ythick=thick,charthick=thick,charsize=charsize,psym=-8,symsize=symsize,$
    title='BES to '+string(fixed_wavelength,format='(F5.1)')+'nm',pos=[0.4,0.1,0.6,0.42],/noerase

  plot,w,p/100,/noerase,pos=[0.7,0.08,0.9,0.28],xtitle='Wavelegth [nm]',yrange=[0,1.05],ystyle=1,xrange=[655,668],$
    title='At 0 angle and max. divergence',linestyle=1,thick=thick,xthick=thick,ythick=thick,charthick=thick,charsize=charsize
  oplot,w,filter_transmission[n_divergence-1,*]/100,linestyle=2,thick=thick
  oplot,spectrum_w,spectrum_data/max(spectrum_data),thick=thick
  oplot,[w_doppler,w_doppler],[0,1],thick=thick
  oplot,[fixed_wavelength,fixed_wavelength],[0,1],linest=2,thick=thick
endif

end