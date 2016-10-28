pro analyze_10809, auto=auto, crosspower=crosspower, crossphase=crossphase, refchan=refchan
n=30
time=dblarr(30,2)
for i=0,n-1 do begin
   time[i,0]=5.07+i*0.1
   time[i,1]=5.11+i*0.1
endfor
if keyword_set(auto) then begin
   hardon, /color
   for i=0,n-1 do begin
      print, double(i)/n*100.,"%"
      erase
      show_all_kstar_bes_power, 10809, timerange=[time[i,0],time[i,1]], /nocalib ,$
                                yrange=[1e-12,1e-7]
   endfor
   hardfile, '10809_autopower.ps'
endif

if keyword_set(crosspower) then begin ;calculates the crosscoherency between ref channel and all other channels
   hardon, /color
   for i=0,n-1 do begin
      print, double(i)/n*100.,"%"
      erase
      show_all_kstar_bes_power, 10809, timerange=[time[i,0],time[i,1]], /nocalib ,$
                                refchan=refchan, /crosspower, /norm
   endfor
   hardfile, '10809_crosspower'+refchan+'.ps'
endif

if keyword_set(crossphase) then begin
   hardon, /color
   for i=0,n-1 do begin
      print, double(i)/n*100.,"%"
      erase
      show_all_kstar_bes_power, 10809, timerange=[time[i,0],time[i,1]], /nocalib ,$
                                refchan=refchan, /crossphase
   endfor
   hardfile, '10809_crossphase'+refchan+'.ps'
endif


end
