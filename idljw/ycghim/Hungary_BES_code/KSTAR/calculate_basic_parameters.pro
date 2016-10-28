pro calculate_basic_parameters, shot, freq_min=freq_min, channel=channel, timerange=timerange, rad_dist=rad_dist, $
                                trange_bg=trange_bg, nocalib=nocalib, ylog=ylog, dummy=dummy, lithium=lithium, cutoff_1=cutoff_1

default, shot, 7900
default, freq_min, 200e3
default, freq_max, 500e3
default, channel, 'BES-2-1'
default, timerange, [2,2.3]

default, lowrange, [1e3,10e3]
default, highrange, [10e3,100e3]
default, noiserange, [200e3,250e3]
default, band_w, 500e3
default, charsize, 1.5
default, thick, 2
default, ylog,0
default, dummy, 0
default, lithium, 0
default, cutoff_1, 100e3
n=16

ch=charsize
hardon, /color
set_plot_style, 'foile_kg_eps'
;calculate SNR for a radial array
snr=dblarr(n)
fluct_amp_tot=dblarr(n)
fluct_amp_low=dblarr(n)
fluct_amp_high=dblarr(n)
noise_level=dblarr(n)
noise_level_low=dblarr(n)
noise_level_high=dblarr(n)
loadct, 5

for i=0,n-1 do begin
   channel='BES-2-'+strtrim(i+1,2)
   get_rawsignal, shot, channel, t, d, /nocalib
   offset_sub=mean(d[n_elements(d)-100:n_elements(d)-1])
   get_rawsignal, shot, channel, t, d, /nocalib, timerange=timerange
   m=mean(d)-offset_sub
   fluc_correlation, shot, refchan=channel, timerange=timerange, /nocalib, /auto,$
                     outpower=outp, outfscale=outf, /noplot, ftype=1, interval_n=1, $
                     frange=[1e3,1e6], /ytype, /noerror, yrange=[1e-11,1e-7], fres=20, /plot_power

   if keyword_set(dummy) then begin
      ind_noise=where(outf gt freq_min and outf lt freq_max)
      ind_signal=where(outf lt freq_min)
      noise_spect=dblarr(n_elements(outp))
      
      noise_spect[0:n_elements(ind_signal)-1]=mean(outp(ind_noise))
      noise_spect[n_elements(ind_signal):n_elements(outp)-1]=outp[n_elements(ind_signal):n_elements(outp)-1]
      
      noise=sqrt(total(noise_spect)*(outf[1]-outf[0])*2)
      
      ind_low=where(outf gt 1e3 and outf le 10e3)
      noise_low=sqrt(total(noise_spect[ind_low])*(outf[1]-outf[0])*2)
      
      ind_High=where(outf gt 10e3 and outf le 100e3)
      noise_high=sqrt(total(noise_spect[ind_high])*(outf[1]-outf[0])*2)
      
      plot, outf, outp, /xlog, /ylog, /ystyle, /xstyle, xtitle='Frequency [Hz]', ytitle='Power', title='Shot: '+strtrim(shot,2)+$
            ' Channel: '+channel+' Time: '+strtrim(timerange[0],2)+' - '+strtrim(timerange[1],2)
      oplot, outf, noise_spect, color=100
      
   endif else begin
      ind=where(outf gt freq_min and outf lt freq_max)
      a=min(abs(outf-band_w),ind_bandw)
      
      p2=mpfitfun('rc_fit',outf[ind],outp[ind],0.01,[band_w,outp[ind_bandw]])
      n=n_elements(outf[where(outf lt freq_min)])
      ind_gt=where(outf gt freq_min)
      n_gt=n_elements(ind_gt)
      noise_spect=[rc_fit(outf[0:n-1],p2),outp[ind_gt]]
      n=n_elements(outf)
      f_res_vect=outf[1:n-1]-outf[0:n-2]
      
      noise=sqrt(total(noise_spect))
                 
      ind_low=where(outf gt 1e3 and outf le 10e3)
      n_ind_low=n_elements(ind_low)
      noise_low=sqrt(total(rc_fit(outf[ind_low[0]:ind_low[n_ind_low-2]],p2)*(outf[ind_low[1:n_ind_low-1]]-outf[ind_low[0:n_ind_low-2]]))*2)

      ind_high=where(outf gt 10e3 and outf le 100e3)
      n_ind_high=n_elements(ind_high)
      noise_high=sqrt(total(rc_fit(outf[ind_high[0]:ind_high[n_ind_high-2]],p2)*(outf[ind_high[1:n_ind_high-1]]-outf[ind_high[0:n_ind_high-2]]))*2)
      
      
      loadct, 5

      a=min(abs(outf-4.9e3),ind_5_1)
      a=min(abs(outf-5.1e3),ind_5_2)
      a=min(abs(outf-10e3),ind_10)
      a=min(abs(outf-15e3),ind_15)
      
      outp[ind_5_1:ind_5_2]=mean([outp[ind_5_1-2],outp[ind_5_1-1],outp[ind_5_2+1],outp[ind_5_2+2]])
      outp[ind_10]=mean([outp[ind_10-2],outp[ind_10-1],outp[ind_10+1],outp[ind_10+2]])
      outp[ind_15]=mean([outp[ind_15-2],outp[ind_15-1],outp[ind_15+1],outp[ind_15+2]])

      outp[ind_10]=(outp[ind_10-1]+outp[ind_10+1])/2
      outp[ind_15]=(outp[ind_15-1]+outp[ind_15+1])/2
      
      plot, outf, outp, /xlog, /ylog, /ystyle, /xstyle, xtitle='Frequency [Hz]', ytitle='Power', title='Shot: '+strtrim(shot,2)+$
            ' Channel: '+channel+' Time: '+strtrim(timerange[0],2)+' - '+strtrim(timerange[1],2)
      oplot, outf, noise_spect, color=100
   endelse

;This part will perform the subtraction of the NBI control peaks
;because they do not contribute to the fluctuation amplitude.

   signal=m
   snr[i]=signal/noise
   outp_won=outp-noise_spect
   ampl_tot=sqrt(total(outp_won[where(outf ge lowrange[0] and outf le highrange[1])]*(outf[1:n_elements(outf)-1]-outf[0:n_elements(outf)-2]))*2)
   ampl_low=sqrt(total(outp_won[where(outf ge lowrange[0] and outf le lowrange[1])])*(outf[1]-outf[0])*2)
   ampl_high=sqrt(total(outp_won[where(outf ge highrange[0] and outf le highrange[1])])*(outf[1]-outf[0])*2)
   fluct_amp_tot[i]=ampl_tot/signal
   fluct_amp_low[i]=ampl_low/signal
   fluct_amp_high[i]=ampl_high/signal

   noise_level[i]=noise/signal
   noise_level_low[i]=noise_low/signal
   noise_level_high[i]=noise_high/signal
   print, channel
   channel='BES-2-'+strtrim(i+1,2)
endfor

xtitle='Radial channel number'
pos=plot_position(3,1, xgap=0.15, ygap=0.15, corner=[0.1,0.1,0.5,0.9])
   
;show_all_kstar_bes, shot, /nocalib
;erase
;show_all_kstar_bes_power, shot, timerange=timerange, /nocalib, yrange=[1e-13, 1e-8]

;if keyword_set(trange_bg) then begin
;   show_all_kstar_bes_power, shot, timerange=trange_bg, /nocalib, color=100, /noerase, yrange=[1e-13, 1e-8]
;endif
;erase
;plot, ra, snr, xtitle=xtitle, ytitle='SNR', title='SNR for shot '+strtrim(shot,2), xstyle=1, ystyle=1, xcharsize=ch, ycharsize=ch,$
;      thick=thick, position=pos[0,*], /noerase, xrange=xrange,
;      yrange=[0, max(snr)*1.1]
;loadct, 1
erase
chan=indgen(n)+1
if not defined(nocalib) then begin
   a=getcal_kstar_spat(shot)
   ra=(reform(a[0,*,0])-1800.)/(a[0,11,0]-1800.)
   chan=ra
   xrange=[min(chan),max(chan)]
endif else begin
   xrange=[n,1]
endelse
pstyle=-4
vector=[[fluct_amp_tot*100],[noise_level*100]]
yrange=[0.001, 1.1*max(vector)]
plot, chan, fluct_amp_tot*100, xtitle=xtitle, ytitle='Fluctuation!C amplitude !C (full spectrum) [%]', title='Fluctuation amplitude for shot '+strtrim(shot,2),$
      xstyle=1, ystyle=1, xcharsize=ch, ycharsize=ch, thick=thick, position=pos[2,*], /noerase, xrange=xrange, yrange=yrange, ylog=ylog, psym=pstyle
oplot, chan, noise_level*100, thick=thick, color=128, psym=pstyle

vector=[[fluct_amp_low*100],[noise_level_low*100]]
yrange=[0.001, 1.1*max(vector)]
plot, chan, fluct_amp_low*100, xtitle=xtitle, ytitle='Fluctuation!C amplitude !C (1kHz-10kHz) [%]', title='Fluctuation amplitude for shot '+strtrim(shot,2),$
      xstyle=1, ystyle=1, xcharsize=ch, ycharsize=ch, thick=thick, position=pos[1,*], /noerase, xrange=xrange, yrange=yrange, ylog=ylog, psym=pstyle
oplot, chan, noise_level*100, thick=thick, color=128, psym=pstyle

vector=[[fluct_amp_high*100],[noise_level_high*100]]
yrange=[0.001, 1.1*max(vector)]
plot, chan, fluct_amp_high*100, xtitle=xtitle, ytitle='Fluctuation!C amplitude !C (10kHz-100kHz) [%]', title='Fluctuation amplitude for shot '+strtrim(shot,2),$
      xstyle=1, ystyle=1, xcharsize=ch, ycharsize=ch, thick=thick, position=pos[0,*], /noerase, xrange=xrange, yrange=yrange, ylog=ylog, psym=pstyle
oplot, chan, noise_level*100, thick=thick, color=128, psym=pstyle
hardfile, 'kstar_basic_parameters_'+strtrim(shot,2)+'.ps'
stop
end

;Good parameters: 
;calculate_kstar_snr,7873,timerange=[3,5],channel='bes-2-*', avg=0 core
;calculate_kstar_snr,7879,timerange=[4,6],channel='bes-1-1', avg=0 edge
