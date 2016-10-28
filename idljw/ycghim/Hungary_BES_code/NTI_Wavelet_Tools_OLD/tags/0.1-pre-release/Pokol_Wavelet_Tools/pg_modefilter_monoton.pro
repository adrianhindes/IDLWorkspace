; Name: pg_modefilter_monoton
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2007.02.26.-03.01.
;
; Purpose: Filter modenumbers from pre-calculated cross-phases assuming monoton (with a given margin)
;				 change of phases and equal modenumbers with all reference probes, selects smaller modenumber
;
; Calling sequence:
;	modenum=pg_modefilter_monoton(cphases,chpos[,margin])
;
; Inputs:
;		cphases: relative cross-phases
;		chpos: channel positions in degrees
;		margin (optional): margin of monotonization; default:0
;
; Output:
;		modenum: modenumber, or 1000 for not defined modenumber
;
; Modifications:
;		2007.04.17. Gergo Pokol: margin added, criterium changed

function pg_modefilter_monoton, cphases, chpos, margin=margin

compile_opt defint32 ; 32 bit integers

; Set defaults
if not(keyword_set(margin)) then margin=0
channelssize=n_elements(chpos)
crosssize=channelssize*(channelssize-1)/2
if crosssize NE n_elements(cphases) then begin
	print,'Wrong input data dimensions!'
	exit
endif
modenum1=1000
modenum2=1000
modenum=1000

; Create array for phase diagrams with different reference channels
phases0=fltarr(channelssize,channelssize)
; Fill array from input
for i=0,channelssize-1 do begin
	for j=i+1,channelssize-1 do begin
		phases0(i,j)=cphases(i*(channelssize-(i+1)/2.)-(i+1)+j)
		phases0(j,i)=-cphases(i*(channelssize-(i+1)/2.)-(i+1)+j)
	endfor
endfor
; Translate phase diagrams to start from (0,0)
for i=1,channelssize-1 do begin
	phases0(i,*)=phases0(i,*)+cphases(0*(channelssize-(0+1)/2.)-(0+1)+i)
endfor
chpos=chpos-chpos(0)
; Add 0 to the end of each phase diagram
phases0=[[phases0],[phases0(*,0)]]

; Test for positive modenumbers
phases=phases0
; Monotonize phase diagrams
for i=0,channelssize-1 do begin
	for j=1,channelssize do begin
		if phases(i,j-1) GT phases(i,j)+margin then phases(i,j:channelssize)=phases(i,j:channelssize)+2*!PI
	endfor
endfor
if n_elements(where(phases(*,channelssize) EQ phases(0,channelssize))) EQ channelssize $
	then modenum1=phases(0,channelssize)/(2*!PI)

; Test for negative modenumbers
phases=phases0
; Monotonize phase diagrams
for i=0,channelssize-1 do begin
	for j=1,channelssize do begin
		if phases(i,j-1) LT phases(i,j)-margin then phases(i,j:channelssize)=phases(i,j:channelssize)-2*!PI
	endfor
endfor
if n_elements(where(phases(*,channelssize) EQ phases(0,channelssize))) EQ channelssize $
	then modenum2=phases(0,channelssize)/(2*!PI)

if abs(modenum1) EQ abs(modenum2) then modenum=1000
if abs(modenum1) LT abs(modenum2) then modenum=modenum1
if abs(modenum1) GT abs(modenum2) then modenum=modenum2


return,modenum

end