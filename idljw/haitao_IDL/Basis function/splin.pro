function splin,r, n,knots

;n=100
varia=findgen(n)*r/(n-1)
; to find the most suitable knots number
;knots=findgen(11)*0.1
;knots=[0.0,0.3,0.5,0.6,0.85,1.0]
;common kpts,k1,k2,k3,k4
;common kpts1,k1,k2,k3,k4,k5
;common kpts3,k1,k2,k3,k4,k5,k6
;knots=[0.0,k1,k2,k3,k4,k5,k6,1.0]

;weights=replicate(1.0,n_elements(knots)-1)
;weights=randomu(50,10)
weights=[0.5,0.4,0.35,0.3,0.3,0.4,0.45,0.5,0.55,0.5]
weights=weights/total(weights)
;zero order function
data0=make_array(n,n_elements(knots)-1,/float)
for i=0, n_elements(knots)-2 do begin
  for j=0,n-1 do begin
    if ((varia(j)ge knots(i)) and (varia(j) lt knots(i+1)))then data0(j,i)=1.0 else data0(j,i)=0.0
    endfor
    endfor

; 1 order funtion
order=1
data1=make_array(n,n_elements(knots)-1,/float)
for i=0, n_elements(knots)-order-2 do begin
  for j=0,n-1 do begin
    data1(*,i)=(varia-knots(i))/(knots(i+1)-knots(i))*data0(*,i)+(knots(i+1+1)-varia)/(knots(i+1+1)-knots(i+1))*data0(*,i+1)
    endfor
    endfor

; 2 order funtion
order=2
data2=make_array(n,n_elements(knots)-1,/float)
for i=0, n_elements(knots)-order-2 do begin
  for j=0,n-1 do begin
    data2(*,i)=(varia-knots(i))/(knots(i+order)-knots(i))*data1(*,i)+(knots(i+order+1)-varia)/(knots(i+order+1)-knots(i+1))*data1(*,i+1)
    endfor
    endfor
     
;3 order function
order=3
data3=make_array(n,n_elements(knots)-1,/float)
for i=0, n_elements(knots)-order-2 do begin
  for j=0,n-1 do begin
    data3(*,i)=(varia-knots(i))/(knots(i+order)-knots(i))*data2(*,i)+(knots(i+order+1)-varia)/(knots(i+order+1)-knots(i+1))*data2(*,i+1)
    endfor
    endfor
    
;datad=make_array(100,10,/float)
;for i=0,n_elements(knots)-1 do begin
  ;datad(*,i)=data0(*,i)*weights(i)
  ;endfor
   
 spfuc={order0:data0,order1:data1,order2:data2,order3:data3}
 return,spfuc
stop  
end 
 
  
  

