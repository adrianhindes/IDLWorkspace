pro kstar_density,shot,dens,reff,rbes,timerange_on=timerange_on,$
                  timerange_off=timerange_off, plot=plot, ps=ps, relcal=relcal

;**************************************************************************
;*  KSTAR_DENSITY.PRO                  S. Zoletnik   16.02.2012
;* Calculates the density profile as a function of r_eff in KSTAR
;* from the combination of interferometer and BES data. r_eff is defined
;* as sqrt(F_flux/Pi), where F_flux is the area of the flux surface.
;*
;* INPUT:
;*  shot: Shot number
;*  timerange_on: The time range in sec where the beam is on
;*  timerange_off: The time range when the beam is off
;*  relcal: use the relative calibrated data for recontruction
;* OUPUT:
;*  dens: The density in m^-3
;*  reff: The effective radius [cm]
;***********************************************************************

default, timerange_on, [1.74,1.76]
default, timerange_off, [1.762,1.777]
default, hline, 1
default, plot, 0
default, ps, 0
default, relcal, 0
nflux = 50
addit=16
if keyword_set(plot) then begin
  erase
  device, decomposed=0
  set_plot_style, 'foile_eps_kg'
  loadct, 5
endif
cd, 'D:\KFKI\Measurements\KSTAR\Measurement'
flux = get_kstar_efit(shot,mean(timerange_on),errormess=errormess,/silent)
if (errormess ne '') then begin
  if (not keyword_set(silent)) then print,errormess
  return
endif

R0=1.260
l=1.2 ;length of the line
res=0.0001 ; resolution in m
n2=round(l/res)

;Position of the BES
pos_bes=dblarr(8,2) 
pos=getcal_kstar_spat(shot)/1000.
  
;for i=0,7 do begin
;  pos_bes[i,0]=mean(pos[0:3,i,0])
;  pos_bes[i,1]=mean(pos[0:3,i,1])
;endfor
pos_bes[*,0]=pos[hline-1,*,0]
pos_bes[*,1]=pos[hline-1,*,1]

R_bes=pos_bes[7,0]-findgen(n2)*res
z_bes=pos_bes[7,1]+(pos_bes[0,1]-pos_bes[7,1])/(pos_bes[0,0]-pos_bes[7,0])*(R_bes-pos_bes[7,0])
R_bes=reverse(R_bes)
z_bes=reverse(z_bes)

;DEBUG:
;       device, decomposed=0
;       loadct, 5
;       plot, R_bes, z_bes, color=100
;       oplot, pos_bes[*,0], pos_bes[*,1], psym=4
;       stop

; Normalize flux
norm_psi = (flux.psi-flux.axis_flux)/(flux.limiter_flux-flux.axis_flux)

levels = (findgen(nflux)+1)/(nflux+1)
reff_list = fltarr(nflux)
alfa=7.*!pi/180.

R=R0+findgen(n2)*res
z1=(R-R0)*sin(alfa)
z2=(R-R0)*sin(-1*alfa)
distvec=dblarr(n2,2)
crosspoint=dblarr(nflux+addit,4,2)
crossbes=dblarr(nflux+addit,2)
if keyword_set(ps) then hardon, /color

for i=0,nflux-1 do begin
  contour,norm_psi,flux.r,flux.z,levels=levels[i],path_xy=contour,path_info=contour_info,/path_data_coords
  n_points = n_elements(contour)/2
  ind = lindgen(n_points-5)+5
  dist2 = (flux.r_axis-reform(contour[0,*]))^2+(flux.z_axis-reform(contour[1,*]))^2
  if (dist2[0] gt dist2[n_points-1]) then begin
    contour = reverse(contour,2)
  endif
  dist2 = (contour[0,0]-reform(contour[0,*]))^2+(contour[1,0]-reform(contour[1,*]))^2
  ind_min = ind[(where(dist2[ind] eq min(dist2[ind])))[0]]
  contour_closed = fltarr(2,ind_min+2)
  contour_closed[*,0:ind_min] = contour[*,0:ind_min]
  contour_closed[*,ind_min+1] = contour[*,0]
  
  if keyword_set(plot) then begin
    plot, contour_closed[0,*], contour_closed[1,*], /iso, xrange=[1.2,2.5],yrange=[-1,1], /noerase, $
          xtitle='R [m]', ytitle='z [m]', xcharsize=1.5, ycharsize=1.5, thick=2
  endif
  
  reff_list[i] = sqrt(poly_area(reform(contour_closed[0,*]),reform(contour_closed[1,*]))/!pi)
  ;Calculate the crosspoints of the interferometer strings and the magnetic flux surfaces
  
  for k=0,1 do begin
    if k eq 0 then ind_2=where(contour_closed[0,*] lt 1.8) else ind_2=where(contour_closed[0,*] gt 1.8) 
    n=n_elements(contour_closed[0,*])
    contour_closed2=dblarr(2,n_elements(ind_2))
    contour_closed2[0,*]=contour_closed[0,ind_2]
    contour_closed2[1,*]=contour_closed[1,ind_2]
    
    for j=0,n2-1 do begin
      distvec[j,0]=min((R[j]-reform(contour_closed2[0,*]))^2+(z1[j]-reform(contour_closed2[1,*]))^2)
    endfor
    for j=0,n2-1 do begin
      distvec[j,1]=min((R[j]-reform(contour_closed2[0,*]))^2+(z2[j]-reform(contour_closed2[1,*]))^2)
    endfor
    
    ind_min1=min(reform(distvec[*,0]),k1)
    crosspoint[i,k*2,0]=R[k1]
    crosspoint[i,k*2,1]=z1[k1]
    
    ind_min1=min(reform(distvec[*,1]),k1)
    crosspoint[i,k*2+1,0]=R[k1]
    crosspoint[i,k*2+1,1]=z2[k1]
  endfor
  
  ;Calculate the cross points of the BES line and the magnetic flux surfaces
  ind_2=where(contour_closed[0,*] gt 1.8)
  n=n_elements(contour_closed[0,*])
  contour_closed2=dblarr(2,n_elements(ind_2))
  contour_closed2[0,*]=contour_closed[0,ind_2]
  contour_closed2[1,*]=contour_closed[1,ind_2]
  
  for j=0,n2-1 do begin
    distvec[j,0]=min((R_bes[j]-reform(contour_closed2[0,*]))^2+(z_bes[j]-reform(contour_closed2[1,*]))^2)
  endfor
  ind_min1=min(reform(distvec[*,0]),k1)
  crossbes[i,0]=R_bes[k1]
  crossbes[i,1]=z_bes[k1]
  
endfor

for i=nflux,nflux+addit-1 do begin
  crosspoint[i,2,0]=crosspoint[i-1,2,0]+mean(abs(crosspoint[i-5:i-1,2,0]-crosspoint[i-6:i-2,2,0]))
  crosspoint[i,2,1]=crosspoint[i-1,2,1]+mean(abs(crosspoint[i-5:i-1,2,1]-crosspoint[i-6:i-2,2,1]))
  crosspoint[i,3,0]=crosspoint[i-1,3,0]+mean(abs(crosspoint[i-5:i-1,3,0]-crosspoint[i-6:i-2,3,0]))
  crosspoint[i,3,1]=crosspoint[i-1,3,1]-mean(abs(crosspoint[i-5:i-1,3,1]-crosspoint[i-6:i-2,3,1]))
  crossbes[i,0]=crossbes[i-1,0]+mean(abs(crossbes[i-5:i-1,0]-crossbes[i-6:i-2,0]))
  crossbes[i,1]=crossbes[i-1,1]+mean(abs(crossbes[i-5:i-1,1]-crossbes[i-6:i-2,1]))
endfor
; These lines are the interferometry strings:
if keyword_set(plot) then begin
  oplot, R, z1
  oplot, R, z2
  oplot, R_bes, z_bes

  for i=0,3 do oplot, crosspoint[*,i,0],crosspoint[*,i,1], psym=4, color=100, thick=3
  oplot, crossbes[*,0],crossbes[*,1], psym=4, color=170, thick=2
  for i=0,3 do begin
    for j=0,7 do begin
      plots,pos[i,j,0], pos[i,j,1],psym=4, color=50
    endfor
  endfor
endif

if keyword_set(ps) then hardfile, 'density_calc.ps'
if keyword_set(relcal) then begin
  ;Getting the background signal 
  bgsub=dblarr(4,8)
  for i=0,3 do begin
    for j=0,7 do begin
      get_rawsignal,shot,'BES-'+strtrim(i+1,2)+'-'+strtrim(j+1,2),t,d,timerange=timerange_off, nocalibrate=0
      bgsub[i,j]=mean(d)
    endfor
  endfor
  
  ;Getting the BES data
  dens_bes=dblarr(8)
  for i=0,7 do begin
    get_rawsignal, shot,'BES-'+strtrim(hline,2)+'-'+strtrim(i+1,2),t,d, timerange=timerange_on, nocalibrate=0
    dm=(mean(d)-bgsub[hline-1,i])*calc_abs_cal_fac(shot)
    dens_bes[i]=dm
  endfor
endif else begin
  ;Getting the background signal
  get_rawsignal, shot, 'E_NBI', t, d, /store
  ebeam=max(d)*1e-3
  kstar_filter_transmission, shot, transmission=trans, ebeam=ebeam
   
  bgsub=dblarr(4,8)
  for i=0,3 do begin
    for j=0,7 do begin
      get_rawsignal,shot,'BES-'+strtrim(i+1,2)+'-'+strtrim(j+1,2),t,d,timerange=timerange_off, nocalibrate=1
      bgsub[i,j]=mean(d)
    endfor
  endfor
  
  ;Getting the BES data
  dens_bes=dblarr(8)
  for i=0,7 do begin
    get_rawsignal, shot,'BES-'+strtrim(hline,2)+'-'+strtrim(i+1,2),t,d, timerange=timerange_on, nocalibrate=1
    dm=(mean(d)-bgsub[hline-1,i])*calc_abs_cal_fac(shot)/trans[hline-1,i]
    dens_bes[i]=dm
  endfor
endelse

nsp=161
dens_bes_spline=dblarr(nsp)

pos_bes_r_spline=pos_bes[0,0]+(pos_bes[7,0]-pos_bes[0,0])*dindgen(nsp)/(nsp-1)
dens_bes_spline=spline(reform(pos_bes[*,0]),dens_bes[*],pos_bes_r_spline)

dens_bes_cross=dblarr(nflux+addit)

ind1=where(crossbes[*,0] lt pos_bes[0,0])
ind2=where(crossbes[*,0] gt pos_bes[7,0])
ind3=where(crossbes[*,0] ge pos_bes[0,0] and crossbes le pos_bes[7,0])
  
dens_bes_cross[ind3]=spline(reform(pos_bes[*,0]),dens_bes/max(dens_bes),reform(reform(crossbes[ind3,0])))
parabolic=1
if not keyword_set(parabolic) then begin
  dens_bes_cross[ind1]=1
endif else begin
if not keyword_set(relcal) then begin
  x=[1.754386,dens_bes[0:1]/max(dens_bes)]
  y=[1.8,reform(pos_bes[0:1,0])]
endif else begin
  x=[1.754386,dens_bes[1:2]/max(dens_bes)]
  y=[1.8,reform(pos_bes[1:2,0])]
endelse

p=mpfitfun('parabolic_fit',x,y,[0.01,0.01,0.01],[1,1,1])

dens_bes_cross[ind1]=(-p[1]-sqrt(p[1]^2-4*p[0]*(p[2]-crossbes[ind1,0])))/(2*p[0])

endelse
plot, crossbes[*,0], 0.57*dens_bes_cross
dens_bes_cross=0.57*dens_bes_cross
;DEBUG:
;plot, float([crossbes[56:57],crossbes[65]]),float([dens_bes_cross[56:57],0.05]), psym=4
;x=findgen(100)/100.*(2.34-2.2)+2.2
;p=mpfitfun('exponential_fit', float([crossbes[ind2[0]-2:ind2[0]-1,0],crossbes[ind2[n_elements(ind2)-1]],0]),$
;                              float([dens_bes_cross[ind2[0]-2:ind2[0]-1],0.02]),$
;                              [0.001,0.01,0.01],[10, 0.1])
;oplot, x, exponential_fit(x, p)                              
;stop

; Fitting of the values

p=mpfitfun('exponential_fit', float([crossbes[ind2[0]-2:ind2[0]-1,0],crossbes[ind2[n_elements(ind2)-1]],0]),$
                              float([dens_bes_cross[ind2[0]-2:ind2[0]-1],0.02]),$
                              [0.01,0.01,0.01],[10, 0.1])
dens_bes_cross[ind2]=exponential_fit(crossbes[ind2,0],p)
                              
;dens_bes_cross[ind2]=0
;DEBUG:  
;       plot, crossbes[*,0], dens_bes_cross[*], yrange=[-0.1, 1.1]

;DEBUG:
;        erase
;        plot, pos_bes[*,0], dens_bes, color=100, psym=4
;        oplot, pos_bes_r_spline,dens_bes_spline, color=150
;        stop

posvec=dblarr(4*nflux+2*addit,2)
dens_all=dblarr(4*nflux+2*addit)

posvec[0:nflux+addit-1,0]=reverse(reform(crosspoint[*,3,0]))
posvec[0:nflux+addit-1,1]=reverse(reform(crosspoint[*,3,1]))

posvec[nflux+addit:2*nflux+addit-1,0]=crosspoint[0:nflux-1,1,0]
posvec[nflux+addit:2*nflux+addit-1,1]=crosspoint[0:nflux-1,1,1]

posvec[2*nflux+addit:3*nflux+addit-1,0]=reverse(reform(crosspoint[0:nflux-1,0,0]))
posvec[2*nflux+addit:3*nflux+addit-1,1]=reverse(reform(crosspoint[0:nflux-1,0,1]))

posvec[3*nflux+addit:4*nflux+2*addit-1,0]=crosspoint[*,2,0]
posvec[3*nflux+addit:4*nflux+2*addit-1,1]=crosspoint[*,2,1]
;DEBUG:
;       oplot, posvec[*,0],posvec[*,1], psym=4, color=150, thick=3

dens_all[0:nflux+addit-1]=reverse(dens_bes_cross)
dens_all[nflux+addit:2*nflux+addit-1]=dens_bes_cross[0:nflux-1]
dens_all[2*nflux+addit:3*nflux+addit-1]=reverse(dens_bes_cross[0:nflux-1])
dens_all[3*nflux+addit:4*nflux+2*addit-1]=dens_bes_cross

n=n_elements(reform(posvec[*,0]))
dist_vec=dblarr(n)
dist_vec[0]=distance(posvec[0,*],posvec[1,*])/2
dist_vec[n-1]=distance(posvec[n-2,*],posvec[n-2,*])/2
for i=1, n-2 do begin
  dist_vec[i]=(distance(posvec[i,*],posvec[i-1,*])+distance(posvec[i,*],posvec[i+1,*]))/2
endfor

;dist_vec=sqrt((posvec[0:n-2,0]-posvec[1:n-1,0])^2+(posvec[0:n-2,1]-posvec[1:n-1,1])^2)
;stop
line_int_dens=total(dens_all[0:n-2]*dist_vec)

;DEBUG:
;       erase
;       plot, posvec[*,1],dens_all

get_rawsignal, 6123, '\NE_INTER01', t, d, timerange=timerange_on, /store
dens_interf=mean(d)*1e19

coeff_bes_interf=dens_interf/line_int_dens
if keyword_set(plot) then begin
  plot, crossbes[*,0],dens_bes_cross*coeff_bes_interf, xtitle='R [m]', ytitle='Electron density [1/m^3]', xcharsize=1.5, ycharsize=1.5, thick=2
endif

dens=dens_bes_cross*coeff_bes_interf
rbes=crossbes[*,0]
reff=[reff_list, reff_list[nflux-1]+(findgen(addit)+1)*mean(abs(reff_list[nflux-4:nflux-2]-reff_list[nflux-3:nflux-1]))]

;flux_list = [0,levels]
;fitorder = 2
;p=poly_fit(flux_list,reff_list,fitorder)
;f = findgen(100)/max(flux_list)
;r = p[0]
;plot,flux_list,reff_list

;modification according to Y.U.Nam

;these data are from Y.U.Nam, from something called scanning interferometer

;restore, 'data/n_e_prof.sav'
;
;dens_norm=dens/max(dens)
;a=min(abs(n_e_prof[*,0]-reff[max(ind3)]),i)
;dens_norm_bes_max=n_e_prof[i] ;normal density for bes, where the n_e is still known
;reff_max=reff[i]
;a=min(abs((n_e_prof[*,0]-reff[min(ind3)])),i)
;dens_norm_bes_max=n_e_prof[i] ;normal density for bes, where the n_e is still known
;;n_e_prof[*,0]=n_e_prof[*,0]*0.5
;dens_norm[where(reff lt n_e_prof[0,0] and reff gt reff[max(ind3)])]=spline(reverse(reform(n_e_prof[*,0])),reverse(smooth(reform(n_e_prof[*,1]),2)/max(smooth(reform(n_e_prof[*,1]),2))),$
;                                                                           reff[where(reff lt n_e_prof[0,0] and reff gt reff[max(ind3)])])
;dens_norm[where(reff gt n_e_prof[0,0])]=1
stop
end
