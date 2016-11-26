pro magpie_profile_radial

;This procedure plots radial (180 or 360 degree) triple probe data
;Make sure phys_quantity is behaving right; eg. set to Argon on Hydrogen as appropriate
;Currently hardcoded for 360 scan, with 20 degree incremements 3 times each
;Need to do: averaging, options, automatically save plots
;Make sure data is mounted before running, either hard drive or network. Change magpie_data as necessary.

;Write experiment title here for plot
  exTitle = ''
  
  
  
  setNum =  2;1 2 or 3
  start_shot = 7558
  
  points_num = 18 ;18*3 (3 measurements per angle), total 54 measurements
  if start_shot ge 7214 then begin
    points_num = 9 ;9*3 = 27 measurements total for second set
  endif
  if start_shot ge 7408 then begin
    points_num = 10 ;9*3 = 27 measurements total for second set
  endif

  
  probe_ax = ptrarr(points_num)
  
;Probe areas, precalculated by Jaewook. Redo if using new probe.
  area_isat = 5.80E-3*!Pi*0.20E-3+!PI*(0.10E-3)^2.0
  area_isat_rot = 6.10E-3*!Pi*0.20E-3+!PI*(0.10E-3)^2.0

 if start_shot ge 6964 then begin
  species = 'hydrogen'
 endif

  for i = 0, points_num-1 do begin
    shot_number = i*setNum+start_shot 
    probe_ax[i] = ptr_new(phys_quantity(shot_number,gas_type=species))
  endfor

;Create arrays
  temp_ax_mean = dblarr(points_num)
  dens_ax_mean = dblarr(points_num)
  vplasma_ax_mean = dblarr(points_num)


  trange = [0.05, 0.09]
  background = [0.11,0.12]
  
  
if start_shot ge 7378 then begin
  trange = [0.01,0.04]
  background = [0.05,0.055]
endif

  
  probe_degrees=[180,160,140,120,100,80,60,40,20]

  if start_shot le 7213 then begin ;Second set, only 180 degree rotations
    probe_degrees=[10,30,50,70,90,110,130,150,170,190,210,230,250,270,290,310,330,350]
    shiftVal = -5
  endif
  if start_shot ge 7408 then begin
    probe_degrees=[0,20,40,60,80,100,120,140,160,180]
    shiftVal = 9 ;data started at 180 degrees
  endif
  probe_radians = probe_degrees * !DtoR
  ;#Coordinates#
  ;First set of axial experiments, started pointing down and rotated clockwise
  ;probe_ax_location=[270,290,310,330,350,10,30,50,70,90,110,130,150,170,190,210,230,250] (Actual order)
  probe_ax_location = probe_degrees
;#Arrange data#

  radius = 3 ;length of probe end shaft, defining radius traced
  yoff = 2.75 ;centre of plasma to centre of probe rotation axis
  
for i = 0, points_num-1 do begin
    temp_ax_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).temp,trange)
    dens_ax_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).dens,trange)
    vplasma_ax_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).vplasma,trange)
    isat_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).isat,trange)
    temp_ax_back = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).temp,background)
    ;dens_ax_back = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).dens,background)
    vplasma_ax_back = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).vplasma,background)

    temp_ax_mean[i] = (mean(temp_ax_cut.yvector)-mean(temp_ax_back.yvector))
    dens_ax_mean[i] = (mean(dens_ax_cut.yvector));-mean(dens_ax_back.yvector))
    vplasma_ax_mean[i] = (mean(vplasma_ax_cut.yvector)-mean(vplasma_ax_back.yvector))
    
;    if probe_radians[i] ge !pi then begin
;      probe_ax_location[i] = sqrt((radius*cos(probe_radians[i])^2.+(3-radius*sin(probe_radians[i]))^2.))
;    endif
;    if probe_radians[i] lt !pi then begin
;      probe_ax_location[i] = sqrt((radius*cos(probe_radians[i])^2.+(radius*sin(probe_radians[i])+3)^2.))
;    endif

probe_ax_location[i] = sqrt( (radius*cos(probe_radians[i]))^2+(yoff-radius*sin(probe_radians[i]))^2   )

endfor
 
;Shifting data for plotting

temp_ax_mean = shift(temp_ax_mean, shiftVal)
dens_ax_mean = shift(dens_ax_mean, shiftVal)
vplasma_ax_mean = shift(vplasma_ax_mean, shiftVal)



print, 'done, ready to plot'

stop
xlab='Radius(cm)'

  ycplot, probe_ax_location, temp_ax_mean, oplot_id = oid1, title=exTitle+' Temperature',xtitle=xlab,ytitle='Temperature (eV)'

  ycplot, probe_ax_location, dens_ax_mean, oplot_id = oid2, title=exTitle+' Density',xtitle=xlab,ytitle='Density (m^(-3))'

  ycplot, probe_ax_location, vplasma_ax_mean, oplot_id = oid3, title =exTitle+' Plasma Potential',xtitle=xlab,ytitle='Voltage (V)'


  stop

end