pro calculate_ecei_cross_all, crosspower=crosspower, crossphase=crossphase, crosscorr=crosscorr, norm=norm

if keyword_set(crosspower) then begin
   action='crosspower'
endif
if keyword_set(crossphase) then begin
   action='crossphase'
endif
if keyword_set(crosscorr) then begin
   action='crosscorr'
endif
if keyword_set(norm) then norm='1' else norm='0'


;shots=[9134, 9135, 9143, 9144, 9146, 9147, 9174, 9175, 9176, 9235, 9236, 9237, 9238, 9239, 9353, 9354, 9355, 9356, 9357, 9359, 9422, 9423]
shots=[9174,9175,9176]

times=transpose([[3,3.5],$
                 [3.5,4],$
                 [4,4.5],$
                 [4.5,5],$
		 [5,5.5],$
		 [5.5,6]])

if n_elements(bridges) eq 0 then bridges=build_bridges(8,1)
ncpus=n_elements(bridges)

for i=0,ncpus-1 do begin
	(bridges[i])->execute, '.r show_all_kstar_ecei_power'
	(bridges[i])->execute, '.r callback'
	(bridges[i])->setproperty, callback='callback'
endfor

in=shots
pout=ptr_new(dblarr(n_elements(shots),n_elements(times[*,0])), /no_copy)
default, refchan, 'ECEI/ECEI_L1204'

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
      bridge->execute, /nowait, 'show_all_kstar_ecei_power, curr_shot, timerange=curr_time, out=out, /'+action+', refchan="'+refchan+'", /onlylfs, norm='+norm
   endfor
endfor

barrier_bridges, bridges
burn_bridges, bridges

for i=0,n_elements(shots)-1 do begin
   hardon, /color
   for j=0,n_elements(times[*,0])-1 do begin
      filename='show_all_kstar_ecei_power_'+strmid(refchan,5,10)+'_'+strtrim(shots[i],2)+'_'+strtrim(times[j,0],2)+'_.sav'
      if file_test('tmp/'+filename) then begin
         show_all_kstar_ecei_power, shots[i], savefile=filename, /nocalc, timerange=reform(times[j,*]), crosspower=crosspower, crosscorr=crosscorr, crossphase=crossphase, refchan='ECEI/'+refchan, norm=horm
      endif else begin
         print, 'File not found! '+filename
      endelse
        erase
     endfor
   hardfile, 'ecei_crosscorr_analysis_'+strtrim(shots[i],2)+'.ps'
endfor


end
