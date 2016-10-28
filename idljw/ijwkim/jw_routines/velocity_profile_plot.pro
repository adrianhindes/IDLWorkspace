pro velocity_profile_plot
  t = 5
  cctd_vel = dblarr(4)
  for i = 0L, 4-1 do begin
     cctd_vel[i] = (*cctd_result[i]).velocity[t]
  endfor
  
  cctd_corr = dblarr(4)
  for i = 0L, 4-1 do begin
     cctd_corr[i] = (*cctd_result[i]).max_envel[t]
  endfor

  ycplot, position, cctd_vel, title = strjoin([string((*cctd_result[0]).tvector[t],format='(d0.6)') , ' sec']), out_base_id = oid
  
  ycplot, eb.position[*,t], eb.velocity[*,t], oplot_id = oid; , title = strjoin([string(eb.time_vector[t],format='(d0.6)') , ' sec'])
  
  ycplot, position, cctd_corr

end