PRO DEFL_beam_coordinates,shot_in,U_defl,RR,ZZ,beam
; ************************************************************
; beam_coordinates.pro                S. Zoletnik
; Loads the coordinates of the Li-beam
; Based on the original program from H. Ehmler 19.01.2001
; For data_source 0,1,2 returns all Li-beam coordinates
; For data_source 3 and 5 returns beam coordinates only
; data_source 8 is the TEXTOR LBO system.
; added in march 2001 by m. bruchhausen
; INPUT
;  shot_in: 	shot number
;  U_defl:	total deflection voltage (+ ==> upward deflection) [V] 
; OUTPUT:
;	(coordinates of crossing points of the beam and the observation sights of lines)
;  RR: 		R (major radius) coordinates of measuring points [cm]
;  ZZ:		Elevation (midplane = 0) of measuring points [cm]
;
;  beam:	Z coordinates along the beam [cm]
; ************************************************************
     
default,data_source,0
if (keyword_set(shot_in)) then shot=shot_in else shot=50451

DEFAULT,defl_const,-1.164E-3					; [degree/Volt]
fi0 = 156.8 & dfi = defl_const*U_defl				; [degree]
tang_fi = TAN((fi0+dfi)/180.*!pi)
R_defl = 427.0 & Z_defl = -100.3				; [cm]

R_opt = 223.0 & Z_opt = -78.0					; [cm]
DEFAULT,n_ch,28
Ri0 = fltarr(n_ch+1) & Zi0 = fltarr(n_ch+1) & beam0 = fltarr(n_ch+1)

data_dir = '../nicolet/'
if (data_source lt 3) then begin

  aa=0. & bb=0. & cc=0. & dd=0.
  case 1 of
    shot le 46588:	begin
			  openr,l,data_dir+'channels_old.dat',/get_lun
			  print,'using channels_old.dat for mapping'
			end
    shot ge 46588 and shot le 48432: begin
			  openr,l,data_dir+'channels.dat',/get_lun
			  print,'using channels.dat for mapping'
			end
    else:		begin
			  openr,l,data_dir+'channels_new.dat',/get_lun
			  print,'using channels_new.dat for mapping'
			end 
  endcase
  
  for i=1,n_ch do begin
    readf,l,aa,bb,cc,dd
    Zi0(i) = bb & Ri0(i) = cc & beam0(i) = dd
  endfor
  free_lun,l

endif

d0 = SQRT((R_defl-Ri0(1))^2+(Z_defl-Zi0(1))^2)-beam0(1)

Ri = Ri0 & Zi = Zi0 & beam = beam0
FOR i=1,n_ch DO BEGIN
  Ri(i) = (-Zi0(i)*R_opt+Z_opt*Ri0(i)+(tang_fi*R_defl-Z_defl)*(Ri0(i)-R_opt))/		$
		(tang_fi*(ri0(i)-R_opt)-(Zi0(i)-Z_opt))
  Zi(i) = Z_defl+tang_fi*(Ri(i)-R_defl)
  beam(i) = SQRT((Ri(i)-R_defl)^2+(Zi(i)-Z_defl)^2)-d0
  PRINT,beam0(i),'      --->',beam(i)
ENDFOR

PLOT,Ri0(1:*),Zi0(1:*),YRANGE=[-14,0],PSYM=1 & OPLOT,Ri(1:*),Zi(1:*),PSYM=2

STOP

RETURN
END
