function teststr,x
data={test:dcomplex(x*findgen(10),(x-1)*findgen(10))}
return, data
stop
end