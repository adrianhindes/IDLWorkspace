pro random_gen

N = 1024
del_t = 0.5*1e-6
t = findgen(N)
t_gen = del_t*t


Udata = randomu(seed, N)
Ndata = randomn(seed, N)

m = moment(Udata)

Udata = Udata - m[0]

;Ndataplot = plot(t_gen, Ndata)

f_n = fft(Ndata) ;fourier transform
f_u = fft(Udata)



;print, f_n

;X = (FINDGEN((1024-1)/2)+1)
;freq = [0.0, X, 1024/2, -1024/2+X]/(1024*0.5*1e-6)


N21 = N/2 +1
F = INDGEN(N)
F[N21] = N21 - N + FINDGEN(N21-2)
F = F/(N*0.5*1e-6)

;nplot=plot(SHIFT(F, -N21), SHIFT(f_n, 1))
;nplot.TICK_PONTSIZE = 10



npower = f_n* conj(f_n)
upower = f_u* conj(f_u)
npower = abs(npower)
upower = abs(upower)

freq = 500000

;kernel = cos(w*t)
;print, k
;print, kernel
kernel = cos(2.0*!PI*freq*t_gen)

ncon = convol(Ndata, kernel, /edge_zero)
fftncon = fft(ncon)
nconpower = abs(fftncon*conj(fftncon))
;plot, ncon, xrange = [450, 550]

ucon = convol(Udata, kernel, /edge_zero)
fftucon = fft(ucon)
uconpower = abs(fftucon*conj(fftucon))

window, 0
!P.MULTI = [0,1,2]
plot, real_part(Ndata)
plot, real_part(Udata)

window, 1
!P.MULTI = [0,1,2]
plot, SHIFT(F, -N21), SHIFT(f_n, -N21)
plot, SHIFT(F, -N21), SHIFT(f_u, -N21)

window, 2
!P.MULTI = [0,1,2]
plot, SHIFT(F, -N21), SHIFT(npower, -N21)
plot, SHIFT(F, -N21), SHIFT(upower, -N21)

window, 3
!P.MULTI = [0,1,2]
plot, SHIFT(F, -N21), SHIFT(nconpower, -N21), /ylog
plot, SHIFT(F, -N21), SHIFT(uconpower, -N21), /ylog ;, XRANGE=[0, 10] , YRANGE=[-0.001,0.001]

stop


;f_u = [[t_gen],[Udata]]
;print, f_u
;plot, f_n
;ff_u = fft(f_u) ;fourier transform
;print, ff_u
;plot, ff_u
;print, conj(ff_u)

upower = ff_u* conj(ff_u)

plot, upower

w = 1

ucon = convol(upower, cos(w*t_gen))

ncon = convol(npower, cos(w*t_gen))

plot, ucon

spec = conj(upower)*npower/(1023*0.5*1e-6)

plot, convol(conj(upower),npower), XRANGE=[1510, 1540]

plot, spec


end
