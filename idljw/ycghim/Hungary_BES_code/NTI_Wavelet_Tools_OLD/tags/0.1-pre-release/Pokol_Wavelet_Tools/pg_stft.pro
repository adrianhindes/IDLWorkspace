; Name: pg_stft
;
; Written by: Gergo Pokol (lokop@uze.net) 2002.07.15.
;
; Purpose: Return the Short Time Fourier Transform of a 1D data vector
;
; Calling sequence:
;	stft = pg_stft( data [,windowsize] [,masksize] [,windowname] [,step] [,freqres] [,/dc] [,/double] )
;
; Inputs:
;	data: 1D vector of data
;	windowsize (optional): length of window (standard deviation *2 for Gauss window); default: length of data / 10
;	masksize (optional): length of mask vector for infinite support windows; default: all nonzero values
;	windowname (optional): shape of the window (available: see in pg_gen_win.pro)
;	step (optional): time steps of FFT; default: 1
;	freqres (optional): frequency resolution (*2); default: length of data
;	/dc (optional): without mean subtraction
;	/double (optional): double precision
;
; Output:
;	stft: nxn matrix of the Short Time Fourier Transform of the input data
;
; Modification:
;	Gergo Pokol 2002.07.17: Introduction of step variable
;	Gergo Pokol 2003.03.25: Changes in the use of pg_gen_win
;	Gergo Pokol 2003.03.27: Repares to allow odd length windows
;	Gergo Pokol 2003.04.08: Optional mean subtraction added
;	Gergo Pokol 2003.04.15: Frequency resolution added
;	Gergo Pokol 2004.02.11: FFT norming factor added


function pg_stft, data, windowsize=windowsize, masksize=masksize,$
	windowname=windowname, step=step, freqres=freqres, dc=dc, double=double

compile_opt defint32 ; 32 bit integers

; Set defaults
size=n_elements(data)
double=keyword_set(double)
dc=keyword_set(dc)
if not(keyword_set(windowsize)) then windowsize=long(size/10)
if not(keyword_set(step)) then step=1
if not(keyword_set(freqres)) then freqres=size

; Mean subtraction
if dc NE 1 then data=data-mean(data)

; Get the window
win=pg_gen_win(windowsize,masksize=masksize,windowname=windowname,double=double)
winsize=n_elements(win)
freqres=(freqres > winsize) < size

; Initialize arrays
if (double) then begin
	stft=dcomplexarr(size/step,freqres)
	mask=dblarr(size)
endif else begin
	stft=complexarr(size/step,freqres)
	mask=fltarr(size)
endelse

; Initialize progress indicator
T=systime(1)

; Compute STFT
for i=0,floor(size/step)-1 do begin
	center=i*step
	first=center-floor(double(winsize)/2) ; begining of the support of the window
	last=center+ceil(double(winsize)/2)-1 ; end of the support of the window
	mask[*]=0
	mask[first>0:last<(size-1)]=win[abs(first<0):winsize-1-abs(((size-1)-last)<0)]
	windoweddata=data*mask

	; Cut windoweddata to freqres size
	if freqres NE size then begin
		temp=windoweddata(where(windoweddata))
		windoweddata=dblarr(freqres)
		windoweddata(0:n_elements(temp)-1)=temp
	endif

;	stft[i,*]=fft(windoweddata)
	stft[i,*]=fft(windoweddata)*sqrt(n_elements(windoweddata))

	; Progress indicator
	if floor(systime(1)-T) GE 5 then begin
		print, pg_num2str(double(i)/size*step*100)+' % done'
		T=systime(1)
		wait,0.1
	endif
endfor

return, stft

end
