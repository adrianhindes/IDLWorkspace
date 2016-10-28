; this function returns log of a value with the specified base

function log_any_base, value, base

; log_a(b) = ln(b)/ln(a)

  return, alog(value)/alog(base)


end