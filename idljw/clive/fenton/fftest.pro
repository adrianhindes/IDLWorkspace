pro fftest, x
; Define the number of points:
N = 100000
; Define the interval:
T = 1./384000
; Midpoint+1 is the most negative frequency subscript:
N21 = N/2 + 1
; The array of subscripts:
F = INDGEN(N)
; Insert negative frequencies in elements F(N/2 +1), ..., F(N-1):
F[N21] = N21 -N + FINDGEN(N21-2)
; Compute T0 frequency:
F = F/(N*T)
; Shift so that the most negative frequency is plotted first:
;PLOT, /YLOG, SHIFT(F, -N21), SHIFT(ABS(FFT(x, -1)), -N21)
PLOT, /YLOG, f, ABS(FFT(x, -1))^2
end
