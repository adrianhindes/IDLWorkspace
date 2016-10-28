pro two_point_check

  shot_input = 11443
  channel_line = 13
  total_trange = [1.6D, 5.0D]
  trange_delta = 0.1D
  window_number=floor((total_trange[1]-total_trange[0])/trange_delta)

  xcorr = ptrarr(window_number,4,4)

  corr_value = dblarr(window_number,4,4)
  corr_value_std = dblarr(window_number,4,4)
  corr_value_en = dblarr(window_number,4,4)
  corr_value_en_std = dblarr(window_number,4,4)

  position_value = dblarr(window_number,4,4)

  for loop_i = 0L, window_number-1L do begin
    for i = 0L, 3L do begin
      for j = 0L, 3L do begin
        if (channel_line GE 10) then begin
          ch1 = strjoin([string(i+1,FORMAT='(I01)'), '-', string(channel_line,FORMAT='(I02)')])
          ch2 = strjoin([string(j+1,FORMAT='(I01)'), '-', string(channel_line,FORMAT='(I02)')])
        endif else begin
          ch1 = strjoin([string(i+1,FORMAT='(I01)'), '-', string(channel_line,FORMAT='(I01)')])
          ch2 = strjoin([string(j+1,FORMAT='(I01)'), '-', string(channel_line,FORMAT='(I01)')])
        endelse

        xcorr[loop_i,i,j] = ptr_new(jw_bes_xcorr(shot_input,ch1,ch2,trange=[total_trange[0]+trange_delta*loop_i,total_trange[0]+trange_delta*(loop_i+1)],freq_filter=[0.01, 1.0],subwindow_npts=512))
  
        corr_value[loop_i,i,j] = (*xcorr[loop_i,i,j]).corr_value[0]
        corr_value_std[loop_i,i,j] = (*xcorr[loop_i,i,j]).corr_std[0] ;/sqrt((*xcorr[i,j]).subwindow_number)
        corr_value_en[loop_i,i,j] = (*xcorr[loop_i,i,j]).corr_value[1]
        corr_value_en_std[loop_i,i,j] = (*xcorr[loop_i,i,j]).corr_std[1] ;/sqrt((*xcorr[i,j]).subwindow_number)
  
        position_value[loop_i,i,j] = j-i
      endfor
    endfor
    print, 'loop_i  :  ', loop_i
  endfor

  corr_value_sum = dblarr(window_number,4*2-1)
  corr_value_en_sum = dblarr(window_number,4*2-1)


  asdf = dblarr(4*2-1)
  for loop_i=0L, window_number-1L do begin
    for i=0, 3L do begin
      for j=0, 3L do begin
        corr_value_sum[loop_i,3+i-j] = corr_value_sum[loop_i,3+i-j]+corr_value[loop_i,i,j]/(4-abs(i-j))
        corr_value_en_sum[loop_i,3+i-j] = corr_value_en_sum[loop_i,3+i-j]+corr_value_en[loop_i,i,j]/(4-abs(i-j))
      endfor
    endfor
  endfor


  ycplot, corr_value_sum, out_base_id = oid
  ycplot, corr_value_en_sum, oplot_id = oid


  corr_value_norm_sum = dblarr(window_number,4*2-1)
  corr_value_en_norm_sum = dblarr(window_number,4*2-1)
  corr_var_norm_sum = dblarr(window_number,4*2-1)
  corr_var_en_norm_sum = dblarr(window_number,4*2-1)

  for loop_i=0L,window_number-1L do begin
    for i=0, 3L do begin
      for j=0, 3L do begin
        corr_value_norm_sum[loop_i,3+i-j] = corr_value_norm_sum[loop_i,3+i-j]+corr_value[loop_i,i,j]/(4-abs(i-j))
        corr_var_norm_sum[loop_i,3+i-j] = corr_var_norm_sum[loop_i,3+i-j]+ (corr_value_std[loop_i,i,j]/(4-abs(i-j)) )^2
        corr_value_en_norm_sum[loop_i,3+i-j] = corr_value_en_norm_sum[loop_i,3+i-j]+corr_value_en[loop_i,i,j]/(4-abs(i-j))
        corr_var_en_norm_sum[loop_i,3+i-j] = corr_var_en_norm_sum[loop_i,3+i-j]+ (corr_value_en_std[loop_i,i,j]/(4-abs(i-j)) )^2
      endfor
    endfor
  endfor

  SAVE, /VARIABLES, FILENAME = '/home/ijwkim/IDL/BES_data_analysis/shot11443_2point_16_50_0.1.sav'
  
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
  for loop_i=0L, window_number-1L do begin
    subwin_number = (*xcorr[loop_i,0,0]).subwindow_number
    expr = 'p[1]*exp(-x^2/4/p[0]^2)'
    start = [0.2, 1.0]
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
            monte_length[case_i,monte_i] = mean_distance*abs(position_value[i,j]-position_value[i,i])/2*sqrt(-1/alog(rand_b[monte_i]/rand_a[monte_i]))
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
    endfor
    monte_distance_norm[loop_i,*] = monte_distance/abs(result[0])

  endfor

  distance_norm = reform(monte_distance_norm,[1,window_number*6])
  length_mean_norm = reform(monte_length_mean_norm,[1,window_number*6])
  length_std_norm = reform(sqrt(monte_length_var_norm),[1,window_number*6])
  ycplot, distance_norm, length_mean_norm, error = length_std_norm
  
  stop


end