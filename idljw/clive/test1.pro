;chisquared test

function f,a,b,x,y
f= a*x + b*y
return,f

end


function csq,da,db
common cb, a, b,x,y

csq=(f(a+da,b+db,x,y)-f(a,b,x,y))^2

return,csq
end

common cb, a, b,x,y


a=1
b=1

x=1
y=1
f=1
mat=[[2*csq(f,0),csq(f,f)-csq(f,0)-csq(0,f)],[csq(f,f)-csq(0,f)-csq(f,0),2*csq(0,f)]]
;print,csq(0.1,0.)

;print,csq(0.1,0.1)


;print,csq(0.,0.1)
end




