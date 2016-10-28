pro chirp_analysis_stft

;Input:
trange = [0.642, 0.662]	; Time interval of interest
freq_max = 100.		; Downsampling data to this value [in kHz]
blocksize = 512		; Blocksize
hann = 1		; Use Hanning window
denoise = 0.01		; Filtering WTN transform
err = 0.		; Error of the measured signal (fictive)

;STFT Parameters
stft_length = 100
stft_fres = 2000
stft_step = 1
freq_min = 60
freq_max = 100

;Ridge following parameters
delta = 5.
start_freq = [80., 82.]
ridge_treshold = 0.1
waiting = 0.001

;Restore data saved with MTR (via NTI Wavelet Tools)
;restore, 'AUGD_28881_SXR_0.6s-0.7s.sav'
;restore, 'AUGD_28881_SXR_H-I-J_0.6s-0.7s_OK.sav'
;restore, 'AUGD_28881_SXR_J50-J55_0.6s-0.7s.sav'
restore, 'AUGD_28881_bal_tor_0.0s-1.0s.sav'

;Cut ROI
data = data(where((timeax ge trange(0)) AND (timeax le trange(1))),*)
timeax = timeax(where((timeax ge trange(0)) AND (timeax le trange(1))))

;Run nti_wavelet_main
  nti_wavelet_main,$
  ; Input
    data=data, dtimeax=timeax, chpos=0.*phi, expname=expname, shotnumber=shotnumber, $
    transf_selection=1, cwt_selection=0, stft_selection=1, stft_details=1, $
    stft_length=stft_length, stft_fres=stft_fres, stft_step=stft_step, $
    freq_min=freq_min, freq_max=freq_max, $
    crosstr_selection=0, coh_selection=0, $
    transfer_selection=0, mode_selection=0, $
    error = 0, errdata = err*data, $
    ; Output
    timeax=timeax, freqax=freqax, scaleax=scaleax, transforms=transforms, smoothed_apsds=smoothed_apsds,$
    crosstransforms=crosstransforms, smoothed_crosstransforms=smoothed_crosstransforms,$
    coherences=coherences, transfers=transfers, modenumbers=modenumbers, qs=qs, $
    channels=channels, channelpairs_used=channelpairs_used, $
    stft_window=stft_window, detailed_transforms=detailed_transforms
    
;Energy density from STFT
stfteds = detailed_transforms.ed.value

;Calculate matrix, to get amplitudes
dt = (timeax(n_elements(timeax)-1)-timeax(0))/(n_elements(timeax)-1)
df = (freqax(n_elements(freqax)-1)-freqax(0))/(n_elements(freqax)-1)
sigma_t = stft_length/stft_step/2.*dt
sigma_f = 1./(2*!pi*sigma_t)
stftamps = sqrt(2*stfteds*sigma_f*sqrt(!pi))

;Find ridge
chnum = n_elements(channels)
ridges = intarr(chnum, n_elements(timeax))

for j = 0, chnum-1 do begin

nti_wavelet_ridge_follower, reform(stfteds(j,*,*)), $
  xaxis = timeax, yaxis = freqax, $
  xrange_index = [stft_length, n_elements(timeax) - stft_length - 1], start_y = start_freq, $
  index_bandwidth = 10, $
  ridge_index = ridge_index, ridge_treshold = 0.15, $
  inwaiting = waiting

ridges(j, *) = ridge_index

endfor

;Estimation RMS of background noise
;----------------------------------

;Choose freqency and time interval
noise_freq = [85., 95.]
noise_time = [0.645, 0.660]

noise_ind_freq = [0,0]
noise_ind_freq(0) = where( min(freqax - noise_freq(0), /abs) eq (freqax - noise_freq(0)) )
noise_ind_freq(1) = where( min(freqax - noise_freq(1), /abs) eq (freqax - noise_freq(1)) )
noise_freq(0) = freqax(noise_ind_freq(0))
noise_freq(1) = freqax(noise_ind_freq(1))

noise_ind_time = [0,0]
noise_ind_time(0) = where( min(timeax - noise_time(0), /abs) eq (timeax - noise_time(0)) )
noise_ind_time(1) = where( min(timeax - noise_time(1), /abs) eq (timeax - noise_time(1)) )
noise_time(0) = timeax(noise_ind_time(0))
noise_time(1) = timeax(noise_ind_time(1))

;Calculate energy
noise_energy = dblarr(chnum)
noise_rms = dblarr(chnum)
errs = 0.*stfteds
for i = 0, chnum - 1 do begin
;  noise_energy(i) = total(stfteds(i,noise_ind_time(0):noise_ind_time(1),noise_ind_freq(0):noise_ind_freq(1)))*dt*df
;  noise_rms(i) = noise_energy(i)/(noise_time(1) - noise_time(0))/((noise_freq(1) - noise_freq(0)))
  noise_rms(i) = mean(stfteds(i,noise_ind_time(0):noise_ind_time(1),noise_ind_freq(0):noise_ind_freq(1)))
  errs(i,*,*) = sqrt((sigma_f*sqrt(!dpi))/(2*reform(stfteds(i,*,*))))*noise_rms(i)
endfor

info = $
	'STFT' + $
	'!Cwinsize: ' + nti_wavelet_i2str(stft_length) + '!C ' + pg_num2str(dt*stft_length/stft_step) + 's' + $
	'!Cfres: ' + nti_wavelet_i2str(stft_fres) + $
	'!Cstep: ' + nti_wavelet_i2str(stft_step)

nti_wavelet_plot_1d, timeax, freqax(ridges), yrange = [65, 85], legend = channels, $
  title = 'Mode frequency', xtitle = 'Time [s]', ytitle = 'Frequency [kHz]', info = info

;Calculate amplitudes
amplitudes = 0.*ridges
errors = 0.*ridges
for l = 0, n_elements(ridges(*,0))-1 do begin
  for k = 0,n_elements(timeax)-1 do begin
    if not (min(ridges(*,k)) eq 0) then  begin
      amplitudes(l,k) = stftamps(l,k,ridges(l,k))
      errors(l,k) = errs(l,k,ridges(l,k))
    endif
  endfor
endfor

nti_wavelet_plot_1d, timeax, amplitudes, yrange = [0, max(amplitudes)+1], legend = channels, $
  title = 'Mode amplitude', xtitle = 'Time [s]', ytitle = 'Amplitude', info = info

rdg = reform(ridges(1,*))	;B31-03
save, timeax, freqax, rdg, filename = 'fit_freq.sav'

stop

goto, tudomilyetnemszabad

stop
  
;Plot radial eigenfunctions

legend = strarr(3)
legend(0) = pg_num2str(timeax(700), length = 7) + 's'
legend(1) = pg_num2str(timeax(800), length = 7) + 's'
legend(2) = pg_num2str(timeax(900), length = 7) + 's'

rho = [0.119517, 0.0167095, 0.0830215, 0.178076, 0.220166, $
  0.138398, 0.0526124, 0.0311640, 0.195174, 0.234195, 0.149670, $
  0.0551692, 0.0424668, 0.146960, 0.252934]
  
under = [2,3,7,8,12,13,14]                  
over = [0,1,4,5,6,9,10,11]
  

urho = rho(under)
orho = rho(over)

uamplitudes = amplitudes(under,*)
oamplitudes = amplitudes(over,*)
uerrors = errors(under,*)
oerrors = errors(over,*)

useq = sort(urho)
oseq = sort(orho)

urho = urho(useq)
orho = orho(oseq)

uamplitudes = uamplitudes(useq,*)
oamplitudes = oamplitudes(oseq,*)
uerrors = uerrors(useq,*)
oerrors = oerrors(oseq,*)

nti_wavelet_plot_1d, urho, transpose(uamplitudes(*,[700,800,900])), error = transpose(uerrors(*,[700,800,900])), $
  xdouble = orho, ydouble = transpose(oamplitudes(*,[700,800,900])), $
  xrange = [0.,0.3], yrange = [0,max(amplitudes)], legend = legend, $
  title = 'Radial eigenfunctions', xtitle = 'Rho', ytitle = 'Amplitude', info = info, psym = -2


stop

tudomilyetnemszabad: print, 'Hajrá...'

;Run nti_wavelet_plot
  nti_wavelet_plot, $
  ; Inputs - calculation results
    timeax=timeax, freqax=freqax, scaleax=scaleax, transforms=transforms, smoothed_apsds=smoothed_apsds,$
    crosstransforms=crosstransforms, smoothed_crosstransforms=smoothed_crosstransforms,$
    coherences=coherences, transfers=transfers, modenumbers=modenumbers, qs=qs,$
  ; Inputs - processing parameters
    expname=expname, shotnumber=shotnumber, channels=channels, channelpairs_used=channelpairs_used,$
    cwt_selection=0, $
    stft_selection=0, stft_window=stft_window, stft_length=stft_length, stft_fres=stft_fres,$
    stft_step=stft_step, freq_min=freq_min, freq_max=freq_max, $
  ; Inputs - visualization parameters
    transf_selection=1, transf_smooth=0, transf_energy=1,$
    transf_phase=0, transf_cscale=0.2,$
    crosstr_selection=0, crosstr_smooth=0, crosstr_energy=0,$
    crosstr_phase=0, crosstr_cscale=0,$
    coh_selection=0, transfer_selection=0, mode_selection=0, poster=1,$
  ; Paths
    startpath='/home/horla/Deep_svn/NTI_Wavelet_Tools/trunk/', savepath='./save_data', version='-', $
    ridges = freqax(ridges)

end