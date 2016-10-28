pro show_kstar_flux,shot,time,silent=silent,rrange=rrange,zrange=zrange,isotropic=isotropic,$
       thick=thick,charsize=charsize,nolegend=nolegend,noerase=noerase,nlevels=nlevels,waittime=waittime,$
       errormess=errormess,overplot=over
;******************************************************************************
;* show_kstar_flux.pro                 S. Zoletnik  08.10.2013                *
;******************************************************************************
;* Plots a flux contour plot for KSTAR using the EFIT g files
;*
;*  INPUT:
;*    shot: Shot number
;*    time: Time for EFIT reconstruction. The closes available time will be used.
;*    /silent: Don't print error messages.
;*    rrange: R range for plot
;*    zrange: z range of plot
;*    /isotropic: Use identical scales for plotting R and Z (this is the default.)
;*    nlevels: Number of levels for contour plot
;*    /over: Overplot mapping, don't dear flux
;***********************************************************************************

default,isotropic,1
default,nlevels,30
default,rrange,[1.2,2.5]
default,zrange,[-1.1,1.1]

flux = get_kstar_efit(shot,time,errormess=errormess,/silent)
if (errormess ne '') then begin
  if (not keyword_set(silent)) then print,errormess
  return
endif

if (not keyword_set(noerase) and not keyword_set(over)) then erase
if (not keyword_set(nolegend) and not keyword_set(over)) then time_legend,'show_kstar_bes_flux.pro'
if (not keyword_set(over)) then begin
  contour,flux.psi,flux.r,flux.z,xrange=rrange,xstyle=1,xtitle='R [m]',nlevels=nlevels,$
     yrange=zrange,ystyle=1,ytitle='Z [m]',isotropic=isotropic,thick=thick,xthick=thick,$
     ythick=thick,charthick=thick,charsize=charsize,/noerase,title=i2str(shot)+'  '+string(time,format='(F5.2)')+'s'
  oplot,flux.boundary_r,flux.boundary_z,linest=2,thick=thick

endif


end