@getpts
;; this is a script file to do hidden line removal.  it runs a as a
;; "main program" calling some other routines.  So start reading from
;; the main program at the bottom of the file.

pro filltri,trg
; this fills the z buffer with triangles define by the simple array
; trg(num of points in triangle (3), coorinate points (x,y,z) (3))

common czb, x2,y2,x1,y1,zb ; this is a common block containing the z buffer and coordinate axes of it

; solve these equations to generate the coefficient array abc
; (containing a,b,c) from the equation ax + by + c = z for points p1
; (x1,y1,z1), p2 and p3:: This is a matrix equation with is solved
; using invert(mat)...
p1=trg(*,0)
p2=trg(*,1)
p3=trg(*,2)
mat=[[p1(0),p1(1),1],$
     [p2(0),p2(1),1],$
     [p3(0),p3(1),1]]

abc=invert(mat) ## [p1(2),p2(2),p3(2)]
;print, p1(0) * abc(0) + p1(1) * abc(1) + abc(2)

; determine X,Y extents of the triangle:
xr=minmax(trg(0,*))
yr=minmax(trg(1,*))
; convert these to indexes in the z buffer array and calc nx,ny as the
; number of points in thex/y directions of  zbuffer over which the
; triangle covers:
iu=value_locate(x1,xr) & nx=iu(1)-iu(0)+1
ju=value_locate(y1,yr) & ny=ju(1)-ju(0)+1
;zz=fltarr(nx,ny)
; sub index the x2,y2 zbuffer 2d poition arrays to only the ones whic
; are of interest:
xx=x2(iu(0):iu(1),ju(0):ju(1))
yy=y2(iu(0):iu(1),ju(0):ju(1))

; calculate the z position for this part of the z buffer
zz=abc(0) * xx + abc(1) * yy + abc(2)

; detirmine which points within this "rectangular" region of interest
; are actually within the insdie of the triangle 
crit=fltarr(nx,ny,3)
for j=0,2 do begin
; jp is j+1 mod 3
    jp=(j+1) mod 3
    v=[trg(0:1,jp)-trg(0:1,j),0] ; v is vector on side of triangle
    nm=crossp(v,[0,0,1]) ; nm is normal to v
   
    xmp0=xx-trg(0,j) 
    xmp1=yy-trg(1,j)
    tmp=(xmp0 * nm(0) + xmp1 * nm(1) ) ; calculate distance for all points xx,yy from line v (signed)
    crit(*,*,j)=tmp ge 0 ; and take the ones which are positive
endfor
tot=product(crit,3) ; multiply the crit for each 3 sides and where they are 1, accept
zb0=zb(iu(0):iu(1),ju(0):ju(1)) ; subscript the rectangle
zbt=zb0
ix=where(tot) ; find ones to apply
if ix(0) ne -1 then zbt(ix)=zz(ix)
cond=zbt le zb0 ; use z buffer condition :: update z buffer only if new z < old z
ip=where(cond)
if ip(0) ne -1 then zb0(ip)=zbt(ip)

zb(iu(0):iu(1),ju(0):ju(1))=zb0 ; now replace this rectangle with the processed one.

end
pro transc, fcb,view
;; this transforms the array fcb (3,indexinface(from 0 to
;; 2),indexofface) according to line of sight or perhaps the other way around

; define observer: angle, major radius r, hieght z, yaw, p0 as the
; position, pitch and roll which define the dip of the axes.
; xhat,yhat,zhat define the direction vectors of the line of sight so
; that zhat is the line of sight [at the middle] and xhat and y hat
; are the directions of the camera image.  so that p0,xhat,yhat,zhat
; define completely this.


ang=view.tor*!dtor;-165.5*!dtor;43.25*!dtor ; minus 1 for some reason???
r=view.rad*1e3;2180.
z=view.hei*1e3;0;219.06
yaw=view.yaw*!dtor;20.66*!dtor;18.5671*!dtor
ang2=ang+yaw-!pi
pit=view.pit*!dtor;0.84*!dtor;3.93*!dtor
rol=view.rol*!dtor;-0.19*!dtor;14.35*!dtor
;stop
;ang=-250*!dtor;43.25*!dtor ; minus 1 for some reason???
;r=2420.
;z=245.
;yaw=-22*!dtor;18.5671*!dtor
;ang2=-ang+yaw
;pit=1.6*!dtor;3.93*!dtor
;rol=-0.3*!dtor;14.35*!dtor



p0=[r*cos(ang),r*sin(ang),z]

zhat=[cos(ang2)*cos(pit),sin(ang2)*cos(pit),sin(pit)] & zhat=zhat/norm(zhat)
xhat=-crossp([0,0,1],zhat) & xhat=xhat/norm(xhat)
yhat=-crossp(zhat,xhat) & yhat=yhat/norm(yhat)

; ah ! xhat and y hat did not include any "roll" of camera about its
; axis.  This is defined by xhat2,yhat2

xhat2=xhat * cos(rol) + yhat * sin(rol)
yhat2=-xhat*sin(rol) +  yhat * cos(rol)
xhat=xhat2 ; and overwrite the orinal array
yhat=yhat2

; now make these 1d arays p0,xhat,yhat,zhat 3d so that they can be
; manipulated as propoper array objects
p02=fcb & for j=0,2 do p02(j,*,*)=p0(j)
zh2=fcb & for j=0,2 do zh2(j,*,*)=zhat(j)
xh2=fcb & for j=0,2 do xh2(j,*,*)=xhat(j)
yh2=fcb & for j=0,2 do yh2(j,*,*)=yhat(j)

; define v2 as the vector between each point and the origin point
v2=fcb-p02
;stop
fcb2=fcb
; then take the dot product with respect to each direction vector
; (xh2==xhat, yh2,zh2 etc)

fcb2(0,*,*)=total(v2 * xh2,1)
fcb2(1,*,*)=total(v2 * yh2,1)
fcb2(2,*,*)=total(v2 * zh2,1)
; now fcb2 is the coordinates in the translated frame
fcb=fcb2


fcb3=fcb
;; now use the proper nonlinear transformation to calculate the x and
;; y angles as elements 0,1 and the distance as element 2
fcb3(0,*,*)=atan(fcb(0,*,*),fcb(2,*,*))
fcb3(1,*,*)=atan(fcb(1,*,*),fcb(2,*,*))
fcb3(2,*,*)=sqrt(fcb(0,*,*)^2+fcb(1,*,*)^2+fcb(2,*,*)^2)
;stop
fcb=fcb3
;stop
; finished
end



pro hidelines,fn,fout,view,dirin
;;;;; start of main program.


;; uncomment following line if you have already precomputed and want
;; to skip some lines.
;goto,ee

common czb, x2,y2,x1,y1,zb ;  common block containing z buffer.  x1,y1 are 1 1d arrays and x2,y2 are 2d arrays

; array of files to load to combine and perform processing on:

;fn=['newcc'];,'coil_lower2','coil_upper_new','coil_upper','coil_lower'];,'coil_upper_new'];,'cent_column','tae_upper','coil_lower2'];,'tae_lower'];,'tank'
;fn=['cent_column','bdump','gdc1','gdc2','coil_lower'];,'tank'

; call this routine to get the faces (fcb) and lines (lns) from the
; filename fn:
getpts, fn, fcb,lns,dir=dirin
;stop

;restore,file='~/tmp.sav'
; remember lns as lns0
lns0=lns
transc,fcb,view ; perform tranformation from world frame of reference to line of sight oriented reference.  the precise viewing geometry in structure view
transc,lns,view ;  and same on lns
;help,fcb,lns
;stop

; declare size of z buffer
nx=2001;/10
ny=2001;/10
;xr=[-2000,2000]
;yr=xr
; find bounds for z buffer
xr=minmax(fcb(0,*,*))
yr=minmax(fcb(1,*,*))
; declare x and y poisitions (1d and 2d versionx (x1, x2 )) of z
; buffer coordinates
x1=linspace(xr(0),xr(1),nx) ; this is clives routine to produce a linearly spaced array from xr(0) to xr(1) with nx points
y1=linspace(yr(0),yr(1),ny)
x2=x1 # replicate(1,ny)
y2=replicate(1,nx) # y1

; declare initial value of z buffer as large value 
; we will fill it and then take the MINIMUM z value [because positive
; z is defined as away from viewer]
fil=9e9;!values.f_nan
zb=fltarr(nx,ny) & zb(*,*)=fil

nt=n_elements(fcb(0,0,*))
; loop over number of faces and fill the z buffer with the triangles
; from each face
for i=0l,nt-1 do begin
    trg=fcb(*,*,i)

    filltri,trg
    if i mod 1000 eq 0 then print,i,nt
endfor
zbb=zb
idx=where(zb eq fil)
if idx(0) ne -1 then zbb(idx)=0 ; replace the ones which were not touched by zeros in array zbb [sinply for plotting convenience -- so the range can be scaled appropriately]
ee:

; may jump to ee from beginning as have filled the z buffer now
;trg=[[0,0,0],[100,100,10],[100,30,100.]]
;contourn2,zbb,x1,y1,/cb

;; calculate the z coofdinates from the line objects [which have
;; already been transformed into the new coordinate system] lns [revieved
;; from vrml file] .  First ix/iy is the index into the x1/y1 array
;; and then lnz is the interpolated value [by interpolating the z
;; buffer values ZB]

ix=interpol(findgen(nx),x1,reform(lns(0,*,*)))
iy=interpol(findgen(ny),y1,reform(lns(1,*,*)))
lnz=interpolate(zb,ix,iy)
; so than lnz is the z position corresponding to each point lns THAT
; WOULD BE FROM THE Z BUFFERE.  This is to be compare dwith the
; actualy lns(2,*,*) below.  
del=.1
topl=reform(lns(2,*,*)) lt lnz-del
; so topl is 1 where we want to plot it and zero where we dont.  We
; compare the z values with a small tolerance del(=0.1mm) which was
; made hard coded to account for round off error, etc.


ix=where(topl(0,*) and topl(1,*))


;ix=where(topl(0,*) or topl(1,*)) ; if either end of the lines are visible then retain the line segment


nix=n_elements(ix)
;now plot it on your screen.  First plot this to declare the plotting
;extent
;device,decomp=0
tek_color
plot,xr,yr,/nodata,/iso

lnsb=lns
for i=0l,nix-1 do oplot,lnsb(0,0:1,ix(i)),lnsb(1,0:1,ix(i)),col='00ff00'x ; now plot each line segment...


lns=lns0(*,*,ix) ;; so now index the aray lns by ix in order to get rid of semgnets which BOTH ends are not visible

save,lns,file=fout,/verb
;getpts,'alltae',fcs2,lns2
;lns=[[[lns]],[[lns2]]]
;retall

; now save but commented out until you are sure it works
;save,lns,file='~/newwrl/allobj_hidden.sav',/verb
;lns=lnsb
end

;view={ang:-250*!dtor,$
;r:2420.,$
;z:245.,$
;yaw:-22*!dtor,$
;pit:1.6*!dtor,$
;rol:-0.3*!dtor};

;hidelines,['alltae','coil_lower2'],'dum',view,'~/newwrl'
;end
