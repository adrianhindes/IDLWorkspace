pro plot_noise_vs_signal,shot,signal,timerange=timerange,noise_frange=noise_frange,$
    inttime=inttime, thick=thick,charsize=charsize,bandwidth=bandwidth
;*******************************************************************
;* PLOT_NOISE_VS_SIGNAL.PRO             S. Zoletnik 27.08.2013     *
;*******************************************************************
;* Plots the noise at high freqeuncy as a function of signal and   *
;* estimates the SNR from a fit.                                   *
;*                                                                 *
;* INPUT:                                                          *
;*   shot: Shot nunber                                             *
;*   signal: Signal name                                           *
;*   timerange: The time range to process                          *
;*   noise_frange: The frequency range of the noise.               *
;*   inttime: Integration time for the signal and noise level      *
;*   bandwidth: The amplifier bandwidth                            *
;*   thick: Line thickness for plot                                *
;*   charsize: Character size for plot                             *
;*******************************************************************
default,noise_frange,[2e5,4e5]
default,bandwidth,1e6
default,inttime,1e-3
default,thick,1
default,charsize,1

get_rawsignal,shot,signal,t,d,timerange=timerange,sampletime=sampletime,errormess=e,/nocalib
if (e ne '') then begin
  print,e
  return
endif
n = integ(bandpass_filter_data(d,sampletime=sampletime,filter_low=noise_frange[0],filter_high=noise_frange[1],filter_order=100)^2,inttime/sampletime)
n = n*bandwidth/(noise_frange[1]-noise_frange[0])
s = integ(d,inttime/sampletime)
default,timerange,[min(t),max(t)]
nind = (timerange[1]-timerange[0])/(inttime*2)
ind = findgen(nind)*(n_elements(t)-2)/(nind-1)
plotsymbol,0
plot,s[ind],n[ind],xtitle='Signal [V]',xstyle=1,xrange=[0,max(s)*1.05],ystyle=1,yrange=[0,max(n)*1.05],ytitle='Noise power [V!U2!N]',title=i2str(shot)+' '+signal,psym=8,thick=thick,xthick=thick,ythick=thick,charthick=thick,charsize=charsize
p=poly_fit(s[ind],n[ind],1)
xx=findgen(100)/99*max(s)
yy=p[0]+p[1]*xx
oplot,xx,yy,thick=thick
xyouts,max(s)*0.02,p[0]*0.7,string(sqrt(p[0])*1000,format='(F4.1)')+' mV',charsize=charsize,charthick=thick
snr=xx/sqrt(p[0]+p[1]*xx)
plot,xx,snr,/noerase,pos=[0.65,0.2,0.9,0.45],title='SNR vs signal',xtitle='Signal [V]',ytitle='SNR',yrange=[0,max(snr)*1.05],ystyle=1,$
   thick=thick,xthick=thick,ythick=thick,charthick=thick,charsize=0.75*charsize,xticks=3,xrange=[0,max(xx)]
end
