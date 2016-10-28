pro nti_wavelet_plot_1d, xaxis, data, error = error, xdouble = xdouble, ydouble = ydouble, xrange = xrange, yrange = yrange, $
  title = title, xtitle = xtitle, ytitle = ytitle, psym = psym, $
  name = name, info = info, legend = legend
  
;Calculate number of vectors
;---------------------------
numofvec = n_elements(data(*,0))

;Setting defaults
;----------------
nti_wavelet_default, xaxis, findgen(n_elements(data(0,*)))
nti_wavelet_default, name, '1D_plot'
nti_wavelet_default, info, ''
nti_wavelet_default, legend, pg_num2str(findgen(numofvec), length = 1)

;Setting path and name
;---------------------
date = systime()
;date = nti_wavelet_i2str(date[0])+'-'+nti_wavelet_i2str(date[1])+'-'+nti_wavelet_i2str(date[2])
path='./save_data/'
file_mkdir, path

;Setting printing parameters
;---------------------------
colors = {value:intarr(8), name:strarr(8)}
colors.value = [0, 255, 64, 160, 208, 228, 25, 112]
colors.name = ['black', 'red', 'blue', 'green', 'yellow', 'orange', 'purple', 'cyan']

pg_initgraph, /print
loadct, 13
!P.FONT=0
device, bits_per_pixel = 8, font_size = 8, /portrait, /color, /cmyk
device, filename = pg_filename(name, dir = path, ext = '.ps')

;Printing
;--------
plot, xaxis, data(0,*), xrange = xrange, yrange = yrange, color = colors.value(0), $
  title = title, xtitle = xtitle, ytitle = ytitle, psym = psym, $
  thick = 2, charsize = 2, xthick = 3, ythick = 3, charthick = 3, xstyle = 1, ystyle = 1, xmargin = [10,16], ymargin = [5,3]
if nti_wavelet_defined(error) then begin
  oplot, xaxis, data(0,*) - error(0,*), color = colors.value(0), /linestyle
  oplot, xaxis, data(0,*) + error(0,*), color = colors.value(0), /linestyle
endif
if nti_wavelet_defined(xdouble) then begin
  oplot, xdouble, ydouble(0,*), color = colors.value(0), /linestyle, psym = psym
endif
for i = 1,numofvec-1 do begin
  oplot, xaxis, data(i,*), thick = 2, color = colors.value(i mod 8), psym = psym
  if nti_wavelet_defined(error) then begin
    oplot, xaxis, data(i,*) - error(i,*), color = colors.value(i mod 8), /linestyle
    oplot, xaxis, data(i,*) + error(i,*), color = colors.value(i mod 8), /linestyle
  endif
  if nti_wavelet_defined(xdouble) then begin
    oplot, xdouble, ydouble(i,*), color = colors.value(i mod 8), /linestyle, psym = psym
  endif
endfor

;Plot xyouts
;-----------
xyouts, 0.83, 0.10, date + '!C' + info, /normal, orientation = 90, charsize = 1.4, charthick = 1.8

;Plot legends
;------------
xylegend = legend(0) + ': ' + colors.name(0)
for i = 1,numofvec-1 do begin
  xylegend = xylegend + '!C' + legend(i) + ': ' + colors.name(i mod 8)
endfor
xyouts, 0.78, 0.80, xylegend, /normal, orientation = 0, charsize = 1.4, charthick = 1.8

;Restore printing parameters
device, /close
!P.FONT = -1
pg_initgraph

end