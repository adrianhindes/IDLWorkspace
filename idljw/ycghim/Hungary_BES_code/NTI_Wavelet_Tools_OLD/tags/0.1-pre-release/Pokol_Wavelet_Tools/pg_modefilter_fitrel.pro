; Name: pg_modefilter_fitrel
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2007.04.20.
;
; Purpose: Select most fitting linear to the relative phases as a function of their relative position
;				(Can be used for a set of probes limited to a segment of the cross section)
;
; Calling sequence:
;	modenum=pg_modefilter_fitrel(cphases, chpos [,weights] [,moderange] [,modestep] [,qlim]$
;		[,ms=ms],[,qs=qs])
;
; Inputs:
;		cphases: relative cross-phases
;		chpos: channel positions in degrees
;		weigths (optional): weights of the fit; default: ones
;		moderange (optional): vector of minimum and maximum modenumbers to be considered
;			default:[-channelssize,channelssize]
;		modestep (optional): modenumber steps to be considered; default: 1
;		qlim (optional): minimum distance accepted Q values from Q_mean measuredin Q_stddev units
;			default: 0 (everything is accepted)
;
; Output:
;		modenum: modenumber, or 1000 for not defined modenumber
;		ms (optional): mode number vector
;		qs (optional): Q_m vector
;
; Modifications:
;	2008.01.02, Gergo Pokol: mean and standard deviation calculated without the minimum q value

function pg_modefilter_fitrel, cphases, chpos, weights=weights,$
	moderange=moderange, modestep=modestep, qlim=qlim, ms=ms, qs=qs

compile_opt defint32 ; 32 bit integers

; Set defaults
channelssize=n_elements(chpos)
if size(chpos, /n_dimensions) GT 1 then begin
  crosssize=channelssize/2 
  sxr=1
endif else begin
  crosssize=channelssize*(channelssize-1)/2
  sxr=0
endelse

if crosssize NE n_elements(cphases) then begin
	print,'Wrong input data dimensions!'
	return,1000
endif
modenum=1000
if not(keyword_set(weights)) then weights=fltarr(crosssize)+1.
if not(keyword_set(modestep)) then modestep=1.
if not(keyword_set(moderange)) then moderange=[-channelssize,channelssize]
if not(keyword_set(qlim)) then qlim=0

; Calculate relative channel positions for SXR data
if sxr EQ 1 then begin
channelssize=n_elements(chpos)
cchpos=fltarr(crosssize)
for i=0,channelssize-1,2 do begin
    cchpos(i/2.,*,*)=chpos(i+1)-chpos(i)
    if cchpos(i/2.,*,*) LT 0 then $
      cchpos(i/2.,*,*)=360+cchpos(i/2.,*,*)
endfor

endif else begin

; Calculate relative channel positions for Mirnov data
channelssize=n_elements(chpos)
cchpos=fltarr(crosssize)
for i=0,channelssize-1 do begin
  for j=i+1,channelssize-1 do begin
    cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*)=chpos(j)-chpos(i)
    if cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*) LT 0 then $
      cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*)=360+$
      cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*)
  endfor
endfor
endelse

; Convert to Pi units
cchposfit=cchpos/360.*2
phasesfit=cphases/!Pi


; Select most fitting modenumber
m=findgen((moderange(1)-moderange(0)+1)/modestep)*modestep+moderange(0)
msize=n_elements(m)
q=fltarr(msize)
for i=0,msize-1 do begin
	if m(i) EQ 0 then lin=cchposfit*0 $
		else lin=((m(i)*(cchposfit+1./abs(m(i)))) mod 2 )-m(i)/abs(m(i))
	q(i)=total((phasesfit-lin)^2*weights<(2-abs(phasesfit-lin))^2*weights)
endfor
qfit=min(q)
mfit=m(where(q EQ qfit))
mfit=mfit(0)
meanq=mean(q(where(q NE qfit)))
stddevq=stddev(q(where(q NE qfit)))

if meanq-qfit GT qlim*stddevq then modenum=mfit

ms=m
qs=q
return,modenum

end