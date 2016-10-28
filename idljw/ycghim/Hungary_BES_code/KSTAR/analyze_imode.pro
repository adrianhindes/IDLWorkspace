pro analyze_imode, shot=shot, auto=auto, crosspower=crosspower, crossphase=crossphase, refchan=refchan


if shot eq 10810 then begin
n=30
time=dblarr(120,2)
for i=0,n-1 do begin
   time[i,0]=3.07+i*0.4
   time[i,1]=3.11+i*0.4
endfor
endif

if shot eq 10809 then begin
   n=30
   time=dblarr(30,2)
   for i=0,n-1 do begin
      time[i,0]=5.07+i*0.1
      time[i,1]=5.11+i*0.1
   endfor
endif

if keyword_set(auto) then begin
   hardon, /color
   for i=0,n-1 do begin
      print, double(i)/n*100.,"%"
      erase
      show_all_kstar_bes_power, shot, timerange=[time[i,0],time[i,1]], /nocalib ,$
                                yrange=[1e-12,1e-7]
   endfor
   hardfile, i2str(shot)+'_autopower.ps'
endif

if keyword_set(crosspower) then begin ;calculates the crosscoherency between ref channel and all other channels
   hardon, /color
   for i=0,n-1 do begin
      print, double(i)/n*100.,"%"
      erase
      show_all_kstar_bes_power, shot, timerange=[time[i,0],time[i,1]], /nocalib ,$
                                refchan=refchan, /crosspower, /norm
   endfor
   hardfile, i2str(shot)+'_crosspower'+refchan+'.ps'
endif

if keyword_set(crossphase) then begin
   hardon, /color
   for i=0,n-1 do begin
      print, double(i)/n*100.,"%"
      erase
      show_all_kstar_bes_power, shot, timerange=[time[i,0],time[i,1]], /nocalib ,$
                                refchan=refchan, /crossphase
   endfor
   hardfile, i2str(shot)+'_crossphase'+refchan+'.ps'
endif


end
