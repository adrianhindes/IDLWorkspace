function rw

  c=1.0
  n=32
  phi=double(0)
  dphi=0.512*sqrt(3)*c*randomn(seed,n,/normal,/double)
  x=double(0)
  y=double(0)
  for j=0L,long(n-1) do begin
    phi=phi+dphi[j]
    x=x+cos(phi)
    y=y+sin(phi)
  endfor
  rl=sqrt(x^2+y^2)/double(n)
  return,rl
end