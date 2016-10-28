pro band_eraser,Yrange,bande_bound,band_overplot_shift=band_overplot_shift
;----------------------------------------------------------------------------
;- 12/09/2009 - Updated POLYFILL to DRAW_ROI, to have it on PS device output.
;
;--------
;
;- plot a polyfill rectangle over a series of band
;- specifying Y bounds, the bands as an array
;- optionally the percentual shift from plot bound in band_overplot_shift
;- default is band_overplot_shift=0.05 or 5% of total Y range
;
;ToDO: Object graphic/DRAW_ROI!
;----------------------------------------------------------------------------

Y_min=Yrange(0)
Y_max=Yrange(1)

numero_bands=N_ELEMENTS(bande_bound)

index_boundary=[1,2,2,1]

Y_Delta=Y_max-Y_min

IF KEYWORD_SET(band_overplot_shift) THEN band_overplot_shift=band_overplot_shift else band_overplot_shift=0.05 

Y_min=Y_min+band_overplot_shift*Y_Delta
Y_max=Y_max-band_overplot_shift*Y_Delta

if numero_bands gt 0 then for i=0,numero_bands-1-1 do  POLYFILL,[ bande_bound (index_boundary+2*i)] ,[Y_min,Y_min,Y_max,Y_max],COLOR = 255
;-- POLYFILL works only on WIN or X device. PD and Object graphic need DRAW_ROI.

;if numero_bands gt 0 then for i=0,numero_bands-1-1 do DRAW_ROI, OBJ_NEW('IDLanROI',[ bande_bound (index_boundary+2*i)] ,[Y_min,Y_min,Y_max,Y_max],TYPE=2) ,color=255

end