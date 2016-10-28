pro click_filter,file

; Digitize a filter transmission curve by clicking on the curve on the image
; Saves the data in a file which can be further processed by write_filter_datafile.pro
; file: Name of image file (jpeg)

  ; Digitizing the tranmission curve of the filter by clikcing on the plot.
  read_jpeg,file,im
  im = float(total(im,1))
  xs = (size(im))[0]
  ys = (size(im))[1]
  plot,[0,xs-1],[0,ys-1],/nodata,xstyle=1,ystyle=1
  otv,(im-min(im))/(max(im)-min(im))*255
  print,'Click on (655,0), (655,100), (668,0) and (668,100) points.'
  digxyadd,xcal,ycal,/data
  if (n_elements(xcal) lt 4) then return
  print, 'Click on a series of points on the curve. Click with right button to stop.'
  digxyadd,xfilt,yfilt,/data
  if (n_elements(xfilt) lt 5) then return
  print,'Enter output filename (xxx.sav):'
  outfile = ''
  read,outfile
  save,xcal,ycal,xfilt,yfilt,file=outfile

end