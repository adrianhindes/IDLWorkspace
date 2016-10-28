function nicenumber2, xp,floor=floor,ceil=ceil,show=show,$
                      forcemultiple=forcemultiple
common niceblock, nicearr, nicearr2,nicearr3,nicearr5,nicearr7
default, forcemultiple, 1
x=floor(xp/forcemultiple)

if keyword_set(floor) then begin
    nx = nicearr-x
    nx(where(nx gt 0)) = -99999999
    dumm = max(nx,idx)
endif else if keyword_set(ceil) then begin
    nx = nicearr-x
    nx(where(nx lt 0)) = 999999999
    dumm = min(nx,idx)
endif else begin
    nx = nicearr-x
    dumm = min(abs(nicearr-x),idx)
endelse

if keyword_set(show) then print,nicearr2(idx),nicearr3(idx),nicearr5(idx),$
  nicearr7(idx),format='("2^",I0," * 3^",I0," * 5^",I0," * 7^",I0)'

return, nicearr(idx)*forcemultiple

end



