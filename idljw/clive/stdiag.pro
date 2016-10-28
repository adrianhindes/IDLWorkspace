function sawteeth,t
s=t mod 1
return,s
end

t=linspace(0,5,501)
y1=sawteeth(t)
y2=sawteeth(2*t)*1.25-0.25
y=[y1,y2]

a=mean(y1)
b=mean(y2)
z=[a*replicate(1,501),b*replicate(1,501)]

mkfig,'~/stcartoon.eps',xsize=14,ysize=9,font_size=10 & !p.thick=3
plot,y,xsty=4,ysty=4
oplot,z,col=2
endfig,/gs,/jp
!p.thick=0
end

