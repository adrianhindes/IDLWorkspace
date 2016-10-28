pro barmtf, sizmm, ang,ssin=ssin


nx=!d.x_size
ny=!d.y_size

x1=findgen(nx)
y1=findgen(ny)
x=x1 # replicate(1,ny)
y=replicate(1,nx) # y1

ang=ang*!dtor
psiz= 350. /1280
tperiod = sizmm / psiz
print,'orig tperiod=',tperiod
tperiod = fix(tperiod/2.) * 2.
print,'rounded tperiod=',tperiod
t=x * cos(ang) + y * sin(ang)
loadct,0

za=cos(2*!pi*t / tperiod)
z = (za ge 0) * 255
t=t+10000.
zb = t mod tperiod
zc=(zb ge 0 and zb lt tperiod/2)
z=zc*255

if keyword_set(ssin) then z = (za/2. + 0.5) * 255.
tv,z

end




