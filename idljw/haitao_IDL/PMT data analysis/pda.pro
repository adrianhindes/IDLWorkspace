pro pda

;phap=make_array(12,16,/float)
;for k=1584,1600 do begin
  
  ;time=findgen(51)*0.01
;pha=make_array(n_elements(time),16)
;for j=0,49 do begin
    ;j=21
common tpara, bt,et,sf
bt=0.21  ;samplint time interval
et=0.22
sf=1e6 ;sampling frequency
  
freqv=make_array(17,/float)
for i=1602,1618 do begin  
d=pmtdata(i)
rd=d.emiss
fd=d.frd
freq=d.freq 
fds=abs(fd)
;fd(0:220,*)=0
;fd(235:*,*)=0


md=smooth(fds(100:5000,10),5,/EDGE_MIRROR)
index=where(md eq max(md))
freqv(i-1602)=freq(index+100)
endfor
save,freqv,filename='1.5 mt and 800 A freq.save'

stop
end
;g=image(fds(0:(et-bt)*sf/2,*),freq/1000, findgen(16)+1, axis_style=1, xrange=[0,60], xtitle='Frequency(kHz)',ytitle='Channel No.', max_value=0.005,min_value=0.0, rgb_table=4,aspect_ratio=1.5)
;c=colorbar(target=g,orientation=1,position=[0.96,0.33,0.98,0.68])


sz=size(fd,/DIMENSIONS)
signal=make_array(sz(0),16,/float)
phase=make_array(sz(0),16,/float)
for i=0,15 do begin
  signal(*,i)=real_part(fft(fd(*,i),/inverse))
  mp=atan(fft(fd(*,i),/inverse)/fft(fd(*,0),/inverse),/phase)
 ;mp=atan(fft(fd(*,i),/inverse),/phase)-atan(fft(fd(*,0),/inverse),/phase)
 ;mp=atan(complex(cos(mp),sin(mp)),/phase)
  phase(*,i)=mp
  endfor
  ;imgplot, phase, /cb
  pham=mean(phase, dimension=1)
  pha(j,*)=pham
 ;endfor
 phap(k-1674,*) =pham
 
stop
;jumpimg, phase
stop
for i=0, 15 do begin
phase(*,i)=phase(*,i)-phase(*,0)
endfor


stop
end