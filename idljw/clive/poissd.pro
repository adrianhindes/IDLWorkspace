function poissd, k, lam=lam
kd=double(k)
lamd=double(lam)
rv=lam^k * exp(-lam) / factorial(k)
return,rv
end
