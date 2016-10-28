pro make_kstar_rawsignal_movie, shot, timerange=timerange, int=int, waittime=waittime, mpeg_filename=mpeg_filename, filter_order=filter_order, filter_low=filter_low, filter_high=filter_high, plot_ha=plot_ha, nocalib=nocalib, channel=channel
!p.font=-1
default, shot, 9163
default, int, 2
default, waittime, 1
default, mpeg_filename, strtrim(shot,2)+'_'+strtrim(timerange[0],2)+'_'+strtrim(timerange[1],2)+'_movie.mpeg'
default, low_cut, 500
default, plot_ha, 0
default, samplefreq,2e6
default, nlev,60
default, filter_low, 2e3
default, filter_high, 100e3
default, filter_order,100
default, channel, 'BES-2-2'
window, xsize=1024, ysize=768

pos=getcal_kstar_spat(shot)

pos2 = [0.15,0.15,0.5,0.9]

get_rawsignal,shot,'BES-1-1',t2,d2, trange=timerange, errormess=err, nocalib=nocalib
nwin=long(n_elements(t2))
d=fltarr(8,4,nwin)
int=double(int)
nwin2=round(nwin/(samplefreq*int*1e-6))
t=timerange[0]+(findgen(nwin2)+1)*int*1e-6

;Load if measurement is a vertically aligned one or not
vert=0
load_config_parameter, shot, 'Optics', 'APDCAMPosition', output=outp,errormess=e
if (e eq '') then begin
   if double(outp.value) eq 30000 then vert=0
   if double(outp.value) eq 12150 then vert=1
endif else begin
   vert=0
endelse
if keyword_set(vertical) then vert=1
if keyword_set(horizontal) then vert=0

if vert then begin 
   din=fltarr(8,4,nwin2) 
   din2=fltarr(8,4,nwin2)
endif else begin
   din=fltarr(4,8,nwin2)
   din2=fltarr(4,8,nwin2)
endelse

for i=0,7 do begin
   for j=0,3 do begin
      get_rawsignal,shot,'BES-'+strtrim(j+1,2)+'-'+strtrim(i+1,2),t2,d2, timerange=timerange+[0,low_cut*1e-6], errormess=err, nocalib=nocalib
      d3=d2
      for k=0,nwin2-1 do begin
         if vert then begin
            row=i
            column=j
         endif else begin
            row=j
            column=i
         endelse
         din2[row,column,k]=(total(d3[k*(samplefreq*int*1e-6):(k+1)*(samplefreq*int*1e-6)-1])/(samplefreq*int*1e-6))
         d2 = bandpass_filter_data(d2,sampletime=1/samplefreq,filter_low=filter_low,filter_high=filter_high,filter_order=filter_order)
         din[row,column,k]=(total(d2[k*(samplefreq*int*1e-6):(k+1)*(samplefreq*int*1e-6)-1])/(samplefreq*int*1e-6)) ;/mean(d[i,j,*])
      endfor
   endfor
endfor

mpeg_id=mpeg_open([!d.x_vsize,!d.y_vsize],filename=mpeg_filename,quality=100)
c_colors=round(findgen(nlev)/nlev*255)

default,plotrange,[min(din),max(din)]
default,levels,(findgen(nlev))/(nlev)*(plotrange[1]-plotrange[0])+plotrange[0]
setcolor,levels=levels,c_colors=c_colors,scheme=colorscheme
for i=0,7 do begin
endfor
loadct, 5
Device, Decomposed=0
for i=0L,n_elements(t)-1 do begin
   print, double(i)/double(n_elements(t))
   erase
   charsize=1.5
   contour,transpose(reform(din[*,*,i])),pos[0,*,0],pos[*,0,1],xstyle=1,$ ;rscale,zscale
           ytitle='z[mm]',ystyle=1,position=pos2,xtitle="Norm. minor radius",$
           title='Shot: '+strtrim(shot,2)+' t='+strtrim(t[i],2),$
           /noerase,/fill,charsize=charsize,xthick=axisthick,ythick=axisthick,thick=linethick,$
           nlev=nlev,levels=levels,ticklen=-0.025,charthick=axisthick,$
           /isotropic,/downhill
                                ;c_colors=c_colors
   oplot, pos[*,0],pos[*,1], psym=4
   sc=fltarr(2,50)
   scale=findgen(50)/49*(max(din)-min(din))+min(din)
   sc(0,*)=scale
   sc(1,*)=scale
   if vert then ypos=pos2[3] else ypos=pos2[3]/2
   contour,sc,[0,1],scale,levels=levels,nlev=nlev,/fill,$
           position=[pos2[2]+0.04,pos2(1),pos2(2)+0.07,ypos],$
           xstyle=1,xrange=[0,0.9],ystyle=1,yrange=[plotrange(0),plotrange(1)],xticks=1,$
           xtickname=[' ',' '],/noerase,charsize=0.7*charsize,xthick=axisthick,$
           ythick=axisthick,thick=linethick,charthick=axisthick
   im = tvrd(/order,true=1)
   plot, pos[0,*,0], din2[0,*,i], yrange=[0,0.5], xtitle="Radius [mm]", ytitle="Signal [V]", xstyle=1, ystyle=1, title="BES profile",$
         position=[0.75,0.75,0.95,0.9], /noerase,charsize=charsize
   show_rawsignal, 9163, channel, timerange=timerange, position=[0.75,0.45,0.95,0.6], /noerase, /nocalib, int=10, charsize=charsize
   oplot, [t[i],t[i]],[0,1]
   show_rawsignal, 9163, "\POL_HA03", timerange=timerange, position=[0.75,0.15,0.95,0.3], /noerase, charsize=charsize
   oplot, [t[i],t[i]],[0,1e21]
   mpeg_put,mpeg_id,window=!d.window,/order,frame=i

endfor

                                ;save and close the mpeg file
if (defined(mpeg_filename)) then begin
   mpeg_save,mpeg_id,filename=mpeg_filename
   mpeg_close,mpeg_id
endif

end


