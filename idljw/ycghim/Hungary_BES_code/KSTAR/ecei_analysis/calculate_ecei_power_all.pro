pro calculate_ecei_power_all, nocalc=nocalc, only_lfs=only_lfs

default, only_lfs, 1
default, nocalc, 1

;shots=[9134, 9135, 9143, 9144, 9146, 9147, 9174, 9175, 9176, 9235, 9236, 9237, 9238, 9239, 9353, 9354, 9355, 9356, 9357, 9359, 9422, 9423]
;shots=[9356, 9357, 9359, 9422, 9423]
shots=[9174,9175,9176]

times=transpose([[3,3.5],$
                 [3.5,4],$
                 [4,4.5],$
                 [4.5,5],$
                 [5,5.5],$
                 [5.5,6]])
if not keyword_set(nocalc) then begin
if n_elements(bridges) eq 0 then bridges=build_bridges(8,1)
ncpus=n_elements(bridges)

for i=0,ncpus-1 do begin
	(bridges[i])->execute, '.r show_all_kstar_ecei_power'
	(bridges[i])->execute, '.r callback'
	(bridges[i])->setproperty, callback='callback'
endfor

in=shots
pout=ptr_new(dblarr(n_elements(shots),n_elements(times[*,0])), /no_copy)

for i=0,n_elements(shots)-1 do begin
   for j=0,n_elements(times[*,0])-1 do begin
      ud={i:i,j:j,pout:pout}
      print, i, j
      bridge=get_idle_bridge(bridges)
      bridge->setproperty, callback='callback'
      bridge->setproperty, userdata=ud
      curr_shot=shots[i]
      curr_time=reform(times[j,*])
      bridge->setvar, 'curr_shot', curr_shot
      bridge->setvar, 'curr_time', curr_time
      bridge->execute, /nowait, 'show_all_kstar_ecei_power, curr_shot, timerange=curr_time, out=out, only_lfs='+strtrim(only_lfs,2)
   endfor
endfor

barrier_bridges, bridges
burn_bridges, bridges
endif

for i=0,n_elements(shots)-1 do begin
   hardon, /color
   for j=0,n_elements(times[*,0])-1 do begin
      filename='show_all_kstar_ecei_power_'+strtrim(shots[i],2)+'_'+strtrim(times[j,0],2)+'_.sav'
      if file_test('tmp/'+filename) then begin
         show_all_kstar_ecei_power, shots[i], savefile=filename, /nocalc, timerange=reform(times[j,*]), yrange=[0.01,100], only_lfs=only_lfs
      endif else begin
         print, 'File not found! '+filename
      endelse
      erase
   endfor
   hardfile, 'ecei_power_analysis_'+strtrim(shots[i],2)+'.ps'
endfor

for i=0,n_elements(shots)-1 do begin
   hardon, /color
   for j=0,n_elements(times[*,0])-1 do begin
      filename='show_all_kstar_ecei_power_'+strtrim(shots[i],2)+'_'+strtrim(times[j,0],2)+'_.sav'
      image=dblarr(8,24)
      restore, filename
      for i=0,7 do begin
         for j=0,23 do begin
            image[i,j]=total(p_matrix(0,i,j,where(fscale gt 20e3 and fscale lt 80e3)))
         endfor
      endfor
      contour, image, indgen(7)+1, indgen(23)+1, nlevel=21, /fill, /xstyle, /ystyle, xtitle='Radial channel number', ytitle='Poloidal channel number', title='Intensity between 20kHz and 80kHz'
   endfor
endfor

end
