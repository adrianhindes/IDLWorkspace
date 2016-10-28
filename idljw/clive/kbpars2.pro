pro kbpars2,isource=isource,us=us,vs=vs,alpha=alpha

; in drawing with beam coming at oblique angle down and to right

us_NB        = -4.5*[1,1] ;[53.9,-139.85]		; abscissa coordinate of beam aperture (cm)
vs_NB        = 370.8*[1,1] ;[-192.6,-142.98]		; vertical coordinate of beam aperture (cm)
alpha_NB     = [(-90+24.3)*!dtor,(-90+24.3+4)*!dtor] ;-180*!dtor		; angle of injected beam relative to u axis (radians)

;   us_NB        = 339.9*[1,1];[53.9,-139.85]		; abscissa coordinate of
   us=us_NB[isource]
   vs=vs_NB[isource]
   alpha=alpha_NB[isource]

end
