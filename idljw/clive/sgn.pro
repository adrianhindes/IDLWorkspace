function sgn, x
idx=where(x ne 0)
rv=x*0.+1
if idx(0) ne -1 then rv(idx)=abs(x(idx))/x(idx)
return,rv
end
