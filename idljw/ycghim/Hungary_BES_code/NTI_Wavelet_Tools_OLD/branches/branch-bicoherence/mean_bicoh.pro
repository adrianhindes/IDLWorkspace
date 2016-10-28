pro mean_bicoh,dev,iteracio,hann=hann,deviation=deviation,bmean=bmean,bdev=bdev

default, hann, 1

iteracio=long(iteracio)
sum_bicoh=0
deviation=dindgen(iteracio)
bikoherencia=dindgen(iteracio)

for i=0L,iteracio-1 do begin
  t=dindgen(16384)*0.001
  phi_1=random_phi(dev)
  phi_2=random_phi(dev)
  phi_3=random_phi(dev)
  data=sin(2*!DPI*100*t+phi_1)+sin(2*!DPI*170*t+phi_2)+sin(2*!DPI*270*t+phi_3)+0.1*randomn(seed,n_elements(t),/NORMAL)
  bicoh=bicoherence(data,t,512,hann=hann)
  sum_bicoh=sum_bicoh+bicoh
  deviation[i]=max(sum_bicoh)/(i+1)
  bikoherencia[i]=max(bicoh)
end

m_bicoh=sum_bicoh/iteracio
;print,'max_m_bicoh: '+pg_num2str(max(m_bicoh))

print,'sigma: '+pg_num2str(dev)

bmean = mean(bikoherencia)
print,'mean: '+pg_num2str(mean(bikoherencia))
;print,'meanabsdev: '+pg_num2str(meanabsdev(bikoherencia))
bdev = stddev(bikoherencia)
print,'stddev: '+pg_num2str(STDDEV(bikoherencia))

plot_bicoherence,data,t,512,ID='mean_bicoh',shotnumber=i2str(systime(1))+', hann='+pg_num2str(hann)$
,channelname='it='+pg_num2str(iteracio,length=3)+', dev_phi='+pg_num2str(dev,length=3),bicoh=m_bicoh

end
