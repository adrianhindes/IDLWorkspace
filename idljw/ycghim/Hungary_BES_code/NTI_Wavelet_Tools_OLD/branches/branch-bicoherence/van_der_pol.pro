function van_der_pol,t,y
  e=[1,1];[epszilon_1,epszilon_2]
  c=[0.2,0.2];[alpha,beta]
  yp=y
  yp(0)=y[1]
  yp(1)=(e[0]-(y[0]+c[1]*y[2])^2)*y[1]-(y[0]+c[1]*y[2])
  yp(2)=y[3]
  yp(3)=(e[1]-(y[2]+c[0]*y[0])^2)*y[3]-(y[2]+c[0]*y[0])
  return,yp
end