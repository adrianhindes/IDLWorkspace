pro moss_sig_power, h, freq

n=n_elements(h)
S=fltarr(10000)
t=findgen(10000)/(3200.*freq)
S=h(0)
for i=1, n-1 do begin
    S=S+h(i)*sin(2*!pi*n*freq*t)
    window, i
    plot, S
    end
plot, S
end

