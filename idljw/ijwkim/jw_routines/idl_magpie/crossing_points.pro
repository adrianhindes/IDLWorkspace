pro crossing_points
  points_num = 36
  degree = dblarr(36)
  rot_radius = dblarr(36)
  rot_degree = dblarr(36)
  rot_x = dblarr(36)
  rot_y = dblarr(36)
  radius = 2.85
  
  rotating_probe = ptrarr(36)
  for i = 0, points_num-1 do begin
    shot_number = i*3+529
;    rotating_probe[i] = ptr_new(phys_quantity(shot_number))
    degree[i] = 270.-10.*i
    rot_x[i] = radius*cos((180.-degree[i])*!pi/180.)
    rot_y[i] = radius*sin((180.-degree[i])*!pi/180.)+3
;    isat_rot_location[i] = sqrt(rot_x[i]^2.0+rot_y[i]^2.0)
;    isat_rot_degree[i] = atan( rot_x[i]/(radius*sin((180.-degree[i])*!pi/180.)+3) ) + !pi/2 
  endfor
  rot_radius = sqrt(rot_x^2.0+rot_y^2.0)
  rot_degree = atan(rot_x/rot_y)+!pi/2.
  
  ycplot, rot_x, rot_y
  
  a = magpie_get_points(radius = 0.05)
  ycplot, rot_radius*cos(rot_degree), rot_radius*sin(rot_degree), out_base_id = oid
  ycplot, 5.*cos(findgen(360)*!dtor), 5.*sin(findgen(360)*!dtor), oplot_id = oid
  ycplot, a.x*100., a.y*100., oplot_id = oid
  
  print, atan(a.y/a.x)*180./!pi
  
end