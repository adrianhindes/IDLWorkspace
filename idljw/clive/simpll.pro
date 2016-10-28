pro mixit, f2,lock
tmax=10
n=1024
t=linspace(0,tmax,n)
f=10.
s_sin=cos(2*!pi*f*t)
s_hat=s_sin gt 0

s2_sin=cos(2*!pi*f2*t)
s2_hat=s2_sin gt 0

plot,t,s_hat,pos=posarr(1,2,0)

oplot,t,s2_hat,col=2
mix=s_hat xor s2_hat
mix2=smooth(mix*1.0,100)
plot,t,mix,pos=posarr(/next),/noer
oplot,t,mix2,col=2
lock=mean(mix*1.0)
print,'mean lock=',lock
end

farr=linspace(9.95,10.05,100)
larr=farr*0
for i=0,99 do begin
f=farr(i)
mixit, f,lock
larr(i)=lock
endfor



end

