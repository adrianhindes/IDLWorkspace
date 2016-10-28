pro coeff_table

f_FIR_f_ADC = [1., 0.5, 0.3, 0.2, 0.1]

for i=0,n_elements(f_FIR_f_ADC)-1 do begin
  order = 5
  r = digital_filter(0,f_fir_f_ADC[i]*2<1,50,order)
  s1 = fltarr(order*10)
  s1[2*order]=1000
  s2=convol(s1,r)
  coeff1 = s2[2*order:3*order-1]
  coeff=coeff1/total(coeff1)
  print,string(f_fir_f_ADC[i],'(F3.1)')+$
    '  '+string(coeff[0],format='(F7.3)')+$
    '  '+string(coeff[1],format='(F7.3)')+$
    '  '+string(coeff[2],format='(F7.3)')+$
    '  '+string(coeff[3],format='(F7.3)')+$
    '  '+string(coeff[4],format='(F7.3)')
endfor


end
