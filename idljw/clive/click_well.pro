;pro click, file
;fn='~/magwell_kh0.72_large';Filter_type_4'
fn='~/iotabar_kh0.72_large'
window,0,xsize=1100,ysize=800
read_png,fn+'.png',pic,ct,colors=256



;r,g,b,/verbose)
;stop
;r=ct(*,0)
;g=ct(*,1)
;b=ct(*,2)
;tvlct, r, g, b

d1=n_elements(pic(0,*,0))
d2=n_elements(pic(0,0,*))

fc=0.35
pic0=pic
pic=congrid(pic,4,d1*fc,d2*fc)
tv,pic,true=1
stop
vx0=0. & vy0=0. & vx1 = 0. & vy1= 0.
read, 'value of x0 :',vx0
read, 'value of x1 :',vx1

;stop
!mouse.button = 1

parr=fltarr(10000,2)
np=0
tek_color
while !mouse.button ne 4 do begin
    cursor, dx, dy,/device,/down
    parr(np,*) = [dx,dy]
    if np gt 0 then plots, parr([np-1,np],0), parr([np-1,np],1),color=2,/device,thick=2
    np=np+1
endwhile

print, 'click on bl (x0,y0) axis'
cursor, x0, y0,/down,/device
print, 'click on br (x1,y0) axis'
cursor, x1, dy,/down,/device
print, 'click on tl (x0,y1) axis'
cursor, dx, y1,/down,/device

read, 'value of y0 :',vy0
read, 'value of y1 :',vy1

x=float(parr(0:np-1,0)-x0) * float(vx1-vx0)/float(x1-x0) + vx0
y=float(parr(0:np-1,1)-y0) * float(vy1-vy0)/float(y1-y0) + vy0

idx=sort(x)
x=x(idx)
y=y(idx)

plot, x, y,psym=2
temp=x
ratio=y
;save,temp,ratio,file='~/ma_te.sav',/verb
save,x,y,file=fn+'.sav',/verb
end





