;********************************************************************************************************
;
;    Name: BICOHERENCE
;
;    Written by: Laszlo Horvath 2010
;
;
;  SHORT MANUAL
;  ------------
;
;
; PURPOSE
; =======
;
;  This program calculates the bicoherence of a data vector.
;
; USAGE
; =====
;
;  bicoherence,fixdata,fixtimeax,fixblocksize,hann=hann,blockn=blockn
;
;  INPUTS:
;    fixdata:      the input vector
;    fixtimeax:    time axis
;    fixblocksize: the blockseize of windowing
;    hann:         the default windowing type is the Hanning windowing. Boxcar can be enabled by typing hann=0
;
;  OUTPUT:
;    blockn:       number of blocks
;
;  RETURN VALUE:
;		   the bicoherence matrix
;
; NEEDED PROGRAMS:
; ================
;
;  nti_wavelet_default.pro
;  nti_wavelet_defined.pro
;
;********************************************************************************************************


function bicoherence,fixdata,fixtimeax,fixblocksize,hann=hann,blockn=blockn

data=double(fixdata)
timeax=double(fixtimeax)
blocksize=long(fixblocksize)

;SETTING DEFAULTS
;================

nti_wavelet_default, hann, 1

;CALCULATE BICOHERENCE
;=====================

print,' '
print,'Calculating bicoherence matrix!'

;The part of the program which will run if hann=1 is adjusted - HANNING-WINDOWING method
;=======================================================================================

if (hann) then begin

;Calculate number of blocks
;---------------------------------------------------------
blockn=long(2*floor((n_elements(data)/blocksize))-1)

;Initializing array of bispectrums and normalizing factors
;---------------------------------------------------------
bispec=dcomplexarr(floor(blocksize/2.)+1,2*floor(blocksize/2.)+1);array of bispectrum
normfact1=dblarr(floor(blocksize/2.)+1,2*floor(blocksize/2.)+1);array of normalizing factor 1
normfact2=dblarr(floor(blocksize/2.)+1,2*floor(blocksize/2.)+1);array of normalizing factor 2

;Calculate bispectrums and array of normalizing factors of the blocks (Kim_PS_7_120_1979 (29))
;-----------------------------------------------------------

    ;Printing process time
    ;-----------------------------------------------------------
      step1=0
      print,'[0%                     50%                    100%]'
      print,FORMAT='("[",$)'
    ;-----------------------------------------------------------

for i=0L,blockn-1 do begin

    ;Printing process time
    ;-----------------------------------------------------------
      step2=floor(i/double(blockn-1)*50)
      if step2 GT step1 then begin
	print,FORMAT='("-",$)'
	step1=step2
      endif
    ;-----------------------------------------------------------

  fft_data=fft(hanning(blocksize)*(data[i*blocksize/2:(i+2)*blocksize/2-1]-mean(data[i*blocksize/2:(i+2)*blocksize/2-1])),-1)

  ;Calculate bispectrums
    for j=0,floor(blocksize/2.) do begin
      for k=0,min([j,floor(blocksize/2.)-j]) do begin
        bispec[j,k+floor(blocksize/2.)]=bispec[j,k+floor(blocksize/2.)]+fft_data[j]*fft_data[k]*conj(fft_data[j+k])
      endfor
    endfor
  
    for j=1,floor(blocksize/2.) do begin
      for k=1,j do begin
        bispec[j,floor(blocksize/2.)-k]=bispec[j,floor(blocksize/2.)-k]+fft_data[j]*conj(fft_data[k])*conj(fft_data[j-k])
      endfor
    endfor

  ;Calculate normalizing factor 1
    for j=0,floor(blocksize/2.) do begin
      for k=0,min([j,floor(blocksize/2.)-j]) do begin
        normfact1[j,k+floor(blocksize/2.)]=normfact1[j,k+floor(blocksize/2.)]+(abs(fft_data[j]*fft_data[k]))^2
      endfor
    endfor
  
    for j=1,floor(blocksize/2.) do begin
      for k=1,j do begin
        normfact1[j,floor(blocksize/2.)-k]=normfact1[j,floor(blocksize/2.)-k]+(abs(fft_data[j]*conj(fft_data[k])))^2
      endfor
    endfor

  ;Calculate normalizing factor 2
    for j=0,floor(blocksize/2.) do begin
      for k=0,min([j,floor(blocksize/2.)-j]) do begin
        normfact2[j,k+floor(blocksize/2.)]=normfact2[j,k+floor(blocksize/2.)]+(abs(fft_data[j+k]))^2
      endfor
    endfor
  
    for j=1,floor(blocksize/2.) do begin
      for k=1,j do begin
        normfact2[j,floor(blocksize/2.)-k]=normfact2[j,floor(blocksize/2.)-k]+(abs(fft_data[j-k]))^2
      endfor
    endfor

endfor

print,']'

;The part of the program which will run if hann=0 is adjusted - BOXCAR WINDOW
;============================================================================
endif else begin

;Calculate number of blocks
;---------------------------------------------------------
blockn=long(floor((n_elements(data)/blocksize)))

;Initializing array of bispectrums and normalizing factors
;---------------------------------------------------------
bispec=dcomplexarr(floor(blocksize/2.)+1,2*floor(blocksize/2.)+1);array of bispectrum
normfact1=dblarr(floor(blocksize/2.)+1,2*floor(blocksize/2.)+1);array of normalizing factor 1
normfact2=dblarr(floor(blocksize/2.)+1,2*floor(blocksize/2.)+1);array of normalizing factor 2

    ;Printing process time
    ;-----------------------------------------------------------
      step1=0
      print,'[0%                     50%                    100%]'
      print,FORMAT='("[",$)'
    ;-----------------------------------------------------------

;Calculate bispectrums and array of normalizing factors of the blocks (Kim_PS_7_120_1979 (29))
;-----------------------------------------------------------
for i=0L,blockn-1 do begin

    ;Printing process time
    ;-----------------------------------------------------------
      step2=floor(i/double(blockn-1)*50)
      if step2 GT step1 then begin
	print,FORMAT='("-",$)'
	step1=step2
      endif
    ;-----------------------------------------------------------

  fft_data=fft(data[i*blocksize:(i+1)*blocksize-1]-mean(data[i*blocksize:(i+1)*blocksize-1]),-1)

  ;Calculate bispectrums
    for j=0,floor(blocksize/2.) do begin
      for k=0,min([j,floor(blocksize/2.)-j]) do begin
        bispec[j,k+floor(blocksize/2.)]=bispec[j,k+floor(blocksize/2.)]+fft_data[j]*fft_data[k]*conj(fft_data[j+k])
      endfor
    endfor
  
    for j=1,floor(blocksize/2.) do begin
      for k=1,j do begin
        bispec[j,floor(blocksize/2.)-k]=bispec[j,floor(blocksize/2.)-k]+fft_data[j]*conj(fft_data[k])*conj(fft_data[j-k])
      endfor
    endfor

  ;Calculate normalizing factor 1
    for j=0,floor(blocksize/2.) do begin
      for k=0,min([j,floor(blocksize/2.)-j]) do begin
        normfact1[j,k+floor(blocksize/2.)]=normfact1[j,k+floor(blocksize/2.)]+(abs(fft_data[j]*fft_data[k]))^2
      endfor
    endfor
  
    for j=1,floor(blocksize/2.) do begin
      for k=1,j do begin
        normfact1[j,floor(blocksize/2.)-k]=normfact1[j,floor(blocksize/2.)-k]+(abs(fft_data[j]*conj(fft_data[k])))^2
      endfor
    endfor

  ;Calculate normalizing factor 2
    for j=0,floor(blocksize/2.) do begin
      for k=0,min([j,floor(blocksize/2.)-j]) do begin
        normfact2[j,k+floor(blocksize/2.)]=normfact2[j,k+floor(blocksize/2.)]+(abs(fft_data[j+k]))^2
      endfor
    endfor
  
    for j=1,floor(blocksize/2.) do begin
      for k=1,j do begin
        normfact2[j,floor(blocksize/2.)-k]=normfact2[j,floor(blocksize/2.)-k]+(abs(fft_data[j-k]))^2
      endfor
    endfor

endfor

print,']'

endelse

;Calculate mean of bispectrums and normalizing factors
;-----------------------------------------------------

  ;Initialize arrays of mean bispectrums and normalizing factors
    mean_bispec=dcomplexarr(floor(blocksize/2.)+1,2*floor(blocksize/2.)+1)
    mean_normfact1=dblarr(floor(blocksize/2.)+1,2*floor(blocksize/2.)+1)
    mean_normfact2=dblarr(floor(blocksize/2.)+1,2*floor(blocksize/2.)+1)

  ;Calculate mean of bispectrums
    mean_bispec=bispec/blockn
    
    ;Remove points out of domain
      for j=0,floor(blocksize/2.) do begin
        for k=min([floor(blocksize/2.)+j+1,2*floor(blocksize/2.)-j+1]),2*floor(blocksize/2.) do begin
          mean_bispec[j,k]=1
        endfor
      endfor

      for j=0,floor(blocksize/2.) do begin
        for k=0,floor(blocksize/2.)-j-1 do begin
          mean_bispec[j,k]=1
        endfor
      endfor

  ;Calculate mean of normalizing factor 1
    mean_normfact1=normfact1/blockn

    ;Remove points out of domain
      for j=0,floor(blocksize/2.) do begin
        for k=min([floor(blocksize/2.)+j+1,2*floor(blocksize/2.)-j+1]),2*floor(blocksize/2.) do begin
          mean_normfact1[j,k]=1
        endfor
      endfor

      for j=0,floor(blocksize/2.) do begin
        for k=0,floor(blocksize/2.)-j-1 do begin
          mean_normfact1[j,k]=1
        endfor
      endfor
  
  ;Calculate mean of normalizing factor 2
    mean_normfact2=normfact2/blockn

    ;Remove points out of domain
      for j=0,floor(blocksize/2.) do begin
        for k=min([floor(blocksize/2.)+j+1,2*floor(blocksize/2.)-j+1]),2*floor(blocksize/2.) do begin
          mean_normfact2[j,k]=1
        endfor
      endfor

      for j=0,floor(blocksize/2.) do begin
        for k=0,floor(blocksize/2.)-j-1 do begin
          mean_normfact2[j,k]=1
        endfor
      endfor


;Calculate bicoherence
;=======================================================================================
bicoh=dblarr(floor(blocksize/2.)+1,2*floor(blocksize/2.)+1);initialize array of bicoherence
bicoh=abs(mean_bispec)/(sqrt(mean_normfact1)*sqrt(mean_normfact2));calculate bicoherence

      ;Values out of domain set to 0
      for j=0,floor(blocksize/2.) do begin
        for k=min([floor(blocksize/2.)+j+1,2*floor(blocksize/2.)-j+1]),2*floor(blocksize/2.) do begin
          bicoh[j,k]=0
        endfor
      endfor

      for j=0,floor(blocksize/2.) do begin
        for k=0,floor(blocksize/2.)-j-1 do begin
          bicoh[j,k]=0
        endfor
      endfor

return,bicoh

end