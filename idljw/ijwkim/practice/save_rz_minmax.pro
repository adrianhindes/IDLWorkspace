pro save_rz_minmax
  OPENW, 1, 'save_rz_minmax.txt'
  printf, 1, 'shot# ', 'Rmin  ', 'Rmax  ', 'Zmin  ', 'Zmax'
  for i=9110, 9427 do begin
    a = bes_read_position(i,/ijwkim)
    if (a.err EQ 0) then begin
      if( (abs(min(a.data[*,*,1])) LT 0.05) or (abs(max(a.data[*,*,1])) LT 0.05) ) then begin
        printf, 1, i, min(a.data[*,*,0]), max(a.data[*,*,0]), min(a.data[*,*,1]), max(a.data[*,*,1]), ' in0.05'
        print, 'write'
      endif else begin
        printf, 1, i, min(a.data[*,*,0]), max(a.data[*,*,0]), min(a.data[*,*,1]), max(a.data[*,*,1])
      endelse
    endif
  endfor
  close, 1
  
end
  
