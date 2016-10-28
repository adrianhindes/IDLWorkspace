pro practice

for i=0, 3L do begin
  for j=0, 3L do begin
    corr_value_sum[3+i-j] = corr_value_sum[3+i-j]+corr_value[i,j]
  endfor
endfor

end