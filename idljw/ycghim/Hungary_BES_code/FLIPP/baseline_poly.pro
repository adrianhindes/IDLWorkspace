function baseline_poly,t,s,order,data_source=data_source
; This routine  returns a polinomial fit to the data
; Used by crosscor_new as one of the baseline subtraction methods
; INPUT:
;   t: time vector
;   s: signal vector
;   order: order of fit

default,order,2

tt = findgen(n_elements(s))
p = poly_fit(tt,s,order)
b = p(0)
for i=1,order do b = b + p(i)*tt^i
return,b

end
