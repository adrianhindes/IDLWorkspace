pro optimize_kstar_filter,n_divergence=n_divergence,divergence_max=divergence_max,cwl_range=cwl_range,$
   ebeam=ebeam,radius=radius,angle=angle,temperature=temperature,thick=thick,charsize=charsize,symsyze=symsize,$
   fixed_wavelength=fixed_wavelength,filter=filter,ratio_range=ratio_range,$
   trans_doppler=trans_doppler_all,trans_spectrum=trans_spectrum_all,trans_fixed=trans_fixed_all,cwls=cwls,divergences=divergences,$
   rho=rho,errormess=errormess,full_beam=full_beam


;* This program calculates the transmission of the filter at difference divergences
;* (on the filter) and at different center wavelengths (cwl). The results are plotted
;* as 2D plots.
;*

default,divergence_max,7. ; degree
default,n_divergence,10
default,cwl_step,0.1 ; n
default,cwl_range,[659,664] ; nm
default,temperature,23.
default,angle,0.

default,ebeam,100.
default,filter,'BES_2011.dat'
default,fixed_wavelength,658.3

n_cwl = round((cwl_range[1]-cwl_range[0])/cwl_step)
cwls = findgen(n_cwl)*cwl_step+cwl_range[0]

for i=0,n_cwl-1 do begin
  print,i2str(i+1)+'/'+i2str(n_cwl) & wait,0.1
  delete,radius
  filter_divergence_transmission,ebeam=ebeam,ray_divergence=divergence_max,n_divergence=n_divergence,$
   angle=angle,temperature=temperature,/noplot,fixed_wavelength=fixed_wavelength,cwl=cwls[i],$
   filter=filter,trans_fixed=trans_fixed,trans_doppler=trans_doppler,trans_spectrum=trans_spectrum,div_list=divergences,errormess=errormess,$
   rho=rho,radius=radius,full_beam=full_beam
  if (errormess ne '') then return
  if (i eq 0) then begin
    trans_fixed_all = fltarr(n_cwl,n_divergence)
    trans_doppler_all = fltarr(n_cwl,n_divergence)
    trans_spectrum_all = fltarr(n_cwl,n_divergence)
  endif
  trans_fixed_all[i,*] = trans_fixed
  trans_doppler_all[i,*] = trans_doppler
  trans_spectrum_all[i,*] = trans_spectrum
endfor

erase
time_legend,'optimize_kstar_filter.pro'
colorscheme = 'black-white'
nlev=100

datarange = [0,max(trans_doppler_all)]
plotrange = datarange
levels = findgen(nlev)/(nlev-1)*(datarange[1]-datarange[0])+datarange[0]
setcolor,levels=levels,c_colors=c_colors,scheme=colorscheme
contour,trans_doppler_all,cwls,divergences,levels=levels,pos=[0.05,0.6,0.24,0.9],/noerase,thick=thick,xthick=thick,ythick=thick,charthick=thick,$
   charsize=charsize,/fill,c_colors=c_colors,xtitle='CWL [nm]',ytitle='Divergence [deg]',xstyle=1,ystyle=1,$
   title='Transmission at Doppler wave',xticklen=-0.05,yticklen=-0.05
scalebar,colorscheme=colorscheme,position=[0.29,0.6,0.3,0.9],datarange=datarange,levels=levels,$
   thick=thick,axisthick=axisthick,linethick=linesthick,charsize=charsize,title='%'

plot_spectrum=1
if (plot_spectrum) then begin
  datarange = [0,max(trans_spectrum_all)]
  plotrange = datarange
  levels = findgen(nlev)/(nlev-1)*(datarange[1]-datarange[0])+datarange[0]
  setcolor,levels=levels,c_colors=c_colors,scheme=colorscheme
  contour,trans_spectrum_all,cwls,divergences,levels=levels,pos=[0.375,0.6,0.565,0.9],/noerase,thick=thick,xthick=thick,ythick=thick,charthick=thick,$
     charsize=charsize,/fill,c_colors=c_colors,xtitle='CWL [nm]',ytitle='Divergence [deg]',xstyle=1,ystyle=1,$
     title='Transmission of spectrum',xticklen=-0.05,yticklen=-0.05
  scalebar,colorscheme=colorscheme,position=[0.615,0.6,0.625,0.9],datarange=datarange,levels=levels,$
     thick=thick,axisthick=axisthick,linethick=linesthick,charsize=charsize,title='%'
endif

datarange = [0,max(trans_fixed_all)]
plotrange = datarange
levels = findgen(nlev)/(nlev-1)*(datarange[1]-datarange[0])+datarange[0]
setcolor,levels=levels,c_colors=c_colors,scheme=colorscheme
contour,trans_fixed_all,cwls,divergences,levels=levels,pos=[0.7,0.6,0.89,0.9],/noerase,thick=thick,xthick=thick,ythick=thick,charthick=thick,$
   charsize=charsize,/fill,c_colors=c_colors,xtitle='CWL [nm]',ytitle='Divergence [deg]',xstyle=1,ystyle=1,$
   title='Transmission at '+string(fixed_wavelength,format='(F5.1)')+'nm',xticklen=-0.05,yticklen=-0.05
scalebar,colorscheme=colorscheme,position=[0.94,0.6,0.95,0.9],datarange=datarange,levels=levels,$
   thick=thick,axisthick=axisthick,linethick=linesthick,charsize=charsize,title='%'

default,ratio_range,[0,min([trans_doppler_all/trans_fixed_all,trans_spectrum_all/trans_fixed_all])]

datarange = [0,max(trans_doppler_all/trans_fixed_all)]
plotrange = ratio_range
levels = findgen(nlev)/(nlev-1)*(plotrange[1]-plotrange[0])+plotrange[0]
setcolor,levels=levels,c_colors=c_colors,scheme=colorscheme
contour,trans_doppler_all/trans_fixed_all,cwls,divergences,levels=levels,pos=[0.05,0.1,0.24,0.4],/noerase,thick=thick,xthick=thick,ythick=thick,charthick=thick,$
   charsize=charsize,/fill,c_colors=c_colors,xtitle='CWL [nm]',ytitle='Divergence [deg]',xstyle=1,ystyle=1,$
   title='Doppler/fixed',xticklen=-0.05,yticklen=-0.05
scalebar,colorscheme=colorscheme,position=[0.29,0.1,0.3,0.4],datarange=datarange,levels=levels,$
   thick=thick,axisthick=axisthick,linethick=linesthick,charsize=charsize,plotrange=plotrange

plot_spectrum = 1
if (plot_spectrum) then begin
  datarange = [0,max(trans_spectrum_all/trans_fixed_all)]
  plotrange = ratio_range
  setcolor,levels=levels,c_colors=c_colors,scheme=colorscheme
  contour,trans_spectrum_all/trans_fixed_all,cwls,divergences,levels=levels,pos=[0.375,0.1,0.565,0.4],/noerase,thick=thick,xthick=thick,ythick=thick,charthick=thick,$
     charsize=charsize,/fill,c_colors=c_colors,xtitle='CWL [nm]',ytitle='Divergence [deg]',xstyle=1,ystyle=1,$
     title='Spectrum/fixed',xticklen=-0.05,yticklen=-0.05
  scalebar,colorscheme=colorscheme,position=[0.615,0.1,0.625,0.4],datarange=datarange,levels=levels,$
     thick=thick,axisthick=axisthick,linethick=linesthick,charsize=charsize,plotrange=plotrange
endif

title = 'R = '+i2str(radius*1000)+'[mm] (r/a='+string(rho,format='(F4.2)')+')
title = title+'!CFilter: '+filter
title = title+'!CT: '+string(temperature,format='(F4.1)')+'[C]'
title = title+'!CFilter angle: '+string(angle,format='(F3.1)')+'[deg]'
title = title+'!CE!Dbeam!N='+i2str(ebeam)+' [keV]'
xyouts,0.65,0.45,title,charthick=thick ,/normal








end