function couple_coeff, transf = transf, a = a, b = b, sa = sa, sb = sb, n=n, snr = snr, timew = timew, powlimit = powlimit

;calculate absoulte value of transfer function
transf = reform(abs(transf))
;initializing the array of coupling coefficient (s):
coeff = transf*0.

;set defaults:
default, sa, 300d
default, sb, 300d
default, n, 20d
default, snr, 100d
default, timew, 0.0005d
default, powlimit, 3d

;calculate noise:
wa = max(a)/double(snr)
wb = max(b)/double(snr)

;calculate the coupling coefficient
;----------------------------------
  ;simplify equations:
  h = exp(-timew^2*0.5*(sa^2+sb^2))
  p = (1+h)/(1-h)*n - (2*h)/((1-h)^2) + (2*h)/((1-h)^2)*h^n
  q = h/n*(h^n-1)/(h-1)

  ;calculate coefficients of the quadratic function:
  e = a*b + (a*b)/(n^2)*p - 2*a*b*q + 2*b*wa/n
  f = -2*(a*b)/(n^2)*p + 2*a*b*q - 2*b*wa/n
  g = (a*b)/(n^2)*p + (a*wb + wa*wb)/n + b*wa/n - (4*transf^2*(a+wa)^2)/!DPI

i=long(0)
j=long(0)
maxa=a/max(a)
maxb=b/max(b)
imax=long(n_elements(coeff(*,0)))
jmax=long(n_elements(coeff(0,*)))

; Initialize progress indicator
T=systime(1)

print, "Filter out modes with low power..."
  if powlimit NE 0. then begin
    powlimit=float(powlimit)/100.
    ; Calculate average cross energy density for power limit filtering
    limpow=coeff
      while i lt imax do begin
	while j lt jmax do begin
          limpow(i,j)=max([maxa(i,j),maxb(i,j)])
	j=j+1
        endwhile
      j=0
	if floor(systime(1)-T) GE 5 then begin
		print, pg_num2str(double(i)/long(n_elements(coeff(*,0)))*100)+' % done'
		T=systime(1)
		wait,0.1
	endif
      i=i+1
      endwhile
    ; Do filtering
    plotted=where(limpow gt powlimit)
    if max(plotted) gt -1 then coeff(plotted)=1
  endif


; Initialize progress indicator
T=systime(1)

i=long(0)
j=long(0)

print, "Calculate coupling coefficients..."

while i lt long(n_elements(coeff(*,0))) do begin
  while j lt long(n_elements(coeff(0,*))) do begin
    if coeff(i,j) eq 1 then begin
      s = imsl_zeropoly([g(i,j),f(i,j),e(i,j)])
      if (imaginary(s(0)) eq 0) then begin
	s1 = real_part(s(0))
	s2 = real_part(s(1))
	  if ((s1 ge 0) and (s1 le 1)) then begin
	    s = s1
	  endif else begin
	    if ((s2 ge 0) and (s2 le 1)) then begin 
	      s = s2
	    endif else begin
	      s = 0
	    endelse
	  endelse	
      endif else begin
	s = 0
      endelse
      coeff(i,j) = s
    endif else begin
      coeff(i,j) = 0
    endelse
  j=j+1
  endwhile
j=0

	if floor(systime(1)-T) GE 5 then begin
		print, pg_num2str(double(i)/long(n_elements(coeff(*,0)))*100)+' % done'
		T=systime(1)
		wait,0.1
	endif

i=i+1
endwhile

return, coeff

end