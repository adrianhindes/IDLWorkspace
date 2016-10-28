pro plot_ecei_power_spectrum
shot=[9134, 9135, 9143, 9144, 9146, 9147, 9174, 9175, 9176, 9235, 9236, 9237, 9238, 9239, 9353, 9354, 9355, 9356, 9357, 9359, 9422, 9423]

times=transpose([[2,2.5],$
                 [2.5,3],$
                 [3,3.5],$
                 [3.5,4],$
                 [4,4.5],$
                 [4.5,5]])  

  for i=0,n_elements(shot)-1 do begin
     hardon, /color
     for j=0,n_elements(times[*,0])-1 do begin
        filename='show_all_kstar_ecei_power_'+strtrim(shot[i],2)+'_'+strtrim(times[j,0],2)+'_.sav'
        if file_test('tmp/'+filename) then begin
           show_all_kstar_ecei_power, shot[i], savefile=filename, /nocalc, timerange=reform(times[j,*]), yrange=[0.01,100]
        endif else begin
           print, 'File not found! '+filename
        endelse
        erase
     endfor
     hardfile, 'ecei_power_analysis_'+strtrim(shot[i],2)+'.ps'
  endfor
end
