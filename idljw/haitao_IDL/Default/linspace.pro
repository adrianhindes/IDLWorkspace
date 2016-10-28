function linspace, mn, mx, n,double=double
if n eq 1 then return, [mn]
if keyword_set(double) then $
  return, dindgen(n)/double(n-1) * (mx-mn) + mn $
else $
  return, findgen(n)/float(n-1) * (mx-mn) + mn
end
