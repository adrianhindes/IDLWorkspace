pro default,var,val,nullarray=nullarray,finite=finite_value
  if (not defined(var,nullarray=nullarray)) then var=val
  if (keyword_set(finite_value)) then begin
    if ((where(finite(var) eq 0))[0] ge 0) then var=val
  endif
end
