pro dssimp,r,ds,en=en
kbpars2,isource=0,us=x,vs=y,alpha=th

nl=100
l=linspace(100,400,nl)
pb= [x,y,0]##replicate(1,nl) + [cos(th),sin(th),0]##l 

r=sqrt(pb(*,0)^2 + pb(*,1)^2)


detp=[-98.2,257.,28.] ; m port

vec2=  detp(0:2)##replicate(1,nl)
vec=pb-vec2

vecnorm=(replicate(1,3)##sqrt(total(vec^2,2)))
vec=vec/vecnorm

v0=[cos(th),sin(th),0] 
v02=v0 ## replicate(1,nl)
ang = acos(total(v02 * vec,2))*!radeg

mi=1.67e-27
echarge=1.6e-19
default,en,90
kev=1000

vel=sqrt(2*echarge*en*kev/(mi*2)) ; deuterium primary
clight=3e8
vc=vel/clight
l0=656.1
ds=l0 *(1+ vc * cos(ang*!dtor))
;plot,r,ds




;plot,r,ang

end
