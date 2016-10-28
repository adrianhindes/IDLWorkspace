pro make_data_txt, shot, channel
default, shot, 6123
for i=0,3 do begin
  for j=0,7 do begin
    shot2=shot
    channel2='BES-'+strtrim(i+1,2)+'-'+strtrim(j+1,2)
    get_rawsignal,shot,channel2,t,d
    cd, 'C:\Users\lampee\KFKI\Measurements\KSTAR\Measurement'
    channel2='BES-'+strtrim(i+1,2)+'-'+strtrim(j+1,2)
    fname='G:\KSTAR2011\'+strtrim(shot2,2)+'_'+channel2+'.txt'
    print, fname
    openw,unit_w,fname,/get_lun,error=error
    for l=0l,n_elements(t)-1 do begin
      printf,unit_w,[t[l],d[l]]
    endfor
    close,unit_w & free_lun,unit_w
  endfor
endfor

end