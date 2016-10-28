;********************************************************************************************************
;
;    Name: TEST_BICOHERENCE
;
;    Written by: Laszlo Horvath 2010
;
;
;  SHORT MANUAL
;  ------------
;
;
; PURPOSE
; =======
;
;  This program tests the BICOHERECNE SUITE.
;  After every major correction must run this program and compare with *********
;
; USAGE
; =====
;
;  test_bicoherence
;
;  Arguments:
;  Switches:
;  Parameters:
;
; SWITCHES
; ========
;
; NEEDED PROGRAMS:
; ================
;
;  i2str.pro
;  plot_bicoherence.pro
;  sxr_bicoherence.pro
;
;********************************************************************************************************


pro test_bicoherence

;QUERY TIME
;--------------------------------------------------------------------------------------------------------


  time=bin_date(systime())
  time=i2str(time[3],digit=2)+':'+i2str(time[4],digit=2)


;TESTING HARMONIC OSCILLATORS
;--------------------------------------------------------------------------------------------------------


  t=dindgen(65536)*0.001	;time ax
  dt=dindgen(512)*0.001		;period of a block

;generate phases of oscillators (linear in every block)
  ;phi_1
    dphi_1=0.5*randomn(10,128,/NORMAL,/DOUBLE)	;variation of phase
    phi_1=dindgen(65536)	;initializing phase vector
      phi_1[0]=0
      phi_1[0:511]=dphi_1[0]*dt
      for i=1L,127L do begin
	phi_1[i*512:(i+1)*512-1]=phi_1[i*512-1]+dphi_1[i]*dt
      end

  ;phi_2
    dphi_2=0.5*randomn(11,128,/NORMAL,/DOUBLE)	;variation of phase
    phi_2=dindgen(65536)	;initializing phase vector
      phi_2[0]=0
      phi_2[0:511]=dphi_2[0]*dt
      for i=1L,127L do begin
	phi_2[i*512:(i+1)*512-1]=phi_2[i*512-1]+dphi_2[i]*dt
      end

  ;phi_3
    dphi_3=0.5*randomn(12,128,/NORMAL,/DOUBLE)	;variation of phase
    phi_3=dindgen(65536)	;initializing phase vector
      phi_3[0]=0
      phi_3[0:511]=dphi_3[0]*dt
      for i=1L,127L do begin
	phi_3[i*512:(i+1)*512-1]=phi_3[i*512-1]+dphi_3[i]*dt
      end


;Calculate bicoherence of phase coupled oscillators

  ;generate data vector of coupled oscillators
    data=sin(2*!DPI*100*t+phi_1)+sin(2*!DPI*170*t+phi_2)+sin(2*!DPI*270*t+phi_1+phi_2)+0.1*randomn(9,n_elements(t),/NORMAL,/DOUBLE)
  ;calculate and plot bicoherence - HANNING 512
    plot_bicoherence, data, t, 512, shotnumber='001', channelname='Coupl.Osc.-HANNING-512', ID='test_bicoherence-'+time
  ;calculate and plot bicoherence - HANNING 256
    plot_bicoherence, data, t, 256, shotnumber='002', channelname='Coupl.Osc.-HANNING-256', ID='test_bicoherence-'+time
  ;calculate and plot bicoherence - BOXCAR 512
    plot_bicoherence, data, t, 512, shotnumber='003', channelname='Coupl.Osc.-BOXCAR-512', ID='test_bicoherence-'+time, hann=0

;Calculate bicoherence of uncoupled oscillators

  ;generate data vector of uncoupled oscillators
    data=sin(2*!DPI*100*t+phi_1)+sin(2*!DPI*170*t+phi_2)+sin(2*!DPI*270*t+phi_3)+0.1*randomn(9,n_elements(t),/NORMAL,/DOUBLE)
  ;calculate and plot bicoherence - HANNING 512
    plot_bicoherence, data, t, 512, shotnumber='004', channelname='UnCoupl.Osc.-HANNING-512', ID='test_bicoherence-'+time
  ;calculate and plot bicoherence - HANNING 256
    plot_bicoherence, data, t, 256, shotnumber='005', channelname='UnCoupl.Osc.-HANNING-256', ID='test_bicoherence-'+time
  ;calculate and plot bicoherence - BOXCAR 512
    plot_bicoherence, data, t, 512, shotnumber='006', channelname='UnCoupl.Osc.-BOXCAR-512', ID='test_bicoherence-'+time, hann=0


;TESTING AUG-SXR SIGMALS
;--------------------------------------------------------------------------------------------------------


  ;calculate bicoherence, using frequency switch
    sxr_bicoherence, 20975, 'AUG_SXR/J_053', [1.395d0,1.425d0], 2048, ID='test_bicoherence-'+time, frequency=50


end