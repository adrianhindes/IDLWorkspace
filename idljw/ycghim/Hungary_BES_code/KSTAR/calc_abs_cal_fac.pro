function calc_abs_cal_fac, shot, det=det,errormess=errormess
;***************************************************************
;*                      calc_abs_cal_fac                       *
;***************************************************************
;* Calculate the absolute calibration factor for the KSTAR BES.*
;* This factor is in [photon number/Vs] so the signal from     *
;* get_rawsignal has to be multiplied with this                *
;***************************************************************
;INPUTs:                                                       *
;         shot: shotnumber @ KSTAR                             *
;         /det: gives the calibration factor for the photon    *
;               flux at the detector (optional)                *
;OUTPUT:                                                       *
;         c_out: calibration factor                            *
;                                                              *
;***************************************************************

errormess = ''
default,datapath,local_default('datapath')
if (datapath eq '') then datapath = 'data'

trans_imp_gain=3.4d6 ;[V/A] tans impedance gain of the operational amplifier
q_e=1.602d-19 ;[C/e-] charge of the electron
quantum_eff=0.858974 ;[photon detected/photon in] quantum efficiency read out from the datasheet at 661.5nm (max of filter)
opt_trans=0.98^8 ; [1] optical throughput of the optics (should be calculated more accurately)
obj_trans=0.96 ;the transmittance of the Nikon lense at 662nm [http://www.lenstip.com/upload2/17042_nik_50_trans.jpg]
opt_throughput=obj_trans*opt_trans
;The following section calculates the internal gain of the APD detector
load_config_parameter,shot,'APDCAM','DetectorBias',datapath=datapath,output_struct=d_bias,errormess=errormess ;returns the bias voltage as integer d_bias.value
if (errormess ne '') then return,0
;The following array contains the gain calibration value
a=0.86        ;The following coefficients are from fitting
b=-0.0111
c=4.14857d-5
x=double(d_bias.value)
int_gain=exp(a+b*x+c*x^2)*2 ; [] the internal gain of the APD
;print, 'Internal gain is '+strtrim(int_gain,2)
cal_coeff=1./trans_imp_gain/int_gain/q_e/quantum_eff
if (keyword_set(det)) then return, cal_coeff else return, cal_coeff/opt_throughput
end