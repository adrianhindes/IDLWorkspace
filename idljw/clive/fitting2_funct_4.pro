pro exp_fit,v,fit_params,i
i = fit_params(0) * (1-exp( (v-fit_params(1))/fit_params(2)))
end

;fit_params=[30., -80., 20.]  ;Isat, Ufl, Te


function avg,x
return,mean(x)
end

function str,x,format=format
return,string(x,format=format)
end
        ;the same like fitting2_funct but it subscribes Isat for the log fit
;CURRENT IN [A] NOT IN [MA]
;change from version 3: in current - instead of current_corrected we use current2
;doesn't really work
;function fitting2_funct_3, shot_number=shot_number, cut_data_start=cut_data_start, number_of_cycles=number_of_cycles, cut_fit2=cut_fit2
;##########################################################################################
;DEFINITIONS:------------------------------------------------------------------------------
;comment if you use it as a function:
shot_number=76465;76465;76474;75918;906
cut_data_start=4.;28.5
number_of_cycles=3
cut_fit2=[-10.,20.]  ;after subscr. Isat and putting the data to log scale, fitting the line
;----------------------
;for fitting:
;cut_for_Isat=-50.   ;voltage cut for eval. the Isat (will cut from -everything to this number)
sweeping_frequency=3. ;in kHz
cut_data=[cut_data_start, cut_data_start+(number_of_cycles/sweeping_frequency)]
B_const1=0.;1.e-2;1.056e-6
B_const2=0.;000315
;slicing of the IV characteristic:
slice_width=3.  ;[V]
;fitting tresholds:
fit_treshold1_Isat=-20.
fit_treshold2_low_cut_off=8.
;-------------------------------------
print_pictures=0
;path_picture='c:\data\ostrovy pokladu\probes and gun\ball pen probe\idl\fitting2\output\turbo\'
path_picture='c:\data\temp\clive\'
;------------------------------------------------------------------------------------------
device, retain=2, decomposed=0   
loadct, 5
;END OF DEFINITIONS------------------------------------------------------------------------
;##########################################################################################

;##########################################################################################
;RESTORING THE DATA:-----------------------------------------------------------------------
;restore, 'c:\data\ostrovy pokladu\probes and gun\ball pen probe\idl\data\'+str(shot_number,format='(i5)')+'_DASdata.sav'
restore, '/home/prl/jana/probe/idl/data/'+str(shot_number,format='(i5)')+'_DASdata.sav',/verb
stop
;END OF RESTORING--------------------------------------------------------------------------
;##########################################################################################

;##########################################################################################
;PROCESSING:-------------------------------------------------------------------------------
shot_str=str(shot_number)
dt=(time_voltage[10]-time_voltage[0])/10.
cut_ind_fit=where(time_voltage ge cut_data[0] and time_voltage le cut_data[1])

;correction of the voltage:
;a) Ufl pin:
capacity=2.e-9
resistivity=1./(1./25.e3+1./1.e6)
Ufl_derivation=deriv(time_voltage, voltage_pin2)
voltage_pin2_corrected=voltage_pin2+capacity*resistivity*Ufl_derivation*1.e3
;b) swept voltage:
voltage_corrected=voltage*10.-voltage_pin2_corrected

;correcting of the current:
;low_pass_cut_fft, data=current, dt=dt, frequency=20000., time_plot=time_voltage, window_number=8, plot_label=''
current_corrected=current*1.e-3 ;in [A]

voltage_derivation=deriv(time_voltage, voltage_corrected)
current1=current_corrected-B_const1*voltage_derivation
current2=current1-B_const2*voltage_corrected

dt=(time_voltage[1000]-time_voltage[0])/1000.

;====================================================
;fitting:
;slicing of the IV character.:
n_slices=ceil( (max(voltage_corrected[cut_ind_fit])-min(voltage_corrected[cut_ind_fit]))/slice_width )
voltage_avg=fltarr(n_slices)
current_for_slicing=current_corrected[cut_ind_fit]
slices_min=findgen(n_slices)*slice_width+min(voltage_corrected[cut_ind_fit])
slices_max=findgen(n_slices)*slice_width+min(voltage_corrected[cut_ind_fit])+slice_width
slices_middle=(slices_min+slices_max)/2.
for i=0, n_slices-1 do begin
  pomoc=current_for_slicing[where(voltage_corrected[cut_ind_fit] ge slices_min[i] and voltage_corrected[cut_ind_fit] lt slices_max[i])]
  if n_elements(pomoc) eq 1 then voltage_avg[i]=pomoc else voltage_avg[i]=avg(pomoc)
  endfor

;normalni
;x_for_fit=voltage_corrected[cut_ind_fit]
;y_for_fit=current2[cut_ind_fit]
;averaged
x_for_fit=slices_middle
y_for_fit=voltage_avg

fit_params=[30., -80., 20.]  ;Isat, Ufl, Te
print, 'Original fit parametres: Isat, Ufl, Te'
print, fit_params
weights=make_array(n_elements(x_for_fit), value=10.)
weights[where(x_for_fit le fit_treshold1_Isat)]=1000.
weights[where(x_for_fit gt fit_treshold2_low_cut_off)]=0.1
;weights[where(y_for_fit le -75.)]=1.
current2_fitted=curvefit(x_for_fit, y_for_fit, weights, fit_params, function_name='exp_fit', status=status, yerror=error_fit1,/noderivative)
print, 'Fit parametres: Isat, Ufl, Te'
print, fit_params
print, 'status of the fit = '+str(status)

;check of the fit:
fitted_function_y=fit_params[0]*(1.0-exp((x_for_fit-fit_params[1])/fit_params[2])) ;fitting function
Isat1=fit_params[0]
Ufl1=fit_params[1]
Te1=fit_params[2]
;---------------------------------------------
;second fit:
ind_fit2=where(slices_middle ge cut_fit2[0] and slices_middle le cut_fit2[1])
x_fit2=slices_middle[ind_fit2]
y_fit2=alog(-(voltage_avg[ind_fit2]-fit_params[0]))
;error_fit2=findgen(n_elements(x_fit2))
fit2_params=linfit(x_fit2, y_fit2, yfit=yfit2);, measure_errors=error_fit2)

Te2=1./fit2_params[1]
Ufl2=Te2*(alog(Isat1)-fit2_params[0])
print, Te2
print, Ufl2

;Ufl2=4.1
;Te2=22.
;check of the fit with Te and Ufl from the second one:
fitted_function_y2=fit_params[0]*(1.0-exp((x_for_fit-Ufl2)/Te2)) ;fitting function


;=============================================
;temperature from the BPP:
const=alog(sqrt(1.67e-27/9.1e-31))
;Te=(plasma_potential-Ufl)/const
Te=(voltage_pin3-voltage_pin2)/const
;averages from BPP:
avg_Te=avg(Te[cut_ind_fit])
avg_ne=avg(voltage_pin2[cut_ind_fit])
print, 'Averaged Te from BPP:'+str(avg_Te)
print, 'Averaged Ufl from pin2:'+str(avg_ne)
;END OF PROCESSING:------------------------------------------------------------------------
;##########################################################################################

;##########################################################################################
;PLOTTING:---------------------------------------------------------------------------------
!p.charsize=1.
!p.color=0
!p.background=255

window,1, xsize=1200, ysize=700
!P.multi=[0,2,2,0,1]
x_range=[-5,60]
;!p.charsize=1.5
;plot, time_voltage, voltage_pin1
plot, time_voltage, voltage_pin2, title='pin 2', xrange=x_range, xstyle=3
  oplot, !x.crange, [0,0]
  oplot, [cut_data[0], cut_data[0]], !y.crange, color=40
  oplot, [cut_data[1], cut_data[1]], !y.crange, color=40
plot, time_voltage, voltage_pin3, title='pin 3', xrange=x_range, xstyle=3
  oplot, !x.crange, [0,0]
  oplot, [cut_data[0], cut_data[0]], !y.crange, color=40
  oplot, [cut_data[1], cut_data[1]], !y.crange, color=40
  
plot, time_voltage, voltage, title='voltage', xrange=x_range, xstyle=3
  oplot, !x.crange, [0,0]
  oplot, [cut_data[0], cut_data[0]], !y.crange, color=40
  oplot, [cut_data[1], cut_data[1]], !y.crange, color=40
plot, time_voltage, current, title='current', xrange=x_range, xstyle=3
  oplot, !x.crange, [0,0]
  oplot, [cut_data[0], cut_data[0]], !y.crange, color=40
  oplot, [cut_data[1], cut_data[1]], !y.crange, color=40
if print_pictures ge 1 then write_pic, name=shot_str+' 1 raw time '+str(cut_data[0], format='(f6.2)'), path=path_picture

window,2, ysize=700,xsize=1200
!p.multi=[0,2,2,0,1]
plot, time_voltage, voltage*10., xrange=x_range, xstyle=3, yrange=[-150,50], $
  title='# '+str(shot_number)+', white: swept voltage*10, red: pin2, blue: voltage_corrected'
  oplot, time_voltage, voltage_pin2, color=100
  ;oplot, time_voltage, voltage+voltage*25.e3*20.*2.e-9/1.e-3, color=40
  oplot, time_voltage, voltage_corrected, color=40
  oplot,!x.crange,[0,0]
plot, time_voltage, voltage*10., title='as above in zoom', xstyle=3, yrange=[-150,50], xrange=[20,21],$
  xtitle='time [ms]'
  oplot, time_voltage, voltage_pin2, color=100
  oplot, time_voltage, voltage_corrected, color=40
  oplot,!x.crange,[0,0]
  
plot, time_voltage, voltage_corrected, xrange=x_range, xstyle=3,$
  title='voltage_corrected'
  oplot,!x.crange,[0,0]
plot, time_voltage, voltage_corrected, xstyle=3, xrange=[20,21], title='as above in zoom'
  oplot,!x.crange,[0,0]
if print_pictures ge 1 then write_pic, name=shot_str+' 2 voltages time '+str(cut_data[0], format='(f6.2)'), path=path_picture

;===========================================
window,7
!p.multi=0
x_range=[20.,21.]
plot, time_voltage,voltage_pin2_corrected, xrange=x_range, /nodata,$
  title='correction of the Ufl: white: raw pin2, purple: after corr.'
  oplot, time_voltage, voltage_pin2
  oplot, time_voltage, voltage_pin2_corrected, color=80
if print_pictures ge 1 then write_pic, name=shot_str+' 7 Uswept compar', path=path_picture

window,8, xsize=800, ysize=600
!p.multi=0
stop
plot, voltage_corrected[cut_ind_fit], current_corrected[cut_ind_fit], xtitle='voltage [V]', ytitle='current [A]',$
  title= '# '+shot_str+', time = '+str(cut_data[0], format='(f6.2)')+' - '+str(cut_data[1], format='(f6.2)')+' ms, '+$
  str(number_of_cycles)+' cycles', yrange=minmax(current_corrected[cut_ind_fit])
  oplot, voltage_corrected[cut_ind_fit], current1[cut_ind_fit], color=40
  oplot, voltage_corrected[cut_ind_fit], current2[cut_ind_fit], color=80, psym=2
  oplot, x_for_fit, fitted_function_y, color=100, thick=2
  oplot, slices_middle, voltage_avg, psym=5, color=140, thick=2
  oplot,!x.crange,[0,0]
  oplot, [0,0], !y.crange
  start_text=0.35
  step_text=0.05
  xyouts, !x.crange[0]+0.1*(!x.crange[1]-!x.crange[0]), !y.crange[0]+(start_text+step_text*3)*(!y.crange[1]-!y.crange[0]), 'Dashed: tresholds', /data, color=80
  xyouts, !x.crange[0]+0.1*(!x.crange[1]-!x.crange[0]), !y.crange[0]+(start_text+step_text*2)*(!y.crange[1]-!y.crange[0]), 'Dotted: Isat and Ufl', /data, color=40
  
  xyouts, !x.crange[0]+0.1*(!x.crange[1]-!x.crange[0]), !y.crange[0]+start_text*(!y.crange[1]-!y.crange[0]), 'Fit parametres - fit1: Isat, Ufl, Te', /data
  xyouts, !x.crange[0]+0.1*(!x.crange[1]-!x.crange[0]), !y.crange[0]+(start_text-step_text)*(!y.crange[1]-!y.crange[0]), str(fit_params[0]), /data
  xyouts, !x.crange[0]+0.22*(!x.crange[1]-!x.crange[0]), !y.crange[0]+(start_text-step_text)*(!y.crange[1]-!y.crange[0]), str(fit_params[1]), /data
  xyouts, !x.crange[0]+0.34*(!x.crange[1]-!x.crange[0]), !y.crange[0]+(start_text-step_text)*(!y.crange[1]-!y.crange[0]), str(fit_params[2]), /data
  xyouts, !x.crange[0]+0.1*(!x.crange[1]-!x.crange[0]), !y.crange[0]+(start_text-step_text*2.)*(!y.crange[1]-!y.crange[0]), 'Error of fit 1:', /data
  xyouts, !x.crange[0]+0.23*(!x.crange[1]-!x.crange[0]), !y.crange[0]+(start_text-step_text*2.)*(!y.crange[1]-!y.crange[0]), str(error_fit1), /data
  xyouts, !x.crange[0]+0.1*(!x.crange[1]-!x.crange[0]), !y.crange[0]+(start_text-step_text*3.)*(!y.crange[1]-!y.crange[0]), 'Fit parametres - fit2: Ufl, Te', /data
  xyouts, !x.crange[0]+0.1*(!x.crange[1]-!x.crange[0]), !y.crange[0]+(start_text-step_text*4.)*(!y.crange[1]-!y.crange[0]), str(Ufl2)+'     '+str(Te2), /data
  xyouts, !x.crange[0]+0.1*(!x.crange[1]-!x.crange[0]), !y.crange[0]+(start_text-step_text*5.)*(!y.crange[1]-!y.crange[0]), 'Averaged Te from BPP: '+str(avg_Te), /data
  xyouts, !x.crange[0]+0.1*(!x.crange[1]-!x.crange[0]), !y.crange[0]+(start_text-step_text*6)*(!y.crange[1]-!y.crange[0]), 'Averaged Ufl from pin2: '+str(avg_ne) , /data
  oplot, !x.crange, [fit_params[0], fit_params[0]], color=40, linestyle=1
  oplot, [fit_params[1], fit_params[1]], !y.crange, color=40, linestyle=1
  oplot, x_for_fit, fitted_function_y2, color=150, thick=2
  oplot, [fit_treshold1_Isat,fit_treshold1_Isat], !y.crange, color=80, linestyle=2
  oplot, [fit_treshold2_low_cut_off,fit_treshold2_low_cut_off], !y.crange, color=80, linestyle=2
  
if print_pictures ge 1 then write_pic, name=shot_str+' 8 IV char fit time '+str(cut_data[0], format='(f6.2)'), path=path_picture

window,9, xsize=800, ysize=600
!p.multi=0
plot, voltage_corrected[cut_ind_fit], -(current_corrected[cut_ind_fit]-fit_params[0]), xtitle='voltage [V]', ytitle='current [A]',$
  title= '# '+shot_str+', time = '+str(cut_data[0], format='(f6.2)')+' - '+str(cut_data[1], format='(f6.2)')+' ms, '+$
  str(number_of_cycles)+' cycles', /ylog, yrange=[1.e-6, 1.e0]
  oplot, voltage_corrected[cut_ind_fit], -(current1[cut_ind_fit]-fit_params[0]), color=40
  oplot, voltage_corrected[cut_ind_fit], -(current2[cut_ind_fit]-fit_params[0]), color=80, psym=2
  oplot, x_for_fit, -(fitted_function_y-fit_params[0]), color=100
  oplot, slices_middle, -(voltage_avg-fit_params[0]), psym=5, color=140, thick=3
  oplot,!x.crange,[0,0]
  oplot, [0,0], [1.e-20, 1.e20]
  oplot, [cut_fit2[0], cut_fit2[0]], [1.e-20, 1.e20], color=40
  oplot, [cut_fit2[1], cut_fit2[1]], [1.e-20, 1.e20], color=40
  if n_elements(x_fit2) gt 1 then begin
    oplot, x_fit2, exp(y_fit2), psym=4, color=100, thick=3
    oplot, x_fit2, exp(yfit2), color=150, thick=2, psym=-2
    endif
if print_pictures ge 1 then write_pic, name=shot_str+' 9 IV char fit logar time '+str(cut_data[0], format='(f6.2)'), path=path_picture

window,10, xsize=1000
plot, time_current, current*1.e-3, xrange=[10,11]
  oplot, time_current, current_corrected, color=40
  oplot, time_current, current2, color=100
  
;END OF PLOTTING:--------------------------------------------------------------------------
;##########################################################################################
print,'Hospoda horela hodinu. Hirosima hadr.'
;return, [Te1, Te2]
end
