;********************************************************************************************************
;
;    Name: PLOT_BICOHERENCE
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
;  This program calculates the bicoherence of a data vector and plot the result.
;
; USAGE
; =====
;
; SWITCHES
; ========
;
; NEEDED PROGRAMS:
; ================
;
;  pg_initgraph.pro
;  default.pro
;  i2str.pro
;  pg_num2str.pro
;
;********************************************************************************************************

pro plot_bicoherence2, fixdata, fixtimeax, fixblocksize, shotnumber=shotnumber, channelname=channelname,$
trange=trange, hann=hann, comment=comment, frequency=frequency, ID=ID, bicoh=bicoh, hun=hun

data=double(fixdata)
timeax=double(fixtimeax)
blocksize=long(fixblocksize)

;SETTING DEFAULTS
;================

default,hann,1
default,comment,'plot_bicoherence.pro'
default,trange,[timeax[0],timeax[n_elements(timeax)-1]]
default,shotnumber,'-'
default,channelname,'-'
default,ID,i2str(systime(1))
default,hun,0

;Language of plots
;-----------------

if hun then begin
;Bicoh
bicoh_title='Bikoherencia'
bicoh_xtitle='Frekvencia 1 [kHz]'
bicoh_ytitle='Frekvencia 2 [kHz]'

;APSD
apsd_title='Auto-spektrum'

;Color scale
cs_xtitle='Bikoherencia'
cs_title='Sz'+string(byte("355B))+'nsk'+string(byte("341B))+'la'

;xyouts
xy_date='D'+string(byte("341B))+'tum'
xy_blocksize='Blokkm'+string(byte("351B))+'ret'
xy_blockn='Blokkok sz'+string(byte("341B))+'ma'
xy_program='Program'
xy_version='Verzi'+string(byte("363B))
xy_revision='rev'+string(byte("355B))+'zi'+string(byte("363B))+''
xy_shotnumber='L'+string(byte("366B))+'v'+string(byte("351B))+'ssz'+string(byte("341B))+'m'
xy_channelname='Csatorna n'+string(byte("351B))+'v'
xy_timerange='Id'+string(byte("366B))+' intervallum'
endif else begin
;Bicoh
bicoh_title='Bicoherence'
bicoh_xtitle='Frequency 1 [kHz]'
bicoh_ytitle='Frequency 2 [kHz]'

;APSD
apsd_title='APSD'

;Color scale
cs_xtitle='Bicoherence'
cs_title='Color scale'

;xyouts
xy_date='Date'
xy_blocksize='Blocksize'
xy_blockn='Blockn'
xy_program='Program'
xy_version='Version'
xy_revision='revision'
xy_shotnumber='Shotnumber'
xy_channelname='Channelname'
xy_timerange='Time range'
endelse



;READ_REVISION
;=============

svn_data=strarr(5)
svn_path='./.svn/entries'
; .svn directory found, but can we open it?
openr,unit,svn_path,/get_lun,error=error
if error ne 0 then begin 
  print, 'Subversion file could not be opened at '+svn_path
endif else begin
  readf,unit,svn_data
endelse

;print, svn_data
revision=fix(svn_data[3])

;CALCULATE BICOHERENCE
;=====================

if defined(bicoh) then begin
blockn=0
end

if (not defined(bicoh)) then begin
bicoh=bicoherence(data,timeax,blocksize,hann=hann,blockn=blockn)
end

sav_bicoh=bicoh

  ;values out of domain set to 1
  for j=0,floor(blocksize/2.) do begin
    for k=min([floor(blocksize/2.)+j+1,2*floor(blocksize/2.)-j+1]),2*floor(blocksize/2.) do begin
      bicoh[j,k]=1
    endfor
  endfor

  for j=0,floor(blocksize/2.) do begin
    for k=0,floor(blocksize/2.)-j-1 do begin
      bicoh[j,k]=1
    endfor
  endfor

;PRINTING
;========

;create frequency axes
;---------------------
stime=(timeax[n_elements(timeax)-1]-timeax[0])/double(n_elements(timeax)-1) ;sampletime of data vector
nfreq=1/(2*stime);Nyquits-frequency

if (defined(frequency)) then begin

  max_freq_index=ceil((blocksize/(2*(nfreq/1000)))*frequency)
  max_freq=(2*nfreq/blocksize)*max_freq_index

print, "nfreq: ", nfreq
print, "blocksize: ", blocksize
print, "max_freq_index", max_freq_index
  
    ;create frequency axes
  freqax=dindgen(max_freq_index+1)
  freqax=freqax/max(freqax)
  freqax=freqax*max_freq/1000.;kHz

  ;frequency axes of x direction
  xfreqax=freqax

  ;frequency axes of y direction
  yfreqax=freqax
  
  plot_bicoh=dblarr(max_freq_index+1,max_freq_index+1)
  plot_bicoh=bicoh[0:max_freq_index+1,floor(blocksize/2.):floor(blocksize/2.)+max_freq_index+1]
  
;---------------------------------------------------------------------------------
;  max_freq_index=ceil(((floor(blocksize/2.)-1)*frequency*1000)/(nfreq))
;  max_freq=max_freq_index*((nfreq)/floor((blocksize/2.)-1))
;  
;    ;create frequency axes
;  freqax=dindgen(max_freq_index)
;  freqax=freqax/max(freqax)
;  freqax=freqax*max_freq/1000.;kHz
;
;  ;frequency axes of x direction
;  xfreqax=freqax
;
;  ;frequency axes of y direction
;  yfreqax=dindgen(2*max_freq_index+1)
;  yfreqax=2*yfreqax/max(yfreqax)-1
;  yfreqax=yfreqax*max_freq/1000;kHz
;  
;  plot_bicoh=dblarr(max_freq_index+1,2*max_freq_index+1)
;  for i=0,max_freq_index do begin
;    for j=0,2*max_freq_index do begin
;      plot_bicoh[i,j]=bicoh[i,floor(blocksize/2.)-max_freq_index+j]
;    endfor
;  endfor
;---------------------------------------------------------------------------
 
endif else begin

  ;create frequency axes
  freqax=dindgen(floor(blocksize/2.)+1)
  freqax=freqax/max(freqax)
  freqax=freqax*nfreq/1000;kHz

  ;frequency axes of x direction
  xfreqax=freqax

  ;frequency axes of y direction
  yfreqax=dindgen(0.5*floor(blocksize/2.)+1)
  yfreqax=freqax[0:0.5*floor(blocksize/2.)]
  
  plot_bicoh=dblarr(floor(blocksize/2.)+1,0.5*floor(blocksize/2.)+1)
  plot_bicoh=bicoh[*,floor(blocksize/2.):1.5*floor(blocksize/2.)]
endelse

;plot bispectrum
;---------------

  ;setting path and name
  date=bin_date(systime())
  date=i2str(date[0])+'-'+i2str(date[1])+'-'+i2str(date[2])
  path='./bicoherence_data/graphs/'+date+'/'+ID+'/'
  file_mkdir,path
  
;convert channelname for filename
  file_ch_name=channelname
  byte_ch_name=byte(file_ch_name)
    for i = 0,n_elements(byte_ch_name)-1 do begin
      if byte_ch_name[i] EQ 47 then begin
        byte_ch_name[i]=45
      endif
    endfor
  file_ch_name=string(byte_ch_name)
  
  name='bicoherence-'+ID+'-'+file_ch_name+'-'+pg_num2str(shotnumber)+'-time-'$
  +pg_num2str(trange[0],length=5)+'-'+pg_num2str(trange[1],length=5)$
  +'-blocksize-'+pg_num2str(blocksize)+'-r'+pg_num2str(revision)+'.eps'
  
  sav_name='bicoherence-'+file_ch_name+'-'+pg_num2str(shotnumber)+'-time-'$
  +pg_num2str(trange[0],length=5)+'-'+pg_num2str(trange[1],length=5)$
  +'-blocksize-'+pg_num2str(blocksize)+'-r'+pg_num2str(revision)+'.sav' 

  ;initializing printing parameters
  pg_initgraph,/print
  device,bits_per_pixel=8,font_size=8,/portrait,/color,/encapsulated,/bold,/cmyk,/preview,/times
  device, filename=path+name

  ;transform bicoherence matrix for plot
  plot_bicoh=plot_bicoh*255
  
  ;load color table
  loadct,5

  ;plot axes
  plot,[min(xfreqax),max(xfreqax)],[min(yfreqax),max(yfreqax)],xmargin=[11.5,16.5],ymargin=[5,3]$
  ,title=bicoh_title,xtitle=bicoh_xtitle,ytitle=bicoh_ytitle,/nodata,$
  xstyle=1,ystyle=1,xticklen=-0.01,yticklen=-0.01,charsize=2,charthick=3,xthick=3,ythick=3;,xminor=5,yminor=5
  
  ;plot bicoherence matrix
  px=!x.window
  py=!y.window
  tv,plot_bicoh,px(0),py(0),xsize=px(1)-px(0),ysize=py(1)-py(0),/normal
  
    ;initialize color scale
  cscale=fltarr(2,256)
  cscale[0,*]=findgen(256)
  cscale[1,*]=findgen(256)
  axis=cscale[0,*]/255

   ;plot axes of color scale
  plot,axis,[0,1],/nodata,xstyle=1,ystyle=1,xrange=[0,1],xticklen=0,xtitle='',xmargin=[79,7],ymargin=[25,6]$
  ,xtickname=[' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ']$
  ,yrange=[min(axis),max(axis)]$
  ,ytitle=cs_xtitle,title=cs_title,NOERASE=1,xthick=3,ythick=3,charsize=1.3,charthick=2


  ;plot color scale
  px=!x.window
  py=!y.window
  tv,cscale,px(0),py(0),xsize=px(1)-px(0),ysize=py(1)-py(0),/normal

if hann then begin
info_blockn=(blockn+1)/2
endif else begin
info_blockn=blockn
endelse

  ;initialize xyouts
  info=xy_date+': '+systime()+$
      '!C'+xy_blocksize+': '+i2str(blocksize)+'    '+xy_blockn+': '+pg_num2str(info_blockn)+$
      '!C'+xy_program+': '+comment+$
      '!C'+xy_version+': '+'revision '+pg_num2str(revision)+$
      '!C'+xy_shotnumber+': '+pg_num2str(shotnumber)+$
      '!C'+xy_channelname+': '+channelname+$
      '!C'+xy_timerange+': '+'['+pg_num2str(trange[0],length=5)+' s, '+pg_num2str(trange[1],length=5)+' s]'

  ;plot xyouts
  xyouts,0.83,0.10,info,/normal,orientation=90,charsize=1.2,charthick=1.8

  device, /close

;===================================================================
;APSD
;===================================================================
if blockn NE 0 then begin

if hann then begin

  APSD=dblarr(blockn,blocksize)

  for i=0L, blockn-1 do begin

    F=FFT(HANNING(blocksize)*(data[i*blocksize/2:(i+2)*blocksize/2-1]-mean(data[i*blocksize/2:(i+2)*blocksize/2-1])),-1)
    APSD[i,*]=conj(F)*F
    
  endfor
endif else begin

  APSD=dblarr(blockn,blocksize)

  for i=0,blockn-1 do begin

    ;F=FFT(data[i*blocksize:(i+1)*blocksize-1]-mean(data[i*blocksize:(i+1)*blocksize-1]),-1)
    F=FFT(hanning(blocksize)*(data[i*blocksize:(i+1)*blocksize-1]-mean(data[i*blocksize:(i+1)*blocksize-1])),-1)
    APSD[i,*]=conj(F)*F

  endfor
endelse

meanapsd=dblarr(blocksize)

for i=0L,blocksize-1 do begin
  meanapsd(i)=mean(APSD(*,i))
endfor

  apsd_y_min=min(meanapsd[1:n_elements(freqax)-1])
  apsd_y_max=max(meanapsd[1:n_elements(freqax)-1])

  name_apsd='apsd-'+ID+'-'+file_ch_name+'-'+pg_num2str(shotnumber)+'-time-'$
  +pg_num2str(trange[0],length=5)+'-'+pg_num2str(trange[1],length=5)$
  +'-blocksize-'+pg_num2str(blocksize)+'-r'+pg_num2str(revision)+'.eps'

device, filename=path+name_apsd

plot, /YLOG, freqax, meanapsd, charsize=2, xthick=3, ythick=3, charthick=3, title=apsd_title,$
      xtitle=bicoh_xtitle, xstyle=1, ystyle=1, xmargin=[10,16], ymargin=[5,3], yrange=[apsd_y_min,apsd_y_max]
      ;, xticklen=-0.01, yticklen=-0.01, xrange=[min(faxis),maxf], xstyle=1, ystyle=1

;plot xyouts
xyouts,0.83,0.10,info,/normal,orientation=90,charsize=1.4,charthick=1.8


;  plot,[min(xfreqax),max(xfreqax)],[min(yfreqax),max(yfreqax)],xmargin=[10,16],ymargin=[5,3]$
; ,title='Bicoherence',xtitle='Frequency 1 [kHz]',ytitle='Frequency 2 [kHz]'$
;  ,/nodata,xstyle=1,ystyle=1,xticklen=-0.01,yticklen=-0.01,charsize=2,charthick=3,xthick=3,ythick=3;,xminor=5,yminor=5

device,/close

end
;===================================================================

  ;restoring printing parameters
  pg_initgraph

;save bicoherence matrix to file  
  if comment EQ 'sxr_bicoherence.pro' then begin
    file_mkdir,'./bicoherence_data/data'
    save,sav_bicoh,filename='./bicoherence_data/data/'+sav_name
  endif
 
end