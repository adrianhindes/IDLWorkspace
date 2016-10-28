pro digxy,fx,fy,data=data,device=device,normal=normal
!ERR=0
if (keyword_set(device)) then cursor,x,y,4,/device,/down
if (keyword_set(data)) then cursor,x,y,4,/data,/down  
if (keyword_set(normal)) then cursor,x,y,4,/normal,/down  
if (!ERR eq 4) then return
fx=x
fy=y
print,'Pointed at:  x='+string(x)+'  y='+string(y)
return
end
