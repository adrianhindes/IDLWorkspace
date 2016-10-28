function fft_t_to_f, t,neg=neg,isrt=isrt

dt=t(1)-t(0)
n=n_elements(t)

f = findgen(n)/float(n)/dt

if keyword_set(neg) then begin
    ix=where(f gt 1./dt/2)
    f(ix)=f(ix)-1./dt
    isrt=sort(f)
endif

return,f
end

