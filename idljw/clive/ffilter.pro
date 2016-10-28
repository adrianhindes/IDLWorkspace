function ffilter, f,which=which
default,which,'old'
if which eq 'new' then begin
   c = 20e-12 + 10e-12 + 50e-12 ; for new filter
   tdel=-.5e-6                  ; for new filter
r2 = 3e3

endif

if which eq 'old' then begin
c = 20e-12 + 10e-12 + 100e-12 ; for old filter
tdel=-.6e-6 ; for old filter

;tdel=-tdel
r2 = 30e3

endif
r1 = 1e6

;r1 = 100e3
;r2 = 2e3


;r1 = 0.
;r2 = 50.

;f=linspace(1,1e6,100)
w=2*!pi*f


xc = 1 / (complex(0,1) * w * c)

rb = 1 / ( 1/xc + 1/ r2 )
ra =  r1

v1 = rb / (rb+ra)


v2=exp(complex(0,1)*2*!pi*f*tdel)
return,v1*v2
;plot,f, abs(v1)

end
