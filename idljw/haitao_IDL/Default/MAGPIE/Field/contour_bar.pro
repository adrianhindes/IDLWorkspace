function contour_bar, phi, x, y, rgb=rgb, $
                      n_level=n_level, $
                      xrange=xrange, yrange=yrange, xtitle=xtitle, ytitle=ytitle, $
                      aspect_ratio=aspect_ratio, tickformat=tickformat, tickinterval=tickinterval, $
                      title=title, ctitle=ctitle,_extra=_extra, overplot=overplot

default, aspect_ratio, 0
default, n_level, 20
default, rgb, 4
default, title, ''
default, ytitle, 'Radius (m)'
default, xtitle, 'Axial coordinate (m)'
sz=size(phi)
if n_elements(x) eq 0 then x=findgen(sz[1])
if n_elements(y) eq 0 then y=findgen(sz[2])

cntr = contour( phi, x, y, n_levels = n_level, $
                axis_style=2, $
                aspect_ratio=aspect_ratio,$
                xrange=xrange, yrange=yrange, $
                xtitle=xtitle, ytitle=ytitle, $
                position=[.15,.12,.82,.88], $
                rgb_table = rgb, $
                title=title,font_size=16,_extra=_extra)
                
;cntr.xtitle = 'View angle to beam (degrees)'
;cntr.ytitle = 'Elevation angle (degrees)' 
;cntr.title = title

cbar = COLORBAR(target=cntr, ORIENTATION=1,  title=ctitle, $
    tickinterval=tickinterval, tickformat=tickformat)
cbar.position=[0.96,.13,.99,.88]
cbar.TEXTPOS = 0
cbar.TICKDIR = 0
cbar.BORDER_ON = 1
cbar.FONT_SIZE = 14
cbar.taper = 0

if keyword_Set(overplot) then begin
n_lev_over=20
cntr = contour( phi, x, y, n_levels = n_lev_over, $
                axis_style=2, fill=0,$
                xrange=xrange, yrange=yrange, $
                aspect_ratio=aspect_ratio,$
                position=[.12,.1,.82,.9],$
                color='black',/overplot,_extra=_extra)
end

return, cntr
end
