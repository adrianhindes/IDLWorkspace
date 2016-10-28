;+
; NAME:
; PLOT_NOISE_VS_SIGNAL
;
; AUTHOR: Sandor Zolentik (zoletnik.sandor@wigner.mta.hu)
;
; PURPOSE:
; Plots the noise at high freqeuncy as a function of signal and
; estimates the SNR from a fit.
;
; CATEGORY:
; Miscellaneous
;
; CALLING SEQUENCE:
; plot_noise_vs_signal,shot,signal,timerange=timerange,noise_frange=noise_frange,$
;                         inttime=inttime, thick=thick,charsize=charsize,bandwidth=bandwidth, snr=snr, $
;                         vmax_snr=vmax_snr,xticks_snr=xticks_snr,siglevel=siglevel,noiselevel=noiselevel,$
;                         noplot=noplot,offset_timerange=offset_timerange,yrange=yrange
;
; INPUTS:
; shot - Shot nunber
; signal - Signal name
; timerange - The time range to process
; noise_frange - The frequency range of the noise
; inttime - Integration time for the signal and noise level
; bandwidth - The amplifier bandwidth
; thick - Line thickness for plot
; charsize - Character size for plot
; vmax_snr - The x axis rmaximum for the SNR plot
; xticks_snr - number of tick interval in SNR plot
; snr - the SNR as a function of signal level
; siglevel - signal level (x axis) belongs to snr
; noiselevel -
; noplot - avoid plotting just retrieve snr and siglevel
; offset_timerange - Timerange for offset and electronic STD calcualtion
; yrange - Plot vertical range
;-


pro plot_noise_vs_signal,shot,signal,timerange=timerange,noise_frange=noise_frange,$
                         inttime=inttime, thick=thick,charsize=charsize,bandwidth=bandwidth, snr=snr, $
                         vmax_snr=vmax_snr,xticks_snr=xticks_snr,siglevel=siglevel,noiselevel=noiselevel,$
                         noplot=noplot,offset_timerange=offset_timerange,yrange=yrange

default,noise_frange,[2e5,4e5]
default,bandwidth,5e5
default,inttime,1e-3
default,thick,1
default,charsize,1

if (n_elements(offset_timerange) lt 2) then begin
  offset_timerange_start = local_default('offset_timerange_start',/silent)
  offset_timerange_end = local_default('offset_timerange_end',/silent)
  if ((offset_timerange_start ne '') and (offset_timerange_end ne '')) then begin
    offset_timerange = [double(offset_timerange_start),double(offset_timerange_end)]
  endif
endif
default,xticks,3
default,noplot,0

get_rawsignal,shot,signal,t_orig,d_orig,sampletime=sampletime,errormess=e,/nocalib,/no_offset,timerange=timerange
if (e ne '') then begin
  print,e
  return
endif

default,timerange,[t_orig[0],t_orig[n_elements(t_orig)-1]]


inds_offset=where((t_orig GE offset_timerange[0]) AND (t_orig LE offset_timerange[1]))
;t_offset=t_orig(inds_offset)
d_offset=d_orig(inds_offset)


inds_invest=where((t_orig GE timerange[0]) AND (t_orig LE timerange[1]))
d=d_orig(inds_invest)-mean(d_offset)
t=t_orig(inds_invest)

n = integ(bandpass_filter_data(d,sampletime=sampletime,filter_low=noise_frange[0],filter_high=noise_frange[1],filter_order=100)^2,inttime/sampletime)
n = n*bandwidth/(noise_frange[1]-noise_frange[0])
s = integ(d,inttime/sampletime)
default,timerange,[min(t),max(t)]
nind = (timerange[1]-timerange[0])/(inttime*2)
ind = findgen(nind)*(n_elements(t)-2)/(nind-1)

p=poly_fit(s[ind],n[ind],1)
default,vmax_snr,max(s)
siglevel=findgen(100)/99*vmax_snr
noiselevel=sqrt(p[0]+p[1]*siglevel)
snr=siglevel/noiselevel
;yy=p[0]+p[1]*siglevel

print, signal+ ', noise at 0 V signal = ' + string(noiselevel[0]*1000,format='(F4.1)') + ' mV, offset STD = ' $
   + string(stddev(d_offset)*1000,format='(F4.1)') + ' mV based on [ '+ string(t_orig[inds_offset[0]],format='(F6.3)') $
   + ' s ; ' + string(t_orig[inds_offset[-1]],format='(F6.3)') + ' s ].'

if noplot NE 1 then begin
    plotsymbol,0
    default,yrange,[0,max(n)*1.05]
    plot,s[ind],n[ind],xtitle='Signal [V]',xstyle=1,xrange=[0,max(s)*1.05],ystyle=1,yrange=yrange,ytitle='!3Noise power [V!U2!N]',$
      title=i2str(shot)+' '+signal + ', Offset STD = ' + string(stddev(d_offset)*1000,format='(F4.1)') + ' mV based on [ '+$
        string(t_orig[inds_offset[0]],format='(F6.3)') + ' s ; ' + string(t_orig[inds_offset[1]],format='(F6.3)') + ' s ].',$
      psym=8,thick=thick,xthick=thick,ythick=thick,charthick=thick,charsize=charsize

    oplot,siglevel,noiselevel^2,thick=thick
    xyouts,max(s)*0.02,p[0]*0.5,string(noiselevel[0]*1000,format='(F4.1)')+' mV',charsize=charsize,charthick=thick


    plot,siglevel,snr,/noerase,pos=[0.65,0.17,0.9,0.45],title='SNR vs signal',xtitle='Signal [V]',ytitle='SNR',yrange=[0,max(snr)*1.05],ystyle=1,$
      thick=thick,xthick=thick,ythick=thick,charthick=thick,charsize=0.75*charsize,xticks=xticks_snr,xrange=[0,vmax_snr*1.05],xstyle=1
endif

end
