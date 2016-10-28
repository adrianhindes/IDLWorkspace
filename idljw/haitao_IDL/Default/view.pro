function vfunction, x
p1=[700*cos(!pi/6), 700*sin(!pi/6),201.545]
p2=[700*cos(!pi/10), 700*sin(!pi/10),137.0]
p3=[700*cos(!pi/6)+35*sin(!pi/6), 700*sin(!pi/6)+35*cos(!pi/6),201.545]
p4=[1000*cos(!pi/6), 1000*sin(!pi/6),107.8]
o=[-1870.405,893.52,252.757]

p11=[-130.0,-21.0]
p22=[22.0,5.0]
p33=[-74.0,-33.0]
p44=[-7.0,-222.0]
p11=sqrt(total(p11^2))*16*1e-3
p22=sqrt(total(p22^2))*16*1e-3
p33=sqrt(total(p33^2))*16*1e-3
p44=sqrt(total(p44^2))*16*1e-3
;p11=sqrt(2)/2
;p22=sqrt(2)/2
;p33=sqrt(2)/2
;p44=sqrt(2)/2
op1=p1-o
op2=p2-o
op3=p3-o
op4=p4-o

p=[[op1],[op2],[op3],[op4]]
;p=[[-50.0,-0.5,-0.5],[-50.0,0.5,-0.5],[-50.0,0.5,0.5],[-50.0,-0.5,0.5]]

return, [p(0,0)*x(0)+p(1,0)*x(1)+p(2,0)*x(2)-sqrt(total(p(*,0)^2))*sqrt(total(x(0:2)^2))*cos(atan(p11/x(3))),p(0,1)*x(0)+p(1,1)*x(1)+p(2,1)*x(2)-sqrt(total(p(*,1)^2))*sqrt(total(x(0:2)^2))*cos(atan(p22/x(3))),$
p(0,2)*x(0)+p(1,2)*x(1)+p(2,2)*x(2)-sqrt(total(p(*,2)^2))*sqrt(total(x(0:2)^2))*cos(atan(p33/x(3))),p(0,3)*x(0)+p(1,3)*x(1)+p(2,3)*x(2)-sqrt(total(p(*,3)^2))*sqrt(total(x(0:2)^2))*cos(atan(p44/x(3)))]
end





pro view 
fil='C:\haitao\papers\study topics\H-1 projection\data and results\plasma data\data 11-12-2013\backlight-4-12-2013.SPE'
read_spe, fil, lam, t,d,texp=texp,str=str,fac=fac & d=float(d)
g=image(d, axis_style=1,rgb_table=1,max_value=2500,min_value=500)
x=[-1000*cos(!pi/6),1000*sin(!pi/6), 0.0,60.0]
;x=[1.0,0,0,49.6]
result=BROYDEN(x,'vfunction',/double)
result(0:2)=abs(result(0:2))/sqrt(total(result(0:2)^2))
stop
end
