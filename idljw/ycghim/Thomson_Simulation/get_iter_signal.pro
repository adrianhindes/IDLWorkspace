FUNCTION get_iter_signal,t_e,n_e,derivative=derivative,plasma_noise=plasma_noise

; fundamental constants
c = 3e8
h = 6.6e-34
re = double(2.8179e-15)

; calibration constants
laser_energy = 5.0*0.5	; (energy [J]) * (transmission of laser energy)
scatlen = 0.067
f_number = 12.
qe = [0.04,0.04,0.04,0.04,0.03];*5	; quantum efficiency in each wavelength bin (multiplied by Nf^2)
t = 0.107			; transmission after scattering
noise_factor = 1.; 	sqrt(5)
nchannels = n_elements(qe)
lambda0 =  1060.
angle = !pi

; determine the polychromator transfer function
fitstruct = CREATE_STRUCT('angle',angle)
fitstruct = CREATE_STRUCT(fitstruct,'lambda0',lambda0)
fitstruct = CREATE_STRUCT(fitstruct,'cal_matrix_x',fltarr(1060,nchannels))
fitstruct = CREATE_STRUCT(fitstruct,'cal_matrix_y',fltarr(1060,nchannels))
fitstruct = CREATE_STRUCT(fitstruct,'cal_matrix_npts',REPLICATE(1060,nchannels))

FOR i =0,nchannels-1 DO fitstruct.cal_matrix_x(*,i) = findgen(1060)
fitstruct.cal_matrix_y(810:850,0) = qe(0)
;fitstruct.cal_matrix_y(800,0) = qe(0)
fitstruct.cal_matrix_y(765:790,1) = qe(1)
fitstruct.cal_matrix_y(700:765,2) = qe(2)
fitstruct.cal_matrix_y(550:700,3) = qe(3)
fitstruct.cal_matrix_y(380:550,4) = qe(4)

stop

; now calculate the number of scattered photons
dsdomg = re*re
del_omg = !pi/(4*f_number*f_number) ; 
ni = laser_energy*(lambda0*1e-9)/(c*h)
nscat =n_e*dsdomg*del_omg*scatlen*ni*T ; this is the number of photons seen before quantum efficency


signal = fltarr(nchannels)	; number of photons
dsignal_dte = fltarr(nchannels)
dsignal_dne = fltarr(nchannels)

For i =0, nchannels-1 do BEGIN
	x = fitstruct.cal_matrix_x(0:fitstruct.cal_matrix_npts[i]-1,i)
	y = fitstruct.cal_matrix_y(0:fitstruct.cal_matrix_npts[i]-1,i)
	x_width = x[1]-x[0]
	; The x-array has to be equally spaced. This is done in ctm_data_collect
	signal(i) = TOTAL(y*nscat*selden_matoba(t_e,x,angle,lambda0)*(x/lambda0),/nan)*x_width/lambda0
	dsignal_dte(i) = TOTAL(y*nscat*selden_matoba(t_e,x,angle,lambda0,/dte)*(x/lambda0),/nan)*x_width/lambda0
        dsignal_dne(i) = TOTAL(y*nscat*selden_matoba(t_e,x,angle,lambda0)*(x/lambda0),/nan)*x_width/lambda0/n_e

ENDFOR; {i} main loop

IF KEYWORD_SET(plasma_noise) THEN BEGIN	
	polariser_transmission = 0.4 ; includes some vignetting
	f_number_detector = 0.7 ; detector F/#
	del_omg_detector = !pi/(4*f_number_detector*f_number_detector) ;
	detector_area = !pi*1.8*1.8/4.; cm^2
	c_emissivity = 9.587e-14
	te_core = 40000.
	ne_core = 3e13 ; this should be in cm^3
;	n_e_cm = ne_core *1e-6
	z_eff = 2
	integration_time = 1/(c/(2*scatlen))
	
	gaunt1 = 0.6183
	gaunt0 = 0.0821
	r_minor = 200. 				; ITER minor radius
	r_int = r_minor*(findgen(100)+1)/100 	
	t_e_r = te_core*(1-(r_int/r_minor)^2)	; Te(r)
;	t_e_r = replicate(10000,n_elements(t_e_r))	flat t_e profile of 10KeV for test similar to D. Hare
	y_int = (gaunt1*alog(t_e_r)-gaunt0)/sqrt(t_e_r)
	finite_ind = where(finite(y_int) eq 1)
	gaunt_integral = 2*int_tabulated(r_int(finite_ind),y_int(finite_ind))

	multiplication_factor = 2. ; this accounts for the fact that there will be line emission as well as plasma light

	For i =0, nchannels-1 do BEGIN
		x = fitstruct.cal_matrix_x(0:fitstruct.cal_matrix_npts[i]-1,i)
		y = fitstruct.cal_matrix_y(0:fitstruct.cal_matrix_npts[i]-1,i)
		x_width = x[1]-x[0]
		; The x-array has to be equally spaced. This is done in ctm_data_collect
		; signal is now the number of background photons in each channel
 		signal(i) = TOTAL(y*t*polariser_transmission*detector_area*del_omg_detector*$ 		; quantum efficiency is in transmission
			c_emissivity*ne_core*ne_core*z_eff*(1/(x))*gaunt_integral*integration_time*multiplication_factor,/nan)/(4*!pi*x_width)
			; result is photons /nm - so (lambda or x) should be in nm
			; 0.001 converts ne_core*ne_core to m^-3 cm^-3 since detector area and guant integral together give m^3
	ENDFOR


ENDIF


   
	IF KEYWORD_SET(derivative) THEN RETURN,[[dsignal_dte],[dsignal_dne]]
	RETURN,signal
END
