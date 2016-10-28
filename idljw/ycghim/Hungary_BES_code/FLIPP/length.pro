function length, input
n=n_elements(input)
length=0
for i=0,n-1 do length+=input[i]^2
return, sqrt(length)
end