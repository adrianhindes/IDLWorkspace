pro nicenumberinit, n2=n2,n3=n3,n5=n5,n7=n7
common niceblock, nicearr, nicearr2,nicearr3,nicearr5,nicearr7

if n_elements(nicearr) ne 0 then return
default, n2, 10
default, n3, 8
default, n5, 6
default, n7, 4

ntot = n2*n3*n5*n7
nicearr = lonarr(ntot) 
nicearr2 = nicearr
nicearr3 = nicearr
nicearr5 = nicearr
nicearr7 = nicearr

cnt=0
for i2 = 0L,n2-1 do for i3=0l,n3-1 do for i5=0l,n5-1 do for i7=0l,n7-1 do begin
    nicearr(cnt) = 2L^i2 * 3L^i3 * 5L^i5 * 7L^i7
    if nicearr(cnt) le 0 then nicearr(cnt) = 99999999
    nicearr2(cnt) = i2
    nicearr3(cnt) = i3
    nicearr5(cnt) = i5
    nicearr7(cnt) = i7
    cnt=cnt+1
endfor
print, 'largest nice number is ',nicearr(n_elements(nicearr)-1)
end
