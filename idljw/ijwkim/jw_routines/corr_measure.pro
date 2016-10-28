
function corr_measure, shot, ch, ch_array = ch_array,$
 trange=trange, freq_filter = freq_filter, subwindow_npts = subwindow_npts, plot=plot
 

  default, subwindow_npts, 1024L
  default, freq_filter, [0.01, 1.0]
  
  xcorr = ptrarr(4,4)

  corr_value = dblarr(4,4)
  corr_value_std = dblarr(4,4)
  corr_value_en = dblarr(4,4)
  corr_value_en_std = dblarr(4,4)

  position_value = dblarr(4,4)
  shot_number = shot

  if KEYWORD_SET(ch_array) then begin
    for i = 0L, 3L do begin
      for j = 0L, 3L do begin
        if (ch GE 10) then begin
          ch1 = strjoin([string(i+1,FORMAT='(I01)'), '-', string(ch,FORMAT='(I02)')])
          ch2 = strjoin([string(j+1,FORMAT='(I01)'), '-', string(ch,FORMAT='(I02)')])
        endif else begin
          ch1 = strjoin([string(i+1,FORMAT='(I01)'), '-', string(ch,FORMAT='(I01)')])
          ch2 = strjoin([string(j+1,FORMAT='(I01)'), '-', string(ch,FORMAT='(I01)')])
        endelse
        
        xcorr[i,j] = ptr_new(jw_bes_xcorr(shot_number,ch1,ch2,ch1_array=ch_array[i,*],ch2_array=ch_array[j,*],freq_filter=freq_filter,subwindow_npts=subwindow_npts))

        corr_value[i,j] = (*xcorr[i,j]).corr_value[0]
        corr_value_std[i,j] = (*xcorr[i,j]).corr_std[0] ;/sqrt((*xcorr[i,j]).subwindow_number)
        corr_value_en[i,j] = (*xcorr[i,j]).corr_value[1]
        corr_value_en_std[i,j] = (*xcorr[i,j]).corr_std[1] ;/sqrt((*xcorr[i,j]).subwindow_number)

        position_value[i,j] = j-i
      endfor
    endfor
  endif else begin
    for i = 0L, 3L do begin
      for j = 0L, 3L do begin
        ch1 = strjoin([string(i+1,FORMAT='(I01)'), '-', string(ch,FORMAT='(I01)')])
        ch2 = strjoin([string(j+1,FORMAT='(I01)'), '-', string(ch,FORMAT='(I01)')])
        xcorr[i,j] = ptr_new(jw_bes_xcorr(shot_number,ch1,ch2,trange=trange,freq_filter=freq_filter,subwindow_npts=subwindow_npts))

        corr_value[i,j] = (*xcorr[i,j]).corr_value[0]
        corr_value_std[i,j] = (*xcorr[i,j]).corr_std[0] ;/sqrt((*xcorr[i,j]).subwindow_number)
        corr_value_en[i,j] = (*xcorr[i,j]).corr_value[1]
        corr_value_en_std[i,j] = (*xcorr[i,j]).corr_std[1] ;/sqrt((*xcorr[i,j]).subwindow_number)

        position_value[i,j] = j-i
      endfor
    endfor
  endelse
  

;  ycplot,position_value[0,*] ,corr_value[0,*], error=corr_value_std[0,*], out_base_id = oid
;  ycplot,position_value[0,*] ,corr_value_en[0,*], error=corr_value_en_std[0,*], oplot_id = oid
;  for i=1L, 3L do begin
;    ycplot,position_value[i,*] ,corr_value[i,*], error=corr_value_std[i,*], oplot_id = oid
;    ycplot,position_value[i,*] ,corr_value_en[i,*], error=corr_value_en_std[i,*], oplot_id = oid
;  endfor

  corr_value_sum = dblarr(4*2-1)
  corr_value_en_sum = dblarr(4*2-1)


  asdf = dblarr(4*2-1)
  for i=0, 3L do begin
    for j=0, 3L do begin
      corr_value_sum[3+i-j] = corr_value_sum[3+i-j]+corr_value[i,j]/(4-abs(i-j))
      corr_value_en_sum[3+i-j] = corr_value_en_sum[3+i-j]+corr_value_en[i,j]/(4-abs(i-j))
    endfor
  endfor

;  ycplot, corr_value_sum, out_base_id = oid
;  ycplot, corr_value_en_sum, oplot_id = oid


  corr_value_norm_sum = dblarr(4*2-1)
  corr_value_en_norm_sum = dblarr(4*2-1)
  corr_var_norm_sum = dblarr(4*2-1)
  corr_var_en_norm_sum = dblarr(4*2-1)

  for i=0, 3L do begin
    for j=0, 3L do begin
      corr_value_norm_sum[3+i-j] = corr_value_norm_sum[3+i-j]+corr_value[i,j]/(4-abs(i-j))
      corr_var_norm_sum[3+i-j] = corr_var_norm_sum[3+i-j]+ (corr_value_std[i,j]/(4-abs(i-j)) )^2
      corr_value_en_norm_sum[3+i-j] = corr_value_en_norm_sum[3+i-j]+corr_value_en[i,j]/(4-abs(i-j))
      corr_var_en_norm_sum[3+i-j] = corr_var_en_norm_sum[3+i-j]+ (corr_value_en_std[i,j]/(4-abs(i-j)) )^2
    endfor
  endfor

;  ycplot, corr_value_norm_sum, error = sqrt(corr_var_norm_sum),out_base_id = oid
;  ycplot, corr_value_en_norm_sum, error = sqrt(corr_var_en_norm_sum), oplot_id = oid
  
  subwin_number = (*xcorr[0,0]).subwindow_number

  position = bes_read_position(shot_number)
  distance = dblarr(3)
  for i = 0L, 2L do begin
    distance[i] = sqrt((position.data[i,ch-1,0]-position.data[i+1,ch-1,0])^2 + (position.data[i,ch-1,1]-position.data[i+1,ch-1,1])^2)
  endfor

  mean_distance = total(distance/3)*100 ;;cm

  ;ycplot,position_value[0,*]*mean_distance ,corr_value[0,*], error=corr_value_std[0,*]/sqrt(subwin_number), out_base_id = oid
;  ycplot,position_value[0,*]*mean_distance ,corr_value_en[0,*], error=corr_value_en_std[0,*]/sqrt(subwin_number), out_base_id = oid;oplot_id = oid
;  for i=1L, 3L do begin
    ;  ycplot,position_value[i,*]*mean_distance ,corr_value[i,*], error=corr_value_std[i,*]/sqrt(subwin_number), oplot_id = oid
;    ycplot,position_value[i,*]*mean_distance ,corr_value_en[i,*], error=corr_value_en_std[i,*]/sqrt(subwin_number), oplot_id = oid
;  endfor

  position_vector = mean_distance*[-3.0:3.0:1.0]
  ;ycplot, position_vector,corr_value_sum, out_base_id = oid
  ;ycplot, position_vector,corr_value_en_sum, oplot_id = oid

;  ycplot, position_vector, corr_value_norm_sum, error = sqrt(corr_var_norm_sum)/sqrt(subwin_number),out_base_id = oid
;  ycplot, position_vector, corr_value_en_norm_sum, error = sqrt(corr_var_en_norm_sum)/sqrt(subwin_number), out_base_id = oid

  expr = 'p[1]*exp(-x^2/p[0]^2)'
  start = [1.0, 0.5]
  rerr = corr_var_en_norm_sum/sqrt(subwin_number)
  result= mpfitexpr(expr,position_vector, corr_value_en_norm_sum,rerr, start)

  x = [-3.0*mean_distance:3.0*mean_distance:0.1]
;  ycplot,x, result[1]*exp(-x^2/result[0]^2), oplot_id = oid

  expr2 = 'p[1]*exp(-abs(x)/p[0])'
  start = [1.0, 0.5]
  rerr = corr_var_en_norm_sum/sqrt(subwin_number)
  result2= mpfitexpr(expr2, position_vector, corr_value_en_norm_sum,rerr, start)

  x = [-3.0*mean_distance:3.0*mean_distance:0.1]
  
  if KEYWORD_SET(plot) then begin
    ycplot, position_vector,corr_value_sum, out_base_id = oid1
    ycplot, position_vector,corr_value_en_sum, oplot_id = oid1

    ycplot, position_vector, corr_value_norm_sum, error = sqrt(corr_var_norm_sum)/sqrt(subwin_number),out_base_id = oid2
    ycplot, position_vector, corr_value_en_norm_sum, error = sqrt(corr_var_en_norm_sum)/sqrt(subwin_number), out_base_id = oid2
    ycplot,x, result[1]*exp(-x^2/result[0]^2), oplot_id = oid2
    ycplot,x, result2[1]*exp(-abs(x)/result2[0]), oplot_id = oid2
  endif
;  ycplot,x, result2[1]*exp(-abs(x)/result2[0]), oplot_id = oid

;  ycplot, x
  
  result = CREATE_STRUCT('position', position_vector, 'corr_value', corr_value_en_norm_sum,'corr_length_gauss',result[0], 'corr_length_exp',result2[0])
  return, result
end
