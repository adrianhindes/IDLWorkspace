pro calculate_fluct_amplitude, shot, timerange=timerange, bg_timerange=bg_timerange, linear_fit=linear_fit,$
                               fres=fres, ftype=ftype, freq_min=freq_min, freq_max=freq_max, band_w=band_w,$
                               plot=plot, timefile=timefile, bg_timefile=bg_timefile,$
                               compensate_spect=compensate_spect, yrange=yrange

default, shot, 11404
default, freq_min, 200e3
default, freq_max, 250e3
if not defined(timefile) then default, timerange, [3.15,3.3]
default, lowrange, [1e3,10e3]
default, highrange, [10e3,freq_min]
default, band_w, 500e3
default, charsize, 1.5
default, thick, 2
default, linear_fit, 0
default, ftype, 1
default, fres, 20
default, plot, 0
default, radial_arr, 2
default, compensate_spect, 1
default, plot_snr, 0
default, subtract_bg, 1
n=16

ch=charsize
hardon, /color
set_plot_style, 'foile_kg_eps'

snr=dblarr(n)
fluct_amp_tot=dblarr(n)
noise_amp_tot=dblarr(n)
loadct, 5

if (keyword_set(timefile)) then begin
 tfile=dir_f_name('time',timefile)
    times=loadncol(tfile,2,/silent,errormess=errormess)
    if (errormess ne '') then begin
      if (not keyword_set(silent)) then print,errormess
      outcorr=0
      return
    endif
    ind=where((times(*,0) ne 0) or (times(*,1) ne 0))
    times=times(ind,*)
endif

if (keyword_set(bg_timefile)) then begin
 tfile=dir_f_name('time',bg_timefile)
    bg_times=loadncol(tfile,2,/silent,errormess=errormess)
    if (errormess ne '') then begin
      if (not keyword_set(silent)) then print,errormess
      outcorr=0
      return
    endif
    ind=where((bg_times(*,0) ne 0) or (bg_times(*,1) ne 0))
    bg_times=bg_times(ind,*)
endif

if keyword_set(nocalc) then begin
    restore, 'tmp/fluct_amplitude_'+strtrim(shot,2)+'.sav'
endif else begin
    for i=0,n-1 do begin
       channel='BES-'+strtrim(radial_arr,2)+'-'+strtrim(i+1,2)
       if defined(timefile) then begin
         ;calculate the average signal level when a timefile is present
          n_t=n_elements(times[*,0])
          d2=dblarr(n_t,2)
          for j=0,n_t-1 do begin
            get_rawsignal, shot, channel, t, d, /nocalib, timerange=reform(times[j,*])
              d2[j,0]=total(d)
              d2[j,1]=n_elements(d)
          endfor
          if defined(bg_timefile) then begin
              bg_n_t=n_elements(bg_times[*,0])
              bg_d2=dblarr(bg_n_t,2)
              for j=0,bg_n_t-1 do begin
                get_rawsignal, shot, channel, t, d, /nocalib, timerange=reform(bg_times[j,*])
                bg_d2[j,0]=total(d)
                bg_d2[j,1]=n_elements(d)
              endfor
              signal=total(d2[*,0])/total(d2[*,1])-total(bg_d2[*,0])/total(bg_d2[*,1])
          endif else begin
            signal=total(d2[*,0])/total(d2[*,1])
          endelse
       endif else begin
          get_rawsignal, shot, channel, t, d, /nocalib, timerange=timerange
          if defined(bg_timerange) then begin
            get_rawsignal, shot, channel, t, bg_d, /nocalib, timerange=bg_timerange
            signal=mean(d)-mean(bg_d)
          endif else begin
            signal=mean(d)
          endelse
       endelse
       
       fluc_correlation, shot, timefile, refchan=channel, timerange=timerange, /nocalib, /auto,$
                         outpower=signal_spect, outfscale=outf, /noplot, ftype=ftype, interval_n=1, $
                         frange=[1e3,1e6], /ytype, /noerror, yrange=[1e-11,1e-7], fres=fres, /plot_power, timefile
    
       n=n_elements(outf)
       f_res_vect=outf[1:n-1]-outf[0:n-2]
       
       if keyword_set(linear_fit) then begin
          ind_noise=where(outf gt freq_min and outf lt freq_max)
          ind_signal=where(outf lt freq_min)
          noise_spect=dblarr(n_elements(signal_spect))
          noise_spect[0:n_elements(ind_signal)-1]=mean(signal_spect(ind_noise))
          noise_spect[n_elements(ind_signal):n_elements(signal_spect)-1]=signal_spect[n_elements(ind_signal):n_elements(signal_spect)-1]
          noise_spect[where(noise_spect gt signal_spect)]=signal_spect[where(noise_spect gt signal_spect)]      
       endif else begin
          ind=where(outf gt freq_min and outf lt freq_max)
          a=min(abs(outf-band_w),ind_bandw)
          p2=mpfitfun('rc_fit',outf[ind],signal_spect[ind],0.001,[band_w,signal_spect[ind_bandw]])
          n=n_elements(outf[where(outf lt freq_min)])
          ind_gt=where(outf gt freq_min)
          n_gt=n_elements(ind_gt)
          noise_spect=[rc_fit(outf[0:n-1],p2),signal_spect[ind_gt]]
          if keyword_set(compensate_spect) then begin
            ind_gt=where(noise_spect gt signal_spect)
            noise_spect[ind_gt]=signal_spect[ind_gt]
          endif
        endelse
                  
        loadct, 5
        
        ; This part subtracts the signal coming from the NBI vibration
        a=min(abs(outf-4.9e3),ind_5_1)
        a=min(abs(outf-5.1e3),ind_5_2)
        a=min(abs(outf-10e3),ind_10)
        a=min(abs(outf-15e3),ind_15)
        
        signal_spect[ind_5_1:ind_5_2]=mean([signal_spect[ind_5_1-2],signal_spect[ind_5_1-1],signal_spect[ind_5_2+1],signal_spect[ind_5_2+2]])
        signal_spect[ind_10]=mean([signal_spect[ind_10-2],signal_spect[ind_10-1],signal_spect[ind_10+1],signal_spect[ind_10+2]])
        signal_spect[ind_15]=mean([signal_spect[ind_15-2],signal_spect[ind_15-1],signal_spect[ind_15+1],signal_spect[ind_15+2]])
    
        signal_spect[ind_10]=(signal_spect[ind_10-1]+signal_spect[ind_10+1])/2
        signal_spect[ind_15]=(signal_spect[ind_15-1]+signal_spect[ind_15+1])/2
        
        ;Plotting each spectra for checking the estimated noise spectrum
        if keyword_set(plot) then begin
          if keyword_set(timefile) then begin
            timetitle=' Time: timefile '+timefile
          endif else begin
            timetitle=' Time: '+strtrim(timerange[0],2)+' - '+strtrim(timerange[1],2)
          endelse
          plot, outf, signal_spect, /xlog, /ylog, /ystyle, /xstyle, xtitle='Frequency [Hz]', ytitle='Power', title='Shot: '+strtrim(shot,2)+$
                ' Channel: '+channel+timetitle
          oplot, outf, noise_spect, color=100
          erase
        endif
    ;This part will perform the subtraction of the NBI control peaks
    ;because they do not contribute to the fluctuation amplitude.
    
       noise=sqrt(total(noise_spect*f_res_vect)*2)
       snr[i]=signal/noise
       
       signal_spect_signal=signal_spect-noise_spect
       
       ind_fluct=where(outf ge lowrange[0] and outf le highrange[1])
       ampl_tot=sqrt(total(signal_spect_signal[ind_fluct]*f_res_vect[ind_fluct])*2)
       fluct_amp_tot[i]=ampl_tot/signal
    
       noise_amp_tot[i]=noise/signal
       print, channel
    endfor
    save, fluct_amp_tot, noise_amp_tot, chan, snr, filename='tmp/fluct_amplitude_'+strtrim(shot,2)+'.sav'

endelse

if not defined(nocalib) then begin
   a=getcal_kstar_spat(shot)
   ra=(reform(a[0,*,0])-1800.)/(a[0,11,0]-1800.)
   chan=ra
   xrange=[min(chan),max(chan)]
   xtitle='Normalized minor radius'
endif else begin
   chan=indgen(n)+1
   xrange=[n,1]
   xtitle='Radial channel number'
endelse
pstyle=-4
vector=[[fluct_amp_tot*100],[noise_amp_tot*100]]

if not defined(yrange) then yrange=[0.001, 1.1*max(vector)]

plot, chan, fluct_amp_tot*100, xtitle=xtitle, ytitle='Fluctuation!C amplitude !C (full spectrum) [%]', title='Fluctuation amplitude for shot '+strtrim(shot,2),$
      xstyle=1, ystyle=1, xcharsize=ch, ycharsize=ch, thick=thick, /noerase, xrange=xrange, yrange=yrange, ylog=ylog, psym=pstyle
oplot, chan, noise_amp_tot*100, thick=thick, color=128, psym=pstyle

if keyword_set(plot_snr) then begin
  erase
  plot, chan, snr, xtitle=xtitle, ytitle='SNR', title='Signal to noise ratio for shot '+strtrim(shot,2),$
        xstyle=1, ystyle=1, xcharsize=ch, ycharsize=ch, thick=thick, /noerase, xrange=xrange, yrange=[0,max(snr)], psym=pstyle
endif
hardfile, 'fluct_amplitude_'+strtrim(shot,2)+'.ps'
end