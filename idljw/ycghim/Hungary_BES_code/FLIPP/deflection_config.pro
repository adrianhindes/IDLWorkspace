PRO DEFLECTION_CONFIG,shot,DATA_SOURCE=data_source,param,DATAPATH=datapath,$
    STARTTIME=starttime,PERIOD_TIME=period_time,       $
    SAMPLETIME=sampletime,PERIOD_N=period_sample_n, PERIOD_CYCLE_N=period_n,$
    START_SAMPLE=start_sample,MASK_DOWN=mask_down,MASK_UP=mask_up,     $
    U_UP=U_up,U_DOWN=U_down,U_switch1=U_switch1,U_switch2=U_switch2, $
    ERRORMESS = errormess,SILENT=silent

; ****************************************************************************
; deflection_config.pro      Original version  S. Zoletnik 08.11.1996
;                            Added TEXTOR support through XML files 16.03.2008
; ****************************************************************************
; Returns the settings of the beam deflection.
;
;
; INPUT
; shot          shot number of deflected measurement
; data_soruce   The experiment (see get_rawsignal.pro)
; datapath      The directory for reading data
;
; OUTPUT
; param         parameter vector of deflected measurement  (for W7-AS only)
; starttime:    start time of the fast deflection (sec). This corresponds to start_sample
; period_time:   period time of beam deflection (sec) (!!! Should be multiple of sampletime !!!)
; sampletime:   time between two consecutive samples within period (sec)
; period_n:  number of samples in one period
; period_cycle_n: Number of deflection period cycles
; start_sample: first sample in first period (It is assumed that this sample
;     is taken at the starttime. This is not always exact, but the value
;     of starttime is also not very exact.)
; mask_up:  list of indices in one period where beam is at upper position
; mask_down:    list of indices in one period where beam is at lower position
;       -> mask_up and mask_down should have equal number of elements <-
; U_up:     voltage on upper deflection plate (V)
; U_down:   voltage on lower deflection plate (V)
;       -> the HV switch is connected to the one that is 0
; U_switch1:    voltage 1 on the HV switch (V)
; U_switch2:    voltage 2 on the HV switch (V)
; ERRORMESS:    Error message or ''
; /SILENT:      Do not print error message just return in ERRORMESS
;***************************************************************************

errormess = ''
default,data_source,fix(local_default('data_source'))
default,datapath,local_default('datapath')

if (not keyword_set(shot)) then begin
  errormess = 'No shot number is set.'
  if (not keyword_set(silent)) then print,errormess
  return
endif

if (data_source eq 25) then begin  ; TEXTOR


  load_config_parameter,shot,'Beam','Energy',data_source=data_source,errormess=errormess,output_struct=s,/silent
  if (errormess ne '') then return
  beam_energy = s.value

  load_config_parameter,shot,'Beam','Species',data_source=data_source,errormess=errormess,output_struct=s,/silent
  if (errormess ne '') then return

  case s.value of
    'Lithium': beam_mass = 6.94
  endcase
  if (not keyword_set(beam_mass)) then begin
    errormess = 'Unknown beam species.'
    if (not keyword_set(silent)) then print,errormess
    return
  endif

  ;print,'Beam mass:',beam_mass
  beam_velocity = sqrt(2*beam_energy*1e3*1.6e-19/(beam_mass*1.66e-27))
  ; print,'Beam velocity:',beam_velocity

  load_config_parameter,shot,'Timing','Mode',data_source=data_source,errormess=errormess,output_struct=s,/silent
  if (errormess ne '') then return

  ; Check whether this shot was done with fast deflection
  if ((s.value ne 'Fast') and (s.value ne 'Deflection') and (s.value ne 'Fast_chopping')) then begin
    errormess = 'Shot is not in fast deflection mode.'
    if (not keyword_set(silent)) then print,errormess
    return
  endif

  load_config_parameter,shot,'Timing','TriggerTime',data_source=data_source,errormess=errormess,output_struct=s,/silent
  if (errormess ne '') then return
  TriggerTime = s.value
  ;print,'TriggerTime:',TriggerTime

  load_config_parameter,shot,'ADCSettings','SampleFreq',data_source=data_source,errormess=errormess,output_struct=s,/silent
  if (errormess ne '') then return
  sampletime = 1./(double(s.value)*1e6)
  ;print,'sampletime:',sampletime

  load_config_parameter,shot,'ADCSettings','StartTime',data_source=data_source,errormess=errormess,output_struct=s,/silent
  if (errormess ne '') then return
  ADC_starttime = s.value
  ;print,'ADC starttime:',ADC_starttime

  load_config_parameter,shot,'ChopperSettings','BaseClock',data_source=data_source,errormess=errormess,output_struct=s,/silent
  if (errormess ne '') then return
  baseclock = s.value
  ;print,'baseclock:',baseclock

  load_config_parameter,shot,'ChopperSettings','OnTime',data_source=data_source,errormess=errormess,output_struct=s,/silent
  if (errormess ne '') then return
  chop_ontime = s.value
  ;print,'chop_ontime:',chop_ontime

  load_config_parameter,shot,'ChopperSettings','OffTime',data_source=data_source,errormess=errormess,output_struct=s,/silent
  if (errormess ne '') then return
  chop_offtime = s.value
  ;print,'chop_offtime:',chop_offtime

  period_time = (chop_ontime+chop_offtime)/(baseclock*1e3)
  ;print,'period_time',period_time
  if (abs(period_time/sampletime - round(period_time/sampletime)) gt 1e-5) then begin
    errormess = 'Deflection period time is not a multiple of sampling time.'
    if (not keyword_set(silent)) then print,errormess
    return
  endif
  period_sample_n = fix(round(period_time/sampletime))

  load_config_parameter,shot,'ChopperSettings','StartTime',data_source=data_source,errormess=errormess,output_struct=s,/silent
  if (errormess ne '') then return
  starttime = s.value/(baseclock*1e3)+TriggerTime
  ;print,'starttime:',starttime

  if (starttime lt ADC_starttime) then begin
    errormess = 'Deflection start time is before ADC start time.'
    if (not keyword_set(silent)) then print,errormess
    return
  endif

  start_sample = round((starttime-ADC_starttime)/sampletime)+2
  if ((start_sample - long(start_sample)) ne 0) then begin
    errormess = 'Deflection start time is not a multiple of sampling time.'
    if (not keyword_set(silent)) then print,errormess
    return
  endif
  ;print,'start_sample',start_sample

  load_config_parameter,shot,'ChopperSettings','PeriodNumber',data_source=data_source,errormess=errormess,output_struct=s,/silent
  if (errormess ne '') then return
  period_n = s.value
  ;print,'period_n:',period_n

  load_config_parameter,shot,'ChopperSettings','Voltage_upper_on',data_source=data_source,errormess=errormess,output_struct=s,/silent
  if (errormess ne '') then begin
    U_upper_on = 0
  endif else begin
    U_upper_on = s.value
  endelse
  ;print,'U_upper_on:',U_upper_on

  load_config_parameter,shot,'ChopperSettings','Voltage_upper_off',data_source=data_source,errormess=errormess,output_struct=s,/silent
  if (errormess ne '') then begin
    U_upper_off = 0
  endif else begin
    U_upper_off = s.value
  endelse
  ;print,'U_upper_off:',U_upper_off

  load_config_parameter,shot,'ChopperSettings','Voltage_lower_on',data_source=data_source,errormess=errormess,output_struct=s,/silent
  if (errormess ne '') then begin
    U_lower_on = 0
  endif else begin
    U_lower_on = s.value
  endelse
  ;print,'U_lower_on:',U_lower_on

  load_config_parameter,shot,'ChopperSettings','Voltage_lower_off',data_source=data_source,errormess=errormess,output_struct=s,/silent
  if (errormess ne '') then begin
    U_lower_off = 0
  endif else begin
    U_lower_off = s.value
  endelse
  ;print,'U_lower_off:',U_lower_off

  load_config_parameter,shot,'Geometry','ChopperBeamCoordinate',data_source=data_source,errormess=errormess,output_struct=s,/silent
  if (errormess ne '') then return
  ChopperBeamCoordinate = s.value
  ;print,'ChopperBeamCoordinate :',ChopperBeamCoordinate

  ; Determining the flight time to the middle channel in the optics
  load_config_parameter,shot,'Optics','BES-8_BeamCoordinate',data_source=data_source,errormess=errormess,output_struct=s,/silent
  if (errormess ne '') then return
  SignalBeamCoordinate = s.value
  ;print,'SignalBeamCoordinate :',SignalBeamCoordinate

  FlightTime = (SignalBeamCoordinate-ChopperBeamCoordinate)*1e-3/beam_velocity
  ; print,'FlightTime',FlightTime

  ; We add all the delays form the timer switch time to the beam movement in the observation regiou
  intrinsic_delay = 0e-6
  channel_shift = (FlightTime+intrinsic_delay)/sampletime
  start_sample = round(start_sample+channel_shift)
  up_sample = round(chop_ontime/(baseclock/1000.)/(sampletime/1e-6)); The chopper up time in samples
  ;mask_up =   [3,4,5]     ; This is now set for shot 107396 !!!!!!!!!!!!!!!!
  mask_up = [up_sample-3,up_sample-2]
  if ((shot ge 107397) and (shot le 107402)) then mask_up = [up_sample-4, up_sample-3,up_sample-2, up_sample-1]
;  mask_up = [up_sample-4,up_sample-3,up_sample-2]
  down_sample = round(chop_offtime/(baseclock/1000.)/(sampletime/1e-6)); The chopper up time in samples
  mask_down = up_sample + [down_sample-3,down_sample-2]
  if ((shot ge 107397) and (shot le 107402)) then mask_down = up_sample + [down_sample-4,down_sample-3,down_sample-2,down_sample-1]
  if (shot eq 108668) then begin
    mask_down = [3,4]
    mask_up = [8,9]
  endif
  if (shot eq 108680) then begin
    mask_down = [4,5]
    mask_up = [8,9]
  endif
  if (shot eq 108682) then begin
    mask_down = [3,4]
    mask_up = [8,9]
  endif
  if (shot ge 108687) and (shot le 108689) then begin
    mask_down = [2,3,4]
    mask_up = [7,8,9]
  endif
  if ((shot eq 108694) or (shot eq 108695) or (shot eq 108696) or (shot eq 108698)) then begin
    mask_down = [1,2]
    mask_up = [4,5]
  endif
  if ((shot ge 110068) and (shot le 110073)) then begin
    mask_down = [1,2]
    mask_up = [4,5]
  endif
  if (shot eq 110154) then begin
    mask_down = [2,3,4]
    mask_up = [7,8,9]
  endif
  if (shot eq 110157) then begin
    mask_down = [1,2]
    mask_up = [4,5]
  endif
  if (shot eq 110286) then begin
    mask_down = [1,2]
    mask_up = [4,5]
  endif
  if (shot eq 110558) then begin
    mask_down = [3,4,5]
    mask_up = [10,11, 12]
  endif

  if (shot ge 113913) and (shot le 113922) then begin
    start_sample = start_sample+4
    mask_down = [1,2]
    mask_up = [4,5]
  endif

endif   ; data source 25  (TEXTOR)

if (data_source eq 34) then begin  ; COMPASS
  ; This is completely manual, should be changed!!
  ; For shot 7743

  starttime = 0.94
  period_time = 4e-6
  sampletime = 5e-7
  period_n = 8
  period_cycle_n = long(1./period_time)-1
  start_sample = 0l
  mask_up = [0,1,2]
  mask_down = [4,5,6]
  U_up = 0
  U_down = 0
  U_switch1 = 300
  U_switch2 = 0

endif ; COMPASS

if (data_source eq 0) then begin     ; W7-AS Li-beam settings
if (shot eq 48126) then begin
  starttime = 0.2
  period_time = 10.E-6
  sampletime = 1.E-6
  period_sample_n = 10l
  start_sample = 3l
  mask_up = [1l,2l]
  mask_down = [5l,6l]
;     deflection = 3.   ; OLD!!!!!!!!
  U_up = -1300       ; TO BE CHECKED!!!!!!!!
  U_down =    0
  U_switch1 =    0
  U_switch2 =  500   ; TO BE CHECKED!!!!!!!!
endif

IF (shot EQ 48153) THEN BEGIN
  starttime = 0.2
  period_time = 10.E-6
  sampletime = 1.E-6
  period_sample_n = 10l
  start_sample = 3l
  mask_up = [1l]
  mask_down = [5l]
  U_up =  -800
  U_down =    0
  U_switch1 =    0
  U_switch2 =  500
ENDIF

IF ((shot GE 48174) AND (shot LE 48180)) THEN BEGIN
  starttime = 0.2
  period_time = 10.E-6
  sampletime = 1.E-6
  period_sample_n = 10l
  start_sample = 3l
  mask_up = [1l]
  mask_down = [5l]
  U_up =  -800
  U_down =    0
  U_switch1 =    0
  CASE shot OF
    48174 : U_switch2 =  500
    48175 : U_switch2 =  400
    48176 : U_switch2 =  400
    48177 : U_switch2 =  300
    48178 : U_switch2 =  200
    48179 : U_switch2 =    0
    48180 : U_switch2 =  100
  ENDCASE
ENDIF

IF ((shot GE 48181) AND (shot LE 48186)) THEN BEGIN     ; no beam
  starttime = 0.2
  period_time = 10.E-6
  sampletime = 1.E-6
  period_sample_n = 10l
  start_sample = 3l
  mask_up = [1l,2l]
  mask_down = [5l,6l]
  U_up =  -800
  U_down =    0
  U_switch1 =    0
  U_switch2 =  500
ENDIF

IF ((shot GE 48190) AND (shot LE 48207)) THEN BEGIN
  starttime = 0.2
  period_time = 10.E-6
  sampletime = 1.E-6
  period_sample_n = 10l
  start_sample = 3l
  mask_up = [1l,2l]
  mask_down = [5l,6l]
  U_down =    0
  U_switch1 =    0

  IF ((shot GE 48190) AND (shot LE 48192)) THEN BEGIN
    U_up = -800
    CASE shot OF
      48190 :   U_switch2 =  500
      48191 :   U_switch2 =  600
      48192 :   U_switch2 =  800
    ENDCASE
  ENDIF
  IF (shot EQ 48193) THEN BEGIN
    U_up =  -400
    U_switch2 =  800
  ENDIF
  IF ((shot GE 48194) AND (shot LE 48202)) THEN BEGIN
    U_up =  -600
    CASE shot OF
      48194 :   U_switch2 =  800
      48195 :   U_switch2 =  600   ; ?
      48196 :   U_switch2 =  450
      48197 :   U_switch2 =  200
      48198 :   U_switch2 =    0
      48199 :   U_switch2 =  400
      48200 :   U_switch2 =  600
      48201 :   U_switch2 =  800
      48202 :   U_switch2 = 1000
    ENDCASE
  ENDIF
  IF (shot EQ 48203) THEN BEGIN
    U_up =  -200
    U_switch2 =  800
  ENDIF
  IF (shot EQ 48204) THEN BEGIN
    U_up = -1000
    U_switch2 =  800
  ENDIF
  IF ((shot GE 48205) AND (shot LE 48207)) THEN BEGIN
    U_up = -600
    CASE shot OF
      48205 :   U_switch2 =  700
      48206 :   U_switch2 =  500
      48207 :   U_switch2 =  300
    ENDCASE
  ENDIF

ENDIF

IF ((shot EQ 50131) OR (shot EQ 50132)) OR            $
    ((shot GE 50134) AND (shot LE 50138)) THEN BEGIN
  IF ((shot EQ 50131) OR (shot EQ 50132)) THEN  starttime =  0.1
  IF (shot EQ 50134) THEN      starttime =  0.0
  IF ((shot GE 50135) AND (shot LE 50138)) THEN starttime = -0.1
  period_time = 10.E-6
  sampletime = 1.E-6
  period_sample_n = 10l
  start_sample = 3l
  mask_up = [6l,7l]
  mask_down = [1l,2l]
  U_up =    0
  U_down =    0
  IF ((shot GE 50131) AND (shot LE 50136)) THEN U_switch2 =  150
  IF ((shot EQ 50137) OR (shot EQ 50138)) THEN U_switch2 =  250
  U_switch1 = -U_switch2
ENDIF

IF ((shot GE 50167) AND (shot LE 50171)) THEN BEGIN
  starttime = 0.0
  period_time = 10.E-6
  sampletime = 1.E-6
  period_sample_n = 10l
  start_sample = 3l
  mask_up = [6l,7l]
  mask_down = [1l,2l]
  U_up =    0
  U_down =    0
  IF ((shot GE 50167) AND (shot LE 50168)) THEN U_switch2 =  350
  IF ((shot GE 50169) AND (shot LE 50171)) THEN U_switch2 =  300
  U_switch1 = -U_switch2
ENDIF

IF ((shot GE 50448) AND (shot LE 50470)) THEN BEGIN
  starttime = 0.4
  period_time = 10.E-6
  sampletime = 1.E-6
  period_sample_n = 10l
  start_sample = 3l
  mask_up = [6l,7l]
  mask_down = [1l,2l]
  U_up =    0
  U_down =    0
  U_switch1 =    0
  CASE shot OF
    50448 : U_switch2 =  200
    50449 : U_switch2 =  250
    50450 : U_switch2 =  250
    50451 : U_switch2 =  300
    50452 : U_switch2 =  350
    50453 : U_switch2 =  400
    50454 : U_switch2 =  450
    50455 : U_switch2 =  500
    50456 : U_switch2 =  550
  ENDCASE
  IF ((shot GE 50457) AND (shot LE 50470)) THEN U_switch2 =  300
ENDIF

IF ((shot GE 51168) AND (shot LE 51181)) THEN BEGIN
  starttime =0.3
  period_time = 10.E-6
  sampletime = 1.E-6
  period_sample_n = 10l
  start_sample = 3l
  mask_up = [6l,7l]
  mask_down =[1l,2l]
  U_up = 0
  U_down = 0
  U_switch1 = 0
  CASE shot OF
    51168 : U_switch2 =  300
    51169 : U_switch2 =  400
    51170 : U_switch2 =  200
    51171 : U_switch2 =  500
    51172 : U_switch2 =  150
    51173 : U_switch2 =   50
    51174 : U_switch2 =   50
    51175 : U_switch2 =   50
    51176 : U_switch2 =  100
    51177 : U_switch2 =  150
    51178 : U_switch2 =  150
    51179 : U_switch2 =  100
    51180 : U_switch2 =  250
    51181 : U_switch2 =  350
  ENDCASE
ENDIF

IF ((shot GE 51188) AND (shot LE 51190)) OR           $
    ((shot GE 51192) AND (shot LE 51194)) OR          $
    ((shot GE 51196) AND (shot LE 51200)) OR          $
    (shot EQ 51206) THEN BEGIN
  IF ((shot GE 51188) AND (shot LE 51190)) THEN starttime = 0.4
  IF ((shot GE 51191) AND (shot LE 51206)) THEN starttime = 0.2
  period_time = 10.E-6
  sampletime = 1.E-6
  period_sample_n = 10l
  start_sample = 6l
  mask_up = [1l,2l,3l,4l]
  mask_down = [6l,7l,8l,9l]
  U_up = 0
  U_down = 0
  U_switch1 = 0
  CASE shot OF
    51188 : U_switch2 =    0
    51189 : U_switch2 =    0
    51190 : U_switch2 =  200
    51192 : U_switch2 =  200
    51193 : U_switch2 =  200
    51194 : U_switch2 =  100
    51196 : U_switch2 =   10
    51197 : U_switch2 =  150
    51198 : U_switch2 =   50
    51199 : U_switch2 =  250
    51200 : U_switch2 =  250
    51206 : U_switch2 =  300
  ENDCASE
ENDIF

IF ((shot GE 51541) AND (shot LE 51542)) OR           $
    ((shot GE 51547) AND (shot LE 51553)) OR          $
    ((shot GE 51556) AND (shot LE 51565)) THEN BEGIN
  IF ((shot GE 51541) AND (shot LE 51542)) THEN starttime = 0.2
  IF ((shot GE 51547) AND (shot LE 51559)) THEN starttime = 0.4
  IF ((shot GE 51560) AND (shot LE 51565)) THEN starttime = 0.5
  period_time = 10.E-6
  sampletime = 1.E-6
  period_sample_n = 10l
  start_sample = 6l
  mask_up = [1l,2l,3l,4l]
  mask_down = [6l,7l,8l,9l]
  U_up = 0
  U_down = 0
  U_switch1 = 0
  CASE shot OF
    51541 : U_switch2 =  100
    51542 : U_switch2 =  200
    51547 : U_switch2 =  100
    51548 : U_switch2 =  200
    51549 : U_switch2 =  300
    51550 : U_switch2 =  110
    51551 : U_switch2 =  100
    51552 : U_switch2 =  200
    51553 : U_switch2 =  300
    51556 : U_switch2 =  100
    51557 : U_switch2 =  200
    51558 : U_switch2 =  300
    51559 : U_switch2 =  150
    51560 : U_switch2 =  100
    51561 : U_switch2 =  200
    51562 : U_switch2 =  200
    51563 : U_switch2 =  300
    51564 : U_switch2 =  300
    51565 : U_switch2 =  250
  ENDCASE
ENDIF

IF ((shot GE 51614) AND (shot LE 51617)) OR           $
    ((shot GE 51623) AND (shot LE 51626)) THEN BEGIN
  starttime = 0.4
  period_time = 10.E-6
  sampletime = 1.E-6
  period_sample_n = 10l
  start_sample = 6l
  mask_up = [1l,2l,3l,4l]
  mask_down = [6l,7l,8l,9l]
  U_up = 0
  U_down = 0
  U_switch1 = 0
  CASE shot OF
    51614 : U_switch2 =  100
    51615 : U_switch2 =  200
    51616 : U_switch2 =  300
    51617 : U_switch2 =  150
    51623 : U_switch2 =  100
    51624 : U_switch2 =  200
    51625 : U_switch2 =  200
    51626 : U_switch2 =  300
  ENDCASE
ENDIF

IF ((shot GE 52122) AND (shot LE 52179)) THEN BEGIN
  starttime = 0.4
  period_time = 4.E-6
  sampletime = 4.0E-7
  period_sample_n = 10l
  start_sample = 5l
  mask_up = [6l,7l,8l,9l]
  mask_down = [1l,2l,3l,4l]
  U_up = 0
  U_down = 0
  U_switch1 = 0
  CASE shot OF
    52122 : U_switch2 =  210
    52123 : U_switch2 =  210
    52124 : U_switch2 =  280
    52125 : U_switch2 =  140
    52126 : U_switch2 =   70
    52127 : U_switch2 =   20
    52128 : U_switch2 =  350
    52129 : U_switch2 =  350
    52130 : U_switch2 =  280
    52131 : U_switch2 =  210
    52132 : U_switch2 =  140
    52133 : U_switch2 =   70
    52134 : U_switch2 =   20
    52135 : U_switch2 =    0
    52136 : U_switch2 =   70
    52137 : U_switch2 =  140
    52138 : U_switch2 =  210
    52139 : U_switch2 =  280
    52140 : U_switch2 =  350
    52141 : U_switch2 =  350
    52142 : U_switch2 =  280
    52143 : U_switch2 =  210
    52144 : U_switch2 =  140
    52145 : U_switch2 =   70
    52146 : U_switch2 =   15
    52147 : U_switch2 =    0
    52148 : U_switch2 =   70
    52149 : U_switch2 =  140
    52150 : U_switch2 =  210
    52151 : U_switch2 =  280
    52152 : U_switch2 =  350
    52153 : U_switch2 =  350
    52154 : U_switch2 =  280
    52155 : U_switch2 =  210
    52156 : U_switch2 =  140
    52157 : U_switch2 =   70
    52158 : U_switch2 =   17
    52159 : U_switch2 =  200
    52160 : U_switch2 =  200
    52161 : U_switch2 =  200
    52162 : U_switch2 =  200
    52163 : U_switch2 =  200
    52164 : U_switch2 =  350
    52165 : U_switch2 =  280
    52166 : U_switch2 =  210
    52167 : U_switch2 =  136
    52168 : U_switch2 =   70
    52169 : U_switch2 =   25
    52170 : U_switch2 =    0
    52171 : U_switch2 =   70
    52172 : U_switch2 =  140
    52173 : U_switch2 =  210
    52174 : U_switch2 =  210
    52175 : U_switch2 =  280
    52176 : U_switch2 =  280
    52177 : U_switch2 =  280
    52178 : U_switch2 =  280
    52179 : U_switch2 =  280
  ENDCASE
ENDIF
IF ((shot GE 55663) AND (shot LE 57000)) THEN BEGIN
  starttime = 0.2
  period_time = 4.0E-6
  sampletime = 1.0E-6
  period_sample_n = 4l
  start_sample = 5l
  mask_up = [1l]
  mask_down = [3l]
  U_up = 0
  U_down = 0
  U_switch1 = 0
  CASE shot OF
    55663:  U_switch2 =  200
    55710:      U_switch2 =  0
    55711:      U_switch2 =  70
    55713:      U_switch2 =  140
    55714:      U_switch2 =  210
    55715:      U_switch2 =  280
    55716:      U_switch2 =  350
    55746:      U_switch2 =  300
    55747:      U_switch2 =  350
    55748:      U_switch2 =  210
    55749:      U_switch2 =  140
    55750:      U_switch2 =  70
    55751:      U_switch2 =  0
    57000:      U_switch2 =  200
  ENDCASE
ENDIF

if ((shot ge 200) and (shot le 300)) then begin
  starttime = 0.2
  period_time = 4.0E-6
  sampletime = 1.0E-6
  period_sample_n = 4l
  start_sample = 2l
  mask_up = [0l,1l]
  mask_down = [2l,3l]
  U_up = 0
  U_down = 0
  U_switch1 = 0
  U_switch2 =  210
endif


if (shot ge 80000) then begin
  starttime = 0.
  restore,file='data/'+i2str(shot,digits=5)+'.simpara'
  sampletime = sampletime             ; ???????
  period_sample_n = 10l
  period_time = period_sample_n*sampletime
  start_sample=0l
  mask_down=[1l,2l,3l,4l]
  mask_up=[6l,7l,8l,9l]
  U_up = 0
  U_down = 0
  U_switch1 = 0
  U_switch2 =  200
endif

param=[STARTTIME,period_time,SAMPLETIME,PERIOD_SAMPLE_N,START_SAMPLE,MASK_DOWN,MASK_UP,U_UP,U_DOWN,U_switch1,U_switch2]  ;must be the last line

endif ;   W7-AS Li-beam

end















