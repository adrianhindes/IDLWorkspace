pro demod_moss_16samp, t, y, phi1set, I0, zeta, phi0, phi1=phi1, phaseerr=phs, $
                       bandwidth=bandwidth,showharms=showharms

default, bandwidth, 5000.
tres = 1./bandwidth
mxharm = 4

fmod = 1./(t(1)-t(0))/16.
nn = nicenumber(n_elements(y),/floor)
non16 = n_elements(y)/16
n = non16*16
if nn mod 16 eq 0 then n = nn

y=y(0:n-1)
t=t(0:n-1)
f = fft_t_to_f(t)
s = fft(y)

phs = -atan(s(n/16)/complex(0,1))
;print, 'phs (deg) = ', phs*!radeg

terr = phs/(2.*!pi*fmod)
fs = fshift(f)
;pidx = 2.*!pi*fs*terr
pidx = phs*fs/fmod
phcorr = complex(cos(pidx),sin(pidx)) 
s = s * phcorr

wf = fwindow(f,0.,fmod/2.,/rev)

h = complexarr(mxharm+1,n)
hc= complexarr(n)
whatshift = hc

for i=0,mxharm do begin

    if i mod 2 eq 1 then begin
        cfact = complex(0,1) 
    endif else begin
        cfact = 1.
    endelse
    fdo = shift(s,-n/16*i)*wf/cfact
    ta0 = systime(1)
    hc = fft(fdo,/inverse)
    print, 'time = ',systime(1)-ta0
    h(i,*) = hc
end

;h = abs(h)

if keyword_set(showharms) then begin
    !p.multi=[0,1,2]
    plot, t, h(3,*)/h(1,*), title='h3/h1'
    plot, t, h(4,*)/h(2,*), title='h4/h2'
    !p.multi=0
endif

if n_elements(phi1) ne 0 then begin

    genhratiotable
    noisebglog = mean(alog10(abs(s)))+0.5
    noisebg = 10.^noisebglog
    h3 = abs(s(n/16*3)) & h1 = abs(s(n/16))
    h31 = h3/h1
    re3 = noisebg/h3 & re1 = noisebg/h1
    h31e = h31 * (re3+re1)

    h4 = abs(s(n/16*4)) & h2 = abs(s(n/16*2))
    h42 = h4/h2
    re4 = noisebg/h4 & re2 = noisebg/h2
    h42e = h42 * (re4+re2)
    print, noisebglog, alog10([h1,h2,h3,h4])

    phi1_1 = findphi1(h31,3)
    phi1_1ea = abs(findphi1(h31+h31e,3)-phi1_1)
    phi1_1eb = abs(findphi1(h31-h31e,3)-phi1_1)
    phi1_1e = max([phi1_1ea,phi1_1eb])
    phi1_2 = findphi1(h42,4)
    phi1_2ea = abs(findphi1(h42+h42e,4)-phi1_2)
    phi1_2eb = abs(findphi1(h42-h42e,4)-phi1_2)
    phi1_2e = max([phi1_2ea,phi1_2eb])


    phi1_3 = sqrt(24./ ((1.+h4/h2)*(1+h1/h3)) )



    phi1_3e = 0.
    phi1 = [[phi1_1,phi1_2,phi1_3],[phi1_1e,phi1_2e,phi1_3e]]
    print,phi1
    print, h31, h31e,h42, h42e
endif    

M = fltarr(n) & C = M & Q = M

hmat = calchmat(phi1set,mxharm)
hinv = pseudoinv(hmat)
print, 'finished ffts'
for i=0L,n-1 do begin
	ans = hinv ## h(*,i)
	M(i) = ans(0)
	Q(i) = ans(1)
	C(i) = ans(2)
end

I0 = M
zeta = sqrt(C^2+Q^2)/M
phi0 = atan(Q,C)

;plot,f,abs(s),/ylog
end
