pro bes_save_position

  for shot = 10500L, 12000-1 do begin
    shotnumber_str = STRCOMPRESS(STRING(shot, format='(i0)'), /rem)
    file_exist = file_test('/home/ijwkim/Research/KSTAR/BES/spatial_info/'+shotnumber_str+'.spat.cal')
    if (file_exist EQ 1) then begin
      d = bes_read_position(shot,/plot)
      filename = FILEPATH(shotnumber_str + '_image.png', ROOT_DIR = '/home/ijwkim/Research/KSTAR/BES/spatial_info_image')
      write_png, filename, TVRD()
    endif
  endfor
end