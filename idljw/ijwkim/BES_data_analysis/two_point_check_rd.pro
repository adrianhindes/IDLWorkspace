;; read data and two-point check
pro two_point_check_rd
;  restore, '/home/ijwkim/IDL/BES_data_analysis/shot9127_2point_10.sav'
  restore, '/home/ijwkim/IDL/BES_data_save/shot9133_2point_35_65_0.025.sav'

  subwin_number = (*xcorr[0,0,0]).subwindow_number

  position = bes_read_position(shot_input)
  probe_distance = dblarr(3)
  for i = 0L, 2L do begin
    probe_distance[i] = sqrt((position.data[i,0,0]-position.data[i+1,0,0])^2 + (position.data[i,0,1]-position.data[i+1,0,1])^2)
  endfor

  mean_distance = total(probe_distance/3)*100 ;;cm

  position_vector = mean_distance*[-3.0:3.0:1.0]

  ycplot, position_vector, corr_value_en_norm_sum, error = sqrt(corr_var_en_norm_sum)/sqrt(subwin_number), out_base_id = oid

  monte_length_mean_norm = dblarr(window_number,6)
  monte_length_var_norm = dblarr(window_number,6)
  monte_distance_norm = dblarr(window_number,6)
  
  monte_length_mean_norm02 = dblarr(window_number,6)
  monte_length_var_norm02 = dblarr(window_number,6)
  monte_distance_norm_two_points = dblarr(window_number,6)
  
  monte_length_mean = dblarr(window_number,6)
  monte_length_var = dblarr(window_number,6)
  monte_distance_02 = dblarr(window_number,6)
  
  for loop_i=0L, window_number-1L do begin
    subwin_number = (*xcorr[loop_i,0,0]).subwindow_number
    expr = 'p[1]*exp(-x^2/2/p[0]^2)'
    start = [1.0, 1.0]
    rerr = corr_var_en_norm_sum[loop_i,*]/sqrt(subwin_number)
    result= mpfitexpr(expr,position_vector, corr_value_en_norm_sum[loop_i,*],rerr, start)

    expr2 = 'p[1]*exp(-abs(x)/2/p[0])'
    start = [0.2, 1.0]
    rerr = corr_var_en_norm_sum[loop_i,*]/sqrt(subwin_number)
    result2= mpfitexpr(expr2, position_vector, corr_value_en_norm_sum[loop_i,*],rerr, start)

    print, abs(result2[0])

    monte_N = 10000
    monte_length = dblarr(6,monte_N)
    monte_distance = dblarr(6)
    case_i=0
    for i=0L, 2L do begin
      for j=i+1L, 3L do begin
        rand_a = randomn(seed,monte_N)*corr_value_en_std[loop_i,i,i]/sqrt(subwin_number)+corr_value_en[loop_i,i,i]
        rand_b = randomn(seed,monte_N)*corr_value_en_std[loop_i,i,j]/sqrt(subwin_number)+corr_value_en[loop_i,i,j]
        for monte_i = 0L,monte_N-1L do begin
          if (rand_a[monte_i] GT rand_b[monte_i]) then begin
            if (rand_b[monte_i] LT 0) then begin
              rand_b[monte_i] = 0;
            endif
            monte_length[case_i,monte_i] = mean_distance*abs(position_value[i,j]-position_value[i,i])/sqrt(2)*sqrt(-1/alog(rand_b[monte_i]/rand_a[monte_i]))
          endif else begin
            monte_length[case_i,monte_i] = 10000
          endelse
        endfor
        monte_distance[case_i] = mean_distance*abs(position_value[i,j]-position_value[i,i])
        case_i = case_i+1
      endfor
    endfor

    for i=0L,case_i-1 do begin
      monte_length_mean_norm[loop_i,i] = mean(monte_length[i,where(monte_length(i,*) LT 10000)])/abs(result[0])
      ;  monte_length_mean[i] = mean(monte_length[i,*])
      monte_length_var_norm[loop_i,i] = variance(monte_length[i,where(monte_length(i,*) LT 10000)])/abs(result[0])
      ;  monte_length_var[i] = variance(monte_length[i,*])
      
      monte_length_mean_norm02[loop_i,i] = mean(monte_length[i,where(monte_length(i,*) LT 10000)])/mean(monte_length[i,where(monte_length(i,*) LT 10000)])
      monte_length_var_norm02[loop_i,i] = variance(monte_length[i,where(monte_length(i,*) LT 10000)])/mean(monte_length[i,where(monte_length(i,*) LT 10000)])
      monte_distance_norm_two_points[loop_i,i] = monte_distance[i]/mean(monte_length[i,where(monte_length(i,*) LT 10000)])
      
      monte_length_mean[loop_i,i] = mean(monte_length[i,where(monte_length(i,*) LT 10000)])
      monte_length_var[loop_i,i] = variance(monte_length[i,where(monte_length(i,*) LT 10000)])
      monte_distance_02[loop_i,i] = monte_distance[i]
    endfor
    monte_distance_norm[loop_i,*] = monte_distance/abs(result[0])

  endfor

  distance_norm = reform(monte_distance_norm,[1,window_number*6])
  length_mean_norm = reform(monte_length_mean_norm,[1,window_number*6])
  length_std_norm = reform(sqrt(monte_length_var_norm),[1,window_number*6])
  
  index_number = floor(N_ELEMENTS(distance_norm)/5)
  ycplot, distance_norm([1:index_number]*5), length_mean_norm([1:index_number]*5), $
     error = length_std_norm([1:index_number]*5), out_base_id = oid
 
 ;;;;divide by itself    

  distance_norm02 = reform(monte_distance_norm_two_points,[1,window_number*6])
  length_mean_norm02 = reform(monte_length_mean_norm02,[1,window_number*6])
  length_std_norm02 = reform(sqrt(monte_length_var_norm02),[1,window_number*6])

  index_number = floor(N_ELEMENTS(distance_norm02)/5)
  ycplot, distance_norm02([1:index_number]*5), length_mean_norm02([1:index_number]*5), $
    error = length_std_norm02([1:index_number]*5), out_base_id = oid2
    
  index_number = floor(N_ELEMENTS(distance_norm02)/5)
  ycplot, distance_norm02([1:index_number]*5), length_mean_norm([1:index_number]*5), $
     error = length_std_norm([1:index_number]*5), out_base_id = oid3
     
 ;;;;;;;;;; unnormalized plot
; y = cgDemoData(17)
; s = N_Elements(y)
; x = Indgen(s)
; colors = Round(cgScaleVector(Findgen(s), 0, 255))
; cgPlot, x, y, /NoData, Color='Charcoal', Background='ivory'
; cgLoadCT, 34
; FOR j=0,s-2 DO cgPlotS, [x[j], x[j+1]], [y[j], y[j+1]], Color=StrTrim(colors[j],2), Thick=2
; FOR j=0,s-1 DO cgPlotS, x[j], y[j], PSym=2, , Color=StrTrim(colors[j],2)
 

  distance_02 = reform(monte_distance_02,[1,window_number*6])
  length_mean = reform(monte_length_mean,[1,window_number*6])
  length_std = reform(sqrt(monte_length_var),[1,window_number*6])
  
  stop
  
 WINDOW, 2
 cgPlot, distance_norm02, length_mean, Color='Charcoal', Background='ivory', xrange=[0,4], err_yhigh=length_std, err_ylow=length_std
 cgLoadCT, 34
 colors = round(cgScaleVector(distance_norm,0,255))
 a = size(distance_norm02,/dimension)
 cgPlots, distance_norm02, length_mean, PSym=2, Color=StrTrim(colors)
 
 
; show_number = 1
; index_number = floor(N_ELEMENTS(distance_02)/show_number)
; ycplot, distance_norm02([1:index_number]*show_number), length_mean([1:index_number]*show_number), $
;   error = length_std([1:index_number]*show_number), out_base_id = oid4
 
 
 ;;;;;;
     
  two_point_case = ptrarr(3)
  two_point_case[0] = ptr_new(CREATE_STRUCT('distance_norm', distance_norm, 'length_mean_norm', length_mean_norm, $
    'length_std_norm', length_std_norm))
    
  two_point_case_02 = ptrarr(3)
  two_point_case_02[0] = ptr_new(CREATE_STRUCT('distance_norm', distance_norm02, 'length_mean_norm', length_mean_norm02, $
    'length_std_norm', length_std_norm02))
;  stop
  
;  restore, '/home/ijwkim/IDL/BES_data_analysis/shot9127_2point_08.sav'
  restore, '/home/ijwkim/IDL/BES_data_save/shot9133_2point_35_65_0.05.sav'
  subwin_number = (*xcorr[0,0,0]).subwindow_number

  position = bes_read_position(shot_input)
  probe_distance = dblarr(3)
  for i = 0L, 2L do begin
    probe_distance[i] = sqrt((position.data[i,0,0]-position.data[i+1,0,0])^2 + (position.data[i,0,1]-position.data[i+1,0,1])^2)
  endfor

  mean_distance = total(probe_distance/3)*100 ;;cm

  position_vector = mean_distance*[-3.0:3.0:1.0]

  ycplot, position_vector, corr_value_en_norm_sum, error = sqrt(corr_var_en_norm_sum)/sqrt(subwin_number), out_base_id = oid

  monte_length_mean_norm = dblarr(window_number,6)
  monte_length_var_norm = dblarr(window_number,6)
  monte_distance_norm = dblarr(window_number,6)
  
  monte_length_mean_norm02 = dblarr(window_number,6)
  monte_length_var_norm02 = dblarr(window_number,6)
  monte_distance_norm_two_points = dblarr(window_number,6)
  
  monte_length_mean = dblarr(window_number,6)
  monte_length_var = dblarr(window_number,6)
  monte_distance_02 = dblarr(window_number,6)
  
  for loop_i=0L, window_number-1L do begin
    subwin_number = (*xcorr[loop_i,0,0]).subwindow_number
    expr = 'p[1]*exp(-x^2/2/p[0]^2)'
    start = [1.0, 1.0]
    rerr = corr_var_en_norm_sum[loop_i,*]/sqrt(subwin_number)
    result= mpfitexpr(expr,position_vector, corr_value_en_norm_sum[loop_i,*],rerr, start)

    expr2 = 'p[1]*exp(-abs(x)/2/p[0])'
    start = [0.2, 1.0]
    rerr = corr_var_en_norm_sum[loop_i,*]/sqrt(subwin_number)
    result2= mpfitexpr(expr2, position_vector, corr_value_en_norm_sum[loop_i,*],rerr, start)

    print, abs(result2[0])

    monte_N = 10000
    monte_length = dblarr(6,monte_N)
    monte_distance = dblarr(6)
    case_i=0
    for i=0L, 2L do begin
      for j=i+1L, 3L do begin
        rand_a = randomn(seed,monte_N)*corr_value_en_std[loop_i,i,i]/sqrt(subwin_number)+corr_value_en[loop_i,i,i]
        rand_b = randomn(seed,monte_N)*corr_value_en_std[loop_i,i,j]/sqrt(subwin_number)+corr_value_en[loop_i,i,j]
        for monte_i = 0L,monte_N-1L do begin
          if (rand_a[monte_i] GT rand_b[monte_i]) then begin
            if (rand_b[monte_i] LT 0) then begin
              rand_b[monte_i] = 0;
            endif
            monte_length[case_i,monte_i] = mean_distance*abs(position_value[i,j]-position_value[i,i])/sqrt(2)*sqrt(-1/alog(rand_b[monte_i]/rand_a[monte_i]))
          endif else begin
            monte_length[case_i,monte_i] = 10000
          endelse
        endfor
        monte_distance[case_i] = mean_distance*abs(position_value[i,j]-position_value[i,i])
        case_i = case_i+1
      endfor
    endfor

    for i=0L,case_i-1 do begin
      monte_length_mean_norm[loop_i,i] = mean(monte_length[i,where(monte_length(i,*) LT 10000)])/abs(result[0])
      ;  monte_length_mean[i] = mean(monte_length[i,*])
      monte_length_var_norm[loop_i,i] = variance(monte_length[i,where(monte_length(i,*) LT 10000)])/abs(result[0])
      ;  monte_length_var[i] = variance(monte_length[i,*])
      
      monte_length_mean_norm02[loop_i,i] = mean(monte_length[i,where(monte_length(i,*) LT 10000)])/mean(monte_length[i,where(monte_length(i,*) LT 10000)])
      monte_length_var_norm02[loop_i,i] = variance(monte_length[i,where(monte_length(i,*) LT 10000)])/mean(monte_length[i,where(monte_length(i,*) LT 10000)])
      monte_distance_norm_two_points[loop_i,i] = monte_distance[i]/mean(monte_length[i,where(monte_length(i,*) LT 10000)])
      
      monte_length_mean[loop_i,i] = mean(monte_length[i,where(monte_length(i,*) LT 10000)])
      monte_length_var[loop_i,i] = variance(monte_length[i,where(monte_length(i,*) LT 10000)])
      monte_distance_02[loop_i,i] = monte_distance[i]      
    endfor
    monte_distance_norm[loop_i,*] = monte_distance/abs(result[0])

  endfor

  distance_norm = reform(monte_distance_norm,[1,window_number*6])
  length_mean_norm = reform(monte_length_mean_norm,[1,window_number*6])
  length_std_norm = reform(sqrt(monte_length_var_norm),[1,window_number*6])
  
  index_number = floor(N_ELEMENTS(distance_norm)/2)
  ycplot, distance_norm([1:index_number]*2), length_mean_norm([1:index_number]*2), error = length_std_norm([1:index_number]*2), oplot_id = oid
  
  ;;;;divide by itself

  distance_norm02 = reform(monte_distance_norm_two_points,[1,window_number*6])
  length_mean_norm02 = reform(monte_length_mean_norm02,[1,window_number*6])
  length_std_norm02 = reform(sqrt(monte_length_var_norm02),[1,window_number*6])

  index_number = floor(N_ELEMENTS(distance_norm02)/2)
  ycplot, distance_norm02([1:index_number]*2), length_mean_norm02([1:index_number]*2), $
    error = length_std_norm02([1:index_number]*2), oplot_id = oid2
    
  index_number = floor(N_ELEMENTS(distance_norm02)/2)
  ycplot, distance_norm02([1:index_number]*2), length_mean_norm([1:index_number]*2), $
    error = length_std_norm([1:index_number]*2), oplot_id = oid3
    
;;;;;;;;;; unnormalized plot

  distance_02 = reform(monte_distance_02,[1,window_number*6])
  length_mean = reform(monte_length_mean,[1,window_number*6])
  length_std = reform(sqrt(monte_length_var),[1,window_number*6])
 
  WINDOW, 1
  cgPlot, distance_norm02, length_mean, /Overplot , Color='Charcoal', Background='ivory', xrange=[0,4], err_yhigh=length_std, err_ylow=length_std 
  cgLoadCT, 34
  colors = round(cgScaleVector(distance_norm,0,255))
  a = size(distance_norm02,/dimension)
  cgPlots, distance_norm02, length_mean, PSym=2, Color=StrTrim(colors)

; show_number = 1
; index_number = floor(N_ELEMENTS(distance_02)/show_number)
; ycplot, distance_norm02([1:index_number]*show_number), length_mean([1:index_number]*show_number), $
;   error = length_std([1:index_number]*show_number), oplot_id = oid4

  ;;;;;;;;;;

  two_point_case[1] = ptr_new(CREATE_STRUCT('distance_norm', distance_norm, 'length_mean_norm', length_mean_norm, $
    'length_std_norm', length_std_norm))
    
  two_point_case_02[1] = ptr_new(CREATE_STRUCT('distance_norm', distance_norm02, 'length_mean_norm', length_mean_norm02, $
    'length_std_norm', length_std_norm02))

;  stop
  
;  restore, '/home/ijwkim/IDL/BES_data_analysis/shot9127_2point_07.sav'
  restore, '/home/ijwkim/IDL/BES_data_save/shot9133_2point_35_65_0.1.sav'
  subwin_number = (*xcorr[0,0,0]).subwindow_number

  position = bes_read_position(shot_input)
  probe_distance = dblarr(3)
  for i = 0L, 2L do begin
    probe_distance[i] = sqrt((position.data[i,0,0]-position.data[i+1,0,0])^2 + (position.data[i,0,1]-position.data[i+1,0,1])^2)
  endfor

  mean_distance = total(probe_distance/3)*100 ;;cm

  position_vector = mean_distance*[-3.0:3.0:1.0]

  ycplot, position_vector, corr_value_en_norm_sum, error = sqrt(corr_var_en_norm_sum)/sqrt(subwin_number), out_base_id = oid

  monte_length_mean_norm = dblarr(window_number,6)
  monte_length_var_norm = dblarr(window_number,6)
  monte_distance_norm = dblarr(window_number,6)
  
  monte_length_mean_norm02 = dblarr(window_number,6)
  monte_length_var_norm02 = dblarr(window_number,6)
  monte_distance_norm_two_points = dblarr(window_number,6)
  
  monte_length_mean = dblarr(window_number,6)
  monte_length_var = dblarr(window_number,6)
  monte_distance_02 = dblarr(window_number,6)
  
  for loop_i=0L, window_number-1L do begin
    subwin_number = (*xcorr[loop_i,0,0]).subwindow_number
    expr = 'p[1]*exp(-x^2/2/p[0]^2)'
    start = [1.0, 1.0]
    rerr = corr_var_en_norm_sum[loop_i,*]/sqrt(subwin_number)
    result= mpfitexpr(expr,position_vector, corr_value_en_norm_sum[loop_i,*],rerr, start)

    expr2 = 'p[1]*exp(-abs(x)/2/p[0])'
    start = [0.2, 1.0]
    rerr = corr_var_en_norm_sum[loop_i,*]/sqrt(subwin_number)
    result2= mpfitexpr(expr2, position_vector, corr_value_en_norm_sum[loop_i,*],rerr, start)

    print, abs(result2[0])

    monte_N = 10000
    monte_length = dblarr(6,monte_N)
    monte_distance = dblarr(6)
    case_i=0
    for i=0L, 2L do begin
      for j=i+1L, 3L do begin
        rand_a = randomn(seed,monte_N)*corr_value_en_std[loop_i,i,i]/sqrt(subwin_number)+corr_value_en[loop_i,i,i]
        rand_b = randomn(seed,monte_N)*corr_value_en_std[loop_i,i,j]/sqrt(subwin_number)+corr_value_en[loop_i,i,j]
        for monte_i = 0L,monte_N-1L do begin
          if (rand_a[monte_i] GT rand_b[monte_i]) then begin
            if (rand_b[monte_i] LT 0) then begin
              rand_b[monte_i] = 0;
            endif
            monte_length[case_i,monte_i] = mean_distance*abs(position_value[i,j]-position_value[i,i])/sqrt(2)*sqrt(-1/alog(rand_b[monte_i]/rand_a[monte_i]))
          endif else begin
            monte_length[case_i,monte_i] = 10000
          endelse
        endfor
        monte_distance[case_i] = mean_distance*abs(position_value[i,j]-position_value[i,i])
        case_i = case_i+1
      endfor
    endfor

    for i=0L,case_i-1 do begin
      monte_length_mean_norm[loop_i,i] = mean(monte_length[i,where(monte_length(i,*) LT 10000)])/abs(result[0])
      ;  monte_length_mean[i] = mean(monte_length[i,*])
      monte_length_var_norm[loop_i,i] = variance(monte_length[i,where(monte_length(i,*) LT 10000)])/abs(result[0])
      ;  monte_length_var[i] = variance(monte_length[i,*])
      
      monte_length_mean_norm02[loop_i,i] = mean(monte_length[i,where(monte_length(i,*) LT 10000)])/mean(monte_length[i,where(monte_length(i,*) LT 10000)])
      monte_length_var_norm02[loop_i,i] = variance(monte_length[i,where(monte_length(i,*) LT 10000)])/mean(monte_length[i,where(monte_length(i,*) LT 10000)])
      monte_distance_norm_two_points[loop_i,i] = monte_distance[i]/mean(monte_length[i,where(monte_length(i,*) LT 10000)])
      
      monte_length_mean[loop_i,i] = mean(monte_length[i,where(monte_length(i,*) LT 10000)])
      monte_length_var[loop_i,i] = variance(monte_length[i,where(monte_length(i,*) LT 10000)])
      monte_distance_02[loop_i,i] = monte_distance[i]
    endfor
    monte_distance_norm[loop_i,*] = monte_distance/abs(result[0])

  endfor

  distance_norm = reform(monte_distance_norm,[1,window_number*6])
  length_mean_norm = reform(monte_length_mean_norm,[1,window_number*6])
  length_std_norm = reform(sqrt(monte_length_var_norm),[1,window_number*6])
  
  index_number = floor(N_ELEMENTS(distance_norm))
  ycplot, distance_norm([1:index_number]), length_mean_norm([1:index_number]), error = length_std_norm([1:index_number]), oplot_id = oid
  
  ;;;;divide by itself

  distance_norm02 = reform(monte_distance_norm_two_points,[1,window_number*6])
  length_mean_norm02 = reform(monte_length_mean_norm02,[1,window_number*6])
  length_std_norm02 = reform(sqrt(monte_length_var_norm02),[1,window_number*6])

  index_number = floor(N_ELEMENTS(distance_norm02))
  ycplot, distance_norm02([1:index_number]), length_mean_norm02([1:index_number]), $
    error = length_std_norm02([1:index_number]), oplot_id = oid2
    
  index_number = floor(N_ELEMENTS(distance_norm02))
  ycplot, distance_norm02([1:index_number]), length_mean_norm([1:index_number]), $
    error = length_std_norm([1:index_number]), oplot_id = oid3
    
  ;;;;;;;;;; unnormalized plot

  distance_02 = reform(monte_distance_02,[1,window_number*6])
  length_mean = reform(monte_length_mean,[1,window_number*6])
  length_std = reform(sqrt(monte_length_var),[1,window_number*6])
  
  WINDOW, 2
  cgPlot, distance_norm02, length_mean, /Overplot, Color='Charcoal',Background='ivory', xrange=[0,4], err_yhigh=length_std, err_ylow=length_std
  cgLoadCT, 34
  colors = round(cgScaleVector(distance_norm,0,255))
  a = size(distance_norm02,/dimension)
  cgPlots, distance_norm02, length_mean, PSym=2, Color=StrTrim(colors)

; show_number = 1
; index_number = floor(N_ELEMENTS(distance_02)/show_number)
; ycplot, distance_norm02([1:index_number]*show_number), length_mean([1:index_number]*show_number), $
;   error = length_std([1:index_number]*show_number), oplot_id = oid4

  ;;;;;;;;;
  
  two_point_case[2] = ptr_new(CREATE_STRUCT('distance_norm', distance_norm, 'length_mean_norm', length_mean_norm, $
    'length_std_norm', length_std_norm))
    
  two_point_case_02[2] = ptr_new(CREATE_STRUCT('distance_norm', distance_norm02, 'length_mean_norm', length_mean_norm02, $
    'length_std_norm', length_std_norm02))
  
  position_case = dblarr(3,20)
  mean_case = dblarr(3,20)
  std_case = dblarr(3,2,20)
  for i = 0L, 20-1 do begin
    for j = 0L, 3-1 do begin
      avg_range = [i*0.2, (i+1)*0.2]
      position_case[j,i] = mean(avg_range)
      number_selected = where(((*two_point_case[j]).distance_norm GT avg_range[0])*((*two_point_case[j]).distance_norm LT avg_range[1]))
      if (number_selected[0] NE -1) then begin
        mean_selected = (*two_point_case[j]).length_mean_norm[where(((*two_point_case[j]).distance_norm GT avg_range[0]) $
          *((*two_point_case[j]).distance_norm LT avg_range[1]))]
        mean_case[j,i] = mean(mean_selected)
        std_selected = (*two_point_case[j]).length_std_norm[where(((*two_point_case[j]).distance_norm GT avg_range[0]) $
          *((*two_point_case[j]).distance_norm LT avg_range[1]))]
        std_case[j,0,i] = sqrt(mean(std_selected^2))
        std_case[j,1,i] = sqrt(variance((*two_point_case[j]).distance_norm[where(((*two_point_case[j]).distance_norm GT avg_range[0]) $
          *((*two_point_case[j]).distance_norm LT avg_range[1]))]))
      endif else begin
        mean_case[j,i] = 0
        std_case[j,0,i] = 0
      endelse
    endfor
  endfor
  
  ycplot, position_case[0,*], mean_case[0,*], error = std_case[0,0,*], out_base_id = oid
  ycplot, position_case[1,*], mean_case[1,*], error = std_case[1,0,*], oplot_id = oid
  ycplot, position_case[2,*], mean_case[2,*], error = std_case[2,0,*], oplot_id = oid
  
  stop
  
  two_point_01 = create_struct('distance_norm',(*two_point_case[0]).distance_norm,'length_mean_norm', $
     (*two_point_case[0]).length_mean_norm,'length_std_norm',(*two_point_case[0]).length_std_norm)
  two_point_02 = create_struct('distance_norm',(*two_point_case[1]).distance_norm,'length_mean_norm', $
     (*two_point_case[1]).length_mean_norm,'length_std_norm',(*two_point_case[1]).length_std_norm)
  two_point_03 = create_struct('distance_norm',(*two_point_case[2]).distance_norm,'length_mean_norm', $
     (*two_point_case[2]).length_mean_norm,'length_std_norm',(*two_point_case[2]).length_std_norm)
     
  two_point_by_two_point_01 = create_struct('distance_norm',(*two_point_case_02[0]).distance_norm,'length_mean_norm', $
     (*two_point_case_02[0]).length_mean_norm,'length_std_norm',(*two_point_case_02[0]).length_std_norm)
  two_point_by_two_point_02 = create_struct('distance_norm',(*two_point_case_02[1]).distance_norm,'length_mean_norm', $
     (*two_point_case_02[1]).length_mean_norm,'length_std_norm',(*two_point_case_02[1]).length_std_norm)
  two_point_by_two_point_03 = create_struct('distance_norm',(*two_point_case_02[2]).distance_norm,'length_mean_norm', $
     (*two_point_case_02[2]).length_mean_norm,'length_std_norm',(*two_point_case_02[2]).length_std_norm)
     
  SAVE, two_point_01, two_point_02, two_point_03, two_point_by_two_point_01, two_point_by_two_point_02, two_point_by_two_point_03, FILENAME = '/home/ijwkim/IDL/BES_data_analysis/shot9133_35_65_0.1_IDLtoMAT.sav'
  
end
  