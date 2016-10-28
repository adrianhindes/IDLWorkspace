;+
; NAME:
;	COH_TEST
;
; PURPOSE:
;	This procedure calculate normal coherence to test signals made with random_phase.
;
;-

pro coh_test

coherence=0

    for i=0,9 do begin

      print, i
      A = 5
      B = 3
      s = 0
      Wa = 0.1
      Wb = 0.1
      dev1 = 3000
      sfreq = 4d5
      trange = [0,0.01]
      f1 = 50d3
      length = 200

      phase_in1 = random_phase(dev = dev1, trange = trange, sfreq = sfreq, length = length, timeax = t)
;      plot, phase_in1
      phase_out1 = random_phase(dev = dev1, trange = trange, sfreq = sfreq, length = length, timeax = t)

      in = A*sin(2*!DPI*f1*t+phase_in1) + Wa*randomn(seed, n_elements(t), /normal)
      out = B*s*sin(2*!DPI*f1*t+phase_in1) + B*(1-s)*sin(2*!DPI*f1*t+phase_out1) + Wb*randomn(seed, n_elements(t), /normal)

!P.Multi = [0, 1, 3] 
!P.Font = 0 
PLOT, in[0:100], Title = 'in'
PLOT, out[0:100], Title = 'out'

      cohphase=gp_cohphasef(in,out,200,hann=0)
      coh=cohphase[*,0]
      phase=cohphase[*,1]

      coherence=coherence+coh
    end

  coherence=coherence/double(10)
plot, coherence


end