function capf, a, b, d

tmptop = b^2 + a^2 - d^2 + sqrt( (b^2 + a^2 - d^2)^2 - 4 * a^2 * b^2 )
tmpbot = 2*a*b
tmp = tmptop/tmpbot
res = 1./ 2. / alog(tmp)
return,res
stop
end
print,capf(1e-4,1e-3,0)
print,capf(1e-4,1e-3,8e-4)
end
