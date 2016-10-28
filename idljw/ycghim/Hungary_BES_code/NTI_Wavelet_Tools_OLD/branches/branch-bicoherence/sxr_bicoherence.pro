;********************************************************************************************************
;
;    Name: SXR_BICOHERENCE
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
;  This program calculates and plots the bicoherence of SXR signals.
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

pro sxr_bicoherence, shotnumber, channelname, trange, blocksize, hann=hann, frequency=frequency, ID=ID, hun=hun

;SETTING DEFAULTS
;================

version=0.0
prog='sxr_bicoherence.pro'

default, hann, 1
default, ID, i2str(systime(1))

get_rawsignal, shotnumber, channelname, timeax, data, trange=trange

plot_bicoherence2,data,timeax,blocksize,shotnumber=shotnumber,channelname=channelname,$
trange=trange,hann=hann,comment='sxr_bicoherence.pro',frequency=frequency,ID=ID, hun=hun

end