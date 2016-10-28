function pmtdata,shotno
common tpara, bt,et,sf
bt=0.21  ;samplint time interval
et=0.22
sf=1e6 ;sampling frequency


radiation=make_array(510000,16,/float)
cd=make_array(16,/float)
fd=make_array((et-bt)*sf+1,16,/complex)

for j=0,15 do begin
  cd(j)=max(read_pmt_channel(1566,j,time=time))  ;shotno 1566 is calibraiton
  endfor
cd=cd/max(cd)


for i=0,15 do begin
data=read_pmt_channel(shotno,i,time=time)
radiation(*,i)=data/cd(i)
radiation1=radiation(*,i)
md=fft(radiation1(bt*sf:et*sf))
fd(*,i)=md(0:(et-bt)*sf)
endfor

freq=findgen((et-bt)*sf/2+1)/((et-bt)*sf*(time(1)-time(0)))

data={emiss:radiation, frd:fd, freq:freq}
return, data


end