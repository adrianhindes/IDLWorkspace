sigma = 1. * 1e6 * 1e-28 ; m^2
mi=1.67e-27 * 4
e=1.6e-19
temp = 15;eV
v=sqrt(2*e*temp/mi)

n_e=1e18 ; m-3

rate = n_e * sigma*v
tau=1/rate
print,tau

kb=1.38e-23
vroom=sqrt(2*kb*300 / mi)
print,'vroom=',vroom

end
