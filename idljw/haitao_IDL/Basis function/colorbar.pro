pro colorbartest

; Example function to plot with 

; a range of [0,100].

d = DIST(41)

fmax = 100.0

f = d / max(d) * fmax

 

; Set 11 contour levels: 

; [0, 10, 20, ... 100].

n_levels = 11

levels = FINDGEN(n_levels)/(n_levels-1)*fmax

 

; Make a step color table for the 

; contour plot. The color table 

; 'step_ct' is a [256,3] array, but 

; there are only 11 distinct colors. 

; The indices into the color tables 

; (both original and step) are contour 

; levels interpolated to the range 

; of color table indices (the byte

; range).

ct_number = 4

ct_indices = BYTSCL(levels)

LOADCT, ct_number, RGB_TABLE=ct, /SILENT

step_ct = CONGRID(ct[ct_indices, *], 256, 3)

 

; Display the example function using 

; the step color table and the

; interpolated indices.

c1 = CONTOUR(f, $

 c_value = levels, $

  RGB_TABLE = step_ct, $

  RGB_INDICES = ct_indices, $

  /FILL, $

  MARGIN = [0.15, 0.20, 0.15, 0.15], $

  TITLE = 'Max = ' + strtrim(fmax,2), $

  WINDOW_TITLE = 'Discrete Colorbar Example')

 

; The colorbar needs n_levels+1 ticks to make 

; labels line up correctly.

; Append empty string.

tick_labels = [STRTRIM(FIX(levels), 2), '']
cb = COLORBAR( $,

  TARGET = c1, $

  TICKLEN = 0, $

  MAJOR = n_levels+1, $

  TICKNAME = tick_labels, $

  FONT_SIZE = 10, $

  POSITION = [0.2, 0.07, 0.8, 0.1])

stop
end