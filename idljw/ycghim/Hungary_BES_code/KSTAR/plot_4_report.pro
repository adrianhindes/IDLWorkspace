pro plot_4_report
  hardon, /color
  set_plot_style, 'foile_kg_eps'
 device,decomposed=1
  focal_length=50
  restore, 'cal/spat_cal_'+strtrim(focal_length,2)+'mm.sav'
  aa=spat_cor_p
  a=[[aa[0,0,*]],[aa[0,1049,*]],[aa[1484,1049,*]],[aa[1484,0,*]],[aa[0,0,*]]]
  plot,a[0,*,0],-a[0,*,1], xstyle=1, ystyle=1, xtitle='Horizontal pixel coordinate [pix]', ytitle='Vertical pixel coordinate [pix]',$
      xcharsize=2, ycharsize=2, thick=1,/isotropic
       ;xrange=[-max(a[0,*,0])*0.1,max(a[0,*,0])*1.1],yrange=[max(-a[0,*,1])*0.1,-max(-a[0,*,1])*1.1]
      
  xres=28.
  for i=0,28 do begin
    oplot, [aa[i*round(1484./xres),0,0],aa[i*round(1484./xres),1049,0]],[-aa[i*round(1484./xres),0,1],-aa[i*round(1484./xres),1049,1]]
  endfor
  yres=18.
  for i=0,18 do begin
    if i ne 9 then begin
      oplot, [aa[0,round(i*1049./yres),0],aa[1484,round(i*1049./yres),0]],[-aa[0,round(i*1049./yres),1],-aa[1484,round(i*1049./yres),1]]
    endif else begin
      oplot, [aa[0,round(i*1049./yres),0],aa[1484,round(i*1049./yres),0]],[-aa[0,round(i*1049./yres),1],-aa[1484,round(i*1049./yres),1]], thick=3
    endelse
  endfor
  a=dblarr(32,2)
  for i=0,7 do for j=0,3 do a[i+j*8,*]=pixcor_d[i,j,*]
  oplot, a[*,0],-a[*,1], psym=4, thick=5
  loadct,39
  oplot,[27,1739],[-1248,-1286], color=100
stop
  hardfile, 'distorsion_det.ps'
  
  hardon, /color
  set_plot_style, 'foile_kg_eps'
    a=dblarr(32,2)
    b=dblarr(128,2)
    
    op_ax = [(spatcor_d[3,1,0]+spatcor_d[4,1,0]+spatcor_d[3,2,0]+spatcor_d[4,2,0])/4.,$
            (spatcor_d[3,1,1]+spatcor_d[4,1,1]+spatcor_d[3,2,1]+spatcor_d[4,2,1])/4.]
    
    spatcor_d[*,*,0]=spatcor_d[*,*,0]-op_ax[0]
    spatcor_d[*,*,1]=spatcor_d[*,*,1]-op_ax[1]
    det_cor_spat[*,*,*,0]= det_cor_spat[*,*,*,0]-op_ax[0]
    det_cor_spat[*,*,*,1]= det_cor_spat[*,*,*,1]-op_ax[1]
    
    loadct, 5
    Device, Decomposed=0
    for i=0,7 do for j=0,3 do for k=0,3 do b[i*16+j*4+k,*]=det_cor_spat[i,j,k,*]
    plot, b[*,0],b[*,1], psym=4, xstyle=1, ystyle=1, xcharsize=1.5, ycharsize=1.5,$
          xtitle='Horizontal distance from the optical axis [mm]', ytitle='Vertical distance from the optical axis [mm]'
    for i=0,7 do for j=0,3 do a[i+j*8,*]=spatcor_d[i,j,*]
    oplot, a[*,0],a[*,1], psym=4, thick=5
    oplot, b[*,0],b[*,1], psym=4, color=50, thick=3
    
  hardfile, 'det_pix.ps'
  
end