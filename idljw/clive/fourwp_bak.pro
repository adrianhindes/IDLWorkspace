function fourwp, r,d,k,kvecxy=kvecxy
Pi=!pi

mat0=        [[Sqrt(2*Pi),0,0,0],[0,Sqrt(2*Pi)*Cos(2*r)^2,Sqrt(Pi/2.)*Sin(4*r),0], [0,Sqrt(Pi/2.)*Sin(4*r),Sqrt(2*Pi)*Sin(2*r)^2,0],[0,0,0,0]]

matp= [[0,0,0,0],[0,Sqrt(Pi/2.)*Sin(2*r)^2,-(Sqrt(Pi/2.)*Sin(4*r))/2.,Complex(0,1)*Sqrt(2*Pi)*Cos(r)*Sin(r)],$
   [0,-(Sqrt(Pi/2.)*Sin(4*r))/2.,Sqrt(Pi/2.)*Cos(2*r)^2,Complex(0,-1)*Sqrt(Pi/2.)*Cos(2*r)],$
   [0,Complex(0,-1)*Sqrt(2*Pi)*Cos(r)*Sin(r),Complex(0,1)*Sqrt(Pi/2.)*Cos(2*r),Sqrt(Pi/2.)]]*exp(complex(0,1)*d)

matn=[[0,0,0,0],[0,Sqrt(Pi/2.)*Sin(2*r)^2,-(Sqrt(Pi/2.)*Sin(4*r))/2.,Complex(0,-1)*Sqrt(2*Pi)*Cos(r)*Sin(r)],$
   [0,-(Sqrt(Pi/2.)*Sin(4*r))/2.,Sqrt(Pi/2.)*Cos(2*r)^2,Complex(0,1)*Sqrt(Pi/2.)*Cos(2*r)],$
   [0,Complex(0,1)*Sqrt(2*Pi)*Cos(r)*Sin(r),Complex(0,-1)*Sqrt(Pi/2.)*Cos(2*r),Sqrt(Pi/2.)]]*exp(-complex(0,1)*d)
kvec=[0,1,-1]*k
kvecx=kvec * cos(r)
kvecy=kvec * sin(r)
kvecxy=transpose([[kvecx],[kvecy]])
tens=complexarr(4,4,3)
tens(*,*,0)=mat0
tens(*,*,1)=matp
tens(*,*,2)=matn
return,tens
end

function tcontract,tens1,tens2
sz1=size(tens1,/dim)
sz2=size(tens2,/dim) ; tens2 must be 4x4x3
nd2=n_elements(sz2)
; contract 2ndt index of 1 with 1st index of 2
szout=[sz1,3]
tout=complexarr(szout)
if nd2 eq 3 then $
for i=0,3 do for j=0,3 do for k1=0,2 do for k2=0,2 do begin
    tout(i,j,k1,k2)=total(tens1(i,*,k1)*tens2(*,j,k2))
endfor
if nd2 eq 4 then $
for i=0,3 do for j=0,3 do for k1=0,2 do for k2=0,2 do for k3=0,2 do begin
    tout(i,j,k1,k2,k3)=total(tens1(i,*,k1,k2)*tens2(*,j,k3))
endfor
if nd2 eq 5 then $
for i=0,3 do for j=0,3 do for k1=0,2 do for k2=0,2 do for k3=0,2 do for k4=0,2 do begin
    tout(i,j,k1,k2,k3,k4)=total(tens1(i,*,k1,k2,k3)*tens2(*,j,k4))
endfor
return,tout
end

function kouter,kay1,kay2
sz1=size(kay1,/dim) ; k1 2x3x3x3... etc
sz2=size(kay2,/dim) ; k2 must be 2x3
nd2=n_elements(sz2)

szout=[sz1,3]
kout=fltarr(szout)
if nd2 eq 2 then $
for i=0,1 do for k1=0,2 do for k2=0,2 do begin
    kout(i,k1,k2)=kay1(i,k1)+kay2(i,k2)
endfor

if nd2 eq 3 then $
for i=0,1 do for k1=0,2 do for k2=0,2 do for k3=0,2 do begin
    kout(i,k1,k2,k3)=kay1(i,k1,k2)+kay2(i,k3)
endfor

if nd2 eq 4 then $
for i=0,1 do for k1=0,2 do for k2=0,2 do for k3=0,2 do for k4=0,2 do begin
    kout(i,k1,k2,k3,k4)=kay1(i,k1,k2,k3)+kay2(i,k4)
endfor



return,kout
end


;test
tens1=fourwp(0,0.,1,kvecxy=kvec1)
tens2=fourwp(!pi/4*1.,0.,1/sqrt(2),kvecxy=kvec2)
tens3=fourwp(!pi/4+!pi/2,0.,1/sqrt(2)*0.8,kvecxy=kvec3)
tout=tcontract(tens1,tens2)
kout=kouter(kvec1,kvec2)

tout2=tcontract(tout,tens3)
kout2=kouter(kout,kvec3)
plot,kout2(0,*,*,*),kout2(1,*,*,*),/iso,psym=4

end
