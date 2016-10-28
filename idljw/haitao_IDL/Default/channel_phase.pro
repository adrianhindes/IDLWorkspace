pro channel_phase, shotno, channel,low_number, high_number,beg_time,end_time
if n_elements(shotno) eq 0 then shotno=1398
if n_elements(channel) eq 0 then channel=0

y=read_pmt_channel(shotno,channel,time=time)
delta_t=time[1]-time[0]
fnyq=1/(2*delta_t)
npts = n_elements(time)
power=make_array(npts/2, value=0.0)
power= abs( (fft(y))[1:npts/2] )
freq = (findgen(npts/2)+1)/(npts/2)*fnyq
;spectrum=plot(freq/1000, alog(power)>(-12)<(-6),xtitle='Freq(kHz)',ytitle='ln(Amplititude)');,layout=[4,4,channel+1],/current)

inv_fft=make_array(16,510000, /complex)
angle=make_array(16,510000, /complex)
for i=0,15 do begin
k=channel+i
y_i=read_pmt_channel(shotno,k,time=time)
max_i=max(y_i)
y_i=y_i/max_i
four_i=fft(y_i)

four_i[0:low_number]=0
four_i[high_number:509999]=0
inv_fft(i,*)=fft(four_i, /inverse)
angle(i,*)=atan(inv_fft(i,*),/phase)

endfor

pick_num=(end_time-beg_time)*1e3
trial_array=make_array(16,pick_num+1)
for j=0,15 do begin
  column=angle(j,*)
trial_array(j,*)=column[beg_time*1e3:end_time*1e3] 
 ;trial_array(j,*)=trial_array(j,*)/max(trial_array(j,*))*!pi
 endfor
 
 time_axis=findgen((((end_time-beg_time)*1e3)+1)*2)*1e-3/2+beg_time
 beg=time_axis(0)
 en=time_axis(1)
; window,0
; for j=0,15 do begin
 ; k=j
  ;p0=plot(time_axis,trial_array(0,*),xtitle='time(ms)',name='channel 0',ytitle='phase(radians)',title='channel 0 vs 8 of shotno 1675')
  ;p1=plot(time_axis,trial_array(1,*),name='channel 1',xtitle='time(ms)',ytitle='phase')
    ;p2=plot(time_axis,trial_array(2,*), color='red',name='channel 2',xtitle='time(ms)',ytitle='phase',/current)
     ; p3=plot(time_axis,trial_array(3,*), color='blue',name='channel 3',xtitle='time(ms)',ytitle='phase')
      ;p4=plot(time_axis,trial_array(4,*), color='red',name='channel 4',xtitle='time(ms)',ytitle='phase',/current)
        ;p6=plot(time_axis,trial_array(6,*), color='blue',name='channel 6',xtitle='time(ms)',ytitle='phase',/current)
          ;p6=plot(time_axis,trial_array(6,*), color='blue',name='channel 6',xtitle='time(ms)',ytitle='phase',/current)
            ;p7=plot(time_axis,trial_array(7,*), color='yellow',name='channel 7',xtitle='time(ms)',ytitle='phase',/current)
  ;p2=plot(time_axis,trial_array(5,*), color='blue',name='channel 5',xtitle='time(ms)',ytitle='phase',title='shotno 1675',/current)
  ;color=legend(target=[p0,p4,p6],position=[0.92,0.9])
;  endfor
  ;imgplot,transpose(trial_array)*!radeg,zr=[-180,180],/cb
 
 phase=image(rebin(transpose(trial_array),1002,480),findgen(1002)/2000,findgen(480)/30,xtitle='time(ms)',ytitle='channel number',rgb_table=4,axis_style=1,title='phases of shotno1685',aspect_ratio=0.01)
 c=colorbar(target=phase,orientation=0,title='Radians',position=[0.13,0.22,0.93,0.27])
;imgplot,transpose(trial_array)*!radeg,zr=[-180,180],/cb
stop
end
