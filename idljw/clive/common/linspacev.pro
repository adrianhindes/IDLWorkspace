function linspacev, mn, mx, n,double=double
ny=n_elements(mn)

rv=fltarr(n,ny)
for i=0,ny-1 do rv(*,i)=linspace(mn(i),mx(i),n)
  return, rv
end
