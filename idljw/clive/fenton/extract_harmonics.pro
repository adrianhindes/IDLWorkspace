pro extract_harmonics, sig, time, npts_cyc, ahrm, complement=complement,$
                       nharm = nharm, carrier=carrier,  $
                       filt_type = filt_type,  filt_bw = filt_bw, $
                       correct_offset=correct_offset, phserr=phserr

; create a filter to isolate the mix product at dc
; needs to be half modulation frequency in width
; time is such that one fundamental period=one time unit

npts = n_elements(sig)
dt=time(1)-time(0)
fmod=1./(npts_cyc*dt)
fnyq=1./(2*dt)
default,  nharm, fnyq/fmod
default,  filt_bw,  1.

limits = [0.,filt_bw*0.5*fmod/fnyq]
ns = (npts/2)*fmod/fnyq
default,  filt_type,  0
filt = shift(tapers(npt=ns,lim=[0.,1], type=filt_type),ns/2)

ahrm=complexarr(ns, nharm)

; absolute values of harmonic carriers
carrier=complexarr(nharm)

; isolate fundamental and find time delay error
;idx=1
 fsig = fft(sig,-1)
; fsig1 = shift(fsig,-idx*ns)
; fsig1=([fsig1(0:ns/2-1),fsig1(npts-ns/2:npts-1)])
; hrm1 = 2.*fft(filt*fsig1,1)


;stop

; fundamental is shifted by 90 degrees in this representation
c=indgen(nharm)
jc=complex(0.,1)^(c mod 2)
carrier=fsig(fix(c*ns))*jc

if not keyword_set(phserr) then begin
  idx=1
  phserr=(atan(carrier))(idx)
  phserr = ((phserr + !pi) mod !pi)/idx
end
print, 'Timing error (degrees):',  phserr*!radeg

freq = range(0.,fnyq,npts=npts/2+1)

again:
phs_correct = exp(complex(0.,-phserr*freq/fmod))
phs_correct = [phs_correct,conj(reverse(phs_correct(1:npts/2-1)))]
new_fsig = fsig*phs_correct
new_carrier=new_fsig(fix(c*ns))*jc
plot,atan(new_carrier)*!radeg,psym=4
read,'Enter new phase in degrees (-1 if satisfied)',entry
if entry ne -1 then begin
	phserr=entry*!dtor
	goto, again
end

carrier=carrier*phs_correct
; now extract the harmonics
;stop
for i=0,nharm-1 do begin
 	fsigi = shift(fsig,-i*ns)
 	fsigi=([fsigi(0:ns/2-1),fsigi(npts-ns/2:npts-1)])
	fsigi = fsigi*exp(complex(0.,-i*phserr))
    if i eq 0 then $
      ahrm(*,i) = fft(filt*fsigi,1) else $
      ahrm(*,i) = 2.*fft(filt*fsigi,1)
	carrier(i) = fsigi(0)
end
;stop
end
