pro kstar_elmplot,shot,timerange=timerange,inttime=inttime,rows=rows,title=title,$
         offset_timerange=offset_timerange,ystep=ystep, profiles=profiles, nocalibrate=nocalibrate,$
         yrange_prof=yrange_prof, symsize=symsize,charsize=charsize,thick=thick, ha_signal=ha_signal,$
         mean_column=mean_column,color=color,ha_psym=ha_psym,channel_prefix=channel_prefix,channel_postfix=channel_postfix,$
         image=image,rot_image=rot_deg,rel_image=rel_image
;*******************************************************************************
; KSTAR_ELMPLOT.PRO     S. Zoletnik  21.08.2013   (based on mast_elmplot.pro)
; Plot kstar BES signals and an  H_alpha signal in a  timewindow
;
; INPUT:
;  shot: Shot No
;  timerange: time range for plotting curves
;  rows: Rows of signals are averaged  to form a mean signal.
;        This variable lists the rows to add (1....)
;  /mean_column: average signals in one column. This is the default)
;  columns: The list of columns on which the signal is used. (1...)
;  inttime: integration time in microsec to apply for BES channels
;  profiles: if < 0  click to timepoints where profiles are plotted
;          otherwise list of timepoints for profiles
;  ystep: vertical offset between BES curves in plot
;  /color: use color coding for poloidally offset channels
;  /nocalibrate: Do not calibrate signals
;  symsize: symbol size on profile plot
;  ha_psym: Plot symbol for H-alpha signal. Default is 0 (no symbol)
;  channel_prefix: A string to add before all channel names
;  channel_postfix: A string to add after all channel names
;  title: Title of the main signal plot
;  image: plot a 2D image of the BES light at this time. Click for time if -1
;  rot_image: Rotate the BES coordinate system [degrees]
;  rel_image: Plot image change relateive to this time isntance (-1 to select)
;***********************************************************************************
default,inttime,10.0   ; microsec
default,rows,[1,2,3,4]
default,columns,8-indgen(8)
default,ha_signal,'\POL_HA03'
default,lcfs_signal,'efm_r(psi100)_out'
default,symsize,0.5
default,charsize,1
default,thick,1
default,mean_column,1
default,ha_psym,0
default,channel_prefix,''
default,channel_postfix,''
default,rot_deg,18.

; This assumes horizontal channel arrangement
channel_matrix = strarr(4,8)
for row=1,4 do begin
  for column=1,8 do begin
    channel_matrix[row-1,column-1] = channel_prefix+'BES-'+i2str(row)+'-'+i2str(column)+channel_postfix
  endfor
endfor

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

n_ch = n_elements(columns)
n_rows = n_elements(rows)
if (keyword_set(color)) then begin
  colors = [1,2,3,4]
  if (!d.name ne 'PS') then device,decompose=0
  setfigcol
endif else begin
  if (!d.name ne 'PS') then device,decompose=1
  colors = lonarr(4)+!p.color
  loadct,0
endelse

offsets = findgen(n_ch)
for i=0,n_ch-1 do begin
  for i_row=0,n_rows-1 do begin
    signame =  channel_matrix[rows[i_row]-1,columns[i]-1]
    print,'Reading '+signame
    get_rawsignal,shot,signame,t,d,sampletime=sampletime,$
       nocalibrate=nocalibrate,timerange=timerange,errormess=errormess
    if (errormess ne '') then begin
      print,errormess
      return
    endif
    if ((i eq 0) and (i_row eq 0)) then begin
      signals = fltarr(n_ch,n_rows,n_elements(d))
      t_sig = t
    endif
    signals[i,i_row,*] = signals[i,i_row,*] + integ(d,double(inttime)/(sampletime/1e-6))
  endfor
endfor

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

default,ystep,max(signals)*0.15

yrange_bes = [0,max(signals[*,*])*1.2+ystep*(n_ch)]
rows_txt = i2str(rows[0])
default,title,i2str(shot)+'  BES signals (rows:'+rows_txt+'), int:'+string(i2str(inttime))+'!7l!Xs'
for i=1,n_rows-1 do rows_txt = rows_txt+','+i2str(rows[i])
plot,t_sig,signals[0,0,*]+ystep*(n_ch-1),position=pos_bes,/noerase,xstyle=1,xrange=timerange,$
     yrange=yrange_bes,ystyle=1,thick=thick,charthick=thick,xthick=thick,ythick=thick,$
     title=title,/nodata,xtitle='Time [s]',$
     charsize=charsize

if (keyword_set(mean_column)) then begin
  for i=0,n_ch-1 do begin
    oplot,t_sig,total(signals[i,*,*],2)/n_rows+(n_ch-1-i)*ystep,thick=thick
    if (keyword_set(lcfs)) then begin
      xyouts,timerange[0]+(timerange[1]-timerange[0])*0.02,signals[i,(size(signals))[2]*0.1]+(n_ch-1-i+0.1)*ystep,string(BES_R[i]/10-lcfs*100,format='(F5.1)')+'cm',charthick=thick
    endif
  endfor
endif else begin
   for i=0,n_ch-1 do begin
      for j=0,n_rows-1 do begin
        oplot,t_sig,signals[i,j,*]+(n_ch-1-i)*ystep,thick=thick,color=colors[j]
        if (keyword_set(lcfs)) then begin
          xyouts,timerange[0]+(timerange[1]-timerange[0])*0.02,signals[i,(size(signals))[2]*0.1]+(n_ch-1-i+0.1)*ystep,string(BES_R[i]/10-lcfs*100,format='(F5.1)')+'cm',charthick=thick
        endif
      endfor
  endfor
endelse


BES_R = reform(detpos[columns-1,0,0])/10

if (defined(profiles)) then begin
  if (profiles[0] lt 0) then begin
    print,'Click timepoints of profiles. Click right button to stop. '
    digxadd,xp,/data
    profiles = xp
  endif
  n_prof = n_elements(profiles)
  x_t = fltarr(n_prof)
  for i=0,n_prof-1 do begin
    x_t[i] = closeind(t_sig,profiles[i])
    oplot,[profiles[i],profiles[i]],yrange_bes,linestyle=i,thick=thick
  endfor


  default,yrange_prof,[0,max(total(signals[*,*,x_t],2)/n_rows)*1.05]
  plot,BES_R, fltarr(n_elements(BES_R)),xrange=[min(BES_R)-1,max(BES_R)+1],$
    xstyle=1,yrange=yrange_prof,ystyle=1,/nodata,xtitle='R [cm]',pos=pos_prof,/noerase,title='BES Profiles',$
    thick=thick,charthick=thick,xthick=thick,ythick=thick,charsize=charsize
  for i=0, n_prof-1 do begin
    plotsymbol,0
    p = signals[*,*,x_t[i]]
    if ((size(p))[0] ne 1) then p = total(p,2)
    oplot, BES_R, p/n_rows,linestyle=i,psym=-8,symsize=symsize,thick=thick
;    ind = closeind(t_lcfs,profiles[i])
;    oplot,[d_lcfs[ind],d_lcfs[ind]]*100,yrange_prof,linestyle=1,thick=thick
  endfor
endif

if (defined(image)) then begin
  loadct, 0
;  Device, Decomposed=0
  if (defined(rel_image)) then begin
    if (rel_image lt 0) then begin
      print,'Click reference timepoint of image.'
      if (defined(xref)) then delete,xref
      digxy,xref,yref,/data
    endif
    ind_ref = closeind(t_sig,xref)
  endif
  while (1) do begin
    if (image lt 0) then begin
      print,'Click timepoint of image. Click right button to stop. '
      if (defined(xi)) then delete,xi
      digxy,xi,yi,/data
      if (not defined(xi)) then break
    endif else begin
      xi =image
    endelse
    ind_image = closeind(t_sig,xi)
    im = reverse(reform(signals[*,*,ind_image]),1)
    if (defined(rel_image)) then begin
      im = im - reverse(reform(signals[*,*,ind_ref]),1)
    endif
    xsave = !x
    ysave = !y
    contour,im,detpos[*,*,0],detpos[*,*,1],/fill,pos = pos_prof,/iso,/noerase,nlev=30
    ;surface,im,detpos[*,*,0],detpos[*,*,1],pos = pos_prof,/noerase,ax=60
    !x=xsave
    !y=ysave


    if (image ge 0) then break
  endwhile
endif


yrange_img = [max(BES_R)+1,min(BES_R)-1]
plot,timerange,yrange_img,/nodata,/noerase,xrange=timerange,xstyle=1,xtitle='Time [s]',$
   yrange=yrange_img,ystyle=1,ytitle='R',xthick=thick,ythick=thick,charthick=thick,charsize=charsize,pos=pos_image,$
   xticks=5,xticklen=-0.03,yticklen=-0.03
loadct,0
otv,reverse(transpose(total(signals,2)),2)/max(total(signals,2))*255,/interp

if (defined(profiles)) then begin
  for i=0,n_prof-1 do begin
    oplot,[profiles[i],profiles[i]],yrange_img,linestyle=i,thick=thick
  endfor
endif



end
