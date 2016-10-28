pro proc_apdcam_gaintest,file=file,thick=thick,vrange=vrange

default,file,'gaintest.sav'
default,thick,1

restore,file

if (defined(vrange)) then begin
  ind = where((volts ge vrange[0]) and (volts le vrange[1]))
  signals = signals[*,ind]
  offsets = offsets[*,ind]
  volts = volts[ind]
  noise_signals = noise_signals[*,ind]
  noise_offsets = noise_offsets[*,ind]
  temps = temps[ind]
endif

calfac = 2000./2.^bits
n_gain = (size(signals))[2]

; Page 1
data = signals - offsets
for i=1,n_gain-1 do begin
  data[*,i] = data[*,i]/data[*,0]
endfor
data[*,0] = 1.
yrange = [0.8,150]
xrange = [min(volts)-20,max(volts)+20]

erase
time_legend,'proc_apdcam_gaintest.pro/1'

for i_block = 0,3 do begin
  pos=[0.1+(i_block mod 2)*0.5,0.6-(i_block / 2)*0.5]
  pos = [pos,pos+0.3]
  plot,volts,data[i_block*8,*],yrange=yrange,ystyle=1,ytype=1,pos=pos,/noerase,xtitle='U [V]',$
    xstyle=1,xrange=[xrange],ytitle='Gain',title='Gain, block #'+i2str(i_block+1),linestyle=0,xthick=thick,$
    ythick=thick,thick=thick,charthick=thick
  for ich = 1,7 do begin
    oplot,volts,data[i_block*8+ich,*],linestyle=ich mod 4,thick=thick*(fix(ich/4)+1)
  endfor
  for ich = 0,7 do begin
    plots,[pos[2],pos[2]+0.03]+0.02,[pos[3],pos[3]]-0.03-ich*0.02,/norm,thick=thick*(fix(ich/4)+1),linestyle=ich mod 4
    xyouts,pos[2]+0.06,pos[3]-0.03-ich*0.02-0.005,i2str(i_block*8+ich+1),/norm,charthick=thick
  endfor
  xyouts,0.1,0.95,/norm,'Light: '+i2str(light)+'  Temp: '+string(min(temps),format='(F4.1)')+'-'+string(max(temps),format='(F4.1)'),charthick=thick
endfor

; Page 2
erase
time_legend,'proc_apdcam_gaintest.pro/2'


yrange = [min(signals),max(signals)]*calfac/1000
yrange = yrange+(yrange[1]-yrange[0])*0.05*[-1,1]

for i_block = 0,3 do begin
  pos=[0.1+(i_block mod 2)*0.5,0.6-(i_block / 2)*0.5]
  pos = [pos,pos+0.3]
  plot,volts,signals[i_block*8,*]*calfac/1000,yrange=yrange,ystyle=1,pos=pos,/noerase,xtitle='U [V]',$
    xstyle=1,xrange=[xrange],ytitle='Signal [V]',title='Mean signal, block #'+i2str(i_block+1),linestyle=0,xthick=thick,$
    ythick=thick,thick=thick,charthick=thick
  for ich = 1,7 do begin
    oplot,volts,signals[i_block*8+ich,*]*calfac/1000,linestyle=ich mod 4,thick=thick*(fix(ich/4)+1)
  endfor
  for ich = 0,7 do begin
    plots,[pos[2],pos[2]+0.03]+0.02,[pos[3],pos[3]]-0.03-ich*0.02,/norm,thick=thick*(fix(ich/4)+1),linestyle=ich mod 4
    xyouts,pos[2]+0.06,pos[3]-0.03-ich*0.02-0.005,i2str(i_block*8+ich+1),/norm,charthick=thick
  endfor
  xyouts,0.1,0.95,/norm,'Light: '+i2str(light)+'  Temp: '+string(min(temps),format='(F4.1)')+'-'+string(max(temps),format='(F4.1)'),charthick=thick
endfor

; Page 3
erase
time_legend,'proc_apdcam_gaintest.pro/3'


yrange = [min(offsets),max(offsets)]*calfac/1000
yrange = yrange+(yrange[1]-yrange[0])*0.05*[-1,1]

for i_block = 0,3 do begin
  pos=[0.1+(i_block mod 2)*0.5,0.6-(i_block / 2)*0.5]
  pos = [pos,pos+0.3]
  plot,volts,offsets[i_block*8,*]*calfac/1000,yrange=yrange,ystyle=1,pos=pos,/noerase,xtitle='U [V]',$
    xstyle=1,xrange=[xrange],ytitle='Offset [V]',title='Mean offset, block #'+i2str(i_block+1),linestyle=0,xthick=thick,$
    ythick=thick,thick=thick,charthick=thick
  for ich = 1,7 do begin
    oplot,volts,offsets[i_block*8+ich,*]*calfac/1000,linestyle=ich mod 4,thick=thick*(fix(ich/4)+1)
  endfor
  for ich = 0,7 do begin
    plots,[pos[2],pos[2]+0.03]+0.02,[pos[3],pos[3]]-0.03-ich*0.02,/norm,thick=thick*(fix(ich/4)+1),linestyle=ich mod 4
    xyouts,pos[2]+0.06,pos[3]-0.03-ich*0.02-0.005,i2str(i_block*8+ich+1),/norm,charthick=thick
  endfor
  xyouts,0.1,0.95,/norm,'Light: '+i2str(light)+'  Temp: '+string(min(temps),format='(F4.1)')+'-'+string(max(temps),format='(F4.1)'),charthick=thick
endfor

; Page 4
erase
time_legend,'proc_apdcam_gaintest.pro/4'

yrange = [min(noise_signals),max(noise_signals)]*calfac
yrange = yrange+(yrange[1]-yrange[0])*0.05*[-1,1]

for i_block = 0,3 do begin
  pos=[0.1+(i_block mod 2)*0.5,0.6-(i_block / 2)*0.5]
  pos = [pos,pos+0.3]
  plot,volts,noise_signals[i_block*8,*]*calfac,yrange=yrange,ystyle=1,pos=pos,/noerase,xtitle='U [V]',$
    xstyle=1,xrange=[xrange],ytitle='[mV]',title='Noise (light on), block #'+i2str(i_block+1),linestyle=0,xthick=thick,$
    ythick=thick,thick=thick,charthick=thick
  for ich = 1,7 do begin
    oplot,volts,noise_signals[i_block*8+ich,*]*calfac,linestyle=ich mod 4,thick=thick*(fix(ich/4)+1)
  endfor
  for ich = 0,7 do begin
    plots,[pos[2],pos[2]+0.03]+0.02,[pos[3],pos[3]]-0.03-ich*0.02,/norm,thick=thick*(fix(ich/4)+1),linestyle=ich mod 4
    xyouts,pos[2]+0.06,pos[3]-0.03-ich*0.02-0.005,i2str(i_block*8+ich+1),/norm,charthick=thick
  endfor
  xyouts,0.1,0.95,/norm,'Light: '+i2str(light)+'  Temp: '+string(min(temps),format='(F4.1)')+'-'+string(max(temps),format='(F4.1)'),charthick=thick
endfor

; Page 5
erase
time_legend,'proc_apdcam_gaintest.pro/5'

yrange = [min(noise_offsets),max(noise_offsets)]*calfac
yrange = yrange+(yrange[1]-yrange[0])*0.05*[-1,1]

for i_block = 0,3 do begin
  pos=[0.1+(i_block mod 2)*0.5,0.6-(i_block / 2)*0.5]
  pos = [pos,pos+0.3]
  plot,volts,noise_offsets[i_block*8,*]*calfac,yrange=yrange,ystyle=1,pos=pos,/noerase,xtitle='U [V]',$
    xstyle=1,xrange=[xrange],ytitle='[mV]',title='Noise (light off), block #'+i2str(i_block+1),linestyle=0,xthick=thick,$
    ythick=thick,thick=thick,charthick=thick
  for ich = 1,7 do begin
    oplot,volts,noise_offsets[i_block*8+ich,*]*calfac,linestyle=ich mod 4,thick=thick*(fix(ich/4)+1)
  endfor
  for ich = 0,7 do begin
    plots,[pos[2],pos[2]+0.03]+0.02,[pos[3],pos[3]]-0.03-ich*0.02,/norm,thick=thick*(fix(ich/4)+1),linestyle=ich mod 4
    xyouts,pos[2]+0.06,pos[3]-0.03-ich*0.02-0.005,i2str(i_block*8+ich+1),/norm,charthick=thick
  endfor
  xyouts,0.1,0.95,/norm,'Light: '+i2str(light)+'  Temp: '+string(min(temps),format='(F4.1)')+'-'+string(max(temps),format='(F4.1)'),charthick=thick
endfor

; Page 6
erase
time_legend,'proc_apdcam_gaintest.pro/6'

data = signals - offsets
snr = data/noise_signals
yrange = [min(snr),max(snr)]
yrange = yrange+(yrange[1]-yrange[0])*0.05*[-1,1]

for i_block = 0,3 do begin
  pos=[0.1+(i_block mod 2)*0.5,0.6-(i_block / 2)*0.5]
  pos = [pos,pos+0.3]
  plot,volts,snr[i_block*8,*],yrange=yrange,ystyle=1,pos=pos,/noerase,xtitle='U [V]',$
    xstyle=1,xrange=[xrange],ytitle='SNR',title='SNR (light on), block #'+i2str(i_block+1),linestyle=0,xthick=thick,$
    ythick=thick,thick=thick,charthick=thick
  for ich = 1,7 do begin
    oplot,volts,snr[i_block*8+ich,*],linestyle=ich mod 4,thick=thick*(fix(ich/4)+1)
  endfor
  for ich = 0,7 do begin
    plots,[pos[2],pos[2]+0.03]+0.02,[pos[3],pos[3]]-0.03-ich*0.02,/norm,thick=thick*(fix(ich/4)+1),linestyle=ich mod 4
    xyouts,pos[2]+0.06,pos[3]-0.03-ich*0.02-0.005,i2str(i_block*8+ich+1),/norm,charthick=thick
  endfor
  xyouts,0.1,0.95,/norm,'Light: '+i2str(light)+'  Temp: '+string(min(temps),format='(F4.1)')+'-'+string(max(temps),format='(F4.1)'),charthick=thick
endfor



end

