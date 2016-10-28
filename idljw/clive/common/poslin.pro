pro poslin, n, nx,ny,xsize=xsize,ysize=ysize
default,xsize,4.
default,ysize,3.

alpha=sqrt(float(n)/float(xsize)/float(ysize))
nx=alpha*xsize
ny=alpha*ysize


cand=[ceil(nx)*floor(ny) ,   floor(nx)*ceil(ny),   floor(nx)*floor(ny)]
tst=cand ge n
if tst(2) then nn=[floor(nx),floor(ny)] else $
  if tst(1) and not tst(0) then nn=[floor(nx),ceil(ny)] else $
  if tst(0) and not tst(1) then nn=[ceil(nx),floor(ny)] else $
  if tst(0) and tst(1) then begin
      if xsize ge ysize then nn=[ceil(nx),floor(ny)] else nn=[floor(nx),ceil(ny)]
  endif else $
  nn=[ceil(nx),ceil(ny)]

nx=nn(0)
ny=nn(1)

end


