pro kbpars,mastbeam=mastbeam,str=str
default,mastbeam,'k1'
if mastbeam eq 'k1' then begin
 centre=[ 13.4034699, -1.4873512,0.0000]*100.;cm
 chat=[-1,0,      0.00000]
endif 

if(mastbeam eq 'k2')then begin 
centre=[ 13.375, -0.787,0.0000]*100;cm
chat=[-cos(4*!dtor),-sin(4*!dtor),      0.00000]	; Unit vector
endif

if mastbeam eq 'k1' then       btangent = 148.6
if mastbeam eq 'k2' then       btangent = 171.848

ductpoint=[3399,-1485,0.] / 10 ; point through which both beams cross {mm->cm)


if mastbeam eq 'k1' then begin
    rotangle=-90*!dtor ; nb this angle is the angle wrt the 'N" not the 'E' axis
    point =[-148.7,-1340.34699,0] ; coordinates in rotated reference frame
endif

if mastbeam eq 'k2' then begin
    rotangle=-94*!dtor
    point=[-171.808,-1328.75,0]
endif

distduct=1000.
vert_foc=1000.
horiz_foc=1000.
div=0.9*!dtor  ;* 0.1
; 0.35*sqrt(2)*sqrt(2)*!dtor ; divergence angle ;;!!!new clive corrected

holp=transpose($
[[   -0.0825000,   0.0135000],$
[   -0.0660000,   0.0135000],$
[   -0.0495000,   0.0135000],$
[   -0.0330000,   0.0135000],$
[   -0.0165000,   0.0135000],$
[      0.00000,   0.0135000],$
[    0.0165000,   0.0135000],$
[    0.0330000,   0.0135000],$
[    0.0495000,   0.0135000],$
[    0.0660000,   0.0135000],$
[    0.0825000,   0.0135000],$
[   -0.0825000,   0.0475000],$
[   -0.0660000,   0.0475000],$
[   -0.0495000,   0.0475000],$
[   -0.0330000,   0.0475000],$
[   -0.0165000,   0.0475000],$
[      0.00000,   0.0475000],$
[    0.0165000,   0.0475000],$
[    0.0330000,   0.0475000],$
[    0.0495000,   0.0475000],$
[    0.0660000,   0.0475000],$
[    0.0825000,   0.0475000],$
[   -0.0825000,   0.0815000],$
[   -0.0660000,   0.0815000],$
[   -0.0495000,   0.0815000],$
[   -0.0330000,   0.0815000],$
[   -0.0165000,   0.0815000],$
[      0.00000,   0.0815000],$
[    0.0165000,   0.0815000],$
[    0.0330000,   0.0815000],$
[    0.0495000,   0.0815000],$
[    0.0660000,   0.0815000],$
[    0.0825000,   0.0815000],$
[   -0.0825000,    0.115500],$
[   -0.0660000,    0.115500],$
[   -0.0495000,    0.115500],$
[   -0.0330000,    0.115500],$
[   -0.0165000,    0.115500],$
[      0.00000,    0.115500],$
[    0.0165000,    0.115500],$
[    0.0330000,    0.115500],$
[    0.0495000,    0.115500],$
[    0.0660000,    0.115500],$
[    0.0825000,    0.115500],$
[   -0.0825000,    0.149500],$
[   -0.0660000,    0.149500],$
[   -0.0495000,    0.149500],$
[   -0.0330000,    0.149500],$
[   -0.0165000,    0.149500],$
[      0.00000,    0.149500],$
[    0.0165000,    0.149500],$
[    0.0330000,    0.149500],$
[    0.0495000,    0.149500],$
[    0.0660000,    0.149500],$
[    0.0825000,    0.149500],$
[   -0.0825000,    0.183500],$
[   -0.0660000,    0.183500],$
[   -0.0495000,    0.183500],$
[   -0.0330000,    0.183500],$
[   -0.0165000,    0.183500],$
[      0.00000,    0.183500],$
[    0.0165000,    0.183500],$
[    0.0330000,    0.183500],$
[    0.0495000,    0.183500],$
[    0.0660000,    0.183500],$
[    0.0825000,    0.183500],$
[   -0.0330000,    0.217500],$
[   -0.0165000,    0.217500],$
[      0.00000,    0.217500],$
[    0.0165000,    0.217500],$
[    0.0330000,    0.217500],$
[   -0.0742500,   0.0305000],$
[   -0.0577500,   0.0305000],$
[   -0.0412500,   0.0305000],$
[   -0.0247500,   0.0305000],$
[  -0.00825000,   0.0305000],$
[   0.00825000,   0.0305000],$
[    0.0247500,   0.0305000],$
[    0.0412500,   0.0305000],$
[    0.0577500,   0.0305000],$
[    0.0742500,   0.0305000],$
[   -0.0742500,   0.0645000],$
[   -0.0577500,   0.0645000],$
[   -0.0412500,   0.0645000],$
[   -0.0247500,   0.0645000],$
[  -0.00825000,   0.0645000],$
[   0.00825000,   0.0645000],$
[    0.0247500,   0.0645000],$
[    0.0412500,   0.0645000],$
[    0.0577500,   0.0645000],$
[    0.0742500,   0.0645000],$
[   -0.0742500,   0.0985000],$
[   -0.0577500,   0.0985000],$
[   -0.0412500,   0.0985000],$
[   -0.0247500,   0.0985000],$
[  -0.00825000,   0.0985000],$
[   0.00825000,   0.0985000],$
[    0.0247500,   0.0985000],$
[    0.0412500,   0.0985000],$
[    0.0577500,   0.0985000],$
[    0.0742500,   0.0985000],$
[   -0.0742500,    0.132500],$
[   -0.0577500,    0.132500],$
[   -0.0412500,    0.132500],$
[   -0.0247500,    0.132500],$
[  -0.00825000,    0.132500],$
[   0.00825000,    0.132500],$
[    0.0247500,    0.132500],$
[    0.0412500,    0.132500],$
[    0.0577500,    0.132500],$
[    0.0742500,    0.132500],$
[   -0.0742500,    0.166500],$
[   -0.0577500,    0.166500],$
[   -0.0412500,    0.166500],$
[   -0.0247500,    0.166500],$
[  -0.00825000,    0.166500],$
[   0.00825000,    0.166500],$
[    0.0247500,    0.166500],$
[    0.0412500,    0.166500],$
[    0.0577500,    0.166500],$
[    0.0742500,    0.166500],$
[   -0.0742500,    0.200500],$
[   -0.0577500,    0.200500],$
[   -0.0412500,    0.200500],$
[   -0.0247500,    0.200500],$
[  -0.00825000,    0.200500],$
[   0.00825000,    0.200500],$
[    0.0247500,    0.200500],$
[    0.0412500,    0.200500],$
[    0.0577500,    0.200500],$
[    0.0742500,    0.200500],$
[   -0.0825000,  -0.0135000],$
[   -0.0660000,  -0.0135000],$
[   -0.0495000,  -0.0135000],$
[   -0.0330000,  -0.0135000],$
[   -0.0165000,  -0.0135000],$
[      0.00000,  -0.0135000],$
[    0.0165000,  -0.0135000],$
[    0.0330000,  -0.0135000],$
[    0.0495000,  -0.0135000],$
[    0.0660000,  -0.0135000],$
[    0.0825000,  -0.0135000],$
[   -0.0825000,  -0.0475000],$
[   -0.0660000,  -0.0475000],$
[   -0.0495000,  -0.0475000],$
[   -0.0330000,  -0.0475000],$
[   -0.0165000,  -0.0475000],$
[      0.00000,  -0.0475000],$
[    0.0165000,  -0.0475000],$
[    0.0330000,  -0.0475000],$
[    0.0495000,  -0.0475000],$
[    0.0660000,  -0.0475000],$
[    0.0825000,  -0.0475000],$
[   -0.0825000,  -0.0815000],$
[   -0.0660000,  -0.0815000],$
[   -0.0495000,  -0.0815000],$
[   -0.0330000,  -0.0815000],$
[   -0.0165000,  -0.0815000],$
[      0.00000,  -0.0815000],$
[    0.0165000,  -0.0815000],$
[    0.0330000,  -0.0815000],$
[    0.0495000,  -0.0815000],$
[    0.0660000,  -0.0815000],$
[    0.0825000,  -0.0815000],$
[   -0.0825000,   -0.115500],$
[   -0.0660000,   -0.115500],$
[   -0.0495000,   -0.115500],$
[   -0.0330000,   -0.115500],$
[   -0.0165000,   -0.115500],$
[      0.00000,   -0.115500],$
[    0.0165000,   -0.115500],$
[    0.0330000,   -0.115500],$
[    0.0495000,   -0.115500],$
[    0.0660000,   -0.115500],$
[    0.0825000,   -0.115500],$
[   -0.0825000,   -0.149500],$
[   -0.0660000,   -0.149500],$
[   -0.0495000,   -0.149500],$
[   -0.0330000,   -0.149500],$
[   -0.0165000,   -0.149500],$
[      0.00000,   -0.149500],$
[    0.0165000,   -0.149500],$
[    0.0330000,   -0.149500],$
[    0.0495000,   -0.149500],$
[    0.0660000,   -0.149500],$
[    0.0825000,   -0.149500],$
[   -0.0825000,   -0.183500],$
[   -0.0660000,   -0.183500],$
[   -0.0495000,   -0.183500],$
[   -0.0330000,   -0.183500],$
[   -0.0165000,   -0.183500],$
[      0.00000,   -0.183500],$
[    0.0165000,   -0.183500],$
[    0.0330000,   -0.183500],$
[    0.0495000,   -0.183500],$
[    0.0660000,   -0.183500],$
[    0.0825000,   -0.183500],$
[   -0.0330000,   -0.217500],$
[   -0.0165000,   -0.217500],$
[      0.00000,   -0.217500],$
[    0.0165000,   -0.217500],$
[    0.0330000,   -0.217500],$
[   -0.0742500,  -0.0305000],$
[   -0.0577500,  -0.0305000],$
[   -0.0412500,  -0.0305000],$
[   -0.0247500,  -0.0305000],$
[  -0.00825000,  -0.0305000],$
[   0.00825000,  -0.0305000],$
[    0.0247500,  -0.0305000],$
[    0.0412500,  -0.0305000],$
[    0.0577500,  -0.0305000],$
[    0.0742500,  -0.0305000],$
[   -0.0742500,  -0.0645000],$
[   -0.0577500,  -0.0645000],$
[   -0.0412500,  -0.0645000],$
[   -0.0247500,  -0.0645000],$
[  -0.00825000,  -0.0645000],$
[   0.00825000,  -0.0645000],$
[    0.0247500,  -0.0645000],$
[    0.0412500,  -0.0645000],$
[    0.0577500,  -0.0645000],$
[    0.0742500,  -0.0645000],$
[   -0.0742500,  -0.0985000],$
[   -0.0577500,  -0.0985000],$
[   -0.0412500,  -0.0985000],$
[   -0.0247500,  -0.0985000],$
[  -0.00825000,  -0.0985000],$
[   0.00825000,  -0.0985000],$
[    0.0247500,  -0.0985000],$
[    0.0412500,  -0.0985000],$
[    0.0577500,  -0.0985000],$
[    0.0742500,  -0.0985000],$
[   -0.0742500,   -0.132500],$
[   -0.0577500,   -0.132500],$
[   -0.0412500,   -0.132500],$
[   -0.0247500,   -0.132500],$
[  -0.00825000,   -0.132500],$
[   0.00825000,   -0.132500],$
[    0.0247500,   -0.132500],$
[    0.0412500,   -0.132500],$
[    0.0577500,   -0.132500],$
[    0.0742500,   -0.132500],$
[   -0.0742500,   -0.166500],$
[   -0.0577500,   -0.166500],$
[   -0.0412500,   -0.166500],$
[   -0.0247500,   -0.166500],$
[  -0.00825000,   -0.166500],$
[   0.00825000,   -0.166500],$
[    0.0247500,   -0.166500],$
[    0.0412500,   -0.166500],$
[    0.0577500,   -0.166500],$
[    0.0742500,   -0.166500],$
[   -0.0742500,   -0.200500],$
[   -0.0577500,   -0.200500],$
[   -0.0412500,   -0.200500],$
[   -0.0247500,   -0.200500],$
[  -0.00825000,   -0.200500],$
[   0.00825000,   -0.200500],$
[    0.0247500,   -0.200500],$
[    0.0412500,   -0.200500],$
[    0.0577500,   -0.200500],$
[    0.0742500,   -0.200500]]) ; this is the coordinates of the beamlet source with respect to the beam coordinate system (z coordinate is implicitly zero)


holp(*,0)*=-0.12994/holp(0,0)
holp(*,1)*= 0.01955/holp(0,1)


str={centre:centre,chat:chat,btangent:btangent,rotangle:rotangle,centrerot:point,holp:holp*100,div:div,ductpoint:ductpoint,distduct:distduct,horiz_foc:horiz_foc,vert_foc:vert_foc} ; keep them all in cm
end

