pro make_2D_mpeg,shot,timerange=timerange,plotrange=plotrange,waittime=waittime,thick=thick,$
    mpeg_filename=mpeg_filename,nlev=nlev, int=int, deadpix=deadpix, bgsub=bgsub, user=user,$
    xyz=xyz, dim1=dim1, channel=channel, twin=twin,shiftrate=shiftrate, rot=rot_deg

default,shot,6078
default,colorscheme,'blue-white-red'
default,nlev,60
default,charsize,1
default,thick,1
default,waittime,1
default,timerange,[5,5.002]
default,contour,1
default,fill,1
default,int,1000
default,samplefreq,2d6
;default,user,'lampee'
default,xyz,0
default,dim1,0



;if (user eq 'lampee') then cd, 'D:\KFKI\Measurements\KSTAR\Measurement'

if not defined(deadpix) then begin
  deadpix=intarr(4,8)
  deadpix[1,6]=1
endif
if not (keyword_set(dim1)) then begin
  default,mpeg_filename, dir_f_name('plots','mpeg_'+strtrim(shot,2)+'_'+strtrim(timerange[0],2)+'_'+strtrim(timerange[1],2)+'.mpg')
  pos2 = [0.15,0.15,0.85,0.9]
  linethick=thick
  axisthick=thick
  rscale = (findgen(8)-6)*1.3
  zscale = findgen(4)*1.3

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


  if keyword_set(bgsub) then begin
    print, 'Please click the time interval on the plot for the background subtraction!'
    show_rawsignal,shot,'BES-1-1'
    cursor,t1_cor,y,/down
    cursor,t2_cor,y,/down
    if (t1_cor ge t2_cor) then begin
      temp=t1_cor
      t1_cor=t2_cor
      t2_cor=temp
    endif
    bgcor=dblarr(8,4)
    for i=0,7 do begin
      for j=0,3 do begin
        get_rawsignal,shot,'BES-'+strtrim(j+1,2)+'-'+strtrim(i+1,2),t,d, trange=[t1_cor,t2_cor], errormess=err
        bgcor[i,j]=mean(d)
      endfor
    endfor
  endif

  ;get the raw data from .dat files

  get_rawsignal,shot,'BES-1-1',t2,d2, trange=timerange, errormess=err
  nwin=long(n_elements(t2))
  print, nwin
  t=t2
  d=fltarr(8,4,nwin)
  int=double(int)
  nwin2=round(nwin/(samplefreq*int*1e-6))
  din=fltarr(8,4,nwin2)
  int=int*1e-6
;din=fltarr(8,4,nwin)
  for i=0,7 do begin
    for j=0,3 do begin
      get_rawsignal,shot,'BES-'+strtrim(j+1,2)+'-'+strtrim(i+1,2),t2,d2, trange=timerange, errormess=err
      if (keyword_set(bgsub)) then begin
;        din[i,j,*] = integ(d2-bgcor[i,j],t,int*1e-6)
        d[i,j,*]=d2-bgcor[i,j]
      endif else begin
;        din[i,j,*] = integ(d2,t,int*1e-6)
        d[i,j,*]=d2
      endelse
      for k=1,nwin2-1 do begin
        ;din[i,j,*]=interpol(d[i,j,*],nwin/20)
        din[i,j,k]=(total(d[i,j,k*(samplefreq*int):(k+1)*(samplefreq*int)-1])/(samplefreq*int)) ;/mean(d[i,j,*])
      endfor
    endfor
  endfor
;  t_resamp=t

  t=interpol(t,nwin2)
  ;creating mpeg file
  mpeg_id=mpeg_open([!d.x_vsize,!d.y_vsize],filename=mpeg_filename,quality=100)
  c_colors=round(findgen(nlev)/nlev*255)

  ;Dead pixel handling
  ind=where(deadpix eq 1)
  ind2=array_indices(deadpix,ind)
  if n_elements(ind2) eq 2 then begin
    temp=ind2
    ind2=intarr(2,1)
    ind2[*,0]=temp
  endif
  print, ind2

  if (ind[0] ne -1) then begin
    for l=0,n_elements(ind2)/2-1 do begin
      din[ind2[1,l],ind2[0,l],*]=0
      case ind2[0,l] of
        0:c=0
        3:d=0
        else: begin
                   c=-1
                   d=1
                   break
                 end
      endcase
      case ind2[1,l] of
        0:a=0
        7:b=0
        else: begin
                   a=-1
                   b=-1
                   break
                 end
      endcase
      k=0.
      for i=a,b do begin
        for j=c,d do begin
          din[ind2[1,l],ind2[0,l],*]+=din[ind2[1,l]+i,ind2[0,l]+j,*]
          k+=1.
        endfor
      endfor
      din[ind2[1,l],ind2[0,l],*]/=k
    endfor
  endif
  pos=dblarr(32,2)
  din2=dblarr(32,nwin2)
  ;din2=dblarr(32,nwin)
  for i=0,7 do begin
    for j=0,3 do begin
      if keyword_set(xyz) then begin
        detpos[i,j,*]=xyztocyl(detpos[i,j,*],/inv)
        pos[j*8+i,0]=detpos[i,j,0]
        pos[j*8+i,1]=detpos[i,j,2]
        title='x [mm]'
      endif else begin
        pos[j*8+i,0]=detpos[i,j,0]
        pos[j*8+i,1]=detpos[i,j,1]
        title='R [mm]'
      endelse
      din2[j*8+i,*]=din[i,j,*]
    endfor
  endfor
  default,plotrange,[min(din2),max(din2)]
  default,levels,(findgen(nlev))/(nlev)*(plotrange[1]-plotrange[0])+plotrange[0]
  setcolor,levels=levels,c_colors=c_colors,scheme=colorscheme

  loadct, 5
  Device, Decomposed=0
  for i=0L,n_elements(t)-1 do begin
    print, double(i)/double(n_elements(t))
    erase
    if (keyword_set(contour)) then begin
      contour,din2[*,i],pos[*,0],pos[*,1],xrange=[min(pos[*,0]),max(pos[*,0])],xtitle=title,xstyle=1,$ ;rscale,zscale
              yrange=[min(pos[*,1]),max(pos[*,1])],ytitle='z[mm]',ystyle=1,$
              title='Shot: '+strtrim(shot,2)+' t='+strtrim(t[i],2),$
              /noerase,fill=fill,charsize=charsize,xthick=axisthick,ythick=axisthick,thick=linethick,$
              nlev=nlev,levels=levels,ticklen=-0.025,charthick=axisthick,$
              /isotropic,/downhill,/irregular,$
              position=pos2-[0,0,0.1,0]
              ;c_colors=c_colors
        oplot, pos[*,0],pos[*,1], psym=4
        if (keyword_set(fill) and not keyword_set(noscale)) then begin
          sc=fltarr(2,50)
          scale=findgen(50)/49*(max(din2)-min(din2))+min(din2)
          sc(0,*)=scale
          sc(1,*)=scale
          contour,sc,[0,1],scale,levels=levels,nlev=nlev,/fill,$
                  position=[pos2(2)-0.03,pos2(1),pos2(2),pos2(3)],$
                  xstyle=1,xrange=[0,0.9],ystyle=1,yrange=[plotrange(0),plotrange(1)],xticks=1,$
                  xtickname=[' ',' '],/noerase,charsize=0.7*charsize,xthick=axisthick,$
                  ythick=axisthick,thick=linethick,charthick=axisthick
          pos2 = [0.15,0.15,0.85,0.9]
          for k=0,n_elements(ind2)/2-1 do begin
            xyouts,0.15,0.9-k*0.02,'Bad pix: BES-'+strtrim(ind2[0,k]+1,2)+'-'+strtrim(ind2[1,k]+1,2),/normal,$
                   size=0.8
          endfor
        endif

      if (defined(mpeg_filename)) then begin
        im = tvrd(/order,true=1)
        mpeg_put,mpeg_id,window=!d.window,/order,frame=i
      endif
      ;if (i ne n_elements(tau)-1) then wait,waittime
    endif
  endfor

  ;save and close the mpeg file
  if (defined(mpeg_filename)) then begin
    mpeg_save,mpeg_id,filename=mpeg_filename
    mpeg_close,mpeg_id
  endif
endif else begin
  ;1 dimension movie of one channel
  ;for i=0,10000 do begin & show_rawsignal, 6123, 'BES-1-4', trange=[2.4+i/1d5,2.401+i/1d5], inttime=5, yrange=[0.1,0.25] & wait,0.05& endfor
  default,mpeg_filename, dir_f_name('plots','mpeg_'+strtrim(shot,2)+'_'+strtrim(timerange[0],2)+'_'+strtrim(timerange[1],2)+'_1D_'+strtrim(channel,2)+'.mpg')
  default,twin,1e-3
  default,channel,''
  default,shiftrate,1
  pos2 = [0.15,0.15,0.85,0.9]
  linethick=thick
  axisthick=thick

  mpeg_frame_rate=25 ;frame=sec
  if (defined(dim1) and channel eq '') then begin
    print, 'Dim1 is set, please write the channel number "BES-<row>-<column>"'
    read,'',channel
  endif
  mpeg_id=mpeg_open([!d.x_vsize,!d.y_vsize],filename=mpeg_filename,quality=100)
  Device, Decomposed=0
  get_rawsignal,shot,channel,t,d,trange=timerange, nocalibrate=0
  yrange=[min(d)*0.9,max(d)*1.11]
  for i=0L,round((timerange[1]-timerange[0])/twin*shiftrate*mpeg_frame_rate)-1 do begin
    print, double(i)/round((timerange[1]-timerange[0])/twin*shiftrate*mpeg_frame_rate)
    trange=[timerange[0]+i*twin/(shiftrate*mpeg_frame_rate),timerange[0]+twin+i*twin/(shiftrate*mpeg_frame_rate)]

    ;show_rawsignal,shot,channel,trange=trange,int=int*1d6, yrange=yrange, nocalibrate=0,$
    ;               ystyle=1
    get_rawsignal,shot,channel,t,d,trange=trange, nocalibrate=0
;    nwin=long(n_elements(t))
;    n_resamp=round(nwin/(samplefreq*int))
;    d_resamp=dblarr(n_resamp)
;    print, n_elements(d)
;    print, n_resamp*samplefreq*int
;    print, trange[1]-trange[0]
;    for j=0L, n_resamp-1 do begin
;      d_resamp[i]=(total(d[i*(samplefreq*int):(i+1)*(samplefreq*int)-1])/(samplefreq*int))
;    endfor
;    t_resamp=interpol(t,n_resamp)

    if (int ne 0) then begin
      d_resamp = integ(d,t,int*1e-6)
    endif
    t_resamp=t
    plot,t_resamp,d_resamp, xtitle='Time [s]',xstyle=1,yrange=yrange,ytitle='Voltage [V]',ystyle=1,$
              title='Shot: '+strtrim(shot,2)+' t='+strtrim(t[i],2)+' Channel: '+channel,$
              xthick=axisthick,ythick=axisthick,thick=linethick,ticklen=-0.025,$
              charthick=axisthick, position=pos2-[0,0,0.1,0], /noerase
    if (defined(mpeg_filename)) then begin
      im = tvrd(/order,true=1)
      mpeg_put,mpeg_id,window=!d.window,/order,frame=i
    endif
    erase
  endfor
  mpeg_save,mpeg_id,filename=mpeg_filename
  mpeg_close,mpeg_id
endelse

end