function cotran,p
; coordinates transform, data from shaun
;common kpts,k1,k2,k3,k4
;common kpts1,k1,k2,k3,k4,k5
;common kpts3,k1,k2,k3,k4,k5,k6
;k1=p(0)
;k2=p(1)
;k3=p(2)
;k4=p(3)
;k5=p(4)
;k6=p(5)

;if ((k1 eq k2) or (k1 eq k3) or (k1 eq k4) or (k2 eq k3) or (k3 eq k4)) then stop
filx='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\coordinate\for_haitao_realspace_x.csv'
dx=read_ascii(filx, delim=' ')
dx=dx.FIELD001
fily='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\coordinate\for_haitao_realspace_y.csv'
dy=read_ascii(fily, delim=' ')
dy=dy.FIELD001
filz='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\coordinate\for_haitao_realspace_z.csv'
dz=read_ascii(filz, delim=' ')
dz=dz.FIELD001


fils='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\coordinate\for_haitao_boozer_s.csv'
ds=read_ascii(fils, delim=' ')
ds=ds.FIELD001
filth='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\coordinate\for_haitao_boozer_theta.csv'
dth=read_ascii(filth, delim=' ')
dth=dth.FIELD001
filph='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\coordinate\for_haitao_boozer_phi.csv'
dph=read_ascii(filph, delim=' ')
dph=dph.FIELD001

n=200
varia=findgen(n)*1.0/n
integral=make_array(5,171,/float)
for i=0,170 do begin
     for j=0,4 do begin
  mda=splin(n,p)
  mda1=interpol(mda(*,j),varia,ds(*,i))
  integral(j,i)=total(mda1)
endfor
endfor
LA_svd, integral, w,u,v
index=where(w gt 1)
w1=w(index)
conn=max(w1)/min(w1)
return, conn
end
Result  = AMOEBA(1.0e-5, function_name='cotran',SCALE=1.0, P0 = [0.0,0.2, 0.4,0.6,0.8,1.0], FUNCTION_VALUE=fval) ; 6 knot points
stop
 save, result, fval, filename='Optimum knots for 6 knots.save'
 intd7=interpol(result, findgen(4)+1,(findgen(5)+1)*4.0/5.0)
Result1  = AMOEBA(1.0e-5, function_name='cotran',SCALE=1.0, P0 = intd7, FUNCTION_VALUE=fval) ; 7 knot points
 save, result, fval, filename='Optimum knots for 7 knots.save'
 intd8=interpol(result, findgen(5)+1,(findgen(6)+1)*5.0/6.0)

print, 'knot points :', Result
print, 'Condition number :',fval(0)
stop
end

