pro  zeeman_structure, S,L,J,S1,L1,J1

if s ne s1 or abs(L1-L) gt 2 or  abs(J1-J) gt 2 or J lt abs(L-s)or J gt abs(L+s)or J1 lt abs(L1-S1)or J1 gt abs(L1+S1) then begin
print, 'transiton forbidden'
return
end

constant=1

if J1 eq J-1 then begin
  mj=findgen(2*j+1)-j
  mj1=findgen(2*j1+1)-j1
  line_number=3*J1
  
  for i=0, 2*j do begin
    for k=0,2*j1 do begin
      if mj1(k)-mj(i) eq 0 then begin 
        print, 'J:',j, '   M:', mj(i), '   to', '   J1:' ,j1, '   M1:',mj1(k), '   !pi component', '       re_intensity:',4*constant*(j+mj(i))*(j-mj(i))
        end 
       if mj1(k)-mj(i) eq 1 then begin  
       print, 'J:',j, '   M:', mj(i), '   to', '   J1:' ,j1, '   M1:',mj1(k), '   sigma + component','   re_intensity:',constant*(j-mj(i)-1)*(j-mj(i))
       end
      if mj1(k)-mj(i) eq -1 then begin   
       print, 'J:',j, '   M:', mj(i), '   to', '   J1:' ,j1, '   M1:',mj1(k), '   sigma - component','   re_intensity:',constant*(j+mj(i)-1)*(j+mj(i))
       end
       endfor
 endfor
 
 end
  
if J1 eq J then begin
  mj=findgen(2*j+1)-j
  mj1=findgen(2*j1+1)-j1
  line_number=3*J1-1
  
  for i=0, 2*j do begin
    for k=0,2*j1 do begin
      if mj1(k)-mj(i) eq 0 and mj(i)ne 0 then begin 
        print, 'J:',j, '   M:', mj(i), '   to', '   J1:' ,j1, '   M1:',mj1(k), '   !pi component', '       re_intensity:',4*constant*mj(i)^2
        end 
       if mj1(k)-mj(i) eq 1 then begin  
       print, 'J:',j, '   M:', mj(i), '   to', '   J1:' ,j1, '   M1:',mj1(k), '   sigma + component','   re_intensity:',constant*(j+mj(i)+1)*(j-mj(i))
       end
      if mj1(k)-mj(i) eq -1 then begin   
       print, 'J:',j, '   M:', mj(i), '   to', '   J1:' ,j1, '   M1:',mj1(k), '   sigma - component','   re_intensity:',constant*(j-mj(i)-1)*(j+mj(i))
       end
       endfor
 endfor
 
 end  
 
if J1 eq J+1 then begin
  mj=findgen(2*j+1)-j
  mj1=findgen(2*j1+1)-j1
  line_number=3*J
  
  for i=0, 2*j do begin
    for k=0,2*j1 do begin
      if mj1(k)-mj(i) eq 0 then begin 
        print, 'J:',j, '   M:', mj(i), '   to', '   J1:' ,j1, '   M1:',mj1(k), '   !pi component', '       re_intensity:',4*constant*(j1+mj1(k))*(j1-mj1(k))
        end 
       if mj1(k)-mj(i) eq 1 then begin  
       print, 'J:',j, '   M:', mj(i), '   to', '   J1:' ,j1, '   M1:',mj1(k), '   sigma + component','   re_intensity:',constant*(j1+mj1(k)-1)*(j1+mj1(k))
       end
      if mj1(k)-mj(i) eq -1 then begin   
       print, 'J:',j, '   M:', mj(i), '   to', '   J1:' ,j1, '   M1:',mj1(k), '   sigma - component','   re_intensity:',constant*(j1-mj1(k)-1)*(j1-mj1(k))
       end
       endfor
 endfor
 
 end  
  
  
  
  

    
stop
end