; Name: pg_anal2
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2004.10.11.
;
; Purpose: Calculate band powers
;
; Calling sequence:
;	pg_anal2, matrix, b [,freqax] [,timeax] [,plot] [,/print] [/poster]$
;		[,bp=bp] [,/nosum]
;
; Input:
;	matrix: STFT or CWT of 1D data vector
;	b: Frequency bands (kHz)
;	freqax (optional): Frequency axis
;	timeax (optional): Time axis
;	plot (optional): Display mode (available: 0: Plot spectrum with band limits
;						  3: 0+band powers)
;						   ; default: 0
;       trange (optional): calculate bandpowers for a given time range
;       (tighter then time range of the input matrix) need timeax to function!
;       trunc (optional): truncates the signal at both ends at 3*trunc
;       (windowsize). call with trange=trange, to give back new trange!

;	/print (optional): Produce ps files
;	/poster (optional): Print in poster form
;	/nosum (optional): Do not calculate spectrum
;
; Output:
;	bp (optional): Band powers
;
; Modification:
;	Gergo Pokol 2003.05.20:	Time scale added
;				Crosscorrelation norm added
;	Gergo Pokol 2003.05.22: Corrlength added
;       Gergely PAPP 2008.10.28: trange and truncation added 
;       Gergely PAPP 2009.03.30: ID switch added

pro pg_anal2, matrix, bfix, freqax=freqax, timeax=timeax, plot=plot, print=print, poster=poster, $
	bp=bp, nosum=nosum, trange=trange, trunc=trunc, ID=ID

compile_opt defint32 ; 32 bit integers

;truncating the matrix and timeax wia trange (if set)
if (not keyword_set(trunc) AND keyword_set(trange)) then begin
   if not keyword_set(timeax) then begin 
      print, 'No timeax is defined!'
      return
   endif
   index1=gp_where(timeax,trange[0])
   index2=gp_where(timeax,trange[1])
   timeax=timeax[index1:index2]
   matrix=matrix[index1:index2,*]
endif


; Set constants
;matrix=matrixfix
b=bfix

; Set defaults
print=keyword_set(print)
poster=keyword_set(poster)
nosum=keyword_set(nosum)
if not(keyword_set(corrlength)) then corrlength=0.001
if not(keyword_set(plot)) then plot=0
if plot GE 0 then splot=1 else splot=0 	; Plot spectrum with band limits
if plot GE 3 then bpplot=1 else bpplot=0 ; Plot band powers
if nosum then splot=0

;truncate with 3*windowsize (if set)
if keyword_set(trunc) then begin
   index1=3*trunc
   index2=n_elements(timeax)-3*trunc-1
   timeax=timeax[index1:index2]
   matrix=matrix[index1:index2,*]
   trange=[min(timeax),max(timeax)]
endif
matrixsize=size(matrix)

if not(keyword_set(timeax)) then timeax=lindgen(matrixsize[1])*0.000003
if not(keyword_set(freqax)) then freqax=findgen(matrixsize[2])/(matrixsize[2]-1)/(timeax[2]-timeax[1])/2./1000.



; Initialize graphics
pg_initgraph,print=print

if poster then begin
	!P.CHARSIZE=4.0
	!P.THICK=4.
	!P.FONT=0
	dstep=20 ; Farction of error bars to be drawn
endif


; Define bands
b=reform(b,2,n_elements(b)/2)
bsize=size(b)
;bx=fix(double(b)/sfreq*matrixsize[2])
;bx=fix(double(b)/100*matrixsize[2]/2) ; Special case of 200 kHz sample frequency

; Generate strings for titles
str=strarr(bsize[2])
for i=0,bsize[2]-1 do str[i]=' '+pg_num2str(b[0,i])+' kHz - '+pg_num2str(b[1,i])+' kHz'

; Calculate band powers

bp=dblarr(bsize[2],matrixsize[1])
bx=dblarr(bsize[1],bsize[2])
for i=0,bsize[2]-1 do begin
	find=where((freqax ge b[0,i]) and (freqax le b[1,i]))
	bp[i,*]=total(abs(matrix[*,find])^2,2)
	bx[*,i]=[min(find),max(find)] ; Boundaries of the band
;	bp[i,*]=total(abs(matrix(*,bx[0,i]:bx[1,i]))^2,2)
	if bpplot then begin
		title='Band power'+str[i]
                ;G.Papp 2009.03.30. added ID option
                if keyword_set(ID) then title=ID+' - '+title
		if print then device,filename=pg_filename(title) else window,/free
		if poster then title='Savteljesitmeny '+i2str(b[0,i])+'-'+i2str(b[1,i])+' kHz'
		if poster then plot, timeax, bp[i,*], title=title, xstyle=1, xtitle='Ido (s)',ytitle='Teljesitmeny' $
			else plot, timeax, bp[i,*], title=title, xstyle=1, xtitle='Time (s)'
	endif
endfor

; Calculate spectrum for the whole time intervall

if nosum then sum=0 else begin
	if (freqax[2]-freqax[1]) EQ (freqax[3]-freqax[2]) then sum=total(abs(matrix[*,0:floor(matrixsize[2]/2d)])^2,1)*2 $ ; STFT
	else sum=total(abs(matrix)^2,1) ; CWT
endelse
if splot then begin
	title='Spectrum'
	if print then device,filename=pg_filename(title) else window,/free
	if poster then title='Spektrum'
	if poster then plot, freqax, sum, title=title, xstyle=1, xtitle='Frekvencia (kHz)' $
		else plot, freqax, sum, title=title, xstyle=1, xtitle='Frequency (kHz)'
	for i=0,bsize[2]-1 do oplot, freqax[bx(*,i)], sum[bx(*,i)], thick=0, psym=(i MOD 3)+4, symsize=2
endif

if print then device,/close

if poster then begin
	!P.CHARSIZE=1.0
	!P.THICK=1.
	!P.FONT=-1
endif


end
