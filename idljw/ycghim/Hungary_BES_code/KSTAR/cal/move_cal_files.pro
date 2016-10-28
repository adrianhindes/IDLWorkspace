pro move_cal_files
for i=5968,8093 do begin
   file1=strtrim(i,2)+'.cal'
   file2=strtrim(i,2)+'.spat.cal'
   bl1=file_test(file1)
   bl2=file_test(file2)
   if bl1 then spawn, 'cp '+file1+' /media/DATA/KSTAR/Measurements/APDCAM/data/'+strtrim(i,2)
   if bl2 then spawn, 'cp '+file2+' /media/DATA/KSTAR/Measurements/APDCAM/data/'+strtrim(i,2)
endfor
end
