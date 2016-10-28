FUNCTION MEAS_CONFIG,shot,data_source=data_source,silent=silent,names=names,	$
	avail_system=avail_system,channel_list=channel_list,			$
	signal_list=signal_list,out_names=out_names,				$
	subchannels=subchannels,errortext=errortext,				$
        ext_fsample=ext_fsample,starttime=starttime


; ************* meas_config.pro ****************** S. Zoletnik 22.03.98 ****
; Returns information on the measurement set-up for a given shot.
; This program contains all information on the measurement set-up, other
; programs call this routine to get information.
; 
; Return value:	0 if request is OK
;		any other means an error
; INPUT:
; shot:	shot number
; data_source: 0: Nicolet, 1:Aurora, 2:Li-standard, 3: AUG Li-standard,
;		7: TEXTOR Li-beam 
; /silent:	do not print errortext
; /names:	print signal names
;
; OUTPUT:
; avail_system:	list of available measurement systems (int array)
; channel_list:	list of available channels for data_source
; signal_list:	list of signal names in channels
; errortext:	Error message if return value is nonzero
; ext_fsample:	external sample frequency [Hz],
;		set to 1 for deflected Li-beam measurements 
;		set to 0 for internal sampling
; starttime:	start time of measurement (trigger) relative to plasma start
; subchannels:	number of subchannels (Used for deflected Li-beam measurements)
;**************************************************************************

DEFAULT,shot,-1             
DEFAULT,subchannels,1
DEFAULT,ext_fsample,0
DEFAULT,starttime,0
DEFAULT, data_source,0
errortext = ''
              
if (keyword_set(names)) then begin
  out_names=strarr(35)
  for i=1,35 do out_names(i-1)='Li-'+i2str(i)
  for i=1,8 do out_names=[out_names,'Blo-'+i2str(i)]
  for i=1,28 do out_names=[out_names,'Lang28-'+i2str(i)]
  out_names=[out_names,'Halpha']
  out_names=[out_names,'Pressure']
  out_names=[out_names,'Mir-A']
  out_names=[out_names,'Mir-B']
  print,'***** Signal names:'
  print,' Li-1...Li-35: Li-beam signals'
  print,' Blo-1...Blo-8: Blow-off beam signals'
  print,' Halpha: Li-beam H_alpha signal'
  print,' Pressure: W7-AS Pressure signal'
  print,' Mir-A: Mirnov signal A'
  print,' Mir-b: Mirnov signal B'
  print,' H_l_xxxx: ECE Haese signal, lower channel xxxx'
  print,' H_u_xxxx: ECE Haese signal, upper channel xxxx'
  print,' Lang28-xxx: 28 channel (reciprocating) Langmuir probe tips'
  return,0
endif	


; ************** W7-AS Li-standard system configurations *****************

W7_st_chnum=30
W7_st_ch=findgen(W7_st_chnum)+1
W7_st_chname=strarr(W7_st_chnum)
for i=0,W7_st_chnum-1 do begin
  case (W7_st_ch(i)) of
;
; *** Enter channel setup in this format *******  
; ch. number  signal name
;     |        |
;     |        |
;     V        V
     1:  w='Li-1'
     2:  w='Li-2'
     3:  w='Li-3'
     4:  w='Li-4'
     5:  w='Li-5'
     6:  w='Li-6'
     7:  w='Li-7'
     8:  w='Li-8'
     9:  w='Li-9'
    10:  w='Li-10'
    11:  w='Li-11'
    12:  w='Li-12'
    13:  w='Li-13'
    14:  w='Li-14'
    15:  w='Li-15'
    16:  w='Li-16'
    17:  w='Li-17'
    18:  w='Li-18'
    19:  w='Li-19'
    20:  w='Li-20'
    21:  w='Li-21'
    22:  w='Li-22'
    23:  w='Li-23'
    24:  w='Li-24'
    25:  w='Li-25'
    26:  w='Li-26'
    27:  w='Li-27'
    28:  w='Li-28'
    29:  w='Halpha'
    30:  w='Pressure'
  endcase
  W7_st_chname(i)=w
endfor

if ((shot ge 54803) and (shot le 54857)) then begin
 for i=0,W7_st_chnum-1 do begin
  case (W7_st_ch(i)) of
 ;
 ; *** Enter channel setup in this format *******  
 ; ch. number  signal name
 ;     |        |
 ;     |        |
 ;     V        V
     1:  w='Li-1'
     2:  w='Li-2'
     3:  w='Li-3'
     4:  w='Li-4'
     5:  w='Li-5'
     6:  w='Li-9'
     7:  w='Li-7'
     8:  w='Li-8'
     9:  w='Li-6'
    10:  w='Li-10'
    11:  w='Li-11'
    12:  w='Li-12'
    13:  w='Li-13'
    14:  w='Li-14'
    15:  w='Li-15'
    16:  w='Li-19'
    17:  w='Li-17'
    18:  w='Li-18'
    19:  w='Li-16'
    20:  w='Li-20'
    21:  w='Li-21'
    22:  w='Li-22'
    23:  w='Li-23'
    24:  w='Li-24'
    25:  w='Li-25'
    26:  w='Li-26'
    27:  w='Li-27'
    28:  w='Li-28'
    29:  w='Halpha'
    30:  w='Pressure'
  endcase
  W7_st_chname(i)=w
 endfor
endif




; ******************** AUG Li-standard configurations *********************

AUG_st_chnum=35
AUG_st_ch=findgen(AUG_st_chnum)+1
AUG_st_chname=strarr(AUG_st_chnum)
for i=0,AUG_st_chnum-1 do begin
  case (AUG_st_ch(i)) of
     1:  w='Li-1'
     2:  w='Li-2'
     3:  w='Li-3'
     4:  w='Li-4'
     5:  w='Li-5'
     6:  w='Li-6'
     7:  w='Li-7'
     8:  w='Li-8'
     9:  w='Li-9'
    10:  w='Li-10'
    11:  w='Li-11'
    12:  w='Li-12'
    13:  w='Li-13'
    14:  w='Li-14'
    15:  w='Li-15'
    16:  w='Li-16'
    17:  w='Li-17'
    18:  w='Li-18'
    19:  w='Li-19'
    20:  w='Li-20'
    21:  w='Li-21'
    22:  w='Li-22'
    23:  w='Li-23'
    24:  w='Li-24'
    25:  w='Li-25'
    26:  w='Li-26'
    27:  w='Li-27'
    28:  w='Li-28'
    29:  w='Li-29'
    30:  w='Li-30'
    31:  w='Li-31'
    32:  w='Li-32'
    33:  w='Li-33'
    34:  w='Li-34'
    35:  w='Li-35'
  endcase
  AUG_st_chname(i)=w
endfor


TEXTOR_li_chnum=6
TEXTOR_li_ch=findgen(TEXTOR_li_chnum)+1
TEXTOR_li_chname=strarr(TEXTOR_li_chnum)
DEFAULT,TEXTOR_li_ext_fsample,0
DEFAULT,TEXTOR_starttime,0

if (shot ge 89720) then begin
  TEXTOR_li_ext_fsample = 1e5
  if ((shot eq 89723) or (shot eq 89724)) then TEXTOR_li_ext_fsample = 1e6
  if (shot lt 89731) then TEXTOR_starttime = 4.0				$
			else TEXTOR_starttime = -1.5
  for i=0,TEXTOR_li_chnum-1 do begin
    case (TEXTOR_li_ch(i)) of
       1:  w='Li-1'
       2:  w='Li-2'
       3:  w='Li-3'
       4:  w='Li-4'
       5:  w='Li-5'
       6:  w='Li-6'
    endcase
    TEXTOR_li_chname(i)=w
  endfor
endif

TEXTOR_li_test_chnum=6
TEXTOR_li_test_ch=findgen(TEXTOR_li_test_chnum)+1
TEXTOR_li_test_chname=strarr(TEXTOR_li_test_chnum)
TEXTOR_li_test_ext_fsample=1e6

for i=0,TEXTOR_li_test_chnum-1 do begin
  case (TEXTOR_li_test_ch(i)) of
     1:  w='Li-1'
     2:  w='Li-2'
     3:  w='Li-3'
     4:  w='Li-4'
     5:  w='Li-5'
     6:  w='Li-6'
  endcase
  TEXTOR_li_test_chname(i)=w
endfor

TEXTOR_blo_chnum=6
TEXTOR_blo_ch=findgen(TEXTOR_blo_chnum)+1
TEXTOR_blo_chname=strarr(TEXTOR_blo_chnum)
TEXTOR_blo_ext_fsample=1e6

if (shot gt 80000) then begin
  for i=0,TEXTOR_blo_chnum-1 do begin
    case (TEXTOR_blo_ch(i)) of
       1:  w='Blo-1'
       2:  w='Blo-2'
       3:  w='Blo-3'
       4:  w='Blo-4'
       5:  w='Blo-5'
       6:  w='Blo-6'
    endcase
    TEXTOR_blo_chname(i)=w
  endfor
endif

;***** W7AS LBO system added by M. Bruchhausen 14.5.01
;***** modified on 20.7.01
;***** shot LT 40000 means data from simulation
IF shot LT 40000 THEN BEGIN
;  channame='/w7/user/bruchhau/idl/sim/channelnumber.dat'
;  openr,chanfile,channame,/get_lun
;    readf,chanfile,W7AS_blo_chnum
;    W7AS_blo_ch=fix(findgen(W7AS_blo_chnum)+1)
    W7AS_blo_chnum=(read_parafile(name='channelnumber.dat',$
      ncol=2,shot=shot))[0]
    IF W7AS_blo_chnum[0] EQ '' THEN BEGIN
;      print,'File not found:','channelnumber.dat'
      W7AS_blo_chnum=8
    ENDIF
    W7AS_blo_ch=fix(findgen(W7AS_blo_chnum)+1)
    W7AS_blo_chname=strarr(W7AS_blo_chnum) 
;  close,chanfile
;  free_lun,chanfile
;stop
ENDIF ELSE BEGIN
  W7AS_blo_chnum=8
;  W7AS_blo_ch=readusechannel(shot)
  W7AS_blo_ch = [1,2,3,4,5,6,7,8]
	if (not defined(W7AS_blo_ch)) then W7AS_blo_ch=[1,2,3,4,5,6,7,8]
  IF W7AS_blo_ch[0] EQ 0 THEN W7AS_blo_ch=fltarr(W7as_blo_chnum)
  W7AS_blo_ch=W7AS_blo_ch[sort(W7AS_blo_ch)]
  ;W7AS_blo_ch=list
  W7AS_blo_chname=strarr(W7AS_blo_chnum)
  W7AS_blo_ext_fsample=5e5
ENDELSE

IF (shot GT 51633) OR (shot LT 40000) THEN W7AS_blo_ext_fsample=1e6

;list=readusechannel(shot)
;list=list[sort(list)]
if (shot gt 50000)OR (shot LT 40000) then begin
  for i=0,W7AS_blo_chnum-1 do begin
    W7AS_blo_chname[i]=strcompress('Blo-'+string(W7AS_blo_ch[i]),/rem)
  endfor
endif

; ************* NI6115 system configurations ***********
NI_chnum=4
NI_ch=findgen(NI_chnum)+1
NI_chname=strarr(NI_chnum)
if ((shot ge 60700) and (shot le 70000)) or (shot lt 10000) then begin
  for i=0,NI_chnum-1 do begin
    case (NI_ch(i)) of
  ;
  ; *** Enter channel setup in this format *******  
  ; ch. number  signal name
  ;     |        |
  ;     |        |
  ;     V        V
     1:  w='Li-8'
     2:  w=''
     3:  w=''
     4:  w=''
    endcase
    NI_chname(i)=w
 endfor
endif
; ******** end of NI6115 system configurations *******

;******************** W7-AS Nicolet system configurations *******************

W7_nic_chnum=28
W7_nic_ch=findgen(W7_nic_chnum)+1
W7_nic_chname=strarr(W7_nic_chnum)

; **** Li2-Li17
IF ((shot GE 4) AND (shot LT 10)) THEN BEGIN
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-6'
       2: w='Li-7'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
ENDIF

IF ((shot GE 10) AND (shot LT 20000)) THEN BEGIN
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-2'
       2: w='Li-3'
       3: w='Li-4'
       4: w='Li-5'
       5: w='Li-6'
       6: w='Li-7'
       7: w='Li-8'
       8: w='Li-9'
       9: w='Li-10'
      10: w='Li-11'
      11: w='Li-12'
      12: w='Li-13'
      13: w='Li-14'
      14: w='Li-15'
      15: w='Li-16'
      16: w='Li-17'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
ENDIF

IF (shot EQ 20001) THEN BEGIN
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-5'
       3: w='Li-6'
       4: w='Li-7'
       5: w='Li-8'
       6: w='Li-9'
       7: w='Li-10'
       8: w='Li-11'
       9: w='Li-12'
      10: w='Li-13'
      11: w='Li-14'               
      12: w='Li-15'
      13: w='Li-16'
      14: w='Li-17'
      15: w='Li-18'
      16: w='Li-19'
	 16+1: w='Li-20'
	 16+2: w='Li-21'
	 16+3: w='Li-22'
	 16+4: w='Li-23'
	 16+5: w='Li-24'
	 16+6: w='Li-25'
	 16+7: w='Li-2'
	 16+8: w='Li-3'
	 16+9: w='Li-1'
	16+10: w='Li-26'
	16+11: w='Li-27'
	16+12: w='Li-28'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
ENDIF

if ((shot ge 31917) and (shot le 31999)) then begin
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-17'
       2: w='Li-18'
       3: w='Li-19'
       4: w='Li-20'
       5: w='Li-21'
       6: w='Li-22'
       7: w='Li-23'
       8: w='Li-24'
       9: w='Li-1'
      10: w='Li-2'
      11: w='Li-3'
      12: w='Li-4'
      13: w='Li-5'
      14: w='Li-6'
      15: w='Li-7'
      16: w='Li-8'
	 16+1: w='Li-9'
	 16+2: w='Li-10'
	 16+3: w='Li-11'
	 16+4: w='Li-12'
	 16+5: w='Li-13'
	 16+6: w='Li-14'
	 16+7: w='Li-15'
	 16+8: w='Li-16'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

; *** Li4-Li19
if ((shot ge 32000) and (shot le 39372)) then begin
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-5'
       3: w='Li-6'
       4: w='Li-7'
       5: w='Li-8'
       6: w='Li-9'
       7: w='Li-10'
       8: w='Li-11'
       9: w='Li-12'
      10: w='Li-13'
      11: w='Li-14'
      12: w='Li-15'
      13: w='Li-16'
      14: w='Li-17'
      15: w='Li-18'
      16: w='Li-19'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

; **** Li2-Li17
if ((shot ge 39373) and (shot le 39926)) or					$
	((shot ge 39934) and (shot le 40353)) then begin
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-2'
       2: w='Li-3'
       3: w='Li-4'
       4: w='Li-5'
       5: w='Li-6'
       6: w='Li-7'
       7: w='Li-8'
       8: w='Li-9'
       9: w='Li-10'
      10: w='Li-11'
      11: w='Li-12'
      12: w='Li-13'
      13: w='Li-14'
      14: w='Li-15'
      15: w='Li-16'
      16: w='Li-17'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

; *** Li4-Li19
if ((shot ge 40354) and (shot le 42599)) then begin
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-5'
       3: w='Li-6'
       4: w='Li-7'
       5: w='Li-8'
       6: w='Li-9'
       7: w='Li-10'
       8: w='Li-11'
       9: w='Li-12'
      10: w='Li-13'
      11: w='Li-14'
      12: w='Li-15'
      13: w='Li-16'
      14: w='Li-17'
      15: w='Li-18'
      16: w='Li-19'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 42600) and (shot le 43046)) then begin
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-5'
       3: w='Li-6'
       4: w='Li-7'
       5: w='Li-8'
       6: w='Li-9'
       7: w='Li-10'
       8: w='Li-11'
       9: w='Li-12'
      10: w='Li-13'
      11: w='Li-14'               
      12: w='Li-15'
      13: w='Li-16'
      14: w='Li-17'
      15: w='Li-18'
      16: w='Li-19'
	 16+1: w='Li-20'
	 16+2: w='Li-21'
	 16+3: w='Li-22'
	 16+4: w='Li-23'
	 16+5: w='Li-24'
	 16+6: w='Li-25'
	 16+7: w='Li-2'
	 16+8: w='Li-3'
	 16+9: w='Li-1'
	16+10: w='Li-26'
	16+11: w='Li-27'
	16+12: w='Li-28'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 43050) and (shot le 43069)) then begin
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w=''
       3: w='Li-6'
       4: w='Li-7'
       5: w='Li-8'
       6: w='Li-9'
       7: w='Li-10'
       8: w='Li-11'
       9: w='Li-12'
      10: w='Li-13'
      11: w='Li-14'
      12: w='Li-15'
      13: w='Li-16'
      14: w='Li-17'
      15: w='Li-18'
      16: w='Li-19'
	 16+1: w='Li-20'
	 16+2: w='Li-21'
	 16+3: w='Li-22'
	 16+4: w='Li-23'
	 16+5: w='Li-24'
	 16+6: w='Li-25'
	 16+7: w='Li-2'
	 16+8: w=''
	 16+9: w='Li-1'
	16+10: w='Li-26'
	16+11: w='Li-3'
	16+12: w='Li-5'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 43070) and (shot le 43074)) then begin
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Mir-A'
       2: w=''
       3: w='Li-6'
       4: w='Li-7'
       5: w='Li-8'
       6: w='Li-9'
       7: w='Li-10'
       8: w='Li-11'
       9: w='Li-12'
      10: w='Li-13'
      11: w='Li-14'
      12: w='Li-15'
      13: w='Li-16'
      14: w='Li-17'
      15: w='Li-18'
      16: w='Li-19'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif
                   
if ((shot ge 43078) and (shot le 43125)) then begin
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w=''
       3: w='Li-6'
       4: w='Li-7'
       5: w='Li-8'
       6: w='Li-9'
       7: w='Li-10'
       8: w='Li-11'
       9: w='Li-12'
      10: w='Li-13'
      11: w='Li-14'
      12: w='Li-15'
      13: w='Li-16'
      14: w='Li-17'
      15: w='Li-18'
      16: w='Li-19'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 43127) and (shot le 43294)) then begin
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 43295) and (shot le 43350)) then begin
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
	 16+1: w='Li-21'
	 16+2: w='Li-22'
	 16+3: w='Li-23'
	 16+4: w='Li-24'
	 16+5: w='Li-25'
	 16+6: w='Li-2'
	 16+7: w='Li-5'
	 16+8: w='Li-7'
	 16+9: w='Li-3'
	16+10: w='Li-26'
	16+11: w='Li-27'
	16+12: w='Li-28'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 43351) and (shot le 43393)) then begin
  ext_fsample = 5e5						; (500 kHz)
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
	 16+1: w='Li-21'
	 16+2: w='Li-22'
	 16+3: w='Li-23'
	 16+4: w='Li-24'
	 16+5: w='Li-25'
	 16+6: w='Li-2'
	 16+7: w='Li-5'
	 16+8: w='Li-7'
	 16+9: w='Li-3'
	16+10: w='Li-26'
	16+11: w='Li-27'
	16+12: w='Li-28'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 43398) and (shot le 43418)) then begin
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
	 16+1: w='Li-21'
	 16+2: w='Li-22'
	 16+3: w='Li-23'
	 16+6: w='Li-21'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 43419) and (shot le 43459)) then begin
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
	 16+1: w=''
	 16+2: w=''
	 16+3: w=''
	 16+4: w=''
	 16+5: w=''
	 16+6: w='Li-21'
	 16+7: w='Li-7'
	 16+8: w='Li-8'
	 16+9: w=''
	16+10: w=''
	16+11: w=''
	16+12: w=''
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 43460) and (shot le 43492)) then begin
  ext_fsample = 5e5						; (500 kHz)
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
	 16+1: w='Li-21'
	 16+2: w='Li-22'
	 16+3: w=''
	 16+4: w='Li-24'
	 16+5: w='Li-25'
	 16+6: w='Mir-A'
	 16+7: w='Halpha'
	 16+8: w='Li-7'
	 16+9: w='Li-5'
	16+10: w='Li-26'
	16+11: w='Li-3'
	16+12: w='Li-27'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if (shot eq 43519) then begin
  ext_fsample = 5e5						; (500 kHz)
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w=''
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if (shot eq 43520) then begin
  ext_fsample = 5e5						; (500 kHz)
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w=''
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
	 16+6: w='Li-21'
	 16+7: w='Li-22'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if (shot eq 43521) then begin
  ext_fsample = 5e5						; (500 kHz)
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
;       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
	 16+6: w='Li-21'
	 16+7: w='Li-22'
	 16+8: w='Mir-A'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 43522) and (shot le 43526)) then begin
  ext_fsample = 5e5						; (500 kHz)
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
	 16+1: w='Li-21'
	 16+2: w='Li-22'
	 16+3: w=''
	 16+4: w='Li-24'
	 16+5: w='Li-25'
	 16+6: w='Mir-A'
	 16+7: w='Halpha'
	 16+8: w='Li-7'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 43527) and (shot le 43530)) then begin
  ext_fsample = 5e5						; (500 kHz)
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
	 16+6: w='Li-21'
	 16+7: w='Li-22'
	 16+8: w='Halpha'
	 16+9: w='Li-24'
	16+10: w='Li-25'
	16+11: w='Li-7'
	16+12: w='Li-5'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 43531) and (shot le 43532)) then begin
  ext_fsample = 5e5						; (500 kHz)
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
	 16+6: w='Li-21'
	 16+7: w='Li-22'
	 16+8: w='Mir-A'
	 16+9: w='Li-24'
	16+10: w='Li-25'
	16+11: w='Li-7'
	16+12: w='Li-5'
       else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 43533) and (shot le 43541)) then begin
  ext_fsample = 5e5						; (500 kHz)
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Mir-A'
      16: w='Li-21'
	 16+6: w='Li-21'
	 16+7: w='Li-22'
	 16+8: w='Halpha'
	 16+9: w='Li-24'
	16+10: w='Li-25'
	16+11: w='Li-7'
	16+12: w='Li-5'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 43542) and (shot le 43545)) then begin
  ext_fsample = 5e5						; (500 kHz)
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
	 16+1: w='Li-21'
	 16+2: w='Li-22'
	 16+4: w='Li-24'
	 16+5: w='Li-25'
	 16+6: w='Mir-A'
	 16+7: w='Halpha'
	 16+8: w='Li-7'
       else: w=''
     endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 43572) and (shot le 43591)) then begin
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
	 16+1: w='Li-4'
	 16+2: w='Li-6'
	 16+4: w='Li-9'
	 16+5: w='Li-10'
	 16+6: w='Li-11'
	 16+7: w='Li-12'
	 16+8: w='Li-13'
	 16+9: w='Li-14'
	16+10: w='Li-15'
	16+11: w='Li-16'
	16+12: w='Li-17'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 43592) and (shot le 43606)) then begin
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
	 16+1: w='Li-4'
	 16+2: w='Li-6'
	 16+4: w='Li-9'
	 16+5: w='Li-10'
	 16+6: w='Li-11'
	 16+7: w='Li-12'
	 16+8: w='Li-13'
	 16+9: w='Li-14'
	16+10: w='Li-15'
	16+11: w='Li-16'
	16+12: w='Li-8'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 43610) and (shot le 43614)) then begin
  if (shot le 43613) then ext_fsample = 2.5e5					$
  			else ext_fsample = 5e5
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
	 16+1: w=''
	 16+2: w=''
	 16+3: w=''
	 16+4: w=''
	 16+5: w='Mir-A'
	 16+6: w='Li-21'
	 16+7: w='Li-22'
	 16+8: w='Li-23'
	 16+9: w='Li-24'
	16+10: w='Li-25'
	16+11: w='Li-7'
	16+12: w='Li-5'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if (shot eq 43615) then begin
  ext_fsample = 5e5						; (500 kHz)
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
	 16+6: w='Li-21'
	 16+7: w='Li-22'
	 16+8: w='Li-23'
	 16+9: w='Mir-A'
	16+10: w='Li-25'
	16+11: w='Li-7'
	16+12: w='Li-5'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 43616) and (shot le 43651)) then begin
  ext_fsample = 5e5					; (500 kHz)
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
	 16+6: w='Li-21'
	 16+7: w='Li-22'
	 16+8: w='Mir-A'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 43658) and (shot le 43661)) then begin
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif
if ((shot ge 43662) and (shot le 43770)) then begin
  if (((shot ge 43662) and (shot le 43669)) or $
      ((shot ge 43690) and (shot le 43693))) then ext_fsample = 2.5e5		$
						else ext_fsample = 5e5
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
	 16+1: w='Li-21'
	 16+2: w='Li-22'
	 16+4: w='Li-24'
	 16+5: w=''
	 16+6: w='Mir-A'
	 16+7: w='Li-23'
	 16+8: w='Li-7'
	 16+9: w=''
	16+10: w=''
	16+11: w=''
	16+12: w='Li-21'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 43835) and (shot le 43894)) then begin
  if (((shot ge 43835) and (shot le 43845))) or $
	((shot ge 43873) and (shot le 43874)) then ext_fsample = 1e6 		$
						else ext_fsample = 5e5 
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
	 16+1: w='Li-22'
	 16+2: w='Li-23'
	 16+4: w='Li-24'
	 16+5: w='Li-25'
	 16+6: w='Mir-A'
	 16+7: w='Li-7'
	 16+8: w='Li-5'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 43895) and (shot le 43938)) then begin
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
	 16+1: w='Li-4'
	 16+2: w='Li-6'
	 16+3: w=''
	 16+4: w='Li-9'
	 16+5: w='Li-10'
	 16+6: w='Li-11'
	 16+7: w='Li-12'
	 16+8: w='Li-13'
	 16+9: w='Li-14'
	16+10: w='Li-15'
	16+11: w='Li-16'
	16+12: w='Li-17'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 43962) and (shot le 43974)) then begin
  ext_fsample = 1e6 
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 43975) and (shot le 43980)) then begin
  ext_fsample = 1e6 
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Hl2101'
       2: w='Hu2201'
       3: w='Hl2102'
       4: w='Hu2202'
       5: w='Hl2103'
       6: w='Hu2203'
       7: w='Hl2104'
       8: w='Hu2204'
       9: w='Hl2105'
      10: w='Hu2205'
      11: w='Hl2106'
      12: w='Hu2206'
      13: w='Hl2107'
      14: w='Hu2207'
      15: w='Hl2108'
      16: w='Hu2208'
	 16+1: w='Li-22'
	 16+2: w='Li-23'
	 16+4: w='Li-24'
	 16+5: w='Li-25'
	 16+6: w='Mir-A'
	 16+7: w='Li-26'
	 16+8: w='Pressure'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if (shot eq 43981) or								$
    ((shot ge 43991) and (shot le 43992)) or					$
    (shot eq 43996) then begin
  ext_fsample = 1e6 
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Hl2101'
       2: w='Hu2201'
       3: w='Hl2102'
       4: w='Hu2202'
       5: w='Hl2103'
       6: w='Hu2203'
       7: w='Hl2104'
       8: w='Hu2204'
       9: w='Hl2105'
      10: w='Hu2205'
      11: w='Hl2106'
      12: w='Hu2206'
      13: w='Hl2107'
      14: w='Hu2207'
      15: w='Hl2108'
      16: w='Hu2208'
	 16+1: w='Li-22'
	 16+2: w='Li-23'
	 16+4: w='Li-24'
	 16+5: w='Li-25'
	 16+6: w='Mir-A'
	 16+7: w='Li-26'
	 16+8: w='Li-27'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif
if ((shot ge 43982) and (shot le 43990)) or					$
    ((shot ge 43993) and (shot le 43995)) or					$
    ((shot ge 43997) and (shot le 44000)) then begin
  ext_fsample = 1e6 
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
	 16+1: w='Li-22'
	 16+2: w='Li-23'
	 16+4: w='Li-24'
	 16+5: w='Li-25'
	 16+6: w='Mir-A'
	 16+7: w='Li-26'
	 16+8: w='Li-27'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if (shot eq 44011) then begin
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 45277) and (shot le 45288)) then begin
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
       else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

if ((shot ge 47937) and (shot le 48038)) then begin
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Mir-A'
       3: w='Li-6'
       4: w='Li-8'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif
                                 
if (shot eq 48126) or (shot eq 48153) or 					$
	((shot ge 48174) and (shot le 48207)) then begin
  subchannels = 2	; Deflected beam measurement
  ext_fsample = 1	; This would mean f = 1 Hz. Actually the samples are 
			; non-equidistant therefor the timescale returned by
			; get_rawsignal() should be interpreted as signal index 
  starttime =  0.2
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Mir-A'
       3: w='Li-6'
       4: w='Li-8'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18
      14: w='Li-19'
      15: w='Li-20'
      16: w='Control-A'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

IF (shot EQ 49727) OR (shot EQ 49729) OR					$
	((shot GE 49732) AND (shot LE 49736)) OR				$
	((shot GE 49740) AND (shot LE 49746)) THEN BEGIN
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
       else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
ENDIF

IF ((shot GE 49755) AND (shot LE 49767)) OR					$
	(shot EQ 49777) OR							$
	((shot GE 49789) AND (shot LE 49791)) OR				$
	((shot GE 49797) AND (shot LE 49817)) OR				$
	((shot GE 49831) AND (shot LE 49844)) OR				$
	((shot GE 49854) AND (shot LE 49887)) OR				$
	((shot GE 49891) AND (shot LE 49912)) OR				$
	((shot GE 49962) AND (shot LE 49964)) OR				$
	((shot GE 49968) AND (shot LE 49981)) OR				$
	((shot GE 49996) AND (shot LE 50011)) OR				$
	((shot GE 50013) AND (shot LE 50023)) THEN BEGIN
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w=''
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
       else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
ENDIF

IF ((shot GE 50028) AND (shot LE 50066)) OR				$
	((shot GE 50068) AND (shot LE 50076)) THEN BEGIN
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
       else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
ENDIF

IF ((shot GE 50131) AND (shot LE 50142)) OR					$
	((shot GE 50165) AND (shot LE 50171)) THEN BEGIN
	
  IF (shot EQ 50131) OR (shot EQ 50132) OR					$
	((shot GE 50134) AND (shot LE 50138)) OR				$
	((shot GE 50167) AND (shot LE 50171)) THEN BEGIN
    subchannels = 2	; Deflected beam measurement
    ext_fsample = 1	; This would be 1 Hz. Actually the samples are 
			; non-equidistant therefor the timescale returned by
			; get_rawsignal() should be interpreted as sample number
    IF (shot EQ 50131) OR (shot EQ 50132) THEN	starttime =  0.1
    IF (shot EQ 50134) THEN			starttime =  0.0
    IF ((shot GE 50135) AND (shot LE 50138)) OR					$
	((shot GE 50167) AND (shot LE 50171)) THEN starttime = -0.1
  ENDIF
  
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Control-A'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
ENDIF

if ((shot ge 50448) and (shot le 50470)) then begin
  subchannels = 2	; Deflected beam measurement
  ext_fsample = 1	; This would be 1 Hz. Actually the samples are 
			; non-equidistant therefor the timescale returned by
			; get_rawsignal() should be interpreted as sample number
  starttime =  0.4
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w=''
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif

IF ((shot EQ 50511) OR (shot EQ 50512)) THEN BEGIN
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w=''
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
ENDIF

IF ((shot GE 50513) AND (shot LE 50551)) OR					$
	((shot GE 50559) AND (shot LE 50588)) OR				$
	(shot EQ 50606) OR							$
	((shot GE 50617) AND (shot LE 50640)) OR				$
	((shot GE 50645) AND (shot LE 50684)) OR				$
	((shot GE 50690) AND (shot LE 50711)) OR				$
	((shot GE 50737) AND (shot LE 50772)) THEN BEGIN
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
      else: w=''
    endcase
    W7_nic_chname(i)=w
  endfor
ENDIF

IF ((shot GE 51168) AND (shot LE 51181)) THEN BEGIN
  subchannels = 2	; Deflected beam measurement
  ext_fsample = 1	; This would be 1 Hz. Actually the samples are 
			; non-equidistant therefor the timescale returned by
			; get_rawsignal() should be interpreted as sample number
  starttime = 0.3
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'	; ?????
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
ENDIF

IF ((shot GE 51188) AND (shot LE 51190)) OR					$
	((shot GE 51192) AND (shot LE 51194)) OR				$
	((shot GE 51196) AND (shot LE 51200)) OR 				$
	(shot EQ 51206) THEN BEGIN
  subchannels = 2	; Deflected beam measurement
  ext_fsample = 1	; This would be 1 Hz. Actually the samples are 
			; non-equidistant therefor the timescale returned by
			; get_rawsignal() should be interpreted as sample number
  IF ((shot GE 51188) AND (shot LE 51190)) THEN starttime = 0.4
  IF ((shot GE 51191) AND (shot LE 51206)) THEN starttime = 0.2
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-24'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
ENDIF

IF ((shot GE 51201) AND (shot LE 51205)) THEN BEGIN
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-24'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
      16+1: w='Lang28-21'
      16+2: w='Lang28-28'
      16+3: w='Lang28-27'
      16+4: w='Lang28-26'
      16+5: w='Lang28-25'
      16+6: w='Lang28-24'
      16+7: w='Lang28-23'
      16+8: w='Lang28-22'      
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
ENDIF

IF ((shot GE 51540) AND (shot LE 51565)) THEN BEGIN

  IF ((shot GE 51541) AND (shot LE 51542)) OR					$
	((shot GE 51547) AND (shot LE 51553)) OR				$
	((shot GE 51556) AND (shot LE 51565)) THEN BEGIN
    subchannels = 2	; Deflected beam measurement
    ext_fsample = 1	; This would be 1 Hz. Actually the samples are 
			; non-equidistant therefor the timescale returned by
			; get_rawsignal() should be interpreted as sample number
    IF ((shot GE 51541) AND (shot LE 51546)) THEN starttime = 0.2
    IF ((shot GE 51547) AND (shot LE 51559)) THEN starttime = 0.4
    IF ((shot GE 51560) AND (shot LE 51565)) THEN starttime = 0.5
  ENDIF
  
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-24'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
ENDIF

IF ((shot GE 51611) AND (shot LE 51620)) OR					$
	((shot GE 51622) AND (shot LE 51626)) THEN BEGIN
  IF ((shot GE 51614) AND (shot LE 51617)) OR					$
	((shot GE 51623) AND (shot LE 51626)) THEN BEGIN
    subchannels = 2	; Deflected beam measurement
    ext_fsample = 1	; This would be 1 Hz. Actually the samples are 
			; non-equidistant therefor the timescale returned by
			; get_rawsignal() should be interpreted as sample number
    starttime = 0.4
  ENDIF
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-24'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
ENDIF

IF ((shot GE 52122) AND (shot LE 52179)) THEN BEGIN
    subchannels = 2	; Deflected beam measurement
    ext_fsample = 1	; This would be 1 Hz. Actually the samples are 
			; non-equidistant therefore the timescale returned by
			; get_rawsignal() should be interpreted as sample number
    starttime = 0.4
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
      16+1: w='Li-22'
      16+2: w=''
      16+3: w='Li-24'
      16+5: w='Li-26'
      16+7: w=''
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
ENDIF

IF ((shot GE 54436) AND (shot LE 54596)) THEN BEGIN
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
ENDIF
IF ((shot GE 54603) AND (shot LE 54802)) THEN BEGIN
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-5'
      16: w='Li-7'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
ENDIF

IF ((shot GE 54803) AND (shot LE 54810)) THEN BEGIN
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-9'
       3: w='Li-8'
       4: w='Li-6'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-19'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-16'
      15: w='Li-7'
      16: w='Li-5'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
ENDIF

IF ((shot GE 54811) AND (shot LE 54818)) THEN BEGIN
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-10'
       5: w='Li-9'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-5'
      16: w='Li-7'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
ENDIF
IF ((shot GE 54819) AND (shot LE 54837)) THEN BEGIN
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-5'
      16: w='Li-7'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
ENDIF
IF ((shot GE 54838) AND (shot LE 54852)) THEN BEGIN
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-10'
       5: w='Li-9'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-5'
      16: w='Li-7'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
ENDIF
IF ((shot GE 54853) AND (shot LE 54857)) THEN BEGIN
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-5'
      16: w='Li-7'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
ENDIF
IF ((shot GE 54853) AND (shot LE 54897)) THEN BEGIN
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-5'
      16: w='Li-7'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
ENDIF
IF ((shot GE 54898) AND (shot LE 54900)) THEN BEGIN
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-12'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-9'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-19'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-16'
      15: w='Li-5'
      16: w='Li-7'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
ENDIF
IF ((shot GE 54901) AND (shot LE 54911)) THEN BEGIN
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-9'
       3: w='Li-8'
       4: w='Li-6'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-19'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-16'
      15: w='Li-5'
      16: w='Li-7'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
ENDIF

if (shot ge 70000) then begin			; test shots
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor 
endif


if ((shot ge 100) and (shot lt 200)) then begin			; test shots
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor 
endif
if (shot ge 90030) then begin   ; Simulated shots after meas_config was written
  for i=0,W7_nic_chnum-1 do begin
    case (W7_nic_ch(i)) of
       1: w='Li-4'
       2: w='Li-6'
       3: w='Li-8'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-11'
       7: w='Li-12'
       8: w='Li-13'
       9: w='Li-14'
      10: w='Li-15'
      11: w='Li-16'
      12: w='Li-17'
      13: w='Li-18'
      14: w='Li-19'
      15: w='Li-20'
      16: w='Li-21'
	 16+1: w='Li-22'
	 16+2: w='Li-23'
	 16+4: w='Li-24'
	 16+5: w='Li-25'
	 16+6: w='Mir-A'
	 16+7: w='Li-26'
	 16+8: w='Li-27'
      else: w=''
    endcase
    W7_nic_chname(i)=w 
  endfor
endif


;************* end of W7-AS Nicolet system configurations *******************

;********************* AUG Nicolet system configurations ********************

AUG_nic_chnum=28
AUG_nic_ch=findgen(AUG_nic_chnum)+1
AUG_nic_chname=strarr(AUG_nic_chnum)
if (shot eq 11052) then begin 
  for i=0,AUG_nic_chnum-1 do begin
    case (AUG_nic_ch(i)) of
       2: w='Li-5'
       3: w='Li-7'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-12'
       7: w='Li-15'
       8: w='Li-18'
       9: w='Li-19'
      10: w='Li-22'
      11: w='Li-23'
      12: w='Li-26'
      13: w='Li-28'
      14: w='Li-29'
      15: w='Li-31'
      else: w=''
    endcase
    AUG_nic_chname(i)=w 
  endfor
endif

if ((shot ge 11053) and (shot le 11067)) then begin 
  for i=0,AUG_nic_chnum-1 do begin
    case (AUG_nic_ch(i)) of
       1: w='Li-3'
       2: w='Li-5'
       3: w='Li-7'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-12'
       7: w='Li-15'
       8: w='Li-18'
       9: w='Li-19'
      10: w='Li-22'
      11: w='Li-23'
      12: w='Li-26'
      13: w='Li-28'
      14: w='Li-29'
      15: w='Li-31'
      else: w=''
    endcase
    AUG_nic_chname(i)=w 
  endfor
endif

if ((shot ge 11068) and (shot lt 11070)) then begin 
  for i=0,AUG_nic_chnum-1 do begin
    case (AUG_nic_ch(i)) of
       1: w='Li-16'
       2: w='Li-17'
       3: w='Li-7'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-12'
       7: w='Li-15'
       8: w='Li-18'
       9: w='Li-19'
      10: w='Li-22'
      11: w='Li-23'
      12: w='Li-26'
      13: w='Li-28'
      14: w='Li-14'
      15: w='Li-21'
      else: w=''
    endcase
    AUG_nic_chname(i)=w 
  endfor
endif

if ((shot ge 11070) and (shot le 11091)) then begin 
  for i=0,AUG_nic_chnum-1 do begin
    case (AUG_nic_ch(i)) of
       1: w='Li-16'
       2: w='Li-17'
       3: w='Li-7'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-12'
       7: w='Li-15'
       8: w='Li-18'
       9: w='Li-19'
      10: w='Li-22'
      11: w='Li-23'
      12: w=''
      13: w='Li-28'
      14: w='Li-14'
      15: w='Li-21'
      else: w=''
    endcase
    AUG_nic_chname(i)=w 
  endfor
endif

if ((shot ge 11096) and (shot le 11112)) then begin 
  for i=0,AUG_nic_chnum-1 do begin
    case (AUG_nic_ch(i)) of
       1: w='Li-16'
       2: w='Li-17'
       3: w='Li-7'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-12'
       7: w='Li-15'
       8: w='Li-18'
       9: w='Li-19'
      10: w='Li-22'
      11: w='Li-23'
      12: w='Li-26'
      13: w='Li-3'
      14: w='Li-14'
      15: w='Li-21'
      else: w=''
    endcase
    AUG_nic_chname(i)=w 
  endfor
endif

if ((shot ge 11117) and (shot le 11124)) then begin 
  for i=0,AUG_nic_chnum-1 do begin
    case (AUG_nic_ch(i)) of
       1: w='Li-16'
       2: w='Li-17'
       3: w='Li-7'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-12'
       7: w='Li-15'
       8: w='Li-18'
       9: w='Li-19'
      10: w='Li-22'
      11: w='Li-23'
      12: w=''
      13: w='Li-3'
      14: w='Li-14'
      15: w='Li-21'
      else: w=''
    endcase
    AUG_nic_chname(i)=w 
  endfor
endif

if ((shot ge 11125) and (shot le 11127)) then begin 
  for i=0,AUG_nic_chnum-1 do begin
    case (AUG_nic_ch(i)) of
       1: w='Li-16'
       2: w='Li-17'
       3: w='Li-7'
       4: w='Li-9'
       5: w='Li-10'
       6: w='Li-12'
       7: w='Li-15'
       8: w='Li-18'
       9: w='Li-19'
      10: w='Li-22'
      11: w='Li-23'
      12: w='Li-26'
      13: w='Li-3'
      14: w='Li-14'
      15: w='Li-21'
      else: w=''
    endcase
    AUG_nic_chname(i)=w 
  endfor
endif

;********* end of AUG Nicolet system configurations ***************

;********************* JET Li-beam system configurations ********************

JET_Libeam_chnum=1
JET_Libeam_ch=[5]
JET_Libeam_chname=strarr(JET_Libeam_chnum)
if ((shot ge 55170) and (shot le 55216)) then begin 
  for i=0,JET_Libeam_chnum-1 do begin
    case (JET_Libeam_ch(i)) of
       5: w='Li-15'
      else: w=''
    endcase
    JET_Libeam_chname(i)=w 
  endfor
endif

if (shot ge 55217) then begin 
  for i=0,JET_Libeam_chnum-1 do begin
    case (JET_Libeam_ch(i)) of
       5: w='Li-8'
      else: w=''
    endcase
    JET_Libeam_chname(i)=w 
  endfor
endif

if ((shot ge 59612) and (shot le 59621)) then begin 
  for i=0,JET_Libeam_chnum-1 do begin
    case (JET_Libeam_ch(i)) of
       5: w='Li-15'
      else: w=''
    endcase
    JET_Libeam_chname(i)=w 
  endfor
endif

if ((shot ge 59622) and (shot le 59630)) then begin 
  for i=0,JET_Libeam_chnum-1 do begin
    case (JET_Libeam_ch(i)) of
       5: w='Li-8'
      else: w=''
    endcase
    JET_Libeam_chname(i)=w 
  endfor
endif

if ((shot ge 59636) and (shot le 59637)) then begin 
  for i=0,JET_Libeam_chnum-1 do begin
    case (JET_Libeam_ch(i)) of
       5: w='Li-8'
      else: w=''
    endcase
    JET_Libeam_chname(i)=w 
  endfor
endif

if ((shot ge 59638) and (shot le 59647)) then begin 
  for i=0,JET_Libeam_chnum-1 do begin
    case (JET_Libeam_ch(i)) of
       5: w='Li-15'
      else: w=''
    endcase
    JET_Libeam_chname(i)=w 
  endfor
endif

;********************* End of JET Li-beam system configurations ********************



syslist=0

ind=where(W7_nic_chname ne '')
if (ind(0) ge 0) then begin
  W7_nic_ch=W7_st_ch(ind)
  W7_nic_chname=W7_nic_chname(ind)
  if (not syslist) then avail_system=0 else avail_system=[avail_system,0]
  syslist=1
endif

ind=where(W7_st_chname ne '')
if (ind(0) ge 0) then begin
  W7_st_ch=W7_st_ch(ind)
  W7_st_chname=W7_st_chname(ind)
  if (not syslist) then avail_system=2 else avail_system=[avail_system,2]
  syslist=1
endif    

ind=where(AUG_st_chname ne '')
if (ind(0) ge 0) then begin
  AUG_st_ch=AUG_st_ch(ind)
  AUG_st_chname=AUG_st_chname(ind)
  if (not syslist) then avail_system=3 else avail_system=[avail_system,3]
  syslist=1
endif 
   
ind=where(AUG_nic_chname ne '')
if (ind(0) ge 0) then begin
  AUG_nic_ch=AUG_st_ch(ind)
  AUG_nic_chname=AUG_nic_chname(ind)
  if (not syslist) then avail_system=5 else avail_system=[avail_system,5]
  syslist=1
endif    

ind=where(TEXTOR_li_chname ne '')
if (ind(0) ge 0) then begin
  TEXTOR_li_ch=TEXTOR_li_ch(ind)
  TEXTOR_li_chname=TEXTOR_li_chname(ind)
  if (not syslist) then avail_system=7 else avail_system=[avail_system,7]
  syslist=1
endif    

ind=where(TEXTOR_blo_chname ne '')
if (ind(0) ge 0) then begin
  TEXTOR_blo_ch=TEXTOR_blo_ch(ind)
  TEXTOR_blo_chname=TEXTOR_blo_chname(ind)
  if (not syslist) then avail_system=8 else avail_system=[avail_system,8]
  syslist=1
endif    

ind=where(TEXTOR_li_test_chname ne '')
if (ind(0) ge 0) then begin
  TEXTOR_li_test_ch=TEXTOR_li_test_ch(ind)
  TEXTOR_li_test_chname=TEXTOR_li_test_chname(ind)
  if (not syslist) then avail_system=9 else avail_system=[avail_system,9]
  syslist=1
endif    

ind=where(W7AS_blo_chname ne '')
if (ind(0) ge 0) then begin
  W7AS_blo_ch=W7AS_blo_ch(ind)
  W7AS_blo_chname=W7AS_blo_chname(ind)
  if (not syslist) then avail_system=10 else avail_system=[avail_system,10]
  syslist=1
endif    

ind=where(JET_Libeam_chname ne '')
if (ind(0) ge 0) then begin
  JET_Libeam_ch=JET_Libeam_ch(ind)
  JET_Libeam_chname=JET_Libeam_chname(ind)
  if (not syslist) then avail_system=11 else avail_system=[avail_system,11]
  syslist=1
endif    

ind=where(NI_chname ne '')
if (ind(0) ge 0) then begin
  NI_ch=NI_ch(ind)
  NI_chname=NI_chname(ind)
  if (not syslist) then avail_system=13 else avail_system=[avail_system,13]
  syslist=1
endif    

; Indicate that 14,15  is always available
if (not syslist) then avail_system=[14,15] else avail_system=[avail_system,14,15]
syslist=1


if (not defined(data_source)) then return,0

if ((where(data_source eq avail_system))(0) lt 0) then begin
  errortext='No data available for shot '+i2str(shot,digits=5)+' in system '
  get_rawsignal,shot,data_names=data_names
  errortext = errortext+'"'+data_names(data_source)+'"'
  if (not keyword_set(silent)) then print,errortext
  return,1
endif

if (data_source eq 0) then begin
  channel_list=W7_nic_ch
  signal_list=W7_nic_chname
  return,0
endif 

if (data_source eq 2) then begin
  channel_list=W7_st_ch
  signal_list=W7_st_chname
  return,0
endif
                    
if (data_source eq 3) then begin
  channel_list=AUG_st_ch
  signal_list=AUG_st_chname
  return,0
endif

if (data_source eq 5) then begin
  channel_list=AUG_nic_ch
  signal_list=AUG_nic_chname
  return,0
endif

if (data_source eq 7) then begin
  channel_list=TEXTOR_li_ch
  signal_list=TEXTOR_li_chname
  ext_fsample=TEXTOR_li_ext_fsample
  starttime=TEXTOR_starttime
  return,0
endif
   
if (data_source eq 8) then begin
  channel_list=TEXTOR_blo_ch
  signal_list=TEXTOR_blo_chname
  ext_fsample=TEXTOR_blo_ext_fsample
  return,0
endif

if (data_source eq 9) then begin
  channel_list=TEXTOR_li_test_ch
  signal_list=TEXTOR_li_test_chname
  ext_fsample=TEXTOR_li_test_ext_fsample
  return,0
endif

if (data_source eq 10) then begin
  channel_list=W7AS_blo_ch
  signal_list=W7AS_blo_chname
  ext_fsample=W7AS_blo_ext_fsample
  return,0
endif

if (data_source eq 11) then begin
  channel_list=JET_Libeam_ch
  signal_list=JET_Libeam_chname
  return,0
endif 

if (data_source eq 13) then begin
; Trying to get starttime from list
  d=loadncol('NI_JET_starttime.dat',2,errormess=errormess,/silent)
  if (errormess eq '') then begin
    file_loaded = 1
    ind = (where(d[*,0] eq shot))[0]
    if (ind lt 0) then begin
      errormess = '-'
    endif else begin
      starttime = d[ind,1]
    endelse
  endif  
  if (errormess ne '') then begin ; Could not find in list
    get_jet_libtiming,shot,timing=timing,errormess=errormess
    if (errormess ne '') then begin  
      errortext='Cannot determine measurement start time. Need  NI_JET_starttime.dat file or JAC.'
      return,1
    endif
    starttime = timing.PCstart
    if (keyword_set(file_loaded)) then begin
      d1 = fltarr((size(d))[1]+1,(size(d))[2])
      d1[0:(size(d1))[1]-2,*] = d
    endif else begin
      d1 = fltarr(1,2)
    endelse
    d1[(size(d1))[1]-1,0] = shot
    d1[(size(d1))[1]-1,1] = starttime
    savencol,d1,'NI_JET_starttime.dat'
  endif  
  channel_list=NI_ch
  signal_list=NI_chname
  return,0
endif 

if (data_source eq 14) then begin
  channel_list=findgen(25)+1
  signal_list=string(indgen(25)+1)
  return,0
endif

if (data_source eq 15) then begin
  channel_list=[findgen(15)+10,findgen(14)+34,findgen(48)+49]
  signal_list=string(long(channel_list))
  return,0
endif

END



