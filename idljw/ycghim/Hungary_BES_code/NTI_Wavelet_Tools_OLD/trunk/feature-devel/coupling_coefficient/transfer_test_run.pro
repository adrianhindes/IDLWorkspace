;+
; NAME:
;	TRANSFER_TEST_RUN
;
; PURPOSE:
;	This procedure was written to test transfer function of NTI Wavelet Tools r395
;
;-

pro transfer_test_run

s = 0.

A = 6
B = 30

Wa = 0.2
Wb = 0.3

f1 = 50d3
f2 = 100d3
f3 = 150d3
dev1 = 300
dev2 = 1000
dev3 = 3000


trange = [0, 0.1]
sfreq = 4d5*5
length = 200*5
stft_fres = 2000

sum_transfers = fltarr(40000,2000)

for j=0,0 do begin

phase_in1 = random_phase(dev = dev1, trange = trange, sfreq = sfreq, length = length, timeax = t)
plot, t, phase_in1
phase_in2 = random_phase(dev = dev2, trange = trange, sfreq = sfreq, length = length, timeax = t)
phase_in3 = random_phase(dev = dev3, trange = trange, sfreq = sfreq, length = length, timeax = t)

phase_out1 = random_phase(dev = dev1, trange = trange, sfreq = sfreq, length = length, timeax = t)
phase_out2 = random_phase(dev = dev2, trange = trange, sfreq = sfreq, length = length, timeax = t)
phase_out3 = random_phase(dev = dev3, trange = trange, sfreq = sfreq, length = length, timeax = t)

;print, "phase_int: ", max([phase_in,phase_out])-min([phase_in,phase_out])

;plot, phase_in
;oplot, phase_out

in = A*sin(2*!DPI*f1*t+phase_in1) + A*sin(2*!DPI*f2*t+phase_in2) + A*sin(2*!DPI*f3*t+phase_in3) + Wa*randomn(seed, n_elements(t), /normal)
out = B*s*sin(2*!DPI*f1*t+phase_in1) + B*(1-s)*sin(2*!DPI*f1*t+phase_out1) + B*s*sin(2*!DPI*f2*t+phase_in2) + B*(1-s)*sin(2*!DPI*f2*t+phase_out2) + B*s*sin(2*!DPI*f3*t+phase_in3) + B*(1-s)*sin(2*!DPI*f3*t+phase_out3) + Wb*randomn(seed, n_elements(t), /normal)

data = fltarr(n_elements(t), 2)
data(*,0) = in
data(*,1) = out

nti_wavelet_main,$
  ;INPUT:
    data=data, expname='transfer_test', shotnumber=77777, channels=["INPUT","OUTPUT"], dtimeax = t,$
    channelpairs_used=["INPUT","OUTPUT"], transf_selection=1, cwt_selection=0, stft_selection=1,$
    stft_window="Gauss", stft_length=length, stft_step=1, freq_min=0, freq_max=200,$
    crosstr_selection=1, coh_selection=1, coh_avr=20, mode_selection=0,$
  ;OUTPUT
    timeax=transf_timeax, freqax=transf_freqax, scaleax=transf_scaleax, transforms=transforms,$
    smoothed_apsds=smoothed_apsds, crosstransforms=crosstransforms,$
    smoothed_crosstransforms=smoothed_crosstransforms, coherences=coherences,$
    transfers=transfers, $
  ;INPUT - OUTPUT
    stft_fres=stft_fres

sum_transfers = sum_transfers + abs(transfers(0,0,*,*))

endfor

transfers = fltarr(2,1,40000,2000)
transfers(0,0,*,*) = sum_transfers*0.1
transfers(1,0,*,*) = sum_transfers*0.1

nti_wavelet_plot, $
  ; Inputs - calculation results
    timeax=transf_timeax, freqax=transf_freqax, scaleax=transf_scaleax,$
    transforms=transforms, smoothed_apsds=smoothed_apsds, crosstransforms=crosstransforms,$
    smoothed_crosstransforms=smoothed_crosstransforms, coherences=coherences,$
    transfers=transfers, $
  ; Inputs - processing parameters
    expname='transfer_test', shotnumber=77777,$
    channels=["INPUT","OUTPUT"], channelpairs_used=["INPUT","OUTPUT"],$
    cwt_selection=0, stft_selection=0, stft_window="Gauss",$
    stft_length=length, stft_fres=stft_fres, stft_step=1, freq_min=0, freq_max=200, coh_avr=20,$
  ; Inputs - visualization parameters
    transf_selection=1, transf_smooth=1,$
    transf_energy=1, transf_phase=0,$
    transf_cscale=0.2, crosstr_selection=1,$
    crosstr_smooth=1, crosstr_energy=1,$
    crosstr_phase=0, crosstr_cscale=0.2,$
    coh_selection=1, coh_all=1, coh_avg=0,$
    coh_min=0, mode_selection=0,$
    mode_cohlimit=0, mode_powlimit=0,$
    mode_qlimit=0, linear_freqax=0,$
  ; Save path
    savepath="./save_data",$
  ; Other
    startpath="/home/horla/svn-sandbox/NTI_Wavelet_Tools/branches/NTI_Wavelet_transfer_function_branch/", version='0'


stop


return

end