pro correlation_fit

shot_input = 13531
channel_line = 13

xcorr = ptrarr(4,4)

corr_value = dblarr(4,4)
corr_value_std = dblarr(4,4)
corr_value_en = dblarr(4,4)
corr_value_en_std = dblarr(4,4)

position_value = dblarr(4,4)

for i = 0L, 3L do begin
  for j = 0L, 3L do begin
    if (channel_line GE 10) then begin
      ch1 = strjoin([string(i+1,FORMAT='(I01)'), '-', string(channel_line,FORMAT='(I02)')])
      ch2 = strjoin([string(j+1,FORMAT='(I01)'), '-', string(channel_line,FORMAT='(I02)')])
    endif else begin
      ch1 = strjoin([string(i+1,FORMAT='(I01)'), '-', string(channel_line,FORMAT='(I01)')])
      ch2 = strjoin([string(j+1,FORMAT='(I01)'), '-', string(channel_line,FORMAT='(I01)')])
    endelse
    xcorr[i,j] = ptr_new(jw_bes_xcorr(shot_input,ch1,ch2,trange=[2.0,2.05],freq_filter=[0.005, 1.0],subwindow_npts=1024))
    
    corr_value[i,j] = (*xcorr[i,j]).corr_value[0]
    corr_value_std[i,j] = (*xcorr[i,j]).corr_std[0] ;/sqrt((*xcorr[i,j]).subwindow_number)
    corr_value_en[i,j] = (*xcorr[i,j]).corr_value[1]
    corr_value_en_std[i,j] = (*xcorr[i,j]).corr_std[1] ;/sqrt((*xcorr[i,j]).subwindow_number)
    
    position_value[i,j] = j-i
  endfor
endfor

ycplot,position_value[0,*] ,corr_value[0,*], error=corr_value_std[0,*], out_base_id = oid
ycplot,position_value[0,*] ,corr_value_en[0,*], error=corr_value_en_std[0,*], oplot_id = oid
for i=1L, 3L do begin
  ycplot,position_value[i,*] ,corr_value[i,*], error=corr_value_std[i,*], oplot_id = oid
  ycplot,position_value[i,*] ,corr_value_en[i,*], error=corr_value_en_std[i,*], oplot_id = oid
endfor

corr_value_sum = dblarr(4*2-1)
corr_value_en_sum = dblarr(4*2-1)


asdf = dblarr(4*2-1)
for i=0, 3L do begin
  for j=0, 3L do begin
    corr_value_sum[3+i-j] = corr_value_sum[3+i-j]+corr_value[i,j]/(4-abs(i-j))
    corr_value_en_sum[3+i-j] = corr_value_en_sum[3+i-j]+corr_value_en[i,j]/(4-abs(i-j))
  endfor
endfor

ycplot, corr_value_sum, out_base_id = oid
ycplot, corr_value_en_sum, oplot_id = oid


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

ycplot, corr_value_norm_sum, error = sqrt(corr_var_norm_sum),out_base_id = oid
ycplot, corr_value_en_norm_sum, error = sqrt(corr_var_en_norm_sum), oplot_id = oid

SAVE, /VARIABLES, FILENAME = '/home/ijwkim/IDL/BES_data_analysis/shot13790.sav'


;ycplot,[0:3:1] ,corr_value[0,*], error=corr_value_std[0,*], out_base_id = oid
;ycplot,[0:3:1] ,corr_value_en[0,*], error=corr_value_en_std[0,*], oplot_id = oid
;ycplot,[-1:2:1] ,corr_value[1,*], error=corr_value_std[1,*], oplot_id = oid
;ycplot,[-1:2:1] ,corr_value_en[1,*], error=corr_value_en_std[1,*], oplot_id = oid
;ycplot,[-2:1:1] ,corr_value[2,*], error=corr_value_std[2,*], oplot_id = oid
;ycplot,[-2:1:1] ,corr_value_en[2,*], error=corr_value_en_std[2,*], oplot_id = oid
;ycplot,[-3:0:1] ,corr_value[3,*], error=corr_value_std[3,*], oplot_id = oid
;ycplot,[-3:0:1] ,corr_value_en[3,*], error=corr_value_en_std[3,*], oplot_id = oid

stop


end