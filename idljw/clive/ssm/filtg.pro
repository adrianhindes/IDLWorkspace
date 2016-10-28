function filtg, x, w0,w,cplx=cplx,hat=hat,sideopt=sideopt
;default,sideopt,0.
;sideopt=0: sym
;sideopt=1: pos side (e.e. for 80kHz->86)
;sideopt=-1;negside (e.g. 92khZ down to 86)
; Bandpass filter. w0 => central wavelength, w => bandwidth
; keywords: cplx => divides complex Fourier spectrum by 'i', befor inversion it
;                      <=> causes a 90 degree phase shift
;                      <=> turns sines into cosines and vice versa
;                   question for Clive: Why?
;           hat  => if set a 'hat' (or 'box') type filter is used, else a Gaussian filter is used
;
; returns the filtered, complex version of the input signal 'x'

n=n_elements(x)     ; number of elements

; normalised frequency base
; e.g. for n=11: [0.0,0.10,...,0.50,     -0.50,...,-0.10]
;      for n=10: [0.0,0.11,...,0.44,0.55,-0.44,...,-0.11]
f      = findgen(n)                ;f=linspace(0,1,n)
idx    = where(f ge floor(n/2.)+1) ;idx=where(f gt 0.5)
f[idx] = f[idx] - n                ;f[idx]=f[idx]-1.
f      = f/(n-1)
; perform Fourier transform
s=fft(x)
if keyword_set(cplx) then s=s/complex(0,1)  ; 90 degree phase shift when 'cplx' is set

; make filter function (hat or Gaussian)
if keyword_set(hat) then begin
    wn  = fltarr(n)
    if sideopt eq 0 then idx = where((f ge w0-w/2.) and (f le w0+w/2.))
    if sideopt eq 1 then idx = where((f ge w0) and (f le w0+w/2.))
    if sideopt eq -1 then idx = where(((f ge w0-w/2) and (f le w0)))

;;;) or f eq w0) ;need to include the effective component iff dc

    if idx[0] ne -1 then wn[idx]=1.
endif else wn=exp(-(f-w0)^2/w^2 /2.)
; apply the filter
s2=s*wn
; and perform the inverse Fourier transform
y=fft(s2,/inverse)

return,y

end

