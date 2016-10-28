
pro digxyadd,fx,fy,data=data,device=device,normal=normal
!ERR=0
while (!ERR ne 4) do begin
  if (keyword_set(device)) then cursor,x,y,4,/device,/down
  if (keyword_set(data)) then cursor,x,y,4,/data,/down  
  if (keyword_set(normal)) then cursor,x,y,4,/normal,/down  
  if (!ERR eq 4) then return
  if (not keyword_set(fx)) then begin
    fx=x
  endif else begin 
    fx=[fx,x]
  endelse  
  if (not keyword_set(fy)) then begin
    fy=y
  endif else begin 
    fy=[fy,y]
  endelse  
  print,'Added:  x='+string(x)+'  y='+string(y)
endwhile
end


