function dee,var,fun
sz=size(fun,/dim)
nx=sz(0)
ny=sz(1)
rv=fun*0
if var eq 'x' then begin
for i=0,ny-1 do begin
   rv(*,i)=deriv(fun(*,i))
endfor
endif

if var eq 'y' then begin
for i=0,nx-1 do begin
   rv(i,*)=deriv(fun(i,*))
endfor
endif
return,rv
end



function fofr,r
return, sin(r*!pi)^2 * (r le 1)
;return, sin(r^(1./3.)*!pi)^2 * (r le 1)

end

function gofr,r
return,  (r le 1) ;* cos(r*!pi/2)
end


;nr=100
;r=linspace(0,1,nr)
;plot,r,fofr(r)

;pro do1, rv, arg=arg
;default,arg,0
nx=100
ny=100
x1=linspace(-1,1,nx)
y1=x1
x=x1 # replicate(1,ny)
y=replicate(1,nx) # y1

r=sqrt(x^2+y^2)
th=atan(y,x); + arg
th0=atan(y,x) ;+ arg

inten=gofr(r)

m=1
f=fofr(r) * exp(complex(0,1)*m * th)
fi = total(f,2)

dfdx=dee('x',f)
dfdy=dee('y',f)


vx=-dfdy
vy=dfdx

plot_field,float(vx)*inten,float(vy)*inten

myplot_field,float(vx),float(vy),title='v r',pos=posarr(4,2,0)
myplot_field,imaginary(vx),imaginary(vy),title='v i',pos=posarr(/next),/noer
f2=f*exp(complex(0,1)*(0.)*!pi/2)
;vx2=vx * f2
;vy2=vy * f2
vx2=complex(float(vx) * float(f2),imaginary(vx) * imaginary(f2))
vy2=complex(float(vy) * float(f2),imaginary(vy) * imaginary(f2))
;vx2=
;vy2=imaginary(vy) * imaginary(f2)
imgplot,float(f2),title='f2 r',pos=posarr(/next),/noer
imgplot,imaginary(f2),title=' i f2',pos=posarr(/next),/noer


myplot_field,float(vx2),float(vy2),title='v2 r',pos=posarr(/next),/noer
myplot_field,imaginary(vx2),imaginary(vy2),title='v2 i',pos=posarr(/next),/noer

;stop

vi=total(vy*inten,2)

vi2=total(vy2,2)
plot,vi2,pos=posarr(/next),title='vi2',/noer
oplot,imaginary(vi2),col=2
plot,vi,pos=posarr(/next),title='vi',/noer
oplot,imaginary(vi),col=2
stop
;; equilibrium floc contrib

vep = fofr(r)
vex=vep * sin(th0)
vey=-vep * cos(th0)
plot_field,vex*f,vey*f
stop
vei = total(vey * f,2)
plot,vei

rv=vei
;imgplot,imaginary(f),/cb,pal=-2

end

;do1,a
;do1,b,arg=!pi
;plot,a,yr=minmax([a,b])
;oplot,b,col=2
;end

