function minmax2,x
ift=where(finite(x) eq 1)
if ift(0) eq -1 then return,-1
return,minmax(x(ift))
end
