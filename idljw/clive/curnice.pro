pro curnice
while 1 do begin
cursor,dx,dy,/down
print,round(dx),format='(I0,",$")'
if !mouse.button eq 4 then break
end
end
