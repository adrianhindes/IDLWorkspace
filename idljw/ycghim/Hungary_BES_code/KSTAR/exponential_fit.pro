function exponential_fit, x1, p
  f=p[0]*exp(-p[1]*(x1-1.8))
  return, f
end