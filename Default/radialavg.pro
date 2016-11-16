function radialAvg, shot=shot

;Adapted from magpie_profile_radial_avg
;Input shot number, output 5 arrays of x axis and averaged data from experiments

;Write experiment title here for plot
 
 
  setNum =  [1,2,3]
  start_shot = shot
  
  points_num = dataPoints(start_shot)
  
  
  temp=dblarr(points_num,3)
  dens=dblarr(points_num,3)
  vplasma=dblarr(points_num,3)
  isat=vplasma
  
for k = 0, 2 do begin
  
  probe_ax = ptrarr(points_num)
  

;Probe areas, precalculated by Jaewook. Redo if using new probe.
  area_isat = 5.80E-3*!Pi*0.20E-3+!PI*(0.10E-3)^2.0
  area_isat_rot = 6.10E-3*!Pi*0.20E-3+!PI*(0.10E-3)^2.0

;Later experiments were hydrogen discharges, set variable to pass
;to phys_quantity
 if start_shot ge 6964 then begin
  species = 'hydrogen'
 endif

;Retrieve data
  for i = 0, points_num-1 do begin
    shot_number = i*setNum[k]+start_shot 
    probe_ax[i] = ptr_new(phys_quantity(shot_number,gas_type=species))
  endfor

;Create arrays
  temp_ax_mean = dblarr(points_num)
  dens_ax_mean = dblarr(points_num)
  vplasma_ax_mean = dblarr(points_num)
  isat_ax_mean = vplasma_ax_mean

  ;#Coordinates#
;Default for later shots (ge 7498)
  probe_degrees=[180,160,140,120,100,80,60,40,20,0]
  shiftVal = 0
  
  if start_shot le 7213 then begin ;Second set, only 180 degree rotations
    probe_degrees=[10,30,50,70,90,110,130,150,170,190,210,230,250,270,290,310,330,350]
    shiftVal = -5
  endif
  if start_shot le 6960 then begin ;Second set, only 180 degree rotations
    probe_degrees=[270,290,310,330,350,10,30,50,70,90,110,130,150,170,190,210,230,250]
    shiftVal = -5
  endif
  
probe_radians = probe_degrees * !DtoR

;Process Data

  radius = 3 ;length of probe end shaft, defining radius traced
  yoff = 2.75 ;offset, dist from centre of probe rotation to centre of plasma
  for i = 0, points_num-1 do begin
    temp_ax_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).temp,(*probe_ax[i]).ptime)
    dens_ax_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).dens,(*probe_ax[i]).ptime)
    vplasma_ax_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).vplasma,(*probe_ax[i]).btime)
    isat_cut = select_time((*probe_ax[i]).tvector,(*probe_ax[i]).isat,(*probe_ax[i]).btime)

;Mean of data
    temp_ax_mean[i] = mean(temp_ax_cut.yvector)
    dens_ax_mean[i] = mean(dens_ax_cut.yvector)
    vplasma_ax_mean[i] = mean(vplasma_ax_cut.yvector)
    isat_ax_mean[i] = mean(isat_cut.yvector)

;Currently broken lol
;probe_ax_location[i] = sqrt( (radius*cos(probe_radians[i]))^2+(yoff-radius*sin(probe_radians[i]))^2   )
    
    endfor

;Shifting data for plotting if necessary
temp_ax_mean = shift(temp_ax_mean, shiftVal)
dens_ax_mean = shift(dens_ax_mean, shiftVal)
vplasma_ax_mean = shift(vplasma_ax_mean, shiftVal)

;Finish setting up arrays
temp[*,k]=temp_ax_mean
dens[*,k]=dens_ax_mean
vplasma[*,k]=vplasma_ax_mean
isat[*,k]=isat_ax_mean

;Three averages, print status for each done
measPrint = ['One','Two','Three']
print, ('done measurement' + measPrint[k])


endfor ;end of big loop


temp_avg = fltarr(points_num)
dens_avg = fltarr(points_num)
vplasma_avg = fltarr(points_num)
isat_avg=vplasma_avg

;Finalize data
temp_avg = (temp[*,0]+temp[*,1]+temp[*,2])/3.
dens_avg = (dens[*,0]+dens[*,1]+dens[*,2])/3.
vplasma_avg = (vplasma[*,0]+vplasma[*,1]+vplasma[*,2])/3.
isat_avg = (isat[*,0]+isat[*,1]+isat[*,2])/3.

result = create_struct('temp',temp_avg,'density',dens_avg,'vplasma',vplasma_avg,'isat',isat_avg)

return,[result,probe_degrees]

end