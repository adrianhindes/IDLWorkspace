pro practice222

restore, '/home/ijwkim/IDL/BES_data_analysis/shot9127.sav'

subwin_number = (*xcorr[0,0]).subwindow_number

position = bes_read_position(9127)
distance = dblarr(3)
for i = 0L, 2L do begin
  distance[i] = sqrt((position.data[i,0,0]-position.data[i+1,0,0])^2 + (position.data[i,0,1]-position.data[i+1,0,1])^2)
endfor

mean_distance = total(distance/3)*100 ;;cm

;ycplot,position_value[0,*]*mean_distance ,corr_value[0,*], error=corr_value_std[0,*]/sqrt(subwin_number), out_base_id = oid
ycplot,position_value[0,*]*mean_distance ,corr_value_en[0,*], error=corr_value_en_std[0,*]/sqrt(subwin_number), out_base_id = oid;oplot_id = oid
for i=1L, 3L do begin
;  ycplot,position_value[i,*]*mean_distance ,corr_value[i,*], error=corr_value_std[i,*]/sqrt(subwin_number), oplot_id = oid
  ycplot,position_value[i,*]*mean_distance ,corr_value_en[i,*], error=corr_value_en_std[i,*]/sqrt(subwin_number), oplot_id = oid
endfor

position_vector = mean_distance*[-3.0:3.0:1.0]
;ycplot, position_vector,corr_value_sum, out_base_id = oid
;ycplot, position_vector,corr_value_en_sum, oplot_id = oid

;ycplot, position_vector, corr_value_norm_sum, error = sqrt(corr_var_norm_sum)/sqrt(subwin_number),out_base_id = oid
ycplot, position_vector, corr_value_en_norm_sum, error = sqrt(corr_var_en_norm_sum)/sqrt(subwin_number), out_base_id = oid



expr = 'p[1]*exp(-x^2/4/p[0]^2)'
;expr = 'max(corr_value_en_norm_sum)*exp(-x^2/4/p[0]^2)'
start = [0.2, 1.0]
;start = 0.2
rerr = sqrt(corr_var_en_norm_sum)/sqrt(subwin_number)
result= mpfitexpr(expr,position_vector, corr_value_en_norm_sum,rerr, start)

x = [-3.0*mean_distance:3.0*mean_distance:0.1]
ycplot,x, result[1]*exp(-x^2/4/result[0]^2), oplot_id = oid
fitted_points = result[1]*exp(-x^2/4/result[0]^2)

SAVE, position_vector, corr_value_en_norm_sum, rerr ,x, fitted_points, FILENAME = '/home/ijwkim/IDL/BES_data_analysis/shot9133_4points_fit.sav'

;ycplot,x, max(corr_value_en_norm_sum)*exp(-x^2/4/result^2), oplot_id = oid

print, abs(result[0])

expr2 = 'p[1]*exp(-abs(x)/2/p[0])'
start = [0.2, 1.0]
rerr = corr_var_en_norm_sum/sqrt(subwin_number)
result2= mpfitexpr(expr2, position_vector, corr_value_en_norm_sum,rerr, start)

x = [-3.0*mean_distance:3.0*mean_distance:0.1]
;ycplot,x, result2[1]*exp(-abs(x)/2/result2[0]), oplot_id = oid

print, abs(result2[0])

;for i=0L, 3L do begin
;  ;  ycplot,position_value[i,*]*mean_distance ,corr_value[i,*], error=corr_value_std[i,*]/sqrt(subwin_number), oplot_id = oid
;  ycplot,position_value[i,*]*mean_distance ,corr_value_en[i,*], error=corr_value_en_std[i,*]/sqrt(subwin_number), out_base_id = oid
;  start = [1.0, 1.0]
;  rerr = corr_value_en_std[i,*]/sqrt(subwin_number)
;  result= mpfitexpr(expr,position_value[i,*]*mean_distance, corr_value_en,rerr, start)
;  x = [position_value[i,0]*mean_distance:position_value[i,3]*mean_distance:0.01]
;  ycplot,x, result[1]*exp(-x^2/4/result[0]^2), oplot_id = oid
;  
;  result2= mpfitexpr(expr2, position_vector, corr_value_en_norm_sum,rerr, start)
;  x = [position_value[i,0]*mean_distance:position_value[i,3]*mean_distance:0.01]
;  ycplot,x, result2[1]*exp(-abs(x)/2/result2[0]), oplot_id = oid
;endfor


monte_N = 10000
monte_length = dblarr(6,monte_N)
monte_distance = dblarr(6)
case_i=0
for i=0L, 2L do begin
  for j=i+1L, 3L do begin
    rand_a = randomn(seed,monte_N)*corr_value_en_std[i,i]/sqrt(subwin_number)+corr_value_en[i,i]
    rand_b = randomn(seed,monte_N)*corr_value_en_std[i,j]/sqrt(subwin_number)+corr_value_en[i,j]
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

monte_length_mean = dblarr(6)
monte_length_var = dblarr(6)
for i=0L,5L do begin
  monte_length_mean[i] = mean(monte_length[i,where(monte_length(i,*) LT 10000)])
;  monte_length_mean[i] = mean(monte_length[i,*])
  monte_length_var[i] = variance(monte_length[i,where(monte_length(i,*) LT 10000)])
;  monte_length_var[i] = variance(monte_length[i,*])
endfor

ycplot, monte_distance/abs(result[0]), monte_length_mean/abs(result[0]), error = sqrt(monte_length_var)/abs(result[0])


stop

end