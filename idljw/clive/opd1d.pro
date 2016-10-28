pro opd1,xc,yc,d,t=t,f2=f2,d1a=d1a,d1b=d1b,d2=d2,n_o=n_o,n_e=n_e,i=i
x=sqrt(xc^2+yc^2)
w=atan(yc,xc)

;d=t * 


;f2 = 150.e-3

i = x /f2

bigx = (xc+yc)/sqrt(2)


cosw=cos(w)
sinw=sin(w)
sini=sin(i)
ni=1.
;t=  1.e-3


a1=(n_o^2 - n_e^2)/(n_o^2 + n_e^2)
a2=(n_o^2 - n_e^2)/ ((n_o^2 + n_e^2)^(3./2.))
a3=(n_o * n_e)/ ( ((n_o^2 + n_e^2)/2)^(3./2.) )

d1a = t * a1 * (cosw + sinw) * ni * sini 
d1b =  t/sqrt(2) * n_o/n_e * a2 * $
    (cosw^2 - sinw^2) * ni^2 * sini^2 
  d1=d1a+d1b
d2=  sqrt(2) * t * bigx/f2 * (a1 + ni * sini * (a3 - 1/n_o))
d=d1+d2
;stop
end

pro opd2,xc,yc,d,t=t,f2=f2,n_o=n_o,n_e=n_e,i=i,doff=doff
x=sqrt(xc^2+yc^2)
w=atan(yc,xc)

;d=t * 


;f2 = 150.e-3

i = x /f2

cosw=cos(w)
sinw=sin(w)
sini=sin(i)
ni=1.



d = t * (n_e-n_o) * (0 + sini^2 / 2 / n_o * (cosw^2 / n_o - sinw^2 / n_e))
doff=t * (n_e-n_o) 
;stop
end


aw=16.6e-3   ;*105./17. * 25. / 40.*.8
;aw=2.56e-3*2;20e-3
n=30
x1=linspace(-aw/2,aw/2,n)
y1=x1
x2=x1 # replicate(1,n)
y2=replicate(1,n) # y1

;f2=26e-3 & savthick=0.3e-3; full 43 deg

f2=100e-3 
platethick = 0.6e-3 

;opd2,x2,y2,dd,t=platethick,f2=f2,n_o=1.54595,n_e = 1.55512,doff=doff
opd2,x2,y2,dd,t=platethick,f2=f2,n_o=1.54174,n_e = 1.550752,doff=doff

end
