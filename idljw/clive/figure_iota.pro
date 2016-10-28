function splines,x,y,t
idx=sort(x)
xs=x(idx)
ys=y(idx)
return,spline(xs,ys,t)
end

mkfig,'~/iota.eps',xsize=8.5,ysize=7,font_size=10
d=(read_ascii('~/w7-x.txt',data_start=1)).(0)
x=linspace(0,1,100)
y0=splines(d(0,*),d(1,*),x)

a=[y0(0),y0(n_elements(y0)-1)]
;Std         0.86   1.00
;cmichael@prl25:~$ Low iota 0.74     0.83
;cmichael@prl25:~$ High iota  1.01   1.2

b1=[.86,1]
b2=[.74,.83]
b3=[1.01,1.2]
l0=a(0) + ((a(1)-a(0)) )* x


l1=b1(0) + (b1(1)-b1(0)) * x
l2=b2(0) + (b2(1)-b2(0)) * x
l3=b3(0) + (b3(1)-b3(0)) * x


y1=y0 / l0 * l1

y2=y0 / l0 * l2
y3=y0 / l0 * l3

;stop
plot,x,y1,yr=[0.4,1.5],xtitle='normalized radius',ytitle='rotational transform',/nodata


oplot,x,y1,col=2,thick=3

oplot,x,y2,col=2,thick=3
oplot,x,y3,col=2,thick=3


d2=(read_ascii('~/lhd.txt',data_start=1)).(0)
oplot,x,splines(d2(0,*),d2(1,*),x),col=4,thick=3



d3=(read_ascii('~/h1a.txt',data_start=1)).(0)
oplot,x,splines(d3(0,*),d3(1,*),x),col=3,thick=3

d4=(read_ascii('~/h1b.txt',data_start=1)).(0)
oplot,x,splines(d4(0,*),d4(1,*),x),col=3,thick=3

d5=(read_ascii('~/h1c.txt',data_start=1)).(0)
oplot,x,splines(d5(0,*),d5(1,*),x),col=3,thick=3

rv=[[1,2],$
    [5,6],$
    [1,1],$
    [5,4],$
    [4,3]]

m=rv(0,*)
n=rv(1,*)
r=float(m)/float(n)

nn=n_elements(r)
for i=0,nn-1 do begin
   oplot,!x.crange,r(i)*[1,1],linesty=2
;   xyouts,0.05,r(i)+0.05,string(m(i),n(i),format='(I0,"/",I0)')
   xyouts,1.0,r(i)-0.03,string(m(i),n(i),format='(I0,"/",I0)')
endfor

xyouts,0.5,0.6,'LHD'
xyouts,0.5,0.9,'W7-X'
xyouts,0.5,1.2,'H-1'
endfig,/gs,/jp
end

;Std         0.86   1.00
;cmichael@prl25:~$ Low iota 0.74     0.83
;cmichael@prl25:~$ High iota  1.01   1.2


