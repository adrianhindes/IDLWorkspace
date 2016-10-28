
;_____________________________________________________________________________
function adaptive_median, vector, nmedian=nmedian, nstddev=nstddev
  default, nstddev, 4
  default, nmedian, 3
  v_new = vector
  v_med = median(v_new, nmedian)
  d = v_new-v_med
  replace = where(abs(d) gt nstddev*stddev(d))
  if replace[0] ne -1 then v_new[replace] = v_med[replace]
  return, v_new
end
