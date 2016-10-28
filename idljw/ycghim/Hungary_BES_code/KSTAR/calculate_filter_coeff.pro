pro calculate_filter_coeff,f_fir=f_fir,f_recurs=f_recurs,gain=gain,f_adc=f_adc

; f_fir: frequency of FIR filter
; f_recurs: frequency of recursive filter
; gain: the gain factor, 1,2,3,4
; f_adc: ADC frequency

default,f_adc,10.e6   ; 10 MHz
default,f_fir,10.e6
default,f_recurs,20.e6
default,gain,1

Nyquist_freq = f_adc/2
    tau = f_adc/f_recurs/2/!pi
    c = exp(-1./double(tau))
    c = long(c*4096)
    order = 5
    r = digital_filter(0,f_fir/(f_adc/2)<1,50,order)
    s1 = fltarr(order*10)
    s1[2*order]=1000
    s2=convol(s1,r)
    coeff1 = s2[2*order:3*order-1]
    coeff=fix(coeff1/total(coeff1)*(4096-c)/16)*2^gain
    filt = fltarr(8)
    for i=0,4 do begin
      filt[i] = coeff[i]
    endfor
    filt[5] = c
    filt[7] = 8+gain

    print,'f_ADC:',string(f_adc/1e6,format='(F4.1)')+' [MHz]'
    print,'f_FIR:',string(f_fir/1e6,format='(F4.1)')+' [MHz]'
    print,'f_REC:',string(f_recurs/1e6,format='(F4.1)')+' [MHz]'
    print,'Gain:',i2str(gain)

    str ='Coeff: '
    for i=0,7 do begin
      str = str+i2str(filt[i],digit=5)+' '
    endfor
    print,str
end