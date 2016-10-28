function makematrix1, p1, nharm
mat=fltarr(2,nharm)
for i=0,nharm-1 do begin
   j=i+1
   if j mod 2 eq 1 then mat(0,i)=beselj(p1,j)
   if j mod 2 eq 0 then mat(1,i)=beselj(p1,j)
endfor
   return,mat
end

function makematrix2, p1,p2, nharm
mat=fltarr(4,nharm)
for i=0,nharm-1 do begin
   j=i+1
   if j mod 2 eq 1 then mat(0,i)=beselj(p1,j)
   if j mod 2 eq 0 then mat(1,i)=beselj(p1,j)
   if j mod 2 eq 1 then mat(2,i)=beselj(p2,j)
   if j mod 2 eq 0 then mat(3,i)=beselj(p2,j)

endfor
   return,mat
end


@getp12   
@locateeps2 
@compeps2   
@getharm2  

;ch10::
;amp=      3.13071      26.4745
;phase=      21.6013     -11.3373
;drive=      335.172      124.138
;ch7:
;amp=      4.05806      16.8831
;phase=     -67.9378     -118.320
;drive=      297.931      99.3103


;pro pemdemod4, shot, chan,npts=n,skip=skip,bw=bw,nocache=nocache,debug=debug
;goto,a

;shot=81134 & nupshift=50 & fbase=10e3
;shot=81207 & nupshift=50 & fbase=10e3

;;;shot=81298 & nupshift=50 & fbase=10e3

;shot=81050 & nupshift=12 & fbase=90e3
;shot=81059 & nupshift=12 & fbase=90e3
;shot=81120 & nupshift=12 & fbase=90e3
;shot=81009 & nupshift=16 & fbase=50e3

shot=83998 & nupshift=25 & fbase=80e3


shot=85988
;amp=      12.4128      67.1091
;phase=      173.014      179.376
;drive=      223.448      111.724

d     = read_datam(shot,14) & d=d(0:1e4-1)
r1    = read_datam(shot,21) & r1=r1(0:1e4-1)
r2    = r1
dtd=1/(fbase*nupshift)
t0d=-0.01
bw=fbase/4;1e3



; extract sine-wave on the time base of the MSE signal from the 'square wave' PEM references
dt  = dtd
r1f = filtg(r1,fbase*dt,1e3*dt,/cplx) ; bandpass filter with 20kHz center and 1 kHz width
r2f = filtg(r2,fbase*dt,1e3*dt,/cplx) ; bandpass filter with 23kHz center and 1 kHz width
da  = d
n=n_elements(d)
;
t1=findgen(n)*dt + t0d

nt2=floor((max(t1)-min(t1))*(2*bw))-1
t2=min(t1)+(1+findgen(nt2-1))*1/(2*bw) ;record twice freq
;linspace(min(t1)+2/bw,max(t1)-2/bw,(max(t1)-min(t1))*bw)
nt2=n_elements(t2)

f=findgen(n)/n /dt
r1f=r1f/max(abs(r1f))
r2f=r2f/max(abs(r2f))

;stop



;ihw1=[0,0,0,0,1,1,1,1,1,1,1,2,2,2,2,2,2,2,3,3,3,3,4,4,4,4,4,5,5,5]
;ihw2=[1,2,3,4,-5,-3,-1,0,1,3,5,-5,-3,-1,0,1,3,5,-3,-1,0,1,-3,-1,0,1,3,-1,0,1]

;ihw1=[0,1,2,3,4,5,6]
;ihw2=[0,0,0,0,0,0,6]
nharm=10
ihw1=indgen(nharm)+1
ihw2=ihw1*0
;stop
cal=0
getharm2, da, r1f, r2f, ihw1, ihw2, harms, t1, t2, bw, epc,cal=cal
ih0=(where(ihw1 eq 0 and ihw2 eq 0))(0)
;if cal eq 0 then begin
;    ho=mean(harms(where(t2 lt -0.005),ih0)) ; subtract offset baseline beforet=0.05
;    harms(*,ih0)=harms(*,ih0)-ho
;endif

a:
;; fda=fft(da)
;; f0=250e3;46.4e3;250e3
;; ;w=exp(-(f-f0)^2/bw^2/2)
;; w=abs(f-f0) le bw
;; wfda=fda*w
;; sfda=shift(wfda,-f0/1e6*n)
;; rs=fft(sfda,/inverse)
;; ns=10000
;; rs2=(smooth(abs(rs)^2,ns))^0.5
;; dharm=interpol(rs2,t1,t2)



;locateeps2, epc, ihw1,ihw2,eps1,rng=rngp
;locateeps2, epc, ihw2,ihw1,eps2,rng=rngp
locateeps2, epc, ihw1,ihw2,eps1,rng=[0,90]*!dtor
;locateeps2, epc, ihw2,ihw1,eps2,rng=[-90,0]*!dtor

;stop


;window,0
debug=1
if keyword_set(debug) then begin
    doplot=1
    noplot=0
endif else begin
    doplot=0
    noplot=1
endelse

eps2=0
compeps2, ihw1, ihw2, harms, eps1, eps2,doplot=doplot
if keyword_set(debug) then stop
;retall

i1=where(ihw1 eq 1 and ihw2 eq 0)
i2=where(ihw1 eq 2 and ihw2 eq 0)
i3=where(ihw1 eq 3 and ihw2 eq 0)
i4=where(ihw1 eq 4 and ihw2 eq 0)

getp12,harms(*,i1),harms(*,i2),harms(*,i3),harms(*,i4),dum,dum2,p1,noplot=noplot,maxang=300.
if keyword_set(debug) then stop


hsum=total(harms,1)

mult = exp(complex(0,1) * (ihw1 mod 2 )*(-!pi/2))
hsum2=float(hsum*mult)
iodd=where(ihw1 mod 2 eq 1)
ieven=where(ihw1 mod 2 eq 0 and ihw1 ne 0 )
plot,imaginary(hsum(iodd)),yr=max(abs(hsum(0:*)))*[-1,1]
theorodd=beselj(p1,ihw1(iodd))
theorodd=theorodd/theorodd(0) * imaginary(hsum(iodd(0)))
oplot,theorodd,thick=2
oplot,float(hsum(ieven)),col=2

theorev=beselj(p1,ihw1(ieven))
theorev=theorev/theorev(0) * float(hsum(ieven(0)))
oplot,theorev,thick=2,col=2

;plot,abs(fft(d))*10,pos=posarr(/next),/noer,yr=[0,1]

;mat--q to harms
;mati - harmsto q
; so i want  harms to q then to harms mat i ## mat
;A = U  SV  VT
;so a-1 ut 1/sv v
;vtv=1
;w * 1/w  =1
;ut * i
np1v=100
p1v=linspace(0*!dtor,360*!dtor,np1v)
csqarr=fltarr(np1v)
for i=0,np1v-1 do begin
   mat=makematrix1(p1v(i),nharm)
   svdc,mat,w,u,v
   remap=(u) ## transpose(u)
   hsum3=remap ## transpose(hsum2)
   csqarr(i)=total((hsum3-hsum2)^2)
endfor


plot,p1v*!radeg,csqarr
stop
dum=min(csqarr,a)
mat=makematrix1(p1v(a),nharm)
svdc,mat,w,u,v

;so a-1 ut 1/sv v
qtab= (transpose(u) # diag_matrix(1/w) # v) ## transpose(hsum2)
hsum3=mat ## qtab
plot,hsum2
oplot,hsum3,col=2

stop


np1v=30
p1v=linspace(0*!dtor,360*!dtor,np1v)
csqarr=fltarr(np1v,np1v)+1e3
for i=0,np1v-1 do for j=0,i do begin
   mat=makematrix2(p1v(i),p1v(j),nharm)
   svdc,mat,w,u,v
   remap=(u) ## transpose(u)
   hsum3=remap ## transpose(hsum2)
   csqarr(i,j)=total((hsum3-hsum2)^2)
endfor

dum=min(csqarr,imin)
a=imin mod np1v
b=imin / np1v
print,csqarr(a,b),dum
print, p1v(a)*!radeg
print, p1v(b)*!radeg
print,imin

imgplot,alog10(csqarr),p1v,p1v,/cb
stop
mat=makematrix2(p1v(a),p1v(b),nharm)
svdc,mat,w,u,v

;so a-1 ut 1/sv v
qtab= (transpose(u) # diag_matrix(1/w) # v) ## transpose(hsum2)
hsum3=mat ## qtab
plot,hsum2
oplot,hsum3,col=2
cqtab=complex(qtab([0,2]),qtab([1,3]))
aq=abs(cqtab)
pq=atan2(cqtab)
print,'amp=',aq
print,'phase=',pq*!radeg
print,'drive=',p1v(a)*!radeg,p1v(b)*!radeg



end

