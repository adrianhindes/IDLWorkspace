function arrow_bitmap,n,up=up,down=down,left=left,right=right
; Arrow bitmaps for use as bitmap buttons
default,n,16
b=bytarr(n,n)
mask=[1,2,4,8,16,32,64,128]
if (keyword_set(down)) then begin
  for i=0,n-1 do begin
    i1=fix(i/2)
    i2=n-1-i1
    b(i1:i2,i)=1
  endfor
endif 
if (keyword_set(up)) then begin
  for i=0,n-1 do begin
    i1=fix(i/2)
    i2=n-1-i1
    b(i1:i2,n-1-i)=1
  endfor
endif  
if (keyword_set(right)) then begin
  for i=0,n-1 do begin
    i1=fix(i/2)
    i2=n-1-i1
    b(i,i1:i2)=1
  endfor
endif 
if (keyword_set(left)) then begin
  for i=0,n-1 do begin
    i1=fix(i/2)
    i2=n-1-i1
    b(n-1-i,i1:i2)=1
  endfor
endif
b1=bytarr(n/8,n)
for j=0,n-1 do begin
  for i=0,fix(n/8)-1 do begin
    b1(i,j)=total(mask*b(i*8:i*8+7,j))
  endfor
endfor
return,b1
end    
