pro coeff_test, in = in, out = out, timeax = timeax

s = 0.6

A = 6
B = 30

Wa = 0.2
Wb = 0.3

f1 = 50d3
f2 = 100d3
f3 = 150d3
dev1 = 300
dev2 = 1000
dev3 = 3000


trange = [0, 0.03]
sfreq = 4d5
length = 200
stft_fres = 2000

phase_in1 = random_phase(dev = dev1, trange = trange, sfreq = sfreq, length = length, timeax = t)
plot, t, phase_in1
phase_in2 = random_phase(dev = dev2, trange = trange, sfreq = sfreq, length = length, timeax = t)
phase_in3 = random_phase(dev = dev3, trange = trange, sfreq = sfreq, length = length, timeax = t)

phase_out1 = random_phase(dev = dev1, trange = trange, sfreq = sfreq, length = length, timeax = t)
phase_out2 = random_phase(dev = dev2, trange = trange, sfreq = sfreq, length = length, timeax = t)
phase_out3 = random_phase(dev = dev3, trange = trange, sfreq = sfreq, length = length, timeax = t)

in = A*sin(2*!DPI*f1*t+phase_in1) + A*sin(2*!DPI*f2*t+phase_in2) + A*sin(2*!DPI*f3*t+phase_in3) + Wa*randomn(seed, n_elements(t), /normal)
out = B*s*sin(2*!DPI*f1*t+phase_in1) + B*(1-s)*sin(2*!DPI*f1*t+phase_out1) + B*s*sin(2*!DPI*f2*t+phase_in2) + B*(1-s)*sin(2*!DPI*f2*t+phase_out2) + B*s*sin(2*!DPI*f3*t+phase_in3) + B*(1-s)*sin(2*!DPI*f3*t+phase_out3) + Wb*randomn(seed, n_elements(t), /normal)

timeax = t

end