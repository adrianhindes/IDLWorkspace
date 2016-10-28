pro digxadd,f,data=data,normal=normal,device=device
if ((not keyword_set(data)) and (not keyword_set(normal))$
    and (not keyword_set(device))) then data=1
!ERR=0
while (!ERR ne 4) do begin
  if (keyword_set(data)) then cursor,x,y,4,/data,/down
  if (keyword_set(normal)) then cursor,x,y,4,/normal,/down
  if (keyword_set(device)) then cursor,x,y,4,/device,/down
  if (!ERR eq 4) then return
  if (not defined(f)) then begin
    f=x
  endif else begin
    f=[f,x]
  endelse
  print,'Added:  x='+string(x)
endwhile
end

