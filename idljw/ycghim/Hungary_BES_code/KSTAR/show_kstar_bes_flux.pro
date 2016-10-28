pro show_kstar_bes_flux,shot,time,phi=phi,turns=turns,silent=silent,rrange=rrange,zrange=zrange,isotropic=isotropic,$
       thick=thick,charsize=charsize,nolegend=nolegend,noerase=noerase,nlevels=nlevels,draw=draw,waittime=waittime,$
       errormess=errormess,overplot=over,offset=offset,channel=channel
;******************************************************************************
;* show_kstar_bes_flux.pro                 S. Zoletnik  14.2.2012             *
;******************************************************************************
;* Plots a flux contour plot and overplots the BES measuring pixels mapped
;* along field lines to a certain toroidal angle. Angle 0 is at port L,
;* positive direction is counter-clockwise.
;* If phi is not set the original poloidal location of the pixels is plotted
;* regardless of toroidal position.
;* Mapping can be done in positive or negative direction and over multiple
;* toroidal turns, this is set by argument "turns"
;*
;*  INPUT:
;*    shot: Shot number
;*    time: Time for EFIT reconstruction. The closes available time will be used.
;*    phi: The toroidal angle where the mapping is shown (default is no mapping)
;*    turns: The number of turns
;*      1: closest phi in counter-clockwise direction
;*      -1: closest turn in clockwise direction
;*      2: closest turn +1 in counter-clockwise direction
;*      ...
;*    /silent: Don't print error messages.
;*    rrange: R range for plot
;*    zrange: z range of plot
;*    /isotropic: Use identical scales for plotting R and Z (this is the default.)
;*    nlevels: Number of levels for contour plot
;*    /draw: Draw mapping as it progresses along toroidal direction.
;*    waittime: wait time between plots in /draw mode
;*    /over: Overplot mapping, don't dear flux
;*    channel: Plot only this channel, otherwise plot all (e.g. 'BES-2-2')
;***********************************************************************************

default,isotropic,1
default,nlevels,30
default,rrange,[1.0,2.5]
default,zrange,[-1.1,1.1]
default,phistep,2*!pi/100
default,turns,1
default,waittime,1
default,offset,[0,0]

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

bes_coord = getcal_kstar_spat(shot, errormess=errorormess)
if (errormess ne '') then begin
  print,errormess
  return
endif
ncol = (size(bes_coord))[1]
nrow = (size(bes_coord))[2]
for i=0,ncol-1 do begin
  for j=0,nrow-1 do begin
    bes_coord[i,j,0:1] = bes_coord[i,j,0:1]+offset
  endfor
endfor

ncol = (size(bes_coord))[1]
nrow = (size(bes_coord))[2]
;for i=0,ncol-1 do begin
;  for j=0,nrow-1 do begin
;    corners_R = reform(bes_coord[i,j,0])
;    corners_Z = reform(bes_coord[i,j,1])
;    plots,[corners_R,corners_R[0]]/1000,[corners_Z,corners_Z[0]]/1000.,thick=thick
;  endfor
;endfor

if (defined(phi)) then begin
  dphi = phi-bes_coord[*,*,2]
  if (turns gt 0) then begin
    ; Normalize between (0,2Pi]
    while 1 do begin
      ind = where(dphi le 0)
      if (ind[0] lt 0) then break
      dphi[ind] = dphi[ind]+2*!pi
    endwhile
    if (turns gt 1) then begin
      dphi = dphi+turns*2*!pi
    endif
  endif
  if (turns lt 0) then begin
    ; Normalize between [-2Pi,0)
    while 1 do begin
      ind = where(dphi ge 0)
      if (ind[0] lt 0) then break
      dphi[ind] = dphi[ind]-2*!pi
    endwhile
    if (turns lt -1) then begin
      dphi = dphi-turns*2*!pi
    endif
  endif
  nstep = round(max(abs(dphi))/phistep)
  bes_coord_orig = bes_coord
  dphi_all = dphi/nstep
  dphi_all_r = reform(dphi_all,ncol*nrow)
  for istep=0,nstep-1 do begin
    if (keyword_set(draw) and not keyword_set(silent)) then print,i2str(istep+1)+'/'+i2str(nstep)
    bes_coord_prev = bes_coord
    xcoord = reform(bes_coord[*,*,0]/1000,ncol*nrow)
    ycoord = reform(bes_coord[*,*,1]/1000,ncol*nrow)
    xcoord_inter = (xcoord-min(flux.r))/(max(flux.r)-min(flux.r))*(n_elements(flux.r)-1)
    ycoord_inter = (ycoord-min(flux.z))/(max(flux.z)-min(flux.z))*(n_elements(flux.z)-1)
    bt_i = interpolate(flux.b_t,xcoord_inter,ycoord_inter)
    bz_i = interpolate(flux.b_z,xcoord_inter,ycoord_inter)
    br_i = interpolate(flux.b_r,xcoord_inter,ycoord_inter)
    bes_coord[*,*,2] = bes_coord[*,*,2] + dphi_all
    bes_coord[*,*,1] = bes_coord[*,*,1] + reform(bz_i/bt_i*dphi_all_r*xcoord,[ncol,nrow])*1000
    bes_coord[*,*,0] = bes_coord[*,*,0] + reform(br_i/bt_i*dphi_all_r*xcoord,[ncol,nrow])*1000
    if (keyword_set(draw)) then begin
      ncol = (size(bes_coord))[1]
      nrow = (size(bes_coord))[2]
      for i=0,ncol-1 do begin
        for j=0,nrow-1 do begin
          corners_R = reform(bes_coord[i,j,0])
          corners_Z = reform(bes_coord[i,j,1])
          plots,[bes_coord_prev[i,j,k,0]/1000,bes_coord[i,j,0]/1000],[bes_coord_prev[i,j,1]/1000,$
            bes_coord[i,j,1]/1000],thick=thick, color=255
        endfor
      endfor
      wait,waittime
    endif
  endfor
endif  ; if defined phi

ncol = (size(bes_coord))[1]
nrow = (size(bes_coord))[2]
if (defined(channel)) then begin
  channel_row = fix(strmid(channel,4,1))
  channel_column = fix(strmid(channel,6,1))
endif else begin
  channel_row = 0
  channel_column = 0
endelse
loadct, 5
for i=0,ncol-1 do begin
  for j=0,nrow-1 do begin
    if ((not defined(channel)) or $
        (defined(channel) and (channel_row eq j) and (channel_column eq i))) then begin
      corners_R = reform(bes_coord[i,j,0])
      corners_Z = reform(bes_coord[i,j,1])
      plots,[corners_R,corners_R[0]]/1000,[corners_Z,corners_Z[0]]/1000.,thick=thick, color=120, psym=4
    endif
  endfor
endfor
end