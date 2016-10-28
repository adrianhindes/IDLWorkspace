c = 500e-12

r1 = 1e6
r2 = 30e3

r1 = 100e3
r2 = 2e3


;r1 = 0.
;r2 = 50.

f=linspace(1,1e6,100)
w=2*!pi*f


xc = 1 / (complex(0,1) * w * c)

rb = 1 / ( 1/xc + 1/ r2 )
ra =  r1

v1 = rb / (rb+ra)

plot,f, abs(v1)

end
