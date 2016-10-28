function closeind,arr,val
; Returns the i index where arr(i) is the closest to val

d=abs(arr-val)
return,(where(min(d) eq d))(0)
end
