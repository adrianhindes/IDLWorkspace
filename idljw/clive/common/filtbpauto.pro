
function filtbpauto,f,fracb,fracw,anal=anal
n=n_elements(f)
ft=fft(f)

s=abs(ft)
s(0:fracb*n)=0.
s(n*0.5:*)=0.
dummy=max(s,imax)
fracc=float(imax)/float(n)
fracl=fracc-fracw/2
fracu=fracc+fracw/2
print,fracl,fracu
;stop
win=replicate(1.,n)
if not keyword_set(anal) then  win(n*fracu:n*(1-fracu))=0. else win(n*fracu:n-1)=0. 

win(0:n*fracl)=0.
win(n*(1-fracl):n-1)=0.
rv=(fft(ft*win,/inverse))
if not keyword_set(anal) then rv=float(rv)
;stop
return,rv
end
