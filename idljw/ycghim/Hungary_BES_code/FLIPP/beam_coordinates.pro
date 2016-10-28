pro beam_coordinates,shot,RR,ZZ,beam,data_source=data_source,U_deflection=u_defl
; ************************************************************
; beam_coordinates.pro                S. Zoletnik
; data_source 8 added in March 2001 by M. Bruchhausen
; U_deflection  added 28.03.2001    by G. Petravich
; data_source 10 added in May 2001 by M. Bruchhausen
;
; Loads the coordinates of the Li-beam
; Based on the original program from H. Ehmler 19.01.2001
; For data_source 0,1,2 returns all Li-beam coordinates
; For data_source 3 and 5 returns beam coordinates only
;
; INPUT
;  shot: 	shot number
;  data_source:	0: Nicolet, 1: Aurora, 2: Li-standard, 3: AUG Li-standard,
;		7: TEXTOR Li-beam, 8: TEXTOR LBO 10:W7-AS LBO
;  U_defl:	total deflection voltage (+ ==> upward deflection) [V]
; OUTPUT:
;	(crossing points of the beam and the observation sight of lines)
;  RR: 		R (major radius) coordinates of measuring points
;  ZZ:		Elevation of measuring points
;
;  beam:	Z coordinates along the  beam
; ************************************************************

default,data_source,0


r_name = 'beam_coordinates'
r = routine_info(r_name,/source)
routine_path = r.path
routine_path = strmid(routine_path,0,rstrpos(routine_path,r_name))

if (data_source lt 3) then begin
  default,U_defl,0						; [V]
  DEFAULT,n_ch,28

  case 1 of
    shot le 46588: begin
          openr,l,routine_path+'channels_old.dat',/get_lun
;  	print,'using channels_old.dat for mapping'
  	end
    shot ge 46588 and shot le 48432: begin
  	openr,l,routine_path+'channels.dat',/get_lun
;  	print,'using channels.dat for mapping'
  	end
    else:begin
          openr,l,routine_path+'channels_new.dat',/get_lun
;  	print,'using channels_new.dat for mapping'
  	end
  endcase

  Ri0 = fltarr(n_ch+1) & Zi0 = fltarr(n_ch+1) & beam0 = fltarr(n_ch+1)
  aa=0. & bb=0. & cc=0. & dd=0.
  for i=1,n_ch do begin
    readf,l,aa,bb,cc,dd
    Zi0(i) = bb & Ri0(i) = cc & beam0(i) = dd
  endfor
  free_lun,l

  if (u_defl ne 0) then begin
    DEFAULT,R_opt,223.0 & DEFAULT,Z_opt,-78.0			; [cm]
    fi0 = ATAN((Zi0(n_ch)-Zi0(1))/(Ri0(n_ch)-Ri0(1)))		; [radian]
    DEFAULT,R_defl,427.0					; [cm]
    Z_defl = Zi0(1)+(R_defl-Ri0(1))*TAN(fi0)			; [cm]
    DEFAULT,defl_const,-1.164E-3				; [degree/Volt]
    dfi = defl_const*U_defl/180.*!pi				; [radian]
    tang_fi = TAN(fi0+dfi)
    d0 = SQRT((R_defl-Ri0(1))^2+(Z_defl-Zi0(1))^2)-beam0(1)
    Ri = Ri0 & Zi = Zi0 & beam = beam0
    FOR i=1,n_ch DO BEGIN
      Ri(i) = (-Zi0(i)*R_opt+Z_opt*Ri0(i)+(tang_fi*R_defl-Z_defl)*(Ri0(i)-R_opt))/	$
  		(tang_fi*(ri0(i)-R_opt)-(Zi0(i)-Z_opt))
      Zi(i) = Z_defl+tang_fi*(Ri(i)-R_defl)
      beam(i) = SQRT((Ri(i)-R_defl)^2+(Zi(i)-Z_defl)^2)-d0
    ENDFOR
    RR = Ri(1:*)
    ZZ = Zi(1:*)
    beam = beam(1:*)
  endif else begin
    RR = Ri0(1:*)
    ZZ = Zi0(1:*)
    beam = beam0(1:*)
  endelse
  return
endif

if ((data_source eq 3) or (data_source eq 5)) then begin
; AUG Li-beam coordinates
  xrr=[  0.00000,   0.54036,   1.03644,   1.52951,   2.01050,   2.57702,	$
	 3.02481,   3.49272,   4.01094,   4.49898,   4.96186,   5.42473,	$
	 5.86245,   6.33741,   6.81941,   7.24304,   7.70189,   8.16075,	$
	 8.59444,   9.04726,   9.47391,   9.87943,  10.3242,   10.7680,		$
	11.1584,   11.6313,   12.0026,   12.4283,   12.8368,   13.2434,		$
	13.6760,   14.0926,   14.4911,   14.9037,   15.3293]
endif

IF (data_source eq 8) THEN BEGIN
  calfile='~/fluc/radcal/radcal.textor'
  openr,cal,calfile,/get_lun
  dummyshot=0L
  setup=''
  WHILE ((NOT eof(cal)) AND NOT (dummyshot EQ shot)) DO BEGIN
    readf,cal,dummyshot,setup
  ENDWHILE
  close,cal
  free_lun,cal
  CASE strcompress(setup,/remove_all) OF
   'a_050600': BEGIN
                  beam=[458,462,467,471,476,480]
              END
   'oa_100800': BEGIN
                  beam=[477.7,475.1,472.6,470.0,467.4,464.9]
                END
   'na_100800': BEGIN
                  beam=[480.3,476.8,474.4,470.0,466.6,463.2]
                END
   'oi_100800': BEGIN
                  beam=[460.0,457.4,454.9,452.3,449.7,447.2]
                END
   'ni_100800': BEGIN
                  beam=[460.0,456.6,453.2,449.7,446.3,442.9]
                END
          ELSE: BEGIN
                  print,'No radial calibration data  found for shot',shot
                  beam=0.
                END
  ENDCASE
  beam=beam/10.
ENDIF

IF data_source EQ 10 THEN BEGIN
  channels=readusechannel(shot)
  channels=channels[sort(channels)]
  beam=fltarr(n_elements(channels))
  FOR i=0,n_elements(channels)-1 DO BEGIN
    beam[i]=readspacal(channel=channels[i],device='pm')
  ENDFOR
  beam=beam/10.
  zz=fltarr(n_elements(channels))
  rr=233.-beam
ENDIF

if ((data_source eq 14) or (data_source eq 15)) then begin
  beam = defchannels(shot,data_source=data_source)
  RR = 0
  ZZ = 0
endif

if data_source EQ 25 then begin
 load_config_parameter,shot,'Optics','ChannelNumber',data_source=data_source,errormess=errormess,output_struct=s,/silent
  if (errormess ne '') then return
  chn = fix(s.value)
  beam=fltarr(chn)
  for i=1,chn do begin
    load_config_parameter,shot,'Optics','BES-'+i2str(i)+'_BeamCoordinate',data_source=data_source,errormess=errormess,output_struct=s,/silent
    if (errormess ne '') then return
    beam[i-1] = float(s.value)
  endfor

  ; This needs to be set properly!!!!
  rr = 300-beam
endif

if (data_source eq 28) then begin ;  signal cache
  signal_cache_get,name='beam_coordinates',time=t,data=beam,errormess=e
  if (e ne '') then begin
    beam = findgen(100)
  endif
endif

end
