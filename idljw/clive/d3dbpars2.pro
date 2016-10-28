pro d3dbpars2,isource=isource,us=us,vs=vs,alpha=alpha
; [30L,30R,150L,150R,210L,210R,330L,330R], e.g., [0,0,0,0,0,0,1,0] for 330L

; in drawing with beam coming at oblique angle down and to right

;us_NB        = -4.5*[1,1] ;[53.9,-139.85]		; abscissa coordinate of beam aperture (cm)
;vs_NB        = 370.8*[1,1] ;[-192.6,-142.98]		; vertical coordinate of beam aperture (cm)
;alpha_NB     = [(-90+24.3)*!dtor,(-90+24.3+4)*!dtor] ;-180*!dtor		; angle of injected beam relative to u axis (radians)

;   us_NB        = 339.9*[1,1];[53.9,-139.85]		; abscissa coordinate of
us_NB=[140.7,140.7,140.7,140.7,-140.7,-140.7,-140.7,-140.7]
vs_NB=[234.1,234.1,-234.1,-234.1,-234.1,-234.1,234.1,234.1]
lrad=!pi*6.18/180. & rrad=!pi*14.84/180.
alpha_NB=[lrad-5*!pi/6-.04,rrad-5*!pi/6-.04,!pi/2+lrad,!pi/2+rrad, $
         !pi/2-rrad,!pi/2-lrad,lrad-!pi/2,rrad-!pi/2]


   us=us_NB[isource]
   vs=vs_NB[isource]
   alpha=alpha_NB[isource]

end
