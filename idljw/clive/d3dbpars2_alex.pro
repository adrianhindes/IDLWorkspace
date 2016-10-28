pro d3dbpars2,isource=isource,us=us,vs=vs,alpha=alpha
; [30L,30R]

us_NB=[52.1*2.54,52.1*2.54] ; abscissa coordinate of beam aperture (cm)
vs_NB=[94*2.54,94*2.54] ; vertical coordinate of beam aperture (cm)
alpha_NB=[-atan((223.4-94.0)/(229.1-52.1)),-atan((207.5-94.0)/(248.6-52.1))] ; angle of injected beam relative to u axis (radians)

   us=us_NB[isource]
   vs=vs_NB[isource]
   alpha=alpha_NB[isource]

end
