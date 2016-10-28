function hatper, th0, thw, ang
ang2=ang+2*!pi
ang3=ang-2*!pi
rval1= ang gt th0-thw/2 and ang lt th0+thw/2
rval2= ang2 gt th0-thw/2 and ang2 lt th0+thw/2
rval3= ang3 gt th0-thw/2 and ang3 lt th0+thw/2
rval=rval1+rval2+rval3
return,rval
end
