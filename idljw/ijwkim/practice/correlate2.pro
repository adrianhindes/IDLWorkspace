pro correlate2

;make delta t and number of points
N = 1024
del_t = 1e-6
t = findgen(N)
t_gen = del_t*t

N21 = N/2 +1
F = INDGEN(N)
F[N21] = N21 - N + FINDGEN(N21-2)
F = F/(N*del_t)
F = shift(F, -N21)

freq = 10000

wave = sin(2.0*!PI*freq*t_gen)



f_wave = FFT(wave)
G_wave = f_wave*conj(f_wave)
C_wave = FFT(G_wave, /inverse)
C_wave = real_part(C_wave)



power_wave = f_wave*conj(f_wave)
power_wave = abs(power_wave)



window, 0, xsize = 900, ysize = 1200
!P.MULTI = [0,1,2]
plot, F, shift(C_wave, -N21)
plot, F, shift(power_wave, -N21), /ylog

t_life = 0.0001
damp = wave*exp(-(t_gen)^2/(t_life)^2)

f_damp = FFT(damp)
G_damp = f_damp*conj(f_damp)
G_damp = real_part(G_damp)
C_damp = FFT(G_damp, /inverse)
C_damp = real_part(C_damp)



power_damp = f_damp*conj(f_damp)
power_damp = abs(power_damp)

k = A_CORRELATE(wave ,t_gen)

window, 1, xsize = 900, ysize =1200 
!P.MULTI = [0,1,2]
plot, k
plot, F, shift(power_damp, -N21), /ylog



end
