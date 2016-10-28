function Power,a,b
return,a^b
end

pro solint, B0,Bv, C0, Cv,coord,coordb,a,b
B0x=B0(0)
B0y=B0(1)
B0z=B0(2)

Bvx=Bv(0)
Bvy=Bv(1)
Bvz=Bv(2)

C0x=C0(0)
C0y=C0(1)
C0z=C0(2)

Cvx=Cv(0)
Cvy=Cv(1)
Cvz=Cv(2)


a=$
(-(B0y*Bvy*Power(Cvx,2)) - B0z*Bvz*Power(Cvx,2) + Bvy*C0y*Power(Cvx,2) + $
     Bvz*C0z*Power(Cvx,2) + B0y*Bvx*Cvx*Cvy + B0x*Bvy*Cvx*Cvy - $
     Bvy*C0x*Cvx*Cvy - Bvx*C0y*Cvx*Cvy - B0x*Bvx*Power(Cvy,2) - $
     B0z*Bvz*Power(Cvy,2) + Bvx*C0x*Power(Cvy,2) + Bvz*C0z*Power(Cvy,2) + $
     B0z*Bvx*Cvx*Cvz + B0x*Bvz*Cvx*Cvz - Bvz*C0x*Cvx*Cvz - $
     Bvx*C0z*Cvx*Cvz + B0z*Bvy*Cvy*Cvz + B0y*Bvz*Cvy*Cvz - $
     Bvz*C0y*Cvy*Cvz - Bvy*C0z*Cvy*Cvz - B0x*Bvx*Power(Cvz,2) - $
     B0y*Bvy*Power(Cvz,2) + Bvx*C0x*Power(Cvz,2) + Bvy*C0y*Power(Cvz,2))/$
   (Power(Bvy,2)*Power(Cvx,2) + Power(Bvz,2)*Power(Cvx,2) - $
     2*Bvx*Bvy*Cvx*Cvy + Power(Bvx,2)*Power(Cvy,2) + $
     Power(Bvz,2)*Power(Cvy,2) - 2*Bvx*Bvz*Cvx*Cvz - 2*Bvy*Bvz*Cvy*Cvz + $
     Power(Bvx,2)*Power(Cvz,2) + Power(Bvy,2)*Power(Cvz,2))

b=$
-((B0y*Bvx*Bvy*Cvx - B0x*Power(Bvy,2)*Cvx + B0z*Bvx*Bvz*Cvx - $
       B0x*Power(Bvz,2)*Cvx + Power(Bvy,2)*C0x*Cvx + $
       Power(Bvz,2)*C0x*Cvx - Bvx*Bvy*C0y*Cvx - Bvx*Bvz*C0z*Cvx - $
       B0y*Power(Bvx,2)*Cvy + B0x*Bvx*Bvy*Cvy + B0z*Bvy*Bvz*Cvy - $
       B0y*Power(Bvz,2)*Cvy - Bvx*Bvy*C0x*Cvy + Power(Bvx,2)*C0y*Cvy + $
       Power(Bvz,2)*C0y*Cvy - Bvy*Bvz*C0z*Cvy - B0z*Power(Bvx,2)*Cvz - $
       B0z*Power(Bvy,2)*Cvz + B0x*Bvx*Bvz*Cvz + B0y*Bvy*Bvz*Cvz - $
       Bvx*Bvz*C0x*Cvz - Bvy*Bvz*C0y*Cvz + Power(Bvx,2)*C0z*Cvz + $
       Power(Bvy,2)*C0z*Cvz)/ $
     (Power(Bvy,2)*Power(Cvx,2) + Power(Bvz,2)*Power(Cvx,2) - $
       2*Bvx*Bvy*Cvx*Cvy + Power(Bvx,2)*Power(Cvy,2) + $
       Power(Bvz,2)*Power(Cvy,2) - 2*Bvx*Bvz*Cvx*Cvz - $
       2*Bvy*Bvz*Cvy*Cvz + Power(Bvx,2)*Power(Cvz,2) + $
       Power(Bvy,2)*Power(Cvz,2))) 

coord = C0 + b * Cv
coordb=B0 + a * Bv
sep=coordb-coord
dst=sqrt(total(sep^2))
end

