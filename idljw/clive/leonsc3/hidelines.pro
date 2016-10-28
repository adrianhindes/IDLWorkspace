@getpts
;; this is a script file to do hidden line removal.  it runs a as a
;; "main program" calling some other routines.  So start reading from
;; the main program at the bottom of the file.

function convp2c1,p
po=fltarr(3)
thtot=sqrt(p(0)^2+p(1)^2)
z=p(2) * cos(thtot)

po = [tan(p(0))*z,tan(p(1))*z,z]

return,po
end



pro filltri,trg
; this fills the z buffer with triangles define by the simple array
; trg(num of points in triangle (3), coorinate points (x,y,z) (3))

common czb, x2,y2,x1,y1,zb ; this is a common block containing the z buffer and coordinate axes of it



;;;save,x2,y2,x1,y1,zb,file='~/idl/clive/nleonw/tang_port/objhidden_zb.sav',/verb

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

p1s=convp2c1(p1)
p2s=convp2c1(p2)
p3s=convp2c1(p3)
mats=[[p1s(0),p1s(1),1],$
      [p2s(0),p2s(1),1],$
      [p3s(0),p3s(1),1]]


abc=invert(mat) ## [p1(2),p2(2),p3(2)]

abcs=invert(mats) ## [p1s(2),p2s(2),p3s(2)]
;;; abcs -- for certesian coords

;print, p1(0) * abc(0) + p1(1) * abc(1) + abc(2)

; determine X,Y extents of the triangle:
xr=minmax(trg(0,*))
yr=minmax(trg(1,*))
; convert these to indexes in the z buffer array and calc nx,ny as the
; number of points in thex/y directions of  zbuffer over which the
; triangle covers:
iu=value_locate3(x1,xr)+[-1,1]&iu=(iu>0)<(n_elements(x1)-1) & nx=iu(1)-iu(0)+1
ju=value_locate3(y1,yr)+[-1,1]&ju=(ju>0)<(n_elements(y1)-1) & ny=ju(1)-ju(0)+1
piu=(iu eq 0 or iu eq n_elements(x1)-1)
pju=(ju eq 0 or ju eq n_elements(j1)-1)
if piu(0) eq 1 and piu(1) eq 1 and pju(0) eq 1 and pju(1) eq 1 then return
;if piu(0) eq 1 or piu(1) eq 1 or pju(0) eq 1 or pju(1) eq 1 then return
;print,'iu=',iu,'ju=',ju
;zz=fltarr(nx,ny)
; sub index the x2,y2 zbuffer 2d poition arrays to only the ones whic
; are of interest:
xx=x2(iu(0):iu(1),ju(0):ju(1))
yy=y2(iu(0):iu(1),ju(0):ju(1))

;53cm round, 40cm up
; calculate the z position for this part of the z buffer
;zz2=abc(0) * xx + abc(1) * yy + abc(2)

zzc = abcs(2) / (1 - abcs(0) * tan(xx) - abcs(1) * tan(yy))
zz  = zzc / cos(sqrt(xx^2+yy^2))

;print,reform([minmax(zz),minmax(zz2)])


; detirmine which points within this "rectangular" region of interest
; are actually within the insdie of the triangle 
crit=fltarr(nx,ny,3)
done=0
s=-1
again:
for j=0,2 do begin
; jp is j+1 mod 3
    jp=(j+1) mod 3
    v=[trg(0:1,jp)-trg(0:1,j),0] ; v is vector on side of triangle
    nm=crossp(v,[0,0,s]) ; nm is normal to v
   
    xmp0=xx-trg(0,j) 
    xmp1=yy-trg(1,j)
    tmp=(xmp0 * nm(0) + xmp1 * nm(1) ) ; calculate distance for all points xx,yy from line v (signed)
    crit(*,*,j)=tmp ge 0 ; and take the ones which are positive
;    wset2,j
;    contourn2,tmp,xx(*,0),yy(0,*),/cb,pal=-2
;    plots,trg(0,*),trg(1,*),psym=4
endfor
tot=product(crit,3) ; multiply the crit for each 3 sides and where they are 1, accept
if total(tot) eq 0 and done eq 0 then begin
   done=1
   s=1
goto,again
endif

zb0=zb(iu(0):iu(1),ju(0):ju(1)) ; subscript the rectangle
zbt=zb0
ix=where(tot) ; find ones to apply
if ix(0) ne -1 then zbt(ix)=zz(ix)
cond=zbt le zb0 ; use z buffer condition :: update z buffer only if new z < old z
ip=where(cond) 
if ip(0) ne -1 then zb0(ip)=zbt(ip)

zb(iu(0):iu(1),ju(0):ju(1))=zb0 ; now replace this rectangle with the processed one.


;stop
end

pro transc, fcb,view,xhat=xhat,yhat=yhat,zhat=zhat
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
;print,'fcb2=',fcb2

fcb3=fcb
;; now use the proper nonlinear transformation to calculate the x and
;; y angles as elements 0,1 and the distance as element 2
fcb3(0,*,*)=atan(fcb(0,*,*),fcb(2,*,*))
fcb3(1,*,*)=atan(fcb(1,*,*),fcb(2,*,*))
fcb3(2,*,*)=sqrt(fcb(0,*,*)^2+fcb(1,*,*)^2+fcb(2,*,*)^2)
;stop
fcb=fcb3

;fcb2t=fcb
;fcb2t(2,*,*)=fcb3(2,*,*)/ $
;  sqrt(tan(fcb3(0,*,*))^2 + tan(fcb3(1,*,*))^2 + 1)
;fcb2t(0,*,*)=tan(fcb3(0,*,*))*fcb2t(2,*,*)
;fcb2t(1,*,*)=tan(fcb3(1,*,*))*fcb2t(2,*,*)
;print,'fcb2t=',fcb2t

; finished
end
;Solve[{thx==ArcTan[x/z],thy==ArcTan[y/z],d==Sqrt[x^2+y^2+z^2]},{x,y,z}]


pro hidelines,fn,fout,view,dirin,refmirr=refmirr
;save,fn,fout,view,dirin,file='~/t3.sav',/verb

;;;;; start of main program.
;restore,file='~/t3.sav',/ver

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

if n_elements(refmirr) ne 0 then if refmirr(0) ge 0 then begin

kay=[cos(refmirr(1)*!dtor)*cos(refmirr(2)*!dtor),sin(refmirr(1)*!dtor)*cos(refmirr(2)*!dtor),sin(refmirr(2)*!dtor)]
pc=kay * refmirr(0)*1e3


print,'reflecting about',pc,kay
   applyp0,fcb,pc
   applyref,fcb,kay
   applyp0,fcb,-pc
   
   applyp0,lns,pc
   applyref,lns,kay
   applyp0,lns,-pc
endif



;restore,file='~/tmp.sav'
; remember lns as lns0
lns0=lns
transc,fcb,view ; perform tranformation from world frame of reference to line of sight oriented reference.  the precise viewing geometry in structure view
transc,lns,view ;  and same on lns
;help,fcb,lns
lns00=lns

; declare size of z buffer
;nx=2001;/10
;ny=2001;/10
;nx=501
;ny=501
nx=1001
ny=1001
;xr=[-2000,2000]
;yr=xr
; find bounds for z buffer
xr=minmax(fcb(0,*,*))
yr=minmax(fcb(1,*,*))

    fv=0.99 ; 0.75

if max(abs(xr)) gt !pi/2*fv or max(abs(yr)) gt !pi/2*fv then begin
    xr=[-!pi/2,!pi/2]*fv
    yr=[-!pi/2,!pi/2]*fv
    print,'coord fcb range overrride'
    idx22=where(abs(fcb(0,0,*)) lt !pi/2 and $
             abs(fcb(0,1,*)) lt !pi/2 and $
             abs(fcb(0,2,*)) lt !pi/2 and $
             abs(fcb(1,0,*)) lt !pi/2 and $
             abs(fcb(1,1,*)) lt !pi/2 and $
             abs(fcb(1,2,*)) lt !pi/2) 
;    stop
    fcb=fcb(*,*,idx22)

 endif


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
    if i mod 1000 eq 0 then begin
        print,i,nt
    endif
;    if i ge 4121 then begin ;4203-100
;;        tv,bytscl(zb,max=3700,min=3400,top=256-32)+32
;        
;        contourn2,zb,x1,y1,zr=3375+[-50,50],/cb,xr=x1([50,150]),yr=y1([200,300]),/noni,xsty=1,ysty=1 ;   contourn2,zb,zr=[3400,3700],/cb,xr=[50,150],yr=[200,300]
;       print,i
;        stop
;    endif


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

for cutit=0,5 do begin ; was it
;for cutit=0,0 do begin
    ix=interpol(findgen(nx),x1,reform(lns(0,*,*)))
    iy=interpol(findgen(ny),y1,reform(lns(1,*,*)))
    lnz=interpolate(zb,ix,iy)
; so than lnz is the z position corresponding to each point lns THAT
; WOULD BE FROM THE Z BUFFERE.  This is to be compare dwith the
; actualy lns(2,*,*) below.  
    del=1.;0.1;1.e-6;'0.1;1e-6;01 ;.1 ; was .1
    topl=(reform(lns(2,*,*)) lt lnz+del) and (abs(lns(0,*,*)) lt !pi/2*fv) and (abs(lns(1,*,*)) lt !pi/2*fv)
; so topl is 1 where we want to plot it and zero where we dont.  We
; compare the z values with a small tolerance del(=0.1mm) which was
; made hard coded to account for round off error, etc.
;    stop

    ix=where(topl(0,*) and topl(1,*))
    
    icut=where(topl(0,*) xor topl(1,*))
;    icut=findgen(n_elements(lns(0,0,*)))
;    icut(0)=-1
    if icut(0) ne -1 then begin
        nlns=n_elements(lns(0,0,*))
        nicut=n_elements(icut)
        print,'cutit=',cutit,'; nlns=',nlns
        lns0=[[[lns0]],[[fltarr(3,2,nicut)]]]
        lns=[[[lns]],[[fltarr(3,2,nicut)]]]
        for i=0,nicut-1 do begin
            midp= (lns(*,0,icut(i)) + lns(*,1,icut(i)) ) / 2.
            endp= lns(*,1,icut(i))
            lns(*,1,icut(i))=midp
            lns(*,0,nlns+i)=midp
            lns(*,1,nlns+i)=endp
            
            midp= (lns0(*,0,icut(i)) + lns0(*,1,icut(i)) ) / 2.
            endp= lns0(*,1,icut(i))
            lns0(*,1,icut(i))=midp
            lns0(*,0,nlns+i)=midp
            lns0(*,1,nlns+i)=endp
;        print,i,sqrt(total(midp-endp)^2)
        endfor
        
    endif
    
endfor



;ix=where(topl(0,*) or topl(1,*)) ; if either end of the lines are visible then retain the line segment


nix=n_elements(ix)
;now plot it on your screen.  First plot this to declare the plotting
;extent
;device,decomp=0
tek_color
plot,xr,yr,/nodata,/iso
imgplot,zb,x1,y1,zr=[0,4000]
lnsb=lns
for i=0l,nix-1 do oplot,lnsb(0,0:1,ix(i)),lnsb(1,0:1,ix(i)),col='00ff00'x ; now plot each line segment...

;cursor,dx,dy,/down

;for i=0l,n_elements(lns00(0,0,*))-1 do oplot,lns00(0,0:1,(i)),lns00(1,0:1,(i)),col='ff0000'x ; now plot each line segment...


lns=lns0(*,*,ix) ;; so now index the aray lns by ix in order to get rid of semgnets which BOTH ends are not visible

save,lns,file=fout,/verb
dum=strsplit(fout,'.',/extr)    
fout2=dum(0)+'_zb'+'.sav'
save, x2,y2,x1,y1,zb,file=fout2,/verb
;getpts,'alltae',fcs2,lns2
;lns=[[[lns]],[[lns2]]]
;retall

; now save but commented out until you are sure it works
;save,lns,file='~/newwrl/allobj_hidden.sav',/verb
;lns=lnsb
;stop 
;cursor,dx,dy,/down
end

;view={ang:-250*!dtor,$
;r:2420.,$
;z:245.,$
;yaw:-22*!dtor,$
;pit:1.6*!dtor,$
;rol:-0.3*!dtor};

;hidelines,['alltae','coil_lower2'],'dum',view,'~/newwrl'
;end
