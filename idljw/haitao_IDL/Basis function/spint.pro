function spint, degree,va,knot
if (va lt knot) then value=0 else value=(va-knot)^degree
return, value
stop
end

