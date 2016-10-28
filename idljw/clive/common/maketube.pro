  pro maketube, st,en,rad,nl,nth2,xln,yln,zln

  lnc=linspacev(st,en,nl)
  lnc3=fltarr(nl,nth2,3)
  for i=0,nth2-1 do lnc3(*,i,*)=lnc
  Bvec=en-st & Bvec=Bvec/norm(Bvec)
  lny=crossp(Bvec,[1,0,0])
  lnx=crossp(Bvec,lny)
  th2=linspace(0,2*!pi,nth2)
  for i=0,nl-1 do for j=0,nth2-1 do lnc3(i,j,*)+=rad *lnx * cos(th2(j)) + rad *lny * sin(th2(j))

;transpose([[B_src+B_vec * 5.],[B_src+B_vec * 10.]])
  xln=lnc3(*,*,0)
  yln=lnc3(*,*,1)
  zln=lnc3(*,*,2)
end
