pro comode

file='C:\haitao\papers\PMT camera\coherence data\data\22-25-2014\tek0008ALL.csv'
d=read_csv(file, n_table_header=21)
t=d.field1
deltat=t(2)-t(1)
data=d.field3
plld=d.field2
data=float(data)
lag=findgen(300)+1
plda=c_correlate(data(5000:5400),plld(5000:5400),lag)
plda1=c_correlate(data(5000:5400),data(5000:5400),lag)
plda2=c_correlate(plld(5000:5400),plld(5000:5400),lag)


fdata=fft(data(5000:5999))
ppower=abs(fdata)

fdata1=fft(data(0:999))
ppower1=abs(fdata1)


fdata2=fft(data(9000:9999))
ppower2=abs(fdata2)
freq=findgen(501)/(1000.0*deltat)
!p.multi=[0,1,3]
plot, data(5000:5400),title='PMT Signal'
plot, plld(5000:5400),title='PLL signal'
plot, plda, title='Correlation'
window, 1
!p.multi=[10,1,2]
plot,  plda1, title='Self Correlation of PMT signal'
plot,  plda2, title='Self Correlation of PLL signal'
p=plot(freq/1000.0,ppower(0:500),title='Power spectrum of the ch2 data (middle part)', xtitle='Frequency/kHz',ytitle='Power',xrange=[0,100],layout=[1,3,1])
p1=plot(freq/1000.0,ppower1(0:500),title='Power spectrum of the ch2 data (begining part)', xtitle='Frequency/kHz',ytitle='Power',xrange=[0,100],layout=[1,3,2],/current)
p2=plot(freq/1000.0,ppower2(0:500),title='Power spectrum of the ch2 data (ending part)', xtitle='Frequency/kHz',ytitle='Power',xrange=[0,100],layout=[1,3,3],/current)
stop
end