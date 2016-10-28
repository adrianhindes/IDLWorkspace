rs= 30. / 1e-3

;rs=0.

l = 4.7e-6
c = 47e-9

r1 = 1e6
r2 = 30e3


;r1 = 0.
;r2 = 50.

f=linspace(1,1e6,100)
w=2*!pi*f

xl = complex(0,1)*w * l

xc = 1 / (complex(0,1) * w * c)

rb = 1 / ( 1/xc + 1/(xl + r1 + r2) )
ra =  rs + xl

v1 = rb / (rb+ra)

gb = r2
ga = xl + r1

v2 = gb / (gb+ga) 

v3 = v2 * v1

plot,f, abs(v3)

end
