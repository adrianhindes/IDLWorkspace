function logspace, mn, mx, n,double=double
if keyword_set(double) then $
  return, 10.d0^linspace(alog10(mn),alog10(mx),n,/double) $
else $
  return, 10.^linspace(alog10(mn),alog10(mx),n)

end
