function nonans,x
idx=where(finite(x) eq 0)
y=x
if idx(0) ne -1 then y(idx)=0.
return,y
end
