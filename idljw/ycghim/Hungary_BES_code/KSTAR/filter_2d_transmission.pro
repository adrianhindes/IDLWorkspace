pro filter_2d_transmission,ebeam_d=ebeam_d,rho=rho,ray_divergence=ray_divergence,$
   filter_angle=angle,temperature=temperature,noplot=noplot,thick=thick,charsize=charsize,symsyze=symsize,$
   fixed_wavelength=fixed_wavelength,title=title,cwl=cwl,filter_name=filter,$
   equation=equation,ref_index=refr_index,image_size=image_size,ratio_range=ratio_range, lithium=lithium, radius=radius, ebeam_li=ebeam_li

default,filter,'Materion_V3.dat'
default,cwl,669.8.
default,image_size,46.
default,ray_divergence,5.
default,image_res,7
default,charsize,1

image_fixed = fltarr(image_res,image_res)
image_doppler = fltarr(image_res,image_res)
image_spectrum = fltarr(image_res,image_res)

xlist = fltarr(image_res)
ylist = fltarr(image_res)
for i=0,image_res-1 do begin
  x = float(image_size)/image_res*(i-float(image_res-1)/2)
  xlist[i] = x
  print,i2str(i)+'/'+i2str(image_res) & wait,0.1
  for j=0,image_res-1 do begin
    y = float(image_size)/image_res*(j-float(image_res-1)/2)
    ylist[j] = y
    delete,radius
    filter_image_transmission,ebeam_d=ebeam_d,rho=rho,ray_divergence=ray_divergence,$
    filter_angle=angle,temperature=temperature,fixed_wavelength=fixed_wavelength,cwl=cwl,filter_name=filter,$
    trans_fixed=trans,trans_doppler=trans_doppler,trans_spectrum=trans_spectrum,errormess=errormess,$
    transmission_filter=filter_transmission,wavelength=w,full_beam=full_beam,spectrum_data=spectrum_data,$
    spectrum_w=spectrum_w,doppler_wavelength=w_doppler,radius=radius,$
    equation=equation,ref_index=refr_index,image_point=[x,y]
    if (errormess ne '') then return

    image_fixed[i,j] = trans
    image_doppler[i,j] = trans_doppler
    image_spectrum[i,j] = trans_spectrum
  endfor
endfor

if (not keyword_set(noplot)) then begin
  erase
  time_legend,'filter_2d_transmission.pro'
  if (!d.name eq 'PS') then colorscheme = 'white-black' else colorscheme = 'black-white'
  nlev=100

  datarange = [0,max(image_doppler)]
  plotrange = [0,10000]
  levels = findgen(nlev)/(nlev-1)*(datarange[1]-datarange[0])+datarange[0]
  setcolor,levels=levels,c_colors=c_colors,scheme=colorscheme
  contour,image_doppler,xlist,ylist,levels=levels,pos=[0.05,0.6,0.24,0.9],/noerase,thick=thick,xthick=thick,ythick=thick,charthick=thick,$
   charsize=charsize*0.8,/fill,c_colors=c_colors,xtitle='X [mm]',ytitle='Y [mm]',xstyle=1,ystyle=1,$
   title='Transmission at Doppler',xticklen=-0.05,yticklen=-0.05,/isotropic
  scalebar,colorscheme=colorscheme,position=[0.29,0.6,0.3,0.9],datarange=datarange,levels=levels,$
   thick=thick,axisthick=axisthick,linethick=linesthick,charsize=charsize*0.8,plotrange=plotrange,title='%'

  datarange = [0,max(image_spectrum)]
  plotrange = [0,10000]
  levels = findgen(nlev)/(nlev-1)*(datarange[1]-datarange[0])+datarange[0]
  setcolor,levels=levels,c_colors=c_colors,scheme=colorscheme
  contour,image_spectrum,xlist,ylist,levels=levels,pos=[0.375,0.6,0.565,0.9],/noerase,thick=thick,xthick=thick,ythick=thick,charthick=thick,$
   charsize=charsize*0.8,/fill,c_colors=c_colors,xtitle='X [mm]',ytitle='Y [mm]',xstyle=1,ystyle=1,$
   title='Transmission of spectrum',xticklen=-0.05,yticklen=-0.05,/isotropic
  scalebar,colorscheme=colorscheme,position=[0.615,0.6,0.625,0.9],datarange=datarange,levels=levels,$
   thick=thick,axisthick=axisthick,linethick=linesthick,charsize=charsize*0.8,plotrange=plotrange,title='%'

  datarange = [0,max(image_fixed)]
  plotrange = [0,max(image_fixed)]
  levels = findgen(nlev)/(nlev-1)*(datarange[1]-datarange[0])+datarange[0]
  setcolor,levels=levels,c_colors=c_colors,scheme=colorscheme
  contour,image_fixed,xlist,ylist,levels=levels,pos=[0.7,0.6,0.89,0.9],/noerase,thick=thick,xthick=thick,ythick=thick,charthick=thick,$
   charsize=charsize*0.8,/fill,c_colors=c_colors,xtitle='X [mm]',ytitle='Y [mm]',xstyle=1,ystyle=1,$
   title='Transmission at '+string(fixed_wavelength,format='(F5.1)')+'nm',xticklen=-0.05,yticklen=-0.05,/isotropic
  scalebar,colorscheme=colorscheme,position=[0.94,0.6,0.95,0.9],datarange=datarange,levels=levels,$
   thick=thick,axisthick=axisthick,linethick=linesthick,charsize=charsize*0.8,plotrange=plotrange,title='%'

default,ratio_range,[0,max([image_doppler/image_fixed,image_spectrum/image_fixed])]

  datarange = [0,max(image_doppler/image_fixed)]
  plotrange = ratio_range
  levels = findgen(nlev)/(nlev-1)*(plotrange[1]-plotrange[0])+plotrange[0]
  setcolor,levels=levels,c_colors=c_colors,scheme=colorscheme
  contour,image_doppler/image_fixed,xlist,ylist,levels=levels,pos=[0.05,0.1,0.24,0.4],/noerase,thick=thick,xthick=thick,ythick=thick,charthick=thick,$
   charsize=charsize*0.8,/fill,c_colors=c_colors,xtitle='X [mm]',ytitle='Y [mm]',xstyle=1,ystyle=1,$
   title='Ratio Doppler/fixed',xticklen=-0.05,yticklen=-0.05,/isotropic
  scalebar,colorscheme=colorscheme,position=[0.29,0.1,0.3,0.4],datarange=datarange,levels=levels,$
   thick=thick,axisthick=axisthick,linethick=linesthick,charsize=charsize*0.8,plotrange=plotrange

  datarange = [0,max(image_spectrum/image_fixed)]
  plotrange = ratio_range
  levels = findgen(nlev)/(nlev-1)*(plotrange[1]-plotrange[0])+plotrange[0]
  setcolor,levels=levels,c_colors=c_colors,scheme=colorscheme
  contour,image_spectrum/image_fixed,xlist,ylist,levels=levels,pos=[0.375,0.1,0.565,0.4],/noerase,thick=thick,xthick=thick,ythick=thick,charthick=thick,$
   charsize=charsize*0.8,/fill,c_colors=c_colors,xtitle='X [mm]',ytitle='Y [mm]',xstyle=1,ystyle=1,$
   title='Ratio Spectrum/fixed',xticklen=-0.05,yticklen=-0.05,/isotropic
  scalebar,colorscheme=colorscheme,position=[0.615,0.1,0.625,0.4],datarange=datarange,levels=levels,$
   thick=thick,axisthick=axisthick,linethick=linesthick,charsize=charsize*0.8,plotrange=plotrange

  title = 'R = '+i2str(radius*1000)+'[mm] (r/a='+string(rho,format='(F4.2)')+')
  title = title+'!CFilter: '+filter
  title = title+'!CCWL: '+string(cwl,format='(F6.2)')+' [nm]'
  title = title+'!CDivergence: '+i2str(ray_divergence)
  title = title+'!CT: '+string(temperature,format='(F4.1)')+'[C]'
  title = title+'!CFilter angle: '+string(angle,format='(F3.1)')+'[deg]'
  title = title+'!CE!Dbeam Lithium!N='+i2str(ebeam_li)+' [keV]'
  xyouts,0.65,0.35,title,charthick=thick ,/normal
endif


end


