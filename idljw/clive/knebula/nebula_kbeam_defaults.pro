Pro nebula_kbeam_defaults,pslice=pslice ,mastbeam=mastbeam ,shot=shot	  ,ntime=ntime       ,$
                         centre=centre ,chat=chat         ,narray=narray  ,noplasma=noplasma ,$
		         btravel=btravel                  ,visualbeam=visualbeam             ,$
		         div_beam_att=div_beam_att        ,entrance=entrance,rotangle=rotangle 
;----------------------------------------------------------------------------------
; Purpose : Set up the defaults to use in NEBULA beam code
; Author  : Stuart Henderson
; Date    : May 2011
; Contact : stuart.henderson@ccfe.ac.uk
;----------------------------------------------------------------------------------
nebula_default,shot,'24914'    ; nebula_default MAST shot number
nebula_default,noplasma,0	; Swtich to turn off plasma	  
nebula_default,mastbeam,'k1'   ; Choose which beam to use
print,string(mastbeam,format='("**** Using ",A2," Beam ****")') 
nebula_default,ntime,10   	; Number of time slices
nebula_default,pslice,21       ; Number of density points
nebula_default,narray,30       ; Number of points to integrate along
if(mastbeam eq 'ss')then begin 
 nebula_default,centre,[0.0961739,-7.16065,0]  ; Centre point of South Beam
 nebula_default,chat,[0.0843735,0.996434,0]	; Unit vector of centre point
endif 
if(mastbeam eq 'k1')then begin 
; nebula_default,centre,[13.4400  ,   -1.06145 ,     0.00000]  ;
; Centre point 
; nebula_default,centre,[ -1.4873512,-13.4034699, 0.0000]
 nebula_default,centre,[ 13.4034699, -1.4873512,0.0000]
 nebula_default,chat,[-1,0,      0.00000]	; Unit vector
endif 

if(mastbeam eq 'k2')then begin 
; nebula_default,centre,[13.4400  ,   -1.06145 ,     0.00000]  ;
; Centre point 
; nebula_default,centre,[ -1.4873512,-13.4034699, 0.0000]
 nebula_default,centre,[ 13.375, -0.787,0.0000]
 nebula_default,chat,[-cos(4*!dtor),-sin(4*!dtor),      0.00000]	; Unit vector
endif 


if(mastbeam eq 'sw')then begin 
 nebula_default,centre,[-6.15322,-3.66361,0]	; Centre point of South West Beam
 nebula_default,chat,[0.905124,0.425148,0]	; Unit vector of centre point
endif
nebula_default,visualbeam,0	; Plot plan view of beam entering plasma

if(mastbeam eq 'ss')then angle=4.84*!dtor 
if(mastbeam eq 'sw')then angle=64.84*!dtor ; Rotation angles for South and Southwest beams
if(mastbeam eq 'k1')then angle= (-90)*!dtor; -178.186*!dtor -90*!dtor +360*!dtor; angle relative to North

if(mastbeam eq 'k2')then angle= (-94)*!dtor; -178.186*!dtor -90*!dtor +360*!dtor; angle relative to North


;btd=[-1.,1]*300;337.5] ; In cm beam coordinates. I.e this will take it y=0 - tangent point
btd=[-250.,200]
nebula_default,btravel,btd 	; Distance travelled by beam to entrance port and finishing 'port'
nebula_default,div_beam_att,1.2; Attenuation factor for divergent beamlets;clive?
nebula_default,entrance,[0.4,0.4] ;Horizontal and vertical width of entrance port;clive-need to change?
nebula_default,rotangle,angle ;Rotation angle used to convert to machine coordinates
End
