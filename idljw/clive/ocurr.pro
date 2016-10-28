;delta I  = 400A 

;(100A 4 turns)

;this gives field change of 2.5e-4 T
flux=2.5e-4 * !pi * 1.^2 * 5 ; for 500A 4 turns

;loop voltage integral E.dl is dphi dt

dt= 0.1

lv= flux / dt
print,'lv=',lv


zed= 1.d0
e = 1.6d-19
m_e=9.1d-31
loglam = 20.
eps0=8.85d-12
T_e=20.
eta = !dpi * zed^2 * e^2 *sqrt(m_e) * loglam / (4*!dpi*eps0)^2 / (e*T_e)^1.5
print, eta

;stop

;eta = 5.2e-5 * loglam * zed / t_e^1.5
;print,eta
;stop
E = lv / 2/!pi/1.
j = E / eta

print,'j=',j
area = !pi * .15^2

print,'area=',area

curr=area*j
print,'curr=',curr
end

