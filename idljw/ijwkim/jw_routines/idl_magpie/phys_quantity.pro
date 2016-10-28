function phys_quantity, shot_number,gas_type=gas_type,discharge_time = discharge_time
  common share2, mean_temp, mean_isat, cspeed_tmp, vacuum_permittivity, boltzmann_si, e_charge
  default, gas_type, 'hydrogen'
  default, discharge_time, 0.3
  
  area_isat = 5.80E-3*!Pi*0.20E-3+!PI*(0.10E-3)^2.0
  area_isat_rot = 6.10E-3*!Pi*0.20E-3+!PI*(0.10E-3)^2.0

  e_charge = 1.602177E-19
  atomic_mass = 1.660539E-27
  vacuum_permittivity = 8.854188E-12
  m_i_argon = 39.948*atomic_mass
  m_i_hydrogen = atomic_mass
  m_e = 9.109384E-31
  boltzmann_si = 1.380648E-23
  boltzmann_ev = 8.617332E-5
  charge_state = 1.D
  
  if shot_number ge 1911L then begin
    isat_sign = -1.D
  endif else begin
    isat_sign = 1.D
  end
  
  cspeed_tmp = sqrt(boltzmann_si*charge_state/m_i_hydrogen)

  ionize_0_1_temp = [1.723E-01, 4.308E-01, 8.617E-01, 1.723E+00, 4.308E+00, 8.617E+00, 1.723E+01, 4.308E+01, 8.617E+01, 1.723E+02, 4.308E+02, 8.617E+02]
  ionize_0_1 = [1.000E-36, 1.230E-23, 1.782E-15, 2.426E-11, 7.985E-09, 5.440E-08, 1.382E-07, 2.355E-07, 2.803E-07, 3.247E-07, 5.391E-07, 8.127E-07]
  
  trange = [0.0, discharge_time*1.1]
  background = [discharge_time*1.1, discharge_time*1.19]
  
  isat = magpie_data('probe_isat',shot_number)
  vfloat = magpie_data('probe_vfloat',shot_number)
  vplus = magpie_data('probe_vplus',shot_number)
  
  isat_rot = magpie_data('probe_isat_rot',shot_number)
  vfloat_rot = magpie_data('probe_vfloat_rot',shot_number)
  
  pmt = magpie_data('single_pmt',shot_number)
  
  isat_cut = select_time(isat.tvector,isat_sign*isat.vvector,trange)
  isat_back = select_time(isat.tvector,isat_sign*isat.vvector,background)
  vfloat_cut = select_time(vfloat.tvector,vfloat.vvector,trange)
  vfloat_back = select_time(vfloat.tvector,vfloat.vvector,background)
  vplus_cut = select_time(vplus.tvector,vplus.vvector,trange)
  vplus_back = select_time(vplus.tvector,vplus.vvector,background)
  
  isat_rot_cut = select_time(isat_rot.tvector,isat_rot.vvector,trange)
  isat_rot_back = select_time(isat_rot.tvector,isat_rot.vvector,background)
  vfloat_rot_cut = select_time(vfloat_rot.tvector,vfloat_rot.vvector,trange)
  vfloat_rot_back = select_time(vfloat_rot.tvector,vfloat_rot.vvector,background)
  
  pmt_cut = select_time(pmt.tvector,pmt.vvector,trange)
  pmt_back = select_time(pmt.tvector,pmt.vvector,background)
  
  isat_resistance = 200.
  if shot_number ge 1876 then begin
    isat_resistance = 400.0
  endif
  
  isolation_amplifier = 1.0
  if shot_number ge 6964 then begin
    isolation_amplifier = 2
  endif
  real_isat = (isat_cut.yvector-mean(isat_back.yvector))/isat_resistance*isolation_amplifier
  real_vfloat = (vfloat_cut.yvector-mean(vfloat_back.yvector));/5.*1003./3.
  real_vplus = (vplus_cut.yvector-mean(vplus_back.yvector));/5.*1003./3.
  
  real_isat_rot = (isat_rot_cut.yvector-mean(isat_rot_back.yvector));/400.
  real_vfloat_rot = (vfloat_rot_cut.yvector-mean(vfloat_rot_back.yvector));/5.*1003./3.
  
  real_pmt = pmt_cut.yvector-mean(pmt_back.yvector)
  
  temp = abs((real_vfloat-real_vplus)/alog(2));*11604)
  dens = real_isat/area_isat/e_charge/cspeed_tmp/sqrt(temp)
  dens_sqrt_temp = real_isat/area_isat/e_charge/cspeed_tmp
  vplasma = real_vfloat+boltzmann_si*temp/e_charge/2.0*alog(2.0*m_i_hydrogen/!pi/m_e)
  
;  x = 1.5E16
;  mean_temp = mean(temp)
;  mean_isat = mean(real_isat)
;  solve = NEWTON(x,'density_eq')
;  print, 'newton method : ', solve
  
;  ycplot, isat_cut.tvector,real_vfloat,out_base_id = oid
;  ycplot, isat_cut.tvector,vplasma,oplot_id = oid
;  ycplot, isat_cut.tvector,real_vplus,oplot_id = oid
;  ycplot, isat_cut.tvector, vplasma-real_vfloat, oplot_id = oid
  
  result = CREATE_STRUCT('tvector',isat_cut.tvector,'temp',temp,'dens',dens,'vplasma',vplasma,'isat',real_isat, $
    'vfloat',real_vfloat,'vplus',real_vplus,'isat_rot',real_isat_rot,'vfloat_rot',real_vfloat_rot,'pmt',real_pmt,'location',isat.location)
  return, result
end

;function density_eq, X
;  common share2
;;  print, 'cspeed_tmp : ', cspeed_tmp
;  return, cspeed_tmp*sqrt(mean_temp)*(5.80E-3*!Pi*(0.20E-3+4*sqrt(vacuum_permittivity*boltzmann_si*mean_temp/e_charge^2)/sqrt(X[0])) $
;    +2*!PI*(0.10E-3+2*sqrt(vacuum_permittivity*boltzmann_si*mean_temp/e_charge^2)/sqrt(X[0]))^2.0)*e_charge*X[0] -mean_isat
;end