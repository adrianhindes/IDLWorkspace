pro model_forward
  passes = 1000 ;Number of iterations per delay pair
  
  ;Define Starting Variables
  ;Radial zones and Impact parameters (nimpacts > nrad)
  ;Increasing nimpacts increases resolution but severely increases runtime
  nrad = 15
  nimpacts = 100 
  
  ;Normalize radius
  r = findgen(nrad)/float(nrad) ;

  ;Create Projection and Backprojection matrices
  L = response(nimpacts, nrad) 
  invL = svdinverse(nrad, nimpacts, transpose(L)) 
  
  ;Define emissivity profile
  photons = 5000 ;highest no. photon counts
  epsilon = abs(0.95*cos((r)/float(0.65))) 
  epsilon = fix((epsilon*photons)>1) 
  
  ;Define Density and Temperature profiles
  ;Curved density - high centre low wings from 1E20 - 5E19 m^-3
  ;Constant temp profile of 0.15eV
  n_e = double(2.2E19*0.45*cos(r*!pi/2))
  T_atom = fltarr(nrad)
  T_atom[*] = 0.1

;Delay pairs defined top-bottom, testing cartesian product of (5K,10K,20K,30K & 40K)
;10 Pairs overall
delays1 = [1000,3000,4000,5000,1000,3000,4000,5000]
delays2 = [10000,10000,10000,10000,20000,20000,20000,10000]

;delays1 = [10000]
;delays2 = [double(50000)]

n_pairs = n_elements(delays1)

;Emissivity, density, temperature
results = fltarr(3,nrad,passes,n_pairs)
;Temporary buffer array
measurements = fltarr(3,nrad) 
;RMS Array
rms_array = fltarr(3,nrad,n_pairs)
;Mean Array
mean = fltarr(3,nrad,n_pairs)

noise_seeds=indgen(passes)

for p = 0, n_pairs -1 do begin &$
delay_a= delays1[p] &$
delay_b = delays2[p] &$
  ;Get Measurements
  for i = 0, passes-1 do begin &$
    measurements = obtain_measurements(delay_a, delay_b, L, invL, epsilon, n_e, T_atom,noise_seeds[i]) &$
    for k = 0, 2 do results[k,*,i,p] = measurements[k,*] &$ ;Emissivity, Temp, Density
  end &$
end

;Process RMS values for all radial zones through passes
for p = 0, n_pairs -1 do begin &$
  for n = 0, nrad-1 do begin &$
  rms_array[0,n,p] = rms(results[0,n,*,p]) &$
  rms_array[1,n,p] = rms(results[1,n,*,p]) &$
  rms_array[2,n,p] = rms(results[2,n,*,p]) &$
  end &$
end


;Calcualte mean measurements for all radial zones
for p = 0, n_pairs -1 do begin &$
  for n = 0, nrad-1 do begin &$
    for k = 0, 2 do mean[k,n,p] = mean(results[k,n,*,p],/NAN) &$
    end &$
end

rmsd_e = fltarr(n_pairs)
for k = 0, n_pairs -1 do rmsd_e[k] = mean(rms_array[0,*,k])
rmsd_e_min = min(rmsd_e,best_e_pair)

rmsd_n = fltarr(n_pairs)
for k = 0, n_pairs -1 do rmsd_n[k] = mean(rms_array[1,*,k])
rmsd_n_min =  min(rmsd_n,best_n_pair)

rmsd_t = fltarr(n_pairs)
for k = 0, n_pairs -1 do rmsd_t[k] = mean(rms_array[2,*,k])
rmsd_t_min = min(rmsd_t,best_t_pair)

rmsd_overall = rmsd_e + rmsd_n + rmsd_t
rmsd_overall_min = min(rmsd_overall,best_pair)
print,'Most Accurate Delay Pair = ',delays1[best_pair],'&',delays2[best_pair]

stop

p = 0
  title='Mean Emissivity from 1,000 & 10,000 Waves'
  p0 = plot(mean[0,*,p],xtitle='Radial Zone',ytitle='Temperature (eV)',name='Mean of 1000 Passes',title=title,col='red')
  p3 = plot(epsilon,col='black',/overplot,name='Generated Distribution',linestyle='--')
  leg = legend(target=[p0,p3],/auto_text_color,position=[0.9,0.8])
  
  title='Mean Temperature from 1,000 & 10,000 Waves'
  p0 = plot(mean[1,*,p],xtitle='Radial Zone',ytitle='Temperature (eV)',name='Mean of 1000 Passes',title=title,col='red')
  p3 = plot(T_atom,col='black',/overplot,name='Generated Distribution',linestyle='--')
  leg = legend(target=[p0,p3],/auto_text_color,position=[0.8,0.8])
  
  title='Mean Density from 1,000 & 10,000 Waves'
  p0 = plot(mean[2,*,p],xtitle='Radial Zone',ytitle='Electron density $(m^{-3})$',name='Mean of 1000 Passes',title=title,col='red')
  p3 = plot(n_e,col='black',/overplot,name='Generated Distribution',linestyle='--')
  leg = legend(target=[p0,p3],/auto_text_color,position=[0.8,0.8])


  epsilon_error = error(mean[0,*,p],epsilon)
  temp_error = error(mean[1,*,p],T_atom)
  density_error = error(mean[2,*,p],n_e)
  
  TempErrorPlot = plot(temp_error, xtitle ='Radial Zone',ytitle='Percent Error',title='Temperature Error')

  DensityErrorPlot = plot(density_error, xtitle='Radial Zone',ytitle='Percent Error',title='Density Error')

  EmmisivityErrorPlot = plot(epsilon_error, xtitle='Radial Zone',ytitle='Percent Error',title='Emissivity Error')

stop

end