pro integn,data,tau
;integrates signals arranged in an array of n signals each having
; m timepoints  data(m,n)

n=(size(data))(2)
for i=long(0),n-1 do data(*,i)=integ(data(*,i),tau)
end
