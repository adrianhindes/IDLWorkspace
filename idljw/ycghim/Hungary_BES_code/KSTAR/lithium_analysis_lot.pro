pro lithium_analysis_lot
str=['0.8','1.0','1.2']
wl1=670
wl2=670.1
wl3=670.2
wl_arr=[-0.3+(30-23)*0.018,-0.3+(70-23)*0.018,(30-23)*0.018,(70-23)*0.018]
wl1=wl1+wl_arr
wl2=wl2+wl_arr
wl3=wl3+wl_arr
loadct, 3
hardon, /color
for i=0, 2 do begin
  for j=0,3 do begin
    print, i,j
    lithium_filter_analysis,wl1[j], str[i]
    ;lithium_filter_analysis,wl2[j], str[i]
    ;lithium_filter_analysis,wl3[j], str[i]
  endfor
endfor
hardfile, 'filter_analysis_det_lot.ps'
end