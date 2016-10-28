pro show_ecei_bes_correlation_map,shot,time,silent=silent,rrange=rrange,zrange=zrange,isotropic=isotropic,$
       thick=thick,charsize=charsize,nolegend=nolegend,noerase=noerase,nlevels=nlevels,zoom=zoom,ecei_frame=ecei_frame,$
       refchannel=refchannel
;******************************************************************************
;* show_ece_bes_correlation_map_.pro                 S. Zoletnik  14.2.2012   *
;******************************************************************************
;*
;*
;*  INPUT:
;*    shot: Shot number
;*    time: Time for EFIT reconstruction. The closes available time will be used.
;*    zoom: Zoom factors for ECEi HFS, LFS system.
;*    /silent: Don't print error messages.
;*    rrange: R range for plot
;*    zrange: z range of plot
;*    /isotropic: Use identical scales for plotting R and Z (this is the default.)
;*    nlevels: Number of levels for contour plot
;***********************************************************************************
default,refchannel,'BES-2-2'
default,isotropic,1
default,nlevels,30
default,rrange,[1.2,2.5]
default,zrange,[-1.1,1.1]
default,zoom,[1.23,1.26]  ; ECEi zoom factor [HFS, LFS]
;1.23; % for HFS system shot 6123, 6056, 6057
;1.26; % for LFS system shot 6123, 6056, 6057
default,hfs_freq,[2.5, 3.4, 4.3, 5.2, 6.1, 7.1, 8.0, 8.9] + 90.25      ;[GHz]
default,lfs_freq,[2.5, 3.4, 4.3, 5.2, 6.1, 7.1, 8.0, 8.9] + 83.00

  device, decomposed=0
flux = get_kstar_efit(shot,time,errormess=errormess,/silent)
if (errormess ne '') then begin
  if (not keyword_set(silent)) then print,errormess
  return
endif
     rrange=[1.95,2.4]
     zrange=[-0.3,0.3]
if (not keyword_set(noerase) and not keyword_set(over)) then erase
if (not keyword_set(nolegend) and not keyword_set(over)) then time_legend,'show_ecei_bes_correlation_map.pro'
if (not keyword_set(over)) then begin
  contour,flux.psi,flux.r,flux.z,xrange=rrange,xstyle=1,xtitle='R [m]',nlevels=nlevels,$
     yrange=zrange,ystyle=1,ytitle='Z [m]',isotropic=isotropic,thick=thick,xthick=thick,$
     ythick=thick,charthick=thick,charsize=charsize,/noerase,title=i2str(shot)+'  '+string(time,format='(F5.2)')+'s',/nodata

endif

xpos_hfs = findgen(24,8,2)
ypos_hfs = findgen(24,8,2)
xpos_lfs = findgen(24,8,2)
ypos_lfs = findgen(24,8,2)
spot_size = 1.4
for i=0,7 do begin
  ypos_hfs[*,i,0] = ((findgen(24)+0.5)-12.5)*spot_size*zoom[0]/100
  ypos_hfs[*,i,1] = ((findgen(24)+1.5)-12.5)*spot_size*zoom[0]/100
endfor
for i=0,7 do begin
  ypos_lfs[*,i,0] = ((findgen(24)+0.5)-12.5)*spot_size*zoom[1]/100
  ypos_lfs[*,i,1] = ((findgen(24)+1.5)-12.5)*spot_size*zoom[1]/100
endfor
ind_0 = closeind(flux.z,0)
bfield0=reform(sqrt(flux.b_t[*,ind_0]^2+flux.b_z[*,ind_0]^2+flux.b_r[*,ind_0]^2))
harmonic = 2
fc = 1.6e-19*bfield0/9.1e-31/2/!pi*harmonic
hfs_r = reverse(interpol(flux.r,fc/1e9,hfs_freq))
hfs_r1 = hfs_r
hfs_r2 = hfs_r
dr = (hfs_r[1:7]-hfs_r[0:6])/2
hfs_r1[0:6] = hfs_r1[0:6]-dr
hfs_r1[7] = hfs_r1[7]-dr[6]
hfs_r2[0:6] = hfs_r2[0:6]+dr
hfs_r2[7] = hfs_r2[7]+dr[6]
lfs_r = reverse(interpol(flux.r,fc/1e9,lfs_freq))
lfs_r1 = lfs_r
lfs_r2 = lfs_r
dr = (lfs_r[1:7]-lfs_r[0:6])/2
lfs_r1[0:6] = lfs_r1[0:6]-dr
lfs_r1[7] = lfs_r1[7]-dr[6]
lfs_r2[0:6] = lfs_r2[0:6]+dr
lfs_r2[7] = lfs_r2[7]+dr[6]

for i=0,23 do begin
  xpos_hfs[i,*,0] = hfs_r1
  xpos_hfs[i,*,1] = hfs_r2
  xpos_lfs[i,*,0] = lfs_r1
  xpos_lfs[i,*,1] = lfs_r2
endfor
loadct, 0
color=0
for i=0,7 do begin
  for j=0,23 do begin
    polyfill,[xpos_hfs[j,i,0],xpos_hfs[j,i,1],xpos_hfs[j,i,1],xpos_hfs[j,i,0]],$
             [ypos_hfs[j,i,0],ypos_hfs[j,i,0],ypos_hfs[j,i,1],ypos_hfs[j,i,1]],/data,color=color
    if (keyword_set(ecei_frame)) then begin
     plots, [xpos_hfs[j,i,0],xpos_hfs[j,i,1],xpos_hfs[j,i,1],xpos_hfs[j,i,0],xpos_hfs[j,i,0]],$
             [ypos_hfs[j,i,0],ypos_hfs[j,i,0],ypos_hfs[j,i,1],ypos_hfs[j,i,1],ypos_hfs[j,i,0]],thick=thick
    endif
  endfor
endfor
for i=0,7 do begin
  for j=0,23 do begin
    polyfill,[xpos_lfs[j,i,0],xpos_lfs[j,i,1],xpos_lfs[j,i,1],xpos_lfs[j,i,0]],$
             [ypos_lfs[j,i,0],ypos_lfs[j,i,0],ypos_lfs[j,i,1],ypos_lfs[j,i,1]],/data,color=color
    if (keyword_set(ecei_frame)) then begin
      plots,[xpos_lfs[j,i,0],xpos_lfs[j,i,1],xpos_lfs[j,i,1],xpos_lfs[j,i,0],xpos_lfs[j,i,0]],$
             [ypos_lfs[j,i,0],ypos_lfs[j,i,0],ypos_lfs[j,i,1],ypos_lfs[j,i,1],ypos_lfs[j,i,0]],thick=thick
    endif
 endfor
endfor

contour,flux.psi,flux.r,flux.z,nlevels=nlevels,thick=thick,/noerase,/over



loadct,3
default,nblock,2
default,ncol,16
default,nrow,24
default, nlev,51
default,savefile,'show_all_kstar_ecei_power_'+refchannel+'.sav'
restore, 'tmp/'+savefile
device, decomposed=0
numdat=n_elements(c_matrix[0,0,0,*])
maxcorr=dblarr(nblock,nrow*ncol/2)
pos_c=dblarr(nblock,nrow*ncol/2,2)
help, maxcorr
twin=57
for iblock=0,nblock-1 do begin
  for irow=0,nrow-1 do begin
    for icol=0,ncol-1 do begin
    
      if (nblock ne 1) then column = icol mod (ncol/2) else column = icol
        numdat=n_elements(c_matrix[0,0,0,*])
        c_matrix2=dblarr(nblock,ncol/2,nrow,2*numdat)
        c_matrix2[*,*,*,0:numdat-1]=c_matrix
        c_matrix2[*,*,*,numdat:2*numdat-1]=c_matrix
        twin=100
        
        in2=25
        for idata=0,numdat+in2 do begin
          c_matrix2[iblock,column,irow,idata]-=mean(c_matrix2[iblock,column,irow,idata:idata+in2])
        endfor
        
      maxcorr[iblock,irow*ncol/2+column]=max(reform(c_matrix2[iblock,column,irow,where(tauscale gt -twin and tauscale lt twin)]))
      
                       
      ;maxcorr[iblock,ncol/2*irow+column]=max(reform(c_matrix[iblock,column,irow,*]))
      if iblock eq 0 then begin
        pos_c[iblock,ncol/2*irow+column,0]=(xpos_hfs[irow,column,0]+xpos_hfs[irow,column,1])/2 ;xhfs
        pos_c[iblock,ncol/2*irow+column,1]=(ypos_hfs[irow,column,0]+ypos_hfs[irow,column,1])/2 ;yhfs
      endif else begin
        pos_c[iblock,ncol/2*irow+column,0]=(xpos_lfs[irow,column,0]+xpos_lfs[irow,column,1])/2 ;xhfs
        pos_c[iblock,ncol/2*irow+column,1]=(ypos_lfs[irow,column,0]+ypos_lfs[irow,column,1])/2 ;yhfs
      endelse
    endfor
  endfor
  num=iblock[0]
  default,plotrange,[min(maxcorr),max(maxcorr)]
  default,levels,(findgen(nlev))/(nlev)*(plotrange[1]-plotrange[0])+plotrange[0]
      
  contour,maxcorr[iblock,*],reform(pos_c[iblock,*,0]),reform(pos_c[iblock,*,1]), /noerase, fill=1, nlev=nlev,$
  levels=levels, /irregular, /overplot
  
endfor
show_kstar_bes_flux,shot,time,phi=-!pi/2,turns=-1,silent=silent,thick=thick,/noerase,/over, offset=[-50,60]
;show_kstar_bes_flux,shot,time,phi=-!pi/2,turns=1,silent=silent,thick=thick,/noerase,/over
;COLORBAR, NCOLORS=255, POSITION=[0.15, 0.85, 0.95, 0.90]



end