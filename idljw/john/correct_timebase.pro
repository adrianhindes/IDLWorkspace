function correct_timebase, tb, s

; s are the supplied settings.  These must be supplied by either the CXRS or MSE appropriate call
;
if n_params() ne 2 then begin
  print, 'Must supply tb and settings
  return, -1
end

if in_struct(s,'frame_offset') then begin
  return, ( (s.frame_offset + findgen(n_elements(tb)) )* s.dt + s.t0 )/1000
end else return, tb

end
