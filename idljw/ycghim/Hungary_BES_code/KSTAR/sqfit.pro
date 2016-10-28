function sqfit,x,p
  f=1.3*(exp(-p[0]*(x-2.24))-1)
  return,f
end