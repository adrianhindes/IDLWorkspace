pro scalebar,colorscheme=colorscheme,position=position,datarange=datarange,levels=levels,nlev=nlev,$
   plotrange=plotrange,thick=thick,axisthick=axisthick,linethick=linesthick,charsize=charsize,title=title

;**********************************************************************************************
;* SCALEBAR.PRO                S. Zoletnik  25.03.2012                                        *
;**********************************************************************************************
;* Plots a scale bar for a contour plot.                                                      *
;*                                                                                            *
;* INPUT:                                                                                     *
;*   colorscheme: color scheme ('red-white-blue','blue-white-red','white-black','back-white') *
;*                (See setcolor.pro)                                                          *
;*    levels: list of levels (e.g. levels for a contour plot)                                 *
;*    thick: Line and character thickness (default:1)                                         *
;*    axisthick,linethick,charthick: Different line thicknesses (default: thick)              *
;*    charsize: Character size (default:1)                                                    *
;*    position: Position on page in normal coordinates                                        *
;*    plotrange: The plot range of the scalebar.                                              *
;*               (The data range of the associated contour plot)                              *
;*    datarange: The data range. This range will be filled in the scalebar. (def: plotrange)  *
;*    levels: The contour levels.                                                             *
;*    nlev: The number of contour levels.                                                     *
;*    title: The scale title (e.g. units)                                                     *
;**********************************************************************************************
default,thick,1
default,charsize,1
default,position,[0.85,0.15,0.9,0.9]
if (defined(thick)) then begin
  axisthick = thick
  charchick = thick
  linethick = thick
endif
default,axisthick,1
default,linethick,1
default,charthick,1
default,colorscheme,'black-white'
if (not defined(plotrange) and not defined(datarange)) then begin
  print,'Plotrange or datarange must be set in scalebar.pro'
  return
endif
if (not defined(plotrange)) then plotrange = datarange
if (not defined(datarange)) then datarange = plotrange
if (defined(levels)) then nlev = n_elements(levels)
default,levels,findgen(nlev)/(nlev-1)*(datarange[1]-datarange[0])+datarange[0]

setcolor,levels=levels,c_colors=c_colors,scheme=colorscheme

sc=fltarr(2,50)
scale=findgen(50)/49*(datarange[1]-datarange[0])+datarange[0]
sc(0,*)=scale
sc(1,*)=scale
contour,sc,[0,1],scale,levels=levels,nlev=nlev,/fill,$
         position=position,xstyle=1,xrange=[0,0.9],ystyle=1,yrange=plotrange,xticks=1,$
         xtickname=[' ',' '],/noerase,c_colors=c_colors,charsize=0.7*charsize,xthick=axisthick,$
         ythick=axisthick,thick=linethick,charthick=axisthick,yticklen=-0.07,ytitle=title
end