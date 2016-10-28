function rms_norm, approx, actual
  n = n_elements(approx)

  diffs = (double(approx - actual))^2

  approx_range = max(approx)-min(approx)

  errorval = sqrt((total(diffs))/float(n))

  normalized = errorval/float(approx_range)
  
  return, normalized


end