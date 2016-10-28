pro plot_2d_lightprofile, shot=shot, timerange=timerange, nocalibrate=nocalibrate, ps=ps
!p.font=2
default, ps, 1
default, shot, 9411
default, timerange, [1.59,1.6]
default, nocalibrate, 1
data=dblarr(9,5)
for i=1,4 do begin
  for j=1,8 do begin
    get_rawsignal, 9411, 'BES-'+strtrim(i,2)+'-'+strtrim(j,2),t,d,timerange=timerange,nocalib=nocalibrate
    data[j,i]=mean(d)
  endfor
endfor

if keyword_set(ps) then hardon, /color
device, decomposed=0
title='Light profile of '+strtrim(shot,2)+' at ['+strtrim(timerange[0],2)+'s,'+strtrim(timerange[1],2)+'s]'
contour, data, nlevels=21, /fill, xtitle='Radial index', ytitle='Vertical index', title=title, xrange=[8,1], yrange=[1,4],$
         xticks=7, yticks=3, ystyle=1, xstyle=1, charsize=2, thick=3

if keyword_set(ps) then hardfile, strtrim(shot,2)+'_lightprofile.ps'
stop
end