pro plot_2D_radial_dist,shot,line,timerange=timerange, average=average,$
                        postscript=postscript, bgsub=bgsub, int=int,$
                        trange_bg=trange_bg, colortable=colortable,$
                        nlev=nlev, charsize=ch, thick=thick

;********************************************************
;*                   plot_2D_radial_dist                *
;********************************************************
;* Plot the radial distribution of the BES for a given  *
;* shot for a given line for a given timerange          *
;********************************************************
;*INPUTs:                                               *
;*        shot: number of the shot                      *
;*        line: number of the line to plot              *
;*        timerange: the time range of the plot [t1,t2] *
;*        average: average the 4 lines of the BES       *
;*        postscript: write a postscript file           *
;*        bgsub: background subtraction                 *
;********************************************************
;*OUTPUTs:                                              *
;*         plot: either postscript or IDL window        *
;********************************************************

default, shot,6123
default, line, 4
default, timerange, [3,3.5]
default, average, 0
default, postscript, 0
default, int,1
default, samplefreq,2d6
default, ch,1
default, fill,1
default, nlev,21
default, thick,1
axisthick=thick
linethick=thick
default, axisthick, 1
default, linethick, 1
default, colortable,5
if not defined(deadpix) then begin 
  deadpix=intarr(4,8)
  deadpix[1,6]=1
endif

if keyword_set(bgsub) then begin
  if not defined(trange_bg) then begin
    print, 'Please click the time interval on the plot for the background subtraction!'
    show_rawsignal,shot,'BES-1-1'
    cursor,t1_cor,y,/down
    cursor,t2_cor,y,/down
    print,t1_cor, t2_cor
  endif else begin
    t1_cor=trange_bg[0]
    t2_cor=trange_bg[1]
  endelse
  if (t1_cor ge t2_cor) then begin
    temp=t1_cor
    t1_cor=t2_cor
    t2_cor=temp
  endif
  bgcor=dblarr(4,8)
  for j=0,7 do begin
    for i=0,3 do begin
      get_rawsignal,shot,'BES-'+strtrim(i+1,2)+'-'+strtrim(j+1,2),t,d, trange=[t1_cor,t2_cor], errormess=err
      bgcor[i,j]=mean(d)
    endfor
  endfor
endif

get_rawsignal,shot,'BES-1-1',t2,d2,timerange=timerange
nwin=long(n_elements(t2))
if not (keyword_set(average)) then begin
  dataarr=dblarr(nwin,8)
  
  for i=0,7 do begin
    get_rawsignal,shot,'BES-'+strtrim(line,2)+'-'+strtrim(i+1,2),t,d,timerange=timerange
    if (keyword_set(bgsub)) then begin
;      dataarr[*,i]=d-bgcor[line-1,i] 
      dataarr[*,i]=integ(d-bgcor[line-1,i],t,int*1e-6)
    endif else begin
;      dataarr[*,i]=d
      dataarr[*,i]=integ(d,t,int*1e-6)
    endelse
  endfor
  ind=where(deadpix eq 1)
  ind2=array_indices(deadpix,ind)
    
  if (ind[0] ne -1 and ind2[0] eq line-1) then begin
    if n_elements(a) gt 1 then begin
      print, 'More than 1 pixel is dead. Please choose another line. Returning...'
      return
    endif
    if (ind2[1] eq 0) then dataarr[*,0]=dataarr[*,1]
    if (ind2[1] eq 7) then dataarr[*,7]=dataarr[*,6]
    if (ind2[1] gt 0 and ind2[1] lt 7) then dataarr[*,ind2[1]]=(dataarr[*,ind2[1]-1]+dataarr[*,ind2[1]+1])/2.
  endif
endif else begin

  t=t2
  dz=fltarr(8,4,nwin)
  dataarr=dblarr(nwin,8)
  
;din=fltarr(8,4,nwin)
  for i=0,7 do begin
    for j=0,3 do begin
      get_rawsignal,shot,'BES-'+strtrim(j+1,2)+'-'+strtrim(i+1,2),t2,d2, trange=timerange, errormess=err
      if (keyword_set(bgsub)) then begin
        dz[i,j,*] = integ(d2-bgcor[i,j],t,int*1e-6)
;        dz[i,j,*]=d2-bgcor[j,i]
      endif else begin
        dz[i,j,*] = integ(d2,t,int*1e-6)
;        dz[i,j,*]=d2
      endelse
    endfor
  endfor
  
  ;Dead pixel handling
  ind=where(deadpix eq 1)
  ind2=array_indices(deadpix,ind)
  if n_elements(ind2) eq 2 then begin
    temp=ind2
    ind2=intarr(2,1)
    ind2[*,0]=temp
  endif
    
  if (ind[0] ne -1) then begin
    for l=0,n_elements(ind2)/2-1 do begin
      dz[ind2[1,l],ind2[0,l],*]=0
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
          dz[ind2[1,l],ind2[0,l],*]+=dz[ind2[1,l]+i,ind2[0,l]+j,*]
          k+=1.
        endfor
      endfor
      dz[ind2[1,l],ind2[0,l],*]/=k
    endfor
  endif
    for i=0,7 do begin
      for j=0,3 do begin
        if (keyword_set(bgsub)) then dataarr[*,i]+=(dz[i,j,*]-bgcor[j,i])/4. else dataarr[*,i]+=d[i,j,*]/4.
      endfor
    endfor
endelse

if (keyword_set(postscript)) then begin
  hardon,/color
  set_plot_style,'foile_eps_kg'
endif
  detpos=getcal_kstar_spat(shot)
  default,plotrange,[min(dataarr),max(dataarr)]
  default,levels,(findgen(nlev))/(nlev)*(plotrange[1]-plotrange[0])+plotrange[0]
  loadct,colortable

  detpos_2=dblarr(8)
  detpos_2[*]=detpos[line-1,*,0]
  a=dblarr(nwin*8,3)
  for i=0l,nwin-1 do begin
    for j=0l,7 do begin
      a[8*i+j,0]=dataarr[i,j]
      a[8*i+j,1]=t[i]
      a[8*i+j,2]=detpos[line-1,j,0]
    endfor
  endfor
  
  contour,a[*,0],a[*,1],a[*,2],xrange=[min(t),max(t)],xtitle='t[s]',xstyle=1,$
          yrange=[min(detpos_2[line-1,*,0]),max(detpos_2[line-1,*,0])],ytitle='R[mm]',ystyle=1,$
          title='Shot:'+strtrim(shot,2)+' BES-'+strtrim(line,2)+'-*',fill=fill, charsize=ch, nlev=nlev, levels=levels,$
          /irregular, xthick=axisthick,ythick=axisthick,thick=linethick
  time_legend, 'plot_2d_radial_dist'
if (keyword_set(postscript)) then hardfile, strtrim(shot,2)+'_'+strtrim(timerange[0],2)+'_'+strtrim(timerange[1],2)+'_radial_con.ps'
end