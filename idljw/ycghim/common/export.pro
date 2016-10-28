;-------------------------------------------------------------------------
; Procedure: EXPORT (Version 1.00)			R.Martin Jan.2008
;
; Routine for creating BMP/GIF or PNG files. Takes the image from the
; currently active window and tries to convert it to 256 colour
; bitmap+colour table.
;
; If successful writes out either a BMP/GIF or PNG file depending on
; keyword selection. If unable to convert to 256 color bitmap the
; image is stored as a truecolor BMP.
;
; Calling sequence:
;
;   EXPORT, filename {, /gif}, {/png}
;
; 
;
;


pro export, filename, gif=gif, png=png

  if not_string(filename) then begin
    print, 'EXPORT: Error unable filename undefined'
    return
  endif

  bmp=tvrd(true=3)

  color=long(bmp)
  color=ishft(color[*,*,0],16)+ishft(color[*,*,1],8)+color[*,*,2]

  sortcol=sort(color)
  uniqcol=uniq(color, sortcol)
  if (n_elements(uniqcol) le 256) then begin
    r=bmp[*,*,0] & r=r[uniqcol]
    g=bmp[*,*,1] & g=g[uniqcol]
    b=bmp[*,*,2] & b=b[uniqcol]

    bmp=byte(value_locate(color[uniqcol], color))

    option=max([0, keyword_set(png), 2*keyword_set(gif)])
    case option of
      0: write_bmp, filename, bmp, r, g, b
      1: write_png, filename, bmp, r, g, b
      2: write_gif, filename, bmp, r, g, b
    endcase

    return
  endif

  if keyword_set(gif) then begin
    print, 'EXPORT: Error unable to write GIF - Too many colors on plot'
    return
  endif

  if keyword_set(png) then begin
    print, 'EXPORT: Error Unable to write PNG - Too many colors on plot'
    return
  endif

  write_bmp, filename, transpose(bmp, [2,0,1]), /rgb

end
