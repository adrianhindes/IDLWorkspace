pro kstar_elmplot_v,shot,timerange=timerange,inttime=inttime,title=title,$
         offset_timerange=offset_timerange,ystep=ystep, profiles=profiles, nocalibrate=nocalibrate,$
         yrange_prof=yrange_prof, symsize=symsize,charsize=charsize,thick=thick, ha_signal=ha_signal,$
         ha_psym=ha_psym,nocalculate=nocalculate,prof_t=prof_t,color=color
;*******************************************************************************
; KSTAR_ELMPLOT_v.PRO     S. Zoletnik  2014
; Plot velocities at different radii as a function of time.
; Velocities are calculated from velocimetry
;
; INPUT:
;  shot: Shot No
;  timerange: time range for plotting curves
;  columns: The list of columns on which the signal is used. (1...)
;  inttime: integration time in microsec to apply for velocity signals
;  profiles: if < 0  click to timepoints where profiles are plotted
;          otherwise list of timepoints for profiles
;  prof_t: The time interval around profiles time for integrrating the velocity
;  ystep: vertical offset between BES curves in plot
;  /nocalibrate: Do not calibrate signals
;  symsize: symbol size on profile plot
;  ha_psym: Plot symbol for H-alpha signal. Default is 0 (no symbol)
;  title: Title of the main signal plot
;  /color: Use colors fro profiles
;***********************************************************************************
default,inttime,50.0   ; microsec
default,columns,8-indgen(8)
default,ha_signal,'\POL_HA03'
default,lcfs_signal,'efm_r(psi100)_out'
default,symsize,0.5
default,charsize,1
default,thick,1
default,ha_psym,0
default,rot_deg,18.
default,search_range,[-6,6]
default,resolution,40
default,v_lowcut,1e3
default,v_inttime,10.
default,v_tres,0.5e-6
default,corr_int,5e-5
default,prof_t,1e-5

if (not keyword_set(nocalculate)) then begin
  for i=0,n_elements(columns)-1 do begin
    print,'Calculating velocity from column '+i2str(columns[i])
    wait,0.1
    calculate_vpol_velocimetry,shot,col=columns[i],int=v_inttime,timer=timerange,lowcut=v_lowcut,tres=v_tres,res=300,$
        search_range=[-5,5],corr_int=corr_int,errormess=errormess
    ;calculate_vpol_velocimetry,shot,timerange=timerange,column=columns[i],lowcut=v_lowcut,int=v_inttime,tres=v_tres,$
    ;    search_r=search_range,res=resolution,errormess=errormess
    if (errormess ne '') then return
  endfor
endif

detpos=getcal_kstar_spat(shot,/trans)
if (defined(rot_deg)) then begin
  detpos_0 = total(total(detpos,1),1)/32
  rot = float(rot_deg)/180*!pi
  for i=0,(size(detpos))[1]-1 do begin
    for j=0,(size(detpos))[2]-1 do begin
      detpos[i,j,0] = (detpos[i,j,0]-detpos_0[0])*cos(rot) + (detpos[i,j,1]-detpos_0[1])*sin(rot)+detpos_0[0]
      detpos[i,j,1] = -(detpos[i,j,0]-detpos_0[0])*sin(rot) + (detpos[i,j,1]-detpos_0[1])*cos(rot)+detpos_0[1]
    endfor
  endfor
endif
;mean_step = total(detpos[*,1:3,1]-detpos[*,0:2,1],2)/3
;mean_step = mean_step[columns-1]

n_ch = n_elements(columns)

if (keyword_set(color)) then begin
  colors = [1,2,3,4,5,6]
  if (!d.name ne 'PS') then device,decompose=0
  setfigcol
endif else begin
  if (!d.name ne 'PS') then device,decompose=1
  colors = lonarr(6)+!p.color
  loadct,0
endelse

get_rawsignal,shot,ha_signal,t_ha,d_ha,timerange=timerange,errormess=errormess
if (errormess ne '') then begin
  print,errormess
endif

pos_bes = [0.1,0.1,0.6,0.7]
pos_ha =[0.1,0.8,0.6,0.95]
pos_prof = [0.7,0.1,0.95,0.5]
pos_image = [0.7,0.65,0.95,0.95]

erase

if (n_elements(d_ha) gt 2) then begin
  plotsymbol,0
  plot,t_ha,d_ha,position=pos_ha,/noerase,xstyle=1,xrange=timerange,$
       yrange=[0,1.05*max(d_ha)],ystyle=1,ytitle='a.u.',xtickname=replicate(' ',10),title=ha_signal,$
       thick=thick,charthick=thick,xthick=thick,ythick=thick,charsize=charsize*0.65,psym=ha_psym,symsize=symsize
endif

default,ystep,1.

yrange_bes = [0,ystep*(n_ch+1)]
default,title,i2str(shot)+'  Poloidal velocity'
plot,[0,0],[1,1],position=pos_bes,/noerase,xstyle=1,xrange=timerange,$
     yrange=yrange_bes,ystyle=1,thick=thick,charthick=thick,xthick=thick,ythick=thick,$
     title=title,/nodata,xtitle='Time [s]',ytitle='km/s',$
     charsize=charsize

for i=0,n_ch-1 do begin
  get_rawsignal,0,'cache/'+i2str(shot)+'_'+i2str(columns[i])+'_v',t,d,errormess=errormess
  if (errormess ne '') then return
  if (keyword_set(inttime)) then d = integ(d,t,inttime*1e-6)

  if (not defined(d_all)) then begin
    d_all = fltarr(n_elements(d),n_ch)
    t_all = dblarr(n_elements(t),n_ch)
  endif else begin
    if ((size(d_all))[1] lt n_elements(d)) then begin
      d_all_save = d_all
      t_all_save = t_all
      d_all = fltarr(n_elements(d),n_ch)
      t_all = dblarr(n_elements(t),n_ch)
      d_all[0:(size(d_all_save))[1]-1,*] = d_all_save
      t_all[0:(size(t_all_save))[1]-1,*] = t_all_save
    endif
  endelse
  d_all[0:n_elements(d)-1,i] = d
  t_all[0:n_elements(t)-1,i] = t

  oplot,t,d+(n_ch-i)*ystep,thick=thick,psym=3
  oplot,timerange,[0,0]+(n_ch-i)*ystep,linest=2,thick=thick
  if (keyword_set(lcfs)) then begin
    xyouts,timerange[0]+(timerange[1]-timerange[0])*0.02,signals[i,(size(signals))[2]*0.1]+(n_ch-1-i+0.1)*ystep,string(BES_R[i]/10-lcfs*100,format='(F5.1)')+'cm',charthick=thick
  endif
endfor

BES_R = reform(detpos[columns-1,0,0])/10

if (defined(profiles)) then begin
  if (profiles[0] lt 0) then begin
    print,'Click timepoints of profiles. Click right button to stop. '
    digxadd,xp,/data
    profiles = xp
  endif
  n_prof = n_elements(profiles)
  x_t = fltarr(n_prof)
  nch = n_elements(columns)
  prof_data = fltarr(n_prof,nch)
  for i=0,n_prof-1 do begin
    oplot,[profiles[i]-prof_t/2,profiles[i]-prof_t/2],yrange_bes,linestyle=i/n_elements(colors),thick=thick,color=colors[i mod n_elements(colors)]
    oplot,[profiles[i]+prof_t/2,profiles[i]+prof_t/2],yrange_bes,linestyle=i/n_elements(colors),thick=thick,color=colors[i mod n_elements(colors)]
    for j=0,nch-1 do begin
      ind = where((reform(t_all[*,j]) ge profiles[i]-prof_t/2) and (reform(t_all[*,j]) le profiles[i]+prof_t/2))
      if (ind[0] ge 0) then begin
        prof_data[i,j] = mean(d_all[ind,j])
      endif
    endfor
  endfor

  default,yrange_prof,[min(prof_data),max(prof_data)]
  plot,BES_R, fltarr(n_elements(BES_R)),xrange=[min(BES_R)-1,max(BES_R)+1],$
    xstyle=1,yrange=yrange_prof,ystyle=1,/nodata,xtitle='R [channel]',pos=pos_prof,/noerase,title='Velocity Profiles',$
    thick=thick,charthick=thick,xthick=thick,ythick=thick,charsize=charsize,ytitle='km/s'
  for i=0, n_prof-1 do begin
    plotsymbol,0
    oplot, BES_R, reform(prof_data[i,*]),linestyle=i/n_elements(colors),psym=-8,symsize=symsize,thick=thick,color=colors[i mod n_elements(colors)]
  endfor
endif




;if (defined(profiles)) then begin
;  for i=0,n_prof-1 do begin
;    oplot,[profiles[i],profiles[i]],yrange_img,linestyle=i,thick=thick
;  endfor
;endif



end
